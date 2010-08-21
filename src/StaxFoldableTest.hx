import TestCases;
import haxe.data.collections.List;
import PreludeExtensions;
import haxe.functional.Foldable;
using haxe.functional.FoldableExtensions;



class StaxFoldableTest extends TestCases {

  // Stax always makes copies

  var mapMapFoldSumData: Array<haxe.data.collections.List<Int>>;

  public override function div(){ return 20; }

  public override function new(td:TestData) {
    super(td);
    mapMapFoldSumData = new Array();
    trace("coping arrays to Stax lists");
    var n = 0;
    for (x in td.mapMapFoldSumData){
      if (n++ > 5) break;
      var l = haxe.data.collections.List.nil();
      for (e in x) l = l.add(e);
      mapMapFoldSumData.push(l);
    }
  }

  public override function implementation(){ return "StaxFoldable (based on lists), only first 7 list lengts are considered. Everything else would be too slow"; }
  // this implementation does not depend on stack
  public override function stack(){ return 0; }


  public override function mapMapFoldSum(nr:Int):Float {
    // why doesn't it return a Float on its own??? (TODO)
    return skip(nr).map(function(x){ return x + 20; }).mapTo(haxe.data.collections.List.nil(), function(y){ return y / 2;} ).foldl(0, function(n,r){ return cast(n + r); });
  }

  public override function sum(nr: Int):Int{
    var c = 0;
    skip(nr).foreach(function(x){ c += x; });
    return c;
  }

  // if mod 10 =0 (returns count)
  public override function filterKeepMany(nr: Int):Int {
    return skip(nr).filter(function(x){ return x % 10 == 0; }).size;
  }
  // if mod 10 !=0 (returns count)
  public override function filterKeepAlmostNone(nr: Int):Int {
    return skip(nr).filter(function(x){ return x % 10 != 0; }).size;
  }

  public function skip(nr:Int){
    if (nr >= mapMapFoldSumData.length)
      throw new TestSkipped();
    else
      return mapMapFoldSumData[nr];
  }

}
