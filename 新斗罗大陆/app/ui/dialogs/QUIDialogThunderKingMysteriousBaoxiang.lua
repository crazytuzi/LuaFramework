local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderKingMysteriousBaoxiang = class("QUIDialogThunderKingMysteriousBaoxiang", QUIDialog)
local QQuickWay = import("...utils.QQuickWay")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogThunderKingMysteriousBaoxiang:ctor(options)
	local ccbFile = "ccb/Dialog_ThunderKing_MysteriousBaoxiang.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogThunderKingMysteriousBaoxiang._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogThunderKingMysteriousBaoxiang._onTriggerOK)},
	}
   	QUIDialogThunderKingMysteriousBaoxiang.super.ctor(self, ccbFile, callBacks, options)

	self._isBtnokEnable = true
	self._isShowitems = false
	self._isFirstOpen = true

	self._callBackFun = options.callBack
	self._isVip = options.isVip or false
	self._layer = options.layer

	self:updateData(options.times or 1)
	-- self:initItemboxPosition()
	self._ccbOwner.is_vip:setVisible(self._isVip)

	self._ccbOwner.node_title_congratulate:setVisible(false)
	self._ccbOwner.node_title_discover:setVisible(true)
	self._ccbOwner.layer_bg1:setVisible(true)
	self._ccbOwner.layer_bg2:setVisible(false)

	self._isPlayAnimationToShowItems = false
end

function QUIDialogThunderKingMysteriousBaoxiang:initItemboxPosition()
	-- self._currentShowitemTimes = 0
	self._num = 3
	self._rows = 1
	self._line = 1
	self._offsetX = -70
	self._offsetY = 75
	self._itemWidth = 100
	self._itemHeight = 100
	self._gap = 20
	local totalNum = #self._currentAwards
	if totalNum > self._num then
		self._widthNum =  self._num * self._itemWidth + 4 * self._gap
	else
		self._widthNum =  totalNum * self._itemWidth + (totalNum - 1) * self._gap
	end
	self._heightNum = math.ceil(totalNum/self._num) * self._itemHeight + (math.ceil(totalNum/self._num) - 1) * self._gap
	self._ccbOwner.node_contain:setPosition(-self._widthNum/2, self._heightNum/2)
end

function QUIDialogThunderKingMysteriousBaoxiang:updateData( times )
	self._buyPreciousTimes = times or 1

	local consumeConfig = QStaticDatabase:sharedDatabase():getTokenConsume("fulminous_price", self._buyPreciousTimes)
	self._currentMoney = consumeConfig.money_num

	if self._buyPreciousTimes > 1 then
		self._ccbOwner.tf_btn_ok:setString( "继续开启" )
		self._ccbOwner.node_title_congratulate:setVisible(true)
		self._ccbOwner.node_title_discover:setVisible(false)
		self._ccbOwner.btn_confirm:setTouchEnabled(true)
		makeNodeFromGrayToNormal(self._ccbOwner.btn_confirm)
		self._ccbOwner.tf_btn_likai:enableOutline()
	else
		self._ccbOwner.tf_btn_ok:setString( "开 启" )
		self._ccbOwner.node_title_congratulate:setVisible(false)
		self._ccbOwner.node_title_discover:setVisible(true)
		self._ccbOwner.layer_bg1:setVisible(true)
		self._ccbOwner.layer_bg2:setVisible(false)
		if self._layer == nil then
			self._ccbOwner.btn_confirm:setTouchEnabled(false)
			makeNodeFromNormalToGray(self._ccbOwner.btn_confirm)
			self._ccbOwner.tf_btn_likai:disableOutline()
		end
	end

	self:setPrice(self._currentMoney)
end

function QUIDialogThunderKingMysteriousBaoxiang:viewDidAppear()
	QUIDialogThunderKingMysteriousBaoxiang.super.viewDidAppear(self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_CLOSE_QUICK_WAY_DIALOG, self._closeDialog, self)
	self.prompt = app:promptTips()
	if self.prompt ~= nil then	
		self.prompt:addItemEventListener(self)
	end
	self:_addBaoxiang()
end

