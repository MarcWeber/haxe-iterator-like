using ExceptionIteratorExtension;

class ExceptionIteratorExtensionTest implements TestCases {

  var _stack:Int;
  public function new(stack:Int) { this._stack = stack; }

  public function stack(){ return _stack; }
  public function implementation(){ return "Eiterator, stack: "+_stack; }

  public function mapMapFoldSum(a: Array<Int>):Float {
    return a.arrayToEIterator().map(function(x){ return x + 20; }).map(function(y){ return y / 2;} ).fold(function(n,r){ return n + r; }, 0);
  }


}
