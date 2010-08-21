/*
  description:
  The Std is using a simple iterator interface:

  interafece<T>{
    function hasNext(): Bool // return true if there is an element
    function next():T        // return that next element
  }

  flaws: For each element you have to call two functions.

  So this E(exception)Iterator tries to use only one function.
  Instead of hasNext() returning false an TEIteratorEOI is thrown

  Much inilining can take place. This should result in fast code (?)

  I think its hard to get same amount of features with less code.

  So I like this implementation a lot

  CODE untested!

  Mark (Dykam) is right: throwing Exceptions can be expensive.
  So I expect this code to pay off only on very long lists..


*/

class TEIteratorEOI {
  public function new() {
  }
} // end of items (TODO extend from Exception type?)

interface TEIterator<T> {
  function next():T;
}

class TEIteratorExtensions{

  static public function map<A,B>(i:TEIterator<A>, f:A->B): TEIterator<B> {
    return cast({
      next: function(){ return f(i.next()); }
    });
  } 

  static public function filter<T>( i:TEIterator<T>, p: T -> Bool ):TEIterator<T>{
    return cast({
      next: function(){
        while (true){
          var e=i.next();
          if (p(e))
            return e;
        }
        return null; // never rearched
      }
    });
  }

  static public function each<T>(i: TEIterator<T>, f:T->Void ){
    try{
      while (true){ f(i.next()); }
    }catch(e:TEIteratorEOI){
      // Ignore any errors - end of iterator rearched
    }
  }

  static public function take<T>(i:TEIterator<T>, n:Int):TEIterator<T>{
    return cast({
      next: function(){
        if (n-- <= 0)
          throw new TEIteratorEOI(); // why don't I need a colon here?
        else {
          return i.next();
        }
      }
    });
  }

  static public function drop<T>(i:TEIterator<T>, n:Int):TEIterator<T>{
    return cast({
      next: function(){
        if (n > 0){
          while (n-- > 0){
            i.next();
          }
        }
        return i.next();
      }
    });
  }

  // to Std Iterator
  static public function iter<T>(i:TEIterator<T>):Iterator<T>{
    return function(){
      var e=null; // each iterator must have its own copy of e
      return {
        hasNext: function(){
          try{
            e = i.next();
            return true;
          }catch(e:TEIteratorEOI){
            return false;
          }
        },
        next: function(){
          return e;
        }
      };
    }();
  }

  // Std to TEIterator
  static public function eiter<T>(iter:Iterator<T>):TEIterator<T>{
    return cast({
      next: function(){
        if (iter.hasNext())
          return iter.next();
        else throw new TEIteratorEOI();
      }
    });
  }

  static public function zip2<A,B,C>(
      i1:TEIterator<A>,
      i2:TEIterator<B>,
      f:A -> B -> C
  ) :TEIterator<C> {
    return cast({
      next: function(){ return f(i1.next(), i2.next()); }
    });
  }

  static public function fold<T,B>(next:TEIterator<T>, f:T -> B -> B, first:B):B{
    var r = first;
    // inline or optimize this!
    TEIteratorExtensions.each(next, function(n){
        r = f(n, r);
    });
    return r;
  }

  static public function array<T>(i:TEIterator<T>):Array<T>{
    var a = new Array();
    TEIteratorExtensions.each(i, function(n){ a.push(n); } );
    return a;
  }

  static public function length<T>(i:TEIterator<T>):Int{
    var c = 0;
    try{
      while (true){
        i.next(); c++;
      }
      return null; // never rearched
    }catch(e:TEIteratorEOI){
      return return c;
    }
  }

  // you should not change the array while iterating
  static public function arrayToTEIterator<T>(a:Array<T>):TEIterator<T>{
    return cast({
      next: function(){
        var i = 0;
        return function(){
          if (i >= a.length)
            throw new TEIteratorEOI();
          else return a[i++];
        }
      }()
    });
  }
}
