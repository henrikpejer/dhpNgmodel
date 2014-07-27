"use strict"

/* jasmine specs for services go here */

describe('service', function () {
    beforeEach(function(){
        // window.indexedDB.deleteDatabase('dhpNgModelStore');
        module('dhpNgModel');
        // indexedDB.close();
    });

    describe('indexedDB', function () {
        it('should save, update and delete the correct value', inject(function (indexedDB, $rootScope) {
            var con = false;
            var o = {
                "id": 1,
                "name": "Henrik Pejer"
            }
            var savedPost;
            var uuidPost;
            var post;
            var uuid;
            var updatedPost = "not changed";
            var updatedo;
            if (indexedDB.available() == false){
                return true;
            }
            expect(indexedDB.available()).toBe(true);
            runs(function(){
                indexedDB.close();
                indexedDB.save(o,'user/1').then(function(d){
                    uuid = d.$uuid;
                    updatedo = o;
                    updatedo.name = 'Updated Henrik Pejer'
                    indexedDB.save(updatedo);
                });

                setTimeout(function(){
                    $rootScope.$apply();
                    var openRequest = window.indexedDB.open("dhpNgModelStore");
                    openRequest.onsuccess = function(){
                        var db = openRequest.result;
                        savedPost = db.objectStoreNames;
                        indexedDB.get('user/1').then(function(d){
                            post = d;
                        });
                        indexedDB.get(uuid).then(function(d){
                            uuidPost = d;
                        });
                        setTimeout(function(){
                            $rootScope.$apply();
                            setTimeout(function(){
                                $rootScope.$apply();
                                setTimeout(function(){
                                    $rootScope.$apply();
                                    setTimeout(function(){
                                        $rootScope.$apply();
                                        con = true;
                                    }, 100)
                                }, 100)
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
                expect(savedPost[0]).toBe("dataStore");
                expect(savedPost[1]).toBe("urlIndex");
                expect(post.id).toBe(1);
                expect(post.name).toBe("Updated Henrik Pejer");
                expect(uuidPost.id).toBe(1);
                expect(uuidPost.name).toBe("Updated Henrik Pejer");
                expect(uuidPost).toEqual(post);
                con = false;
                indexedDB.delete(post);
                setTimeout(function(){
                    $rootScope.$apply();
                    indexedDB.get(uuid).then(function(d){
                            updatedPost = d;
                        },
                        function(){
                            updatedPost = true
                        }
                    )
                    setTimeout(function(){
                            $rootScope.$apply();
                            setTimeout(function(){
                                    $rootScope.$apply();
                                    setTimeout(function(){
                                            $rootScope.$apply();
                                            setTimeout(function(){
                                                    $rootScope.$apply();
                                                    con = true;
                                                }
                                                ,100);
                                        }
                                        ,100);
                                }
                                ,100);
                        }
                        ,100);
                },100);
            })
            waitsFor(
                function(){
                    return con
                }
                ,"Error - $rootScope.$apply didn't run properly",3000
            )
            runs(function(){
                expect(updatedPost).toBe(true)
            })
        }));
    });
});