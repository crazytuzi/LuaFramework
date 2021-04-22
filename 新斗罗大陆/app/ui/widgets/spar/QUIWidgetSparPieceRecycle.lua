-- @Author: xurui
-- @Date:   2017-04-10 20:33:34
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-15 20:42:25
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparPieceRecycle = class("QUIWidgetSparPieceRecycle", QUIWidget)

local QNotificationCenter = import("....controllers.QNotificationCenter")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QScrollView = import("....views.QScrollView")
local QUIWidgetItemsBoxMount = import("...widgets.mount.QUIWidgetItemsBoxMount")
local QTextFiledScrollUtils = import("....utils.QTextFiledScrollUtils")
local QUIViewController = import("...QUIViewController")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QShop = import("....utils.QShop")
local QUIWidgetShopTap = import("...widgets.QUIWidgetShopTap")
local QHerosUtils = import("....utils.QHerosUtils")
local QRichText = import("....utils.QRichText")

QUIWidgetSparPieceRecycle.GAP = 10
QUIWidgetSparPieceRecycle.MARGIN = 0
QUIWidgetSparPieceRecycle.ENCHANT_PROMPT = "分解外附魂骨碎片，将会返还%d地狱币，是否确认分解？"

QUIWidgetSparPieceRecycle.NUMBER_TIME = 1

function QUIWidgetSparPieceRecycle:ctor(options, dialogOptions)
	local ccbFile = "ccb/Widget_HeroRecover_baoshi.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIWidgetSparPieceRecycle.onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIWidgetSparPieceRecycle.onTriggerRight)},
		{ccbCallbackName = "onTriggerRecycle", callback = handler(self, QUIWidgetSparPieceRecycle.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, QUIWidgetSparPieceRecycle.onTriggerExchange)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetSparPieceRecycle.onTriggerRule)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, QUIWidgetSparPieceRecycle.onTriggerShop)},
	}

	QUIWidgetSparPieceRecycle.super.ctor(self,ccbFile,callBacks,options)

   
    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height

    self._ccbOwner.gain:setString(0)
    self:initExplainTTF()
    q.setButtonEnableShadow(self._ccbOwner.btn_spar_shop)

    self._forceUpdate = QTextFiledScrollUtils.new()
    self._firstItem = nil
    self._defaultItem = dialogOptions and dialogOptions.itemId

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._selectEffectLayer = CCNode:create()
    page:getView():addChild(self._selectEffectLayer)

    local itemInfo = remote.items:getWalletByType(ITEM_TYPE.JEWELRY_MONEY)
    if itemInfo and itemInfo.alphaIcon then
        self._ccbOwner.sp_money_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(itemInfo.alphaIcon))
        self._ccbOwner.sp_money_icon:setScale(0.6)
    end
    self._ccbOwner.node_spar_shop:setVisible(true)
    self._ccbOwner.store:setVisible(false)
    self._ccbOwner.node_gain:setVisible(false)
    self._ccbOwner.gain:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.gain:setPositionX(14)
end

function QUIWidgetSparPieceRecycle:onEnter()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._width, self._height), {bufferMode = 2, sensitiveDistance = 30, nodeAR = ccp(0.5, 0.5)})

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self.onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.FREEZE, handler(self, self.onScrollViewFreeze))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self.onScrollViewBegan))
    
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetItemsBoxMount.EVENT_CLICK, self.itemClickHandler, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetItemsBoxMount.EVENT_CLICK_END, self.itemClickEndHandler, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetItemsBoxMount.EVENT_MINUS_CLICK, self.itemMinusClickHandler, self)
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetItemsBoxMount.EVENT_MINUS_CLICK_END, self.itemMinusClickEndHandler, self)

    self._scheduler = scheduler.performWithDelayGlobal(function ( ... )
        self._itemSize, self._itemObjects = self._scrollView:setCacheNumber(10, "widgets.QUIWidgetItemsBoxMount")
        self:update()
    end, 0)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    local gemBar = page.topBar:getBarForType(ITEM_TYPE.JEWELRY_MONEY)
    local barGemIcon = gemBar:getIcon()
    barGemIcon:stopAllActions()
