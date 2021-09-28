------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_star_light_shape = i3k_class("wnd_gm_star_light_shape", ui.wnd_base)

function wnd_gm_star_light_shape:ctor()
	self.positionBtn = {false, false, false, false, false, false, false, false}
	self.colorId = 0
end

function wnd_gm_star_light_shape:configure()
	local widget = self._layout.vars
	widget.shapeBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_star_light_shape:refresh(gmType)
	local widget = self._layout.vars
	for k = 1, 8 do
		widget["position"..k]:onClick(self, self.changePos, k)
	end
	for i = 1, 4 do
		widget["colorBtn"..i]:onClick(self, self.changeColor, i)
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_star_light_shape:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmStarLightShape)
end

function wnd_gm_star_light_shape:changePos(sender, id)
	if self.positionBtn[id] then
		self.positionBtn[id] = false
		self._layout.vars["position"..id]:stateToNormal(true)
	else
		self.positionBtn[id] = true
		self._layout.vars["position"..id]:stateToPressed(true)
	end
end

function wnd_gm_star_light_shape:changeColor(sender, id)
	self.colorId = id
	for i = 1, 4 do
		if i == id then
			self._layout.vars["colorBtn"..i]:stateToPressed(true)
		else
			self._layout.vars["colorBtn"..i]:stateToNormal(true)
		end
	end
end

function wnd_gm_star_light_shape:onSend(sender)
	g_i3k_ui_mgr:PopupTipMessage("暂未开放")
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_star_light_shape.new()
	wnd:create(layout, ...);
	return wnd
end
