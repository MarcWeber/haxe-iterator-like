using haxe.more.data.Manipulation;

class EnumeratorTest extends TestCases {

  public override function implementation(){ return "Enumerator, stack: "; }

  public override function mapMapFoldSum(nr:Int):Float {
    return 
      this.td.mapMapFoldSumData[nr]
      .asEnumerable()
      .select(function(x) return x + 20)
      .select(function(y) return y / 2)
      .fold(function(n,r) return n + r, 0);
  }

  public override function sum(nr: Int):Int{
    var c = 0;

    var enumerator =
      this.td.mapMapFoldSumData[nr]
      .asEnumerable().getEnumerator();

    while(enumerator.moveNext())
        c += enumerator.current;

    return c;
  }

  // if mod 10 =0 (returns count)
  public override function filterKeepMany(nr: Int):Int {
    var enumerator =  this.td.mapMapFoldSumData[nr]
      .asEnumerable()
      .where(function(x){ return x % 10 == 0; })
      .getEnumerator();
    var c = 0;
    while (enumerator.moveNext())
      c++;
    return c;
  }
  // if mod 10 !=0 (returns count)
  public override function filterKeepAlmostNone(nr: Int):Int {
    var enumerator = this.td.mapMapFoldSumData[nr]
      .asEnumerable()
      .where(function(x){ return x % 10 != 0; })
      .getEnumerator();
    var c = 0;
    while (enumerator.moveNext())
      c++;
    return c;
  }

}
