-- @Author: xurui
-- @Date:   2018-10-25 15:19:08
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-04 21:10:56
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyOpenChest = class("QUIDialogMonopolyOpenChest", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogMonopolyOpenChest:ctor(options)
	local ccbFile = "ccb/Dialog_ThunderKing_MysteriousBaoxiang.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogMonopolyOpenChest._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogMonopolyOpenChest._onTriggerOK)},
    }
    QUIDialogMonopolyOpenChest.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end

	self._isBtnokEnable = true
	self._isShowitems = false
	self._isFirstOpen = true

	self._ccbOwner.is_vip:setVisible(self._isVip)
	self._ccbOwner.node_title_congratulate:setVisible(false)
	self._ccbOwner.node_title_discover:setVisible(false)
	self._ccbOwner.node_title_monopoly:setVisible(true)
	self._ccbOwner.layer_bg1:setVisible(true)
	self._ccbOwner.layer_bg2:setVisible(false)
	self._isPlayAnimationToShowItems = false
end

function QUIDialogMonopolyOpenChest:viewDidAppear()
	QUIDialogMonopolyOpenChest.super.viewDidAppear(self)

	self:_addBaoxiang()

	self:setChestInfo()
end

function QUIDialogMonopolyOpenChest:viewWillDisappear()
  	QUIDialogMonopolyOpenChest.super.viewWillDisappear(self)

	if self._waitForShowitem ~= nil then
		scheduler.unscheduleGlobal( self._waitForShowitem )
		self._waitForShowitem = nil
	end
end

function QUIDialogMonopolyOpenChest:_addBaoxiang( isOpen )
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

function QUIDialogMonopolyOpenChest:setChestInfo()
	self._monopolyInfo = remote.monopoly.monopolyInfo or {}
	self._buyCount = self._monopolyInfo.goodBuyCount or 0

	local consumeConfig, isFinal = QStaticDatabase:sharedDatabase():getTokenConsume("monopoly_buy_good_times", self._buyCount)
	self._currentMoney = consumeConfig.money_num
	if self._buyCount == 0 then
		self._currentMoney = 0
		isFinal = true
	end
	self._isFinal = isFinal

	if self._buyCount > 0 then
		self._ccbOwner.tf_btn_ok:setString( "继续开启" )
		self._ccbOwner.node_title_congratulate:setVisible(true)
		self._ccbOwner.node_title_discover:setVisible(false)
		self._ccbOwner.node_title_monopoly:setVisible(false)
		self._ccbOwner.btn_confirm:setTouchEnabled(true)
		makeNodeFromGrayToNormal(self._ccbOwner.btn_confirm)
		self._ccbOwner.tf_btn_likai:enableOutline()
	else
		self._ccbOwner.tf_btn_ok:setString( "开 启" )
		self._ccbOwner.node_title_congratulate:setVisible(false)
		self._ccbOwner.node_title_discover:setVisible(false)
		self._ccbOwner.node_title_monopoly:setVisible(true)
		self._ccbOwner.layer_bg1:setVisible(true)
		self._ccbOwner.layer_bg2:setVisible(false)
		self._ccbOwner.btn_confirm:setTouchEnabled(false)
		makeNodeFromNormalToGray(self._ccbOwner.btn_confirm)
		self._ccbOwner.tf_btn_likai:disableOutline()
	end

	self:setPrice(self._currentMoney)
end

function QUIDialogMonopolyOpenChest:setPrice(str)
	if str == "0" or str == 0 then
		self._ccbOwner.tf_price:setString("免费")
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

function QUIDialogMonopolyOpenChest:initItemboxPosition()
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

function QUIDialogMonopolyOpenChest:hideitems()
	self:initItemboxPosition()
	local count = self._ccbOwner.node_contain:getChildrenCount()
	if count > 0 and self._itemBoxs ~= nil then
		for _, itemBox in pairs(self._itemBoxs) do
			self._ccbOwner.node_contain:removeChild( itemBox )
		end
		self._itemBoxs = nil
	end
end

function QUIDialogMonopolyOpenChest:showItems()
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
		table.remove(self._currentAwards, 1)

		if self._isFirstShowitems == true then 
			local fun = function()
				scheduler.unscheduleGlobal( self._waitForShowitem )
				self._waitForShowitem = nil
				self._ccbOwner.layer_bg1:setVisible(false)
				self._ccbOwner.layer_bg2:setVisible(true)
				self._ccbOwner.node_contain:setVisible(true)
				self._ccbOwner.node_title_congratulate:setVisible(true)
				self._ccbOwner.node_title_discover:setVisible(false)
				self._ccbOwner.node_title_monopoly:setVisible(false)

				self:showItemByEffect()
			end
			self._waitForShowitem = scheduler.performWithDelayGlobal(fun, delayTime)
		else
			self:showItemByEffect()
		end
	else
		self._isBtnokEnable = true
		self._isShowitems = false
		self:setChestInfo()
		self._isPlayAnimationToShowItems = false
		if self._isFinal == false then
			self._monopolyInfo.goodBuyCount = 0
			app.tip:floatTip("所有宝箱都开启完了")
			self:_onTriggerConfirm()
		end
	end
end

function QUIDialogMonopolyOpenChest:showItemByEffect()
	local itemBox = QUIWidgetItemsBox.new()
	table.insert(self._itemBoxs, itemBox)
	itemBox:setGoodsInfo(self._itemInfo.id, self._itemInfo.type, self._itemInfo.count)
	itemBox:showItemName()
	itemBox:setPromptIsOpen(true)
	itemBox:setNeedshadow( false )
	
	local posX = self._rows * self._itemWidth + (self._rows-1) * self._gap
	local posY = self._line * self._itemHeight + (self._line-1) * self._gap
	self._ccbOwner.node_contain:addChild(itemBox)
	self:_nodeRunAction(itemBox, posX + self._offsetX, -(posY) + self._offsetY)
	self._rows = self._rows + 1
	if self._rows > self._num then
		self._rows = 1
		self._line = self._line + 1
	end
end 

function QUIDialogMonopolyOpenChest:_nodeRunAction(node, posX, posY)
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

function QUIDialogMonopolyOpenChest:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
	if self._isPlayAnimationToShowItems then
		return
	end
	app.sound:playSound("common_cancel")

	remote.monopoly:monopolyBuyChestRequest(false,1, function(data)
		self:popSelf()

		remote.monopoly.beginOneCheatState = false
		if self._callBack ~= nil then 
			self._callBack() 
		end
	end)
end

function QUIDialogMonopolyOpenChest:_onTriggerOK(event) 
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	if self._isBtnokEnable ~= true or self._isPlayAnimationToShowItems then return end
	app.sound:playSound("common_confirm")

	if remote.user.token < self._currentMoney then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil, nil, function ()
			self:popSelf()
			if self._callBack then
				self._callBack()
			end
		end)
		return
	end
	self._isBtnokEnable = false
	self._isPlayAnimationToShowItems = true

	remote.monopoly:monopolyBuyChestRequest(true,1, function(data)
		if self:safeCheck() then
			self._currentAwards = data.prizes or {}
			self._ccbOwner.layer_bg1:setVisible(true)
			self._ccbOwner.layer_bg2:setVisible(false)
			self:hideitems()
			self:showItems()
		end
	end)
end

function QUIDialogMonopolyOpenChest:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMonopolyOpenChest:viewAnimationOutHandler()
	self:popSelf()

	if self._callBack then
		self._callBack()
	end
end

return QUIDialogMonopolyOpenChest
