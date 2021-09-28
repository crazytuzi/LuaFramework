-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
require("ui/base");
local ui = require("ui/underwear_profile");
-------------------------------------------------------

wnd_underwear_rune = i3k_class("wnd_underwear_rune",ui.wnd_underwear_profile)

local QJ_WIDGETS = "ui/widgets/dj1"
local btnShowTab = { 
	upStage_btn 	= i3k_db_under_wear_alone.underWearUpStageShowLvl,
	talent_btn 		= i3k_db_under_wear_alone.underWearTalentShowLvl,
	fuwen_btn 		= i3k_db_under_wear_alone.underWearRuneShowLvl,
}

function wnd_underwear_rune:ctor()
		self.showType = 1 --第几套插槽
		self.ItemTab = {}
		self.curState = 1
		self._wishIndex = 0 --许愿槽内符文个数
		self._canWish1 = false --判断材料是否充足
		self.runeTab = {} --许愿数据
		self.langIndex = 0
		self.langName = nil
		self.wishRewards = {}
end

function wnd_underwear_rune:configure()
	local widgets = self._layout.vars
	widgets.helpBtn:onClick(self, self.openHelp)
	self.widgets = widgets
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self._layout.vars.gotoBtn:onClick(self,function ()
		g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear)
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear)
		self:onCloseUI()
	end)
	self.scroll = widgets.scroll
	
	self.update_btn = widgets.update_btn  --升级
	self.update_btn:stateToNormal()
	self.update_btn:onClick(self, self.onUpdate_btn)
	
	self.upStage_btn = widgets.upStage_btn  --升阶
	self.upStage_btn:stateToNormal()
	self.upStage_btn:onClick(self, self.onUpStageBtn)--符文
	
	self.talent_btn = widgets.talent_btn
	self.talent_btn:stateToNormal()
	self.talent_btn:onClick(self, self.onTalentBtn)--天赋
	
	self.fuwen_btn = widgets.fuwen_btn
	self.fuwen_btn:stateToPressed()
	
	self.soltUI = widgets.soltUI
	self.WishUI = widgets.WishUI

	self.runeWishBtn= widgets.runeWishBtn
	self.runeWishBtn:onClick(self, self.onRuneWishBtn) --符文许愿
	
	self.aKeySave = widgets.aKeySave
	self.aKeySave:onTouchEvent(self, self.onOneKeySave) --一键存入
	
	self.move_btn = widgets.move_btn 
	
	self.bgImage = widgets.bgImage --背景图
	self.saveRed = widgets.saveRed
	self.langRed = widgets.langRed

	self.talentRp = widgets.talentRp
	self.forgeRp = widgets.forgeRp
	self.upgradeRp = widgets.upgradeRp
	self.runeRp = widgets.runeRp

	self.soltBtnTab = {}
	--第几套插槽	
	self.soltRedPoit = {widgets.oneRed, widgets.twoRed, widgets.threeRed}
	self.soltBtnTab = {widgets.soltbtn1, widgets.soltbtn2, widgets.soltbtn3}
	local soltCfg = i3k_db_under_wear_slot[1]
	for i, v in ipairs(self.soltBtnTab) do
		if g_i3k_game_context:GetLevel() >= soltCfg[i].unlockNeedLvl then
			v:onClick(self, self.onShowTypeChanged, i)
		else
		 	v:hide()
		end
	end
	if self:runeInBag() then
		self.saveRed:show()
	else
		self.saveRed:hide()
	end
	
	self.soltBtnTab[self.showType]:stateToPressed(true)
	self:initLeftSoltData(widgets)
	self:initLeftWishData(widgets)
end

