--
-- Author: qinyuanji
-- Date: 2015-04-02 17:14:49
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMaterialRecycle = class("QUIWidgetMaterialRecycle", QUIWidget)

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

QUIWidgetMaterialRecycle.GAP = 10
QUIWidgetMaterialRecycle.MARGIN = 0
QUIWidgetMaterialRecycle.MATERIAL_PROMPT = "分解现有材料，将会返还%d灵魂石，是否确认分解？"
QUIWidgetMaterialRecycle.FRAGMENT_PROMPT = "分解现有魂师灵魂碎片，将会返还%d灵魂石，是否确认分解？"
QUIWidgetMaterialRecycle.HERO_PROMPT = "%s##0x865537的碎片是正在收集的魂师碎片,是否要分解？"
QUIWidgetMaterialRecycle.NUMBER_TIME = 1

function QUIWidgetMaterialRecycle:ctor(options)
	local ccbFile = "ccb/Widget_HeroRecover_Cailiao.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIWidgetMaterialRecycle.onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIWidgetMaterialRecycle.onTriggerRight)},
		{ccbCallbackName = "onTriggerRecycle", callback = handler(self, QUIWidgetMaterialRecycle.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, QUIWidgetMaterialRecycle.onTriggerExchange)},
        {ccbCallbackName = "onTriggerAutoSelect", callback = handler(self, QUIWidgetMaterialRecycle.onTriggerAutoSelect)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetMaterialRecycle.onTriggerRule)},
	}

	QUIWidgetMaterialRecycle.super.ctor(self,ccbFile,callBacks,options)

    self._type = options.type
    -- self._recycleMoney = QUIWidgetShopTap.new({money = remote.user.soulMoney, type = "soulMoney"})
    -- self._recycleMoney:setScale(0.7)
    -- self._ccbOwner.tap:addChild(self._recycleMoney)

    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height

    self._ccbOwner.token_gain:setVisible(false)
    self._ccbOwner.soul_gain:setVisible(true)
    -- self._ccbOwner.material_description:setVisible(self._type == 1)
    self._ccbOwner.material_rule:setVisible(self._type == 1)

    -- self._ccbOwner.soul_description:setVisible(self._type == 3)
    self._ccbOwner.soul_rule:setVisible(self._type == 3)
    -- self._ccbOwner.yellow:setVisible(false)
    -- self._ccbOwner.red:setVisible(true)
    self._ccbOwner.store:setVisible(true)
    self._ccbOwner.gain:setString(0)

    self._forceUpdate = QTextFiledScrollUtils.new()
    self._firstItem = nil
    self:initExplainTTF()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._selectEffectLayer = CCNode:create()
    page:getView():addChild(self._selectEffectLayer)
end

