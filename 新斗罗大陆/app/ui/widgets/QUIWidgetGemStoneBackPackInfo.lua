--
-- Author: xurui
-- Date: 2016-07-25 17:01:57
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemStoneBackPackInfo = class("QUIWidgetGemStoneBackPackInfo", QUIWidget)

local QUIWidgetGemStonePieceBox = import("..widgets.QUIWidgetGemStonePieceBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetGemstoneBackPackDetail = import("..widgets.QUIWidgetGemstoneBackPackDetail")
local QUIViewController = import("...ui.QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QActorProp = import("...models.QActorProp")
local QUIDialogHeroGemstoneDetail = import("..dialogs.QUIDialogHeroGemstoneDetail")

QUIWidgetGemStoneBackPackInfo.CLICK_COMPOSE = "CLICK_COMPOSE"

function QUIWidgetGemStoneBackPackInfo:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_Packsack.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerCompose", callback = handler(self, self._onTirggerCompose)},
		{ccbCallbackName = "onTriggerRecyle", callback = handler(self, self._onTirggerRecyle)},
	}
	QUIWidgetGemStoneBackPackInfo.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
    self._equipState = false
end

function QUIWidgetGemStoneBackPackInfo:onEnter()
    self:setScrollView()

end

function QUIWidgetGemStoneBackPackInfo:onExit()
end

function QUIWidgetGemStoneBackPackInfo:setScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	if self._scrollView == nil then
		self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {sensitiveDistance = 10})
		self._scrollView:setVerticalBounce(true)
	end
end

function QUIWidgetGemStoneBackPackInfo:onEvent()
	self:setItemId(self._itemId, self._selectTab, self._stoneInfo)
end

function QUIWidgetGemStoneBackPackInfo:setItemId(itemId, selectTab, stoneInfo)
	self._itemId = itemId
	self._selectTab = selectTab
	self._stoneInfo = stoneInfo

	local stoneProp = {}
	local suit = {}

	local gemQuality = nil
	if self._stoneInfo then
		local itemId , quality , iconPath = remote.gemstone:getGemstoneTransferInfoByData(self._stoneInfo)
		self._itemId = itemId
		gemQuality = quality
	end

	-- set item info
	local itemInfo = db:getItemByID(self._itemId)

	if itemInfo == nil then return end
	if gemQuality == nil then
		gemQuality = itemInfo.gemstone_quality
	end



	if self._stoneItem == nil then
		self._stoneItem = QUIWidgetGemstonesBox.new()
		self._ccbOwner.node_icon:addChild(self._stoneItem)
	end
	if self._pieceItem == nil then
		self._pieceItem = QUIWidgetGemStonePieceBox.new()
		self._ccbOwner.node_icon:addChild(self._pieceItem)
	end
	if self._selectTab == "TAB_GEMSTONE" then
		self._stoneInfo = stoneInfo
		stoneProp = stoneInfo.prop

		self._stoneItem:setGemstoneInfo(stoneInfo)
		self._stoneItem:setVisible(true)
		self._pieceItem:setVisible(false)
		suit = remote.gemstone:getSuitByItemId(self._itemId)

		local mixConfig = db:getGemstoneMixConfigByIdAndLv(stoneInfo.itemId , stoneInfo.mix_level or 0) or {}
		local refineConfig = db:getRefineConfigByIdAndLevel(stoneInfo.itemId , stoneInfo.refine_level or 0) or {}
		stoneProp = self:addProp(mixConfig, stoneProp)
		stoneProp = self:addProp(refineConfig, stoneProp)

		if stoneInfo.actorId ~= nil then
			local heroInfo = db:getCharacterByID(stoneInfo.actorId)
			self._ccbOwner.tf_num:setString(heroInfo.name.."装备")
			self._equipState = true
		else
			self._ccbOwner.tf_num:setString("未装备")
			self._equipState = false
		end
		self._ccbOwner.tf_content:setString("状态:")

		self._ccbOwner.node_money:setVisible(false)
	elseif self._selectTab == "TAB_PIECE" then

		self._pieceItem:setGoodsInfo(self._itemId, ITEM_TYPE.GEMSTONE_PIECE, 0, false)
		self._stoneItem:setVisible(false)
		self._pieceItem:setVisible(true)

		local info = remote.gemstone:getStoneCraftInfoByPieceId(self._itemId)
		local item = db:getGemstoneBreakThroughByLevel(info.item_id, 0) or {}
		local getstoneInfo = db:getItemByID(info.item_id)
		local config = db:getEnhanceDataByEquLevel(getstoneInfo.enhance_data, 1) or {}
		stoneProp = self:addProp(item, config)
		
		suit = remote.gemstone:getSuitByItemId(info.item_id)

		self._ccbOwner.tf_content:setString("拥有:")
		local itemNum = remote.items:getItemsNumByID(self._itemId)
		self._ccbOwner.tf_num:setString(itemNum or 0)

		self._ccbOwner.node_money:setVisible(true)
		self._ccbOwner.tf_money:setString(info.price or 0)
		if info.price > remote.user.money then
			self._ccbOwner.tf_money:setColor(UNITY_COLOR_LIGHT.red)
		else
			self._ccbOwner.tf_money:setColor(ccc3(66, 13, 0))
		end
	end

	local itemType = remote.gemstone:getTypeDesc(itemInfo.gemstone_type)
	self._ccbOwner.tf_type:setString(itemType or "")
	self._ccbOwner.tf_name:setString(itemInfo.name or "")
	
	local fontColor = BREAKTHROUGH_COLOR_LIGHT[remote.gemstone:getSABC(gemQuality).color]
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

	stoneProp = self:setPiecePropInfo(stoneProp)
	self:setDetailInfo(stoneProp, suit , gemQuality)
	self:setBtnState()

	self:checkRedTip()
end

function QUIWidgetGemStoneBackPackInfo:setDetailInfo(stoneProp , suit , gemQuality)
	self._scrollView:runToTop()

	if self._detailInfo == nil then
		self._detailInfo = QUIWidgetGemstoneBackPackDetail.new()
		self._scrollView:addItemBox(self._detailInfo)
	end
	self._detailInfo:setPosition(ccp(180, -220))
	self._detailInfo:setDetailInfo(stoneProp, suit , false , gemQuality)
	local contentSize = self._detailInfo:getContentSize()
	self._scrollView:setRect(0, -contentSize.height, 0, contentSize.width)

end

function QUIWidgetGemStoneBackPackInfo:setBtnState()
	if self._selectTab == "TAB_GEMSTONE" then
		if self._equipState then
			self._ccbOwner.tf_compose:setString("查 看")
			-- self._ccbOwner.button_compose:setEnabled(true)
			-- makeNodeFromGrayToNormal(self._ccbOwner.btn_compose)
			-- makeNodeFromGrayToNormal(self._ccbOwner.btn_recyle)
		else
			self._ccbOwner.tf_compose:setString("装 备")
			-- self._ccbOwner.button_compose:setEnabled(true)
			-- makeNodeFromGrayToNormal(self._ccbOwner.btn_compose)
			-- makeNodeFromGrayToNormal(self._ccbOwner.btn_recyle)
		end
	else
		self._ccbOwner.tf_compose:setString("合 成")
		-- self._ccbOwner.button_compose:setEnabled(true)
		-- makeNodeFromGrayToNormal(self._ccbOwner.btn_compose)
		-- makeNodeFromGrayToNormal(self._ccbOwner.btn_recyle)
	end
end

function QUIWidgetGemStoneBackPackInfo:checkRedTip()
	local isShowTips = false
	if self._selectTab == "TAB_PIECE" then
		local stoneInfo = remote.gemstone:getStoneCraftInfoByPieceId(self._itemId)
		isShowTips = remote.items:getItemsNumByID(self._itemId) >= stoneInfo.component_num_1 and remote.user.money > stoneInfo.price
	end
	self._ccbOwner.compose_tips:setVisible(isShowTips)
end

function QUIWidgetGemStoneBackPackInfo:addProp(prop1, prop2)
	local propInfo = {}
	for name,filed in pairs(QActorProp._field) do
		if prop1[name] ~= nil or prop2[name] ~= nil then
			local num = (prop1[name] or 0) + (prop2[name] or 0)
			if num  > 0 then
				if propInfo[name] == nil then
					propInfo[name] = num
				else
					propInfo[name] = propInfo[name] +num
				end
			end

		end
	end
	return propInfo
end 


