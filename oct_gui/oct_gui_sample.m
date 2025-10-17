clear all
close all
clc


function mylist_callback(hs,evt, arg1)
    msgbox(get(hs,"string"){get(hs,"value")},"ListboxSelection");
end

function mybutton_grb(hs,evt, arg1)
    msgbox(["called from grb " num2str(arg1)],"group button");
end

function update_menu(obj, init=false)

    hs=guidata(obj);
    %gcbo holds the habdle of the control
    switch(gcbo)
      case {hs.gb1}
        if((get(hs.gb1,"value")==true) && (get(hs.gb2,"value")==false))
           msgbox("Choice1","Selected");
        end
      case {hs.gb2}
        if((get(hs.gb2,"value")==true) && (get(hs.gb1,"value")==false))
           msgbox("Choice2","Selected");
        end
      case {hs.tglbtn1}% 0/1変化
        num=get(gcbo, "value");
        disp(num)
      case {hs.ed1}
        ed_gui=get(gcbo,"string");
        disp(ed_gui);
      case {hs.cb1}
        cb1_gui=get(gcbo,"value");
        disp(cb1_gui);
      case {hs.slb1}
        slb1_num_gui=get(gcbo,"value");
        set(hs.slb1_num,"string",num2str(slb1_num_gui));
    end
end


%## Create figure and panel on it
h.f=figure("position",[100 100 640 480]);

h.p = uipanel ("title", "Panel Title Menu",
               "units", "normalized",
               "position", [.4 .25 .3 .2]);

%## add two buttons to the panel
h.b1 = uicontrol ("parent", h.p,
                  "string", "A Button", 
                  "units", "normalized",
                  "horizontalalignment", "left",
                  "position", [.1 .6 .8 .3],
                  "callback", @update_menu);

h.b2 = uicontrol ("parent", h.p,
                  "string", "Another Button", 
                  "units", "normalized",
                  "horizontalalignment", "left",
                  "position",[.1 .2 .8 .3],
                  "callback", @update_menu);

%## Create a button group
h.gp = uibuttongroup ("parent",h.f,
                      "units", "normalized",
                      "Position", [0 0.8 1 0.2]);
%## Create a buttons in the group
h.gb1 = uicontrol ("parent", h.gp,
                   "style", "radiobutton", 
                   "string", "Choice 1",
                   "value",false,
                   "units", "normalized",
                   "horizontalalignment", "left",
                   "position", [ .1 .6 .2 .2 ],
                   "callback", @update_menu);
h.gb2 = uicontrol ("parent", h.gp,
                   "style", "radiobutton",
                   "string", "Choice 2", 
                   "value",false,
                   "units", "normalized",
                   "horizontalalignment", "left",
                   "position", [ .1 .2 .2 .2 ],
                   "callback",@update_menu);

h.gp2 = uibuttongroup ("parent", h.f,
                       "title","grb",
                       "units", "normalized",
                       "Position", [ 0.4 0.5 0.3 0.15] );

h.grb1 = uicontrol ("parent",h.gp2,
                    "style", "radiobutton",
                    "string", "Choice grb1",
                    "units", "normalized",
                    "position", [ .1 .6 .7 .3 ],
                    "callback",{@mybutton_grb,1});

h.grb2 = uicontrol ("parent", h.gp2,
                    "style", "radiobutton",
                    "string", "Choice grb2",
                    "units", "normalized",
                    "horizontalalignment", "left",
                    "position", [ .1 .2 .7 .3 ],
                    "callback",{@mybutton_grb,2});

%## Create a button not in the group
h.rb0 = uicontrol ("parent",h.f,
                   "style", "radiobutton",
                   "string", "Not in the group", 
                   "units", "normalized",
                   "horizontalalignment", "left",
                   "position", [ .1 .5 .2 .2 ],
                   "callback", @update_menu);

%## Create an edit control
h.ed1 = uicontrol ("parent", h.f,
                  "style", "edit",
                  "string", "editable text", 
                  "units", "normalized",
                  "horizontalalignment", "left",
		  "position", [.1 .4 .2 .1],
                  "callback", @update_menu );

%## Create a checkbox
h.cb1 = uicontrol ("parent", h.f,
                  "style", "checkbox",
                  "string", "a checkbox", 
                  "units", "normalized",
                  "horizontalalignment", "left",
		  "position", [.1 .2 .15 .1],
                  "callback", @update_menu);

mylist={"hoge1","hoge2","hoge3","hoge4","hoge5"};
h.lb1 = uicontrol ("parent", h.f,
                   "style", "listbox",
                   "string", mylist,
                   "units", "normalized",
                   "horizontalalignment", "left",
                   "position", [.1 0.1 .2 .1],
                   "callback", {@mylist_callback, mylist});

h.cont_list = uicontrol ("parent", h.f,
%                         "title","select controller",
                         "style", "popupmenu",
                         "units", "normalized",
                         "string", {"none",
                                    "PID",
                                    "PoleSet",
                                    "LQ",
                                    "Fuzzy",
                                    "STR",
                                    "SlidingMode",
                                    "BackStepping",
                                    "SimpleAdaptiveCont.",
                                    "ModelPredictCont."},
                         "horizontalalignment", "left",
                         "position", [0.6 0.04 0.2 0.1],
                         "callback", @update_menu);

h.l_label = uicontrol ("parent",h.f,
                       "style", "text",
                       "units", "normalized",
                       "string", "SelectContoller",
                       "horizontalalignment", "left",
                       "position", [0.6 0.15 0.15 0.05]);

%two states,0/1
h.tglbtn1 = uicontrol ("parent",h.f,
                       "style", "togglebutton",
                       "units", "normalized",
                       "string", "tglbtn",
                       "horizontalalignment", "left",
                       "position", [0.15 0.3 0.1 0.05],
                       "callback", @update_menu);

slb_ini=0.4;
h.slb1 = uicontrol ("parent",h.f,
                    "style", "slider",
                    "units", "normalized",
                    "value", slb_ini, % 初期値の指定,max/min指定なければ変化幅は0/1
                    "max",10,
                    "min",-100,
                    "sliderstep",[0.001 0.01],
                    "horizontalalignment", "left",
                    "Position", [ 0.1 0.7 0.3 0.05],
                    "callback",@update_menu);

h.slb1_num=uicontrol("parent",h.f,
                     "style","text",
                    "units", "normalized",
                     "string",num2str(slb_ini),
                     "horizontalalignment", "left",
                     "position", [ 0.42 0.7 0.2 0.05]);

h.sl_ver = uicontrol ("parent",h.f,
                      "style", "slider",
                      "units", "normalized",
                      "string", "volume",
                      "value", 0.4, % 初期値の指定,出力は0/1
                      "horizontalalignment", "left",
                      "Position", [ 0.8 0.4 0.05 0.3],%幅/高さ比で自動的に向きが変わる!
                      "callback",@update_menu);

set (h.f, "color", get(0, "defaultuicontrolbackgroundcolor"));
guidata(h.f, h);
update_menu(h.f, true);

