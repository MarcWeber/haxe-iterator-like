import TestCases;
using ExceptionIteratorExtension;

class ExceptionIteratorExtensionTest extends TestCases {

  var _stack:Int;
  public override function new(testData: TestData, stack:Int) {
    super(testData);
    this._stack = stack;
  }

  public override function stack(){ return _stack; }
  public override function implementation(){ return "Eiterator, stack: "+_stack; }

  public override function mapMapFoldSum(nr:Int):Float {
    return td.mapMapFoldSumData[nr].arrayToEIterator().map(function(x){ return x + 20; }).map(function(y){ return y / 2;} ).fold(function(n,r){ return n + r; }, 0);
  }

  public override function  sum(nr: Int):Int{
    var c = 0;
    td.mapMapFoldSumData[nr].arrayToEIterator().each(function(x){ c+=x; });
    return c;
  }

  // if mod 10 =0 (returns count)
  public override function filterKeepMany(nr: Int):Int {
    return td.mapMapFoldSumData[nr].arrayToEIterator().filter(function(x){ return x % 10 == 0; }).length_();
  }
  // if mod 10 !=0 (returns count)
  public override function filterKeepAlmostNone(nr: Int):Int {
    return td.mapMapFoldSumData[nr].arrayToEIterator().filter(function(x){ return x % 10 != 0; }).length_();
  }


}
