package com.company;

public class Main {

    static int square(int x) {
        return x*x;
    }

   static int sumSquareDigits (int n) {
        int s = 0;
        int x = n;
        while (x > 0) {
            s += square(x % 10);
            x /= 10;
        }
        return s;
    }

    static int[] ssdCache = new int[10000];

    static void init() {
        for (int i = 1; i <= 9999; i++) {
            ssdCache[i] = sumSquareDigits(i);
        }
    }

    static int ssd2(int x) {
        return ssdCache[x % 10000] +
                ((x > 9999) ? ssdCache[x / 10000] : 0);
    }

    static int termination(int x) {
        while (!(x == 1 || x == 89))
            x = ssd2(x);
        return x;
    }

    static int countT89(int n) {
        int count = 0;
        for (int i = 1; i < n; i++)
        {
            if (termination(i) == 89)
                count++;
        }
        return count;
    }

    static final int N = 10000000;

    public static void main(String[] args) {
        long startTime = System.nanoTime();
        System.out.println("init...");
        init();
        long endTime = System.nanoTime();
        long elapsed = (endTime - startTime);  //divide by 1000000 to get milliseconds.
        System.out.println(String.format("elapsed={0}" , elapsed));
        startTime = System.nanoTime();
        System.out.println("Calculating # of sumsquaredigits terminating in 89 from 1 to 10,000,000...");
        System.out.println(countT89(N));
        endTime = System.nanoTime();
        elapsed = (endTime - startTime);  //divide by 1000000 to get milliseconds.
        System.out.println(String.format("elapsed={0}" , elapsed));
        System.out.println("Press Enter to continue");
        try {
            System.in.read();
        } catch (Exception ex) {
            System.out.println(ex.getMessage());
        };
    }
}
