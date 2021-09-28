module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_springRollQuiz = i3k_class("wnd_springRollQuiz", ui.wnd_base)

function wnd_springRollQuiz:ctor()
	self._answer = nil
	self._npcID = nil
end

function wnd_springRollQuiz:configure()
	local widgets = self._layout.vars
	
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	
	self.btn = widgets.btn
	self.btn:onClick(self, self.onBtnClick)
	
	self.time = widgets.time
	self.activityInfo = widgets.activityInfo
end

function wnd_springRollQuiz:refresh()
	self.time:setText(i3k_get_string(19031, g_i3k_get_commonDateStr(i3k_db_spring_roll.baseConfig.openTime), g_i3k_get_commonDateStr(i3k_db_spring_roll.baseConfig.endTime)))
	self.activityInfo:setText(i3k_get_string(19029, i3k_db_npc[i3k_db_spring_roll.rollConfig.npcID].remarkName))
end

function wnd_springRollQuiz:onBtnClick(sender)
	local isSpringRollOpen = g_i3k_game_context:checkSpringRollOpen()
	if not isSpringRollOpen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19167))
		g_i3k_ui_mgr:CloseUI(eUIID_SpringRollTips)
		return
	end
	g_i3k_game_context:GotoNpc(i3k_db_spring_roll.rollConfig.npcID)
	g_i3k_ui_mgr:CloseUI(eUIID_SpringRollTips)
end

function wnd_create(layout, ...)
	local wnd = wnd_springRollQuiz.new()
	wnd:create(layout, ...)
	return wnd
end