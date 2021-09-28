-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_biography_map_exit = i3k_class("wnd_biography_map_exit", ui.wnd_base)

function wnd_biography_map_exit:ctor()
	self._countDown = 0
end

function wnd_biography_map_exit:configure()
	self._layout.vars.ok:onClick(self, self.onOkBtn)
end

function wnd_biography_map_exit:refresh()
	self._layout.vars.desc:setText(i3k_get_string(18518))
end

function wnd_biography_map_exit:onUpdate(dTime)
	self._countDown = self._countDown + dTime
	self._layout.vars.btnName:setText(i3k_get_string(18519, math.ceil(i3k_db_biography_career_common.leaveCountdown - self._countDown)))
	if self._countDown >= i3k_db_biography_career_common.leaveCountdown then
		g_i3k_ui_mgr:AddTask(self, {}, function()
			--[[local callback = function ()
				g_i3k_ui_mgr:OpenUI(eUIID_OutCareerPractice)
				g_i3k_ui_mgr:RefreshUI(eUIID_OutCareerPractice, careerId)
			end
			i3k_sbean.mapcopy_leave(nil, callback)--]]
			i3k_sbean.mapcopy_leave()
			g_i3k_ui_mgr:CloseUI(eUIID_BiographyMapExit)
		end, 1)
	end
end

function wnd_biography_map_exit:onOkBtn(sender)
	i3k_sbean.mapcopy_leave()
	g_i3k_ui_mgr:CloseUI(eUIID_BiographyMapExit)
end

function wnd_create(layout)
	local wnd = wnd_biography_map_exit.new()
	wnd:create(layout)
	return wnd
end