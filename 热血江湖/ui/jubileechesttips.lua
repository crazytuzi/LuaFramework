--[[
        @Date    : 2019-02-20
        @Author  : zhangbing
        @Class   : zhounianqingbxtips
    	@UIID	 : eUIID_JubileeChestTip
--]]
module(..., package.seeall)

local require = require;

local ui = require("ui/jubileeBase");
---------------------------------------------------------------

wnd_jubileeChestTips = i3k_class("wnd_jubileeChestTips", ui.jubileeBase)

function wnd_jubileeChestTips:ctor()

end

function wnd_jubileeChestTips:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.desc:setText(i3k_get_string(17932))
end

function wnd_jubileeChestTips:refresh(taskType)
	local cfg = i3k_db_jubilee_base.stage2.taskAwards
	self:loadAwardScroll(cfg[taskType])	
end

function wnd_create(layout)
	local wnd = wnd_jubileeChestTips.new()
	wnd:create(layout)
	return wnd
end