-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_bag_item_info = i3k_class("wnd_bag_item_info",ui.wnd_base)

function wnd_bag_item_info:ctor()
	self.id = 0
	self.count = 0
	self.use_times = 0
	self._assignCount = 0
end

function wnd_bag_item_info:configure()
	local widgets = self._layout.vars
	self.globel_bt = widgets.globel_bt

	self.itemName_label = widgets.itemName_label
	self.item_bg = widgets.item_bg
	self.item_icon = widgets.item_icon
	self.itemGrade_lable = widgets.itemGrade_lable
	self.itemDesc_label = widgets.itemDesc_label
	self.get_label = widgets.get_label

	self.btn1 = widgets.sale
	self.btn2 = widgets.combineBtn
	self.btn3 = widgets.inset
	self.label1 = widgets.label1
	self.label2	= widgets.label2
	self.label3 = widgets.label3

	self.btn1:onClick(self, self.saleButton)
	self.globel_bt:onClick(self, self.closeButton)
	self.skillPanel = widgets.skillPanel
	self.mainPanel = widgets.mainPanel
	self.scroll = widgets.scroll

end

function wnd_bag_item_info:refresh(id, isWarehouse)
	self.id = id
	self.count = g_i3k_game_context:GetCommonItemCount(id)

	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)

	self.itemName_label:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self.itemDesc_label:setText(g_i3k_db.i3k_db_get_common_item_desc(id))
	self.get_label:setText(g_i3k_db.i3k_db_get_common_item_source(id))
	self.itemName_label:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))

	local lvlReq = g_i3k_db.i3k_db_get_common_item_level_require(id)
	self.itemGrade_lable:setText(i3k_get_string(g_UseItem_Need_Level, lvlReq))
	self.itemGrade_lable:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= lvlReq))
	self.itemGrade_lable:setVisible(lvlReq > 1)

	local limitTimes = g_i3k_db.i3k_db_get_bag_item_limitable(id)
	if g_i3k_db.i3k_db_get_bag_item_limitable(id) and (lvlReq <= 1 or g_i3k_game_context:GetLevel() >= lvlReq) then
		self.use_times = g_i3k_db.i3k_db_get_day_use_item_day_use_times(id)
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(id)
		local times = self.use_times
		local str = i3k_get_string(283, self.use_times)
		self.itemGrade_lable:setText(i3k_get_string(283, self.use_times))
		self.itemGrade_lable:setVisible(g_i3k_db.i3k_db_get_day_use_item_times(id) ~= 999)
		self.itemGrade_lable:setTextColor(g_i3k_get_cond_color(self.use_times > 0))
	end
	if isWarehouse then
		self.btn2:hide()
		self.btn3:hide()
		self.btn1:hide()
		local str = isWarehouse.around == 1 and "取出仓库" or "存入仓库"
		self.label1:setText(str)
		if isWarehouse.isCanSave then
			self.btn1:show()
			self.btn1:onClick(self, self.saleButton, isWarehouse)
		end
	else
		self:JudgeBtn()
		if g_i3k_db.i3k_db_get_common_item_sell_count(self.id) == 0 then
			self.btn1:hide()
		end
	end
	local isShowSkillPanel = i3k_show_skill_item_description(self.scroll, id)
	self.skillPanel:setVisible(isShowSkillPanel)
	if not isShowSkillPanel then
		local skillPanelPosition = self.skillPanel:getPosition()
		local mainPanelPosition = self.mainPanel:getPosition()
		self.mainPanel:setPosition((skillPanelPosition.x + mainPanelPosition.x) / 2, mainPanelPosition.y)
	end
end

