--
-- Author: qinyuanji
-- Date: 2015-04-02 17:14:49
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEnchantRecycle = class("QUIWidgetEnchantRecycle", QUIWidget)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QUIWidgetItemsBoxEnchant = import("..widgets.QUIWidgetItemsBoxEnchant")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QShop = import("...utils.QShop")
local QUIWidgetShopTap = import("..widgets.QUIWidgetShopTap")
local QHerosUtils = import("...utils.QHerosUtils")
local QRichText = import("...utils.QRichText")

QUIWidgetEnchantRecycle.GAP = 10
QUIWidgetEnchantRecycle.MARGIN = 0
QUIWidgetEnchantRecycle.ENCHANT_PROMPT = "分解觉醒材料，将会返还%d觉醒积分，是否确认分解？"

QUIWidgetEnchantRecycle.NUMBER_TIME = 1

function QUIWidgetEnchantRecycle:ctor(options)
	local ccbFile = "ccb/Widget_HeroRecover_fumo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIWidgetEnchantRecycle.onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIWidgetEnchantRecycle.onTriggerRight)},
		{ccbCallbackName = "onTriggerRecycle", callback = handler(self, QUIWidgetEnchantRecycle.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, QUIWidgetEnchantRecycle.onTriggerExchange)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetEnchantRecycle.onTriggerRule)},
	}

	QUIWidgetEnchantRecycle.super.ctor(self,ccbFile,callBacks,options)

   
    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height

   
    self._ccbOwner.gain:setString(0)

    self._forceUpdate = QTextFiledScrollUtils.new()
    self._firstItem = nil
    self:initExplainTTF()

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._selectEffectLayer = CCNode:create()
    page:getView():addChild(self._selectEffectLayer)
end

function QUIWidgetEnchantRecycle:initExplainTTF( )
 	local  richText = QRichText.new({
        {oType = "font", content = "25%~100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "觉醒积分",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "，所属的魂师",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "品质越高",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "觉醒积分",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "越多",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})
   
   
    if richText then
        self._ccbOwner.explainTTF:addChild(richText)
    end
end

function QUIWidgetEnchantRecycle:onEnter()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._width, self._height), {bufferMode = 2, sensitiveDistance = 30, nodeAR = ccp(0.5, 0.5)})

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self.onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.FREEZE, handler(self, self.onScrollViewFreeze))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self.onScrollViewBegan))
    
    self._scheduler = scheduler.performWithDelayGlobal(function ( ... )
        self._itemSize, self._itemObjects = self._scrollView:setCacheNumber(10, "widgets.QUIWidgetItemsBoxEnchant")
        for _, item in ipairs(self._itemObjects) do
            item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_CLICK, handler(self, self.itemClickHandler))
            item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_CLICK_END, handler(self, self.itemClickEndHandler))
            item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK, handler(self, self.itemMinusClickHandler))
            item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK_END, handler(self, self.itemMinusClickEndHandler))
        end
        self:update()
    end, 0)
end

function QUIWidgetEnchantRecycle:onExit()
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

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    local soulBar = page.topBar:getBarForType(ITEM_TYPE.ENCHANT_SCORE)
    local barSoulIcon = soulBar:getIcon()
    barSoulIcon:stopAllActions()
end

function QUIWidgetEnchantRecycle:getAvailableItems()
    local items = {}
    local db = QStaticDatabase:sharedDatabase()
    local config, actorId, characher ,value = nil, nil, nil
    for k, v in pairs(remote.items:getAllRecycleEnchant()) do
        config = db:getItemByID(v.type)
        if not config.item_recycle then
            value = {id = v.type, count = v.count, selectedCount = 0, item_id = config.id, score_recyle = config.score_recyle or 0, enchant_recovery_classify = config.enchant_recovery_classify or 0}
            items[v.type] = value  -- Here v.type is the item id
        end
    end

    return items
end

function QUIWidgetEnchantRecycle:update()
  
    self._scrollView:clearCache()

    self._enchantNumber = 0
    self._items = self:getAvailableItems()

    -- sort material by id
    local enchants = {}
    for k, v in pairs(self._items) do
        table.insert(enchants, {id = k, value = v})
    end
	table.sort(enchants, function (x, y) 
			if x.value.enchant_recovery_classify < y.value.enchant_recovery_classify then
				return true
			elseif x.value.enchant_recovery_classify > y.value.enchant_recovery_classify then
				return false
			else
				return x.value.score_recyle < y.value.score_recyle 
			end
	    end)


    -- set correct position for each item
    local x = QUIWidgetEnchantRecycle.MARGIN + self._itemSize.width/2 + 10
    local y = -self._height/2 + 20
    self._co = q.PlayRoutine(function ()
        for k, v in ipairs(enchants) do
            if not self._scrollView then break end
            self._scrollView:addItemBox(x, y, self._items[v.id])
            x = x + QUIWidgetEnchantRecycle.GAP + self._itemSize.width
            coroutine.yield() 
        end
    end)
    local scrollViewWidth = #enchants * (QUIWidgetEnchantRecycle.GAP + self._itemSize.width) + QUIWidgetEnchantRecycle.MARGIN + 10
    if scrollViewWidth <= self._width then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    else
        self._ccbOwner.arrowLeft:setVisible(true)
        self._ccbOwner.arrowRight:setVisible(true)
    end
    self._scrollView:setRect(0, -self._height, 0, scrollViewWidth)
    self._firstItem = enchants[1] and self._items[enchants[1].id] or nil

    self:updateEnchantNumber()
