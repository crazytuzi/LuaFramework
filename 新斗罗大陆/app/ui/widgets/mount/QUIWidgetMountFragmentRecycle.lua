local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountFragmentRecycle = class("QUIWidgetMountFragmentRecycle", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QNotificationCenter = import("....controllers.QNotificationCenter")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QScrollView = import("....views.QScrollView")
local QUIWidgetItemsBoxMount = import(".QUIWidgetItemsBoxMount")
local QTextFiledScrollUtils = import("....utils.QTextFiledScrollUtils")
local QUIViewController = import("...QUIViewController")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QShop = import("....utils.QShop")
local QUIWidgetShopTap = import("...widgets.QUIWidgetShopTap")
local QHerosUtils = import("....utils.QHerosUtils")
local QRichText = import("....utils.QRichText")

QUIWidgetMountFragmentRecycle.GAP = 10
QUIWidgetMountFragmentRecycle.MARGIN = 0
QUIWidgetMountFragmentRecycle.ENCHANT_PROMPT = "分解暗器碎片，将会返还%d暗器币，是否确认分解？"

QUIWidgetMountFragmentRecycle.NUMBER_TIME = 1

function QUIWidgetMountFragmentRecycle:ctor(options, dialogOptions)
	local ccbFile = "ccb/Widget_HeroRecover_mount2.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIWidgetMountFragmentRecycle.onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIWidgetMountFragmentRecycle.onTriggerRight)},
		{ccbCallbackName = "onTriggerRecycle", callback = handler(self, QUIWidgetMountFragmentRecycle.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, QUIWidgetMountFragmentRecycle.onTriggerExchange)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetMountFragmentRecycle.onTriggerRule)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, QUIWidgetMountFragmentRecycle.onTriggerShop)},
	}

	QUIWidgetMountFragmentRecycle.super.ctor(self,ccbFile,callBacks,options)

    q.setButtonEnableShadow(self._ccbOwner.btn_shop)
   
    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height

    self._ccbOwner.gain:setString(0)
    self:initExplainTTF()

    self._forceUpdate = QTextFiledScrollUtils.new()
    self._firstItem = nil
    self._defaultItem = dialogOptions and dialogOptions.itemId

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._selectEffectLayer = CCNode:create()
    page:getView():addChild(self._selectEffectLayer)
end

function QUIWidgetMountFragmentRecycle:onEnter()
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
    local gemBar = page.topBar:getBarForType(ITEM_TYPE.STORM_MONEY)
    local barGemIcon = gemBar:getIcon()
    barGemIcon:stopAllActions()
end

function QUIWidgetMountFragmentRecycle:onExit()
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
    local gemBar = page.topBar:getBarForType(ITEM_TYPE.STORM_MONEY)
    local barSoulIcon = gemBar:getIcon()
    barSoulIcon:stopAllActions()
end

--创建底部说明文字
function QUIWidgetMountFragmentRecycle:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "暗器碎片分解为",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "暗器币，",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "碎片",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "品质越高",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "暗器币越多",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "越多",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end


function QUIWidgetMountFragmentRecycle:getAvailableItems()
    local items = {}
    local db = QStaticDatabase:sharedDatabase()
    local config, actorId, characher ,value = nil, nil, nil
    for k, v in pairs(remote.items:getAllMountFragment()) do
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

function QUIWidgetMountFragmentRecycle:update()
  
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
    local x = QUIWidgetMountFragmentRecycle.MARGIN + self._itemSize.width/2 + 10
    local y = -self._height/2 + 20
    self._co = q.PlayRoutine(function ()
        for k, v in ipairs(gemFragment) do
            if not self._scrollView then break end
            self._scrollView:addItemBox(x, y, self._items[v.id])
            x = x + QUIWidgetMountFragmentRecycle.GAP + self._itemSize.width
            coroutine.yield() 
        end
    end)
    local scrollViewWidth = #gemFragment * (QUIWidgetMountFragmentRecycle.GAP + self._itemSize.width) + QUIWidgetMountFragmentRecycle.MARGIN + 10
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

function QUIWidgetMountFragmentRecycle:updateEnchantNumber()
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

    self._forceUpdate:addUpdate(self._gemNumber, gemNumber, handler(self, self._onForceUpdate), QUIWidgetMountFragmentRecycle.NUMBER_TIME)
    self._gemNumber = gemNumber

    self._ccbOwner.gain1:setString(0)
    self._ccbOwner.gain2:setString(0)
    for id, count in pairs(self._recycleItems) do
        -- self._ccbOwner.gain1:setString(count)
        if tostring(id) == "4200001" then
            self._ccbOwner.gain1:setString(count)
        elseif tostring(id) == "4200002" then
            self._ccbOwner.gain2:setString(count)
        end
    end

    for _, v in ipairs(self._itemObjects) do
        if v and v.setNeedshadow then
            v:setNeedshadow( false )
        end
    end
end

function QUIWidgetMountFragmentRecycle:_onForceUpdate(value)
    self._ccbOwner.gain:setString(tostring(math.ceil(value)))
end

function QUIWidgetMountFragmentRecycle:nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

-- Callbacks
function QUIWidgetMountFragmentRecycle:onTriggerLeft()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if math.abs(self._scrollView:getPositionX()) < self._width then
        self._scrollView:runToLeft(true)
    else
        local offset = math.ceil(math.abs(self._scrollView:getPositionX())/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-(offset - self._width), self._scrollView:getPositionY(), true)
    end
end

