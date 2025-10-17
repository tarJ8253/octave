%Octave ソース : PID制御系設計
clear all
close all
clc

pkg load control
h.gf=figure("position",[10 300 560 250],"name","PID制御シミュレーション");
h.wind=[570 100 560 420];%defaultは[300 200 560 420].4:3
                         %640-480

h.P1=@() zpk([],[0 -0.5 -2],1);%(z,p,k),1/s(2s+1)(0.5s+1),Q1-P1
h.P2=@() tf(1,[1 2 0]);%,1/s(s+2),Q1-P2
h.P3=@() zpk([],[-1 -5],1);%(z,p,k),1/(s+1)(s+5)*1,Q2-応答データ取得に使用


function prt_fig(fn,fnum)
    ext='.png';
    fname=["fig_" num2str(fnum) "_" fn ext];
    %    print(["fig_" fn "_" num2str(fnum) ".svg"],"-dsvg");
    print(fnum, fname,'-dpng','-S640,480');
end

function [P t_end lab fnum]=set_model(obj,P1_select,P2_select,P3_select)
    hs=guidata(obj);
    if (P1_select== true)
        P=hs.P1();
        t_end=[20 40];%開ループ,閉ループsim時間
        lab="P1";
        fnum=[2 21];%開ループ,閉ループ,図番
    elseif (P2_select== true)
        P=hs.P2();
        t_end=[10 10];
        lab="P2";
        fnum=[3 31];
    elseif (P3_select== true)
        P=hs.P3();
        t_end=[5 5];
        lab="P3";
        fnum=[4 41];
    else
%        H=errordlg("制御対象を選択してください");
        H=errordlg("Select Control Object Trans.");
        uiwait(H);
        %exit;終了してしまう?
    end
end


function [C]=set_pid_cont(KP,TI,TD)
    if(TI!=0)
        if(TD!=0)
            tau=0.1*TD;%Uのグラフを描くためこの形式を使用
            C=KP*(1+tf(1,[TI 0])+tf([TD 0],[tau 1]));
        else
            C=KP*(1+tf(1,[TI 0]));
        end
    else

        if(TD!=0)
            tau=0.1*TD;%Uのグラフを描くためこの形式を使用
            C=KP*(1+tf([TD 0],[tau 1]));
        else
            C=KP;
        end
    end
end

function [GC UC]=set_close_tf(C,P)
    L=C*P;
    GC=minreal(L/(1+L));
    UC=minreal(C/(1+L));%入力表示
end
function Time_sim(GCL,UCL, leg,ti,fnum,wind)

    cl={[0 0 1],[0 0.51 0],[1 0 0],[0.3  0.74 0.93],[0.49 0.18 0.55],[0.93 0.69 0.12],[0 0.44 0.74],[0.46  0.67 0.18],[0.85  0.32 0.09]};
    %bgrcm(紫)ybg(薄緑)r(茶)

    %linewidthはpt, 1.5pt=2px,1.125pt=1.5px
    lw=1.125;

    [c lnum ]=size(leg);%legendの数(入力で),1*lnum
    for i=1:lnum
        y(:,i)=step(GCL{i},ti);
        uin(:,i)=step(UCL{i},ti);
    end
    figure(fnum,"position",wind)
    set(fnum,"position",wind);
    clf
    figure(fnum);%,"position",wind)

    for i=1:lnum
        plot(ti,y(:,i),'color',cl{i+3},'linewidth',lw);%rを避けるため+3
        hold on
    end
    set(gca,'xlabel','time s','ylabel','y');

    if(lnum==2)
        legend(leg{1},leg{2},'location','southeast');
    elseif(lnum==3)
        legend(leg{1},leg{2},leg{3},'location','southeast');
    elseif(lnum==4)
        legend(leg{1},leg{2},leg{3},leg{4},'location','southeast');
    end

    fnum=fnum+1;
    figure(fnum,"position",wind)
    set(fnum,"position",wind);
    clf
    figure(fnum);%,"position",wind)

    for i=1:lnum
        plot(ti,uin(:,i),'color',cl{i+3},'linewidth',lw);%rを避けるため+3
        hold on
    end
    set(gca,'xlabel','time s','ylabel','u in');


    if(lnum==2)
        legend(leg{1},leg{2},'location','southeast');
    elseif(lnum==3)
        legend(leg{1},leg{2},leg{3},'location','southeast');
    elseif(lnum==4)
        legend(leg{1},leg{2},leg{3},leg{4},'location','southeast');
    end