function wnd_bag_item_info:JudgeBtn()
	local label = {}
	local btn = {}
	for i=2, 3 do
		label[i] = self["label" .. i]
		btn[i]	 = self["btn" .. i]
	end
	local labelCont = 0
	if g_i3k_game_context:GetBagMiscellaneousCount(-self.id) ~= 0 and g_i3k_game_context:GetBagMiscellaneousCount(-self.id) then
		self.btn2:show()
		self.btn3:show()
		self.btn2:onClick(self, self.combineButton, self.id)
		labelCont = 3
	else
		self.btn2:show()
		self.btn3:hide()
		labelCont = 2
	end
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
	if g_i3k_db.i3k_db_get_bag_item_useable(self.id) then
		label[labelCont]:setText("使用")
		self._assignCount = 1
		if item_cfg and item_cfg.type and item_cfg.type == UseItemLibrary then
			label[labelCont]:setText("存入")
			self._assignCount = 1
		elseif item_cfg and item_cfg.type == UseItemHorseBook then -- 存入（骑术背包）
			label[labelCont]:setText("存入")
			self._assignCount = 1	
		end
	elseif g_i3k_db.i3k_db_get_gem_item_cfg(self.id) then
		label[labelCont]:setText("镶嵌")
		self._assignCount = 2
	elseif item_cfg and item_cfg.type == UseItemChip then
		label[labelCont]:setText("合成")
		self._assignCount = 3
	elseif  item_cfg and item_cfg.type == UseItemMail then    --阅读
		label[labelCont]:setText("阅读")
		self._assignCount = 4
	elseif  item_cfg and item_cfg.type == UseItemRune then    --存入（符文背包）
		label[labelCont]:setText("存入")
		self._assignCount = 5
	elseif item_cfg and item_cfg.isGoto ~= 0 and item_cfg.type == UseItemRelease then
		if not g_i3k_game_context:GetNotEnterTips() then
			label[labelCont]:setText("放生")
			self._assignCount = 6
		else
			btn[labelCont]:hide()
		end		
	elseif item_cfg and item_cfg.isGoto ~= 0 then
		if not g_i3k_game_context:GetNotEnterTips() then
			label[labelCont]:setText("前往")
			self._assignCount = 6
		else
			btn[labelCont]:hide()
		end
	elseif item_cfg and item_cfg.type == UseItemBaguaSacrifice then
		if item_cfg.args5 ~= 0 then
			label[labelCont]:setText(i3k_get_string(17814))
			self._assignCount = 7
		else
			btn[labelCont]:hide()
		end
	else
		btn[labelCont]:hide()
	end
	btn[labelCont]:onClick(self, self.useButton, item_cfg)
end

function wnd_bag_item_info:useButton(sender, cfg)
	g_i3k_game_context:useItemAtBagRemoveTip(self.id)
	if self.id == ConveyID then --传送符（特殊）
		self:useConvey()
		return
	end
	if self._assignCount == 1 then
		self:useAsItem()
	elseif self._assignCount == 2 then
		self:useAsGem()
	elseif self._assignCount == 3 then
		--合成
		self:useCompound(self.id)
	elseif self._assignCount == 4 then
		--阅读
		self:readMail(self.id)
	elseif self._assignCount == 5 then
		--阅读
		self:inputRuneBag(self.id)
	elseif self._assignCount == 6 then
		--前往
		self:ShowGo(cfg)
	elseif self._assignCount == 7 then --八卦祭品拆分
		self:openBaGuaSplit()
	elseif g_i3k_db.i3k_db_get_book_item_cfg(self.id) then
		self:useAsBook()
	end
end
function wnd_bag_item_info:openBaGuaSplit()
	local id = self.id
	g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
	g_i3k_logic:OpenBaGuaSplit(id)
end

function wnd_bag_item_info:ShowGo(item_cfg)
	if item_cfg.isGoto == g_GO_NPC  then
		g_i3k_game_context:GotoNpc(item_cfg.isGo)
	elseif item_cfg.isGoto==g_GO_MONSTER then 
		g_i3k_game_context:GotoMonsterPos(item_cfg.isGo)
	end
    g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
	g_i3k_ui_mgr:CloseUI(eUIID_Bag)
end
--jxw
function wnd_bag_item_info:inputRuneBag(id)
	if self.count ==1 then
		local itemTab = {}
		itemTab[id] = self.count
		i3k_sbean.pushRune(itemTab)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_Push_Rune)
		g_i3k_ui_mgr:RefreshUI(eUIID_Push_Rune, self.id, self.count)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
end

---道具类型45
function wnd_bag_item_info:inputHorseBookBag()
	local tmp = {}
	if self.count == 1 then
		tmp[self.id] = self.count
		i3k_sbean.goto_horseBook_push(tmp)
	else
		self:openUseItemsUI()
	end
	return true
end

---道具类型47
function wnd_bag_item_info:useEscordSkin()
	g_i3k_ui_mgr:OpenUI(eUIID_FactionEscort)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort,"onUpdateSkin")	
	return true
end

function wnd_bag_item_info:useCompound(id)
	g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
	g_i3k_ui_mgr:OpenUI(eUIID_Compound)
	g_i3k_ui_mgr:RefreshUI(eUIID_Compound, id)
end

