local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogVip = class("QUIDialogVip", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QScrollView = import("...views.QScrollView")
local QUIViewController = import("..QUIViewController")
local QUIWidgetVip = import("..widgets.QUIWidgetVip")
local QListView = import("...views.QListView")

function QUIDialogVip:ctor(options)
	local ccbFile = "ccb/Dialog_Vip_new.ccbi"
	local callbacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogVip._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogVip._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogVip._onTriggerRight)},
		{ccbCallbackName = "onTriggerRecharge", callback = handler(self, QUIDialogVip._onTriggerRecharge)},
	}
	QUIDialogVip.super.ctor(self, ccbFile, callbacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    if FinalSDK.isHXShenhe() then
        page:setScalingVisible(false)
    end
    page.topBar:showWithMainPage()

    local vipLevel = QVIPUtil:VIPLevel()
	if options ~= nil and options.vipContentLevel ~= nil then
		vipLevel = options.vipContentLevel
	else
		local shopItems = remote.stores:getStoresById(SHOP_ID.vipShop) or {}
		for j = 1, #shopItems, 1 do
			if shopItems[j].count > 0 then
				vipLevel = j-1
				break
			end
		end
	end
    
	self._contentLevel = vipLevel
	self.moveIsFinished = true

	self._pageContent = self._ccbOwner.sheet
end

function QUIDialogVip:viewDidAppear()
	QUIDialogVip.super.viewDidAppear(self)
    self:addBackEvent()
    if FinalSDK.isHXShenhe() then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setHomeBtnVisible(false)
    end
    self:updateVIP()

    self:setVipContentInfo(self._contentLevel)

	self:initListView()
end

function QUIDialogVip:viewWillDisappear()
	QUIDialogVip.super.viewWillDisappear(self)
    self:removeBackEvent()
end

-- 初始化中间的魂师选择框 swipe工能
function QUIDialogVip:initListView()
	local maxLevel = QVIPUtil:getMaxLevel() + 1

    local cfg = {
        renderItemCallBack = function( list, index, info )
            -- body
            local isCacheNode = true
            local data = {}
            local item = list:getItemFromCache(tag)

            if not item then
                item = QUIWidgetVip.new()
                item:addEventListener(QUIWidgetVip.UPDATE_VIP, handler(self, self._updateList))
                isCacheNode = false
            end

            item:setInfo(index-1, self)
            info.item = item
            info.tag = tag
            info.size = item:getContentSize()

            item:registerItemBoxPrompt(index,list)
            list:registerTouchHandler(index, "onTouchListView")
            list:registerBtnHandler(index, "canbuy", "_onTriggerBuy")

            return isCacheNode
        end,
        headIndex = self._contentLevel + 1,
        isVertical = false,
        enableShadow = false,
        ignoreCanDrag = false,
        totalNumber = maxLevel,
        autoCenter = true,
    }  

    if self._contentListView == nil then
    	self._contentListView = QListView.new(self._ccbOwner.sheet_layout,cfg)
		self._contentListView:setCanNotTouchMove(true)
    else
    	self._contentListView:reload({totalNumber = maxLevel})
	end
end

function QUIDialogVip:_updateList()
    local shopItems = remote.stores:getStoresById(SHOP_ID.vipShop) or {}
    local vipLevel = 0
    for i = 1, #shopItems do
        if shopItems[i].count ~= 0 then
            vipLevel = i
            break
        end
    end
    if vipLevel > 0 then
        self._contentLevel = vipLevel - 1
        self.moveIsFinished = false
        self._contentListView:startScrollToIndex(vipLevel, true, 100, function()
            self.moveIsFinished = true
            self:setVipContentInfo(self._contentLevel)
        end)
    end
end

function QUIDialogVip:updateVIP()
    -- Show vip exp progress bar
    local function addMaskLayer(ccb, mask, scaleX, scaleY)
        local width = ccb:getContentSize().width * scaleX
        local height = ccb:getContentSize().height * scaleY
        local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
        maskLayer:setAnchorPoint(ccp(0, 0.5))
        maskLayer:setPosition(ccp(-width/2, -height/2))

        local ccclippingNode = CCClippingNode:create()
        ccclippingNode:setStencil(maskLayer)
        ccb:retain()
        ccb:removeFromParent()
        ccb:setPosition(ccp(-width/2, 0))
        ccclippingNode:addChild(ccb)
        ccb:release()

        mask:addChild(ccclippingNode)
        return maskLayer
    end

    local currentVIPLevel = QVIPUtil:VIPLevel()
    self._ccbOwner.currentVIPLevel:setString(currentVIPLevel)
    if QVIPUtil:isVIPMaxLevel() then
        self._ccbOwner.nextVIPNode:setVisible(false)

        local vipLevel, vipExp = QVIPUtil:getVIPLevel(remote.user.totalRechargeToken) 

        vipExp = QVIPUtil:cash(vipLevel)
        self._ccbOwner.vip_progress:setString(tostring(remote.user.totalRechargeToken) .. "/" .. self:getAllExp(vipLevel))

        local vipMask = addMaskLayer(self._ccbOwner.vip_bar, self._ccbOwner.vip_mask, 1, 1)
        local vipRatio = remote.user.totalRechargeToken/self:getAllExp(vipLevel)
        vipRatio = vipRatio > 1 and 1 or (vipRatio < 0 and 0 or vipRatio)
        vipMask:setScaleX(vipRatio)
    else
        local nextVIPLevel = currentVIPLevel + 1
        self._ccbOwner.nextVIPNode:setVisible(true)
        self._ccbOwner.nextVIPLevel:setString(nextVIPLevel)

        local vipLevel, vipExp = QVIPUtil:getVIPLevel(remote.user.totalRechargeToken)

        local nextVIPExp = QVIPUtil:cash(nextVIPLevel) - vipExp
        local nextString = nextVIPExp > 1000000 and tostring(math.floor(nextVIPExp/10000)) .. "万" or nextVIPExp
        self._ccbOwner.vip_progress:setString(tostring(remote.user.totalRechargeToken) .. "/" .. self:getAllExp(nextVIPLevel))
        self._ccbOwner.nextCost:setString(nextString)

        local vipMask = addMaskLayer(self._ccbOwner.vip_bar, self._ccbOwner.vip_mask, 1, 1)
        local vipRatio = remote.user.totalRechargeToken/self:getAllExp(nextVIPLevel)
        vipRatio = vipRatio > 1 and 1 or (vipRatio < 0 and 0 or vipRatio)
        vipMask:setScaleX(vipRatio)
    end
end

function QUIDialogVip:setVipContentInfo(vipLevel)
	self._ccbOwner.left_btn:setVisible(vipLevel > 0)
	self._ccbOwner.right_btn:setVisible(vipLevel < QVIPUtil:getMaxLevel())
end

function QUIDialogVip:_contentRunAction(posX, posY)
	if posY == self._pageContent:getPositionY() then
		return
	end
	local actionArrayIn = CCArray:create()
	actionArrayIn:addObject(CCMoveTo:create(0.3, ccp(posX,posY)))
	actionArrayIn:addObject(CCCallFunc:create(function ()
		self:_removeAction()
	end))
	local ccsequence = CCSequence:create(actionArrayIn)
	self._actionHandler = self._pageContent:runAction(ccsequence)
end

function QUIDialogVip:_removeAction()
	-- self:stopEnter()
	if self._actionHandler ~= nil then
		self._pageContent:stopAction(self._actionHandler)
		self._actionHandler = nil
	end
end

function QUIDialogVip:_onTriggerLeft(e)
	if self.vip == 0 then return end
	if self.moveIsFinished == true then
		if e ~= nil then
    		app.sound:playSound("common_menu")
		end
		self:vipContentMoveAnimation("left")
	end
end

function QUIDialogVip:_onTriggerRight(e)
	if self.vip == QVIPUtil:getMaxLevel() then return end
	if self.moveIsFinished == true then
		if e ~= nil then
    		app.sound:playSound("common_menu")
		end
		self:vipContentMoveAnimation("right")
	end
end

--vip特权移动动画
function QUIDialogVip:vipContentMoveAnimation(direction)
	self.moveIsFinished = false

	if direction == "right" then
		self._contentLevel = self._contentLevel + 1
	else
		self._contentLevel = self._contentLevel - 1
	end
	if self._contentLevel < 0 then
		self._contentLevel = 0
	end
	local maxLevel = QVIPUtil:getMaxLevel()
	if self._contentLevel > maxLevel then
		self._contentLevel = maxLevel
	end

	self._contentListView:startScrollToIndex(self._contentLevel+1, true, 100, function()
		self.moveIsFinished = true
		self:setVipContentInfo(self._contentLevel)
	end)
end

function QUIDialogVip:getContentListView(  )
    -- body
    return self._contentListView
end

function QUIDialogVip:getAllExp(vipLevel)
    return QVIPUtil:cash(vipLevel)
end

function QUIDialogVip:_onTriggerRecharge()
	if self._isTrigger == true then return end
    app.sound:playSound("common_small")
	if ENABLE_CHARGE() then
		self._isTrigger = true
	    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER, false)
	    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

function QUIDialogVip:onTriggerBackHandler(tag)
    self:_onTriggerBack()
end

function QUIDialogVip:onTriggerHomeHandler(tag)
    self:_onTriggerHome()
end

function QUIDialogVip:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogVip:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogVip:_backClickHandler()
end

-- 关闭对话框
function QUIDialogVip:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogVip:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end


return QUIDialogVip