function QUIWidgetMountFragmentRecycle:onTriggerRight()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if self._scrollView:getWidth() - math.abs(self._scrollView:getPositionX()) < 2 * self._width then
        self._scrollView:runToRight(true)
    else
        local offset = math.floor((self._width + math.abs(self._scrollView:getPositionX()))/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-offset, self._scrollView:getPositionY(), true)
    end
end




function QUIWidgetMountFragmentRecycle:onTriggerRule()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 11}}, {isPopCurrentDialog = false})
end

function QUIWidgetMountFragmentRecycle:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.metalCityShop)
end

function QUIWidgetMountFragmentRecycle:onTriggerRecycle(event)
    if self._playing  then return end
    
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

    local compensations = {}
    if self._gemNumber > 0 then
        table.insert(compensations, {id = "stormMoney", value = self._gemNumber})
    end
    local number = self._gemNumber
    for id, count in pairs(self._recycleItems) do
        table.insert(compensations, {id = id, value = count})
        number = number + count
    end
    if number <= 0 then
        return
    end
    local callRecycleAPI = function()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        self:onTriggerRecycleFinished() 
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = compensations, callFunc = callRecycleAPI, title = "暗器碎片分解后将返还以下资源，是否确认分解暗器碎片"}})
end

function QUIWidgetMountFragmentRecycle:onTriggerRecycleFinished()
    app.sound:playSound("common_confirm")
    local items = {}
    for k, v in pairs(self._items) do
        if v.selectedCount > 0 then
            table.insert(items, {type = v.id, count = v.selectedCount})
        end
    end

    remote.mount:zuoqiPieceRecoverRequest(items, function ()
        print("gem recycle successfully")
        self:showRecycleFinishAnimation()
        end)
end

function QUIWidgetMountFragmentRecycle:onTriggerExchange()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantExchange"})
    
end

function QUIWidgetMountFragmentRecycle:showRecycleFinishAnimation()
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
            effect:stopAnimation()
            local awards = {}
            if self._gemNumber > 0 then
                table.insert(awards, {id = "stormMoney", typeName = ITEM_TYPE.STORM_MONEY, count = self._gemNumber})
            end
            for id, count in pairs(self._recycleItems) do
                if count > 0 then
                    table.insert(awards, {id = id, typeName = ITEM_TYPE.ITEM, count = count})
                end
            end
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards}}, {isPopCurrentDialog = false})

            self:update()
        end))

    local action = CCSequence:create(arr)
    self._ccbOwner.angelEffect1:runAction(action)
end


function QUIWidgetMountFragmentRecycle:setNodeCascadeOpacityEnabled( node )
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

function QUIWidgetMountFragmentRecycle:showSelectAnimation(item)

    local icon = QUIWidgetItemsBoxMount.new(true)
    icon:setGoodsInfo(item.id, ITEM_TYPE.ITEM, 0, false)
    -- icon:setNameVisibility(false)

    self:setNodeCascadeOpacityEnabled(icon)


    local p = item.itemWidget:convertToWorldSpaceAR(ccp(0,0))
    icon:setPosition(p.x, p.y)
    self._selectEffectLayer:addChild(icon)
    icon:setScale(0.8)
    local targetP = self._ccbOwner.effect:convertToWorldSpaceAR(ccp(0,0))
    local arr = CCArray:create()
    
    -- arr:addObject(CCMoveTo:create(0.4, targetP))
    local bezierConfig = ccBezierConfig:new()
    bezierConfig.endPosition = targetP
    bezierConfig.controlPoint_1 = ccp(p.x + (targetP.x - p.x) * 0.333, p.y + (targetP.y- p.y) * 0.8)
    bezierConfig.controlPoint_2 = ccp(p.x + (targetP.x - p.x) * 0.667, p.y + (targetP.y- p.y) * 1)
    local bezierTo = CCBezierTo:create(0.4, bezierConfig)
    arr:addObject(CCSpawn:createWithTwoActions(bezierTo,CCSequence:createWithTwoActions(CCDelayTime:create(0.2),CCFadeOut:create(0.4))))
    arr:addObject(CCCallFunc:create(function()
            icon:removeFromParentAndCleanup(true)
            -- local effectName = self._type == 1 and "effects/HeroRecover_yellow_boom.ccbi" or "effects/HeroRecover_yellow_boom_zi.ccbi"
            -- local effect = QUIWidgetAnimationPlayer.new()
            -- self._ccbOwner.effect:addChild(effect)
            -- effect:playAnimation(effectName, nil, nil)
        end))
    local seq = CCSequence:create(arr)
    icon:runAction(seq)
     
end

-- Item click event
function QUIWidgetMountFragmentRecycle:itemClickHandler(event)
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

function QUIWidgetMountFragmentRecycle:itemClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount ~= nil then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetMountFragmentRecycle:itemMinusClickHandler(event)
    if self._isMoving == true or self._playing then return end

    print("minus" .. event.itemID)
    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount > 0 then
        item.selectedCount = item.selectedCount - 1
        item.itemWidget = event.source
        item.itemWidget:setGoodsInfo(event.itemID, ITEM_TYPE.ITEM, item.selectedCount.."/"..item.count, true)
        item.itemWidget:showMinusButton(item.selectedCount > 0)
        self:updateEnchantNumber()
    end
end

function QUIWidgetMountFragmentRecycle:itemMinusClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount > 0 then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetMountFragmentRecycle:onScrollViewMoving()
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

function QUIWidgetMountFragmentRecycle:onScrollViewBegan( ... )
    self._isMoving = false
end

function QUIWidgetMountFragmentRecycle:onScrollViewFreeze( ... )
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



return QUIWidgetMountFragmentRecycle