function QUIWidgetMaterialRecycle:initExplainTTF( )
    -- body
    local richText
    if self._type == 1 then
        richText = QRichText.new({
            {oType = "font", content = "分解魂环和材料可获得",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "灵魂石",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "，材料",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "品质越高",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "灵魂石",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "越多",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        },790,{autoCenter = true})
    elseif self._type == 3 then
        richText = QRichText.new({
            {oType = "font", content = "碎片分解可获得",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "灵魂石",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "，碎片",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "品质越高",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "灵魂石",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "越多",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        },790,{autoCenter = true})
    end
    if richText then
        self._ccbOwner.explainTTF:addChild(richText)
    end
end

function QUIWidgetMaterialRecycle:onEnter()
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

function QUIWidgetMaterialRecycle:onExit()
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
    local soulBar = page.topBar:getBarForType(ITEM_TYPE.SOULMONEY)
    local barSoulIcon = soulBar:getIcon()
    barSoulIcon:stopAllActions()
end

function QUIWidgetMaterialRecycle:getAvailableItems()
    local items = {}
    local db = QStaticDatabase:sharedDatabase()
    local config, actorId, characher ,value = nil, nil, nil
    for k, v in pairs((self._type == 1 and remote.items:getAllRecycleMaterial() or remote.items:getAllRecycleFragment())) do
        config = db:getItemByID(v.type)
        value = {id = v.type, count = v.count, selectedCount = 0, color = config.colour, break_through = config.break_through or 1, item_id = config.id, soul_circle_dot = config.soul_circle_dot}
        if self._type ~= 1 then
            actorId = db:getActorIdBySoulId(config.id)
            characher = db:getCharacterByID(actorId) or {}
            value.aptitude = characher.aptitude or 10
        end
        items[v.type] = value  -- Here v.type is the item id
    end

    return items
end

function QUIWidgetMaterialRecycle:update()
  
    self._scrollView:clearCache()

    self._materialNumber = 0
    self._items = self:getAvailableItems()

    -- sort material by id
    local materials = {}
    for k, v in pairs(self._items) do
        table.insert(materials, {id = k, value = v})
    end
    if self._type == 1 then
        table.sort(materials, function (x, y) 
                if x.value.break_through == y.value.break_through then
                    if x.value.count == y.value.count then
                        return x.value.item_id < y.value.item_id
                    else
                        return x.value.count > y.value.count 
                    end
                else
                    return x.value.break_through < y.value.break_through
                end
            end)
    else
        table.sort(materials, function (x, y) 
                if x.value.aptitude == y.value.aptitude then
                    if x.value.count == y.value.count then
                        return x.value.item_id < y.value.item_id
                    else
                        return x.value.count > y.value.count 
                    end
                else
                    return x.value.aptitude < y.value.aptitude
                end
            end)
    end

    -- set correct position for each item
    local x = QUIWidgetMaterialRecycle.MARGIN + self._itemSize.width/2 + 10
    local y = -self._height/2 + 20
    for k, v in ipairs(materials) do
        if not self._scrollView then break end
        if self._items[v.id] ~= nil then
            self._scrollView:addItemBox(x, y, self._items[v.id])
            x = x + QUIWidgetMaterialRecycle.GAP + self._itemSize.width
        end
    end

    local scrollViewWidth = #materials * (QUIWidgetMaterialRecycle.GAP + self._itemSize.width) + QUIWidgetMaterialRecycle.MARGIN + 10
    if scrollViewWidth <= self._width then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    else
        self._ccbOwner.arrowLeft:setVisible(true)
        self._ccbOwner.arrowRight:setVisible(true)
    end

    self._scrollView:setRect(0, -self._height, 0, scrollViewWidth)
    self._firstItem = materials[1] and self._items[materials[1].id] or nil
    self:updateMaterialNumber()

    -- self._recycleMoney:setMoney(remote.user.soulMoney)
end

function QUIWidgetMaterialRecycle:updateMaterialNumber()
    local materialNumber = 0
    for k, v in pairs(self._items) do
        if v.selectedCount > 0 then
            materialNumber = materialNumber + QStaticDatabase:sharedDatabase():getItemByID(v.id).soul_recycle * v.selectedCount
        end
    end

    if materialNumber > self._materialNumber then
        self:nodeEffect(self._ccbOwner.gain)
    end

    self._forceUpdate:addUpdate(self._materialNumber, materialNumber, handler(self, self._onForceUpdate), QUIWidgetMaterialRecycle.NUMBER_TIME)
    self._materialNumber = materialNumber

    for _, v in ipairs(self._itemObjects) do
        if v and v.setNeedshadow then
            v:setNeedshadow( false )
        end
    end
end

function QUIWidgetMaterialRecycle:_onForceUpdate(value)
    self._ccbOwner.gain:setString(tostring(math.ceil(value)))
end

function QUIWidgetMaterialRecycle:nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

-- Callbacks
function QUIWidgetMaterialRecycle:onTriggerLeft()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if math.abs(self._scrollView:getPositionX()) < self._width then
        self._scrollView:runToLeft(true)
    else
        local offset = math.ceil(math.abs(self._scrollView:getPositionX())/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-(offset - self._width), self._scrollView:getPositionY(), true)
    end
end

function QUIWidgetMaterialRecycle:onTriggerRight()
    if self._playing then return end

    self._scrollView:stopAllActions()
    if self._scrollView:getWidth() - math.abs(self._scrollView:getPositionX()) < 2 * self._width then
        self._scrollView:runToRight(true)
    else
        local offset = math.floor((self._width + math.abs(self._scrollView:getPositionX()))/self._itemSize.width)*self._itemSize.width
        self._scrollView:moveTo(-offset, self._scrollView:getPositionY(), true)
    end
end

-- Type 1: check if material's grade is less than the lowest grade of fight heroes
-- Type 2: check if fragment's grade is less than 3 and not in the fight heroes
function QUIWidgetMaterialRecycle:onTriggerAutoSelect(event)
    if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_select) == false then return end
    app.sound:playSound("common_small")
    
    if self._type == 1 then
        local func = function (reservedCount, saveSoulMaterial)
            if reservedCount == -1 then
                return
            end

            self:update()

            local selected = false
            local minBreakthrough = nil
            local heroInfos, count = remote.herosUtil:getMaxForceHeros()
            for i = 1, count, 1 do
                if heroInfos[i] ~= nil then
                    local hero = remote.herosUtil:getHeroByID(heroInfos[i].id)
                    if hero then
                        if not minBreakthrough then minBreakthrough = hero.breakthrough end
                        minBreakthrough = math.min(minBreakthrough, hero.breakthrough)
                    end
                end
            end
            
            if minBreakthrough then
                minBreakthrough = minBreakthrough
                for k, v in pairs(self._items) do
                    if v.break_through < minBreakthrough then
                        if saveSoulMaterial ~= true or v.soul_circle_dot ~= 1 then
                            v.selectedCount = math.max(v.count - reservedCount, 0)
                            if v.selectedCount > 0 then
                                selected = true
                            end
                        end
                    end
                end
                if selected then
                    for k, v in ipairs(self._itemObjects) do
                        if v.used then
                            v:refresh()
                        end
                    end
                    self:updateMaterialNumber()
                end
            end
            if not selected then
                app.tip:floatTip("当前没有可自动分解的材料,请手动添加")
            end
        end
        if table.nums(self._items) > 0 then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMaterialRecycleSelect",
                        options = {callBack = func}}, {isPopCurrentDialog = false})
        end
    else
        local selected = false
        local eligibleAptitude = 15
        local uneligibleFragment = {}

        local db = QStaticDatabase:sharedDatabase()
        for k, v in pairs(self._items) do
            local actorId = db:getActorIdBySoulId(k)
            local heroEligible = true -- indiciate if hero fragment can be recycled
            local hero = remote.herosUtil:getHeroByID(actorId)
            local heroAptitude = db:getCharacterByID(actorId).aptitude
            if heroAptitude < eligibleAptitude then
                local heroInfos, count = remote.herosUtil:getMaxForceHeros()

                for i = 1, count, 1 do
                    if heroInfos[i] and heroInfos[i].id == actorId and hero then
                        heroEligible = false
                        break
                    end
                end
            else
                heroEligible = false
            end

            if heroEligible then
                v.selectedCount = v.count
                selected = true
                print(actorId .. " is selected ")
            end
        end
        if selected then
            for k, v in ipairs(self._itemObjects) do
                if v.used then
                    v:refresh()
                end
            end
            self:updateMaterialNumber()
        else
            if table.nums(self._items) > 0 then
                app.tip:floatTip("当前没有可自动分解的材料,请手动添加")
            end
        end
    end
