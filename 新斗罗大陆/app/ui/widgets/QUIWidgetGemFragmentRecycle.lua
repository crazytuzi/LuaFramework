--
-- Author: qinyuanji
-- Date: 2015-04-02 17:14:49
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemFragmentRecycle = class("QUIWidgetGemFragmentRecycle", QUIWidget)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QUIWidgetItemsBoxGem = import("..widgets.QUIWidgetItemsBoxGem")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")
local QShop = import("...utils.QShop")
local QUIWidgetShopTap = import("..widgets.QUIWidgetShopTap")
local QHerosUtils = import("...utils.QHerosUtils")
local QRichText = import("...utils.QRichText")

QUIWidgetGemFragmentRecycle.GAP = 10
QUIWidgetGemFragmentRecycle.MARGIN = 0
QUIWidgetGemFragmentRecycle.ENCHANT_PROMPT = "分解魂骨碎片，将会返还%d魂骨币，是否确认分解？"

QUIWidgetGemFragmentRecycle.NUMBER_TIME = 1

function QUIWidgetGemFragmentRecycle:ctor(options, dialogOptions)
	local ccbFile = "ccb/Widget_HeroRecover_baoshi.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIWidgetGemFragmentRecycle.onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIWidgetGemFragmentRecycle.onTriggerRight)},
		{ccbCallbackName = "onTriggerRecycle", callback = handler(self, QUIWidgetGemFragmentRecycle.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, QUIWidgetGemFragmentRecycle.onTriggerExchange)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetGemFragmentRecycle.onTriggerRule)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, QUIWidgetGemFragmentRecycle.onTriggerShop)},
	}

	QUIWidgetGemFragmentRecycle.super.ctor(self,ccbFile,callBacks,options)

   
    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height

    self._ccbOwner.gain:setString(0)
    self._ccbOwner.gain1:setString(0)
    self:initExplainTTF()
    q.setButtonEnableShadow(self._ccbOwner.btn_spar_shop)

    self._forceUpdate = QTextFiledScrollUtils.new()
    self._firstItem = nil
    self._defaultItem = dialogOptions and dialogOptions.itemId

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._selectEffectLayer = CCNode:create()
    page:getView():addChild(self._selectEffectLayer)
end

function QUIWidgetGemFragmentRecycle:onEnter()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._width, self._height), {bufferMode = 2, sensitiveDistance = 30, nodeAR = ccp(0.5, 0.5)})

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self.onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.FREEZE, handler(self, self.onScrollViewFreeze))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self.onScrollViewBegan))
    
    self._scheduler = scheduler.performWithDelayGlobal(function ( ... )
        self._itemSize, self._itemObjects = self._scrollView:setCacheNumber(10, "widgets.QUIWidgetItemsBoxGem")
        for _, item in ipairs(self._itemObjects) do
            item:addEventListener(QUIWidgetItemsBoxGem.EVENT_CLICK, handler(self, self.itemClickHandler))
            item:addEventListener(QUIWidgetItemsBoxGem.EVENT_CLICK_END, handler(self, self.itemClickEndHandler))
            item:addEventListener(QUIWidgetItemsBoxGem.EVENT_MINUS_CLICK, handler(self, self.itemMinusClickHandler))
            item:addEventListener(QUIWidgetItemsBoxGem.EVENT_MINUS_CLICK_END, handler(self, self.itemMinusClickEndHandler))
        end
        self:update()
    end, 0)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    local gemBar = page.topBar:getBarForType(ITEM_TYPE.SILVERMINE_MONEY)
    local barGemIcon = gemBar:getIcon()
    barGemIcon:stopAllActions()
end

function QUIWidgetGemFragmentRecycle:onExit()
    -- q.RemoveRoutine(self._co)

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

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    local gemBar = page.topBar:getBarForType(ITEM_TYPE.SILVERMINE_MONEY)
    local barSoulIcon = gemBar:getIcon()
    barSoulIcon:stopAllActions()
end

--创建底部说明文字
function QUIWidgetGemFragmentRecycle:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "魂骨碎片分解为",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "魂骨币，",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "碎片",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "品质越高",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "魂骨币",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "越多",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end


