-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
wnd_star_Activate = i3k_class("wnd_star_Activate",ui.wnd_base)

function wnd_star_Activate:ctor()
end

function wnd_star_Activate:configure()
	local widgets = self._layout.vars
	self.des		= widgets.des
	self.checkBtn	= widgets.checkBtn
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_star_Activate:onActivateBtn(sender, starId)
	g_i3k_ui_mgr:CloseUI(eUIID_StarActivate)
	g_i3k_ui_mgr:OpenUI(eUIID_StarFlare)
	g_i3k_ui_mgr:RefreshUI(eUIID_StarFlare, starId)
end

function wnd_star_Activate:refresh(stars)
	local count = #stars;
	if count and count > 0 then
		self.des:setText(i3k_db_star_soul[stars[count]].name);
		self.checkBtn:onClick(self, self.onActivateBtn, stars[count]);
	end
end  

function wnd_create(layout)
	local wnd = wnd_star_Activate.new()
	wnd:create(layout)
	return wnd 
end
	