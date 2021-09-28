-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

require("i3k_ui_mgr");
require("i3k_usercfg");
-------------------------------------------------------
wnd_shen_bing_ti_shi = i3k_class("wnd_shen_bing_ti_shi", ui.wnd_base)

function wnd_shen_bing_ti_shi:ctor( )

end

function wnd_shen_bing_ti_shi:configure( )
	local widgets = self._layout.vars
	self._layout.vars.ok:onClick(self, self.onCloseUI)
	self.bzts_btn = widgets.bzts_btn
	self.bzts_btn:onClick(self,self.onTouch)
	self.bzts_img = widgets.bzts_img
	self.Touch = true


end

function wnd_shen_bing_ti_shi:onCloseUI(  )
	g_i3k_ui_mgr:CloseUI(eUIID_TiShi)
end

function wnd_shen_bing_ti_shi:onTouch( )
	if self.Touch then
		self.bzts_img:show()
		i3k_usercfg:SetIsPrompt(0)
		self.Touch = false
	else
		self.bzts_img:hide()
		i3k_usercfg:SetIsPrompt(1)
		self.Touch = true
	end
end

function wnd_create(layout)
	local wnd = wnd_shen_bing_ti_shi.new()
	wnd:create(layout)
	return wnd
end
