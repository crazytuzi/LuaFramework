-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_limit_consume_items = i3k_class("wnd_limit_consume_items",ui.wnd_add_sub)

local USE_COUNT_TEXT = 1
local NEED_ITEM_COUNT = 0


function wnd_limit_consume_items:ctor()
	self._itemid = 0
	self._item_count = 0
	self._need_itemid = 0
end

function wnd_limit_consume_items:configure()
	local widget = self._layout.vars
	
	self.item_icon = widget.item_icon
	self.item_name = widget.item_name
	self.item_count = widget.item_count
	self.use_count = widget.use_count
	self.close_btn = widget.close_btn
	self.need_count = widget.need_count
	self.item_bg = widget.item_bg
	self.suo = widget.suo
	self.times_desc = widget.times_desc
	self.desc_root = widget.desc_root
	self.item_btn = widget.item_btn
	
	widget.jian:onClick(self, self.jianButton)
	widget.jia:onClick(self, self.jiaButton)
	widget.max:onClick(self, self.maxButton)
	
	widget.cancel:onClick(self, self.cancelButton)
	widget.ok:onClick(self, self.okButton)
	
	self.add_btn = widget.jia
	self.sub_btn = widget.jian
	self.max_btn = widget.max
	self._count_label = self.use_count 
	self.use_count:addEventListener(function(eventType)
		if eventType == "ended" then
			local str = tonumber(self.use_count:getText()) or 1
			if str > self.current_add_num then
				str = self.current_add_num
			end
			if str > g_edit_box_max then
				str = g_edit_box_max
			end
			if str < 1 then
				str = 1
			end
			self.use_count:setText(str)
			self.current_num = str
		end
	end)
	
	--self.current_add_num = 100 	--当前能够增加到的最大值
	
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.onMax)
end

function wnd_limit_consume_items:setSaleMoneyCount(count)
	self.use_count:setText(count)
end

function wnd_limit_consume_items:updatefun()
	self._fun = function()
		if self.current_num > g_edit_box_max then
			self.current_num = g_edit_box_max
		end
		if self.current_num < 1 then
			self.current_num = 1
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_UseLimitConsumeItems,"setSaleMoneyCount",self.current_num)
	end
end 


function wnd_limit_consume_items:jianButton(sender)
	if USE_COUNT_TEXT > 1 then
		USE_COUNT_TEXT = USE_COUNT_TEXT - 1
		self:updateNeedCount()
	end
end

function wnd_limit_consume_items:updateMaxNum()
	local itemId = self._itemid
	local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
	local needItemId, needItemCount = g_i3k_db.i3k_db_get_day_use_consume_info(itemId)
	local needItemCanUseCount = g_i3k_game_context:GetCommonItemCanUseCount(needItemId)
	--local maxTimes = g_i3k_db.i3k_db_get_get_day_use_max_times(itemId)
	self.desc_root:setVisible(g_i3k_db.i3k_db_get_bag_item_limitable(self._itemid))
	if g_i3k_db.i3k_db_get_bag_item_limitable(itemId) then --限制使用次数类型道具类型
		local dayTimes = g_i3k_db.i3k_db_get_day_use_item_day_use_times(itemId)
		self.times_desc:setText(i3k_get_string(283, dayTimes))
		self._item_count = math.min(itemCount, dayTimes, math.floor(needItemCanUseCount/needItemCount))
	else --不限制使用次数消耗道具类型
		local num = math.min(math.floor(needItemCanUseCount/needItemCount), itemCount)
		self._item_count = num > 1 and num or 1
	end
	
	USE_COUNT_TEXT = 1
	NEED_ITEM_COUNT = needItemCount
	self._need_itemid = needItemId
	self:updateNeedCount()
	
	self.item_btn:onClick(self, self.onItemInfo, needItemId)
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needItemId))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needItemId,i3k_game_context:IsFemaleRole()))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(needItemId))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemId)))
	self.suo:setVisible(needItemId > 0)
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
	if item_cfg.type == UseItemVit then
		local needCount = g_i3k_game_context:GetAddVitNumber(self._itemid)
		self.current_add_num = needCount
	elseif item_cfg.type == UseItemExp then
		local itemExp = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid).args1
		local itemCount = self._item_count
		local needCount =  g_i3k_game_context:GetAddExpNumber(itemExp,itemCount)
		self.current_add_num = needCount
	else
		self.current_add_num = self._item_count
	end
