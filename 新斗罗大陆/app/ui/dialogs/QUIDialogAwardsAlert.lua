--
-- Author: wkwang
-- Date: 2015-03-23 20:47:18
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAwardsAlert = class("QUIDialogAwardsAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")

function QUIDialogAwardsAlert:ctor(options)
	local ccbFile = "ccb/Dialog_AchieveProp_acitivity.ccbi"
    local callBacks = {
        -- {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogAwardsAlert._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogAwardsAlert._onTriggerConfirm)},
    }
    QUIDialogAwardsAlert.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page ~= nil and page.topBar ~= nil then
		page.topBar:setAllSound(false)
	end

    self._callBackFun = options.callBack or options.callback
    self._id = options.id
    self.heros = {}
    self.oldHeros = options.oldHeros or clone(remote.herosUtil:getOldHaveHero())
    self._isShowing = true
    self._isTouch = false
    self._speed = 2
    self.isSort = options.isSort or false  
    self._awardRatio = options.awardRatio or 1

    self:setTitle(options.title or "")
    
    local awards = {}
    for _,value in ipairs(options.awards or {}) do
    	table.insert(awards, {id = value.id or value.itemId, typeName = (value.typeName or value.type or value.itemType), count = value.count, isLucky = value.isLucky})
    end
    if not self.isSort then
	    --合并相同的道具
		local tempAwards = {}
		local tempAwards2 = {}
		for _, v in pairs(awards) do
			if v.typeName ~= ITEM_TYPE.HERO then
				if tonumber(v.id) ~= nil and tonumber(v.id) > 0 then
		    		if tempAwards[v.id] then
		    			tempAwards[v.id].count = tempAwards[v.id].count + v.count
		    		else
		    			tempAwards[v.id] = v
		    		end
		    	else
		    		if tempAwards[v.typeName] then
		    			tempAwards[v.typeName].count = tempAwards[v.typeName].count + v.count
		    		else
		    			tempAwards[v.typeName] = v
		    		end
		    	end
		    else
		    	table.insert(tempAwards2, v)
		    end
		end
		awards = tempAwards2
		for k,v in pairs(tempAwards) do
			if tonumber(v.id) ~= nil and tonumber(v.id) > 0 then
				local int = math.ceil(v.count/9999)
				for i= 1,int do
					local temp = clone(v)
					local tempCount = v.count - 9999
					if tempCount < 0 then
						temp.count = v.count
					else
						v.count = v.count - 9999
						temp.count = 9999
					end	
					table.insert(awards,temp)
				end
			else
				table.insert(awards,v)
			end
		end	
	end
    self._allAwards = awards
    self._isVip = options.isVip or false
	self:startShowItem()
	self._ccbOwner.is_vip:setVisible(self._isVip)
end

function QUIDialogAwardsAlert:startShowItem()
	self._rows = 1
	self._line = 1
	self._offsetY = 60
	self._gap = 45
	self._itemWidth = 120
	self._itemHeight = 140
	self._maxNum = 10
    self._num = self._maxNum/2
	local totalNum = #self._allAwards
	totalNum = math.min(totalNum, self._maxNum)
	self._awards = {}
	for i = 1,totalNum do
		table.insert(self._awards, table.remove(self._allAwards,1))
	end
	self._ccbOwner.node_contain:removeAllChildren()

	self._scaleX = self._ccbOwner.node_contain:getScaleX()
	self._scaleY = self._ccbOwner.node_contain:getScaleY()
	
	if totalNum > self._num then
		self._widthNum =  self._num * self._itemWidth + (self._num - 1) * self._gap
	else
		self._widthNum =  totalNum * self._itemWidth + (totalNum - 1) * self._gap
	end
	self._heightNum = math.ceil(totalNum/self._num) * self._itemHeight + (math.ceil(totalNum/self._num) - 1) * self._gap
	self._ccbOwner.node_contain:setPosition(-self._widthNum/2 * self._scaleX, self._heightNum/2 * self._scaleY)
	self._handler = scheduler.performWithDelayGlobal(handler(self, self.showItems), 0.5)
end


function QUIDialogAwardsAlert:viewDidAppear()
	QUIDialogAwardsAlert.super.viewDidAppear(self)
	self.prompt = app:promptTips()
  	if self.prompt ~= nil then	
		self.prompt:addItemEventListener(self)
  	end
end

function QUIDialogAwardsAlert:viewWillDisappear()
  	QUIDialogAwardsAlert.super.viewWillDisappear(self)
  	if self.prompt ~= nil then	
  		self.prompt:removeItemEventListener()
  	end
  	if self._handler ~= nil then
  		scheduler.unscheduleGlobal(self._handler)
  		self._handler = nil
  	end
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.topBar then
		page.topBar:setAllSound(true)
	end
end

function QUIDialogAwardsAlert:setTitle(str)
	self._ccbOwner.tf_title:setString(str)
end

-- 设置文本标题Y轴偏移
function QUIDialogAwardsAlert:setTitleOffsetY(posY)
	posY = posY or 0
	self._ccbOwner.tf_title:setPositionY(self._ccbOwner.tf_title:getPositionY() + posY)
end

function QUIDialogAwardsAlert:showItems()
	if #self._awards > 0 then
		self._isShowing = true
		self._isTouch = true
		self._itemInfo = table.remove(self._awards,1)
		if remote.items:getItemType(self._itemInfo.typeName) == ITEM_TYPE.HERO then
			self:showHeroCard()
		elseif remote.items:getItemType(self._itemInfo.typeName) == ITEM_TYPE.ZUOQI then
			self:_showMountAvatar()
		else
			self:showItemByEffect()
		end
	else
		self._isShowing = false
	end	
