--
-- Author: xurui
-- Date: 2015-10-31 16:47:39
--
local QUIDialog = import(".QUIDialog")
local QUIDialogShopList = class("QUIDialogShopList", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetShopBar = import("..widgets.QUIWidgetShopBar")
local QScrollView = import("...views.QScrollView") 

function QUIDialogShopList:ctor(options)
	local ccbFile  = "ccb/Dialog_FliyBoat_Shop.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogShopList.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
 	page:setAllUIVisible(false)
	page._scaling:willPlayHide() 
	
    CalculateUIBgSize(self._ccbOwner.sp_background)

    local style = string.split("money^token^soulMoney", "^")
    page.topBar:showWithStyle(style)

	-- self.isAnimation = true
	
	self._backBoxAniamtion = false

	self:setShopBar()
	self:checkRedTip()
	local _time = 0.2
	for i=1,3 do
		local node = self._ccbOwner["shop"..i]
		local posY = node:getPositionY()
		local posX = node:getPositionX()
		node:setPosition(ccp(posX,posY+600))
		-- local arr = CCArray:create()
		-- arr:addObject(CCEaseSineOut:create(CCMoveTo:create(_time, ccp(posX, posY))))
		-- node:runAction(CCSequence:create(arr))
	end
	-- if page.setAllUIVisible then page:setAllUIVisible() end


	-- self.shopsType = {SHOP_ID.generalShop, SHOP_ID.soulShop, SHOP_ID.thunderShop,SHOP_ID.sunwellShop}
	-- self:initScreenView()
	-- self:_updateCurrentPage()
end

function QUIDialogShopList:viewDidAppear()
	QUIDialogShopList.super.viewDidAppear(self)
	self:addBackEvent()
	self:backBoxRunInAction()

end

function QUIDialogShopList:viewWillDisappear()
	QUIDialogShopList.super.viewWillDisappear(self)
	self:removeBackEvent()

	if self._timeScheduler1 then
		scheduler.unscheduleGlobal(self._timeScheduler1)
		self._timeScheduler1 = nil
	end
	
	if self._timeScheduler2 then
		scheduler.unscheduleGlobal(self._timeScheduler2)
		self._timeScheduler2 = nil
	end
end

function QUIDialogShopList:backBoxRunInAction()
	self._backBoxAniamtion = true
	local barNum = #self._shopBar
	self.time = 0.15
	local index = 1
	self.func2 = function()
		if index <= barNum then
			if self._shopBar[index] ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						makeNodeFadeToOpacity(self._shopBar[index], self.time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(self.time, ccp(0,-600))))

				local array2 = CCArray:create()
				array2:addObject(CCSpawn:create(array1))
				self._shopBar[index]:setVisible(true)
				self._shopBar[index]:runAction(CCSequence:create(array2))
			end
			index = index + 1
			self._timeScheduler2 = scheduler.performWithDelayGlobal(self.func2, 0.05)
		else
			self.func3 = function()
				self._timeScheduler1 = scheduler.performWithDelayGlobal(function()
					if self:safeCheck() then
						self._backBoxAniamtion = false
					end
				end, 0.07)
			end
			self.func3()

		end
	end
	self.func2()
end 

function QUIDialogShopList:setShopBar()
	local shopType = {SHOP_ID.generalShop, SHOP_ID.soulShop, SHOP_ID.blackShop}

	self._shopBar = {}
	for i = 1, 3, 1 do
		self._ccbOwner["shop"..i]:removeAllChildren()
		self._shopBar[i] = QUIWidgetShopBar.new({shopType = shopType[i]})
		self._ccbOwner["shop"..i]:addChild(self._shopBar[i])
		self._shopBar[i]:addEventListener(QUIWidgetShopBar.EVENT_CLICK_SHOP_BAR, handler(self, self._onClickEvnet))
	end
end

function QUIDialogShopList:initScreenView()
	-- body
	local contentSize = self._ccbOwner.sheet_layout:getContentSize()
	self._scrollView = QScrollView.new(self._ccbOwner.sheet, contentSize, {sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(false)
	self._scrollView:setHorizontalBounce(true)
	self._scrollView:setGradient(true)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogShopList:_updateCurrentPage()
	self._scrollView:clear()

	local totalWidth = 110
	local offsetX = 5

	for i = 1,#self.shopsType,1 do
		-- print("value = "..self.shopsType[i])
		local _shopbar = QUIWidgetShopBar.new({shopType = self.shopsType[i]})
		_shopbar:setPosition(ccp(totalWidth, -_shopbar:getContentsize().height/2))
		_shopbar:addEventListener(QUIWidgetShopBar.EVENT_CLICK_SHOP_BAR, handler(self, self._onClickEvnet))
		self._scrollView:addItemBox(_shopbar)
		totalWidth = totalWidth + _shopbar:getContentsize().width + offsetX
	end
	self._scrollView:setRect(0, -self._ccbOwner.sheet_layout:getContentSize().height, 0, totalWidth-110)
end

function QUIDialogShopList:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogShopList:_onScrollViewBegan()
	self._isMove = false
end

function QUIDialogShopList:_onClickEvnet(event)
	-- nzhang: http://jira.joybest.com.cn/browse/WOW-8990
	if event == nil or self._backBoxAniamtion == true then return end
	if self._shopClicked  or self._isMove then
		return
	else
		self._shopClicked = true
	end
    app.sound:playSound("common_small")

	remote.stores:openShopDialog(event.shopType)
end

function QUIDialogShopList:checkRedTip()
	if app.unlock:getUnlockShop() and remote.stores:checkCanRefreshShop(SHOP_ID.generalShop) and remote.stores:checkHeroShopRedTipUnlock() then
		self._shopBar[1]:setRedTips(true)
	end

	if app.unlock:getUnlockHeroStore() and remote.stores:checkCanRefreshShop(SHOP_ID.soulShop) and remote.stores:checkHeroShopRedTipUnlock() then
		self._shopBar[2]:setRedTips(true)
	end

	if app.unlock:getUnlockShop2() then
		if QVIPUtil:enableBlackMarketPermanent() then
			if remote.stores:checkCanRefreshShop(SHOP_ID.blackShop) and remote.stores:checkMystoryStore(SHOP_ID.blackShop) then
				self._shopBar[3]:setRedTips(true)
			end
		elseif remote.stores:checkMystoryStoreTimeOut(SHOP_ID.blackShop) and
			remote.stores:checkBlackIsNeedRedTips(SHOP_ID.blackShop) then
			self._shopBar[3]:setRedTips(true)
		end
	end
end

-- function QUIDialogShopList:_backClickHandler()
-- 	self:_onTriggerClose()
-- end

function QUIDialogShopList:_onTriggerClose(e)
    if e ~= nil then
        app.sound:playSound("common_cancel")
    end
	self:playEffectOut()
end

function QUIDialogShopList:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogShopList