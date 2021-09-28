------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/array_stone_mw_info')
------------------------------------------------------
wnd_array_stone_mw_displace = i3k_class("wnd_array_stone_mw_displace", ui.wnd_array_stone_mw_info)

local ITEM = "ui/widgets/zbqht2"
local DISPLACE_ITEM = "ui/widgets/zfsmwzht"

function wnd_array_stone_mw_displace:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onOK)
	widgets.scroll:setBounceEnabled(false)
end

function wnd_array_stone_mw_displace:refresh(id)
	self.id = id
	self.cfg = i3k_db_array_stone_cfg[id]
	local cfg = self.cfg
	local widgets = self._layout.vars
	self:setMiWenInfo()
	self:setConsume()
	self:setDisplaceItems()
end

function wnd_array_stone_mw_displace:setConsume()--包上一层刷新道具使用
	self.isMaterialEnough = self:setConsumes(self._layout.vars.scroll2, self.cfg.transformCost)
end

function wnd_array_stone_mw_displace:setDisplaceItems()
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	self.flags = {}
	self.curSel = 0
	for i,v in ipairs(self.cfg.transformStone) do
		local item = require(DISPLACE_ITEM)()
		self:setMiWenInfo(item.vars, i3k_db_array_stone_cfg[v])
		item.vars.flag:hide()
		self.flags[v] = item.vars.flag
		item.vars.btn:onClick(self, self.onSelect, v)
		widgets.scroll:addItem(item)
	end
end

function wnd_array_stone_mw_displace:onSelect(sender, id)
	for i,v in pairs(self.flags) do
		v:setVisible(id == i)
	end
	self.curSel = id
end

function wnd_array_stone_mw_displace:onOK(sender)
	if self.curSel ~= 0 then
		if self.isMaterialEnough then
			i3k_sbean.array_stone_ciphertext_change(self.id, self.curSel)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18426))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18435))
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_array_stone_mw_displace.new()
	wnd:create(layout,...)
	return wnd
end
