/*
  description:
  The Std is using a simple iterator interface:

  interafece<T>{
    function hasNext(): Bool // return true if there is an element
    function next():T        // return that next element
  }

  flaws: For each element you have to call two functions.

  So this E(exception)Iterator tries to use only one function.
  Instead of hasNext() returning false an e_iterator.EOI is thrown

  Much inilining can take place. This should result in fast code (?)

  I think its hard to get same amount of features with less code.

  So I like this implementation a lot

  CODE untested!

  Mark (Dykam) is right: throwing Exceptions can be expensive.
  So I expect this code to pay off only on very long lists..


*/
package e_iterator;

// is EOI now
// class e_iterator.EOI {
//   public function new() {
//   }
// } // end of items (TODO extend from Exception type?)

typedef EIterator<T>= Void -> T;

class Extension {

  static public function map<A,B>(next:EIterator<A>, f:A->B): EIterator<B> {
    return function(){ return f(next()); };
  } 

  static public function filter<T>( next:EIterator<T>, p: T -> Bool ):EIterator<T>{
    return function(){
      var e=next();
      while (!p(e)){
        var e=next();
      }
      return e;
    }
  }

  static public function each<T>(next: EIterator<T>, f:T->Void ){
    try{
      while (true){ f(next()); }
    }catch(e:e_iterator.EOI){
      // Ignore any errors - end of iterator rearched
    }
  }

  static public function take<T>(next:EIterator<T>, n:Int):EIterator<T>{
    return function(){
      if (n-- <= 0)
        throw new e_iterator.EOI(); // why don't I need a colon here?
      else {
        return next();
      }
    }
  }

  static public function drop<T>(next:EIterator<T>, n:Int):EIterator<T>{
    return function(){
      if (n > 0){
        while (n-- > 0){
          next();
        }
      }
      return next();
    }
  }

  // to Std Iterator
  static public function iter<T>(next:EIterator<T>):Iterator<T>{
    return function(){
      var e=null; // each iterator must have its own copy of e
      return {
        hasNext: function(){
          try{
            e = next();
            return true;
          }catch(e:e_iterator.EOI){
            return false;
          }
        },
        next: function(){
          return e;
        }
      };
    }();
  }

  // Std to EIterator
  static public function eiter<T>(iter:Iterator<T>):EIterator<T>{
    return function(){
      if (iter.hasNext())
        return iter.next();
      else throw new e_iterator.EOI();
    }
  }

  static public function zip2<A,B,C>(
      next:EIterator<A>,
      next2:EIterator<B>,
      f:A -> B -> C
  ) :EIterator<C> {
    return function(){ return f(next(), next2()); };
  }

  static public function fold<T,B>(next:EIterator<T>, f:T -> B -> B, first:B):B{
    var r = first;
    // inline or optimize this!
    e_iterator.Extension.each(next, function(n){
        r = f(n, r);
    });
    return r;
  }

  static public function array<T>(next:EIterator<T>):Array<T>{
    var a = new Array();
    e_iterator.Extension.each(next, function(n){ a.push(n); } );
    return a;
  }

  // name length is dropped by js ??!!
  static public function length_<T>(next:EIterator<T>):Int{
    var c = 0;
    try{
      while (true){
        next(); c++;
      }
      return 0; // never rearched
    }catch(e:e_iterator.EOI){
      return c;
    }
  }

  // you should not change the array while iterating
  static public function arrayToEIterator<T>(a:Array<T>):EIterator<T>{
    return function(){
      var i = 0;
      return function(){
        if (i >= a.length)
          throw new e_iterator.EOI();
        else return a[i++];
      }
    }();
  }
}
