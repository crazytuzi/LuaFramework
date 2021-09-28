-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_equip_temper_skill_up = i3k_class("wnd_equip_temper_skill_up",ui.wnd_base)

local NEEDITEMT1 = "ui/widgets/zbqht2"
local DESCT1 = 'ui/widgets/zbcljnsjt'

function wnd_equip_temper_skill_up:refresh(info)
	self.skillID = info.skillID
	self.partID = info.partID
	self.skillLvl = info.skillLvl
	self.index = info.index
	local cfg =  i3k_db_equip_temper_skill[self.skillID][self.skillLvl]
	local nextCfg = i3k_db_equip_temper_skill[self.skillID][self.skillLvl + 1]
	local widgets = self._layout.vars
	widgets.name:setText(cfg.name)
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local curDes = require(DESCT1)()
		curDes.vars.des:setText(cfg.des)
		self._layout.vars.curEffectScroll:addItem(curDes)
		local nextDes = require(DESCT1)()
		nextDes.vars.des:setText(nextCfg.des)
		self._layout.vars.upEffectScroll:addItem(nextDes)
		g_i3k_ui_mgr:AddTask(self, {curDes, nextDes}, function(ui)
			local contents = {self._layout.vars.curEffectScroll, self._layout.vars.upEffectScroll}
			for i, v in ipairs({curDes, nextDes}) do
				local textUI = v.vars.des
				local size = v.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = math.max(size.height, height)
				v.rootVar:changeSizeInScroll(contents[i], width, height ,true)
			end
		end, 1)
	end, 1)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
	widgets.up_btn:onClick(self, self.onUpBtnClick)
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.prerequisite:setText(string.format("前提 总星数(%s/%s)",g_i3k_game_context:GetEquipTemperTotalStars(self.partID),nextCfg.needStar))
	self.canUnlock = g_i3k_game_context:GetEquipTemperTotalStars(self.partID) >= nextCfg.needStar
	widgets.prerequisite:setTextColor(g_i3k_get_cond_color(self.canUnlock))
	self:setNeedItem(nextCfg.activeConsume)
end

function wnd_equip_temper_skill_up:setNeedItem(data)
	local widgets = self._layout.vars.consume_scroll
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

function wnd_equip_temper_skill_up:onUpBtnClick(sender)
	if self.canUnlock then
		local equip = g_i3k_game_context:GetWearEquips()[self.partID].equip
		local equip_id = equip.equip_id
		local guid = equip.equip_guid
		i3k_sbean.equip_hammer_skill_unlock(equip_id, guid, self.partID, self.index, self.skillID, self.skillLvl + 1)
	else
	    g_i3k_ui_mgr:PopupTipMessage("条件不足，不能起强化")
	end
end

function wnd_equip_temper_skill_up:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

---------------------------------------------------------
function wnd_create(layout)
	local wnd = wnd_equip_temper_skill_up.new()
	wnd:create(layout)
	return wnd
end
