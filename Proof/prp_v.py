from math import *

b = 2
n = 2
rho = 1
# calculate the number of low k bits distribution while keeping the sum being s. 
def Vai(s,n,k):
    if k == 1:
        return 1
    dep = int(pow(2, k-1))
    low = int(s - pow(2, k-1) * n)
    if low < dep:
        low = s%dep
    up = int((pow(2,k-1) - 1) * n)
    if up > s:
        up = s
    count = 0;
    # print(low,up,dep)
    for i in range(int(low), int(up+1), int(dep)):
        # print(i,k-1)
        count += Vai(i,n,k-1)
    return count
# calculate the number of all bits (exclude the ones to be adjusted) distribution with sum s.
def RegR(s,n,b,rho):
    print("--------in RegR---------")
    count = 0
    up = int(min(s,255*(b*b-n)))
    low = int(max(0,s-n*(pow(2,8-rho)-1)))
    for s1 in range (low,up+1):
        count += Vai(s1,b*b-n,8)*Vai(s-s1,n,8-rho)
    return count
def Calcu(s,cur,n,rho,b):
    print("--------in Calcu---------")
    count1 = 0;
    count2 = 0;
    if cur > s: #高位赋0
        print("-----------=0---------")
        count1 = RegR(cur,n,b,rho)
        count2 = Vai(cur,b*b,8)
    elif s <= cur+(pow(2,8)-pow(2,8-rho))*n: #调整成功
        print("----------success---------")
        s_adj = s-cur
        s_adj = s_adj-s_adj%pow(2,8-rho)
        count1 = Vai(int(s_adj)>>(8-rho),n,rho)*RegR(cur,n,b,rho)
        count2 = Vai(s_adj+cur,b*b,8)
    else:
        print("------------=1------------")
        count1 = RegR(cur,n,b,rho)
        count2 = Vai(cur+(pow(2,8)-pow(2,8-rho))*n,b*b,8)
    return count1,count2

if __name__ == '__main__':
    # p = float(0)
    # for s in range(0,255*b*b+1):
    #     for cur in range(0,int(255*(b*b-n)+(pow(2,8-rho)-1)*n+1)):
    #         print("---------------s = "+str(s)+", cur = "+str(cur)+"---------------")
    #         count1,count2 = Calcu(s,cur,n,rho,b)
    #         print(count1,count2)
    #         p+=(1/255*b*b)*(1/255*(b*b-n)+(pow(2,8-rho)-1)*n)*((count2-count1)/count2)
    # print(p)
    # p = float(0)
    # s = 
    # cur = 
    # print("---------------s = "+str(s)+", cur = "+str(cur)+"---------------")
    # count1,count2 = Calcu(s,cur,n,rho,b)
    # print(count1,count2)
    # p+=(1/255*b*b)*(1/255*(b*b-n)+(pow(2,8-rho)-1)*n)*((count2-count1)/count2)
    # print(p)
    print(Vai(5,5,2))