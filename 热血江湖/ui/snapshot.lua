module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_snapShot = i3k_class("wnd_snapShot", ui.wnd_base)
function wnd_snapShot:ctor()

end

function wnd_snapShot:configure()
	self._layout.vars.snapShotBtn:onClick(self, self.onSnapShotBtn)
	self._layout.vars.restoreBtn:onClick(self, self.onRestoreBtn)
	self._layout.vars.ShareBtn:onClick(self,self.onShare)
end

function wnd_snapShot:refresh()

end

function wnd_snapShot:onShow()
	local ShareBtn = self._layout.vars.ShareBtn
	ShareBtn:setVisible(false)
	if i3k_game_get_os_type() ~= eOS_TYPE_IOS then
	    if	g_i3k_game_handler:IsSupportShareSDK() then
	 	     ShareBtn:setVisible(true)
	    end
	else 
	 ShareBtn:setVisible(true)
	end
	ShareBtn:setVisible(false)
 end
function wnd_snapShot:onShare(sender)
	g_i3k_game_handler:ShareScreenSnapshotAndText(i3k_get_string(15370), true)
end


function wnd_snapShot:onSnapShotBtn(sender)
	if i3k_game_get_os_type() == eOS_TYPE_IOS then -- 系统为ios
		g_i3k_game_handler:SnapshotScreen("screenshot.png", false);
	else
		-- 其它os
		local time = os.date("%Y-%m-%d-%H-%M-%S",i3k_game_get_systime())
		local path = "screenshot"..time..".png"
		g_i3k_game_handler:SnapshotScreen(path, false);
		g_i3k_ui_mgr:PopupTipMessage("档保存为："..path)
	end
end

function wnd_snapShot:onRestoreBtn(sender)
	g_i3k_logic:ShowBattleUI(true)
	-- local cfg = g_i3k_game_context:GetUserCfg()
	-- local isTouchOperate = cfg:GetIsTouchOperate()
	-- g_i3k_game_handler:EnableObjHitTest(true, isTouchOperate)
	g_i3k_ui_mgr:CloseUI(eUIID_SnapShot)
end


function wnd_create(layout)
	local wnd = wnd_snapShot.new();
		wnd:create(layout);
	return wnd;
end
