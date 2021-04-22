-- @Author: xurui
-- @Date:   2016-10-13 11:46:50
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-06 22:51:34
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountChestAchieve = class("QUIDialogMountChestAchieve", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")

QUIDialogMountChestAchieve.MOUNT_CHEST_TYPE = "MOUNT_CHEST_TYPE"

function QUIDialogMountChestAchieve:ctor(options)
	local ccbFile = "ccb/effects/anqi_baoxian_huode.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogMountChestAchieve._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerAgain", callback = handler(self, QUIDialogMountChestAchieve._onTriggerAgain)}
	}
	QUIDialogMountChestAchieve.super.ctor(self, ccbFile, callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(false)

	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	if options.hasShowAni then
		self._animationManager:runAnimationsForSequenceNamed("Untitled Timeline")
   		self._ccbOwner.node_buy:setVisible(true)
		self._ccbOwner.node_ok:setVisible(true)
   	else
		self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
    	self._ccbOwner.node_buy:setVisible(false)
		self._ccbOwner.node_ok:setVisible(false)
    end

	self.isShow = true
	self._canAgain = true
	self._scheduler1 = scheduler.performWithDelayGlobal(function()
            app.sound:playSound("common_bright")
        end, 0.05)
end

function QUIDialogMountChestAchieve:viewDidAppear()
    QUIDialogMountChestAchieve.super.viewDidAppear(self)

   	self:_showThunderEffect()
end

function QUIDialogMountChestAchieve:viewWillDisappear()
  	QUIDialogMountChestAchieve.super.viewWillDisappear(self)
  	if self._scheduler1 then
  		scheduler.unscheduleGlobal(self._scheduler1)
  		self._scheduler1 = nil
  	end
end

function QUIDialogMountChestAchieve:_showThunderEffect()
	local options = self:getOptions()
	self:initView(options)

	if options.hasShowAni then
		self:setHeroHeadBox()
    	self:setTitleByType()
	else
		self:setHeroHeadBoxEffects()
		self:setTitleByType()
	end

    options.hasShowAni = true
end

function QUIDialogMountChestAchieve:initView(options)
	self.prize = clone(options.items)
	self.againBack = options.againBack
	self.money = options.cost or 0
	self.tavernType = options.tavernType
	self.tokenType = options.tokenType
	self.prizeNum = #self.prize
	self.confirmBack = options.confirmBack

	self._ccbOwner.tf_money:setString(self.money)
	
	if self.prizeNum == 1 then
		self._ccbOwner.buy_label:setString("再召一次")
	else
		self._ccbOwner.buy_label:setString("再召十次")
	end	

	self.index = 1 
	self.heros = {}
end

function QUIDialogMountChestAchieve:setHeroHeadBoxEffects()
	if self.index > self.prizeNum then return end

	self.isHero = false
	self.info = clone(self.prize[self.index])
	if self.info.type == "ZUOQI" then
		self:_showMountAvatar()
	else
		self:_setItemBox()
	end
end 

--显示Avatar详细信息
function QUIDialogMountChestAchieve:_showMountAvatar()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogShowMountInfo", 
        options= {actorId = self.info.id, isMount = true, callBack = handler(self, self.setMountPieceInfo)}}, {isPopCurrentDialog = false})
end

function QUIDialogMountChestAchieve:setMountPieceInfo()
	self._isHave = remote.mount:checkMountHavePast(self.info.id)

	if self._isHave then
		local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.info.id , 0)
        self.info.id = config.soul_gem
		self.info.type = ITEM_TYPE.ITEM
        self.info.count = config.soul_second_hero
		self:_setItemBox()
	else
		self:_checkMountCombination()
	end
end

function QUIDialogMountChestAchieve:_checkMountCombination()
	if self:safeCheck() and self.info.id ~= nil then
		app.tip:creatMountCombinationTip(self.info.id, handler(self, self._setItemBox))
	end
end

