using Lambda;
using StringTools;

typedef CountTime = {
  count: Int,     // items in list fed into iterator
  time_ms: Float, // time taken for test
  times: Int      // test was run X times
}

enum TestRunResult {
  Failed(s:String);
  CountTime( c : CountTime );
}

typedef TestRun = {
  impl: String,
  test: String,
  data: Array<TestRunResult>
}


class TestTarget {
  public var tests: List<TestRun>;

  public function new() {
    tests = new List();
  }

  public function addTest(t:TestRun){
    tests.add(t);
  }

  public function writeCSV(file:String){

    /*
    // header for test
    csv += "target;implementation;test;times run";
    for (x in testData.mapMapFoldSumData){
      csv += ";timing;count="+x.length;
    }
    csv += csvSep;
    */
  }

  static public function dataOfTest(prefix:String, test:TestRun){
    var t:String -> String = function(x){ return x.replace("+","").replace("-","").replace(".","").replace(" ","_"); };
    return prefix+"-"+t(test.impl)+"-"+t(test.test)+".gnuplotdata";
  }

  public function writeData(prefix){
    for (t in tests){
    }
  }
}