function QUIDialogThunderKingMysteriousBaoxiang:viewWillDisappear()
	QUIDialogThunderKingMysteriousBaoxiang.super.viewWillDisappear(self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_CLOSE_QUICK_WAY_DIALOG, self._closeDialog, self)
	if self.prompt ~= nil then	
		self.prompt:removeItemEventListener()
	end
	if self._waitForShowitem ~= nil then
		scheduler.unscheduleGlobal( self._waitForShowitem )
		self._waitForShowitem = nil
	end
end

function QUIDialogThunderKingMysteriousBaoxiang:_addBaoxiang( isOpen )
	if isOpen == nil then isOpen = false end
	-- 控制宝箱CCB
	local animationManager = tolua.cast(self._ccbOwner["baoxiang"]:getUserObject(), "CCBAnimationManager")
	if animationManager ~= nil then
		if isOpen == true then
			self._isFirstOpen = false
			animationManager:runAnimationsForSequenceNamed("open")
		else
			animationManager:runAnimationsForSequenceNamed("normal")
			animationManager:pauseAnimation()
		end
	end
end

function QUIDialogThunderKingMysteriousBaoxiang:setPrice(str)
	if str == "0" or str == 0 then
		self._ccbOwner.tf_price:setString("")
		self._ccbOwner.tf_price:setVisible(false)
		self._ccbOwner.node_tokenMoney:setVisible(false)
		self._ccbOwner.tf_free:setVisible(true)
	else
		self._ccbOwner.tf_price:setString(str)
		self._ccbOwner.tf_price:setVisible(true)
		self._ccbOwner.node_tokenMoney:setVisible(true)
		self._ccbOwner.tf_free:setVisible(false)
	end
end

function QUIDialogThunderKingMysteriousBaoxiang:showItems()
	if #self._currentAwards > 0 then
		local delayTime = 0
		if self._isShowitems ~= true then 
			self._itemBoxs = {}
			self._isFirstShowitems = true
			self._ccbOwner.node_contain:setVisible(false)

			if self._isFirstOpen then 
				self:_addBaoxiang( true )
				delayTime = 1.5
			end
		end

		self._isShowitems = true
		self._itemInfo = self._currentAwards[1]
		table.remove(self._currentAwards,1)

		-- xurui WOW-13050
		self:getOptions().times = self._buyPreciousTimes + 1
		if self._isFirstShowitems == true then 
			local fun = function()
				scheduler.unscheduleGlobal( self._waitForShowitem )
				self._waitForShowitem = nil
				self._ccbOwner.layer_bg1:setVisible(false)
				self._ccbOwner.layer_bg2:setVisible(true)
				self._ccbOwner.node_contain:setVisible(true)
				self._ccbOwner.node_title_congratulate:setVisible(true)
				self._ccbOwner.node_title_discover:setVisible(false)
				if remote.items:getItemType(self._itemInfo.type) == ITEM_TYPE.HERO then
					self:showHeroCard()
				else
					self:showItemByEffect()
				end
			end
			self._waitForShowitem = scheduler.performWithDelayGlobal(fun, delayTime)
		else
			if remote.items:getItemType(self._itemInfo.type) == ITEM_TYPE.HERO then
				self:showHeroCard()
			else
				self:showItemByEffect()
			end
		end
	else
		self._isBtnokEnable = true
		self._isShowitems = false
		self:updateData(self._buyPreciousTimes + 1)
		self._isPlayAnimationToShowItems = false
	end
end