end


function [r st bl]=get_from_edit(edit_value)

    bl=1;
    if(size(edit_value)==0)%空白の場合を見つける
        bl=false;
    end

    [r st]=str2num(edit_value);%status:数値以外は0,ただし空白でもtrue

    if ((st==false)|| (bl==false))%数値以外は0で戻る
        r=0;
    end
end

function update_plot(obj, init=false)
    hs=guidata(obj);

    P1_select=get(hs.rbP1,"value");
    P2_select=get(hs.rbP2,"value");
    P3_select=get(hs.rbP3,"value");

    lmt_sense=get(hs.rb_lmt,"value");
    step_method=get(hs.rb_open,"value");

    STEP_res_draw=false;
    STEP_res_file=false;
    Q1_STEP_res_draw=false;
    Q1_STEP_res_file=false;


    tag=1;
    [lmt_gain_gui st(tag) bl(tag)]=get_from_edit(get(hs.rb_lmt_gain_edit,"string"));  tag=tag+1;

    [Lmt_K_val_gui  st(tag) bl(tag)]=get_from_edit(get(hs.Lmt_K_edit,"string")); tag=tag+1;
    [Lmt_Ti_val_gui st(tag) bl(tag)]=get_from_edit(get(hs.Lmt_Ti_edit,"string")); tag=tag+1;
    [Lmt_Td_val_gui st(tag) bl(tag)]=get_from_edit(get(hs.Lmt_Td_edit,"string")); tag=tag+1;

    [Step_K_val_gui st(tag) bl(tag)]=get_from_edit(get(hs.Step_K_edit,"string")); tag=tag+1;
    [Step_Ti_val_gui st(tag) bl(tag)]=get_from_edit(get(hs.Step_Ti_edit,"string")); tag=tag+1;
    [Step_Td_val_gui st(tag) bl(tag)]=get_from_edit(get(hs.Step_Td_edit,"string")); tag=tag+1;

    [Tune_K_val_gui st(tag) bl(tag)]=get_from_edit(get(hs.Tune_K_edit,"string")); tag=tag+1;
    [Tune_Ti_val_gui st(tag) bl(tag)]=get_from_edit(get(hs.Tune_Ti_edit,"string")); tag=tag+1;
    [Tune_Td_val_gui st(tag) bl(tag)]=get_from_edit(get(hs.Tune_Td_edit,"string")); tag=tag+1;

    % get_call_back_object:
    ## gcbo holds the handle of the control
    switch (gcbo)
      case {hs.rbP1} % buttongroupは全イベント起こるので場合分け必要
        if ( (get(hs.rbP1, "value")==true) && (get(hs.rbP2, "value")==false) &&  (get(hs.rbP3, "value")==false) )
            P1_select=true;
            P2_select=false;
            P3_select=false;
        else
            P1_select=false;
            P2_select=false;
            P3_select=false;
        end
      case {hs.rbP2}
        if ( (get(hs.rbP1, "value")==false) && (get(hs.rbP2, "value")==true) &&  (get(hs.rbP3, "value")==false) )
            P2_select=true;
            P1_select=false;
            P3_select=false;
        else
            P1_select=false;
            P2_select=false;
            P3_select=false;
        end
      case {hs.rbP3}
        if ( (get(hs.rbP1, "value")==false) && (get(hs.rbP2, "value")==false) &&  (get(hs.rbP3, "value")==true) )
            P3_select=true;
            P1_select=false;
            P2_select=false;
        else
            P1_select=false;
            P2_select=false;
            P3_select=false;
        end


      case {hs.rb_lmt}
        if ( (get(hs.rb_lmt, "value")==true) && (get(hs.rb_open, "value")==false))
            lmt_sense=true;
            step_method=false;
        else
            lmt_sense=false;
            step_method=false;
        end
      case {hs.rb_open}
        if ( (get(hs.rb_open, "value")==true) && (get(hs.rb_lmt, "value")==false))
            step_method=true;
            lmt_sense=false;
        else
            lmt_sense=false;
            step_method=false;
        end
      case {hs.rb_lmt_gain_edit}
        tag=1;
        [lmt_gain_gui st(tag) bl(tag)]=get_from_edit(get(gcbo,"string"));
        STEP_res_draw=true;
      case {hs.STEP_res_button}
        STEP_res_draw=true;
      case {hs.STEP_res_file_button}
        STEP_res_file=true;
      case {hs.STEP_res_button_1}
        Q1_STEP_res_draw=true;
      case {hs.STEP_res_file_button_1}
        Q1_STEP_res_file=true;
      case {hs.Step_K_edit}
        tag=5;
        [Step_K_val_gui st(tag) bl(tag)]=get_from_edit(get(gcbo, "string"));
      case {hs.Step_Ti_edit}
        tag=6;
        [Step_Ti_val_gui st(tag) bl(tag)]=get_from_edit(get(gcbo, "string"));
      case {hs.Step_Td_edit}
        tag=7;
        [Step_Td_val_gui st(tag) bl(tag)]=get_from_edit(get(gcbo, "string"));

      case {hs.Tune_K_edit}
        tag=8;
        [Tune_K_val_gui st(tag) bl(tag)]=get_from_edit(get(gcbo, "string"));
      case {hs.Tune_Ti_edit}
        tag=9;
        [Tune_Ti_val_gui st(tag) bl(tag)]=get_from_edit(get(gcbo, "string"));
      case {hs.Tune_Td_edit}
        tag=10;
        [Tune_Td_val_gui st(tag) bl(tag)]=get_from_edit(get(gcbo, "string"));

    end %end of case

    if (min(bl)==0)
        %        msgbox("PIDパラメータに空白の設定を発見しましたので0としました","注意")
        msgbox("FOUND blank term in PID pars.,  treated as zero.","caution");
    end
    if (min(st)==0)
        %        msgbox("PIDパラメータに数値以外の設定を発見しましたので0としました","注意")
        msgbox("FOUND non number on PID pars., treated as zero","caution");
    end

    if((STEP_res_draw==true) || (STEP_res_file==true))

        if((step_method==false) && (lmt_sense==false))
            %            H=errordlg("出力応答方法を選択してください");
            H=errordlg("Set OUTPUT method","caution");
            uiwait(H);
            return
        end


        [P tnum lab fnum]=set_model(obj,P1_select,P2_select,P3_select);
        %tnum=[開ループsim時間 閉ループsim時間]
        dt=0.01;
        ti=[0:dt:tnum(1)];

        if(lmt_sense==true)
            L=lmt_gain_gui*P;
            G=L/(1+L);
            fn=fnum(1);%lmd/stpで図番変える
                       %msgbox(["制御対象" lab "の限界感度法実施"],"出力応答実施");
            msgbox(["Exec limit sens. method using " lab ],"OUTPUT");
        elseif(step_method==true)
            G=P;
            fn=fnum(1)*10;
            %            msgbox(["制御対象" lab "のステップ応答実施"],"出力応答実施");
            msgbox(["STEP resp. using " lab ],"OUTPUT");
        else
            return
        end
        %PID設計用の出力応答を見る時はfnumはPによって変える@set_model
        fh=figure(fn);%,"position",hs.wind);
        set(fh,"position",hs.wind);
        figure(fn)
        step(G,ti);
        legend("off");

        if(STEP_res_file==true)
            prt_fig(["OUT_res_" lab ],fn);%lab:P1,P2,P3
            %            msgbox(["fig\\_" num2str(fn) "\\_OUT\\_res.pngで保存しました"],"案内");
            msgbox(["Saved as fig\\_" num2str(fn) "\\_OUT\\_res\\_" lab ".png"],"Announce");
            %uiwaitなしでmsgboxを連続すると、別windowが開くが、スルーする
        end

    end % end of 出力応答

    %pid制御器設計
    c_lmt=set_pid_cont(Lmt_K_val_gui,Lmt_Ti_val_gui,Lmt_Td_val_gui);
    c_step=set_pid_cont(Step_K_val_gui,Step_Ti_val_gui,Step_Td_val_gui);
    c_tune=set_pid_cont(Tune_K_val_gui,Tune_Ti_val_gui,Tune_Td_val_gui);
    if((Q1_STEP_res_draw==true) || (Q1_STEP_res_file==true))
        [P tnum lab fnum]=set_model(obj,P1_select,P2_select,P3_select);
