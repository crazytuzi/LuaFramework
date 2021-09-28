------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/array_stone_mw_info')
------------------------------------------------------
wnd_array_stone_mw_equip_confirm = i3k_class("wnd_array_stone_mw_equip_confirm", ui.wnd_array_stone_mw_info)

function wnd_array_stone_mw_equip_confirm:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.cancel:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onOK)
end

function wnd_array_stone_mw_equip_confirm:refresh(id, sameId)
	self.id = id
	self.sameId = sameId
	local targetCfg = i3k_db_array_stone_cfg[sameId]
	local tryEquipCfg = i3k_db_array_stone_cfg[id]
	local iconPath = tryEquipCfg.level > targetCfg.level and "<e=chu1#ss/>" or "<e=chu1#xj/>"
	self._layout.vars.desc:setText(i3k_get_string(18436, targetCfg.name, targetCfg.level, tryEquipCfg.name, tryEquipCfg.level, iconPath))
end

function wnd_array_stone_mw_equip_confirm:onOK(sender)
	i3k_sbean.array_stone_ciphertext_equip(self.id)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_array_stone_mw_equip_confirm.new()
	wnd:create(layout,...)
	return wnd
end