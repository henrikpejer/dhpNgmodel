"use strict"

/* jasmine specs for services go here */

describe('service', function () {
    beforeEach(module('dhpNgModel'));
    afterEach(function () {
        // window.indexedDB.deleteDatabase('dhpNgModelStore')
    });

    describe('indexedDB', function () {
        it('should save the correct value', inject(function (indexedDB, $rootScope) {
            var con = false;
            var o = {
                "id": 1,
                "name": "Henrik Pejer"
            }
            indexedDB.insert('user/1', o);
            setTimeout(function(){
                $rootScope.$apply();
                con = true;
            },1000)


            waitsFor(
                function(){
                    return con
                }
                ,"Error!!!",2000
            );
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