end

function QUIWidgetMaterialRecycle:onTriggerRule()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = (self._type == 1) and 3 or 4}}, {isPopCurrentDialog = false})
end

function QUIWidgetMaterialRecycle:onTriggerRecycle(event)
    if self._playing or self._materialNumber == 0 then return end 
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")
    local content = string.format(self._type == 1 and QUIWidgetMaterialRecycle.MATERIAL_PROMPT or QUIWidgetMaterialRecycle.FRAGMENT_PROMPT, self._materialNumber)
    app:alert({content = content, title = "系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:onTriggerRecycleFinished()
            end
        end})
end

function QUIWidgetMaterialRecycle:onTriggerRecycleFinished()
    local items = {}
    for k, v in pairs(self._items) do
        if v.selectedCount > 0 then
            table.insert(items, {type = v.id, count = v.selectedCount})
        end
    end

    app:getClient():materialRecycle(items, self._type, function ()
        print("material recycle successfully")
        self:showRecycleFinishAnimation()
        end)
end

function QUIWidgetMaterialRecycle:onTriggerExchange()
    if self._playing then return end
    app.sound:playSound("common_small")
    if app.unlock:checkLock("UNLOCK_SOUL_SHOP", true) then
        remote.stores:openShopDialog(SHOP_ID.soulShop)
    end
end

function QUIWidgetMaterialRecycle:showRecycleFinishAnimation()
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
            local awards = {}
            table.insert(awards, {id = "soulMoney", typeName = ITEM_TYPE.SOULMONEY, count = self._materialNumber})
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards}}, {isPopCurrentDialog = false})
            
            self:update()
            effect:stopAnimation()
        end))

    local action = CCSequence:create(arr)
    self._ccbOwner.angelEffect1:runAction(action)
end