function wnd_bag_item_info:readMail(id)
	if g_i3k_game_context:GetLevel() <  g_i3k_db.i3k_db_get_other_item_cfg(id).levelReq then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(127, g_i3k_db.i3k_db_get_other_item_cfg(id).levelReq))
		return true
	end

	g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
	g_i3k_ui_mgr:OpenUI(eUIID_ItemMailUI)
	local idss = id
	g_i3k_ui_mgr:RefreshUI(eUIID_ItemMailUI,id)
	--g_i3k_logic:OpenItemMailUI(self.id)

end

function wnd_bag_item_info:useAsGem()
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.inlayLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(127, i3k_db_common.functionOpen.inlayLvl))
		return true
	end
	g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
	g_i3k_ui_mgr:CloseUI(eUIID_Bag)
	g_i3k_logic:OpenEquipGemInlayUI()
end

function wnd_bag_item_info:useAsBook()
	g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
	g_i3k_ui_mgr:CloseUI(eUIID_Bag)
	g_i3k_logic:OpenXinfaUI()
end

function wnd_bag_item_info:useConvey()
	g_i3k_logic:OpenBattleUI()
	--g_i3k_ui_mgr:OpenUI(eUIID_SceneMap)
	local world = i3k_game_get_logic():GetWorld()
	local mapId = world._cfg.id
	--g_i3k_ui_mgr:RefreshUI(eUIID_SceneMap, mapId)
	g_i3k_logic:OpenMapUI(mapId)
end

--道具类型1 钻石包
function wnd_bag_item_info:useItemDiamond()
	if self.count == 1 then
		i3k_sbean.bag_useitemdiamond(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型2 金币包
function wnd_bag_item_info:useItemCoin()
	if self._diamond_count == 1 then
		i3k_sbean.bag_useitemcoin(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型3 经验丹
function wnd_bag_item_info:useItemExp()
	if not g_i3k_game_context:GetCanUseExpItem() then
		g_i3k_ui_mgr:PopupTipMessage("你满级了")
	else
		-- if self.count == 1 then
		-- 	i3k_sbean.bag_useitemexp(self.id, self.count)
		-- else
			self:openUseItemsUI()
		-- end
	end
	return true
end

--道具类型4 礼物包
function wnd_bag_item_info:useItemGift()
	local needItemId, needItemCount = g_i3k_db.i3k_db_get_day_use_consume_info(self.id)
	if self.count == 1 and (needItemId == 0 or needItemCount == 0) then
		local isCanBuy, needVipLvl = g_i3k_db.i3k_db_get_bag_item_is_need_viplvl(self.id)
		if not isCanBuy then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17393, needVipLvl))
			return true
		end
		if g_i3k_db.i3k_db_get_gift_bag_is_open_select(self.id) then
			g_i3k_ui_mgr:OpenUI(eUIID_GiftBagSelect)
			g_i3k_ui_mgr:RefreshUI(eUIID_GiftBagSelect, self.id, 1)
		else
			if g_i3k_db.i3k_db_get_open_gift_is_enough(self.id, 1) then
				i3k_sbean.bag_useitemgift(self.id, self.count)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
			end	
		end
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型6 药瓶
function wnd_bag_item_info:useItemHp()
	
	local maptype = i3k_game_get_map_type()
	if maptype == g_FIELD then
		local mapId = g_i3k_game_context:GetWorldMapID()
		if i3k_db_field_map[mapId].showBloodPool == 0 then
			g_i3k_ui_mgr:PopupTipMessage("龙穴不能使用血药")
			return
		end
	end
	
	local curHp, maxHP = g_i3k_game_context:GetRoleHp()
	if curHp == maxHP then
		g_i3k_ui_mgr:PopupTipMessage("血量已满，无法使用药品")
	elseif i3k_integer(i3k_game_get_time()) - g_i3k_game_context:GetUseDrugTime() < i3k_db_common.drug.drugTime.cTime then
		g_i3k_ui_mgr:PopupTipMessage("药品冷却时间未到")
	else
		i3k_sbean.bag_useitemhp(self.id, 1,g_i3k_game_context:GetUseDrugTime())
	end
	return true
end

--道具类型8 Vip血池
function wnd_bag_item_info:useItemVipHp()
	if g_i3k_game_context:GetIsInHomeLandHouse() then
		g_i3k_ui_mgr:PopupTipMessage("房屋内不能使用该道具")
		return false
	end
	if g_i3k_game_context:GetMaxVipBloodPoolCount(self.id) == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(209))
	else
		if self.count == 1 then
			i3k_sbean.bag_useitemhppool(self.id,  self.count)
		else
			self:openUseItemsUI()
		end
	end

	return true
