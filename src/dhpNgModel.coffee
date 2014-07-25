"use strict"
###
    How do I want to play this...?
    model('user').find()

    user = model('user').get({"id":1}).find()
    user.delete()
    user.update({name:values})....

    return should be a promise that will be populated once the return data is complete
###

angular.module("dhpNgModel", ['dhpNgModelConfiguration']);
angular.module("dhpNgModel").factory("model", ['Request', '$q', 'indexedDB',(Request, $q,indexedDB)->
    modelCache = {}
    modelFn = (model)->
        ret = null
        if modelCache[model]?
            ret = modelCache[model]
        else
            ret = new Model(model, Request, $q, indexedDB)
            modelCache[model] = ret
        ret
    modelFn
])

angular.module("dhpNgModel").factory("modelItem", ['Request', (Request)->
    modelItemFn = (model, Request, data, config = null)->
        new ModelItem(model, Request, data, config)
    modelItemFn
])

angular.module("dhpNgModel").factory("ModelItemIndexDb", ['Request','indexedDB', (Request, indexedDB)->
    modelItemFn = (model, Request, data, config = null)->
        new ModelItemIndexDb(model, Request, data, config, indexedDB)
    modelItemFn
])

angular.module("dhpNgModel").service("Request", ['$http', '$q', 'BASE_URL', ($http, $q, BASE_URL)->
    new ModelRequest($http, $q, BASE_URL)
])

