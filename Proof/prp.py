# from math import *

# b = 8
# SUM = 28
# rho = 3
# # calculate the number of low k bits distribution while keeping the sum being s. 
# def Vai(s, k):
#     if k == 1:
#         return 1
#     dep = int(pow(2, k-1))
#     low = int(s - pow(2, k-1) * SUM)
#     if low < dep:
#         low = s%dep
#     up = int((pow(2,k-1) - 1) * SUM)
#     if up > s:
#         up = s
#     count = 0;
#     # print(low,up,dep)
#     for i in range(low, up+1, dep):
#         # print(i,k-1)
#         count += Vai(i, k-1)
#     return count

# # calculate the number of high k bits distribution while keeping the sum being s. 
# def Cai(s, k):
#     s = s >> (8-k)
#     return Vai(s, k)


# def Conf(s):
#     limit = SUM + 1
#     count = 0
#     for i in range(limit):
#         for j in range(limit):
#             for k in range(limit):
#                 for p in range(limit):
#                     for q in range(limit):
#                         res = int(1*i+2*j+4*k+8*p+16*q)
#                         if res == s:
#                             count += 1
#     return count

# def Calcu(s, rho):
#     tmp = 0
#     for i in range(8-rho,8):
#         tmp += int(pow(2,i))
#     low = s - tmp*SUM
#     dep = int(pow(2,8-rho))
#     if low < dep:
#         low = s%dep
#     up = int((pow(2,8-rho)-1)*SUM)
#     if up > s:
#         up = s
#     count = 0
#     for i in range(low, up+1, dep):
#         count += Vai(i, 8-rho)*Cai(s-i, rho)
#     return count

# for SUM in range(1,b*b):
#     for i in range(255*SUM+1):
#         res1 = Calcu(i,rho)
#         res2 = Vai(i,8)
#         if res1 != res2:
#             print(i,res1,res2)
#             break
def M(s,low1,up1,low2,up2):
    count = 0
    for i in range(low1,up1+1):
        if low2<=s-i<=up2:
            count +=1
    return count
if __name__ == '__main__':
    t = 413
    x = 8
    n = 6
    n1 = 2
    s1 =- max(0,t-(n-n1)*(pow(2,x)-1))+ min(t,n1*(pow(2,x)-1))
    low = max(t%pow(2,x),t-n*(pow(2,x)-1))
    up = min(t,n*(pow(2,x)-1))
    count = 0
    for i in range(int(low),int(up)+1,int(pow(2,x))):
        count += M((t-i)>>x,0,n1,0,n-n1)
    print(s1,count)