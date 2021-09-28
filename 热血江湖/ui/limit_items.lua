-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_limit_items = i3k_class("wnd_limit_items",ui.wnd_add_sub)

local USE_COUNT_TEXT = 1

function wnd_limit_items:ctor()
	self._itemid = 0
	self._item_count = 0
end

function wnd_limit_items:configure()
	local widget = self._layout.vars

	self.times_desc = widget.times_desc
	self.use_count = widget.use_count

	widget.jian:onClick(self, self.jianButton)
	widget.jia:onClick(self, self.jiaButton)
	widget.max:onClick(self, self.maxButton)

	widget.cancel:onClick(self, self.cancelButton)
	widget.ok:onClick(self, self.okButton)

	self.add_btn = widget.jia
	self.sub_btn = widget.jian
	self.max_btn = widget.max
	self._count_label = self.use_count

	--self.current_add_num = 100 	--当前能够增加到的最大值

	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.onMax)
end

function wnd_limit_items:setSaleMoneyCount(count)
	self.use_count:setText(count)
end

function wnd_limit_items:updatefun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_UseLimitItems,"setSaleMoneyCount",self.current_num)
	end
end

function wnd_limit_items:updateMaxNum()
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
	if item_cfg.type == UseItemVit then
		local needCount = g_i3k_game_context:GetAddVitNumber(self._itemid)
		self.current_add_num = needCount
	elseif item_cfg.type == UseItemExp then
		local itemExp = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid).args1
		local itemCount = self._item_count
		local needCount =  g_i3k_game_context:GetAddExpNumber(itemExp,itemCount)
		self.current_add_num = needCount
	elseif item_cfg.type == UseItemBuffDrug and item_cfg.args2 == g_NORMAL_BUFF_DRUG then
		local needCount = g_i3k_game_context:GetBuffDrugLimit(item_cfg.args1)
		needCount = self._item_count < needCount and self._item_count or needCount
		self.current_add_num = needCount
	else
		self.current_add_num = self._item_count
	end
end


function wnd_limit_items:jianButton(sender)
	if USE_COUNT_TEXT > 1 then
		USE_COUNT_TEXT = USE_COUNT_TEXT - 1
		self.use_count:setText(USE_COUNT_TEXT)
	end
end

function wnd_limit_items:jiaButton(sender)
	if USE_COUNT_TEXT < self._item_count then
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
		if item_cfg.type == UseItemVit then
			local needCount = g_i3k_game_context:GetAddVitNumber(self._itemid)
			local test = self._item_count
			if needCount >= self._item_count then
				USE_COUNT_TEXT = USE_COUNT_TEXT + 1
			else
				if USE_COUNT_TEXT >= needCount then
					g_i3k_ui_mgr:PopupTipMessage("只需要这么多就可以了！")
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
		elseif item_cfg.type == UseItemBuffDrug and item_cfg.args2 == g_NORMAL_BUFF_DRUG then
			local needCount = g_i3k_game_context:GetBuffDrugLimit(item_cfg.args1)
			if needCount >= self._item_count then
				USE_COUNT_TEXT = USE_COUNT_TEXT + 1
			else
				if USE_COUNT_TEXT >= needCount then
					g_i3k_ui_mgr:PopupTipMessage("只需要这么多就可以了！")
					USE_COUNT_TEXT = needCount
				else
					USE_COUNT_TEXT = USE_COUNT_TEXT + 1
				end
			end
		else
			USE_COUNT_TEXT = USE_COUNT_TEXT + 1
		end
		self.use_count:setText(USE_COUNT_TEXT)
	end
end

function wnd_limit_items:maxButton(sender)
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
	elseif item_cfg.type == UseItemBuffDrug and item_cfg.args2 == g_NORMAL_BUFF_DRUG then
		local needCount = g_i3k_game_context:GetBuffDrugLimit(item_cfg.args1)
		if needCount >= self._item_count then
			USE_COUNT_TEXT = self._item_count
		else
			USE_COUNT_TEXT = needCount
		end
	else
		USE_COUNT_TEXT = self._item_count
	end
	self.use_count:setText(USE_COUNT_TEXT)
end

function wnd_limit_items:cancelButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_UseLimitItems)
end

function wnd_limit_items:okButton(sender)
	self:useAsItem()
end

