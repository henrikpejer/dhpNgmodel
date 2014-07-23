"use strict"

/* jasmine specs for services go here */

describe('service', function() {
    beforeEach(module('dhpNgModel'));

    describe('ModelItemIndexDb', function() {
        it('should delete the item', inject(function(Request, model, modelItem,ModelItemIndexDb, $httpBackend) {
            $httpBackend.expect('DELETE','/user/1').respond(200, 'delete response');
            var d = ModelItemIndexDb(model('user'), Request,{"id":1}).$delete();
            expect(d.$isDeleted()).toEqual(false);
            $httpBackend.flush();
            expect(d.$isDeleted()).toEqual(true);
            $httpBackend.expect('POST','/user/1').respond(200, '');
            d.$save();
            $httpBackend.flush();
            expect(d.$isDeleted()).toEqual(false);
        }));
        it('should have the correct data', inject(function(modelItem, model, ModelItemIndexDb,Request) {
            var d = ModelItemIndexDb(model('user'), Request,{"id":1, "name": "Henrik"});
            expect(d.name).toEqual("Henrik");
            expect(d.$update({"name":"Henrik Pejer"}).name).toEqual("Henrik Pejer");
        }));
        it('should update the data', inject(function(modelItem, model, $httpBackend, ModelItemIndexDb,Request) {
            var d = ModelItemIndexDb(model('user'),Request,{"id":1, "name": "Henrik Pejer"});

            $httpBackend.expectPOST('/user/1',{"id":1, "name": "Henrik Pejer"}).respond(200);
            d.$save();
            $httpBackend.flush();

            $httpBackend.expectPOST('/user/1',{"id":1, "name": "Henrik"}).respond(200);
            d.$update({"name":"Henrik"});
            $httpBackend.flush();
        }));
        it('should update the data', inject(function(Request, modelItem, model, ModelItemIndexDb,$httpBackend) {
            $httpBackend.expectPOST('/user/1').respond(200);
            ModelItemIndexDb(model('user'),Request,{"id":1, "name": "Henrik Pejer"},{"idField": "id"}).$update({"name":"Henke"})
            $httpBackend.flush();
        }));
        it('should create a new uuid every time',inject(function(Request, modelItem, model, ModelItemIndexDb,$httpBackend){
            $httpBackend.expectPOST('/user/1').respond(200);
            var g = ModelItemIndexDb(model('user'),Request,{"id":1, "name": "Henrik Pejer"},{"idField": "id"});
            var uuid1 = g.$createUUID();
            var uuid2 = g.$createUUID();
            expect(uuid1 == uuid2).toEqual(false)
            g.$save();
            $httpBackend.flush();
        }));
    });
});