function wnd_underwear_rune:initLeftSoltData(widgets)
	--每套插槽对应的装备符文
	self.wear_runeTab = {}
	for i=1, 6 do  --SoltItem1_bg  SoltItem1_icon SoltItem1_btn
		local SoltItem_bg =  string.format("SoltItem%s_bg",i)
		local SoltItem_icon = string.format("SoltItem%s_icon",i)
		local SoltItem_btn = string.format("SoltItem%s_btn",i)			
		self.wear_runeTab[i] = {SoltItem_bg= widgets[SoltItem_bg],SoltItem_icon= widgets[SoltItem_icon],SoltItem_btn= widgets[SoltItem_btn],}
	end
	self.hero_module = widgets.hero_model
	self.soltAiLiBtn1 = widgets.soltAiLiBtn
	self.star = widgets.star
	self.star:hide()
	self.soltAiLiBtn1:onClick(self, self.onSoltAiLiBtn)
	self.AiliLabel1 = widgets.AiliLabel
	self.AiliLabel1:setText(i3k_get_string(990)) --查看符文之语
	
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
end

function wnd_underwear_rune:updateFuyuLevel(langId)
	--铸锭等级显示
	local data = g_i3k_game_context:getFuYuZhudingData()
	if data[langId] and data[langId].level > 0 then
		self.star:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_under_wear_alone.zhuDingLvStarIcon[data[langId].level]))
		self.star:show()
	else
		self.star:hide()
	end
end

function wnd_underwear_rune:initLeftWishData(widgets)
	--符文许愿
	self.closeWish = widgets.closeWish
	self.closeWish:onClick(self, self.onCloseWish)
	self.wishBtn = widgets.wishBtn --许愿
	self.wishBtn:onClick(self, self.onWishBtn)
	self.wishCloseBtn =  widgets.wishCloseBtn --关闭许愿
	self.wishCloseBtn:onClick(self, self.onCloseWish)
	self.wishCloseBtn:hide()
	--prop
	self.propItem = {itemBg =widgets.item_bg,itemIcon=widgets.item_icon ,itemBtn=widgets.item_btn ,itemName =widgets.itemName,itemCount =widgets.itemCount,itemSuo= widgets.item_suo}
	self:initLefRuneWishData(widgets)
end

function wnd_underwear_rune:initLefRuneWishData(widgets)
	self.rune_wishTab = {}
	for i=1, 6 do  
		local wishItem_bg =  string.format("wishItem_bg%s",i)
		local wishItem_icon = string.format("wishItem_icon%s",i)
		local wishItem_btn= string.format("wishItem_btn%s",i)
		local wishItem_suo= string.format("wishItem_suo%s",i)	
		self.rune_wishTab[i] = {wishItem_bg= widgets[wishItem_bg],wishItem_icon= widgets[wishItem_icon],wishItem_btn= widgets[wishItem_btn],wishItem_haveRune = false,wishItem_suo = widgets[wishItem_suo]}
		local wrbtn =  widgets["rwdBtn"..i]
		self.wishRewards[i] = {bg = widgets["rwdBg"..i], btn = wrbtn, icon = widgets["rwdIcon"..i]}
		wrbtn:onClick(self, self.onWishRuneTips)
		wrbtn:setTag(0)
	end
	self:updateWishRunesData()
end

function wnd_underwear_rune:refresh(index ,tab)
	 --根据内甲id显示背景图
	self:setBgImage(index)
	--打开界面时需要判断等级是否满足显示
	for k,v in pairs(btnShowTab) do
		self.widgets[tostring(k)]:show()
		if g_i3k_game_context:GetLevel() < v then
			self.widgets[tostring(k)]:hide()
		end
	end	
	self.index= index
	self.tab = tab 
	self.ItemTab = {}
	self.curState = 1
	self.soltUI:show()
	self.WishUI:hide()
	self.soltGroupData  = g_i3k_game_context:getAnyUnderWearAnyData(self.index,"soltGroupData")
	self:updateWearRunesData(1)
	self:updateBag(g_i3k_game_context:GetRuneBagInfo())
	self:ShowRedPoint(index, tab)
	self:updateRedPoint(index)
	self:changeRedPoint(self.showType)
	ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(), {id = index, stage = tab.underwear_stage})		