end

function QUIWidgetSparPieceRecycle:onExit()
    q.RemoveRoutine(self._co)

    if self._forceUpdate then
        self._forceUpdate:stopUpdate()
        self._forceUpdate = nil
    end
    if self._selectEffectLayer then
        self._selectEffectLayer:removeFromParentAndCleanup()
    end

    if self._scheduler ~= nil then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetItemsBoxMount.EVENT_CLICK, self.itemClickHandler,self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetItemsBoxMount.EVENT_CLICK_END, self.itemClickEndHandler, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetItemsBoxMount.EVENT_MINUS_CLICK, self.itemMinusClickHandler,self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetItemsBoxMount.EVENT_MINUS_CLICK_END, self.itemMinusClickEndHandler, self)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    local gemBar = page.topBar:getBarForType(ITEM_TYPE.JEWELRY_MONEY)
    local barSoulIcon = gemBar:getIcon()
    barSoulIcon:stopAllActions()
end

--创建底部说明文字
function QUIWidgetSparPieceRecycle:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "外附魂骨碎片分解为",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "地狱币",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end


function QUIWidgetSparPieceRecycle:getAvailableItems()
    local items = {}
    local db = QStaticDatabase:sharedDatabase()
    local config, actorId, characher ,value = nil, nil, nil
    for k, v in pairs(remote.items:getAllSparFragment()) do
        config = db:getItemByID(v.type)
        if config and config.item_recycle then
            local selectedCount = 0
            if v.type == self._defaultItem then
                selectedCount = v.count
            end
            value = {id = v.type, count = v.count, selectedCount = selectedCount, item_id = config.id}
            items[v.type] = value  -- Here v.type is the item id
        end
    end

    return items
end

function QUIWidgetSparPieceRecycle:update()
  
    self._scrollView:clearCache()

    self._gemNumber = 0
    self._items = self:getAvailableItems()

    -- sort material by id
    local gemFragment = {}
    for k, v in pairs(self._items) do
        table.insert(gemFragment, {id = k, value = v})
    end
	table.sort(gemFragment, function (x, y) 
			if x.value.count ~= y.value.count then
				return x.value.count > y.value.count 
			else
				return x.id < y.id
			end
	    end)

    -- set correct position for each item
    local x = QUIWidgetSparPieceRecycle.MARGIN + self._itemSize.width/2 + 10
    local y = -self._height/2 + 20
    self._co = q.PlayRoutine(function ()
        for k, v in ipairs(gemFragment) do
            if not self._scrollView then break end
            self._scrollView:addItemBox(x, y, self._items[v.id])
            x = x + QUIWidgetSparPieceRecycle.GAP + self._itemSize.width
            coroutine.yield() 
        end
    end)
    local scrollViewWidth = #gemFragment * (QUIWidgetSparPieceRecycle.GAP + self._itemSize.width) + QUIWidgetSparPieceRecycle.MARGIN + 10
    if scrollViewWidth <= self._width then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    else
        self._ccbOwner.arrowLeft:setVisible(true)
        self._ccbOwner.arrowRight:setVisible(true)
    end
    self._scrollView:setRect(0, -self._height, 0, scrollViewWidth)
    self:onScrollViewFreeze()
    self._firstItem = gemFragment[1] and self._items[gemFragment[1].id] or nil

    self:updateEnchantNumber()
end

