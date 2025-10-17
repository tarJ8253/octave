clear all
close all
clc


[fname fpath fltindex]=uigetfile("d:\\home\\takiyama\\docs\\*.pdf");

[fname fpath fltindex]=uiputfile();


H=msgbox("OK!?","Title");
uiwait(H)

H=errordlg("ERROR!","DANGER!");
uiwait(H)

H=helpdlg("HELP YOU","MayI");
uiwait(H)


H=warndlg("WARNING!!!","Caution");
uiwait(H)

%uiwait(H) がないと、OK ボタンを押さなくてもプログラム実行は次に進んでいきます。

btn = questdlg ("Close Octave?", "Some fancy title", "Yes", "No", "No");
if (strcmp (btn, "Yes"))
exit ();
else
H=msgbox("Octave continue");
uiwait(H)
endif

prompt = {"Width", "Height", "Depth"};
defaults = {"1.10", "2.20", "3.30"};
rowscols = [1,10; 2,20; 3,30];
dims = inputdlg (prompt, "Enter Box Dimensions", rowscols, defaults);


