"use strict"

/* jasmine specs for services go here */

describe('service', function() {
    beforeEach(module('dhpNgModel'));

    describe('ModelItem', function() {
        it('should delete the item', inject(function(Request, model, modelItem, $httpBackend) {
            $httpBackend.expect('DELETE','/user/1').respond(200, 'delete response');
            var d = modelItem(model('user'), Request,{"id":1}).$delete();
            expect(d.$isDeleted()).toEqual(false);
            $httpBackend.flush();
            expect(d.$isDeleted()).toEqual(true);
            $httpBackend.expect('POST','/user/1').respond(200, '');
            d.$save();
            $httpBackend.flush();
            expect(d.$isDeleted()).toEqual(false);
        }));
        it('should have the correct data', inject(function(modelItem, model, Request) {
            var d = modelItem(model('user'), Request, {"id":1, "name": "Henrik"});
            expect(d.id).toEqual(1);
            expect(d.name).toEqual("Henrik");
            expect(d.$update({"name":"Henrik Pejer"}).name).toEqual("Henrik Pejer");
        }));
        it('should update the data', inject(function(modelItem, model, $httpBackend, Request) {
            var d = modelItem(model('user'), Request,{"id":1, "name": "Henrik Pejer"});

            $httpBackend.expectPOST('/user/1',{"id":1, "name": "Henrik Pejer"}).respond(200);
            d.$save();
            $httpBackend.flush();

            $httpBackend.expectPOST('/user/1',{"id":1, "name": "Henrik"}).respond(200);
            d.$update({"name":"Henrik"});
            $httpBackend.flush();
        }));
        it('should update the data with custom id field', inject(function(Request, modelItem, model, $httpBackend) {
            $httpBackend.expectPOST('/user/1', {'di': 1, "name": "Henke"}).respond(200);
            modelItem(model('user'), Request,{"di":1, "name": "Henrik Pejer"},{"idField": "di"}).$update({"name":"Henke"})
            $httpBackend.flush();
        }));
        it('should create an empty model item when data is null',inject(function(Request, modelItem, model, $httpBackend){
            var user = modelItem(new model('user'), Request);
            expect(user.name).toEqual(null);
        }));
    });
});