function QUIDialogMountChestAchieve:_setItemBox() 
	local info = self.info
	self["itemNode"..self.index] = CCNode:create()
	self:getView():addChild(self["itemNode"..self.index])

	self["heroHeadBox"..self.index] = QUIWidgetItemsBox.new()
	local itemType = remote.items:getItemType(info.type)
	self["heroHeadBox"..self.index]:setGoodsInfo(info.id, itemType, info.count)
	-- self["heroHeadBox"..self.index]:showEffect()
	self["heroHeadBox"..self.index]:setNeedshadow( false )
	if itemType == ITEM_TYPE.ITEM then
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(info.id)
		if itemInfo.colour == ITEM_QUALITY_INDEX.PURPLE then
			self["heroHeadBox"..self.index]:showBoxEffect("Widget_AchieveHero_light_purple.ccbi")
		elseif itemInfo.colour == ITEM_QUALITY_INDEX.ORANGE then
			self["heroHeadBox"..self.index]:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
		end
	end
	if itemType == ITEM_TYPE.HERO or itemType == ITEM_TYPE.ZUOQI then
		local itemConfig = db:getCharacterByID(tonumber(info.id))
		self["heroHeadBox"..self.index]:showSabc(remote.gemstone:getSABC(itemConfig.aptitude).lower)
	end

	local positionY = -100
	if self.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
		positionY = 0
	end
	self["heroHeadBox"..self.index]:setPosition(ccp(0, positionY))

	self["itemNode"..self.index]:addChild(self["heroHeadBox"..self.index])

	local maxNum = math.floor(self.prizeNum/2)
	local startPositionX = maxNum == 3 and -135 or -290
	local startPositionY = 45
	local lineGap = 175
	local rowGap = 145

	local itemNum = self.index > maxNum and self.index-maxNum or self.index
	local lineNum = self.index > maxNum and 2 or 1
	local posX = startPositionX + ((itemNum-1) * rowGap)
	local posY = startPositionY - ((lineNum-1) * lineGap)
	if self.prizeNum == 1 then
		posX = 0
		posY = 0
	end
	posY = posY + 30
	self:_nodeRunAction(self["heroHeadBox"..self.index], posX, posY)
end

-- 移动到指定位置
function QUIDialogMountChestAchieve:_nodeRunAction(node,posX,posY)
    self._isMove = true
    local actionTime = 0.125
    node:setScale(0)

    app.sound:playSound("common_award")

    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(actionTime, ccp(posX,posY)))
    actionArrayIn:addObject(CCScaleTo:create(actionTime, 1, 1))
    actionArrayIn:addObject(CCRotateBy:create(actionTime, -360))
    actionArrayIn:addObject(CCCallFunc:create(function() 
			local itemEffects = QUIWidgetAnimationPlayer.new()
			node:addChild(itemEffects)
			itemEffects:playAnimation("effects/Item_box_shine.ccbi", function()
				end)
    	end))

    local array = CCArray:create()
    array:addObject(CCSpawn:create(actionArrayIn))
    array:addObject(CCCallFunc:create(function() 
                        self.index = self.index + 1 
                        if self.index > self.prizeNum then
    						app.sound:playSound("common_end")
							for i = 1, self.prizeNum do
								self["heroHeadBox"..i]:setPromptIsOpen(true)
							end
                        else
                        	self:setHeroHeadBoxEffects()
                    	end
						node:showItemName()
                    end))
    self._actionHandler = node:runAction(CCSequence:create(array))
end

