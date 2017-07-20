// Thanks, fable.io! (conference in France, sep 2017! http://fable.io/fableconf/#home )
import { tryGetValue } from "fable-core/Map";
import { op_Subtraction, now } from "fable-core/Date";
import { fsFormat } from "fable-core/String";
export function square(x) {
  return x * x | 0;
}
export function sumSquareDigits(n) {
  let s = 0;
  let x = n | 0;

  while (x > 0) {
    s = s + square(x % 10) | 0;
    x = ~~(x / 10) | 0;
  }

  return s | 0;
}
export const ssdCache = new Int32Array(10000);

for (let i = 1; i <= 9999; i++) {
  ssdCache[i] = sumSquareDigits(i) | 0;
}

export function ssd2(x) {
  return ssdCache[x % 10000] + (x > 9999 ? ssdCache[~~(x / 10000)] : 0) | 0;
}
export function termination(x) {
  termination: while (true) {
    if (x === 1 ? true : x === 89) {
      return x | 0;
    } else {
      x = ssd2(x);
      continue termination;
    }
  }
}
export function countT89() {
  let count = 0;

  for (let i_1 = 1; i_1 <= 10000000; i_1++) {
    if (termination(i_1) === 89) {
      count = count + 1 | 0;
    }
  }

  return count | 0;
}
export function createDic(key, value) {
  return new Map();
}
export function collateArg(arg, f, a) {
  return f(a);
}
export function memoize1(f) {
  const dic = createDic(null, null);
  return function (x) {
    const matchValue = tryGetValue(dic, x, null);

    if (matchValue[0]) {
      return matchValue[1];
    } else {
      dic.set(x, f(x));
      return dic.get(x);
    }
  };
}
export const termmemo = memoize1(function (x) {
  return termination(x);
});
export const startTime = now();
fsFormat("Calculating # of sumsquaredigits terminating in 89 from 1 to 10,000,000...")(x => {
  console.log(x);
});
fsFormat("%d")(x => {
  console.log(x);
})(countT89());
export const endTime = now();
export const elapsed = op_Subtraction(endTime, startTime);
fsFormat("elapsed=%A (%A-%A)")(x => {
  console.log(x);
})(elapsed, startTime, endTime);