function QUIWidgetGemFragmentRecycle:getAvailableItems()
    local items = {}
    local db = QStaticDatabase:sharedDatabase()
    local config, actorId, characher ,value = nil, nil, nil
    for k, v in pairs(remote.items:getAllGemFragment()) do
        config = db:getItemByID(v.type)
        local selectedCount = 0
        if v.type == self._defaultItem then
            selectedCount = v.count
        end
        value = {id = v.type, count = v.count, selectedCount = selectedCount, item_id = config.id, gemstone_quality = config.gemstone_quality, gemstone_type = config.gemstone_type}
        items[v.type] = value  -- Here v.type is the item id
    end

    return items
end

function QUIWidgetGemFragmentRecycle:update()
  
    self._scrollView:clearCache()

    self._gemNumber = 0
    self._items = self:getAvailableItems()

    -- sort material by id
    local gemFragment = {}
    for k, v in pairs(self._items) do
        table.insert(gemFragment, {id = k, value = v})
    end
	table.sort(gemFragment, function (x, y) 
			if x.value.gemstone_quality > y.value.gemstone_quality then
				return true
			elseif x.value.gemstone_quality < y.value.gemstone_quality then
				return false
			else
				return x.value.gemstone_type > y.value.gemstone_type 
			end
	    end)

    -- set correct position for each item
    local x = QUIWidgetGemFragmentRecycle.MARGIN + self._itemSize.width/2 + 10
    local y = -self._height/2 + 20
    -- self._co = q.PlayRoutine(function ()
        for k, v in ipairs(gemFragment) do
            if not self._scrollView then break end
            self._scrollView:addItemBox(x, y, self._items[v.id])
            x = x + QUIWidgetGemFragmentRecycle.GAP + self._itemSize.width
            -- coroutine.yield() 
        end
    -- end)
    local scrollViewWidth = #gemFragment * (QUIWidgetGemFragmentRecycle.GAP + self._itemSize.width) + QUIWidgetGemFragmentRecycle.MARGIN + 10
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

    -- self._recycleMoney:setMoney(remote.user.soulMoney)
end

function QUIWidgetGemFragmentRecycle:updateEnchantNumber()
    local gemNumber = 0
    self._recycleItems = {}
    for k, v in pairs(self._items) do
        if v.selectedCount > 0 then
            local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(v.id)
            gemNumber = gemNumber + itemInfo.gemstone_recycle * v.selectedCount

            local itemRecycle = itemInfo.item_recycle
            if itemRecycle then
                local items = string.split(itemRecycle, ";")
                for k, value in ipairs(items) do
                    local item = string.split(value, "^")
                    local id = tonumber(item[1])
                    local count = item[2]
                    self._recycleItems[id] = (self._recycleItems[id] or 0) + (count or 0)*v.selectedCount
                end
            end
        end
    end

    if gemNumber > self._gemNumber then
        self:nodeEffect(self._ccbOwner.gain)
    end

    self._forceUpdate:addUpdate(self._gemNumber, gemNumber, handler(self, self._onForceUpdate), QUIWidgetGemFragmentRecycle.NUMBER_TIME)
    self._gemNumber = gemNumber
    
    self._ccbOwner.gain1:setString(0)
    for id, count in pairs(self._recycleItems) do
        self._ccbOwner.gain1:setString(count)
    end

    for _, v in ipairs(self._itemObjects) do
        if v and v.setNeedshadow then
            v:setNeedshadow( false )
        end
    end
end

function QUIWidgetGemFragmentRecycle:_onForceUpdate(value)
    self._ccbOwner.gain:setString(tostring(math.ceil(value)))
end

function QUIWidgetGemFragmentRecycle:nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

-- Callbacks
function QUIWidgetGemFragmentRecycle:onTriggerLeft()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if math.abs(self._scrollView:getPositionX()) < self._width then
        self._scrollView:runToLeft(true)
    else
        local offset = math.ceil(math.abs(self._scrollView:getPositionX())/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-(offset - self._width), self._scrollView:getPositionY(), true)
    end
end

function QUIWidgetGemFragmentRecycle:onTriggerRight()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if self._scrollView:getWidth() - math.abs(self._scrollView:getPositionX()) < 2 * self._width then
        self._scrollView:runToRight(true)
    else
        local offset = math.floor((self._width + math.abs(self._scrollView:getPositionX()))/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-offset, self._scrollView:getPositionY(), true)
    end
end




