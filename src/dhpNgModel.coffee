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
    modelFn = (model)->
        new Model(model, Request, $q)
    modelFn
])

angular.module("dhpNgModel").factory("modelItem", ['Request', (Request)->
    modelItemFn = (model, data, Request, config = null)->
        new ModelItem(model, data, Request, config)
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
                d.resolve(new ModelItem(@,parsedData,@request))
            (reason)=>
                d.reject(reason)
        )
        d.promise

class ModelItem
    constructor: (@model, @data, @request, @config = {"idField": "id"})->
        @id = @data[@config["idField"]]
        @deleted = false;
    $delete: ()->
        @request.delete(@model, @id).then(()=>
            @deleted = true
        )
        @
    $update: (data)->
        angular.extend @data, data
        @$save()
    $save: ()->
        @request.post(@model, @id, @data).then(()=>
            @deleted = false
        )
        @
    $getData: ()->
        @data
    $isDeleted: ()->
        @deleted

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
            data: data
            cache: true
            # transformRequest: @__transformRequest
            transformResponse: @__transformResponse
        })
        .success (data, status, headers, config)=>
                @__successRequest(deferred, data, status, headers, config)
        .error (data, status, headers, config)=>
                @__errorRequest(deferred, data, status, headers, config)
        deferred.promise
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
    __transformRequest: (data, headers)->
        data
    __transformResponse: (data, headers)->
        try
            jsonAttempt = angular.fromJson(data)
            return jsonAttempt
        data
    __successRequest: (deferred, data, status, headers, config)->
        deferred.resolve data
    __errorRequest: (deferred, data, status, headers, config)->
        deferred.reject status

class ModelIndexdb
    constructor: (@namespace, @version = 1)->
    get: (table, id)->
    filter: (table, filters)->