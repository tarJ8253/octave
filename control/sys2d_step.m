clear all
close all
clc

%graphics_toolkit qt%なくてもいい

pkg load control

h.fnc= @(w,z) tf([w*w],[1 2*z*w w*w]);
%h.gf=figure("position",[100 100 700 600],"name","2次標準形式のステップ応答");
h.gf=figure("position",[50 50 560 420],"name","2次標準形式のステップ応答");
%defaultは[300 200 560 420].4:3


function update_plot(obj, init=false)
    hs=guidata(obj);
    replot=false;
    recalc=false;
    % getcallbackobject:
    ## gcbo holds the handle of the control
    switch (gcbo)
      case {hs.zeta_sl}
        zeta_gui=get(gcbo, "value");
        replot=true;
        recalc=true;
        omega_gui=get(hs.omega_sl,"value");
        set(hs.zeta_value,"string",num2str(zeta_gui));
      case {hs.omega_sl}
        omega_gui=get(gcbo, "value");
        replot=true;
        recalc=true;
        zeta_gui=get(hs.zeta_sl,"value");
        set(hs.omega_value,"string",num2str(omega_gui));
    end

    if(recalc==true)
        omega_n=omega_gui;
        zeta=zeta_gui;
        G=hs.fnc(omega_n,zeta);
        [y t]=step(G);
    end
    
    if(replot==true)
        hs.plot=plot(t,y);
        set(gca,"xlabel","time s","ylabel", "y out","fontsize",20);
        %guidata (obj, hs);
    end
    
end

h.p=uipanel(
    "title","\omega, \zeta vary",
    "position",[0.05 0.05 0.9 0.2]);

zeta_ini=0.1;
omega_ini=1;

h.zeta_disp=uicontrol(
    "parent",h.p,
    "style","text",
    "units", "normalized",
    "string","zeta",
    "horizontalalignment", "left",
    "position", [0 0.1 0.1 0.2]);

h.zeta_value=uicontrol(
    "parent",h.p,
    "style","text",
    "units", "normalized",
    "string",num2str(zeta_ini),
    "horizontalalignment", "left",
    "position", [0.1 0.1 0.1 0.2]);

h.zeta_sl=uicontrol(
    "parent",h.p,
    "style","slider",
    "units", "normalized",
    "string", "slider",
    "value", zeta_ini,
    "max",2,
    "min",0.001,
    "sliderstep",[0.01 0.1],
    "horizontalalignment", "left",
    "position", [0.2 0.1 0.75 0.2],
    "callback", @update_plot );

h.omega_disp=uicontrol(
    "parent",h.p,
    "style","text",
    "units", "normalized",
    "string","omega",
    "horizontalalignment", "left",
    "position", [0 0.5 0.1 0.2]);

h.omega_value=uicontrol(
    "parent",h.p,
    "style","text",
    "units", "normalized",
    "string",num2str(omega_ini),
    "horizontalalignment", "left",
    "position", [0.1 0.5 0.1 0.2]);


h.omega_sl=uicontrol(
    "parent",h.p,
    "style","slider",
    "units", "normalized",
    "string", "slider",
    "value", omega_ini,
    "max",100,
    "min",0.1,
    "sliderstep",[0.001 0.01],
    "position", [0.2 0.5 0.75 0.2],
    "callback", @update_plot );


set (h.gf, "color", get(h.gf, "defaultuicontrolbackgroundcolor"));

h.ax=axes(h.gf,"position",[0.1 0.4 0.8 0.55]);

%初期描画用伝達関数step応答
G=h.fnc(omega_ini,zeta_ini);
[y t]=step(G);
h.plot=plot(t,y);
set(gca,"xlabel","time s","ylabel", "y out","fontsize",20);

guidata(h.gf,h);% guidata(figure handle,datacontainer)
%これがなかったらerror : matrix cannot be indexed with . になる

update_plot(h.gf,true);