end

function QUIDialogAwardsAlert:showItemByEffect()
	if self:safeCheck() == false then
		return
	end

	local itemBox
	if self._itemInfo.typeName == ITEM_TYPE.ZUOQI then
		itemBox = QUIWidgetMountBox.new()
        itemBox:setMountInfo({zuoqiId = self._itemInfo.id, grade = 0, enhanceLevel = 1})
		local config = QStaticDatabase:sharedDatabase():getCharacterByID(self._itemInfo.id)
		itemBox:showSabc(remote.gemstone:getSABC(config.aptitude).lower)
		itemBox:setPromptIsOpen(true)
	else
		itemBox = QUIWidgetItemsBox.new()
		itemBox:addEventListener(QUIWidgetItemsBox.EVENT_BEGAIN, handler(self, self._lock))
		itemBox:addEventListener(QUIWidgetItemsBox.EVENT_END, handler(self, self._lock))
		local itemType = remote.items:getItemType(self._itemInfo.typeName)
		itemBox:setGoodsInfo(self._itemInfo.id, self._itemInfo.typeName, self._itemInfo.count,nil,true)
		if self._awardRatio and self._awardRatio > 1 and self._itemInfo.typeName == ITEM_TYPE.STORM_MONEY  then
			itemBox:setRateActivityState(true, self._awardRatio)
		end
		itemBox:setPromptIsOpen(true)
		itemBox:showEffect()
		itemBox:setNeedshadow( false )
		if self._itemInfo.isLucky then
			local ccbFile = "ccb/effects/heji_kuang_2.ccbi"
			itemBox:showBoxEffect(ccbFile,true)
		end
	end
	itemBox:setScale(1.2)
	local posX = self._itemWidth/2 + (self._rows-1) * (self._gap + self._itemWidth)
	local posY = self._line * self._itemHeight + (self._line-1) * self._gap
	self._ccbOwner.node_contain:addChild(itemBox)
	self:_nodeRunAction(itemBox, posX , -(posY) + self._offsetY)
	self._rows = self._rows + 1
	if self._rows > self._num then
		self._rows = 1
		self._line = self._line + 1
	end
end

function QUIDialogAwardsAlert:setMountPieceInfo()
	if self._isHave then
		local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._itemInfo.id , 0)
        self._itemInfo.id = config.soul_gem
		self._itemInfo.typeName = ITEM_TYPE.ITEM
        self._itemInfo.count = config.soul_second_hero
		self:showItemByEffect()
	else
		self:_checkMountCombination()
	end
end

--显示Avatar详细信息
function QUIDialogAwardsAlert:_showMountAvatar()
	self._isHave = remote.mount:checkMountHavePast(self._itemInfo.id)

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogShowMountInfo", 
        options= {actorId = self._itemInfo.id, callBack = handler(self, self.setMountPieceInfo)}}, {isPopCurrentDialog = false})
end

--显示获得魂师反馈
function QUIDialogAwardsAlert:showHeroCard()

	--检查购买前是否拥有该魂师
	self.isHave = false
	for _,actorId in ipairs(self.oldHeros) do
		if actorId == self._itemInfo.id then
			self.isHave = true
		end
	end

	--检查本次奖励的魂师中是否有该魂师
	if self.isHave == false and next(self.heros) then
		for k, value in pairs(self.heros) do 
			if value.id == self._itemInfo.id then
				self.isHave = true
			end
		end
	end
	table.insert(self.heros, self._itemInfo)
	
	local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._itemInfo.id)
	if heroInfo ~= nil and heroInfo.grade ~= nil then
		self._itemInfo.grade = heroInfo.grade
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHeroCard", 
	        options={actorId = self._itemInfo.id, callBack = handler(self, self.checkPrizeHero)}}, {isPopCurrentDialog = false})
end

function QUIDialogAwardsAlert:checkPrizeHero()
    if self.isHave == false then
		self:showItemByEffect()
	else
		local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._itemInfo.id , self._itemInfo.grade or 0)
        self._itemInfo.typeName = ITEM_TYPE.ITEM
        self._itemInfo.id = config.soul_gem
        self._itemInfo.count = config.soul_second_hero
		self:showItemByEffect()
	end
end

function QUIDialogAwardsAlert:_lock( event )
	if event.name == QUIWidgetItemsBox.EVENT_BEGAIN then
		self._isLock = true
	else
		scheduler.performWithDelayGlobal(function() self._isLock = false end, 0)
	end
end

-- 移动到指定位置
function QUIDialogAwardsAlert:_nodeRunAction(node,posX,posY)
    self._isMove = true
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveBy:create(0.11 * 1/self._speed, ccp(posX,posY)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
                                                self:showItems()
												node:showItemName()
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionHandler = node:runAction(ccsequence)
end

function QUIDialogAwardsAlert:_backClickHandler()
	if self._isLock then return end
    self:_onTriggerConfirm()
end

function QUIDialogAwardsAlert:_onTriggerConfirm()
	if self._isShowing then return end
	if #self._allAwards > 0 then
		if self._isTouch then
			-- 当第一屏的奖励播放完之后，只接受一次点击事件，避免点的太快，把后面几屏的奖励一下点掉
			self._isTouch = false
			self:startShowItem()
		end
		return
	end

	local callback = self._callBackFun
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
    	callback(self._id)
    end
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.class.__cname == "QUIPageMainMenu" then
		page:buildLayer()
		page:checkGuiad()
	end
end

return QUIDialogAwardsAlert