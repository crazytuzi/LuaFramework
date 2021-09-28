-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_longevityPavilionDelivery = i3k_class("wnd_longevityPavilionDelivery", ui.wnd_base)

function wnd_longevityPavilionDelivery:ctor()
	self._time = i3k_db_longevity_pavilion.deliveryTime
	self._countTime = 0
end

function wnd_longevityPavilionDelivery:configure()
	local widgets = self._layout.vars
	widgets.ok:onClick(self, self.onOK)
	widgets.cancel:onClick(self, self.onCancel)
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_longevityPavilionDelivery:onShow()
end

function wnd_longevityPavilionDelivery:onHide()
end


function wnd_longevityPavilionDelivery:onOK(sender)
	i3k_sbean.longevity_loft_boss()
	g_i3k_ui_mgr:CloseUI(eUIID_LongevityPavilionDelivery)
end

function wnd_longevityPavilionDelivery:onCancel(sender)
	self:onCloseUI()
end

function wnd_longevityPavilionDelivery:refresh()
	local widgets = self._layout.vars
	widgets.desc:setText(i3k_get_string(18561))
	widgets.time:setText(i3k_get_string(18586, self._time))
end

function wnd_longevityPavilionDelivery:onUpdate(dTime)
	self._countTime = self._countTime + dTime
	if self._countTime >= 1 and self._time > 0 then
		local widgets = self._layout.vars
		self._time = self._time - 1
		self._countTime = 0
		widgets.time:setText(i3k_get_string(18586, self._time))
		if self._time <= 0 then
			self:onOK()
		end
	end 
end

function wnd_create(layout)
	local wnd = wnd_longevityPavilionDelivery.new()
	wnd:create(layout)
	return wnd
end