%        msgbox(["制御対象は" lab "(s)です"]);
        msgbox([lab "(s) is Control object"]);
        %tnum=[開ループsim時間 閉ループsim時間]
        dt=0.01;
        ti=[0:dt:tnum(2)];
        [GC{1} UC{1}]=set_close_tf(c_lmt,P);
        [GC{2} UC{2}]=set_close_tf(c_step,P);
        [GC{3} UC{3}]=set_close_tf(c_tune,P);

        leg={"set1","set2","set3"};%1*3

        Time_sim(GC, UC, leg,ti,fnum(2),hs.wind);

        if(Q1_STEP_res_file==true)
            prt_fig(["Q1_" lab],fnum(2));%lab:P1,or,P2
            prt_fig(["Q1_" lab],fnum(2)+1);%制御入力
            fnbody=["\\_Q1\\_" lab ".png"];
            %            msgbox(["fig\\_" num2str(fnum(2)) fnbody "と\n fig\\_" num2str(fnum(2)+1) fnbody "で保存しました"]);
            msgbox(["Saved as fig\\_" num2str(fnum(2)) fnbody "and\n fig\\_" num2str(fnum(2)+1) fnbody ],"Success");

        end

    end
end


gp = uibuttongroup ("title","制御対象","Position", [ 0.05 0.56 0.13 0.43]);

