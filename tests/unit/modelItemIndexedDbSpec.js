"use strict"

/* jasmine specs for services go here */

describe('service', function() {
    beforeEach(module('dhpNgModel'));

    describe('ModelItemIndexDb', function() {
        it('should delete the item', inject(function(Request, model, modelItem,ModelItemIndexDb, $httpBackend, $rootScope,indexedDB) {
            $httpBackend.expect('POST','/user/666').respond(200);
            var d = ModelItemIndexDb(model('user'), Request,{"id":666})
            // $delete();
            expect(d.$isDeleted()).toEqual(false);
            d.$save();
            $httpBackend.flush();

            var isDone = false;
            runs(function(){
                if(!indexedDB.available()){
                    $rootScope.$apply();$rootScope.$apply();$rootScope.$apply();$rootScope.$apply();$rootScope.$apply();$rootScope.$apply();
                    isDone = true;
                } else {
                    setTimeout(function(){
                        $rootScope.$apply();
                        setTimeout(function(){
                            $rootScope.$apply();
                            setTimeout(function(){
                                $rootScope.$apply();
                                setTimeout(function(){
                                    $rootScope.$apply();
                                    isDone = true;
                                }, 100)
                            }, 100)
                        }, 100)
                    }, 100)
                }
            });
            waitsFor(function(){
                return isDone;
            })
            runs(function(){
                isDone = false;
                $httpBackend.expect('DELETE','/user/666').respond(200);
                d.$delete();
                $httpBackend.flush();
                setTimeout(function(){
                    $rootScope.$apply();
                    setTimeout(function(){
                        $rootScope.$apply();
                        setTimeout(function(){
                            $rootScope.$apply();
                            setTimeout(function(){
                                $rootScope.$apply();
                                setTimeout(function(){
                                    $rootScope.$apply();
                                    setTimeout(function(){
                                        $rootScope.$apply();
                                        isDone = true;
                                    }, 100)
                                }, 100)
                            }, 100)
                        }, 100)
                    }, 100)
                }, 100)
            })
            waitsFor(function(){
                return isDone;
            })
            runs(function(){
                expect(d.$isDeleted()).toEqual(true);
                $httpBackend.expect('POST','/user/666').respond(200);
                d.$save();
                $httpBackend.flush();
                expect(d.$isDeleted()).toEqual(false);
            })
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
    });
});