function QUIDialogThunderKingMysteriousBaoxiang:showItemByEffect()
	local itemBox = QUIWidgetItemsBox.new()
	table.insert(self._itemBoxs, itemBox)
	itemBox:setGoodsInfo(self._itemInfo.id, self._itemInfo.type, self._itemInfo.count)
	itemBox:showItemName()
	itemBox:setPromptIsOpen(true)
	itemBox:setNeedshadow( false )
	
	local posX = self._rows * self._itemWidth + (self._rows-1) * self._gap
	local posY = self._line * self._itemHeight + (self._line-1) * self._gap
	self._ccbOwner.node_contain:addChild(itemBox)
	-- if self._isFirstShowitems == true then 
	-- 	local fun = function()
	-- 		scheduler.unscheduleGlobal( self._waitForShowitem )
	-- 		self._waitForShowitem = nil
	-- 		self._ccbOwner.layer_bg1:setVisible(false)
	-- 		self._ccbOwner.layer_bg2:setVisible(true)
	-- 		self._ccbOwner.node_contain:setVisible(true)
	-- 		self._ccbOwner.node_title_congratulate:setVisible(true)
	-- 		self._ccbOwner.node_title_discover:setVisible(false)
	-- 		self:_nodeRunAction(itemBox, posX + self._offsetX, -(posY) + self._offsetY)
	-- 	end
	-- 	self._waitForShowitem = scheduler.performWithDelayGlobal(fun, 1.5)
	-- else
		self:_nodeRunAction(itemBox, posX + self._offsetX, -(posY) + self._offsetY)
	-- end
	self._rows = self._rows + 1
	if self._rows > self._num then
		self._rows = 1
		self._line = self._line + 1
	end
end 

function QUIDialogThunderKingMysteriousBaoxiang:showHeroCard()
	self.isHave = false

	--检查购买前是否拥有该魂师
	if next(self.oldHeros) then
		for k, value in pairs(self.oldHeros) do
			if self._itemInfo.id == value then
				self.isHave = true
			end
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

function QUIDialogThunderKingMysteriousBaoxiang:checkPrizeHero()
    if self.isHave == false then
		self:showItemByEffect()
	else
		local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._itemInfo.id , self._itemInfo.grade or 0)
        self._itemInfo.type = ITEM_TYPE.ITEM
        self._itemInfo.id = config.soul_gem
        self._itemInfo.count = config.soul_second_hero
		self:showItemByEffect()
	end
end

function QUIDialogThunderKingMysteriousBaoxiang:hideitems()
	self:initItemboxPosition()
	local count = self._ccbOwner.node_contain:getChildrenCount()
	if count > 0 and self._itemBoxs ~= nil then
		for _, itemBox in pairs(self._itemBoxs) do
			self._ccbOwner.node_contain:removeChild( itemBox )
		end
		self._itemBoxs = nil
	end
end

-- 移动到指定位置
function QUIDialogThunderKingMysteriousBaoxiang:_nodeRunAction(node,posX,posY)
    self._isMove = true
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveBy:create(0.15, ccp(posX,posY)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
				self._isFirstShowitems = false
				self:showItems()
            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._actionHandler = node:runAction(ccsequence)
end

function QUIDialogThunderKingMysteriousBaoxiang:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
	if self._isPlayAnimationToShowItems then
		return
	end
	app.sound:playSound("common_cancel")
	if self._waitForShowitem ~= nil then
		scheduler.unscheduleGlobal( self._waitForShowitem )
		self._waitForShowitem = nil
	end
	if self._layer == nil then
		remote.thunder:thunderBuyPreciousRequest(false, nil, false)
	end
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	if self._layer == nil then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		if page.class.__cname == "QUIPageMainMenu" then
			printInfo("call QUIPageonTriggerConfirmMainMenu function checkGuiad()")
			page:checkGuiad()
		end
	end
	if self._callBackFun ~= nil then self._callBackFun() end
end

function QUIDialogThunderKingMysteriousBaoxiang:_onTriggerOK(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	if self._isBtnokEnable ~= true or self._isPlayAnimationToShowItems then return end
	app.sound:playSound("common_confirm")
	if remote.user.token < self._currentMoney then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil, nil, function ()
			self:_closeDialog()
		end)
		return
	end
	self._isBtnokEnable = false
	self.oldHeros = clone(remote.herosUtil:getHaveHero())
	self.heros = {}
	self._isPlayAnimationToShowItems = true
	remote.thunder:thunderBuyPreciousRequest(true, self._layer, false, function(data)
		self._currentAwards = data.apiThunderBuyPreciousResponse.luckyDraw.prizes
		self._ccbOwner.layer_bg1:setVisible(true)
		self._ccbOwner.layer_bg2:setVisible(false)
		self:hideitems()
		self:showItems()
	end)
end

function QUIDialogThunderKingMysteriousBaoxiang:_closeDialog()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end 

return QUIDialogThunderKingMysteriousBaoxiang