function QUIWidgetSparPieceRecycle:updateEnchantNumber()
    local gemNumber = 0
    for k, v in pairs(self._items) do
        if v.selectedCount > 0 then
        	local itemNum = QStaticDatabase:sharedDatabase():getItemByID(v.id).item_recycle
        	itemNum = string.split(itemNum, "^")
            gemNumber = gemNumber + tonumber(itemNum[2]) * v.selectedCount
        end
    end

    if gemNumber > self._gemNumber then
        self:nodeEffect(self._ccbOwner.gain)
    end

    self._forceUpdate:addUpdate(self._gemNumber, gemNumber, handler(self, self._onForceUpdate), QUIWidgetSparPieceRecycle.NUMBER_TIME)
    self._gemNumber = gemNumber

    for _, v in ipairs(self._itemObjects) do
        if v and v.setNeedshadow then
            v:setNeedshadow( false )
        end
    end
end

function QUIWidgetSparPieceRecycle:_onForceUpdate(value)
    self._ccbOwner.gain:setString(tostring(math.ceil(value)))
end

function QUIWidgetSparPieceRecycle:nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

-- Callbacks
function QUIWidgetSparPieceRecycle:onTriggerLeft()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if math.abs(self._scrollView:getPositionX()) < self._width then
        self._scrollView:runToLeft(true)
    else
        local offset = math.ceil(math.abs(self._scrollView:getPositionX())/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-(offset - self._width), self._scrollView:getPositionY(), true)
    end
end

function QUIWidgetSparPieceRecycle:onTriggerRight()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if self._scrollView:getWidth() - math.abs(self._scrollView:getPositionX()) < 2 * self._width then
        self._scrollView:runToRight(true)
    else
        local offset = math.floor((self._width + math.abs(self._scrollView:getPositionX()))/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-offset, self._scrollView:getPositionY(), true)
    end
end




function QUIWidgetSparPieceRecycle:onTriggerRule()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 14}}, {isPopCurrentDialog = false})
end

function QUIWidgetSparPieceRecycle:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    
    remote.stores:openShopDialog(SHOP_ID.sparShop)
end

function QUIWidgetSparPieceRecycle:onTriggerRecycle(event)
    if self._playing or self._gemNumber == 0 then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

    local moneyNumber = self._gemNumber
    app:alert({content = string.format(QUIWidgetSparPieceRecycle.ENCHANT_PROMPT , self._gemNumber), 
        title = "系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
               self:onTriggerRecycleFinished(moneyNumber) 
            end
        end})
end

function QUIWidgetSparPieceRecycle:onTriggerRecycleFinished(moneyNumber)
    app.sound:playSound("common_confirm")
    local items = {}
    for k, v in pairs(self._items) do
        if v.selectedCount > 0 then
            table.insert(items, {type = v.id, count = v.selectedCount})
        end
    end

    remote.spar:requestSparReturn({}, items, function()
            self:showRecycleFinishAnimation(moneyNumber)
        end)
end

function QUIWidgetSparPieceRecycle:onTriggerExchange()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantExchange"})
    
end

function QUIWidgetSparPieceRecycle:showRecycleFinishAnimation(moneyNumber)
    self._playing = true
    self._ccbOwner.angelEffect:setVisible(false)
    local effectName = "effects/chongsheng_huolu2.ccbi"
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.angelEffect1:addChild(effect)
    effect:playAnimation(effectName, nil,nil,false)
    effect:setPositionY(-100)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(1))
    arr:addObject(CCCallFunc:create(function() 
            self._playing = false 
            self:update()
            effect:stopAnimation()
            local awards = {}
            table.insert(awards, {id = "jewelryMoney", typeName = ITEM_TYPE.JEWELRY_MONEY, count = moneyNumber or 0})
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards}}, {isPopCurrentDialog = false})
        end))

    local action = CCSequence:create(arr)
    self._ccbOwner.angelEffect1:runAction(action)
end


function QUIWidgetSparPieceRecycle:setNodeCascadeOpacityEnabled( node )
    -- body
    if node then
        node:setCascadeOpacityEnabled(true)
        local children = node:getChildren()
        if children then
            for index = 0, children:count()-1, 1 do
                local tempNode = children:objectAtIndex(index)
                local tempNode = tolua.cast(tempNode, "CCNode")
                if tempNode then
                    self:setNodeCascadeOpacityEnabled(tempNode)
                end
            end
        end
    end