end

--根据内甲id显示背景图
function wnd_underwear_rune:setBgImage(index)
	local bgImageTab = {2701,2702,2703}
	self.bgImage:setImage(i3k_db_icons[bgImageTab[index]].path) 
end

function wnd_underwear_rune:updateWishRunesData()--左侧符文许愿的信息
	--初始化消耗道具
	self.wishNeedItem = {}
	needid = i3k_db_under_wear_alone.runeWishUseProp
	needCount1 = i3k_db_under_wear_alone.runeWishUsePropNums
	local name_color = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needid))
	local itemCount1 = g_i3k_game_context:GetCommonItemCanUseCount(needid)
	--self.propItem.itemName:setText(g_i3k_db.i3k_db_get_common_item_name(needid))
	--self.propItem.itemName:setTextColor(name_color)
	self.propItem.itemCount:setText(itemCount1.."/"..needCount1)
	self.propItem.itemCount:setTextColor(g_i3k_get_cond_color(needCount1<=itemCount1))
	self._canWish1 = needCount1 <= itemCount1
	self.propItem.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needid))
	self.propItem.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needid,i3k_game_context:IsFemaleRole()))
	self.propItem.itemBtn:onClick(self, function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(needid)
	end)
	self.propItem.itemSuo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(needid))	
	self.wishNeedItem = {itemid =needid,count = needCount1}
end

function wnd_underwear_rune:updateWearRunesData(slotTag)--左侧已穿装备的信息
	--默认显示第一个插槽的符文装备
	
	self.soltGroupData  = g_i3k_game_context:getAnyUnderWearAnyData(self.index,"soltGroupData")
	local data = self.soltGroupData[slotTag]
	for k,v in ipairs(data.solts) do
		if v~=0 then
			self.wear_runeTab[k].SoltItem_icon:show()
			self.wear_runeTab[k].SoltItem_btn:show()
			-- self.wear_runeTab[k].SoltItem_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
			self.wear_runeTab[k].SoltItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v,i3k_game_context:IsFemaleRole()))
			self.wear_runeTab[k].SoltItem_btn:onClick(self, self.onUnloadItem,{slotTag = slotTag,slotIndex = k,runeid = v})--长按按钮	
		else
			-- self.wear_runeTab[k].SoltItem_bg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
			self.wear_runeTab[k].SoltItem_icon:hide()
			self.wear_runeTab[k].SoltItem_btn:hide()
		end
	end
	self.langName ,self.langIndex= self:getRuneLangData(data.solts)

	if self.langName then
		local lvl = g_i3k_game_context:getRuneLangLevel(self.langIndex)
		self.AiliLabel1:setText(lvl == 0 and self.langName or self.langName.."·"..i3k_db_rune_lang_upgrade[self.langIndex][lvl].lvlName)
	else
		self.AiliLabel1:setText(i3k_get_string(990))	 --查看符文之语
	end
	self:updateFuyuLevel(self.langIndex)
	self:upgradeLangRed()
end

function wnd_underwear_rune:updateLangLabel(langId)
	if self.langIndex == langId then
		local lvl = g_i3k_game_context:getRuneLangLevel(langId)
		self.AiliLabel1:setText(lvl == 0 and self.langName or self.langName.."·"..i3k_db_rune_lang_upgrade[langId][lvl].lvlName)
	end
	self:updateFuyuLevel(self.langIndex)
	self:upgradeLangRed()
end

function wnd_underwear_rune:onSoltAiLiBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_Rune_Lang)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Rune_Lang, self.index, self.showType,self.langIndex)
end

function wnd_underwear_rune:getRuneLangData(slotData)
	local rnId = g_i3k_db.i3k_db_get_rune_word(slotData)
	if rnId > 0 then
		local cfg = i3k_db_under_wear_rune_lang[rnId]
		return cfg.runeLangName, rnId
	end
	return nil, 0