end

--道具类型9 神环礼包
function wnd_bag_item_info:useItemChest()
	self:openUseItemsUI()
	return true
end

--道具类型13 装备能量
function wnd_bag_item_info:useItemEquipEnergy()
	if self.count == 1 then
		i3k_sbean.bag_useitemequipenergy(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型14 宝石能量
function wnd_bag_item_info:useItemGemEnergy()
	if self.count == 1 then
		i3k_sbean.bag_useitemgemenergy(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型15 心法悟性
function  wnd_bag_item_info:useItemBookSpiration()
	if self.count == 1 then
		i3k_sbean.bag_useiteminspiration(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型16 体力包
function wnd_bag_item_info:useItemVit()
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
	local value = item_cfg.args1 or 0 
	local curVit = g_i3k_game_context:GetVit()
	local maxVit = g_i3k_game_context:GetVitRealMax() - value --使用道具后不允许超过最大值
	if self.count == 1 then
		if curVit <= maxVit then
			i3k_sbean.bag_useitemvit(self.id, self.count)
		else
			g_i3k_ui_mgr:PopupTipMessage("体力值已满，不需要使用体力包")
		end
	else
		if curVit <= maxVit then
			self:openUseItemsUI()
		else
			g_i3k_ui_mgr:PopupTipMessage("体力值已满，不需要使用体力包")
		end
	end
	return true
end

--道具类型19 历练（满）
function wnd_bag_item_info:useItemEmpowerment()
	if self.count == 1 then
		i3k_sbean.goto_bag_useitemexpcoinpool(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型20 藏书
function wnd_bag_item_info:useItemLibrary()
	if g_i3k_game_context:GetLevel() < i3k_db_experience_args.args.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s级开启历练后才能存入藏书", i3k_db_experience_args.args.openLevel))
		return false
	end
	local tmp = {}
	if self.count == 1 then
		tmp[self.id] = self.count
		i3k_sbean.goto_rarebook_push(tmp)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型21 月卡体验
function wnd_bag_item_info:useItemCard()
	local endTime = g_i3k_game_context:GetMonthlyCardEndTime()
	i3k_sbean.goto_bag_usemonthlycard(self.id, endTime)
	return true
end

--道具类型22 vip卡体验
function wnd_bag_item_info:useItemVipCard()
	local data = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
	if g_i3k_game_context:GetVipLevel() < data.args2 then
		if g_i3k_game_context:GetVipExperienceLevel() < data.args2 then
			i3k_sbean.goto_bag_usevipcard(self.id, data.args2)
		else
			g_i3k_ui_mgr:PopupTipMessage("你的贵族体验等级超过体验卡的等级，无法使用")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("你的贵族等级超过体验卡的等级，无法使用")
	end
	return true
end

--道具类型24 增加武勋道具
function wnd_bag_item_info:useItemFeats()
	if self.count == 1 then
		i3k_sbean.goto_bag_useitemfeat(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型30 扣除罪恶点
function wnd_bag_item_info:useItemEvil()
	if self.count == 1 then
		i3k_sbean.bag_useitemevil(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

-- 道具类型31 烟花
function wnd_bag_item_info:useItemFirework()
	local id = self.id
	i3k_sbean.playFirework(id)
	g_i3k_ui_mgr:CloseUI(eUIID_Bag)
	return true
end

--道具类型33 一生限制使用道具
function wnd_bag_item_info:useItemOneTimes()
	local canUseCount = g_i3k_game_context:getOneTimesItemAllCountDataForId(self.id)
	if canUseCount == 0 or canUseCount == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
		return true
	end
	if self.count == 1 then
		i3k_sbean.bag_useitempropstrength(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型34 离线经验修炼点
function wnd_bag_item_info:useItemSpirit()
	if self.count == 1 then
		i3k_sbean.bag_useitemofflinefuncpoint(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型35 重置称号剩余时间
function wnd_bag_item_info:useItemResetTitleTime()
	i3k_sbean.bag_useitemtitle(self.id)
	return true
end

--道具类型36 激活绝技道具
function wnd_bag_item_info:useItemUniqueSkill()
	if g_i3k_db.i3k_db_get_isown_from_itemid(self.id) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(958))
	else
		g_i3k_logic:OpeneUniqueskillPreviewUI(self.id)
	end
	return true
end

--道具类型38 增加vip经验
function wnd_bag_item_info:useItemVipExp()
	local data = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
	local maxVipLvl = i3k_table_length(i3k_db_kungfu_vip) - 1
	local curVipLvl = g_i3k_game_context:GetVipLevel()
	if curVipLvl == maxVipLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15464))
		return true
	elseif curVipLvl > data.args1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15465))
		return true
	end
	if self.count == 1 then
		i3k_sbean.bag_useitemvipexp(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型39 增加生产能量值
function wnd_bag_item_info:useItemProduceSplitSp()
	if self.count == 1 then
		i3k_sbean.bag_useitemaddproducesplitsp(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型40 使用buff药
function wnd_bag_item_info:useItemBuffDrug()
	if self.count == 1 then
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
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
					if g_i3k_game_context:GetBuffDrugLimit(cfg.args1) >= self.count then  --超过buff药叠加层数
						local count = self.count

						local slotLvl = g_i3k_game_context:GetUseBuffDrugSlotLvl(cfg.args1)
						local desc = ""
						if slotLvl == g_USE_HIGH_SLOTLVL then
							desc = i3k_get_string(16142)
						elseif slotLvl == g_USE_LOW_SLOTLVL then
							desc = i3k_get_string(16141)
						elseif slotLvl == g_USE_SAME_SLOTLVL then
							desc = i3k_get_string(16144, self.count, cfg.name)
						end
						
						local fun = (function(ok)
							if ok then
								i3k_sbean.bag_useitembuffdrug(cfg.id, count)
							end
						end)
						g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
					else
						local overLays = i3k_db_buff[cfg.args1].overlays
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16140, overLays))
					end
				end
			elseif cfg.args2 == g_FIGHT_LINE_BUFF_DRUG then
				local count = self.count
				if g_i3k_game_context:GetBuffAffectValue(cfg.args1) >= i3k_db_common.fight_line_exp_max and not g_i3k_game_context:IsFightLineBuffTypeExist(cfg.args1) then
					local desc = i3k_get_string(16149, i3k_db_common.fight_line_exp_max * 0.01)
					local fun = (function(ok)
						if ok then
							i3k_sbean.bag_useitembuffdrug(cfg.id, count)
						end
					end)
					g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
				else
					i3k_sbean.bag_useitembuffdrug(cfg.id, count)
				end
			end
		end
	else
		self:openUseItemsUI()
	end
	return true
end

--道具类型41 使用表情包
function wnd_bag_item_info:useItemGetEmoji()
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
	local emoji_cfg = g_i3k_game_context:getEmojiData()
	local timeStamp = i3k_game_get_time()
	--判断使用一个是否会超过最大时间
	if emoji_cfg[item_cfg.args1] and timeStamp + i3k_db_emoji_cfg[item_cfg.args1].limitTime * 86400 < emoji_cfg[item_cfg.args1] + item_cfg.args2 then
		g_i3k_ui_mgr:PopupTipMessage("超过最大期限")
		return true
	end
	
	if self.count == 1 then
		local id = self.id
		local count = self.count
		local fun = function (ok)
			if ok then
				local callback = function()
					if emoji_cfg[item_cfg.args1] then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16366))
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16365))
					end
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_SelectBq, "refreshUI")
				end
				i3k_sbean.bag_useitemiconpackage(id, count, callback)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2("确定使用该表情包？", fun, callback)
	else
		self:openUseItemsUI()
	end
	return true
