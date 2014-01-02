/*
  description:
  
  same as ExceptionIteratorExtension.

  However instead of using an Exception to signal "end of iterator"
  null is returned. Not allowing false results this implies that 
  the iterators may not contain null elements. Exceptions are thrown in that case


*/
package e_iterator;

class ValueIteratorNullValueFound {
  public function new() {
  }
} // end of items (TODO extend from Exception type?)

typedef VIterator<T>= Void -> Null<T>;

class InlinedValueIteratorExtension{

  static public inlined function nullguard<T>(x:Null<T>):T{
    if (x == null)
      throw new ValueIteratorNullValueFound();
    return x;
  }


  static public function map<A,B>(next:VIterator<A>, f:A->B): VIterator<B> {
    return function(){
      var x= next();
      if (x==null) return null;
      return nullguard(f(x));
    };
  } 

  static public function filter<T>( next:VIterator<T>, p: T -> Bool ):VIterator<T>{
    return function(){
      while (true){
        var e=next();
        if (e == null)
          return null;
        if (p(e)) return e;
      }
      return null; // never rearched
    }
  }

  static public function each<T>(next: VIterator<T>, f:T->Void ){
    while (true){
      var n = next();
      if (n == null)
        break;
      f(n);
    }
  }

  static public function take<T>(next:VIterator<T>, n:Int):VIterator<T>{
    return function(){
      if (n-- <= 0)
        return null;
      else {
        return next();
      }
    }
  }

  static public function drop<T>(next:VIterator<T>, n:Int):VIterator<T>{
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
  static public function iter<T>(next:VIterator<T>):Iterator<T>{
    return function(){
      var e=null; // each iterator must have its own copy of e
      return {
        hasNext: function(){
          e = next();
          return e != null;
        },
        next: function(){
          return e;
        }
      };
    }();
  }

  // Std to VIterator
  static public function valueiter<T>(iter:Iterator<T>):VIterator<T>{
    return function(){
      return (iter.hasNext())
        ?  nullguard(iter.next())
        : null;
    }
  }

  static public function zip2<A,B,C>(
      next:VIterator<A>,
      next2:VIterator<B>,
      f:A -> B -> C
  ) :VIterator<C> {
    return function(){ return nullguard(f(next(), next2())); };
  }

  static public function fold<T,B>(next:VIterator<T>, f:T -> B -> B, first:B):B{
    var r = first;
    // inline or optimize this!
    ValueIteratorExtension.each(next, function(n){
        r = f(n, r);
    });
    return r;
  }

  static public function array<T>(next:VIterator<T>):Array<T>{
    var a = new Array();
    ValueIteratorExtension.each(next, function(n){ a.push(n); } );
    return a;
  }

  static public function length_<T>(next:VIterator<T>):Int{
    var c = 0;
    while (true){
      var n = next();
      if (n == null)
        break;
      c++;
    }
    return c;
  }

  // you should not change the array while iterating
  static public function arrayToVIterator<T>(a:Array<T>):VIterator<T>{
    return function(){
      var i = 0;
      return function(){
        if (i >= a.length)
          return null;
        else return nullguard(a[i++]);
      }
    }();
  }
}
