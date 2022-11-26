from math import *
b = 8
zeta = 64
rho = 3

def C(n,m):
    # print(m,n)
    if m == n:
        return 1
    elif m == 0:
        return 1
    elif m == 1 or m == n-1:
        return n
    else:
        return int(factorial(n)/(factorial(m)*factorial(n-m)))

def Phi(s,n,k):
    if k==1:
        return C(n,s)
    low = max(s%(pow(2,k-1)),s-n*pow(2,k-1))
    up = min(s,n*(pow(2,k-1)-1))
    count = 0;
    for s1 in range(int(low),int(up+1),int(pow(2,k-1))):
        m = int((s-s1)/(pow(2,k-1)))
        count += Phi(s1,n,k-1)*C(n,m)
    return count

# def Phi_1(s,n,k,b):
#     if k==1:
#         return C(n,s+b)
#     low = max(s%(pow(2,k-1)),s-n*pow(2,k-1))
#     up = min(s,n*(pow(2,k-1)-1))
#     count = 0;
#     for s1 in range(int(low),int(up+1),int(pow(2,k-1))):
#         m = int((s-s1)/(pow(2,k-1)))
#         count += Phi(s1,n,k-1)*C(n,m+b)
#     return count
def M(s,low1,up1,low2,up2):
    count = 0
    for i in range(low1,up1+1):
        if low2<=s-i<=up2:
            count +=1
    return count


def Phi_2(s1,s2,n1,n2,k):
    # print(s1,s2,n1,n2,k)
    if k==1:
        return C(n1+n2,s1+s2)/M(s1+s2,0,n1,0,n2)
    low = max(s1%(pow(2,k-1)),s1-n1*pow(2,k-1))
    up = min(s1,n1*(pow(2,k-1)-1))
    # print(s1,low,up)
    count = 0;
    for sk1 in range(int(low),int(up+1),int(pow(2,k-1))):
        low1 = max(s2%(pow(2,k-1)),s2-n2*pow(2,k-1))
        up1 = min(s2,n2*(pow(2,k-1)-1))
        for sk2 in range(int(low1),int(up1+1),int(pow(2,k-1))):
            m = int((s1+s2-sk1-sk2)/(pow(2,k-1)))
            # print(n1+n2,m)
            count += Phi_2(sk1,sk2,n1,n2,k-1) * C(n1+n2,m)/M(m,0,n1,0,n2)
            # print((s1-sk1)>>(k-1),(s2-sk2)>>(k-1),count,m,M(m,0,n1,0,n2))
    return count
def Calcu(s,cur,b,rho,zeta):
    count1 = 0
    if cur > s:
        low = max(0,ceil((cur-b*b*(pow(2,8-rho)-1))/pow(2,8-rho))*pow(2,8-rho))
        up = min(cur,(b*b-zeta)*(pow(2,8)-pow(2,8-rho)))
        for s1 in range(int(low),int(up+1),int(pow(2,8-rho))):
            count1 += Phi_2(0,int(s1/pow(2,8-rho)),zeta,b*b-zeta,rho)*Phi(cur-s1,b*b,8-rho)
            # print(s1,Phi_2(0,int(s1/pow(2,8-rho)),zeta,b*b-zeta,rho),cur-s1,Phi(cur-s1,b*b,8-rho))
        count2 = Phi(cur,b*b,8)
    elif cur<=s<=cur+zeta*(pow(2,8)-pow(2,8-rho)):
        low = max(0,ceil((cur-b*b*(pow(2,8-rho)-1))/pow(2,8-rho))*pow(2,8-rho))
        up = min(cur-(cur%(pow(2,8-rho))),(b*b-zeta)*(pow(2,8)-pow(2,8-rho)))
        # print(low,up)
        for s1 in range(int(low),int(up+1),int(pow(2,8-rho))):
            count1 += Phi_2(int((s-cur)/(pow(2,8-rho))),int(s1/pow(2,8-rho)),zeta,b*b-zeta,rho)*Phi(cur-s1,b*b,8-rho)
        count2 = Phi(s,b*b,8)
        print("222222")
    else:
        low = max(0,ceil((cur-b*b*(pow(2,8-rho)-1))/pow(2,8-rho))*pow(2,8-rho))
        up = min(cur,(b*b-zeta)*(pow(2,8)-pow(2,8-rho)))
        for s1 in range(int(low),int(up+1),int(pow(2,8-rho))):
            count1 += Phi_2(zeta*(pow(2,8)-pow(2,8-rho))/pow(2,8-rho),int(s1/pow(2,8-rho)),zeta,b*b-zeta,rho)*Phi(cur-s1,b*b,8-rho)
        count2 = Phi(cur+zeta*(pow(2,8)-pow(2,8-rho)),b*b,8)
    return count1,count2