end

function wnd_underwear_rune:setData()
	self.curState = 1
	self:updateBag(g_i3k_game_context:GetRuneBagInfo())
	if self:runeInBag() then
		self.saveRed:show()
	else
		self.saveRed:hide()
	end
end

function wnd_underwear_rune:updateBag(bagSize, BagItems) -- 右侧scroll 物品信息的遍历并排序
	self.scroll:removeAllChildren()
	local items ,totalCellNum= self:itemSort(BagItems)
	--local widgetCount = math.ceil(totalCellNum/5) *5 --符文背包界面，不需要显示空白的格子

	local all_layer = self.scroll:addChildWithCount(QJ_WIDGETS,5,totalCellNum)
	local cell_index = 1
	for i=1 ,totalCellNum do
		local widget = all_layer[i].vars
		widget.item_count:hide()
	end
	for i,e in ipairs(items) do
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
		local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
		for k=1,cell_count do
			local widget = all_layer[cell_index].vars
			local itemCount = k == cell_count and e.count-(cell_count-1)*stack_count or stack_count
			self:updateCell(widget, e.id, itemCount,cell_index)
			--self:setUpIsShow(e.id, e.guids[k], widget)
			cell_index = cell_index + 1
		end
	end
end

function wnd_underwear_rune:updateCell(widget, id, count ,index)
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widget.item_count:setText(count)
	if count <= 0 then
		widget.item_count:hide()
	else
		widget.item_count:show()
	end
	widget.suo:setVisible(id>0)
	widget.bt:setTag(1000+index)
	self.ItemTab[index] = {is_select = widget.is_select, id = id}
	if self.curState ==1 then
		--widget.bt:onTouchEvent(self, self.onRuneMove)
		widget.bt:onClick(self, self.onRuneTips)
	else
		widget.bt:onClick(self, self.onRuneWish,{is_select = widget.is_select, id = id})
	end	
end

function wnd_underwear_rune:setUpIsShow(id, guid, widget)
	if g_i3k_db.i3k_db_get_common_item_type(id) == g_COMMON_ITEM_TYPE_EQUIP then
		local equip_cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
		if g_i3k_game_context:GetRoleType() == equip_cfg.roleType or equip_cfg.roleType == 0 then
			local equip = g_i3k_game_context:GetBagEquip(id, guid)
			local wearEquips = g_i3k_game_context:GetWearEquips()
			local _data = wearEquips[equip_cfg.partID].equip
			if _data then
				local wAttribute = _data.attribute
				local wNaijiu = _data.naijiu
				local wEquip_id = _data.equip_id
				local wPower = g_i3k_game_context:GetBagEquipPower(wEquip_id,wAttribute,wNaijiu,_data.refine,_data.legends, _data.smeltingProps)
				local total_power = g_i3k_game_context:GetBagEquipPower(id,equip.attribute,equip.naijiu,equip.refine,equip.legends, equip.smeltingProps)
				widget.isUp:show()
				if wPower > total_power then
					widget.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				elseif wPower < total_power then
					widget.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				else
					widget.isUp:hide()
				end
			else
				widget.isUp:show()
				widget.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
			end
			
		end
	end
end

--背包物品排序  i3k_db_get_icon_path获取图标路径
function wnd_underwear_rune:itemSort(items)
	local sort_items = {}
	local totalCellNum =0 
	for k,v in pairs(items) do
		local sorit = g_i3k_db.i3k_db_get_bag_item_order(k) + (k > 0 and 0 or -0.2)
		local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(k)
		local cell_count = g_i3k_get_use_bag_cell_size(v, stack_count)
		totalCellNum = totalCellNum +cell_count
		table.insert(sort_items, { sortid = sorit, id = k, count = v})
	end
	table.sort(sort_items,function (a,b)
		return a.sortid < b.sortid
	end)
	return sort_items,totalCellNum
