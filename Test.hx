import e_iterator.TestCases;
import e_iterator.ValueIteratorExtension;
import neko.Lib;
import TestTarget;

using Lambda;


typedef APPLY<I,E> = I -> (E -> Void) -> Void


class Test {

  static public var results:TestTarget;

  // allow testing deep stacks to cause penalty for EIterator
  // n: stack depth
  // f: operation
  static public function benchStackN(n:Int, f:Void -> Dynamic):{ time: Float, result: Dynamic }{
    if (n > 0)
      return benchStackN(n-1, f);
    else {
      var start = time(); //  Date.now().getTime();
      var r:Dynamic = f();
      return { time: 1000 * (time() - start), result: r };
      // return { time:  Date.now().getTime() - start, result: r };
    }
  }
  static public function bench(stack:Int, f:Void -> Dynamic){
    return benchStackN(stack, f);
  }

  static public function target(){
    return
#if js
     "js"
#elseif neko
    "neko"
#elseif php
    "php"
#elseif cpp
    "cpp"
#elseif flash9
    "flash"
#end
    ;
  }


  static public function generateTestData():TestData{
    var length = 16;
    var a=new Array();
    var n;
    var c = #if php 9 #elseif js 9 #else 7 #end;

    for (n in 1...c){
      var i;
      var ra = new Array();
      for (i in 1...length)
        ra.push(i);

      a.push(ra);
      length *= 3;
    }

    return {
      mapMapFoldSumData: a
    }
  }

  static public function times(n:Int, f:Void -> Dynamic){
    return function(){
      for (x in 0 ... n-1)
        f();
      return f();
    }
  }


  static public function div(){
#if js
    return 400; // for IE this should be much more
#elseif flash9
    return 50;
#elseif php
    return 10000;
#else
    return 10;
#end
  }

  static public function runTest(testData:TestData, testI:TestCases, stack){
    var time:Float = 0;
    var n;

    // TODO testI.div() > 1 is unfair cause less iterations take place.
    // Maybe that's because .count outperforms the other implementations when using Stax?
    var d = div() * testI.div();

    var items_to_process = 10000 * 250 / d;


    // reflection could tidy up the code and remove duplication
    // however that's not what you usually do.
    // I don't want to influence the results. Doing copy & paste for that reason.

    var start = target()+"/ "+div()+";"+testI.implementation()+" extra div "+testI.div()+"+;";

    var runTest = function(n:String, f){
      var data:Array<TestRunResult> = new Array();

      for (n in 0 ... testData.mapMapFoldSumData.length){
        var a = testData.mapMapFoldSumData[n];
        var count = a.length;
        println(n+" "+count);
        var times_ = Std.int(items_to_process / count);
        if (times_ == 0)
          times_ = 1;
        try{
          var r = bench(stack, times(times_,  function(){ return f(n); } ));
          data.push(CountTime({times: times_, count: count, time_ms: r.time / times_}));
        }catch(e:TestSkipped){
          data.push(Failed("skipped"));
        }
      }
      results.addTest({impl: testI.implementation(), test: n, data: data});
    }

    // test mapMapFoldSumData
    runTest("mapMapFoldSumData", function(n){ return testI.mapMapFoldSum(n); });
    runTest("sum", function(n){ return testI.sum(n); });
    runTest("filterKeepMany", function(n){ return testI.filterKeepMany(n); } );
    runTest("filterKeepAlmostNone", function(n){ return testI.filterKeepAlmostNone(n); });

  }

  static public function closureTest(){
    var newClosure = function(){
      var i:Int = 0;
      return function(){
        return i++;
      }
    }

    var next = newClosure();
    println(next()+" "+next());

  }

  static function main() {
#if php
    untyped __call__("ini_set", "memory_limit", "2000M" );
#end

    var add = function(x){ return x + 1; };
    var p   = function(x){ return x > 2; };

    trace("running tests on target "+target());


    // generate test data
    var testData = null;
    trace("generating test data");
    testData = generateTestData(); 



    // test
    // WHY DO I NEED CASTS HERE ?? WTF.
    var testImplementations:Array<TestCases> = [
#if ENUMERATOR_LIBRARY
      cast(new e_iterator.EnumeratorTest(testData)),
#end
#if php
#elseif cpp
#else
#if STAX_LIBRARY
      cast(new e_iterator.StaxFoldableTestL(testData)),
      cast(new e_iterator.StaxFoldableTestR(testData)),
#end
#end
#if !cpp
      cast(new e_iterator.ExceptionIteratorExtensionTest(testData, 0)),

      // cast(new ExceptionIteratorExtensionTest(testData, 50)),
      cast(new e_iterator.ExceptionIteratorExtensionTest(testData, 200)),

      // don't think your stack is higher than 500
      cast(new e_iterator.ExceptionIteratorExtensionTest(testData, 500)),
      // cast(new TExceptionIteratorExtensionTest(testData, 0)),
      // cast(new TExceptionIteratorExtensionTest(testData, 200)),
#end
      cast(new e_iterator.TCExceptionIteratorExtensionTest(testData, 200)),
      cast(new e_iterator.ValueIteratorExtensionTest(testData)),
      // cast(new e_iterator.InlinedValueIteratorExtensionTest(testData)),
      cast(new e_iterator.ManualTest(testData)),
      cast(new e_iterator.StdTest(testData)),
      // cast(new e_iterator.StdDiv10Test(testData))
      // Stax foldable test
      // Stax iterators test
      // more test
    ];

    /*
    testImplementations = [
      cast(new ExceptionIteratorExtensionTest(testData, 200)),
    ];
    */

    // testImplementations = testImplementations.concat(testImplementations);

    // use smallest numbers after runinng each test 4 times.
    var manyResults = new Array();
    for (x in 1 ... 2){
      results = new TestTarget();
      var i:Iterator<e_iterator.TestCases> = testImplementations.iterator();
      for (testI in i){
        trace("");
        trace(" ==> testing implementation : "+testI.implementation());
        runTest(testData, testI, testI.stack());
      }
      manyResults.push(results);
    }

    var keepBestResults = function(r1: TestTarget, r2:TestTarget){

      var bestTests = new List();
      var i1 = r1.tests.iterator();
      var i2 = r2.tests.iterator();
      while (i1.hasNext() && i2.hasNext()){
        var t1 = i1.next();
        var t2 = i2.next();
        for (n in 0 ... t1.data.length){
          var d1 = t1.data[n];
          var d2 = t2.data[n];

          switch (d1){
            case CountTime(cT1):
              switch (d2){
                case CountTime(cT2):
                  if (cT2.time_ms < cT1.time_ms){
                    cT1.time_ms = cT2.time_ms;
                  }
              default:
              }
            default:
          }
        }
      }
      return r1;
    }

    results = manyResults.fold(keepBestResults, manyResults[0]);

    var s = haxe.Serializer.run(results);
#if js
    trace(s);
#elseif flash9
    println(s);
#else
    writeFile("results-"+target()+".data", [s]);
#end
  }    


#if (!(js || flash9))
  static function writeFile(path, lines:Array<String>){
    var f = sys.io.File.write(path, true);
    for (s in lines) f.writeString(s+"\n");
    f.close();
  }
#end

  static public function println(s){
#if js
    trace(s);
#elseif flash9
    flash.Lib.trace(s);
#else
    neko.Lib.println(s);
#end
  }



  static public function time(){
#if (js || flash9)
    return Date.now().getTime();
#else
    return std.Sys.time();
#end
  }


}