%## Create a buttons in the group
h.rbP1 = uicontrol (
		    "parent", gp,
		    "style", "radiobutton",
		    "units", "normalized",
		    "string", "P1(s)",
		    "value", false,
		    "horizontalalignment", "left",
		    "Position", [ 0.1 0.7 0.8 0.2 ],
		    "callback",@update_plot);
h.rbP2 = uicontrol (
		    "parent", gp,
		    "style", "radiobutton",
		    "units", "normalized",
		    "string", "P2(s)",
		    "value", false,
		    "horizontalalignment", "left",
		    "Position", [ 0.1 0.4 0.8 0.2 ],
		    "callback",@update_plot);
h.rbP3 = uicontrol (
		    "parent",gp,
		    "style", "radiobutton",
		    "units", "normalized",
		    "string", "P3(s)",
		    "value", false,
		    "horizontalalignment", "left",
		    "Position", [ 0.1 0.1 0.8 0.2 ],
		    "callback",@update_plot);
% b1/b2/b3いずれかだけ


h.Menu=uipanel("title","出力応答実施項目設定","position",[0.2 0.56 0.75 0.43]);

gp2 = uibuttongroup (h.Menu, "title","出力応答","Position", [ 0.01 0.1 0.6 0.8]);

%## Create a buttons in the group
h.rb_lmt = uicontrol (
		    "parent", gp2,
		    "style", "radiobutton",
		    "units", "normalized",
		    "string", "限界感度法",
		    "value", false,
%		    "callback",@update_plot,
		    "horizontalalignment", "left",
		    "Position", [ 0.01 0.7 0.7 0.22 ]);

h.rb_open = uicontrol (
		    "parent", gp2,
		    "style", "radiobutton",
		    "units", "normalized",
		    "string", "ステップ応答",
		    "value", false,
%		    "callback",@update_plot,
		    "horizontalalignment", "left",
		    "Position", [ 0.01 0.1 0.7 0.22 ]);

h.rb_lmt_label = uicontrol (
		    "parent", gp2,
		    "style", "text",
		    "units", "normalized",
		    "string", "限界感度法のゲインK",
		    "value", false,
%		    "callback",@update_plot,
		    "horizontalalignment", "left",
		    "Position", [ 0.1 0.45 0.62 0.22 ]);

h.rb_lmt_gain_edit = uicontrol (
		    "parent", gp2,
		    "style", "edit",
		    "units", "normalized",
		    "string", "1",
%		    "value", "",
		    "horizontalalignment", "left",
		    "Position", [ 0.73 0.45 0.2 0.22 ],
		    "callback",@update_plot);