end

function wnd_underwear_rune:setSlotData(showType)
	self:setBagShowType(showType)
	self:changeRedPoint(showType)
end
function wnd_underwear_rune:setBagShowType(showType)
	if self.showType ~= showType then
		if self.soltGroupData[showType].unlocked ==1 then
			self.showType = showType
			for i, v in ipairs(self.soltBtnTab) do
				v:stateToNormal(true)
			end
			self.soltBtnTab[showType]:stateToPressed(true)
			--插槽显示也要变
			self:updateWearRunesData(showType)
			self:changeRedPoint(showType)
		else
			--todo 此套插槽需要解锁
			g_i3k_logic:OpenRuneSoltUnlock(self.index,showType)		
		end
	end
end

function wnd_underwear_rune:onShowTypeChanged(sender, tag)
	self:setBagShowType(tag)
end

--点击装备Item
function wnd_underwear_rune:onUnloadItem(sender, items)
	g_i3k_ui_mgr:OpenUI(eUIID_RuneBagItemInfo)
	--todo 发协议 内甲id 插槽id 槽内id  符文id
	local tab = { underWear = self.index ,slotGroupIndex = self.showType , slotIndex = items.slotIndex,runeId = items.runeid}
	g_i3k_ui_mgr:RefreshUI(eUIID_RuneBagItemInfo,self.index ,self.showType,items.runeid ,2,tab)
end

--点击背包Item
function wnd_underwear_rune:onRuneTips(sender)
	local tag = sender:getTag()- 1000
	self.tag = tag
	self:setCellIsSelectHide()
	local tab =self.ItemTab[self.tag]
	tab.is_select:show()
	g_i3k_ui_mgr:OpenUI(eUIID_RuneBagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_RuneBagItemInfo,self.index,self.showType, tab.id ,1)
	
end

function wnd_underwear_rune:setCellIsSelectHide()
	for i, e in ipairs(self.scroll:getAllChildren()) do
		e.vars.is_select:hide()
	end
end

function wnd_underwear_rune:onUpdate_btn() --升级
	g_i3k_logic:OpenUnderWearUpdate(self.index,self.tab)
	self:onCloseUI()
end

function wnd_underwear_rune:onUpStageBtn()--升阶
	--升阶
	local canOpen ,level = g_i3k_game_context:isCanOpenUI(1)
	if canOpen then
		g_i3k_logic:OpenUnderWearUpStage(self.index,self.tab)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(805,string.format("%s",level)))
	end
end

function wnd_underwear_rune:onTalentBtn() --天赋
	--天赋
	local canOpen ,level = g_i3k_game_context:isCanOpenUI(2)
	if canOpen then
		g_i3k_logic:OpenUnderWearTalent(self.index,self.tab)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(806,level))
	end
end

function wnd_underwear_rune:onOneKeySave(sender, eventType) -- 一键存入
	if eventType == ccui.TouchEventType.began then
		local runeItemTab = {}
		local _canSave, runeItemTab = self:runeInBag()
		
		if _canSave then
			i3k_sbean.pushRune(runeItemTab) 
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(991)) --没有可以存入的符文
		end
	end	
end

function wnd_underwear_rune:onRuneWishBtn(sender) -- 符文许愿
	self.soltUI:hide()
	self.WishUI:show()
	self.wishCloseBtn:show()
	self.aKeySave:hide()
	self.curState = 2
	self:setRuneBagWishData(1)
end	

function wnd_underwear_rune:onCloseWish(sender) -- 关闭符文许愿
	self.soltUI:show()
	self.WishUI:hide()
	self.wishCloseBtn:hide()
	self.aKeySave:show()
	self.curState = 1
	self._wishIndex = 0 --许愿槽内符文个数
	self._canWish1 = false --判断材料是否充足
	self.runeTab = {} --许愿数据
	self:wishRefresh()
	self:updateBag(g_i3k_game_context:GetRuneBagInfo())