function wnd_limit_items:useItemGift()
	local isCanBuy, needVipLvl = g_i3k_db.i3k_db_get_bag_item_is_need_viplvl(self._itemid)
	if not isCanBuy then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17393, needVipLvl))
		return true
	end
	if g_i3k_db.i3k_db_get_gift_bag_is_open_select(self._itemid) then
		g_i3k_ui_mgr:OpenUI(eUIID_GiftBagSelect)
		g_i3k_ui_mgr:RefreshUI(eUIID_GiftBagSelect, self._itemid, self.current_num)
		g_i3k_ui_mgr:CloseUI(eUIID_UseLimitItems)
	else
		if g_i3k_db.i3k_db_get_open_gift_is_enough(self._itemid, self.current_num) then
			local needItemId, needItemCount = g_i3k_db.i3k_db_get_day_use_consume_info(self._itemid)
			if needItemId ~= 0 and needItemCount ~= 0 then
				g_i3k_ui_mgr:OpenUI(eUIID_UseLimitConsumeItems)
				g_i3k_ui_mgr:RefreshUI(eUIID_UseLimitConsumeItems, self._itemid, self._item_type)
				g_i3k_ui_mgr:CloseUI(eUIID_UseLimitItems)
			else
				i3k_sbean.bag_useitemgift(self._itemid, self.current_num)
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
		end
	end
	return true
end

function wnd_limit_items:useItemCoin()
	i3k_sbean.bag_useitemcoin(self._itemid, self.current_num)
	return true
end

function wnd_limit_items:useItemDiamond()
	i3k_sbean.bag_useitemdiamond(self._itemid, self.current_num)
	return true
end

function wnd_limit_items:useItemExp()
	return self:onUseExpItems()
end

function wnd_limit_items:useItemEquipEnergy()
	i3k_sbean.bag_useitemequipenergy(self._itemid, self.current_num)
	return true
end

function wnd_limit_items:useItemGemEnergy()
	i3k_sbean.bag_useitemgemenergy(self._itemid, self.current_num)
	return true
end

function wnd_limit_items:useItemBookSpiration()
	i3k_sbean.bag_useiteminspiration(self._itemid, self.current_num)
	return true
end

function wnd_limit_items:useItemVipHp()
	i3k_sbean.bag_useitemhppool(self._itemid,  self.current_num)
	return true
end

function wnd_limit_items:useItemChest()
	i3k_sbean.bag_useitemchest(self._itemid, self.current_num)
	return true
end

function wnd_limit_items:useItemVit()
	i3k_sbean.bag_useitemvit(self._itemid, self.current_num)
	return true
end

function wnd_limit_items:useItemFeats()
	i3k_sbean.goto_bag_useitemfeat(self._itemid, self.current_num)
	return true
end

function wnd_limit_items:useItemVipExp()
	i3k_sbean.bag_useitemvipexp(self._itemid, self.current_num)
	return true
end

function wnd_limit_items:useItemProduceSplitSp()
	i3k_sbean.bag_useitemaddproducesplitsp(self._itemid, self.current_num)
	return true
end

-- 历练
function wnd_limit_items:useItemEmpowerment()
	i3k_sbean.goto_bag_useitemexpcoinpool(self._itemid, self.current_num)
	return true
end

-- buff药
function wnd_limit_items:useItemBuffDrug()
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
	if cfg.args1 then
		if cfg.args2 == g_NORMAL_BUFF_DRUG then
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
						if ok then
							i3k_sbean.bag_useitembuffdrug(cfg.id, current_num)
						end
					end)
					g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
				else
					local overLays = i3k_db_buff[cfg.args1].overlays
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16140, overLays))
				end
			end
		elseif cfg.args2 == g_FIGHT_LINE_BUFF_DRUG then
			local current_num = self.current_num
			if g_i3k_game_context:GetBuffAffectValue(cfg.args1) >= i3k_db_common.fight_line_exp_max and not g_i3k_game_context:IsFightLineBuffTypeExist(cfg.args1) then
				local desc = i3k_get_string(16149, i3k_db_common.fight_line_exp_max * 0.01)
				local fun = (function(ok)
					if ok then
						i3k_sbean.bag_useitembuffdrug(cfg.id, current_num)
					end
				end)
				g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
			else
				i3k_sbean.bag_useitembuffdrug(cfg.id, current_num)
			end
		end
	end
	return true
end

-- 道具类型42 武运道具
function wnd_limit_items:useWeaponSoul()
	i3k_sbean.bag_useweaponsoulcoinadder(self._itemid, self.current_num)
	return true
end

