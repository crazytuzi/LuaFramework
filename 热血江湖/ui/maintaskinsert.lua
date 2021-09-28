module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_maintaskInsert = i3k_class("wnd_maintaskInsert", ui.wnd_base)

function wnd_maintaskInsert:ctor()
	
end

function wnd_maintaskInsert:configure()
	local widgets = self._layout.vars
	local closeBtn = widgets.closebtn
	closeBtn:onClick(self,self.onCloseUI)
end

function wnd_maintaskInsert:onCloseUI(sender)
	local mId,mVlaue = g_i3k_game_context:getMainTaskIdAndVlaue()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMainTask",mId,mVlaue)
	g_i3k_game_context:RefreshMissionEffect()
	g_i3k_ui_mgr:CloseUI(eUIID_MainTaskInsertUI)
end

function wnd_create(layout)
	local wnd = wnd_maintaskInsert.new();
		wnd:create(layout);
	return wnd;
end