package e_iterator;
using Lambda;

class StdTest extends TestCases {

  public override function implementation(){ return "Std"; }

  // this implementation does not depend on stack
  public override function stack(){ return 0; }

  public override function mapMapFoldSum(nr:Int):Float {
    return td.mapMapFoldSumData[nr].list().map(function(x){ return x + 20; }).map(function(y){ return y / 2;} ).fold(function(n,r){ return n + r; }, 0);
  }

  public override function sum(nr:Int):Int {
    var c =0;
    td.mapMapFoldSumData[nr].list().iter(function(x){ c+=x; });
    return c;
  }

  // if mod 10 =0 (returns count)
  public override function filterKeepMany(nr: Int):Int {
    return td.mapMapFoldSumData[nr].list().filter(function(x){ return x % 10 == 0; }).length;
  }
  // if mod 10 !=0 (returns count)
  public override function filterKeepAlmostNone(nr: Int):Int {
    return td.mapMapFoldSumData[nr].list().filter(function(x){ return x % 10 != 0; }).length;
  }

}
