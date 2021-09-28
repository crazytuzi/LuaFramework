------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_pet_guard_potential_active = i3k_class("wnd_pet_guard_potential_active",ui.wnd_base)

function wnd_pet_guard_potential_active:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	self.commonItemId = i3k_db_pet_guard_base_cfg.preUnlockNeedItemId
	local commonItemId = self.commonItemId
	widgets.bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(commonItemId))
	widgets.icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(commonItemId, g_i3k_game_context:IsFemaleRole()))
	widgets.name2:setText(g_i3k_db.i3k_db_get_common_item_name(commonItemId))
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(commonItemId))
	widgets.name2:setTextColor(name_colour)
	widgets.icon2:onClick(self, self.onItemTips, commonItemId)
	widgets.okBtn:onClick(self, self.onOKBtnClick)
end

function wnd_pet_guard_potential_active:refresh(petGuardId, potentialId, process)
	self.petGuardId = petGuardId or self.petGuardId
	self.potentialId = potentialId or self.potentialId
	self.process = process or self.process
	local process = self.process
	local petGuardId = self.petGuardId
	local potentialId = self.potentialId
	local cfg = i3k_db_pet_guard[petGuardId]
	local itemId = cfg.needItemId
	local widgets = self._layout.vars
	self.itemId = itemId
	widgets.bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	widgets.icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId, g_i3k_game_context:IsFemaleRole()))
	widgets.name1:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId))
	widgets.name1:setTextColor(name_colour)
	widgets.icon1:onClick(self, self.onItemTips, itemId)
	self.commonCount = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_pet_guard_base_cfg.preUnlockNeedItemId)
	widgets.count2:setText(self.commonCount)
	local needCount = i3k_db_pet_guard_potential[petGuardId][potentialId].needCount
	needCount = math.ceil(needCount * math.pow(1 - self.process, i3k_db_pet_guard_base_cfg.itemCountRatio))
	self.have = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
	widgets.count1:setText(self.have .."/".. needCount)
	widgets.count1:setTextColor(g_i3k_get_cond_color(self.have >= needCount))
	self.needCount = needCount
end

function wnd_pet_guard_potential_active:onOKBtnClick(sender)
	if self.have + self.commonCount >= self.needCount then
		i3k_sbean.pet_guard_unlock_latent(self.petGuardId, self.potentialId, math.min(self.have, self.needCount), math.max(self.needCount - self.have, 0))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
	end
end

function wnd_pet_guard_potential_active:ConsumeItems(itemCnt, commonCnt)
	local itemId = self.itemId
	local commonItemId = self.commonItemId
	local itemCount = self.have
	local commonCount = self.commonCount
	g_i3k_game_context:UseCommonItem(itemId, itemCnt)
	g_i3k_game_context:UseCommonItem(commonItemId, commonCnt)
end

function wnd_pet_guard_potential_active:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_pet_guard_potential_active.new()
	wnd:create(layout,...)
	return wnd
end