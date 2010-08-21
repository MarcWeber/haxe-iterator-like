// import Prelude;
// import PreludeExtensions;
// import haxe.functional.Foldable;
// using FoldabeExtensions;


class StaxFoldableTest implements TestCases {

  public function new() { }

  public function implementation(){ return "StaxFoldable"; }
  // this implementation does not depend on stack
  public function stack(){ return 0; }


  public function mapMapFoldSum(a: Array<Int>):Float {
    throw "TODO";
    // return a.arrayToVIterator().map(function(x){ return x + 20; }).map(function(y){ return y / 2;} ).fold(function(n,r){ return n + r; }, 0);
    return 0;
  }

}
