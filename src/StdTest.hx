using Lambda;

class StdTest implements TestCases {

  public function new() { }

  // this implementation does not depend on stack
  public function stack(){ return 0; }

  public function mapMapFoldSum(a: Array<Int>):Float {
    return a.list().map(function(x){ return x + 20; }).map(function(y){ return y / 2;} ).fold(function(n,r){ return n + r; }, 0);
  }

  public function implementation(){ return "Std"; }

}
