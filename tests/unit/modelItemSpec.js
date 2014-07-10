"use strict"

/* jasmine specs for services go here */

describe('service', function() {
    beforeEach(module('dhpNgModel'));

    describe('ModelItem', function() {
        it('should delete the item', inject(function(Request, model, modelItem, $httpBackend) {
            $httpBackend.expect('DELETE','/user/1').respond(200, 'delete response');
            var d = modelItem(model('user'),{"id":1}, Request).$delete();
            expect(d.$isDeleted()).toEqual(false);
            $httpBackend.flush();
            expect(d.$isDeleted()).toEqual(true);
            $httpBackend.expect('POST','/user/1').respond(200, '');
            d.$save();
            $httpBackend.flush();
            expect(d.$isDeleted()).toEqual(false);
        }));
        it('should have the correct data', inject(function(modelItem, model, Request) {
            var d = modelItem(model('user'),{"id":1, "name": "Henrik"}, Request);
            expect(d.$getData()).toEqual({"id":1, "name": "Henrik"});
            expect(d.$update({"name":"Henrik Pejer"}).$getData()).toEqual({"id":1, "name": "Henrik Pejer"});
        }));
        it('should update the data', inject(function(modelItem, model, $httpBackend, Request) {
            var d = modelItem(model('user'),{"id":1, "name": "Henrik Pejer"},Request);

            $httpBackend.expectPOST('/user/1',{"id":1, "name": "Henrik Pejer"}).respond(200, 'postData');
            d.$save();
            $httpBackend.flush();

            $httpBackend.expectPOST('/user/1',{"id":1, "name": "Henrik"}).respond(200, 'postData');
            d.$update({"name":"Henrik"});
            $httpBackend.flush();
        }));
        it('should update the data', inject(function(Request, modelItem, model, $httpBackend) {
            $httpBackend.expectPOST('/user/1').respond(200, 'postData');
            modelItem(model('user'),{"id":1, "name": "Henrik Pejer"},Request,{"idField": "id"}).$update({"name":"Henke"})
            $httpBackend.flush();
        }));
    });
});