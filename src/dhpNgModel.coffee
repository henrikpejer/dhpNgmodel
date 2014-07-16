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
angular.module("dhpNgModel").factory("model", ['Request', '$q', (Request, $q)->
    modelCache = {}
    modelFn = (model)->
        ret = null
        if modelCache[model]?
            ret = modelCache[model]
        else
            ret = new Model(model, Request, $q)
            modelCache[model] = ret
        ret
    modelFn
])

angular.module("dhpNgModel").factory("modelItem", ['Request', (Request)->
    modelItemFn = (model, data, Request, config = null)->
        new ModelItem(model, data, Request, config)
    modelItemFn
])

angular.module("dhpNgModel").factory("ModelItemIndexDb", ['Request', (Request)->
    modelItemFn = (model, data, Request, config = null)->
        new ModelItemIndexDb(model, data, Request, config)
    modelItemFn
])

angular.module("dhpNgModel").service("Request", ['$http', '$q', 'BASE_URL', ($http, $q, BASE_URL)->
    new ModelRequest($http, $q, BASE_URL)
])

class Model
    constructor: (@model, @request, @$q)->
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
                d.resolve(new ModelItem(@, parsedData, @request))
            (reason)=>
                d.reject(reason)
        )
        d.promise
    new: (data = {})->
        new ModelItem @, data, @request

class ModelItem
    constructor: (@$model, data = {}, @$request, @$config = {"idField": "id"})->
        @$setData data
    $delete: ()->
        @$request.delete(@$model, @$id).then(()=>
            @$deleted = true
        )
        @
    $update: (data)->
        angular.extend @, data
        @$save()
    $save: ()->
        @$request.post(@$model, @$id, @).then((data)=>
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

class ModelRequest
    config:
        baseUrl: '/'
    # config for the request object
    constructor: (@$http, @$q, base_url)->
        @config.baseUrl = base_url
    get: (model, id, params = null)->
        @__request(model.getModel() + '/' + @__parseId(id), 'GET', params)
    post: (model, id, data, params = null)->
        @__request(model.getModel() + '/' + @__parseId(id), 'POST', params, data)
    put: (model, id, data)->
        @__request(model.getModel() + '/' + @__parseId(id), 'PUT', null, data)
    delete: (model, id)->
        @__request(model.getModel() + '/' + @__parseId(id), 'DELETE')
    __request: (url, method = 'GET', params = null, data = null)->
        deferred = @$q.defer();
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
    constructor: ()->
        super
    $delete: ()-> # remove from indexedDb?
        super
    $update: ()->   # update, set savedtodb on success
        super
    $save: ()-> # save, set savedtodb on success
        super
    $getData: ()-> # get, set savedtodb on success
        super
    $isDeleted: ()->
        super
    createUUID: ()->
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