end

function QUIWidgetSparPieceRecycle:showSelectAnimation(item)
    local icon = QUIWidgetItemsBoxMount.new(true)
    icon:setGoodsInfo(item.id, ITEM_TYPE.ITEM, 0, false)

    self:setNodeCascadeOpacityEnabled(icon)

    local p = item.itemWidget:convertToWorldSpaceAR(ccp(0,0))
    icon:setPosition(p.x, p.y)
    self._selectEffectLayer:addChild(icon)
    icon:setScale(0.8)
    local targetP = self._ccbOwner.effect:convertToWorldSpaceAR(ccp(0,0))
    local arr = CCArray:create()
    
    local bezierConfig = ccBezierConfig:new()
    bezierConfig.endPosition = targetP
    bezierConfig.controlPoint_1 = ccp(p.x + (targetP.x - p.x) * 0.333, p.y + (targetP.y- p.y) * 0.8)
    bezierConfig.controlPoint_2 = ccp(p.x + (targetP.x - p.x) * 0.667, p.y + (targetP.y- p.y) * 1)
    local bezierTo = CCBezierTo:create(0.4, bezierConfig)
    arr:addObject(CCSpawn:createWithTwoActions(bezierTo,CCSequence:createWithTwoActions(CCDelayTime:create(0.2),CCFadeOut:create(0.4))))
    arr:addObject(CCCallFunc:create(function()
            icon:removeFromParentAndCleanup(true)
        end))
    local seq = CCSequence:create(arr)
    icon:runAction(seq)
end

-- Item click event
function QUIWidgetSparPieceRecycle:itemClickHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil then
        if item.selectedCount < item.count then
           
          
            item.selectedCount = item.count
            
            item.itemWidget = event.source
            item.itemWidget:setGoodsInfo(item.id, ITEM_TYPE.ITEM, item.selectedCount .. "/" .. item.count, true)
            item.itemWidget:showMinusButton(item.selectedCount > 0)
            self:updateEnchantNumber()
            self:showSelectAnimation(item)
        else
            app.tip:floatTip("所选道具数量已达上限")
        end
    end
end

function QUIWidgetSparPieceRecycle:itemClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount ~= nil then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetSparPieceRecycle:itemMinusClickHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount > 0 then
        item.selectedCount = item.selectedCount - 1
        item.itemWidget = event.source
        item.itemWidget:setGoodsInfo(event.itemID, ITEM_TYPE.ITEM, item.selectedCount.."/"..item.count, true)
        item.itemWidget:showMinusButton(item.selectedCount > 0)
        self:updateEnchantNumber()
    end
end

function QUIWidgetSparPieceRecycle:itemMinusClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount > 0 then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetSparPieceRecycle:onScrollViewMoving()
    self._isMoving = true

    if self._scrollView:getPositionX() >= 0 then
        self._ccbOwner.arrowLeft:setVisible(false)
    else
        self._ccbOwner.arrowLeft:setVisible(true)
    end
    if -self._scrollView:getPositionX() + self._width >= self._scrollView:getWidth() then
        self._ccbOwner.arrowRight:setVisible(false)
    else
        self._ccbOwner.arrowRight:setVisible(true)
    end 
end

function QUIWidgetSparPieceRecycle:onScrollViewBegan( ... )
    self._isMoving = false
end

function QUIWidgetSparPieceRecycle:onScrollViewFreeze( ... )
    if self._scrollView:getPositionX() >= 0 then
        self._ccbOwner.arrowLeft:setVisible(false)
    else
        self._ccbOwner.arrowLeft:setVisible(true)
    end
    if -self._scrollView:getPositionX() + self._width >= self._scrollView:getWidth() then
        self._ccbOwner.arrowRight:setVisible(false)
    else
        self._ccbOwner.arrowRight:setVisible(true)
    end 
end

return QUIWidgetSparPieceRecycle