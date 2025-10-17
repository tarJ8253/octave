clear all
close all
clc

pkg load control

function step_cal(x,y)
fnc= @(p1,p2) zpk([],[p1,p2],p1*p2);

    p1=x+j*y;
    p2=x-j*y;
    G=fnc(p1,p2);
    figure(2)
    step(G);

end

function complex_plot(pl)
    count=1;
    [r c]=size(pl);
    for i=1:r
        x(i)=real(pl(i));
        y(i)=imag(pl(i));
    end
    hold on
    plot(x,y,"x");
    text(x,y,num2str(count));
    %    count=count+1;
end

figure(1,"position",[100,100,500,500],"name","任意の極位置をクリックすると対応する時間応答を表示します。")
axis([-10 1 -10 10])
sgrid(0.5912,[])%zeta,omega
                %daspect([1 1])

G=tf(1,[1 1 1]);
figure(2,"position",[600,100,500,500])
step(G)
[pole zero]=pzmap(G);
figure(1)
complex_plot(pole);

count=2;

H=msgbox("Click a pole position on the complex plane","SELECT POLE pos.");
%H=msgbox("極位置として複素平面上の点をクリックしてください","極位置と時間応答");
uiwait(H);

while(1)
    figure(1)
    [x y btn]=ginput(1);
    hold on
    if(btn==1)
        plot(x,y,"x")
        plot(x,-y,"x");
        text(x,y,num2str(count));
        count=count+1;
        step_cal(x,y);
    else
        break% error対策: text: invalid combination of points and text strings
    end

end

close all
