"use strict"

/* jasmine specs for services go here */

describe('service', function () {
    beforeEach(module('dhpNgModel'));

    describe('Request module', function () {
        it('should make correct get request with correct model & id', inject(function (Request, $httpBackend, $http, model) {
            var model = model('user');
            var result = null;
            $httpBackend.expectGET('/user/1').respond(200, 'Result from fake request');
            Request.get(model, 1).then(function (d) {
                result = d;
            });
            $httpBackend.flush();
            expect(result).toEqual('Result from fake request');
            $httpBackend.expectGET('/user/1?t=5').respond(200, 'Result from fake request');
            Request.get(model, 1,{"t":"5"}).then(function (d) {
                result = d;
            });
            $httpBackend.flush();
            expect(result).toEqual('Result from fake request');
        }));
        it('should make correct get request with string id', inject(function (Request, $httpBackend, $http, model) {
            var model = model('user');
            var result = null;
            $httpBackend.expectGET('/user/henrik').respond(200, 'Another result from fake request');
            Request.get(model, 'henrik').then(function (d) {
                result = d;
            });
            $httpBackend.flush();
            expect(result).toEqual('Another result from fake request');
        }));
        it('should make a request with multiple ids as an "array"', inject(function (Request, $httpBackend, $http, model) {
            var model = model('user');
            var result = null;
            $httpBackend.expectGET('/user/[1,99,201]').respond(200, 'array of objects');
            Request.get(model, [1, 99, 201]).then(function (d) {
                result = d;
            });
            $httpBackend.flush();
            expect(result).toEqual('array of objects');
        }));
        it('should make correct post request', inject(function (Request, $httpBackend, $http, model) {
            var model = model('user');
            var result = null;
            $httpBackend.expectPOST('/user/1').respond(200, 'postData');
            Request.post(model, 1, {"user": "henrik"}).then(function (d) {
                result = d;
            });
            $httpBackend.flush();
            expect(result).toEqual('postData');
            $httpBackend.expectPOST('/user/1?p=g').respond(200, 'postData with params');
            Request.post(model, 1, {"user": "henrik"},{"p":"g"}).then(function (d) {
                result = d;
            });
            $httpBackend.flush();
            expect(result).toEqual('postData with params');
        }));
        it('should make default get request with no parameters', inject(function (Request, $httpBackend, $http, model) {
            var model = model('user');
            var result = null;
            $httpBackend.expectGET('/user/').respond(200, 'default request data');
            Request.__request('user/').then(function(d){
                result = d;
            });
            $httpBackend.flush();
            expect(result).toEqual('default request data');

        }));
        it('should make put request', inject(function (Request, $httpBackend, $http, model) {
            var model = model('user');
            var result = null;
            $httpBackend.expect('PUT','/user/1').respond(200, 'put response');
            Request.put(model,1,{"data":"toPut"}).then(function(d){
                result = d;
            });
            $httpBackend.flush();
            expect(result).toEqual('put response');
        }));
        it('should make delete request', inject(function (Request, $httpBackend, $http, model) {
            var model = model('user');
            var result = null;
            $httpBackend.expect('DELETE','/user/1').respond(200, 'delete response');
            Request.delete(model,1).then(function(d){
                result = d;
            });
            $httpBackend.flush();
            expect(result).toEqual('delete response');
        }));
        it('should handle failure requests', inject(function (Request, $httpBackend, $http, model) {
            var model = model('user');
            var result = null;
            $httpBackend.expectGET('/user/1').respond(500);
            Request.get(model,1).then(function(){
                result = 'Wrongfully this method got called';
            },function(d){
                result = 'ERROR: ' + d;
            });
            $httpBackend.flush();
            expect(result).toEqual('ERROR: 500');
        }));
    });
});