module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_springInvite = i3k_class("wnd_springInvite", ui.wnd_base)

function wnd_springInvite:ctor()
    self._scheduler = nil
    self._callback = nil
end

function wnd_springInvite:configure()
    local vars = self._layout.vars
    local time = i3k_db_spring.common.inviteTime
    vars.time:setText(i3k_get_string(3186, time));
    self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
        time = time - 1
        vars.time:setText(i3k_get_string(3186, time));
        if time <= 0 then
            if self._callback then
                self._callback(false)
            end
            g_i3k_ui_mgr:CloseUI(eUIID_SpringInvite)
        end
    end, 1, false)
end

function wnd_springInvite:refresh(btnTitle, msg, isShowClose, callback)
    local vars = self._layout.vars
    self._callback = callback
    vars.btnTitle:setText(btnTitle)
    vars.desc:setText(msg)
    vars.closeBtn:setVisible(isShowClose)
    vars.btn:onClick(self, function  ()
        callback(true)
        --g_i3k_ui_mgr:CloseUI(eUIID_SpringInvite)
    end)
    vars.closeBtn:onClick(self, function  ()
        callback(false)
        --g_i3k_ui_mgr:CloseUI(eUIID_SpringInvite)
    end)
    vars.tips:setText(i3k_get_string(3185))
end

function wnd_springInvite:onHide()
	if self._scheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler)
		self._scheduler = nil
	end
end

-------------------------------------
function wnd_create(layout)
	local wnd = wnd_springInvite.new();
		wnd:create(layout);
	return wnd;
end
