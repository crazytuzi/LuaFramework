-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")

-------------------------------------------------------

wnd_use_items = i3k_class("wnd_use_items",ui.wnd_add_sub)

local SALE_COUNT_TEXT = 1

function wnd_use_items:ctor()
	self._itemid = 0
	self._item_count = 0
	self._item_type = 0
end

function wnd_use_items:configure()
	local widget = self._layout.vars
	self.item_icon = widget.item_icon
	self.item_name = widget.item_name
	self.item_count = widget.item_count
	self.use_count = widget.use_count
	self.use_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.use_count:addEventListener(function(eventType)
		if eventType == "ended" then
		    local str = tonumber(self.use_count:getText()) or 1
		    if  str > self.current_add_num then
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
	self.close_btn = widget.close_btn
	self.item_desc = widget.item_desc
	self.item_bg = widget.item_bg

	widget.max:onClick(self, self.maxButton)

	widget.cancel:onClick(self, self.cancelButton)
	widget.ok:onClick(self, self.okButton)
	self.ok_word = widget.ok_word

	self.add_btn = widget.jia
	self.sub_btn = widget.jian
	self.max_btn = widget.max
	self._count_label = self.use_count

	--self.current_add_num = 100 	--当前能够增加到的最大值

	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.onMax)
	--self.current_num   当前的实际数值，默认为1，不会小于1，可以直接用

end

function wnd_use_items:setSaleMoneyCount(count)
	self.use_count:setText(count)
end

function wnd_use_items:updatefun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_UseItems,"setSaleMoneyCount",self.current_num)
	end
end

function wnd_use_items:updateMaxNum()
	if self._item_type == UseItemExp then
		local itemExp = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid).args1
		local itemCount = self._item_count
		local needCount =  g_i3k_game_context:GetAddExpNumber(itemExp,itemCount)
		self.current_add_num = needCount
	elseif self._item_type == UseItemVipHp then
		local itemCount = self._item_count
		local needCount = g_i3k_game_context:GetMaxVipBloodPoolCount(self._itemid,itemCount)
		self.current_add_num = needCount
	elseif self._item_type == UseItemVit then
		local itemCount = self._item_count
		local needCount =  g_i3k_game_context:GetAddVitNumber(self._itemid)
		self.current_add_num = needCount
	elseif self._item_type == UseItemEmpowerment then
		local needCount = g_i3k_game_context:canGetMaxCurExpCoin(self._itemid)
		self.current_add_num = needCount
	elseif self._item_type == UseItemEvil then
		local needCount = g_i3k_game_context:canGetMaxCurrentPKValue(self._itemid)
		self.current_add_num = needCount
	elseif self._item_type == UseItemOneTimes then
		local needCount = g_i3k_game_context:getOneTimesItemAllCountDataForId(self._itemid)
		self.current_add_num = needCount
	elseif  self._item_type == UseItemPowerRep then -- 势力声望提交道具，可以选择的最大值
		local needCount = g_i3k_game_context:getPowerRepMaxCommitCount(self._itemid)
		local haveCount = g_i3k_game_context:GetCommonItemCount(self._itemid)
		self.current_add_num = math.min(needCount, haveCount)
	else
		self.current_add_num = self._item_count
	end
end

function wnd_use_items:cancelButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_UseItems)
end