end

--类型42 使用加武运道具 
function wnd_bag_item_info:useWeaponSoul()
	if self.count == 1 then
		i3k_sbean.bag_useweaponsoulcoinadder(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

function wnd_bag_item_info:useChatBox()
	if self.count == 1 then
		i3k_sbean.bag_usechatboxitemReq(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

--53神装礼包
function wnd_bag_item_info:useGodEquip()
	if self.count == 1 then
		local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
		if i3k_db_career_gift_bag[itemCfg.args1].giftType == 0 then
			i3k_sbean.bag_useitemgiftnew(self.id, self.count)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_GiftBagSelect)
			g_i3k_ui_mgr:RefreshUI(eUIID_GiftBagSelect, self.id, self.count)
		end
	else
		self:openUseItemsUI()
	end
	return true
end

--55心情日记激活道具
function wnd_bag_item_info:useDiaryDecorate()
	local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
	local callback = function ()
		g_i3k_ui_mgr:OpenUI(eUIID_MoodDiaryBeauty)
		g_i3k_ui_mgr:RefreshUI(eUIID_MoodDiaryBeauty)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiaryBeauty, "changeDecoration", nil, itemCfg.args1)
	end
	i3k_sbean.mood_diary_open_main_page(1, g_i3k_game_context:GetRoleId(), callback)
	return true
