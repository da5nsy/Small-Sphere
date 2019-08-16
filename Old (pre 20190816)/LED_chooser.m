clear all
loop2 = 1;
loop3 = 1;
x=[480,380,600];

a=zeros(9,14);

while loop2 <10    
    while loop3 <15
        x(3)=x(3)+10;
        a(loop2,loop3)=LED_4_chooser(x);  
        loop3=loop3+1;
        close all
    end
    x(2)=x(2)+10;
    loop3=1;
    x(3)=600;
    loop2=loop2+1
        
end


%%
LED_4_chooser([480,400,620])