function QUIDialogMountChestAchieve:setTitleByType()
    self._ccbOwner.callCard_advanced:setVisible(false)
    self._ccbOwner.node_tokenMoney:setVisible(false)
    self._ccbOwner.node_money:setVisible(false)
    self._ccbOwner.callCard_normal:setVisible(false)
    self._ccbOwner.node_free:setVisible(false)

	local maxNum = 1
	if self.prizeNum == 10 then maxNum = 10 end

    if self.tokenType == ITEM_TYPE.TOKEN_MONEY then
        self._ccbOwner.node_tokenMoney:setVisible(true)
    	self._canAgain = remote.user.token >= self.money
    	self._ccbOwner.tf_money:setString(self.money or 0)
    elseif self.tokenType == ITEM_TYPE.SUMMONCARD_MOUNT then
    	self._ccbOwner.callCard_normal:setVisible(true)
        local currencyNum = remote.items:getItemsNumByID(162)
    	self._canAgain = currencyNum >= self.money
    	self._ccbOwner.tf_money:setString((self.money or 0).."/"..maxNum)
    end

    self._ccbOwner.node_ok:setVisible(true)
    self._ccbOwner.node_buy:setVisible(true)

	local content1, content3 = "成功获得", "暗器币"

	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	local content2 = config["ZUOQI_ZHAOHUAN_HUOBI"].value or 60
	if self.prizeNum == 10 then
		content2 = config["ZUOQI_SHICIZHAOHUAN_HUOBI"].value or 800
	end

   	local richText = QRichText.new({
        {oType = "font", content = content1,size = 26,color = ccc3(253,231,169)},
        {oType = "font", content = content2,size = 26,color = ccc3(90,249,0)},
        {oType = "font", content = content3,size = 26,color = ccc3(253,231,169)},
    },790)
	self._ccbOwner.node_tf_content:addChild(richText)
	local wordLen = q.wordLen(content1..content2..content3, 26, 13)
	local positionX = self._ccbOwner.node_tf_content:getPositionX()
	self._ccbOwner.node_tf_content:setPositionX(positionX-(positionX + wordLen/2))
	self._ccbOwner.node_tf_content:setVisible(false)
end

function QUIDialogMountChestAchieve:setHeroHeadBox()
	for index, info in pairs(self.prize) do
		self["itemNode"..index] = CCNode:create()
		self:getView():addChild(self["itemNode"..index])

		self["heroHeadBox"..index] = QUIWidgetItemsBox.new()
		local itemType = remote.items:getItemType(info.type)
		self["heroHeadBox"..index]:setGoodsInfo(info.id, itemType, info.count)
		self["heroHeadBox"..index]:setPromptIsOpen(true)
		self["heroHeadBox"..index]:setNeedshadow( false )
		if itemType == ITEM_TYPE.ITEM then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(info.id)
			if itemInfo.colour == ITEM_QUALITY_INDEX.PURPLE then
				self["heroHeadBox"..index]:showBoxEffect("Widget_AchieveHero_light_purple.ccbi")
			elseif itemInfo.colour == ITEM_QUALITY_INDEX.ORANGE then
				self["heroHeadBox"..index]:showBoxEffect("Widget_AchieveHero_light_orange.ccbi")
			end
		end
		if itemType == ITEM_TYPE.HERO or itemType == ITEM_TYPE.ZUOQI then
			local itemConfig = db:getCharacterByID(tonumber(info.id))
			self["heroHeadBox"..index]:showSabc(remote.gemstone:getSABC(itemConfig.aptitude).lower)
		end

		local positionY = -100
		if self.tavernType == TAVERN_SHOW_HERO_CARD.ORIENT_TAVERN_TYPE then
			positionY = 0
		end
		self["heroHeadBox"..index]:setPosition(ccp(0, positionY))

		self["itemNode"..index]:addChild(self["heroHeadBox"..index])

		local maxNum = math.floor(self.prizeNum/2)
		local startPositionX = maxNum == 3 and -135 or -290
		local startPositionY = 45
		local lineGap = 175
		local rowGap = 145

		local itemNum = index > maxNum and index-maxNum or index
		local lineNum = index > maxNum and 2 or 1
		local posX = startPositionX + ((itemNum-1) * rowGap)
		local posY = startPositionY - ((lineNum-1) * lineGap)
		if self.prizeNum == 1 then
			posX = 0
			posY = 0
		end
		posY = posY + 30

		self["heroHeadBox"..index]:setPosition(posX, posY)
	end
	self.index = self.prizeNum+1
end

function QUIDialogMountChestAchieve:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_back) == false then return end
	if self.index <= self.prizeNum then return end
    app.sound:playSound("common_small")
    if self.confirmBack ~= nil then
    	self.confirmBack()
    end
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMountChestAchieve:_onTriggerAgain(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_again) == false then return end
	if self.index <= self.prizeNum then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	
    local againBack = self.againBack
	if againBack ~= nil then
		againBack({isAgain = true})
	end
end

return QUIDialogMountChestAchieve