# todo : implement clever error handling for these!
# todo : implement promises for these!
angular.module("dhpNgModel").service("indexedDB",['$q',($q)->
    dbToOpen = "dhpNgModelStore"
    version = 1
    db = null
    setUp = false
    stores = {
    "urlIndex":
        schema:
            autoIncrement:true
        indexes:
            "url": [
                "url",
                {unique:true}
            ]
    "dataStore":
        schema:
            unique:true
            keyPath: '$uuid'

    }
    get = (key)->
        deferred = $q.defer()
        if available() is false
            deferred.reject "indexedDB not available"
            return deferred.promise
        if key is undefined
            deferred.reject false
            return deferred.promise
        if key.indexOf('/') is -1
            getItem(key,'dataStore').then(
                (d)->
                    if d is undefined
                        deferred.reject false
                    else
                        deferred.resolve d
                (event)->
                    deferred.reject event
            );
        else
            getItem(key,'urlIndex').then(
                (d)->
                    getItem(d, 'dataStore').then(
                        (d)->
                            deferred.resolve d
                        (event)->
                            deferred.reject event
                    )
            );
        deferred.promise

    getItem = (key, storeName)->
        deferred = $q.defer()
        if available() is false
            deferred.reject "indexedDB not available"
            return deferred
        connect().then ()->
            transaction = db.transaction [storeName], "readwrite"
            OS = transaction.objectStore storeName
            res = OS.get(key)
            res.onsuccess = (event)->
                deferred.resolve res.result

            res.onerror = (event)->
                deferred.reject event

        deferred.promise
    close = ()->
        if setUp is true
            db.close()

    clear = ()->
        # remove database
        db.deleteObjectStore("ObjectStore_BookList");
        close()
    deleteItem = (o)->
        deferred = $q.defer()
        connect().then ()->
            urlTransaction = db.transaction(['urlIndex'], "readwrite")
                                .objectStore('urlIndex')
                                .delete(o.$urlKey)

            urlTransaction.onerror = (event)->
                deferred.reject event

            urlTransaction.onsuccess = (event)->
                dataTransaction = db.transaction(['dataStore'], "readwrite")
                                    .objectStore('dataStore')
                                    .delete(o.$uuid)

                dataTransaction.onsuccess = (event)->
                    deferred.resolve true

                dataTransaction.onerror = (event)->
                    console.log "Unable to erase", event
                    deferred.reject event
        deferred.promise
    save = (data, urlKey = null)->
        deferred = $q.defer()
        newData = null
        connect().then(
            ()->
                if !db? || !db.transaction?
                    deferred.reject false
                    return deferred.promise
                if data.$uuid? && data.$urlKey?
                    uuid = data.$uuid
                    newData = false
                else
                    uuid = UUID();
                    data.$uuid = uuid   # add it to the object... just because, right?
                    data.$urlKey = urlKey
                    newData = true;

                dataToSave = angular.copy data
                for k,v of dataToSave
                    if angular.isFunction(v) || (k.indexOf('$') is 0 && (k != '$uuid' && k != '$urlKey'))
                        delete dataToSave[k]
                try
                    if newData is true
                        transaction = db.transaction ['urlIndex'], "readwrite"
                                        .objectStore "urlIndex"
                                        .add uuid, dataToSave.$urlKey

                        transaction = db.transaction ['dataStore'], "readwrite"
                                        .objectStore "dataStore"
                                        .add dataToSave
                    else
                        transaction = db.transaction ['dataStore'], "readwrite"
                                        .objectStore "dataStore"
                                        .put dataToSave
                catch error
                    switch error.code
                        when 25
                            deferred.reject error  # object exists: clone
                        else
                            console.log "Uncaught error type", error
                deferred.resolve data
        );
        deferred.promise
    UUID = ()->
        # from http://bit.ly/HkAnFi
        # http://www.ietf.org/rfc/rfc4122.txt
        s = []
        hexDigits = "0123456789abcdef";
        for i in [0..35]
            s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1)
        s[14] = "4" # bits 12-15 of the time_hi_and_version field to 0010
        s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1) # bits 6-7 of the clock_seq_hi_and_reserved to 01
        s[8] = s[13] = s[18] = s[23] = "-"
        s.join("");

    connect = ()->
        deferred = $q.defer()
        if setUp is true
            deferred.resolve true
            return deferred.promise
        if available() is false
            deferred.reject "indexedDB not available"
            return deferred
        openRequest = window.indexedDB.open(dbToOpen, version)
        openRequest.onupgradeneeded = (event)->
            db = event.target.result
            upgrade()
            deferred.resolve true
        openRequest.onblocked = (event)->
            console.log "blocked"
        openRequest.onsuccess = (event)->
            db = event.target.result
            db.onerror = (event)->
                deferred.reject "Database error: " + event.target.errorCode
            setUp = true
            deferred.resolve true
        # deferred.resolve true
        deferred.promise
    upgrade = ()->
        for indexName, indexData of stores
            if indexData.schema?
                obStore = db.createObjectStore indexName, indexData.schema
            if indexData.indexes?
                for indexName, indexData in indexData.indexes
                    obStore.createIndex indexName, indexData[0], indexData[1]

    available = ()->
        window.indexedDB?

    {
    save: save
    delete: deleteItem
    get: get
    close: close
    available: available
    clear:clear
    }
])
class Model
    constructor: (@model, @request, @$q,@indexedDB)->
    find: ()->
        "finding " + @model
    setModel: (@model)->
        @
    __parseResponse: (responseData)-> # todo: parse data and return it: return should be an array of objects, always, right?
        responseData
    getModel: ()->
        @model
    get: (id = null)->
        d = @$q.defer()
        @request.get(@, id).then(
            (data)=>
                parsedData = @__parseResponse(data)
                if parsedData.meta? && parsedData.data?
                    returnData = {}
                    for modelName, modelData of parsedData.data
                        returnData[modelName] = []
                        for data in modelData
                            # todo : gotta find a more elegant solution to the new Model problem
                            if window.indexedDB
                                returnData[modelName].push(new ModelItemIndexDb(new Model(modelName, @request, @q, @indexedDB),
                                  @request, data,null,@indexedDB))
                            else
                                returnData[modelName].push(new ModelItem(new Model(modelName, @request, @q), @request,
                                  data))
                else
                    returnData = parsedData
                d.resolve(returnData)
            (reason)=>
                d.reject(reason)
        )
        d.promise
    new: (data = {})->
        new ModelItem @, @request, data