-- 道具类型53 神装礼包
function wnd_limit_items:useGodEquip()
	local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
	if i3k_db_career_gift_bag[itemCfg.args1].giftType == 0 then
		i3k_sbean.bag_useitemgiftnew(self._itemid, self.current_num)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_GiftBagSelect)
		g_i3k_ui_mgr:RefreshUI(eUIID_GiftBagSelect, self._itemid, self.current_num)
	end
	return true
end
-- 道具类型64 定期活动道具
function wnd_limit_items:useItemUseItemRegular()
	i3k_sbean.bag_use_regular_item_activity(self._itemid, self.current_num)
	return true
end

-- 道具类型34 离线精灵修炼点
function wnd_limit_items:useItemSpirit()
	i3k_sbean.bag_useitemofflinefuncpoint(self._itemid, self.current_num)
	return true
end

-- 道具类型66 增加结拜金兰值道具
function wnd_limit_items:useItemSwornValue()
	local isSworn = g_i3k_game_context:getSwornFriends()
	if isSworn then
		i3k_sbean.use_sworn_gift_item(self._itemid, self.current_num)
		return true
	end
end
--道具类型80  势力声望
function wnd_limit_items:UseItemNewPower()
	i3k_sbean.bag_useItemForceFame(self._itemid, self.current_num)
	return true
end
local useItemTypeTbl =
{
	[UseItemCoin]			= wnd_limit_items.useItemCoin,
	[UseItemDiamond]		= wnd_limit_items.useItemDiamond,
	[UseItemExp]			= wnd_limit_items.useItemExp,
	[UseItemGift]			= wnd_limit_items.useItemGift,
	[UseItemHp]				= wnd_limit_items.useItemHp,
	[UseItemVipHp]			= wnd_limit_items.useItemVipHp,
	[UseItemChest]			= wnd_limit_items.useItemChest,
	[UseItemEquipEnergy]	= wnd_limit_items.useItemEquipEnergy,
	[UseItemGemEnergy]		= wnd_limit_items.useItemGemEnergy,
	[UseItemBookSpiration]	= wnd_limit_items.useItemBookSpiration,
	[UseItemVit]			= wnd_limit_items.useItemVit,
	[UseItemFeats]			= wnd_limit_items.useItemFeats,
	[UseItemVipExp]			= wnd_limit_items.useItemVipExp,
	[UseItemProduceSplitSp]	= wnd_limit_items.useItemProduceSplitSp,
	[UseItemEmpowerment]	= wnd_limit_items.useItemEmpowerment,
	[UseItemBuffDrug]		= wnd_limit_items.useItemBuffDrug,
	[UseItemWeaponSoul]		= wnd_limit_items.useWeaponSoul,
	[UseItemGodEquip]		= wnd_limit_items.useGodEquip,
	[UseItemRegular]        = wnd_limit_items.useItemUseItemRegular,
	[UseItemSpirit]			= wnd_limit_items.useItemSpirit,
	[UseItemSwornValue]		= wnd_limit_items.useItemSwornValue,
	[UseItemNewPower]		= wnd_limit_items.UseItemNewPower,
}

function wnd_limit_items:useAsItem()
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
	local func = useItemTypeTbl[item_cfg.type]
	if func and func(self) then
		g_i3k_ui_mgr:CloseUI(eUIID_UseLimitItems)
	end
end

function wnd_limit_items:refresh(itemId)
	self._itemid = itemId
	local dayTimes = g_i3k_db.i3k_db_get_day_use_item_day_use_times(itemId)
	local itemCount = g_i3k_game_context:GetCommonItemCount(itemId)
	self._item_count = math.min(g_i3k_game_context:GetCommonItemCount(itemId), dayTimes)

	USE_COUNT_TEXT = 1
	self.use_count:setText(self.current_num)

	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(itemId)
	if item_cfg.type == UseItemBuffDrug and item_cfg.args2 == g_NORMAL_BUFF_DRUG then
		local needCount = g_i3k_game_context:GetBuffDrugLimit(item_cfg.args1)
		needCount = self._item_count < needCount and self._item_count or needCount
		self.times_desc:setText(string.format("本次可使用次数：%s", needCount))
	else
		self.times_desc:setText(i3k_get_string(283, dayTimes))
	end
	
	self:updateMaxNum()
	self:updatefun()
end

function wnd_create(layout)
	local wnd = wnd_limit_items.new()
	wnd:create(layout)
	return wnd
end
