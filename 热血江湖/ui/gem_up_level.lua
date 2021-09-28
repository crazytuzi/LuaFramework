-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_gem_up_level = i3k_class("wnd_gem_up_level",ui.wnd_base)

local BSSJT_WIDGET = "ui/widgets/bssjt"

function wnd_gem_up_level:ctor()
	self.nextId = 0
	self.pos = 0
	self.slotPos = 0
	self.gemId = 0
end

function wnd_gem_up_level:configure()
	local widgets = self._layout.vars
	
	widgets.update:onClick(self, self.upLevelBtn)
	widgets.autoUpdate:onClick(self, self.autoUpLevelBtn)
	widgets.close:onClick(self, self.closeButton)
	
	self.nowRank = widgets.nowRank
	self.nowIcon = widgets.nowIcon
	self.nowName = widgets.nowName
	self.nowProp = widgets.nowProp
	
	self.nextRank = widgets.nextRank
	self.nextIcon = widgets.nextIcon
	self.nextName = widgets.nextName
	self.nextProp = widgets.nextProp
	self.scroll = widgets.scroll
	
	self.c_bssj = self._layout.anis.c_bssj
end

function wnd_gem_up_level:refresh(data)
	self.pos = data.pos
	self.slotPos = data.seq
	self.gemId = data.gemId
	self.nextId = g_i3k_db.i3k_db_get_gem_item_cfg(data.gemId).updated_id
	self:updateCompareInfo(data)
	self:updateNeedItem(self.nextId)
end

function wnd_gem_up_level:updateCompareInfo(data)
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(data.gemId))
	self.nowIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(data.gemId,i3k_game_context:IsFemaleRole()))
	self.nowRank:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(data.gemId))
	self.nowName:setText(g_i3k_db.i3k_db_get_common_item_name(data.gemId))
	self.nowName:setTextColor(name_colour)
	self.nowProp:setText(self:getGemPropertyDesc(data.gemId))
	
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.nextId))
	self.nextIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.nextId,i3k_game_context:IsFemaleRole()))
	self.nextRank:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.nextId))
	self.nextName:setText(g_i3k_db.i3k_db_get_common_item_name(self.nextId))
	self.nextName:setTextColor(name_colour)
	self.nextProp:setText(self:getGemPropertyDesc(self.nextId))
end

function wnd_gem_up_level:getGemPropertyDesc(id)
	local gemCfg = g_i3k_db.i3k_db_get_gem_item_cfg(id)
	local effectDesc = i3k_db_prop_id[gemCfg.effect_id].desc
	return string.format("%s +%s",effectDesc, gemCfg.effect_value)
end

function wnd_gem_up_level:updateNeedItem()
	self.scroll:removeAllChildren()
	local needItem = g_i3k_db.i3k_db_get_gem_need_info(self.nextId)
	for i, e in pairs(needItem) do
		local _layer = require(BSSJT_WIDGET)()
		local widget = _layer.vars
		self:updateCell(widget, e.id, e.count)
		self.scroll:addItem(_layer)
	end
end

function wnd_gem_up_level:updateCell(widget, id, count)
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id))
	widget.item_rank:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widget.item_name:setTextColor(name_colour)
	local itemCount = id==g_BASE_ITEM_GEM_ENERGY and g_i3k_game_context:GetStoneEnergy() or g_i3k_game_context:GetCommonItemCanUseCount(id)
	widget.item_count:setTextColor(g_i3k_get_cond_color(itemCount>=count))
	local str = string.format("%s/%s",itemCount, count)
	if id == g_BASE_ITEM_COIN then
		str = string.format("%s", count)
	end
	widget.item_count:setText(str)
	widget.item_btn:onClick(self, self.onItemTips, id)
end

function wnd_gem_up_level:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_gem_up_level:upLevelBtn(sender)
	local isEnough = self:isCanUpLevel()
	if self:isCanUpLevel() then
		i3k_sbean.gem_levelup(self.pos, self.slotPos, self.nextId, g_i3k_db.i3k_db_get_gem_need_info(self.nextId))
	end
end