function QUIWidgetGemFragmentRecycle:onTriggerRule()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 6}}, {isPopCurrentDialog = false})
end

function QUIWidgetGemFragmentRecycle:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIWidgetGemFragmentRecycle:onTriggerRecycle(event)
    if self._playing or self._gemNumber == 0 then return end
    
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

    local compensations = {}
    table.insert(compensations, {id = "silvermineMoney", value = self._gemNumber})
    for id, count in pairs(self._recycleItems) do
        table.insert(compensations, {id = id, value = count})
    end

    local callRecycleAPI = function()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        self:onTriggerRecycleFinished() 
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = compensations,title = "魂骨碎片分解后将返还以下资源，是否确认分解该魂骨碎片", callFunc = callRecycleAPI}})
end

function QUIWidgetGemFragmentRecycle:onTriggerRecycleFinished()
    app.sound:playSound("common_confirm")
    local items = {}
    for k, v in pairs(self._items) do
        if v.selectedCount > 0 then
            table.insert(items, {type = v.id, count = v.selectedCount})
        end
    end

    app:getClient():materialRecycle(items, 0, function ()
            self:showRecycleFinishAnimation()
        end)
end

function QUIWidgetGemFragmentRecycle:onTriggerExchange()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantExchange"})
    
end

function QUIWidgetGemFragmentRecycle:showRecycleFinishAnimation()
    self._playing = true
    self._ccbOwner.angelEffect:setVisible(false)
    local effectName = "effects/chongsheng_huolu2.ccbi"
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.angelEffect1:addChild(effect)
    effect:playAnimation(effectName, nil,nil,false)
    effect:setPositionY(-100)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.5))
    arr:addObject(CCCallFunc:create(function() 
            self._playing = false 
            local awards = {}
            table.insert(awards, {id = "silvermineMoney", typeName = ITEM_TYPE.SILVERMINE_MONEY, count = self._gemNumber})
            for id, count in pairs(self._recycleItems) do
                table.insert(awards, {id = id, typeName = ITEM_TYPE.ITEM, count = count})
            end
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards}}, {isPopCurrentDialog = false})

            self:update()
            effect:stopAnimation()
        end))

    local action = CCSequence:create(arr)
    self._ccbOwner.angelEffect1:runAction(action)
end


function QUIWidgetGemFragmentRecycle:setNodeCascadeOpacityEnabled( node )
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

function QUIWidgetGemFragmentRecycle:showSelectAnimation(item)

    local icon = QUIWidgetItemsBoxGem.new(true)
    icon:setGoodsInfo(item.id, ITEM_TYPE.GEMSTONE_PIECE, "", false)
    icon:setNameVisibility(false)

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
function QUIWidgetGemFragmentRecycle:itemClickHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil then
        if item.selectedCount < item.count then
           
          
            item.selectedCount = item.count
            
            item.itemWidget = event.source
            item.itemWidget:setGoodsInfo(item.id, ITEM_TYPE.GEMSTONE_PIECE, item.selectedCount .. "/" .. item.count, true)
            item.itemWidget:showMinusButton(item.selectedCount > 0)
            self:updateEnchantNumber()
            self:showSelectAnimation(item)
        else
            app.tip:floatTip("所选道具数量已达上限")
        end
    end
end

function QUIWidgetGemFragmentRecycle:itemClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount ~= nil then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetGemFragmentRecycle:itemMinusClickHandler(event)
    if self._isMoving == true or self._playing then return end

    print("minus" .. event.itemID)
    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount > 0 then
        item.selectedCount = item.selectedCount - 1
        item.itemWidget = event.source
        item.itemWidget:setGoodsInfo(event.itemID, ITEM_TYPE.GEMSTONE_PIECE, item.selectedCount.."/"..item.count, true)
        item.itemWidget:showMinusButton(item.selectedCount > 0)
        self:updateEnchantNumber()
    end
end

function QUIWidgetGemFragmentRecycle:itemMinusClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount > 0 then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetGemFragmentRecycle:onScrollViewMoving()
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

function QUIWidgetGemFragmentRecycle:onScrollViewBegan( ... )
    self._isMoving = false
end

function QUIWidgetGemFragmentRecycle:onScrollViewFreeze( ... )
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



return QUIWidgetGemFragmentRecycle
