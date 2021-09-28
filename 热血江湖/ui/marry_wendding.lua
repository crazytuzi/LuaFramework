-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--是否开启游街和 --
-------------------------------------------------------

wnd_marry_wendding = i3k_class("wnd_marry_wendding",ui.wnd_base)

function wnd_marry_wendding:ctor()
	
end

function wnd_marry_wendding:configure()
	local widgets = self._layout.vars
	self.closeBtn = widgets.close
	self.closeBtn:onClick(self, self.closeButton)
	self.openWenddingBtn = widgets.openWenddingBtn
	self.openWenddingBtn:onClick(self, self.onOpenWendding)
end

function wnd_marry_wendding:cheakData()
	--检查按钮的显示与否
	local state = g_i3k_game_context:getEnterProNum() --1 代表月老处 可点 --2 代表姻缘处
	if state ==1 then
		--显示上一层
		
		self.openWenddingBtn:hide()
		
	elseif state ==2 then
		local step = g_i3k_game_context:getRecordSteps() --1 ，结婚状态时间
		if step== -1 then		
			self.openWenddingBtn:hide()
		end
	else
	end
end

function wnd_marry_wendding:refresh()
	self:cheakData()
	
	
end

--开启游街
function wnd_marry_wendding:onOpenWendding(sender)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	--寻路到月老处
	g_i3k_ui_mgr:PopupTipMessage("寻路到月老处")
	g_i3k_game_context:gotoYueLaoNpc()
	--self:closeButton()
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Progress_Inst)
end

function wnd_marry_wendding:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Wendding)
end

function wnd_create(layout)
	local wnd = wnd_marry_wendding.new()
		wnd:create(layout)
	return wnd
end