end 

function wnd_limit_consume_items:jiaButton(sender)
	if USE_COUNT_TEXT < self._item_count then
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
		if item_cfg.type == UseItemVit then
			local needCount = g_i3k_game_context:GetAddVitNumber(self._itemid)
			if needCount >= self._item_count then
				USE_COUNT_TEXT = USE_COUNT_TEXT + 1
			else
				if USE_COUNT_TEXT >= needCount then
					g_i3k_ui_mgr:PopupTipMessage(string.format("只需要这么多就可以了！"))
					USE_COUNT_TEXT = needCount
				else
					USE_COUNT_TEXT = USE_COUNT_TEXT + 1
				end
			end
		elseif item_cfg.type == UseItemExp then
			local itemExp = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid).args1
			local itemCount = self._item_count
			local needCount =  g_i3k_game_context:GetAddExpNumber(itemExp,itemCount)
			if needCount >= itemCount then
				USE_COUNT_TEXT = USE_COUNT_TEXT + 1
			else
				if USE_COUNT_TEXT >= needCount then
					g_i3k_ui_mgr:PopupTipMessage(string.format("只需要这么多就可以满级了！"))
					USE_COUNT_TEXT = needCount
				else
					USE_COUNT_TEXT = USE_COUNT_TEXT + 1
				end
			end
		else
			USE_COUNT_TEXT = USE_COUNT_TEXT + 1
		end
		self:updateNeedCount()
	end
end

function wnd_limit_consume_items:maxButton(sender)
	if USE_COUNT_TEXT < self._item_count then
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
		if item_cfg.type == UseItemVit then
			local needCount = g_i3k_game_context:GetAddVitNumber(self._itemid)
			if needCount >= self._item_count then
				USE_COUNT_TEXT = self._item_count
			else
				USE_COUNT_TEXT = needCount
			end
		elseif item_cfg.type == UseItemExp then
			local itemExp = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid).args1
			local needCount =  g_i3k_game_context:GetAddExpNumber(itemExp, self._item_count)
			if needCount >= self._item_count then
				USE_COUNT_TEXT = self._item_count
			else
				USE_COUNT_TEXT = needCount
			end
		else
			USE_COUNT_TEXT = self._item_count
		end
		self:updateNeedCount()
	end
end

function wnd_limit_consume_items:cancelButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_UseLimitConsumeItems)
end

function wnd_limit_consume_items:okButton(sender)
	self:useAsItem()
end

function wnd_limit_consume_items:useItemGift()
	if g_i3k_db.i3k_db_get_open_gift_is_enough(self._itemid, self.current_num) then
		if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
			i3k_sbean.bag_useitemgift(self._itemid, self.current_num)
			return true
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
	return false
end