function wnd_use_items:okButton(sender)
	if self.current_num > 0 then
		local isClose = true
		if self._item_type == UseItemGift then
			local isCanBuy, needVipLvl = g_i3k_db.i3k_db_get_bag_item_is_need_viplvl(self._itemid)
			if not isCanBuy then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17393, needVipLvl))
			end
			if g_i3k_db.i3k_db_get_gift_bag_is_open_select(self._itemid) then
				g_i3k_ui_mgr:OpenUI(eUIID_GiftBagSelect)
				g_i3k_ui_mgr:RefreshUI(eUIID_GiftBagSelect, self._itemid, self.current_num)
			else
				if g_i3k_db.i3k_db_get_open_gift_is_enough(self._itemid, self.current_num) then
					local needItemId, needItemCount = g_i3k_db.i3k_db_get_day_use_consume_info(self._itemid)
					if needItemId ~= 0 and needItemCount ~= 0 then
						g_i3k_ui_mgr:OpenUI(eUIID_UseLimitConsumeItems)
						g_i3k_ui_mgr:RefreshUI(eUIID_UseLimitConsumeItems, self._itemid, self._item_type)
					else
						i3k_sbean.bag_useitemgift(self._itemid, self.current_num)
					end
					g_i3k_ui_mgr:CloseUI(eUIID_UseItems)
					return
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
					return
				end
			end
		elseif self._item_type == UseItemCoin then
			i3k_sbean.bag_useitemcoin(self._itemid, self.current_num)
		elseif self._item_type == UseItemDiamond then
			i3k_sbean.bag_useitemdiamond(self._itemid, self.current_num)
		elseif self._item_type == UseItemExp then
			isClose = self:onUseExpItems()
		elseif self._item_type == UseItemEquipEnergy then
			i3k_sbean.bag_useitemequipenergy(self._itemid, self.current_num)
		elseif self._item_type == UseItemGemEnergy then
			i3k_sbean.bag_useitemgemenergy(self._itemid, self.current_num)
		elseif self._item_type == UseItemBookSpiration then
			i3k_sbean.bag_useiteminspiration(self._itemid, self.current_num)
		elseif self._item_type == UseItemVipHp then
			i3k_sbean.bag_useitemhppool(self._itemid,  self.current_num)
		elseif self._item_type == UseItemChest then
			i3k_sbean.bag_useitemchest(self._itemid, self.current_num)
		elseif self._item_type == UseItemVit then
			i3k_sbean.bag_useitemvit(self._itemid, self.current_num)
		elseif self._item_type == UseItemLibrary then
			local tmp = {}
			tmp[self._itemid] = self.current_num
			i3k_sbean.goto_rarebook_push(tmp)
		elseif self._item_type == UseItemHorseBook then
			local tmp = {}
			tmp[self._itemid] = self.current_num
			i3k_sbean.goto_horseBook_push(tmp)
		elseif self._item_type == UseItemFeats then --武勋
			i3k_sbean.goto_bag_useitemfeat(self._itemid, self.current_num)

		elseif self._item_type == UseItemEmpowerment then
			local nowCoin = g_i3k_game_context:GetExperienceCurExpCoin()
			local maxCoin = i3k_db_experience_args.args.maxSaveExperience
			local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
			local needCoin = item_cfg.args1
			local coin = (maxCoin - nowCoin) / needCoin
			if math.floor(coin) < 1 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(440))
				return
			else
				i3k_sbean.goto_bag_useitemexpcoinpool(self._itemid, self.current_num)
			end
		elseif self._item_type == UseItemEvil then
			i3k_sbean.bag_useitemevil(self._itemid, self.current_num)
		elseif self._item_type == UseItemCard then -- 月卡
			local endTime = g_i3k_game_context:GetMonthlyCardEndTime()
			i3k_sbean.goto_bag_usemonthlycard(self._itemid, endTime)
		elseif self._item_type == UseItemOneTimes then
			i3k_sbean.bag_useitempropstrength(self._itemid, self.current_num)
		elseif self._item_type == UseItemSpirit then
			i3k_sbean.bag_useitemofflinefuncpoint(self._itemid, self.current_num)
		elseif self._item_type == UseItemVipExp then  --vip经验
			i3k_sbean.bag_useitemvipexp(self._itemid, self.current_num)
		elseif self._item_type == UseItemProduceSplitSp then  --生产能量
			i3k_sbean.bag_useitemaddproducesplitsp(self._itemid, self.current_num)
		elseif self._item_type == UseItemBuffDrug then  --buff药
			i3k_sbean.bag_useitembuffdrug(self._itemid, self.current_num)
		elseif self._item_type == UseItemGetEmoji then
			local timeStamp = i3k_game_get_time()
			local emoji_cfg = g_i3k_game_context:getEmojiData()
			local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
			local emoji_id = item_cfg.args1
			local isOver = false
			if not emoji_cfg[emoji_id] then
				isOver = i3k_db_emoji_cfg[emoji_id].limitTime * 86400 >= item_cfg.args2 * self.current_num
			else
				isOver = timeStamp + i3k_db_emoji_cfg[emoji_id].limitTime * 86400 >= emoji_cfg[emoji_id] + item_cfg.args2 * self.current_num
			end
			if isOver then
				local callback = function ()
					if emoji_cfg[emoji_id] then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16366))
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16365))
					end
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_SelectBq, "refreshUI")
				end
				i3k_sbean.bag_useitemiconpackage(self._itemid, self.current_num, callback)
			else
				g_i3k_ui_mgr:PopupTipMessage("超过表情包使用上限")
				return
			end
		elseif self._item_type == UseItemWeaponSoul then
			i3k_sbean.bag_useweaponsoulcoinadder(self._itemid, self.current_num)
		elseif self._item_type == UseItemGetChatBox then
			i3k_sbean.bag_usechatboxitemReq(self._itemid, self.current_num)
		elseif self._item_type == UseItemGodEquip then
			local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
			if i3k_db_career_gift_bag[itemCfg.args1].giftType == 0 then
				i3k_sbean.bag_useitemgiftnew(self._itemid, self.current_num)
			else
				g_i3k_ui_mgr:OpenUI(eUIID_GiftBagSelect)
				g_i3k_ui_mgr:RefreshUI(eUIID_GiftBagSelect, self._itemid, self.current_num)
			end
		elseif self._item_type == UseItemPowerRep then
			local count = g_i3k_game_context:GetCommonItemCount(self._itemid)
			if count == 0 then
				g_i3k_ui_mgr:PopupTipMessage("道具不足")
			end
			local tempInfo = g_i3k_game_context:getPowerRepUselessInfo()
			local key = g_i3k_game_context:getCurrentPowerRepCommitKey(tempInfo.powerSide, self._itemid)
			i3k_sbean.powerReqDonate(tempInfo.powerSide, key, self.current_num, self._itemid)
		elseif self._item_type == UseItemSpiritBoss then
			local count = g_i3k_game_context:GetCommonItemCount(self._itemid)
			if count == 0 then
				g_i3k_ui_mgr:PopupTipMessage("道具不足")
			else
				i3k_sbean.bag_useitemgbcoin(self._itemid, self.current_num)
			end
		elseif self._item_type == UseItemFurniture then
			local count = g_i3k_game_context:GetCommonItemCount(self._itemid)
			if count == 0 then
				g_i3k_ui_mgr:PopupTipMessage("道具不足")
			else
				local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(self._itemid)
				i3k_sbean.furniture_bag_put(itemCfg.args2, self.current_num, itemCfg.args1, self._itemid)
			end
		elseif self._item_type == UseItemRegular then
			local count = g_i3k_game_context:GetCommonItemCount(self._itemid)
			if count == 0 then
				g_i3k_ui_mgr:PopupTipMessage("道具不足")
			else
				i3k_sbean.bag_use_regular_item_activity(self._itemid, self.current_num)
			end
		elseif self._item_type == UseItemSwornValue then
			local count = g_i3k_game_context:GetCommonItemCount(self._itemid)
			if count == 0 then
				g_i3k_ui_mgr:PopupTipMessage("道具不足")
			else
				i3k_sbean.use_sworn_gift_item(self._itemid, self.current_num)
			end
		elseif self._item_type == UseItemSteedEquipSpirit then
			i3k_sbean.bag_useItemSteedStove(self._itemid, self.current_num)
		elseif self._item_type == UseItemArrayStone then
			local count = g_i3k_game_context:GetCommonItemCount(self._itemid)
			if count == 0 then
				g_i3k_ui_mgr:PopupTipMessage("道具不足")
			else
				if g_i3k_game_context:GetLevel() >= i3k_db_array_stone_common.openLvl then
					i3k_sbean.bag_useitemciphertextenergy(self._itemid, self.current_num)
				else
					g_i3k_ui_mgr:PopupTipMessage("等级不够(需要配置)")
				end
			end
		elseif self._item_type == UseItemNewPower then
			local count = g_i3k_game_context:GetCommonItemCount(self._itemid)
			if count == 0 then
				g_i3k_ui_mgr:PopupTipMessage("道具不足")
			else
				i3k_sbean.bag_useItemForceFame(self._itemid, self.current_num)
			end
		else
			--炼化选中
			if g_i3k_ui_mgr:GetUI(eUIID_Production) then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production,"selectRecycleItem",self.current_num)
			end
		end
		if isClose then
			g_i3k_ui_mgr:CloseUI(eUIID_UseItems)
		end
	end
