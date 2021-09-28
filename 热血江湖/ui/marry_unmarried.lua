-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--尚未婚嫁
-------------------------------------------------------

wnd_marry_unmarried = i3k_class("wnd_marry_unmarried",ui.wnd_base)

function wnd_marry_unmarried:ctor()
	
end

function wnd_marry_unmarried:configure()
	local widgets = self._layout.vars
	self.closeBtn = widgets.close
	self.closeBtn:onClick(self, self.closeButton)
	self.gotoMarryBtn = widgets.gotoMarryBtn --我要结婚
	self.gotoMarryBtn:onClick(self, self.onGotoMarryBtn)
	
	self.gotoProBtn = widgets.gotoProBtn  --查看说明
	self.gotoProBtn:onClick(self, self.onGotoProBtn)
	
end

function wnd_marry_unmarried:refresh()
	
	
end

--我要结婚 ->缔结姻缘
function wnd_marry_unmarried:onGotoMarryBtn(sender)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	g_i3k_ui_mgr:PopupTipMessage("寻路到月老")
	g_i3k_game_context:gotoYueLaoNpc()
end

--查看说明
function wnd_marry_unmarried:onGotoProBtn(sender)
	g_i3k_logic:OpenMerryProInstructions()
	self:closeButton()
end

function wnd_marry_unmarried:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Unmarried)
end

function wnd_create(layout)
	local wnd = wnd_marry_unmarried.new()
		wnd:create(layout)
	return wnd
end
