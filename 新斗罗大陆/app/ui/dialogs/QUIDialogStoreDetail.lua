local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStoreDetail = class("QUIDialogStoreDetail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QShop = import("...utils.QShop")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QColorLabel = import("...utils.QColorLabel")

QUIDialogStoreDetail.ITEM_SELL_SCCESS = "ITEM_SELL_SCCESS"
QUIDialogStoreDetail.ITEM_SELL_FAIL = "ITEM_SELL_FAIL"

function QUIDialogStoreDetail:ctor(options)
	local ccbFile = "ccb/Widget_BuyItem.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSell", callback = handler(self, self._onTriggerSell)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerHeroDetail", callback = handler(self, self._onTriggerHeroDetail)},
		{ccbCallbackName = "onTriggerGenre", callback = handler(self, self._onTriggerGenre)}
	}
	QUIDialogStoreDetail.super.ctor(self, ccbFile, callBacks, options)

	self._ccbOwner.frame_tf_title:setString("购  买")

	self.isAnimation = true
	self.isSell = false
	
	q.setButtonEnableShadow(self._ccbOwner.button_sell)
	if options ~= nil then
		self._shopId = options.shopId
		self._itemInfo = options.itemInfo
		self._position = options.position
		self._index = options.index
		self._isCombination = options.isCombination
	end

	self._wallet = 0
	self:resetAll()
	self:setInfo()
end

function QUIDialogStoreDetail:viewAnimationOutHandler()
	if self.isSell == true then
		if self._itemInfo.id == nil then
			self._itemInfo.id = 0
		end
		app:getClient():buyShopItem(self._shopId, self._itemInfo.position, self._itemInfo.id, self._itemInfo.count, 1, function(data)
			if remote.stores:checkMystoryStoreTimeOut(self._shopId) == false then
				return
			else
				QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = remote.stores.SHOP_ITEM_BUY_SCCESS, index = self._index})
				-- self:openPackageSucceed()
				app.tip:floatTip("购买成功")
			end

			if self._shopId == SHOP_ID.soulShop then
				remote.user:addPropNumForKey("c_soulShopConsumeCount")
        		remote.activity:updateLocalDataByType(525, 1)
        	elseif self._shopId == SHOP_ID.thunderShop then
        		app.taskEvent:updateTaskEventProgress(app.taskEvent.THUNDER_STORE_BUY_TASK_EVENT, 1)
			end
		end,
		function(data)
		end)
	end
	self:removeSelfFromParent()
end

function QUIDialogStoreDetail:openPackageSucceed( ... )
	local awards = {}
	awards[1] = {id = self._itemInfo.id, typeName = self._itemInfo.itemType, count = self._itemInfo.count}

	-- app.tip:awardsTip(awards,"恭喜您获得奖励", function ()end)
	app.tip:floatTip("购买成功")
	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	-- 	options = {awards = awards}},{isPopCurrentDialog = true} )
end

function QUIDialogStoreDetail:resetAll()
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_num:setString(0)
	self._ccbOwner.tf_introduce:setString("")
	self._ccbOwner.tf_money:setString(0)
	self._ccbOwner.node_genre:setVisible(false)
end