end

-- 如果道具数量=1，则直接使用并且马上关闭此界面。此函数仅在battleEquip中调用
function wnd_use_items:checkItemCountEqualOne()
	if self._item_count == 1 then
		self:okButton(nil)
		g_i3k_ui_mgr:CloseUI(eUIID_UseItems)
	else
		self:onMax(nil, ccui.TouchEventType.ended)
	end
end

function wnd_use_items:refresh(itemId, itemType)
	self._itemid = itemId
	self._item_count = g_i3k_game_context:GetCommonItemCount(self._itemid)
	self._item_type = itemType
	if self._item_type == UseItemGetEmoji then
		local emoji_cfg = g_i3k_game_context:getEmojiData()
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemid)
		if emoji_cfg[item_cfg.args1] then
			self.ok_word:setText("续费")
		else
			self.ok_word:setText("确定")
		end
	else
		self.ok_word:setText("确定")
	end
	self:updateUI()
end

function wnd_use_items:updateUI()
	SALE_COUNT_TEXT = 1

	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(self._itemid)

	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._itemid,i3k_game_context:IsFemaleRole()))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._itemid))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(self._itemid))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(self._itemid))
	self.item_count:setText(self._item_count)
	self.use_count:setText(self.current_num)
	self:updateMaxNum()
	self:updatefun()
end

function wnd_use_items:setRecycleMaxNum(num)
	self._item_count = num
	self:updateMaxNum()
end

function wnd_create(layout)
	local wnd = wnd_use_items.new()
	wnd:create(layout)
	return wnd
end