end	

function wnd_underwear_rune:onRuneWish(sender,tab)
	--tab.id
	--设置左侧符文许愿数据展示
	--设置符文背包数据
	--设置符文背包数据
	if i3k_db_under_wear_rune[math.abs(tab.id)].canWish == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(992)) --该符文为高级符文无法许愿
	end
	if self._wishIndex < i3k_db_under_wear_alone.fuwenVowMaxCount then
		g_i3k_game_context:setRuneWishChangeData(tab.id ,1,true) --记录改变
		self:setRuneBagWishData(2)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(993,i3k_db_under_wear_alone.fuwenVowMaxCount)) --开始许愿吧
	end
	for i=1,6 do
		if not self.rune_wishTab[i].wishItem_haveRune then
			self._wishIndex = self._wishIndex +1
			self.rune_wishTab[i].wishItem_haveRune = true
			self.rune_wishTab[i].wishItem_icon:show()
			self.rune_wishTab[i].wishItem_btn:show()
			self.rune_wishTab[i].wishItem_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(tab.id))
			self.rune_wishTab[i].wishItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(tab.id,i3k_game_context:IsFemaleRole()))
			self.rune_wishTab[i].wishItem_btn:onClick(self, self.onUnloadWishRune,{wishIndex = i,wishId = tab.id})--长按按钮
			self.rune_wishTab[i].wishItem_suo:setVisible(tab.id>0)
			if self.runeTab[tab.id] then
				--i3k_log("jxw---------------"..self.runeTab[tab.id])
				self.runeTab[tab.id] = self.runeTab[tab.id] +1
			else
				self.runeTab[tab.id] = 1
			end
			if self._wishIndex >= i3k_db_under_wear_alone.fuwenVowMinCount then
				self:updateCanReward(self.runeTab)
			end
			return
		end
	end
	
end

function wnd_underwear_rune:updateCanReward(wishRunes)
	local value = 0
	local cfg = i3k_db_under_wear_rune

	for id, count in pairs(wishRunes) do
		value = value + cfg[math.abs(id)].vowWeight * count
	end
	cfg = i3k_db_under_wear_rune_wish
	local size = #cfg
	for i = 1 , size do
		if value < cfg[i].power then
			cfg = cfg[i-1]
			break
		elseif i == size then
			cfg = cfg[i]
			break
		end
	end

	for i,v in ipairs(cfg.items) do
		local node = self.wishRewards[i]
		if v > 0  then
			node.icon:show()
			node.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
			node.btn:setTag(v)
			node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v,i3k_game_context:IsFemaleRole()))
		else
			node.icon:hide()
			node.btn:setTag(0)
			node.bg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
		end
	end
end

function wnd_underwear_rune:clearWishRewardUI()
	for i,v in ipairs(self.wishRewards) do
		v.btn:setTag(0)
		v.icon:hide()
		v.bg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
	end
end

function wnd_underwear_rune:onWishRuneTips(sender, itemId)
	local itemId = sender:getTag()
	if itemId == 0 then
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_RuneBagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_RuneBagItemInfo, nil, nil,  itemId, 3)
end

function wnd_underwear_rune:onUnloadWishRune(sender,tab)
	--许愿卸下
	if self._wishIndex>0 then
		self._wishIndex = self._wishIndex -1
	end
	if self.runeTab[tab.wishId] ==1 then
		self.runeTab[tab.wishId] =nil
	else
		self.runeTab[tab.wishId] = self.runeTab[tab.wishId] -1
	end
	self.rune_wishTab[tab.wishIndex].wishItem_bg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
	self.rune_wishTab[tab.wishIndex].wishItem_icon:hide()
	self.rune_wishTab[tab.wishIndex].wishItem_btn:hide()
	self.rune_wishTab[tab.wishIndex].wishItem_suo:hide()
	self.rune_wishTab[tab.wishIndex].wishItem_haveRune = false
	g_i3k_game_context:setRuneWishChangeData(tab.wishId ,1,false)
	self:setRuneBagWishData(2)
	if self._wishIndex >= 3 then
		self:updateCanReward(self.runeTab)
	else
		self:clearWishRewardUI()
	end
