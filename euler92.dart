void main(List<String> arguments) {
  initSsdCache();
  var startTime = DateTime.now();
  print(
      "Calculating # of sumsquaredigits terminating in 89 from 1 to 10,000,000...");
  print(countT89());
  var endTime = DateTime.now();
  var elapsed = endTime.difference(startTime);
  print("elapsed=${elapsed} (${startTime} - ${endTime} )");
}

int square(x) {
  return x * x | 0;
}

int sumSquareDigits(n) {
  int s = 0;
  int x = n | 0;

  while (x > 0) {
    s = s + square(x % 10);
    x = (x ~/ 10);
  }

  return s;
}

List<int> ssdCache = List.filled(10000, 0);

void initSsdCache() {
  for (var i = 1; i <= 9999; i++) {
    ssdCache[i] = sumSquareDigits(i) | 0;
  }
}

int ssd2(x) {
  return ssdCache[x % 10000] + (x > 9999 ? ssdCache[(x ~/ 10000)] : 0);
}

int termination(x) {
  termination:
  while (true) {
    if (x == 1 ? true : x == 89) {
      return x;
    } else {
      x = ssd2(x);
      continue termination;
    }
  }
}

int countT89() {
  int count = 0;

  for (int i_1 = 1; i_1 <= 10000000; i_1++) {
    if (termination(i_1) == 89) {
      count = count + 1;
    }
  }

  return count;
}
