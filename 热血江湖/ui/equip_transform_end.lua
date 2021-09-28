-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_equip_transform_end = i3k_class("wnd_equip_transform_end", ui.wnd_base)

function wnd_equip_transform_end:ctor()
	
end

function wnd_equip_transform_end:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_equip_transform_end:refresh(id, guid, groupId)
	local newEquipId = i3k_db_equip_transform[groupId][math.abs(id)].newEquipId
	local newEquip = g_i3k_game_context:GetBagEquip(newEquipId, guid)
	self._layout.vars.des:setText(i3k_get_string(1252, g_i3k_db.i3k_db_get_equip_item_cfg(newEquipId).name))
	self._layout.vars.check:setText("查看")
	self._layout.vars.checkBtn:onClick(self, self.openEquipTips, newEquip)
end

function wnd_equip_transform_end:openEquipTips(sender, newEquip)
	g_i3k_ui_mgr:ShowCommonEquipInfo(newEquip, false, 0)
	g_i3k_ui_mgr:CloseUI(eUIID_EquipTransformEnd)
end

function wnd_create(layout, ...)
	local wnd = wnd_equip_transform_end.new()
	wnd:create(layout, ...);
	return wnd
end
