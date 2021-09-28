------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_activity_add_times_way = i3k_class("wnd_activity_add_times_way",ui.wnd_base)

function wnd_activity_add_times_way:configure()
	local widget = self._layout.vars
	widget.close:onClick(self,self.onCloseUI)
	widget.vip:onClick(self, self.onVip)
	widget.item:onClick(self, self.onItem)
	widget.desc:setText(i3k_get_string(18640))
end

function wnd_activity_add_times_way:refresh(mapId)
	self.mapId = mapId
end

function wnd_activity_add_times_way:onVip()
	local id = self.mapId
	g_i3k_logic:OpenActivityVipBuyTimesUI(id)
end

function wnd_activity_add_times_way:onItem()
	g_i3k_ui_mgr:OpenUI(eUIID_ActivityAddTimesByItem)
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_activity_add_times_way.new()
	wnd:create(layout,...)
	return wnd
end