function QUIWidgetGemStoneBackPackInfo:setPiecePropInfo(itemInfo)

	local prop = remote.gemstone:setPropInfo(itemInfo,true,true, true)
	-- local index = 1
	-- if itemInfo.attack_value and itemInfo.attack_value > 0 then
	-- 	prop[index] = {}
	-- 	prop[index].value = itemInfo.attack_value
	-- 	prop[index].name = "攻击"
	-- 	index = index + 1
	-- end
	-- if itemInfo.attack_percent and itemInfo.attack_percent > 0 then
	-- 	prop[index] = {}
	-- 	prop[index].value = (itemInfo.attack_percent * 100).."%"
	-- 	prop[index].name = "攻击"
	-- 	index = index + 1
	-- end
	-- if itemInfo.hp_value and itemInfo.hp_value > 0 then
	-- 	prop[index] = {}
	-- 	prop[index].value = itemInfo.hp_value
	-- 	prop[index].name = "生命"
	-- 	index = index + 1
	-- end
	-- if itemInfo.hp_percent and itemInfo.hp_percent > 0 then
	-- 	prop[index] = {}
	-- 	prop[index].value = (itemInfo.hp_percent * 100).."%"
	-- 	prop[index].name = "生命"
	-- 	index = index + 1
	-- end
	-- if itemInfo.armor_physical and itemInfo.armor_physical > 0 then
	-- 	prop[index] = {}
	-- 	prop[index].value = itemInfo.armor_physical
	-- 	prop[index].name = "物防"
	-- 	index = index + 1
	-- end
	-- if itemInfo.armor_physical_percent and itemInfo.armor_physical_percent > 0 then
	-- 	prop[index] = {}
	-- 	prop[index].value = (itemInfo.armor_physical_percent * 100).."%"
	-- 	prop[index].name = "物防"
	-- 	index = index + 1
	-- end
	-- if itemInfo.armor_magic and itemInfo.armor_magic > 0 then
	-- 	prop[index] = {}
	-- 	prop[index].value = itemInfo.armor_magic
	-- 	prop[index].name = "法防"
	-- 	index = index + 1
	-- end
	-- if itemInfo.armor_magic_percent and itemInfo.armor_magic_percent > 0 then
	-- 	prop[index] = {}
	-- 	prop[index].value = (itemInfo.armor_magic_percent * 100).."%"
	-- 	prop[index].name = "法防"
	-- 	index = index + 1
	-- end

	return prop 
end 

function QUIWidgetGemStoneBackPackInfo:_onTirggerRecyle(e)
	if q.buttonEventShadow(e, self._ccbOwner.button_recyle) == false then return end
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	if app.unlock:getUnlockGemStone(true) == false then
		return
	end
	if self._selectTab == "TAB_GEMSTONE" then
		if self._equipState == false then
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroReborn", 
				options = {tab = "gemRecycle", gemStone = self._stoneInfo}})
		else
			app.tip:floatTip("装备中无法回收")
		end
	else
		if remote.items:getItemsNumByID(self._itemId) <= 0 then
			app.tip:floatTip("没有碎片可以回收")
			return 
		end
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroReborn", 
			options = {tab = "gemFragment", itemId = self._itemId}})
	end
end

function QUIWidgetGemStoneBackPackInfo:_onTirggerCompose(e)
	if q.buttonEventShadow(e, self._ccbOwner.button_compose) == false then return end
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	if app.unlock:getUnlockGemStone(true) == false then
		return
	end

	if self._selectTab == "TAB_GEMSTONE" then
		-- local heros = {10021}
		if self._equipState then
			local gemstonePos = 1
			local heroInfo = remote.herosUtil:getHeroByID(self._stoneInfo.actorId)
			local heros = remote.herosUtil:getHaveHero()
			local pos = 1
			for i = 1, #heros do
				if heros[i] == self._stoneInfo.actorId then
					pos = i
					break
				end
			end
			for index,gemstone in ipairs(heroInfo.gemstones) do
				if gemstone.sid == self._stoneInfo.sid then
					gemstonePos = gemstone.position
				end
			end
	        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroGemstoneDetail", 
	            options = {gemstonePos = gemstonePos, heros = heros, pos = pos, initTab = QUIDialogHeroGemstoneDetail.TAB_DETAIL}})
			return 
		else
			local heroId = self:checkHeroGemstone(self._stoneInfo.gemstoneType)
			if heroId == nil then
				app.tip:floatTip("当前没有魂师可以装备此魂骨")
				return
			end
			local heros = remote.herosUtil:getHaveHero()
			local pos = 1
			for i = 1, #heros do
				if heros[i] == heroId then
					pos = i
					break
				end
			end
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
				options = {hero = heros, pos = pos, isQuickWay = true, swtichState = true}})
		end
	else
		local stoneInfo = remote.gemstone:getStoneCraftInfoByPieceId(self._itemId)
		if stoneInfo.item_id == nil then return end

		if stoneInfo.component_num_1 > remote.items:getItemsNumByID(self._itemId) then
			QQuickWay:addQuickWay(QQuickWay.SYNTHETIC_DROP_WAY, stoneInfo.item_id, nil, nil, false)
			return 
		end
		if stoneInfo.price > remote.user.money then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
			return 
		end

		self:setItemId(self._itemId, self._selectTab)
		self:dispatchEvent({name = QUIWidgetGemStoneBackPackInfo.CLICK_COMPOSE, sid = stoneInfo.item_id})
	end
end

function QUIWidgetGemStoneBackPackInfo:checkHeroGemstone(gemstoneType)
	local heroInfos, count = remote.herosUtil:getMaxForceHeros()
	for i = 1, #heroInfos do
		local heroModel = remote.herosUtil:getUIHeroByID(heroInfos[i].id)
		if heroModel:checkGemstoneCanWear(gemstoneType) then
			return heroInfos[i].id
		end
	end
	return nil
end

return QUIWidgetGemStoneBackPackInfo