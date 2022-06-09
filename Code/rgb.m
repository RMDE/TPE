%file: rgb.m
%function: calculate the value distribution of pixels in the image
img = imread("original.png");
cal = zeros(3,256);
[M,N,C] = size(img);


for cha = 1 : C
    for m = 1 : M
        for n = 1 : N
            pixel = img(m,n,cha)+1;
            cal(cha,pixel) = cal(cha,pixel)+1;
        end
    end
end
x=0:1:255;
 a=cal(1,:); 
 b=cal(2,:);
 c=cal(3,:);
 plot(x,a,'-r',x,b,'-g',x,c,'-b','LineWidth',1.1);
 
axis([0,255,0,20000])  

set(gca,'xticklabel',[0:50:250])
set(gca,'YTick',[0:5000:20000])
set(gca,'FontName','Times New Roman','FontSize',13);

% legend('Red','Green','Blue','fontsize',11);  
% xlabel('Error value','fontsize',13) 
xlabel('Prediction value','FontName','Times New Roman','FontSize',15);
legend('Red','Green','Blue', 'FontName','Times New Roman', 'FontSize',13);
ylabel('Count','FontName','Times New Roman','FontSize',15)
set(gcf,'position',[0,0,420,270])

% for cha = 1 : C
%     for m = 1 : M
%         for n = 1 : N
%             error = MED(img,m,n,cha);
%             index = int32(error)+256;
%             cal(cha,index) = cal(cha,index)+1;
%         end
%     end
% end
% flag1 = [1,1,1];
% flag2 = [511,511,511];
% for cha = 1 : C
%     i1 = 1;
%     i2 = 511;
%     while cal(cha,i1)==0
%         i1 = i1+1;
%     end
%     while cal(cha,i2)==0
%         i2 = i2-1;
%     end
%     flag1(cha) = i1;
%     flag2(cha) = i2;
% end
% i1 = min(flag1);
% i2 = max(flag2);
% i1-256,i2-256
% x=-255:1:255;
%  a=cal(1,:); 
%  b=cal(2,:);
%  c=cal(3,:);
%  plot(x,a,'-r',x,b,'-g',x,c,'-b','LineWidth',1.1);
%  
% axis([-255,255,0,350000])  
% 
% set(gca,'xticklabel',[-200:100:200])
% set(gca,'YTick',[0:50000:350000])
% set(gca,'FontName','Times New Roman','FontSize',13);
% 
% % legend('Red','Green','Blue','fontsize',11);  
% % xlabel('Error value','fontsize',13) 
% xlabel('Error value','FontName','Times New Roman','FontSize',15);
% legend('Red','Green','Blue', 'FontName','Times New Roman', 'FontSize',13);
% ylabel('Count','FontName','Times New Roman','FontSize',15)
% set(gcf,'position',[0,0,420,270])
% 
% function error = MED(origin,x,y,z)
%     if x==1 &&y==1
%         error = origin(x,y,z);
%     elseif x==1
%         pred = origin(x,y-1,z);
%         error = double(origin(x,y,z)) - double(pred);
%     elseif y==1
%         pred = origin(x-1,y,z);
%         error = double(origin(x,y,z)) - double(pred);
%     else
%         minn = origin(x-1,y,z);
%         maxx = origin(x,y-1,z);
%         if minn > origin(x,y-1,z)
%             minn = origin(x,y-1,z);
%             maxx = origin(x-1,y,z);
%         end
%         if origin(x-1,y-1,z) < minn
%             pred = maxx;
%         elseif origin(x-1,y-1,z) > maxx
%             pred = minn;
%         else
%             pred = double(origin(x-1,y,z)) + double(origin(x,y-1,z)) - double(origin(x-1,y-1,z));
%         end
%         error = double(origin(x,y,z)) - double(pred);
%     end
% end