if __name__ == '__main__':
    p = 0.0
    count = 0;
    # for s in range(0,b*b*255+1):
    #     for cur in range(0,s-zeta*int(pow(2,8)-pow(2,8-rho))):
    #         # if cur<=s<=cur+zeta*(pow(2,8)-pow(2,8-rho)):
    #         #     continue
    #         count = 0
    #         low = max(0,int((cur-b*b*(pow(2,8-rho)-1))/pow(2,8-rho))*pow(2,8-rho))
    #         up = min(cur,(b*b-zeta)*(pow(2,8)-pow(2,8-rho)))
    #         for s1 in range(int(low),int(up+1),int(pow(2,8-rho))):
    #             count += Phi(s1/pow(2,8-rho),b*b-zeta,rho)*Phi(cur-s1,b*b,8-rho)
    #         count1,count2 = Calcu(s,cur,b,rho,zeta) 
    #         p += float((Phi(s,b*b,8)/pow(256,b*b)))*float(count/(pow(256,b*b-zeta)*pow(pow(2,8-rho),zeta)))*float(count2-count1)/float(count2)
    #         # print(s,cur,Phi(s,b*b,8),pow(256,b*b),count,(pow(256,b*b-zeta)*pow(pow(2,8-rho),zeta)),count1,count2)
    #         # print(p)
    # print(p)

    # for s in range(0,b*b*255+1):
    #     for cur in range(s,int(255*b*b-zeta*(pow(2,8)-pow(2,8-rho)))):
    #         if cur<=s<=cur+zeta*(pow(2,8)-pow(2,8-rho)):
    #             continue
    #         count = 0
    #         low = max(0,int((cur-b*b*(pow(2,8-rho)-1))/pow(2,8-rho))*pow(2,8-rho))
    #         up = min(cur,(b*b-zeta)*(pow(2,8)-pow(2,8-rho)))
    #         for s1 in range(int(low),int(up+1),int(pow(2,8-rho))):
    #             count += Phi(s1/pow(2,8-rho),b*b-zeta,rho)*Phi(cur-s1,b*b,8-rho)
    #         count1 = Phi(cur,b*b,8-rho)
    #         count2 = Phi(cur,b*b,8)
    #         p += float((Phi(s,b*b,8)/pow(256,b*b)))*float(count/(pow(256,b*b-zeta)*pow(pow(2,8-rho),zeta)))*float(count2-count1)/float(count2)
    #         # print(s,cur,Phi(s,b*b,8),pow(256,b*b),count,(pow(256,b*b-zeta)*pow(pow(2,8-rho),zeta)),count1,count2)
    #         # print(p)
    # print(p)
    # cur = pow(2,8-rho)/2*b*b
    # s = cur-10
    # print(Calcu(s,cur,b,rho,zeta))
    # c1 = Phi(16*64,64,8-rho)
    # c2 = Phi(16*64,64,8)
    count = 0
    for i in range(int(17*64/32)+1):
        c1,c2 = Calcu(17*64,i*32,8,3,64)
        count += c1
        print(c1)

    print(float(count)/c2)
    # print(Calcu(1020,0,2,2,2))
    # print(Phi_2(zeta*(pow(2,8)-pow(2,8-rho)),int(0/pow(2,8-rho)),zeta,b*b-zeta,rho))
    # print(Phi(0,b*b,8-rho))
    # print(Phi(9,4,6)*16+Phi(73,4,6)*10+Phi(137,4,6)*4+Phi(201,4,6))
    # print(Phi(9,4,6),Phi(73,4,6),Phi(137,4,6),Phi(201,4,6))
    # print(Phi_2(128>>6,0,2,2,2))
    # for s in range(0,b*b*255+1):
    # for s in range(201,202):
    #     for cur in range(int(max(s%pow(2,8-rho),s-zeta*(pow(2,8)-pow(2,8-rho)))),int(min(s,zeta*(pow(2,8-rho)-1)+(b*b-zeta)*255)+1),int(pow(2,8-rho))):
    #         count1,count2 = Calcu(s,cur,b,rho,zeta)
    #         print(cur,count1,count2)
    #         count += count1
    # print(count,count2)
    # s = 9
    # cur = 201
    # count = 0
    # low = max(0,int((cur-b*b*(pow(2,8-rho)-1))/pow(2,8-rho))*pow(2,8-rho))
    # up = min(cur,(b*b-zeta)*(pow(2,8)-pow(2,8-rho)))
    # for s1 in range(int(low),int(up+1),int(pow(2,8-rho))):
    #     count += Phi(s1/pow(2,8-rho),b*b-zeta,rho)*Phi(cur-s1,b*b,8-rho)
    # count1,count2 = Calcu(s,cur,b,rho,zeta) 
    # p += float((Phi(s,b*b,8)/pow(256,b*b)))*float(count/(pow(256,b*b-zeta)*pow(pow(2,8-rho),zeta)))*float(count2-count1)/float(count2)
    # print(p)