end

-- 57 家园装备道具
function wnd_bag_item_info:useHomeLandEquip()
	i3k_sbean.bag_useitemhomelandequip(self.id, 1)
	return true
end

-- 61 使用正义徽章道具
function wnd_bag_item_info:useSpiritBoss()
	if self.count == 1 then
		i3k_sbean.bag_useitemgbcoin(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end

-- 63使用家具类型道具
function wnd_bag_item_info:useItemFurniture()
	if self._count == 1 then
		local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(self.id)
		i3k_sbean.furniture_bag_put(itemCfg.args2, 1, itemCfg.args1, self.id)
	else
		self:openUseItemsUI()
	end
	return true
end
-- 64使用定期活动道具
function wnd_bag_item_info:useItemUseItemRegular()
	if g_i3k_db.i3k_db_get_timing_activity_state() == g_TIMINGACTIVITY_STATE_NONE then
		g_i3k_ui_mgr:PopupTipMessage("道具已经失效！")
	else
		if self.count == 1 then
			i3k_sbean.bag_use_regular_item_activity(self.id, self.count)
		else
			self:openUseItemsUI()
		end
	    
	end
	return true
end

--65使用房屋皮肤解锁道具
function wnd_bag_item_info:useItemHouseSkin()
	i3k_sbean.bag_use_house_skin_item(self.id)
	return true
end

function wnd_bag_item_info:useItemCardPacket()
	g_i3k_logic:OpenUnlockCardPacketUI()
	return true
end
--66增加结拜金兰值道具
function wnd_bag_item_info:useItemSwornValue()
	local isSworn = g_i3k_game_context:getSwornFriends()
	if isSworn then
		if self.count == 1 then
			i3k_sbean.use_sworn_gift_item(self.id, self.count)
		else
			self:openUseItemsUI()
		end
		return true
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5443))
		return false
	end
end
-- 69 骑战装备熔炼精华道具
function wnd_bag_item_info:useItemSteedEquipEnergy()
	if self.count == 1 then
		i3k_sbean.bag_useItemSteedStove(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end
-- 77 密文能量道具
function wnd_bag_item_info:useItemArrayStone()
	if g_i3k_game_context:GetLevel() >= i3k_db_array_stone_common.openLvl then
		if self.count == 1 then
			i3k_sbean.bag_useitemciphertextenergy(self.id, self.count)
		else
			self:openUseItemsUI()
		end
		return true
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18400, i3k_db_array_stone_common.openLvl))
		return false
	end
end
-- 78 战区卡片道具
function wnd_bag_item_info:useItemWarZoneCard()
	if g_i3k_game_context:GetLevel() >= i3k_db_war_zone_map_cfg.needLvl then
		local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
		if not cardInfo.card.bag[cfg.args1] then
			i3k_sbean.global_world_use_card_box(self.id)
			return true
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5751))
			return false
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5770, i3k_db_war_zone_map_cfg.needLvl))
		return false
	end
end
function wnd_bag_item_info:openUseItemsUI()
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
	local needItemId, needItemCount = g_i3k_db.i3k_db_get_day_use_consume_info(self.id)
	if g_i3k_db.i3k_db_get_bag_item_limitable(self.id) then
		local dayUseTimes, canAddMaxTimes, needVipLvl = g_i3k_db.i3k_db_get_day_use_item_day_use_times(self.id)
		if dayUseTimes ~= 0 then
			if needItemId == 0 or needItemCount == 0 then
				g_i3k_ui_mgr:OpenUI(eUIID_UseLimitItems)
				g_i3k_ui_mgr:RefreshUI(eUIID_UseLimitItems, self.id, item_cfg.type)
			else
				g_i3k_ui_mgr:OpenUI(eUIID_UseLimitConsumeItems)
				g_i3k_ui_mgr:RefreshUI(eUIID_UseLimitConsumeItems, self.id, item_cfg.type)
			end
		elseif canAddMaxTimes > 0 and needVipLvl > 0 then
			local fun = (function(ok)
				if ok then
					g_i3k_logic:OpenChannelPayUI()
				end
			end)
			g_i3k_ui_mgr:ShowCustomMessageBox2("升级贵族", "确定", i3k_get_string(289, needVipLvl), fun)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(291))
		end
	else
		-- if needItemId == 0 or needItemCount == 0 then
		if item_cfg.type == UseItemOneTimes then
			g_i3k_ui_mgr:OpenUI(eUIID_UseItems)
			g_i3k_ui_mgr:RefreshUI(eUIID_UseItems, self.id, item_cfg.type)
		elseif needItemId == 0 or needItemCount == 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_UseItems)
			g_i3k_ui_mgr:RefreshUI(eUIID_UseItems, self.id, item_cfg.type)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_UseLimitConsumeItems)
			g_i3k_ui_mgr:RefreshUI(eUIID_UseLimitConsumeItems, self.id, item_cfg.type)
		end
	end