function QUIDialogStoreDetail:setInfo()
	self._itemConfig = nil
	local name = ""
	if self._itemInfo.itemType == "soul_gem" then self._itemInfo.itemType = "item" end
	if self._itemInfo.itemType == "item" then
		self._itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemInfo.id)
		if self._itemConfig == nil then return end
		name = self._itemConfig.name
		self._itemNum = remote.items:getItemsNumByID(self._itemInfo.id)
	else
		self._itemConfig = remote.items:getWalletByType(self._itemInfo.itemType)
		name = self._itemConfig.nativeName
		self._itemNum = remote.user[self._itemConfig.name]
	end

	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemInfo.id)
	local widgets = "QUIWidgetItemsBox"
	if itemInfo ~= nil and itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE then
		widgets = "QUIWidgetGemstonesBox"
	elseif itemInfo ~= nil and itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
		widgets = "QUIWidgetGemStonePieceBox"
	end
	local widgetClass = import(app.packageRoot .. ".ui.widgets." .. widgets)
	local itemBox = widgetClass.new()
	self._ccbOwner.node_icon:addChild(itemBox)
	if itemInfo ~= nil and itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE then
        itemBox:setItemId(self._itemInfo.id)
        itemBox:setBreakLevel(0)
        itemBox:setStrengthen(1)
		itemBox:setQuality(remote.gemstone:getSABC(itemInfo.gemstone_quality).lower)
	elseif itemInfo ~= nil and itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
		itemBox:setGoodsInfo(self._itemInfo.id, ITEM_TYPE.GEMSTONE_PIECE, self._itemInfo.count, true, false)
	else
		itemBox:setGoodsInfo(self._itemInfo.id, self._itemInfo.itemType, self._itemInfo.count)
	end
	if widgets == "QUIWidgetItemsBox" then
		if itemInfo ~= nil and  itemInfo.type ~= ITEM_CONFIG_TYPE.GEMSTONE_PIECE and itemInfo.type ~= ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
			itemBox:setPromptIsOpen(true)
		else
			itemBox:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._clickItemBox))
		end
	end


	self._ccbOwner.tf_name:setString(name)
	--self._ccbOwner.tf_name:setColor(UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[self._itemConfig.colour]])
	self._ccbOwner.tf_num:setString(self._itemNum)

	local itemMoney = self._itemInfo.cost or 0
	self._currencyInfo = remote.items:getWalletByType(self._itemInfo.moneyType)
	self._ccbOwner.bug_content:setString("确认购买")

	local sale = self._itemInfo.sale or 1
	-- self._ccbOwner.tf_money:setString(math.ceil(itemMoney * sale)) -- 这里原来量表配置的价格是原价，后来量表配置全部是折后价，所以修改（2/2）
	self._ccbOwner.tf_money:setString(itemMoney)
	self._wallet = remote.user[self._currencyInfo.name] or 0

	-- 物品描述
	local description = self._itemConfig.description or ""
	if self._itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
		local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemInfo.id)
		local decWord = ""
		if self._isCombination then
	    	decWord = self:getCombinationDec(actorId)
		else
			decWord = self:getAssistHeroDec(actorId)
		end

		description = description..decWord
		local colorLabel = QColorLabel:create(description, 430, 60, nil, 22, ccc3(131, 85, 55), global.font_zhcn)
		self._ccbOwner.node_color_label:addChild(colorLabel)
	else
		self._ccbOwner.tf_introduce:setString(description)
	end


	self:setCurrencyIcon()

	self._ccbOwner.btn_hero_detail:setVisible(false)
	if self._itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
		self._ccbOwner.btn_hero_detail:setVisible(true)
	end

	--[[
        by Kumo
        显示流派信息
        Fri Mar  4 19:23:11 2016
    ]]
    local genreText = self:_getHeroGenre()
    self._ccbOwner.tf_genre_name:setString("类型：")
    if genreText then
        self._ccbOwner.tf_genre:setString(genreText)
    else
        self._ccbOwner.tf_genre:setString("无")
    end
    if self._itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
    	self._ccbOwner.node_genre:setVisible(true)
    	self:setPieceNum()
    end
end

function QUIDialogStoreDetail:setPieceNum()
	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId( self._itemInfo.id )
	if actorId == nil then return end
	local numWord = ""
	local currentNum = remote.items:getItemsNumByID(self._itemInfo.id)
    local heroInfo = remote.herosUtil:getHeroByID(actorId)
    local gradeLevel = 0
    if heroInfo ~= nil then
    	gradeLevel = heroInfo.grade+1 or 0
    end
    local info = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(actorId, gradeLevel) or {}
    local needNum = info.soul_gem_count or 0
    local currentNum = remote.items:getItemsNumByID(self._itemInfo.id) or 0
    if needNum > 0 then
        numWord = currentNum.."/"..needNum
    else
        numWord = currentNum
    end
	self._ccbOwner.tf_num:setString(numWord)
end

