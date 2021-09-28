-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gmEntrance = i3k_class("wnd_gmEntrance", ui.wnd_base)

function wnd_gmEntrance:ctor()
	self.moved = false
end

function wnd_gmEntrance:configure()
	
end

function wnd_gmEntrance:refresh()
	self._layout.vars.backBtn:onTouchEvent(self, self.openBackstage)
end

function wnd_gmEntrance:showInternalInjury(internalInjuryDamage)
	self._layout.vars.test_num:setText(internalInjuryDamage)
end
function wnd_gmEntrance:openBackstage(sender, eventType)
	local parent = self._layout.vars.backBtn:getParent()
	local touchPos = g_i3k_ui_mgr:GetMousePos()
	local pos = {}
	if parent then
		pos = parent:convertToNodeSpace(cc.p(touchPos.x,touchPos.y))
	end
	if eventType == ccui.TouchEventType.began then
		self.moved = false
	elseif eventType == ccui.TouchEventType.moved then
		self.moved = true
		self._layout.vars.backBtn:setPosition(pos)
	elseif eventType == ccui.TouchEventType.ended then
		if not self.moved then
			g_i3k_ui_mgr:OpenUI(eUIID_GmBackstage)
			i3k_sbean.world_msg_send_req("@#power")
		end
	elseif eventType == ccui.TouchEventType.canceled then
		
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_gmEntrance.new()
	wnd:create(layout, ...);
	return wnd
end