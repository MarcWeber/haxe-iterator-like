
class ManualTest extends TestCases {

  var _stack:Int;

  public override function stack(){ return 0; }
  public override function implementation(){ return "manual coded the task. should be fastest: "; }

  public override function mapMapFoldSum(nr:Int):Float {
    var s:Float = 0;
    for (e in td.mapMapFoldSumData[nr])
      s += (e + 20) / 2;
    return s;
  }

  public override function  sum(nr: Int):Int{
    var c =0;
    for (e in td.mapMapFoldSumData[nr])
      c += e;
    return c;
  }

  // if mod 10 =0 (returns count)
  public override function filterKeepMany(nr: Int):Int {
    var c = 0;
    for (e in  td.mapMapFoldSumData[nr])
      if ( e % 10 == 0) c++;
    return c;
  }
  // if mod 10 !=0 (returns count)
  public override function filterKeepAlmostNone(nr: Int):Int {
    var c = 0;
    for (e in  td.mapMapFoldSumData[nr])
      if ( e % 10 != 0) c++;
    return c;
  }

}
