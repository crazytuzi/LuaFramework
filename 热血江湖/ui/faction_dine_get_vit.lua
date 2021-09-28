-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_faction_dine_get_vit = i3k_class("wnd_faction_dine_get_vit",ui.wnd_base)


local SYDJJL_WIDGET = "ui/widgets/sydjjlt"
local RowitemCount = 3

function wnd_faction_dine_get_vit:ctor()
	
end

function wnd_faction_dine_get_vit:configure()
	local widgets = self._layout.vars
	
	self.count = widgets.count
	self.text = widgets.text
	self.item_bg = widgets.item_bg
	widgets.ok:onClick(self, self.closeButton)
end

function wnd_faction_dine_get_vit:refresh(count,strId)
	local delay = cc.DelayTime:create(0.15)--序列动作 动画播了0.15秒后显示奖励
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self._layout.anis.c_dakai.play()
	end), delay, cc.CallFunc:create(function ()
		self:updateScroll(count,strId)
	end))
	self:runAction(seq)
end

function wnd_faction_dine_get_vit:updateScroll(count,strId)
	self.count:setText(string.format("×%s",count))
	self.text:setText(i3k_get_string(strId))
	self.item_bg:onClick(self, self.onItemInfo, g_BASE_ITEM_VIT)
end

function wnd_faction_dine_get_vit:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_faction_dine_get_vit:closeButton(sender)
	
	g_i3k_ui_mgr:CloseUI(eUIID_FactionDineGetVit)
end

function wnd_create(layout)
	local wnd = wnd_faction_dine_get_vit.new()
	wnd:create(layout)
	return wnd
end
