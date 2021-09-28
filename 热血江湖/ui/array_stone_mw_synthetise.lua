------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/array_stone_mw_info')
------------------------------------------------------
wnd_array_stone_mw_synthetise = i3k_class("wnd_array_stone_mw_synthetise",ui.wnd_array_stone_mw_info)

local ITEM = "ui/widgets/zbqht2"

function wnd_array_stone_mw_synthetise:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onOk)
end

function wnd_array_stone_mw_synthetise:onOk(sender)
	if self.materialEngough then
		i3k_sbean.array_stone_ciphertext_uplvl(self.id, self.isEquip and 1 or 0)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18434))	   
	end
end

function wnd_array_stone_mw_synthetise:refresh(id, isEquip)
	self.id = id
	if isEquip ~= nil then
		self.isEquip = isEquip
	end
	local cfg = i3k_db_array_stone_cfg[id]
	local widgets = self._layout.vars
	local compoundId = cfg.compoundId
	local cfg2 = i3k_db_array_stone_cfg[compoundId]
	if not cfg2 then self:onCloseUI() return end
	local widget = {}
	for i = 1, 2 do
		widget[i] = {}
		widget[i].name = widgets["name"..i]
		widget[i].level = widgets["level"..i]
		widget[i].quality = widgets["quality"..i]
		widget[i].icon = widgets["icon"..i]
	end
	self:setMiWenInfo(widget[1], cfg)
	self:setMiWenInfo(widget[2], cfg2)
	self:setConsume()
end

function wnd_array_stone_mw_synthetise:setConsume()
	local widgets = self._layout.vars
	local cfg = i3k_db_array_stone_cfg[self.id]
	local items = {}
	items[#items + 1] = {id = g_BASE_ITEM_STONE_ENERGY, count = cfg.costEnergy}
	local itemId = cfg.compoundItemId
	if itemId ~= 0 then
		items[#items + 1] = {id = itemId, count = cfg.compoundItemCount}
	end
	self.materialEngough = self:setConsumes(widgets.scroll, items)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_array_stone_mw_synthetise.new()
	wnd:create(layout,...)
	return wnd
end