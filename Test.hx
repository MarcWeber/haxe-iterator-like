import TestCases;
import ValueIteratorExtension;
import neko.Lib;

using ValueIteratorExtension;

class Test {

  static public var csvSep:String;
  

  // allow testing deep stacks to cause penalty for EIterator
  // n: stack depth
  // f: operation
  static public function benchStackN(n:Int, f:Void -> Void):{ time: Float, result: Dynamic }{
    if (n > 0)
      return benchStackN(n-1, f);
    else {
      var start = time(); //  Date.now().getTime();
      var r = f();
      return { time: 1000 * (time() - start), result: r };
      // return { time:  Date.now().getTime() - start, result: r };
    }
  }
  static public function bench(name:String, n:Int, f:Void -> Dynamic){
      println(name+" stack:"+n);
      var r = benchStackN(n, f);
      println("ok, time: "+r.time+" result: "+r.result);
      csv += ";t: "+r.time+";"+r.result;
      return r.time;
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
    + " nr tests / " + div();
  }

  static public function generateTestData():TestData{
    var length = 16;
    var a=new Array();
    var n;
    for (n in 1...15){
      var i;
      var ra = new Array();
      for (i in 1...length)
        ra.push(i);

      a.push(ra);
      length *= 2;
    }

    return {
      mapMapFoldSumData:  a
    }
  }

  static var csv:String;

  static public function times(n:Int, f:Void -> Dynamic){
    return function(){
      for (x in 0 ... n-1)
        f();
      return f();
    }
  }


  static public function div(){
#if js
    // js is slow, so divide by 100
    return 100;
#elseif flash9
    return 10;
#else
    return 1;
#end
  }

  static public function runTest(testData:TestData, testI:TestCases, stack){
    var time:Float = 0;
    var n;
    var d = div();

    var items_to_process = 1000 * 250 / d;

    // test mapMapFoldSumData
    for (n in 0 ... testData.mapMapFoldSumData.length){
      var a = testData.mapMapFoldSumData[n];
      time = bench("mapMapFoldSumData", stack,  times( Std.int(items_to_process / a.length), function(){ return testI.mapMapFoldSum(a); }));
    }
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

#if js
    csvSep = "br";
#else
    csvSep = "\n";
#end

    csv = "";

    var add = function(x){ return x + 1; };
    var p   = function(x){ return x > 2; };

    var a:Array<Int> = [ 1, 2, 3 ];

    trace("running tests on target "+target());
    csv += target()+csvSep;


    // generate test data
    var testData = null;
    bench("generating test data ", 0,  function(){ testData = generateTestData(); });

    csv += csvSep;


    // header for test
    csv += "benchmark";
    for (x in testData.mapMapFoldSumData){
      csv += ";timing;count="+x.length;
    }
    csv += csvSep;

    // test
    // WHY DO I NEED CASTS HERE ?? WTF.
    var testImplementations:Array<TestCases> = [
      cast(new ExceptionIteratorExtensionTest(0)),
      cast(new ExceptionIteratorExtensionTest(50)),
      cast(new ExceptionIteratorExtensionTest(200)),
      cast(new ExceptionIteratorExtensionTest(500)),
      cast(new ValueIteratorExtensionTest()),
      cast(new StdTest())
      // cast(new StaxFoldableTest())
      // Stax foldable test
      // Stax iterators test
      // more test
    ];

    testImplementations = testImplementations.concat(testImplementations);

    for (testI in testImplementations){
      trace("");
      trace(" ==> testing implementation : "+testI.implementation());
      csv += ";"+testI.implementation();
      runTest(testData, testI, testI.stack());
      csv += csvSep;
    }

#if js
    for (l in csv.split("\n"))
      trace(l);
#elseif flash9
    println(csv);
#else
    writeFile("results.csv", [csv]);
#end

    /*
    trace("3,4 expected: "+a.arrayToEIterator().map(add).filter(p).array());

    trace("expected: [1 3 4]");
    a.arrayToEIterator().zip2(a.arrayToEIterator().filter(p), function(a,b){ return [a,b, a+b]; }).each(function(x){ trace(x); });

    trace("expected: [2 1 3]");
    a.arrayToEIterator().drop(1).zip2(a.arrayToEIterator().take(1), function(a,b){ return [a,b, a+b]; }).each(function(x){ trace(x); });
    */
  }    


#if (!(js || flash9))
  static function writeFile(path, lines:Array<String>){
    var f =neko.io.File.write(path, true);
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
    return neko.Sys.time();
#end
  }


}
