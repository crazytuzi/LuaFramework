
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_woodManShare = i3k_class("wnd_woodManShare",ui.wnd_base)

function wnd_woodManShare:ctor()
	self.damageCnt = 0
	self.damage = 0
	self.time = 0
end

function wnd_woodManShare:configure()

end

function wnd_woodManShare:refresh(time, damageCnt, damage, monsterId)
	self.damageCnt = damageCnt or 0
	self.damage = damage or 0
	self.time = time or 0
	self.monsterId = monsterId

	local widget = self._layout.vars
	widget.timeCnt:setText(time)
	widget.damCnt:setText(damageCnt)
	widget.damTxt:setText(damage)
	widget.desc:setText(i3k_get_string(968))
	widget.ok:onClick(self, self.share)
	widget.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_woodManShare:share()
	local msg = string.format("#DPS%d,%d,%d,%d#",self.time, self.damageCnt, self.damage, self.monsterId)
	i3k_sbean.world_msg_send_req(msg)
	self:onCloseUI()
end

function wnd_woodManShare:onHide()
	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_woodMan, "ResetBreakState")
	g_i3k_game_context:clearWoodManDamage()
end

function wnd_create(layout, ...)
	local wnd = wnd_woodManShare.new()
	wnd:create(layout, ...)
	return wnd;
end

