% 極位置指定からstep応答をみる
% guiのwindowと描画windowをわける:sim_2
%step応答の画面をGUIとまとめてみる:sim_2_r is sim_1の拡張

clear all
close all
clc

%graphics_toolkit qt%なくてもいい

pkg load control

%h.fnc= @(rel,img) tf(img*img,[ 1, -2*rel, rel*rel+img*img]);
h.fnc= @(p1,p2) zpk([],[p1,p2],p1*p2);
%h.gf=figure("position",[100 100 700 600],"name","極位置と時間応答の関係");
h.gf=figure("position",[10 100 560 540],"name","極位置と時間応答の関係");
%defaultは[300 200 560 420].4:3

function complex_plot(pl)
global     count=1;
%global zeta_com=0.6;

[r c]=size(pl);
    for i=1:r
        x(i)=real(pl(i));
        y(i)=imag(pl(i));
    end
    figure(1)
    hold on
    plot(x,y,"x");
    text(x,y,num2str(count));
    count=count+1;
    %    sgrid(zeta_com,[])
end



function update_plot(obj, init=false)
    hs=guidata(obj);
    replot=false;
    recalc=false;

    IMG_ZERO=get(hs.rb1,"value");
    TH_CNST=get(hs.gp2_rb1,"value");

    real_part_gui=get(hs.real_part_sl,"value");
    imag_part_gui=get(hs.imag_part_sl,"value");
    real_part2_gui=get(hs.real_part2_sl,"value");

    th_cnst_gui=get(hs.th_cnst_sl,"value");
    dist=sqrt(real_part_gui*real_part_gui+imag_part_gui*imag_part_gui);

    if(IMG_ZERO==false)
        th_angle=atan(imag_part_gui/real_part_gui)*180/pi;
    end

    % get_call_back_object:
    ## gcbo holds the handle of the control
    switch (gcbo)
      case {hs.real_part_sl}
        real_part_gui=get(gcbo, "value");
        set(hs.real_part_value,"string",num2str(real_part_gui));
        replot=true;
        recalc=true;
      case {hs.imag_part_sl}
        imag_part_gui=get(gcbo, "value");
        set(hs.imag_part_value,"string",num2str(imag_part_gui));
        replot=true;
        recalc=true;
      case {hs.real_part2_sl}
        real_part2_gui=get(gcbo, "value");
        set(hs.real_part2_value,"string",num2str(real_part2_gui));
        replot=true;
        recalc=true;

      case {hs.rb1} % buttongroupは両方イベント起こるので場合分け必要
        if ( (get(hs.rb1, "value")==true) && (get(hs.rb2, "value")==false) )
            IMG_ZERO=true;
        else
            IMG_ZERO=false;
        end
        replot=true;
        recalc=true;
      case {hs.rb2}
        if ( (get(hs.rb2, "value")==true) && (get(hs.rb1, "value")==false) )
            IMG_ZERO=false;
        else
            IMG_ZERO=true;
        end
        replot=true;
        recalc=true;

      case {hs.th_cnst_sl}
        th_cnst_gui=get(gcbo, "value");
        set(hs.th_cnst_value,"string",num2str(th_cnst_gui));

        replot=true;
        recalc=true;
      case {hs.gp2_rb1} % buttongroupは両方イベント起こるので場合分け必要
        if ( (get(hs.gp2_rb1, "value")==true) && (get(hs.gp2_rb2, "value")==false) )
            TH_CNST=true;
        else
            TH_CNST=false;
        end
        replot=true;
        recalc=true;
      case {hs.gp2_rb2}
        if ( (get(hs.gp2_rb2, "value")==true) && (get(hs.gp2_rb1, "value")==false) )
            TH_CNST=false;
        else
            TH_CNST=true;
        end
        replot=true;
        recalc=true;
end

    if(recalc==true)
        if(IMG_ZERO==true)
            p1=real_part_gui;
            p2=real_part2_gui;
        else
            if(TH_CNST==true)
                %座標計算時のみ、原点から計算する
                real_part_gui=dist*th_cnst_gui*cos(pi-th_angle*pi/180);
                imag_part_gui=dist*th_cnst_gui*sin(pi-th_angle*pi/180);
                set(hs.real_part_value,"string",num2str(real_part_gui));
                set(hs.imag_part_value,"string",num2str(imag_part_gui));
                set(hs.th_cnst_value2,"string",num2str(th_angle));
                set(hs.th_cnst_value_disp,"string",num2str(th_angle));
            end

            p1=real_part_gui+imag_part_gui*j;
            p2=real_part_gui-imag_part_gui*j;

        end
        G=hs.fnc(p1,p2);
        [y t]=step(G);
    end

    if(replot==true)
        figure(3)
        hs.plot=plot(t,y);
        set(gca,"xlabel","time s","ylabel","y out","fontsize",20);

        figure(1)
        [pole,zero]=pzmap(G);
        complex_plot(pole)
    end

