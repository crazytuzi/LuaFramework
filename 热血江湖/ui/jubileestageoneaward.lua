--[[
        @Date    : 2019-02-16
        @Author  : zhangbing
        @layout  : zhounianqing
    	@UIID	 : eUIID_JubileeStageOneAward
--]]
module(..., package.seeall)

local require = require;

local ui = require("ui/jubileeBase");
---------------------------------------------------------------

wnd_jubileeStageOneAward = i3k_class("wnd_jubileeStageOneAward", ui.jubileeBase)

function wnd_jubileeStageOneAward:ctor()

end

function wnd_jubileeStageOneAward:configure()
	local widgets = self._layout.vars
	widgets.receiveBtn:onClick(self, self.onRecevieBtn)
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_jubileeStageOneAward:refresh(canReceive)
	if canReceive then
		self._layout.vars.receiveBtn:enableWithChildren()
	else
		self._layout.vars.receiveBtn:disableWithChildren()
	end
	self:loadAwardScroll(i3k_db_jubilee_base.stage1.awards)
end

function wnd_jubileeStageOneAward:onRecevieBtn(sender)
	local awards = i3k_db_jubilee_base.stage1.awards
	local items = g_i3k_db.i3k_db_cfg_items_to_BagEnougMap(awards)
	if not g_i3k_game_context:IsBagEnough(items) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
	end
    i3k_sbean.jubilee_activity_step1_reward()
end

function wnd_create(layout)
	local wnd = wnd_jubileeStageOneAward.new()
	wnd:create(layout)
	return wnd
end