class ModelItem
    constructor: (@$model, @$request, data = {}, @$config = {"idField": "id"})->
        @$setData data
    $delete: ()->
        @$promise = @$request.delete(@$model, @$id).then(()=>
            @$deleted = true
        )
        @
    $update: (data)->
        angular.extend @, data
        @$save()
    $save: ()->
        # check... if we have a idField set ? and use that as $id?
        @$checkForId()
        @$promise = @$request.post(@$model, @$id, @).then((data)=>
            @$setData data
        )
        @
    $setData: (data)->
        angular.extend @, data
        if data? and data[@$config["idField"]]?
            @$id = data[@$config["idField"]]
        @$deleted = false;
        @
    $isDeleted: ()->
        @$deleted
    $checkForId: ()->
        if !@$id? && @id
            @$id = @id
    $getId: ()->
        @$checkForId()
        @$model.getModel() + '/' + @$id

class ModelRequest
    config:
        baseUrl: '/'
    # config for the request object
    constructor: (@$http, @$q, base_url)->
        @config.baseUrl = base_url
    get: (model, id, params = null)->
        @__request(model, id, 'GET', params)
    post: (model, id, data, params = null)->
        @__request(model, id, 'POST', params, data)
    put: (model, id, data)->
        @__request(model, id, 'PUT', null, data)
    delete: (model, id)->
        @__request(model, id, 'DELETE')
    __request: (model, id, method = 'GET', params = null, data = null)->
        # todo: check with indexed db storage to see if we have something that is requested - then we can use indexedDB data instead
        deferred = @$q.defer();
        url = model.getModel() + '/' + @__parseId(id)
        @$http({
            url: @config.baseUrl + url
            method: method
            params: params
            data: @__sanitizeData data
            cache: true
            transformRequest: @__transformRequest
            transformResponse: @__transformResponse
        })
        .success (data, status, headers, config)=>
                @__successRequest(deferred, data, status, headers, config)
        .error (data, status, headers, config)=>
                @__errorRequest(deferred, data, status, headers, config)
        deferred.promise
    __sanitizeData: (data)->
        angular.toJson data
    __parseId: (id)->
        if !id?
            id = ''
        if angular.isArray id
            ret = '['
            angular.forEach(id, (value)->
                ret = ret + value + ','
            )
            ret = ret.substr(0, (ret.length - 1)) + ']'
            return ret
        id
    __transformRequest: (data)-> # , headers
        data
    __transformResponse: (data)-> # , headers
        try
            jsonAttempt = angular.fromJson(data)
            return jsonAttempt
        data
    __successRequest: (deferred, data)-> # , status, headers, config
        deferred.resolve data
    __errorRequest: (deferred, data, status)-> # , headers, config
        deferred.reject status


###
    Exends modelItem with indexDb methods

    This should create an object that encapsulates the data we want to save
    so we have values that say if it has been saved to the database...?

    dbtable: objects
    key: uuid
    data: {
        data: {
            <actuall data of object>
        }
        savedToDatabase: if this is saved to database or not
    }

    dbtable: dbobj
    key: modelName/objectId
    data: {
        uuid: uuid
    }

    this table connects uri to uuid. Used for looking up uri to local data and make sure we should use indexdb or not
###
class ModelItemIndexDb extends ModelItem
    constructor: (@$model, @$request, data = {}, @$config = {"idField": "id"}, @$indexedDB)->
        super
    $delete: ()-> # remove from indexedDb?
        super
    $update: ()->   # update, set savedtodb on success
        super
    $save: ()-> # save, set savedtodb on success
        super
        @$promise.then (data)=>
            @$indexedDB.save @, @$getId()
        @
    $isDeleted: ()->
        super
    $createUUID: ()->
        # from http://bit.ly/HkAnFi
        # http://www.ietf.org/rfc/rfc4122.txt
        s = []
        hexDigits = "0123456789abcdef";
        for i in [0..35]
            s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1)
        s[14] = "4" # bits 12-15 of the time_hi_and_version field to 0010
        s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1) # bits 6-7 of the clock_seq_hi_and_reserved to 01
        s[8] = s[13] = s[18] = s[23] = "-"
        s.join("");
