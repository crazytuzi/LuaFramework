-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_doubleInteraction = i3k_class("wnd_doubleInteraction", ui.wnd_base)

function wnd_doubleInteraction:ctor()
	
end

function wnd_doubleInteraction:configure()
	local widgets	= self._layout.vars;
	self.hugBtn 	= widgets.hugBtn
	self.kissBtn 	= widgets.kissBtn
	widgets.hugBtn:onClick(self, self.onHugClick)
	widgets.kissBtn:onClick(self, self.onKissBtn)
end

function wnd_doubleInteraction:refresh(id)
	
end

function wnd_doubleInteraction:Confirm(sender)
	
end

function wnd_doubleInteraction:onHugClick(sender)
	local isOnHug = g_i3k_game_context:IsOnHugMode()
	if isOnHug then
		self.hugBtn:stateToNormal()
	else
		self.hugBtn:stateToPressed()
	end
	if isOnHug then
		i3k_sbean.staywith_leave()
	else
		g_i3k_ui_mgr:PopupTipMessage("邀请其他人进行相依相偎")
	end
end

function wnd_doubleInteraction:onKissBtn(sender)
	local isOnHug = g_i3k_game_context:IsOnHugMode()
	if isOnHug then
		self.kissBtn:stateToNormal()
	else
		self.kissBtn:stateToPressed()
	end
	if isOnHug then
		i3k_sbean.staywith_memeda()
	end
end

function wnd_create(layout)
	local wnd = wnd_doubleInteraction.new();
		wnd:create(layout);
	return wnd;
end