function QUIDialogStoreDetail:setCurrencyIcon()
   local path = self._currencyInfo.alphaIcon

  	if path ~= nil then
	    local icon = CCSprite:create()
	    icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
	    self._ccbOwner.icon_node:addChild(icon)
	    self._ccbOwner.icon_node:setScale(0.6)
  	end
end

function QUIDialogStoreDetail:getAssistHeroDec(actorId)
	local word = ""
	local assistInfos = QStaticDatabase:sharedDatabase():getAllAssistSkillByActorId(actorId)
	if next(assistInfos) then
		for _, value in pairs(assistInfos) do
			local isHide = db:checkHeroShields(value.hero)
			if value.hero ~= actorId and not isHide then
				local character = QStaticDatabase:sharedDatabase():getCharacterByID(value.hero)
				local aptitudeInfo = db:getSABCByQuality(character.aptitude)
				if word == "" then
					word = "；可激活##"..aptitudeInfo.colorLetter..character.name
				else
					word = word.."##d/##"..aptitudeInfo.colorLetter..character.name
				end
			end
		end
		if word ~= "" then
			word = word.."##d融合技"
		end
	end
	return word
end 

function QUIDialogStoreDetail:getCombinationDec(actorId)
	local word = ""
	local combinationInfos = QStaticDatabase:sharedDatabase():getCombinationInfoByactorId(actorId)
	if next(combinationInfos) then
		local heroInfos, count = remote.herosUtil:getMaxForceHeros()
		local checkActorId = function(actorId)
			for i = 1, count do
				if heroInfos[i] and heroInfos[i].id == actorId then
					return true
				end
			end
			return false
		end

		local index = 0
		local heros = {}
		for i = 1, #combinationInfos do
			if index >= 5 then
				break
			end
			if combinationInfos[i].hero_id ~= actorId and checkActorId(combinationInfos[i].hero_id) and heros[combinationInfos[i].hero_id] ~= true then
				heros[combinationInfos[i].hero_id] = true
				local character = QStaticDatabase:sharedDatabase():getCharacterByID(combinationInfos[i].hero_id)
				local aptitudeInfo = db:getSABCByQuality(character.aptitude)
				if word == "" then
					word = "；可激活##"..aptitudeInfo.colorLetter..character.name
				else
					word = word.."##d/##"..aptitudeInfo.colorLetter..character.name
				end
				index = index + 1
			end
		end
		if word ~= "" then
			word = word.."##d宿命"
		end
	end
	return word
end

function QUIDialogStoreDetail:_onTriggerSell()
    app.sound:playSound("common_small")
	local price = tonumber(self._ccbOwner.tf_money:getString())
	if price > self._wallet then
		self:removeSelfFromParent()
		remote.stores:checkShopCurrencyQuickWay(self._currencyInfo.name)
		return
	end

	self.isSell = true
	self:_onTriggerClose()
end

function QUIDialogStoreDetail:_onTriggerHeroDetail(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_hero_detail) == false then return end
    app.sound:playSound("common_small")
	if self._itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
		self:removeSelfFromParent()
		local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemInfo.id)
		if remote.herosUtil:getHeroByID(actorId) then
			local pos = 1
			local haveHerosID = {actorId}
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
						 options = {hero = haveHerosID, pos = pos, isQuickWay = true}})
		else
			app.tip:itemTip(ITEM_TYPE.HERO, actorId, true)
		end
	end
end 


function QUIDialogStoreDetail:_clickItemBox()
	if self._itemId == nil then return end
	app.tip:itemTip(ITEM_TYPE.GEMSTONE_PIECE, self._itemId)
end

function QUIDialogStoreDetail:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogStoreDetail:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e ~= nil then app.sound:playSound("common_close") end
	self:playEffectOut()
end

function QUIDialogStoreDetail:removeSelfFromParent()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogStoreDetail:_getHeroGenre()
	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemInfo.id)
    local text, index = QStaticDatabase:sharedDatabase():getHeroGenreById(actorId)
    self._genreIndex = index
    return text
end

function QUIDialogStoreDetail:_onTriggerGenre()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPreview", 
		options = {genreType = self._genreIndex}})
end

return QUIDialogStoreDetail
