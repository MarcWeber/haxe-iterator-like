interface TestCases {

  public function implementation():String;

  public function stack():Int;

  // intermediate results allowed but not required
  // +20 /2 -> sum
  public function mapMapFoldSum(a: Array<Int>):Float;
}

typedef TestData = {
  mapMapFoldSumData: Array<Array<Int>>
}