end
-- 79 装备升级卷轴
function wnd_bag_item_info:useItemUpEquipLevel()
	local wEquips = g_i3k_game_context:GetWearEquips()
	local itemCfg= g_i3k_db.i3k_db_get_other_item_cfg(self.id)
	if #wEquips == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(46))
		return false
	else
		for i=1, eEquipJumpLvl do
			if wEquips[i].equip and g_i3k_game_context:GetEquipStrengLevel(i) < itemCfg.args1 then
			local partID = g_i3k_db.i3k_db_get_equip_item_cfg(wEquips[i].equip.equip_id).partID
			g_i3k_ui_mgr:OpenUI(eUIID_UseItemUpEquipLevel)
			g_i3k_ui_mgr:RefreshUI(eUIID_UseItemUpEquipLevel, itemCfg, partID, wEquips[i].equip.equip_id)
			g_i3k_ui_mgr:CloseUI(eUIID_Bag)
			return true
			end
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18554))
		return false
	end
end
--80 势力声望道具
function wnd_bag_item_info:UseItemNewPower()
	if self.count == 1 then
		i3k_sbean.bag_useItemForceFame(self.id, self.count)
	else
		self:openUseItemsUI()
	end
	return true
end
--81 试炼次数道具
function wnd_bag_item_info:UseItemAddActivityTimes()
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
	local needItemId, needItemCount = g_i3k_db.i3k_db_get_day_use_consume_info(self.id)
	local dayUseTimes, canAddMaxTimes, needVipLvl = g_i3k_db.i3k_db_get_day_use_item_day_use_times(self.id)
	if dayUseTimes ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_ActivityAddTimesByItem)
	elseif canAddMaxTimes > 0 and needVipLvl > 0 then
		local fun = (function(ok)
			if ok then
				g_i3k_logic:OpenChannelPayUI()
			end
		end)
		g_i3k_ui_mgr:ShowCustomMessageBox2("升级贵族", "确定", i3k_get_string(289, needVipLvl), fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(291))
	end
end

