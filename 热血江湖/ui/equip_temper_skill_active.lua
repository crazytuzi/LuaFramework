-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_equip_temper_skill_active = i3k_class("wnd_equip_temper_skill_active",ui.wnd_base)

local NEEDITEMT1 = "ui/widgets/zbqht2"

function wnd_equip_temper_skill_active:refresh(info)
	self.skillID = info.skillID
	self.partID = info.partID
	self.skillLvl = info.skillLvl
	self.index = info.index
	local cfg =  i3k_db_equip_temper_skill[self.skillID][self.skillLvl]
	local widgets = self._layout.vars
	widgets.name:setText(cfg.name)
	widgets.des:setText(cfg.des)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
	widgets.okBtn:onClick(self, self.onOKBtnClick)
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.prerequisite:setText(string.format("前提 总星数(%s/%s)",g_i3k_game_context:GetEquipTemperTotalStars(self.partID),cfg.needStar))
	self.canUnlock = g_i3k_game_context:GetEquipTemperTotalStars(self.partID) >= cfg.needStar
	widgets.prerequisite:setTextColor(g_i3k_get_cond_color(self.canUnlock))
	self:setNeedItem(cfg.activeConsume)
end

function wnd_equip_temper_skill_active:setNeedItem(data)
	local widgets = self._layout.vars.needItem
	widgets:removeAllChildren()
	for i, e in ipairs(data) do
		local T1 = require(NEEDITEMT1)()
		local widget = T1.vars
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemId))
		widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemId))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemId,i3k_game_context:IsFemaleRole()))
		widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.itemId))
		widget.item_name:setTextColor(name_colour)
		widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemId))
		if e.itemId == g_BASE_ITEM_DIAMOND or e.itemId == g_BASE_ITEM_COIN then
			widget.item_count:setText(e.itemCount or e.count)
		else
			widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) .."/".. (e.itemCount or e.count))
			if self.canUnlock then
				self.canUnlock = g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) >= (e.itemCount or e.count)
			end
		end
		widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) >= (e.itemCount or e.count)))
		widget.bt:onClick(self, self.onItemTips, e.itemId)
		widgets:addItem(T1)
	end
end

function wnd_equip_temper_skill_active:onOKBtnClick(sender)
	if self.canUnlock then
		local equip = g_i3k_game_context:GetWearEquips()[self.partID].equip
		local equip_id = equip.equip_id
		local guid = equip.equip_guid
		i3k_sbean.equip_hammer_skill_unlock(equip_id, guid, self.partID, self.index, self.skillID, self.skillLvl)
	else
	    g_i3k_ui_mgr:PopupTipMessage("条件不足，不能解锁")
	end
end

function wnd_equip_temper_skill_active:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

---------------------------------------------------------
function wnd_create(layout)
	local wnd = wnd_equip_temper_skill_active.new()
	wnd:create(layout)
	return wnd
end
