using ExceptionIteratorExtension;

class Test {

  function new(arg) {
  }
  

  static function main() {

    var add = function(x){ return x + 1; };
    var p   = function(x){ return x > 2; };

    var a:Array<Int> = [ 1, 2, 3 ];


    trace("3,4 expected: "+a.arrayToEIterator().map(add).filter(p).array());

    trace("expected: [1 3 4]");
    a.arrayToEIterator().zip2(a.arrayToEIterator().filter(p), function(a,b){ return [a,b, a+b]; }).each(function(x){ trace(x); });

    trace("expected: [2 1 3]");
    a.arrayToEIterator().drop(1).zip2(a.arrayToEIterator().take(1), function(a,b){ return [a,b, a+b]; }).each(function(x){ trace(x); });
  }    

}