h.STEP_res_button=uicontrol(
    "parent",h.Menu,
    "style","pushbutton",
    "units", "normalized",
    "string","出力応答表示",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", [0.63 0.6 0.35 0.2]);

h.STEP_res_file_button=uicontrol(
    "parent",h.Menu,
    "style","pushbutton",
    "units", "normalized",
    "string","出力応答ファイル保存",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", [0.63 0.2 0.35 0.2]);


h.Q1=uipanel("title","PID Gain set","position",[0.05 0.05 0.9 0.5]);

p_x_pos=0.01;
p_y_pos=0.65;
p_width=0.7;
p_l_width=p_width/10 ;%label_width
p_e_width=p_l_width*2.8;%editbox_width
p_height=0.32;


h.Lmt=uipanel("parent",h.Q1,
	      "title","ゲインset1","position",[p_x_pos p_y_pos p_width p_height]);
h.Step=uipanel("parent",h.Q1,
	       "title","ゲインset2","position",[p_x_pos p_y_pos-p_height p_width p_height]);
h.Tune=uipanel("parent",h.Q1,
	       "title","ゲインset3","position",[p_x_pos p_y_pos-p_height*2 p_width p_height]);



h.STEP_res_button_1=uicontrol(
    "parent",h.Q1,
    "style","pushbutton",
    "units", "normalized",
    "string","出力応答表示",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", [0.71 0.5 0.28 0.2]);
h.STEP_res_file_button_1=uicontrol(
    "parent",h.Q1,
    "style","pushbutton",
    "units", "normalized",
    "string","出力応答ファイル保存",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", [0.71 0.1 0.28 0.2]);



%label_mn:m行n列
label_11=[0.05 0.05 p_l_width 0.8];
label_12=[0.05+p_l_width 0.05 p_e_width 0.8];
label_13=[0.1+p_l_width+p_e_width*1 0.05 p_l_width 0.8];
label_14=[0.1+p_l_width*2+p_e_width*1 0.05 p_e_width 0.8];
label_15=[0.15+p_l_width*2+p_e_width*2 0.05 p_l_width 0.8];
label_16=[0.15+p_l_width*3+p_e_width*2 0.05 p_e_width 0.8];
label_btn=[0.75 0.1 0.2 0.2];



h.Lmt_K_label=uicontrol(
    "parent",h.Lmt,
    "style","text",
    "units", "normalized",
    "string","Kp",
%    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_11);
h.Lmt_K_edit=uicontrol(
    "parent",h.Lmt,
    "style","edit",
    "units", "normalized",
    "string","0",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_12);

h.Lmt_Ti_label=uicontrol(
    "parent",h.Lmt,
    "style","text",
    "units", "normalized",
    "string","Ti",
%    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_13);
h.Lmt_Ti_edit=uicontrol(
    "parent",h.Lmt,
    "style","edit",
    "units", "normalized",
    "string","0",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_14);
h.Lmt_Td_label=uicontrol(
    "parent",h.Lmt,
    "style","text",
    "units", "normalized",
    "string","Td",
%    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_15);
h.Lmt_Td_edit=uicontrol(
    "parent",h.Lmt,
    "style","edit",
    "units", "normalized",
    "string","0",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_16);

h.Step_K_label=uicontrol(
    "parent",h.Step,
    "style","text",
    "units", "normalized",
    "string","Kp",
%    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_11);
h.Step_K_edit=uicontrol(
    "parent",h.Step,
    "style","edit",
    "units", "normalized",
    "string","0",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_12);

h.Step_Ti_label=uicontrol(
    "parent",h.Step,
    "style","text",
    "units", "normalized",
    "string","Ti",
%    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_13);
h.Step_Ti_edit=uicontrol(
    "parent",h.Step,
    "style","edit",
    "units", "normalized",
    "string","0",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_14);

h.Step_Td_label=uicontrol(
    "parent",h.Step,
    "style","text",
    "units", "normalized",
    "string","Td",
%    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_15);
h.Step_Td_edit=uicontrol(
    "parent",h.Step,
    "style","edit",
    "units", "normalized",
    "string","0",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_16);


h.Tune_K_label=uicontrol(
    "parent",h.Tune,
    "style","text",
    "units", "normalized",
    "string","Kp",
%    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_11);
h.Tune_K_edit=uicontrol(
    "parent",h.Tune,
    "style","edit",
    "units", "normalized",
    "string","0",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_12);

h.Tune_Ti_label=uicontrol(
    "parent",h.Tune,
    "style","text",
    "units", "normalized",
    "string","Ti",
%    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_13);
h.Tune_Ti_edit=uicontrol(
    "parent",h.Tune,
    "style","edit",
    "units", "normalized",
    "string","0",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_14);
h.Tune_Td_label=uicontrol(
    "parent",h.Tune,
    "style","text",
    "units", "normalized",
    "string","Td",
%    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_15);
h.Tune_Td_edit=uicontrol(
    "parent",h.Tune,
    "style","edit",
    "units", "normalized",
    "string","0",
    "callback", @update_plot,
    "horizontalalignment", "left",
    "position", label_16);





set(h.gf, "color", get(h.gf, "defaultuicontrolbackgroundcolor"));
guidata(h.gf,h);
update_plot(h.gf,true);