end

function QUIWidgetEnchantRecycle:updateEnchantNumber()
    local enchantNumber = 0
    for k, v in pairs(self._items) do
        if v.selectedCount > 0 then
            enchantNumber = enchantNumber + QStaticDatabase:sharedDatabase():getItemByID(v.id).score_recyle * v.selectedCount
        end
    end

    if enchantNumber > self._enchantNumber then
        self:nodeEffect(self._ccbOwner.gain)
    end

    self._forceUpdate:addUpdate(self._enchantNumber, enchantNumber, handler(self, self._onForceUpdate), QUIWidgetEnchantRecycle.NUMBER_TIME)
    self._enchantNumber = enchantNumber

    for _, v in ipairs(self._itemObjects) do
        if v and v.setNeedshadow then
            v:setNeedshadow( false )
        end
    end
end

function QUIWidgetEnchantRecycle:_onForceUpdate(value)
    self._ccbOwner.gain:setString(tostring(math.ceil(value)))
end

function QUIWidgetEnchantRecycle:nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

-- Callbacks
function QUIWidgetEnchantRecycle:onTriggerLeft()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if math.abs(self._scrollView:getPositionX()) < self._width then
        self._scrollView:runToLeft(true)
    else
        local offset = math.ceil(math.abs(self._scrollView:getPositionX())/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-(offset - self._width), self._scrollView:getPositionY(), true)
    end
end

function QUIWidgetEnchantRecycle:onTriggerRight()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if self._scrollView:getWidth() - math.abs(self._scrollView:getPositionX()) < 2 * self._width then
        self._scrollView:runToRight(true)
    else
        local offset = math.floor((self._width + math.abs(self._scrollView:getPositionX()))/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-offset, self._scrollView:getPositionY(), true)
    end
end




function QUIWidgetEnchantRecycle:onTriggerRule()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 5}}, {isPopCurrentDialog = false})
end

function QUIWidgetEnchantRecycle:onTriggerRecycle(event)
    if self._playing or self._enchantNumber == 0 then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

    app:alert({content = string.format(QUIWidgetEnchantRecycle.ENCHANT_PROMPT , self._enchantNumber), 
        title = "系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:onTriggerRecycleFinished()
            end
        end})
end

function QUIWidgetEnchantRecycle:onTriggerRecycleFinished()
    app.sound:playSound("common_confirm")
    local items = {}
    for k, v in pairs(self._items) do
        if v.selectedCount > 0 then
            table.insert(items, {type = v.id, count = v.selectedCount})
        end
    end

    local awards = {}
    table.insert(awards, {id = "enchantScore", typeName = ITEM_TYPE.ENCHANT_SCORE, count = self._enchantNumber})
    app:getClient():enchantRecycle(items, function ()
        print("enchant recycle successfully")
            self:showRecycleFinishAnimation(awards)
        end)
end

function QUIWidgetEnchantRecycle:onTriggerExchange()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantExchange"})
    
end

function QUIWidgetEnchantRecycle:showRecycleFinishAnimation(awards)
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
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards}}, {isPopCurrentDialog = false})
        end))

    local action = CCSequence:create(arr)
    self._ccbOwner.angelEffect1:runAction(action)
end


function QUIWidgetEnchantRecycle:setNodeCascadeOpacityEnabled( node )
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

function QUIWidgetEnchantRecycle:showSelectAnimation(item)

    local icon = QUIWidgetItemsBoxEnchant.new(true)
    icon:setGoodsInfo(item.id, ITEM_TYPE.ITEM, 0, false)
    icon:setNameVisibility(false)

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
function QUIWidgetEnchantRecycle:itemClickHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil then
        if item.selectedCount < item.count then
           
          
            item.selectedCount = item.selectedCount + 1
            
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

function QUIWidgetEnchantRecycle:itemClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount ~= nil then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetEnchantRecycle:itemMinusClickHandler(event)
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

function QUIWidgetEnchantRecycle:itemMinusClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount > 0 then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetEnchantRecycle:onScrollViewMoving()
    self._isMoving = true
end

function QUIWidgetEnchantRecycle:onScrollViewBegan( ... )
    self._isMoving = false
end

function QUIWidgetEnchantRecycle:onScrollViewFreeze( ... )
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



return QUIWidgetEnchantRecycle