end

h.p_real=uipanel(
    "position",[0.05 0.1 0.7 0.12]);

h.p2_real=uipanel(
    "position",[0.05 0.0 0.7 0.12]);

h.p_imag=uipanel(
    "position",[0.775 0.3 0.1 0.6]);

h.th_cnst=uipanel(
    "position",[0.875 0.3 0.1 0.6]);

real_part_ini=-1;
imag_part_ini=1;
real_part2_ini=0;
dist_ini=sqrt((real_part_ini*real_part_ini)+(imag_part_ini*imag_part_ini));
th_ini=atan(imag_part_ini/real_part_ini)*180/pi;


p1_ini=real_part_ini+imag_part_ini*j;
p2_ini=real_part_ini-imag_part_ini*j;

h.real_part1_disp=uicontrol(
    "parent",h.p_real,
    "style","text",
    "units", "normalized",
    "string","pole1",
    "horizontalalignment", "left",
    "position", [0.01 0.3 0.1 0.4]);

h.real_part_disp=uicontrol(
    "parent",h.p_real,
    "style","text",
    "units", "normalized",
    %    "string","real_part",
    "string","実軸の値",
    "horizontalalignment", "left",
    "position", [0.3 0.6 0.2 0.4]);

h.real_part_value=uicontrol(
    "parent",h.p_real,
    "style","text",
    "units", "normalized",
    "string",num2str(real_part_ini),
    "horizontalalignment", "left",
    "position", [0.55 0.6 0.1 0.4]);

h.real_part_sl=uicontrol(
    "parent",h.p_real,
    "style","slider",
    "units", "normalized",
    "string", "slider",
    "value", real_part_ini,
    "max",10,
    "min",-50,
    "sliderstep",[0.1 1.0],
    "horizontalalignment", "left",
    "position", [0.1 0.1 0.8 0.4],
    "callback", @update_plot );

h.real_part2_disp=uicontrol(
    "parent",h.p2_real,
    "style","text",
    "units", "normalized",
    "string","pole2",
    "horizontalalignment", "left",
    "position", [0.01 0.3 0.1 0.4]);

h.real_part2_disp=uicontrol(
    "parent",h.p2_real,
    "style","text",
    "units", "normalized",
    %    "string","when p2 use, set yes at Im=0? button",
    "string","実軸上に極を2つ設定したい時は Im=0?のボタンをyesにしてください",
    "horizontalalignment", "left",
    "position", [0.1 0.7 0.9 0.3]);

h.real_part2_value=uicontrol(
    "parent",h.p2_real,
    "style","text",
    "units", "normalized",
    "string",num2str(real_part2_ini),
    "horizontalalignment", "left",
    "position", [0.5 0.45 0.2 0.3]);

h.real_part2_sl=uicontrol(
    "parent",h.p2_real,
    "style","slider",
    "units", "normalized",
    "string", "slider",
    "value", real_part2_ini,
    "max",10,
    "min",-50,
    "sliderstep",[0.1 1.0],
    "horizontalalignment", "left",
    "position", [0.1 0.1 0.8 0.4],
    "callback", @update_plot );


h.imag_part_disp=uicontrol(
    "parent",h.p_imag,
    "style","text",
    "units", "normalized",
    %    "string","imag_part",
    "string","虚軸の値",
    "position", [0.01 0.95 0.95 0.05]);

h.imag_part_value=uicontrol(
    "parent",h.p_imag,
    "style","text",
    "units", "normalized",
    "string",num2str(imag_part_ini),
    "position", [0.1 0.85 0.9 0.05]);

h.imag_part_sl=uicontrol(
    "parent",h.p_imag,
    "style","slider",
    "units", "normalized",
    "string", "slider",
    "value", imag_part_ini,
    "max",50,
    "min",0,
    "sliderstep",[0.1 1.0],
    "position", [0.7 0 0.4 0.8],
    "callback", @update_plot );

h.th_cnst_disp=uicontrol(
    "parent",h.th_cnst,
    "style","text",
    "units", "normalized",
    %    "string","th_cnst",
    "string","偏角一定",
    "position", [0.01 0.95 0.95 0.05]);

h.th_cnst_value=uicontrol(
    "parent",h.th_cnst,
    "style","text",
    "units", "normalized",
    "string",num2str(dist_ini),
    "position", [0.1 0.85 0.9 0.035]);

