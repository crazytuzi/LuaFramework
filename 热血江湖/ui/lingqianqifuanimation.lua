------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_ling_qian_animation = i3k_class("wnd_ling_qian_animation",ui.wnd_base)

function wnd_ling_qian_animation:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseBtnClick)
	ui_set_hero_model(widgets.module, 1327)
	widgets.module:playAction("stand01")
	self._timer = 0
end

function wnd_ling_qian_animation:onCloseBtnClick(sender)
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			g_i3k_ui_mgr:OpenUI(eUIID_LingQianQiFuResult)
			g_i3k_ui_mgr:RefreshUI(eUIID_LingQianQiFuResult, ui.info)
			ui:onCloseUI()
		end, 1)
end

function wnd_ling_qian_animation:refresh(info)
	self.info = info
end

function wnd_ling_qian_animation:onUpdate(dTime)
	if self._timer > 3 then
		self:onCloseBtnClick()
	else
		self._timer = self._timer + dTime
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_ling_qian_animation.new()
	wnd:create(layout,...)
	return wnd
end