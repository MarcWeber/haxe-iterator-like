package e_iterator;
/*
  same as TExceptionIteratorExtension

  difference: classes are used instead of unnamed closures (eg for the Array
  iterator)

  TODO: finish replacing all closures by classes

*/

class TCe_iterator.EOI {
  public function new() {
  }
} // end of items (TODO extend from Exception type?)

interface TCEIterator<T> {
  function next():T;
}

class TCEArrayIterator<T> implements TCEIterator<T>{
  var a: Array<T>;

  public function new(a:Array<T>, ?start:Int, ?end:Int) {
    this.a = a;
    this.end = (end == null) ? a.length : end
    this.current = (start == null) ? 0 : start;
  }

  function next():T{
    if (this.current == end)
      throw TCe_iterator.EOI()
    else return this.a[this.current++];
  }
}

class TCEIteratorExtensions{

  static public function map<A,B>(i:TCEIterator<A>, f:A->B): TCEIterator<B> {
    return cast({
      next: function(){ return f(i.next()); }
    });
  } 

  static public function filter<T>( i:TCEIterator<T>, p: T -> Bool ):TCEIterator<T>{
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

  static public function each<T>(i: TCEIterator<T>, f:T->Void ){
    try{
      while (true){ f(i.next()); }
    }catch(e:TCe_iterator.EOI){
      // Ignore any errors - end of iterator rearched
    }
  }

  static public function take<T>(i:TCEIterator<T>, n:Int):TCEIterator<T>{
    return cast({
      next: function(){
        if (n-- <= 0)
          throw new TCe_iterator.EOI(); // why don't I need a colon here?
        else {
          return i.next();
        }
      }
    });
  }

  static public function drop<T>(i:TCEIterator<T>, n:Int):TCEIterator<T>{
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
  static public function iter<T>(i:TCEIterator<T>):Iterator<T>{
    return function(){
      var e=null; // each iterator must have its own copy of e
      return {
        hasNext: function(){
          try{
            e = i.next();
            return true;
          }catch(e:TCe_iterator.EOI){
            return false;
          }
        },
        next: function(){
          return e;
        }
      };
    }();
  }

  // Std to TCEIterator
  static public function eiter<T>(iter:Iterator<T>):TCEIterator<T>{
    return cast({
      next: function(){
        if (iter.hasNext())
          return iter.next();
        else throw new TCe_iterator.EOI();
      }
    });
  }

  static public function zip2<A,B,C>(
      i1:TCEIterator<A>,
      i2:TCEIterator<B>,
      f:A -> B -> C
  ) :TCEIterator<C> {
    return cast({
      next: function(){ return f(i1.next(), i2.next()); }
    });
  }

  static public function fold<T,B>(next:TCEIterator<T>, f:T -> B -> B, first:B):B{
    var r = first;
    // inline or optimize this!
    TCEIteratorExtensions.each(next, function(n){
        r = f(n, r);
    });
    return r;
  }

  static public function array<T>(i:TCEIterator<T>):Array<T>{
    var a = new Array();
    TCEIteratorExtensions.each(i, function(n){ a.push(n); } );
    return a;
  }

  static public function length<T>(i:TCEIterator<T>):Int{
    var c = 0;
    try{
      while (true){
        i.next(); c++;
      }
      return null; // never rearched
    }catch(e:TCe_iterator.EOI){
      return return c;
    }
  }

  // you should not change the array while iterating
  static public function arrayToTCEIterator<T>(a:Array<T>):TCEIterator<T>{
    return new TCEArrayIterator(a);
  };
}