function wnd_gem_up_level:isCanUpLevel()
	local needItem = g_i3k_db.i3k_db_get_gem_need_info(self.nextId)
	local is_ok = {is_ok1 = true, is_ok2 = true, is_ok3 = true}
	local isEnough = true
	for i, e in pairs(needItem) do
		local isOk = string.format("is_ok%s",i)
		local itemCount = e.id==g_BASE_ITEM_GEM_ENERGY and g_i3k_game_context:GetStoneEnergy() or g_i3k_game_context:GetCommonItemCanUseCount(e.id)
		if itemCount < e.count then
			g_i3k_ui_mgr:PopupTipMessage(string.format("材料不足，无法升级宝石"))
			isEnough = false
			break
		end
	end
	return isEnough
end

function wnd_gem_up_level:autoUpLevelBtn(sender)
	local cfg = g_i3k_db.i3k_db_get_gem_item_cfg(self.gemId)
	local allGem = g_i3k_db.i3k_db_get_gem_from_type(cfg.type)
	local canUpLvl = self:isCanAutoUpLevel(self.gemId)
	if canUpLvl then
		local neeItem = self:autoUpLevelNeedItem(canUpLvl)
		i3k_sbean.gem_levelup(self.pos, self.slotPos, allGem[canUpLvl].id, neeItem)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("材料不足，无法升级宝石"))
	end
end

function wnd_gem_up_level:isCanAutoUpLevel()
	local cfg = g_i3k_db.i3k_db_get_gem_item_cfg(self.gemId)
	local allGem = g_i3k_db.i3k_db_get_gem_from_type(cfg.type)
	local nowLvl = cfg.level
	
	local can_up_lv = 0
	local need_item = {}
	for i=nowLvl+1, #allGem do
		local _data = allGem[i]
		if need_item[g_BASE_ITEM_GEM_ENERGY] then
			need_item[g_BASE_ITEM_GEM_ENERGY] = need_item[g_BASE_ITEM_GEM_ENERGY] + _data.upgrade_consume_energy
		else
			need_item[g_BASE_ITEM_GEM_ENERGY] = _data.upgrade_consume_energy
		end
		for j=1, 2 do
			local tmpId = string.format("update_consume%s_id", j)
			local tmpCount = string.format("update_consume%s_count", j)
			local itemId = _data[tmpId]
			local itemCount = _data[tmpCount]
			if need_item[itemId] then
				need_item[itemId] = need_item[itemId] + itemCount
			else
				need_item[itemId] = itemCount
			end
		end
		local is_enough = true
		for k,v in pairs(need_item) do
			if g_i3k_game_context:GetCommonItemCanUseCount(k) < v then
				is_enough = false
				break
			end
		end
		if not is_enough then
			can_up_lv = i - 1
			break
		end
		can_up_lv = i
	end
	if can_up_lv <= nowLvl then
		return false
	elseif can_up_lv > nowLvl then
		return can_up_lv
	end
end

function wnd_gem_up_level:autoUpLevelNeedItem(canUpLvl)
	local cfg = g_i3k_db.i3k_db_get_gem_item_cfg(self.gemId)
	local allGem = g_i3k_db.i3k_db_get_gem_from_type(cfg.type)
	local nowLvl = cfg.level
	local need_item = {}
	local items = {}
	for i=nowLvl+1, canUpLvl do
		local _data = allGem[i]
		if need_item[g_BASE_ITEM_GEM_ENERGY] then
			need_item[g_BASE_ITEM_GEM_ENERGY] = need_item[g_BASE_ITEM_GEM_ENERGY] + _data.upgrade_consume_energy
		else
			need_item[g_BASE_ITEM_GEM_ENERGY] = _data.upgrade_consume_energy
		end
		for j=1, 2 do
			local tmpId = string.format("update_consume%s_id", j)
			local tmpCount = string.format("update_consume%s_count", j)
			local itemId = _data[tmpId]
			local itemCount = _data[tmpCount]
			if itemId ~= 0 then
				if need_item[itemId] then
					need_item[itemId] = need_item[itemId] + itemCount
				else
					need_item[itemId] = itemCount
				end
			end
		end
	end
	for k, v in pairs(need_item) do
		table.insert(items, {id = k, count = v})
	end
	return items
end

function wnd_gem_up_level:playUpLevelEffect(data)
	local delay = cc.DelayTime:create(0.5)--序列动作 动画播了0.5秒后刷新界面
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self.c_bssj.play()
	end), delay, cc.CallFunc:create(function ()
		self:refresh(data)
	end))
	self:runAction(seq)
end

function wnd_gem_up_level:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GemUpLevel)
end

function wnd_create(layout)
	local wnd = wnd_gem_up_level.new()
	wnd:create(layout)
	return wnd
end