end	

function wnd_underwear_rune:setRuneBagWishData(index)
	self.curState = 2
	if index ==1 then
		g_i3k_game_context:setRuneWishData() --设置临时数据
		self:updateBag( g_i3k_game_context:getRuneWishData())	
	elseif index ==2 then		
		self:updateBag( g_i3k_game_context:getRuneWishData())	
	elseif index ==3 then
		
	end
	
end

function wnd_underwear_rune:onWishBtn(sender)
	--许愿
	if self._wishIndex<i3k_db_under_wear_alone.fuwenVowMinCount then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(995,i3k_db_under_wear_alone.fuwenVowMinCount)) --最少投入3个符文
		return
	end
	if  not self._canWish1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(994)) --材料不足，无法许愿
		return
	end
	i3k_sbean.runeWish(self.runeTab,self.wishNeedItem)
end	

function wnd_underwear_rune:wishRefresh()
	self._wishIndex = 0
	self.runeTab = {} --许愿数据
	self._canWish1 = false --判断材料是否充足
	for i=1, 6 do  
		self.rune_wishTab[i].wishItem_bg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
		self.rune_wishTab[i].wishItem_icon:hide()
		self.rune_wishTab[i].wishItem_btn:hide()
		self.rune_wishTab[i].wishItem_suo:hide()
		self.rune_wishTab[i].wishItem_haveRune = false
	end
	self:updateWishRunesData()
	self:clearWishRewardUI()
end

function wnd_underwear_rune:changeRedPoint(showType)
	if showType then
		local curr = self:getRuneRedPointData(self.index)
		if curr[self.showType] ~= 1 then
			self:changeRuneNeedRed(self.index ,showType)
			self.soltRedPoit[showType]:hide()
		else
			return
		end
	end
	local allRed, langRed = self:getUnderWearRuneNeedRed(self.index)
	--self.langRed:setVisible(langRed)
	if allRed then
		self.runeRp:show()
	else
		self.runeRp:hide()
	end
end

function wnd_underwear_rune:updateRedPoint(index)
	local curr = self:getRuneRedPointData(index)
	for i , v in ipairs(self.soltRedPoit) do
		if curr[i] == 0 then
			v:show()
		else
			v:hide()
		end
	end
end

function wnd_underwear_rune:upgradeLangRed()
	local visible = false
	if self.langIndex > 0 then
		local nextLvl = g_i3k_game_context:getRuneLangLevel(self.langIndex) + 1
		local v = i3k_db_under_wear_rune_lang[self.langIndex]
		local items = {v.slotRuneId1, v.slotRuneId2, v.slotRuneId3, v.slotRuneId4, v.slotRuneId5, v.slotRuneId6}
		if g_i3k_game_context:getUpLangRuneEnough(self.langIndex, nextLvl, items) then
			visible = true
		end
	end
	self.langRed:setVisible(visible)
end

function wnd_underwear_rune:getRuneRedPointData(underwearIndex)
	local RedPoint = g_i3k_game_context:getRuneRedTip()
	return RedPoint[underwearIndex]
end

function wnd_underwear_rune:changeRuneNeedRed(underwearIndex, runeIndex)
	local RedPoint = g_i3k_game_context:getRuneRedTip()
	RedPoint[underwearIndex][runeIndex] = 1
end

function wnd_underwear_rune:openHelp()
	g_i3k_ui_mgr:OpenUI(eUIID_Help)
	g_i3k_ui_mgr:RefreshUI(eUIID_Help,i3k_get_string(982))
end

function wnd_create(layout)
	local wnd = wnd_underwear_rune.new()
	wnd:create(layout)
	return wnd
end
