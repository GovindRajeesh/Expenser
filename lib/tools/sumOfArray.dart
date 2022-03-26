num sumOfArray(arr) {
  arr = arr as List<num>;
  num sum = 0;
  for (var i = 0; i < arr.length; i++) {
    sum += arr[i];
  }
  return sum;
}