function QUIWidgetMaterialRecycle:setNodeCascadeOpacityEnabled( node )
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

function QUIWidgetMaterialRecycle:showSelectAnimation(item)

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
    
    local bezierConfig = ccBezierConfig:new()
    bezierConfig.endPosition = targetP
    bezierConfig.controlPoint_1 = ccp(p.x + (targetP.x - p.x) * 0.333, p.y + (targetP.y- p.y) * 0.8)
    bezierConfig.controlPoint_2 = ccp(p.x + (targetP.x - p.x) * 0.667, p.y + (targetP.y- p.y) * 1)
    local bezierTo = CCBezierTo:create(0.4, bezierConfig)
    arr:addObject(CCSpawn:createWithTwoActions(bezierTo, CCDelayTime:create(0.2)))
    arr:addObject(CCCallFunc:create(function()
            icon:removeFromParentAndCleanup(true)
        end))
    local seq = CCSequence:create(arr)
    icon:runAction(seq)
end

-- return 1 means this hero has never been summoned(collected) and aptitude above A
-- return 2 means this hero is among top N
-- return 0 means normal
function QUIWidgetMaterialRecycle:checkSpecialHero(itemId)
    local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(itemId)
    if not table.find(remote.user.collectedHeros, actorId) then
        local aptitude = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
        if aptitude.qc ~= "B" and aptitude.qc ~= "C" then
            return 1
        end
    end

    local heroInfos, count = remote.herosUtil:getMaxForceHeros()
    if count > 0 and heroInfos then 
        for i = 1, count do 
            if heroInfos[i] and heroInfos[i].id == actorId then
                return 2
            end
        end
    end

    return 0
end

-- Item click event
function QUIWidgetMaterialRecycle:itemClickHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    local func = function ( ... )
        if item ~= nil then
            if item.selectedCount < item.count then
                if self._type == 1 then
                    item.selectedCount = item.selectedCount + 1
                elseif self._type == 3 then
                    item.selectedCount = item.count
                end
                item.itemWidget = event.source
                item.itemWidget:setGoodsInfo(item.id, ITEM_TYPE.ITEM, item.selectedCount .. "/" .. item.count, true)
                item.itemWidget:showMinusButton(item.selectedCount > 0)
                self:updateMaterialNumber()
                self:showSelectAnimation(item)
            else
                app.tip:floatTip("所选道具数量已达上限")
            end
        end
    end

    if self._type == 3 and item and item.selectedCount == 0 then
        local ret = self:checkSpecialHero(event.itemID)
        if ret ~= 0  then
            local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(event.itemID)
            local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
            local aptitude = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
            local color = "##p"
            if aptitude.qc == "S" then
                color = "##o"
            elseif aptitude.qc == "B" then
                color = "##b"
            elseif aptitude.qc == "C" then
                color = "##g"
            end

            app:alert({content = string.format(QUIWidgetMaterialRecycle.HERO_PROMPT, color.."\""..characher.name.."\""),
                title = "系统提示", callback = function (state)
                    if state == ALERT_TYPE.CONFIRM then
                        func()
                    end
                end, colorful = true})
        else
            func()
        end
    else
        func()
    end
end

function QUIWidgetMaterialRecycle:itemClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount ~= nil then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetMaterialRecycle:itemMinusClickHandler(event)
    if self._isMoving == true or self._playing then return end

    print("minus" .. event.itemID)
    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount > 0 then
        item.selectedCount = item.selectedCount - 1
        item.itemWidget = event.source
        item.itemWidget:setGoodsInfo(event.itemID, ITEM_TYPE.ITEM, item.selectedCount.."/"..item.count, true)
        item.itemWidget:showMinusButton(item.selectedCount > 0)
        self:updateMaterialNumber()
    end
end

function QUIWidgetMaterialRecycle:itemMinusClickEndHandler(event)
    if self._isMoving == true or self._playing then return end

    local item = self._items[event.itemID]
    if item ~= nil and item.selectedCount > 0 then
        item.itemWidget = event.source
        item.itemWidget:showMinusButton(item.selectedCount > 0)
    end
end

function QUIWidgetMaterialRecycle:onScrollViewMoving()
    self._isMoving = true
end

function QUIWidgetMaterialRecycle:onScrollViewBegan( ... )
    self._isMoving = false
end

function QUIWidgetMaterialRecycle:onScrollViewFreeze( ... )
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



return QUIWidgetMaterialRecycle
