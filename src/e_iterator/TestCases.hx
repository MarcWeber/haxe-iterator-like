package e_iterator;
using Lambda;

typedef TestData = {
  mapMapFoldSumData: Array<Array<Int>>
}
typedef TestDataList = {
  mapMapFoldSumData: Array<List<Int>>
}

class TestSkipped {
  public function new() { }
}

class TestCases {

  var td:TestData;
  var tdList: TestDataList;

  // stax is that slow that I want to run less tests
  public function div(){ return 1; }

  public function new(testData:TestData) {
    this.td = testData;
    this.tdList = cast({
      mapMapFoldSumData2: testData.mapMapFoldSumData.map(function(x){ return x.list(); }).array()
    });
  }

  public function implementation():String {
    return "";
  }

  public function stack():Int { return 0; }

  // intermediate results allowed but not required
  // +20 /2 -> sum
  public function mapMapFoldSum(nr: Int):Float { return ni(); }

  // test .each (Std.iter) performance:
  public function sum(nr: Int):Int { return ni(); }

  // if mod 10 =0 (returns count)
  public function filterKeepMany(nr: Int):Int { return ni(); }
  // if mod 10 !=0 (returns count)
  public function filterKeepAlmostNone(nr: Int):Int { return 0; }


  static public function ni():Dynamic{
    throw "not implemented";
  }
}
