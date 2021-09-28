-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

require("i3k_usercfg");
-------------------------------------------------------
wnd_steed_skin_prompt = i3k_class("wnd_steed_skin_prompt", ui.wnd_base)

function wnd_steed_skin_prompt:ctor()

end

function wnd_steed_skin_prompt:configure()
	local widgets = self._layout.vars
	self._layout.vars.ok:onClick(self, self.onCloseUI)
	self.promptBtn = widgets.promptBtn
	self.promptBtn:onClick(self, self.onTouch)
	self.bzts_img = widgets.bzts_img
	self.Touch = true
end

function wnd_steed_skin_prompt:onTouch()
	self.bzts_img:setVisible(self.Touch)
	if self.Touch then
		i3k_usercfg:SetSteedSkinPrompt(0)
		self.Touch = false
	else
		i3k_usercfg:SetSteedSkinPrompt(1)
		self.Touch = true
	end
end

function wnd_create(layout)
	local wnd = wnd_steed_skin_prompt.new()
	wnd:create(layout)
	return wnd
end
