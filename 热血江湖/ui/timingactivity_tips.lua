module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_timingActivityTips = i3k_class("wnd_timingActivityTips", ui.wnd_base)

function wnd_timingActivityTips:ctor()
	
	self._widgets = nil
	
end

function wnd_timingActivityTips:configure()
	local widgets = self._layout.vars
	widgets.cancel:onClick(self,self.onCloseUI)
end

function wnd_timingActivityTips:refresh()
	local widgets = self._layout.vars
	local activity_id = g_i3k_db.i3k_db_get_timing_activity_id()
	--local cfgName = i3k_db_timing_activity.openday[activity_id].name
	--widgets.title:setText(cfgName)
	local cfgDb = i3k_db_timing_activity.openday[activity_id]
	local openTime =  g_i3k_get_commonDateStr(cfgDb.opentime)
	local endTime = g_i3k_get_commonDateStr(cfgDb.endtime)
	widgets.time:setText(openTime.."-"..endTime)
	widgets.desc:setText(i3k_get_string(cfgDb.titleName))
	widgets.activityInfo:setText(i3k_get_string(cfgDb.activityTarget))
end
--关闭
function wnd_timingActivityTips:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TimingActivityTips);
end

function wnd_create(layout,...)
	local wnd = wnd_timingActivityTips.new()
	wnd:create(layout,...)
	return wnd
end