h.th_cnst_value2=uicontrol(
    "parent",h.th_cnst,
    "style","text",
    "units", "normalized",
    "string",num2str(th_ini),
    "position", [0.1 0.9 0.9 0.035]);

h.th_cnst_sl=uicontrol(
    "parent",h.th_cnst,
    "style","slider",
    "units", "normalized",
    "string", "slider",
    "value", dist_ini,
    "max",10,
    "min",0.01,
    "sliderstep",[-0.1 -1.0],
    "position", [0.7 0 0.4 0.8],
    "callback", @update_plot );

h.th_cnst_disp_far=uicontrol(
    "parent",h.th_cnst,
    "style","text",
    "units", "normalized",
    "string","原点\nから\n遠方",
    "horizontalalignment", "left",
    "position", [0.05 0.6 0.5 0.2]);
h.th_cnst_disp_origin=uicontrol(
    "parent",h.th_cnst,
    "style","text",
    "units", "normalized",
    "string","原点\nの\n近傍",
    "horizontalalignment", "left",
    "position", [0.05 0.05 0.5 0.2]);


gp = uibuttongroup ("title","Im=0?",
                    "Position", [ 0.775 0.15 0.15 0.15]);
gp2 = uibuttongroup ("title","th const?",
                    "Position", [ 0.775 0 0.22 0.15]);

h.rb1=uicontrol(
    "parent",gp,
    "style","radiobutton",
    "units", "normalized",
    "string", "yes",
    "value", false,
    "position", [0.1 0.4 0.7 0.4],
    "callback", @update_plot );
h.rb2=uicontrol(
    "parent",gp,
    "style","radiobutton",
    "units", "normalized",
    "string", "no",
    "value", true,
    "position", [0.1 0.05 0.7 0.4],
    "callback", @update_plot );

h.gp2_rb1=uicontrol(
    "parent",gp2,
    "style","radiobutton",
    "units", "normalized",
    "string", "yes",
    "value", false,
    "position", [0.1 0.4 0.7 0.4],
    "callback", @update_plot );
h.gp2_rb2=uicontrol(
    "parent",gp2,
    "style","radiobutton",
    "units", "normalized",
    "string", "no",
    "value", true,
    "position", [0.1 0.05 0.7 0.4],
    "callback", @update_plot );

h.th_cnst_label_disp=uicontrol(
    "parent",gp2,
    "style","text",
    "units", "normalized",
    "string","now (deg)",
    "horizontalalignment", "left",
    "position", [0.5 0.55 0.45 0.4]);

h.th_cnst_value_disp=uicontrol(
    "parent",gp2,
    "style","text",
    "units", "normalized",
    "string", num2str(th_ini),
    "horizontalalignment", "left",
    "position", [0.6 0.1 0.3 0.4]);

h.menu_label=uicontrol(
    "parent",h.gf,
    "style","text",
    "units", "normalized",
    "string", "スライダーを動かすと、極位置が移動しその時のステップ応答を表示します。\n 偏角一定で極を移動させたい時は、 th const? のボタンをyesにしてください\n　実軸上に極を2つ設定したい時は Im=0?のボタンをyesにしてください",
    "horizontalalignment", "left",
    "position", [0.05 0.9 1 0.1]);

set (h.gf, "color", get(h.gf, "defaultuicontrolbackgroundcolor"));

%h.ax=axes(h.gf,"position",[0.05 0.27 0.7 0.65]);
h.ax=axes(h.gf,"position",[0.05 0.3 0.7 0.6]);

%初期描画用伝達関数step応答
G=h.fnc(p1_ini,p2_ini);
[y t]=step(G);
guidata(h.gf,h);% guidata(figure handle, datacontainer)
%これがなかったらerror : matrix cannot be indexed with . になる

%figure(3,"position",[800,100,700,600])
figure(3,"position",[570,100,560,480])
%defaultは[300 200 560 420].4:3
h.plot=plot(t,y);
set(gca,"xlabel","time s","ylabel", "y out","fontsize",20);

figure(1);%,"position",[900,100,700,600])
[pole,zero]=pzmap(G);
%sgrid(zeta_com,[]);%zeta,omega

complex_plot(pole);

%guidata(h.gf,h);% guidata(figure handle, datacontainer)
%これがなかったらerror : matrix cannot be indexed with . になる:fig(3)の前に移動

update_plot(h.gf,true);

%H=msgbox("Slide the mover to select a pole position");
%H=msgbox("スライダーを動かすと、極位置が移動し、\n その時のステップ応答を表示します。\n 偏角一定で極を移動させたい時は、\n th const? のボタンをyesにしてください","使い方");





