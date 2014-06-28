using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace euler92csharp
{
    class Program
    {
        const int LIMIT = 10000000;
        //int[] sqdigit = {0,1,4,9,16,25,36,49,64,81};
        int ssd(int x) 
        {
	        int s = 0;
	        int t = x;
	        int d;
	        while (t>0) {
                d = t % 10;
		        //s += sqdigit[t%10]; // slower
                s += d * d;
		        t /= 10;
	        }
	        return s;
        }

        int termination(int x)
        {
            int t = x;
            while (t != 1 && t != 89)
            {
                t = ssd(t);
            }
            return t;
        }

        int countT89()
        {
            int count = 0;
            int i;
            for (i = 1; i < LIMIT; i++)
            {
                //printf("%d=%d %d\t",i,termination(i),count);
                if (termination(i) == 89)
                    count++;
            }
            return count;
        }

        static void Main(string[] args)
        {
            var p = new Program();
            var sw = new System.Diagnostics.Stopwatch();
            for (int i = 0; i < 10; i++)
            {
                sw.Reset();
                sw.Start();
                //var t0 = DateTime.Now;
                int cnt = p.countT89();
                var elapsedSeconds = sw.ElapsedMilliseconds * .001;
                //var t1 = DateTime.Now;
                //var elapsed = t1.Subtract(t0).;
                //var elapsedSeconds = elapsed.Milliseconds * .001;
                // these values were around an order of magnitude too small! Does Milliseconds actually mean hundredths?

                Console.WriteLine("count terminating at 89={0}, took {1} seconds", cnt, elapsedSeconds);
            }
            Console.ReadLine();
	        return;
        }
    }
}