function wnd_limit_consume_items:useItemCoin()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useitemcoin(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

function wnd_limit_consume_items:useItemDiamond()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useitemdiamond(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

function wnd_limit_consume_items:useItemExp()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		return self:onUseExpItems()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

function wnd_limit_consume_items:useItemEquipEnergy()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useitemequipenergy(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

function wnd_limit_consume_items:useItemGemEnergy()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useitemgemenergy(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

function wnd_limit_consume_items:useItemBookSpiration()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useiteminspiration(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

function wnd_limit_consume_items:useItemVipHp()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useitemhppool(self._itemid,  self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

function wnd_limit_consume_items:useItemChest()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useitemchest(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

function wnd_limit_consume_items:useItemVit()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useitemvit(self._itemid,  self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

--道具类型24 增加武勋道具
function  wnd_limit_consume_items:useItemFeats()
	
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.goto_bag_useitemfeat(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

--道具类型38 增加vip经验值
function wnd_limit_consume_items:useItemVipExp()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useitemvipexp(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

--道具类型39 增加生产能量值
function wnd_limit_consume_items:useItemProduceSplitSp()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useitemaddproducesplitsp(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

-- 道具类型19 历练（满）
function wnd_limit_consume_items:useItemEmpowerment()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.goto_bag_useitemexpcoinpool(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

-- 道具类型40 buff药
function wnd_limit_consume_items:useItemBuffDrug()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
		if cfg.args1 then
			if g_i3k_game_context:GetUseBuffDrugTypeCount() >= i3k_db_common.buff_drug_use_max and not g_i3k_game_context:IsBuffDrugTypeExist(cfg.args1) then  --超过buff药使用种类上限,并且没有同类型的buff
				local desc = i3k_get_string(16146, i3k_db_common.buff_drug_use_max)
				local fun = (function(ok)
					if ok then
						g_i3k_ui_mgr:OpenUI(eUIID_BuffDrugRemove)
						g_i3k_ui_mgr:RefreshUI(eUIID_BuffDrugRemove)
					end
				end)
				g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
			else
				if g_i3k_game_context:GetBuffDrugLimit(cfg.args1) >= self.current_num then  --超过buff药叠加层数
					local current_num = self.current_num
					
					local slotLvl = g_i3k_game_context:GetUseBuffDrugSlotLvl(cfg.args1)
					local desc = ""
					if slotLvl == g_USE_HIGH_SLOTLVL then
						desc = i3k_get_string(16142)
					elseif slotLvl == g_USE_LOW_SLOTLVL then
						desc = i3k_get_string(16141)
					elseif slotLvl == g_USE_SAME_SLOTLVL then
						desc = i3k_get_string(16144, self.current_num, cfg.name)
					end

					local fun = (function(ok)
						i3k_sbean.bag_useitembuffdrug(cfg.id, current_num)
					end)
					g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
				else
					local overLays = i3k_db_buff[cfg.args1].overlays
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16140, overLays))
				end
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

-- 道具类型42 武运道具
function wnd_limit_consume_items:useWeaponSoul()
	if g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num then
		i3k_sbean.bag_useweaponsoulcoinadder(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(290))
	end
	return g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num
end

function wnd_limit_consume_items:refresh(itemId)
	self._itemid = itemId
	self:updateMaxNum()
	self:updatefun()
end

function wnd_limit_consume_items:updateNeedCount()
	if self.current_num > g_edit_box_max then
		self.current_num = g_edit_box_max
	end
	if self.current_num < 1 then
		self.current_num = 1
	end
	local numDesc = string.format("%s/%s", g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid), NEED_ITEM_COUNT * self.current_num)
	if self._need_itemid < 65536 or self._need_itemid > -65536 then
		numDesc = string.format("%s", NEED_ITEM_COUNT * self.current_num)
	end
	self.need_count:setText(numDesc)
	self.need_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(self._need_itemid) >= NEED_ITEM_COUNT * self.current_num))
	self.use_count:setText(self.current_num)
end

local useItemTypeTbl = 
{
	[UseItemCoin]			= wnd_limit_consume_items.useItemCoin,
	[UseItemDiamond]		= wnd_limit_consume_items.useItemDiamond,
	[UseItemExp]			= wnd_limit_consume_items.useItemExp,
	[UseItemGift]			= wnd_limit_consume_items.useItemGift,
	[UseItemHp]				= wnd_limit_consume_items.useItemHp,
	[UseItemVipHp]			= wnd_limit_consume_items.useItemVipHp,
	[UseItemChest]			= wnd_limit_consume_items.useItemChest,
	[UseItemEquipEnergy]	= wnd_limit_consume_items.useItemEquipEnergy,
	[UseItemGemEnergy]		= wnd_limit_consume_items.useItemGemEnergy,
	[UseItemBookSpiration]	= wnd_limit_consume_items.useItemBookSpiration,
	[UseItemVit]			= wnd_limit_consume_items.useItemVit,
	[UseItemFeats]			= wnd_limit_consume_items.useItemFeats,
	[UseItemVipExp]			= wnd_limit_consume_items.useItemVipExp,
	[UseItemProduceSplitSp]	= wnd_limit_consume_items.useItemProduceSplitSp,
	[UseItemEmpowerment]	= wnd_limit_consume_items.useItemEmpowerment,
	[UseItemBuffDrug]		= wnd_limit_consume_items.useItemBuffDrug,
	[UseItemWeaponSoul]		= wnd_limit_consume_items.useWeaponSoul,
}

function wnd_limit_consume_items:useAsItem()
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
	local func = useItemTypeTbl[item_cfg.type]
	if func and func(self) then
		g_i3k_ui_mgr:CloseUI(eUIID_UseLimitConsumeItems)
	end
end

function wnd_limit_consume_items:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_create(layout)
	local wnd = wnd_limit_consume_items.new()
	wnd:create(layout)
	return wnd
end
