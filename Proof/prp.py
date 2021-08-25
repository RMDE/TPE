from math import *

b = 3
# calculate the number of low k bits distribution while keeping the sum being s. 
def Vai(s, k):
    if k == 1:
        return 1
    dep = int(pow(2, k-1))
    low = int(s - pow(2, k-1) * (4*b-4))
    if low < dep:
        low = s%dep
    up = int((pow(2,k-1) - 1) * (4*b-4))
    if up > s:
        up = s
    count = 0;
    # print(low,up,dep)
    for i in range(low, up+1, dep):
        # print(i,k-1)
        count += Vai(i, k-1)
    return count

# calculate the number of high k bits distribution while keeping the sum being s. 
def Cai(s, k):
    s = s >> (8-k)
    return Vai(s, k)

def Conf(s):
    limit = 4 * b - 4 + 1
    count = 0
    for i in range(limit):
        for j in range(limit):
            for k in range(limit):
                for p in range(limit):
                    for q in range(limit):
                        res = int(1*i+2*j+4*k+8*p+16*q)
                        if res == s:
                            count += 1
    return count

def Calcu(s, rho):
    tmp = 0
    for i in range(8-rho,8):
        tmp += int(pow(2,i))
    low = s - tmp*(4*b-4)
    dep = int(pow(2,8-rho))
    if low < dep:
        low = s%dep
    up = int((pow(2,8-rho)-1)*(4*b-4))
    if up > s:
        up = s
    count = 0
    for i in range(low, up+1, dep):
        count += Vai(i, 8-rho)*Cai(s-i, rho)
    return count

for rho in range(1,8):
    for i in range(255*(4*b-4)+1):
        res1 = Calcu(i,rho)
        res2 = Vai(i,8)
        if res1 != res2:
            print(i,res1,res2)
            break
