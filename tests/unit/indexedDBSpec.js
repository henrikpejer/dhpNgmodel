"use strict"

/* jasmine specs for services go here */

describe('service', function () {
    beforeEach(function(){
        window.indexedDB.deleteDatabase('dhpNgModelStore');
        module('dhpNgModel');
        // indexedDB.close();
    });

    describe('indexedDB', function () {
        iit('should save the correct value', inject(function (indexedDB, $rootScope) {
            var con = false;
            var o = {
                "id": 1,
                "name": "Henrik Pejer"
            }
            var something;
            var post;
            runs(function(){
                indexedDB.close();
                indexedDB.insert('user/1', o);
                setTimeout(function(){
                    $rootScope.$apply();

                    var openRequest = window.indexedDB.open("dhpNgModelStore");
                    openRequest.onsuccess = function(){
                        var db = openRequest.result;
                        something = db.objectStoreNames;
                        indexedDB.get('user/1').then(function(d){
                            post = d;
                        });
                        setTimeout(function(){
                            $rootScope.$apply();
                            setTimeout(function(){
                                $rootScope.$apply();
                                con = true;
                            }, 100)
                        }, 100)
                    }

                    openRequest.onerror = function(){
                        con = true;
                    }

                },100);
            })

            waitsFor(
                function(){
                    return con
                }
                ,"Error - $rootScope.$apply didn't run properly",3000
            );
            runs(function(){
                expect(something[0]).toBe("dataStore");
                expect(something[1]).toBe("urlIndex");
                expect(post.id).toBe(1);
                expect(post.name).toBe("Henrik Pejer");

            })
        }));
        it('should fetch from correct store depending on key',inject(function(indexedDB, $rootScope){
            indexedDB.get('user/1');
            indexedDB.get('620a4517-caff-4b5a-a662-a8ef8f3a7317');
        }));
        /*it('should save the correct value', inject(function (indexedDB, $rootScope) {
            var con = false;
            var o = {
                "id": 1,
                "name": "Henrik Pejer"
            }
            indexedDB["delete"]('user/1');
            runs(function(){
                setTimeout(function(){
                    $rootScope.$apply();
                    con = true;
                },1000)
            });
            waitsFor(
                function(){
                    return con
                }
                ,"Error!!!",2000
            );

        }));*/
    });
});