using Lambda;
using StringTools;

import TestTarget;

class Plot {

  static function main() {
    var data = [
      "results-flash.data",
      "results-js-firefox-linux.data",
      "results-js-webkit-windows.data",
      "results-js-ie7-windows.data",
      "results-js-opera-linux.data",
      "results-php.data",
      "results-neko.data",
    ];

    var tests = [
      "mapMapFoldSumData",
      "sum", "filterKeepMany",
      "filterKeepAlmostNone",
    ];

    for (test in tests){

      var plotAll = new Array<String>();

      for (d in data){
        var gp = prepareGnuPlot(d, test);
        plotAll = plotAll.concat(gp);
        plot(d+"-"+test+".svg", gp);
      }
      plot("all"+test+".svg", plotAll);
    }
  }    

  static public function plot(svg, lines:Array<String>){
    var sn = svg+".gnuplot";
    var l = new Array<String>();

    l.push("set logscale x");
    l.push("set term svg size 1200,800 ");
    l.push("set output \""+svg+"\"");
    l.push("plot "+ lines.join(","));

    writeFile(sn, l);
    var p = new neko.io.Process("gnuplot", [sn]);
    trace(p.stdout.readAll().toString());

    if (0 != p.exitCode())
      throw "running gnuplot failed: gnuplot "+sn;
  }

  static public function prepareGnuPlot(file, test:String):Array<String>{
    var s:TestTarget = haxe.Unserializer.run(neko.io.File.getContent(file));
    var gnuplot_lines = new Array();

    for (t in s.tests){
      if (t.test != test)
        continue;
      var data_file = TestTarget.dataOfTest(file, t);
      gnuplot_lines.push("\""+data_file+"\" with "+( t.impl.indexOf("0") > 0 ? "linespoints" : "lines" ));

      Plot.writeFile(data_file,
        t.data.map(function(pt){
          return switch (pt){
            case Failed(s): "";
            case CountTime(c):
              c.count+"\t"+c.time_ms / c.count;
          }
        }).filter(function(x){ return x!=""; }).array());

    }
    if (gnuplot_lines.length == 0)
      throw "failure ? "+file+test;
    return gnuplot_lines;
  }

  static public function writeFile(path, lines:Array<String>){
    var f =neko.io.File.write(path, true);
    for (s in lines) f.writeString(s+"\n");
    f.close();
  }

}


