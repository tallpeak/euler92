// euler92b.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"


#include <stdio.h>
#include <stdlib.h>

const int LIMIT = 10000000;

int sqdigit[10] = {0,1,4,9,16,25,36,49,64,81};

int ssd (int x) 
{
	int s = 0;
	register int t = x;
	register int d;
	while (t>0) {
		s += sqdigit[t%10];
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
int _tmain(int argc, _TCHAR* argv[])
{
	int cnt = countT89();
	printf("count terminating at 89=%d\n", cnt);
	return 0;
}