local useItemTypeTbl =
{
	[UseItemCoin]			= wnd_bag_item_info.useItemCoin,
	[UseItemDiamond]		= wnd_bag_item_info.useItemDiamond,
	[UseItemExp]			= wnd_bag_item_info.useItemExp,
	[UseItemGift]			= wnd_bag_item_info.useItemGift,
	[UseItemHp]				= wnd_bag_item_info.useItemHp,
	[UseItemVipHp]			= wnd_bag_item_info.useItemVipHp,
	[UseItemChest]			= wnd_bag_item_info.useItemChest,
	[UseItemEquipEnergy]	= wnd_bag_item_info.useItemEquipEnergy,
	[UseItemGemEnergy]		= wnd_bag_item_info.useItemGemEnergy,
	[UseItemBookSpiration]	= wnd_bag_item_info.useItemBookSpiration,
	[UseItemVit]			= wnd_bag_item_info.useItemVit,
	[UseItemLibrary]        = wnd_bag_item_info.useItemLibrary,
	[UseItemEmpowerment]	= wnd_bag_item_info.useItemEmpowerment,
	[UseItemCard]			= wnd_bag_item_info.useItemCard,
	[UseItemVipCard]		= wnd_bag_item_info.useItemVipCard,
	[UseItemFeats]			= wnd_bag_item_info.useItemFeats,
	[UseItemEvil]			= wnd_bag_item_info.useItemEvil,
	[UseItemFirework]		= wnd_bag_item_info.useItemFirework,
	[UseItemOneTimes]		= wnd_bag_item_info.useItemOneTimes,
	[UseItemSpirit]			= wnd_bag_item_info.useItemSpirit,
	[UseItemResetTitleTime]	= wnd_bag_item_info.useItemResetTitleTime,
	[UseItemUniqueSkill]	= wnd_bag_item_info.useItemUniqueSkill,
	[UseItemVipExp]			= wnd_bag_item_info.useItemVipExp,
	[UseItemProduceSplitSp]	= wnd_bag_item_info.useItemProduceSplitSp,
	[UseItemBuffDrug]		= wnd_bag_item_info.useItemBuffDrug,
	[UseItemGetEmoji]		= wnd_bag_item_info.useItemGetEmoji,
	[UseItemWeaponSoul]		= wnd_bag_item_info.useWeaponSoul,
	[UseItemGetChatBox]		= wnd_bag_item_info.useChatBox,
	[UseItemHorseBook]      = wnd_bag_item_info.inputHorseBookBag,
	[UseItemEscortCar]      = wnd_bag_item_info.useEscordSkin,
	[UseItemGodEquip]      = wnd_bag_item_info.useGodEquip,
	[UseItemDiaryDecorate]	= wnd_bag_item_info.useDiaryDecorate,
	[UseItemHomeLandEquip]	= wnd_bag_item_info.useHomeLandEquip,
	[UseItemSpiritBoss]		= wnd_bag_item_info.useSpiritBoss,
	[UseItemFurniture]		= wnd_bag_item_info.useItemFurniture,
	[UseItemRegular]        = wnd_bag_item_info.useItemUseItemRegular,
	[UseItemHouseSkin]		= wnd_bag_item_info.useItemHouseSkin,
	[UseItemCardPacket]		= wnd_bag_item_info.useItemCardPacket,
	[UseItemSwornValue]		= wnd_bag_item_info.useItemSwornValue,
	[UseItemSteedEquipSpirit] = wnd_bag_item_info.useItemSteedEquipEnergy,
	[UseItemArrayStone]		= wnd_bag_item_info.useItemArrayStone,
	[UseItemWarZoneCard]	= wnd_bag_item_info.useItemWarZoneCard,
	[useItemUpEquipLevel]	= wnd_bag_item_info.useItemUpEquipLevel,
	[UseItemNewPower]		= wnd_bag_item_info.UseItemNewPower,
	[UseItemAddActivityTimes]	= wnd_bag_item_info.UseItemAddActivityTimes,
}

function wnd_bag_item_info:useAsItem()
	if g_i3k_game_context:GetLevel() >= g_i3k_db.i3k_db_get_common_item_level_require(self.id) then
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.id)
		local func = useItemTypeTbl[item_cfg.type]
		if func and func(self) then
			g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
		else
			local jumpID = g_i3k_db.i3k_db_get_bag_item_jumpUIID(self.id)
			if jumpID then
				g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
				g_i3k_logic:JumpUIID(jumpID)
			end

		end
	else
		g_i3k_ui_mgr:PopupTipMessage("角色所需等级不足")
	end
end

function wnd_bag_item_info:saleButton(sender, isWarehouse)
	if isWarehouse then
		local str = isWarehouse.around == 1 and "取出仓库(测试)" or "存入仓库(测试)"
		--g_i3k_ui_mgr:PopupTipMessage(str)
		g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
		if isWarehouse.around == 1 then
			i3k_sbean.goto_take_out_warehouse(isWarehouse.id, isWarehouse.count, isWarehouse.warehouseType)
		elseif isWarehouse.around == 2 then
			i3k_sbean.goto_put_in_warehouse(isWarehouse.id, isWarehouse.count, isWarehouse.warehouseType)
		end
	else
		g_i3k_ui_mgr:OpenUI(eUIID_SaleItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_SaleItems, self.id, self.count)
		g_i3k_game_context:useItemAtBagRemoveTip(self.id)
		g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
	end
end

function wnd_bag_item_info:combineButton(sender, id)
	g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
	local function callback(isOK)
		if isOK then
			i3k_sbean.bag_merge(id)
		end
	end
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(id) or g_i3k_db.i3k_db_get_book_item_cfg(id) or g_i3k_db.i3k_db_get_gem_item_cfg(id)
	local str = item_cfg and item_cfg.name or ""
	local msg = i3k_get_string(531, str, str)
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end

function wnd_bag_item_info:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_BagItemInfo)
end

function wnd_create(layout)
	local wnd = wnd_bag_item_info.new()
		wnd:create(layout)
	return wnd
end
