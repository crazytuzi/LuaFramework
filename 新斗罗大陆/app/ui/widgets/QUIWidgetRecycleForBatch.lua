--
-- Kumo.Wang
-- 回收站，批量回收界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRecycleForBatch = class("QUIWidgetRecycleForBatch", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

local QListView = import("...views.QListView")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QRichText = import("...utils.QRichText")
local QUIWidgetRecycleItemContainer = import("..widgets.QUIWidgetRecycleItemContainer")

function QUIWidgetRecycleForBatch:ctor(options)
	local ccbFile = "ccb/Widget_Recycle_For_Batch.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerRecycle", callback = handler(self, self.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerAutoSelect", callback = handler(self, self.onTriggerAutoSelect)},
        {ccbCallbackName = "onTriggerStore", callback = handler(self, self.onTriggerStore)},
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self.onTriggerHelp)},
	}
	QUIWidgetRecycleForBatch.super.ctor(self, ccbFile, callBacks, options)

    q.setButtonEnableShadow(self._ccbOwner.btn_autoSelect)
    q.setButtonEnableShadow(self._ccbOwner.btn_recycle)

    self:init()
end

function QUIWidgetRecycleForBatch:getWidgetId()
    if self:getOptions() then
        return self:getOptions().widgetId
    end
end
------------- reset function -------------

function QUIWidgetRecycleForBatch:onEnter()
    self:update(true)
end

function QUIWidgetRecycleForBatch:onExit()
    if not q.isEmpty(self._numUpdateDic) then
        for _, numUpdate in pairs(self._numUpdateDic) do
            if numUpdate then
                numUpdate:stopUpdate()
                numUpdate = nil
            end
        end
        self._numUpdateDic = nil
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

function QUIWidgetRecycleForBatch:update(isResetData)
    if isResetData then
        self:updateData()
    end
    self:_initListView()
    local info = self:updateRecyclePreviewInfo()
    self:_showRecyclePreviewInfo(info)
end

function QUIWidgetRecycleForBatch:init()
    self._ccbOwner.node_resource:removeAllChildren()
    self._width  = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height
    self._ccbOwner.node_btn_store:setVisible(false)

    self.data = {}
    self.resourceOwner = {}
    self.recycleCountTbl = {}

    self.itemClassName = "QUIWidgetItemsBox"
    self.spaceX = 10
    self.isPlaying = false 

    -- 選擇回收物品時的特效動畫圖層
    self._selectEffectLayer = CCNode:create()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:getView():addChild(self._selectEffectLayer)

    self:initExplain()
    self:initMenu()
end

function QUIWidgetRecycleForBatch:initExplain()
    self._ccbOwner.node_tf_explain:removeAllChildren()
end

function QUIWidgetRecycleForBatch:initMenu()
    -- 由於init方法裡可能會修改按鈕icon的圖片資源，所以按鈕狀態設定放在這裡
    q.setButtonEnableShadow(self._ccbOwner.btn_store)
    q.setButtonEnableShadow(self._ccbOwner.btn_help)

    self._ccbOwner.node_btn_help:setVisible(false)
    self._ccbOwner.node_btn_store:setVisible(false)
end

function QUIWidgetRecycleForBatch:updateData()
end


function QUIWidgetRecycleForBatch:clickToAddItem(selectedCount, totalCount)
    local num = 0
    if selectedCount < totalCount then
        num = selectedCount + 1
    else
        num = totalCount
    end

    return num
end

function QUIWidgetRecycleForBatch:setItemInfo( item, itemData )
end

function QUIWidgetRecycleForBatch:setItemGoodsInfo(itemNode, itemID, itemType, goodsNum, froceShow)
    itemNode:setGoodsInfo(itemID, itemType, goodsNum, froceShow)
    if itemNode.hideTalentIcon then
        itemNode:hideTalentIcon()
    end
end

function QUIWidgetRecycleForBatch:getIconBySelectData(selectData)
    local icon = nil
    return icon
end

function QUIWidgetRecycleForBatch:updateRecyclePreviewInfo()
    local info = {}

    return info
end

function QUIWidgetRecycleForBatch:getRecycyleItemType()
    return ITEM_TYPE.ITEM
end

function QUIWidgetRecycleForBatch:onTriggerRecycle()
end
function QUIWidgetRecycleForBatch:onTriggerAutoSelect()
end
function QUIWidgetRecycleForBatch:onTriggerStore()
end
function QUIWidgetRecycleForBatch:onTriggerHelp()
end

------------- ------------- -------------

function QUIWidgetRecycleForBatch:_initListView()
    local _scrollEndCallback
    local _scrollBeginCallback
    _scrollEndCallback = function ()
        print("_scrollEndCallback")
        if self._ccbView then
            self._ccbOwner.node_arrowRight:setVisible(false)
            self._ccbOwner.node_arrowLeft:setVisible(true)
        end
    end

    _scrollBeginCallback = function ()
        print("_scrollBeginCallback")
        if self._ccbView then
            self._ccbOwner.node_arrowRight:setVisible(true)
            self._ccbOwner.node_arrowLeft:setVisible(false)
        end
    end
    self._ccbOwner.node_arrowRight:setVisible(true)
    self._ccbOwner.node_arrowLeft:setVisible(false)
    if not self._listView then
        local cfg = {
            renderItemCallBack = handler(self,self._renderItemCallback),
            spaceX = self.spaceX,
            isVertical = false,
            ignoreCanDrag = false,
            autoCenter = false,
            enableShadow = true,
            leftShadow = self._ccbOwner.s9s_leftShadow,
            rightShadow = self._ccbOwner.s9s_rightShadow,
            scrollEndCallBack = _scrollEndCallback,
            scrollBeginCallBack = _scrollBeginCallback,
            totalNumber = #self.data,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self.data})
    end
end

function QUIWidgetRecycleForBatch:_renderItemCallback( list, index, info )
    if self._ccbView then
        if self._leftScheduler ~= nil then
            scheduler.unscheduleGlobal(self._leftScheduler)
            self._leftScheduler = nil
        end
        if self._rightScheduler ~= nil then
            scheduler.unscheduleGlobal(self._rightScheduler)
            self._rightScheduler = nil
        end
        self._ccbOwner.node_arrowLeft:setVisible(list:getCurStartIndex() > 1)
        self._ccbOwner.node_arrowRight:setVisible(list:getCurEndIndex() < #self.data)
    end
    local isCacheNode = true
    local itemData = self.data[index]
    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetRecycleItemContainer.new()
        item:addEventListener(QUIWidgetRecycleItemContainer.EVENT_ADD, handler(self, self._onTriggerItemAdd))
        item:addEventListener(QUIWidgetRecycleItemContainer.EVENT_MINUS, handler(self, self._onTriggerItemMinus))
        isCacheNode = false
    end

    self:setItemInfo(item, itemData)
    item:setIndex(index)

    info.item = item
    info.size = item._itemNode:getContentSize()

    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_minus", "onTriggerMinus")
    list:registerBtnHandler(index, "btn_add", "onTriggerAdd")
    
    return isCacheNode
end

function QUIWidgetRecycleForBatch:_onTriggerItemAdd( event )
    print("[QUIWidgetRecycleForBatch:_onTriggerItemAdd]")
    if not self._listView then return end
    app.sound:playSound("common_others")
    local selectData = self.data[event.index]
    local item = self._listView:getItemByIndex(event.index)

    if selectData.selectedCount < selectData.count then
        selectData.selectedCount = self:clickToAddItem( selectData.selectedCount, selectData.count )
        local typeName = self:getRecycyleItemType()
        self:setItemGoodsInfo(item._itemNode, selectData.id, typeName, selectData.selectedCount .. "/" .. selectData.count, true)
        item:setNodeMinusVisible(selectData.selectedCount > 0)
        local info = self:updateRecyclePreviewInfo()
        self:_showRecyclePreviewInfo(info)
        self:_showSelectAnimation(selectData, item)
    else
        app.tip:floatTip("所选道具数量已达上限")
    end
end

function QUIWidgetRecycleForBatch:_onTriggerItemMinus( event )
    print("[QUIWidgetRecycleForBatch:_onTriggerItemMinus]")
    if not self._listView then return end
    app.sound:playSound("common_others")
    local selectData = self.data[event.index]
    local item = self._listView:getItemByIndex(event.index)

    if selectData.selectedCount > 0 then
        selectData.selectedCount = selectData.selectedCount - 1
        local typeName = self:getRecycyleItemType()
        self:setItemGoodsInfo(item._itemNode, selectData.id, typeName, selectData.selectedCount .. "/" .. selectData.count, true)
        item:setNodeMinusVisible(selectData.selectedCount > 0)
        local info = self:updateRecyclePreviewInfo()
        self:_showRecyclePreviewInfo(info)
    end
end

function QUIWidgetRecycleForBatch:_showSelectAnimation(selectData, item)
    local icon = self:getIconBySelectData(selectData)
    if not icon then return end

    self:_setNodeCascadeOpacityEnabled(icon)

    local p = item._itemNode:convertToWorldSpaceAR(ccp(0,0))
    icon:setPosition(p.x, p.y)
    self._selectEffectLayer:addChild(icon)
    icon:setScale(0.8)
    local targetP = self._ccbOwner.node_item_action_end_point:convertToWorldSpaceAR(ccp(0,0))
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

function QUIWidgetRecycleForBatch:_setNodeCascadeOpacityEnabled( node )
    if node then
        node:setCascadeOpacityEnabled(true)
        local children = node:getChildren()
        if children then
            for index = 0, children:count()-1, 1 do
                local tempNode = children:objectAtIndex(index)
                local tempNode = tolua.cast(tempNode, "CCNode")
                if tempNode then
                    self:_setNodeCascadeOpacityEnabled(tempNode)
                end
            end
        end
    end
end

-- info = {tf, id, num}
function QUIWidgetRecycleForBatch:_showRecyclePreviewInfo(info)
    for _, value in ipairs(info) do
        local tf = value.tf
        print(tf)
        if tf then
            if not self._oldValueDic then
                self._oldValueDic = {}
            end
            if not self._oldValueDic[value.id] then
                self._oldValueDic[value.id] = 0
            end
            if not self._numUpdateDic then
                self._numUpdateDic = {}
            end
            if not self._numUpdateDic[value.id] then
                self._numUpdateDic[value.id] = QTextFiledScrollUtils.new()
            end
            if not self._numUpdateCallbackDic then
                self._numUpdateCallbackDic = {}
            end
            if not self._numUpdateCallbackDic[value.id] then
                self._numUpdateCallbackDic[value.id] = function (num)
                    tf:setString(tostring(math.ceil(num)))
                end
            end

            self:_showNumberEffect(tf, self._numUpdateDic[value.id], self._numUpdateCallbackDic[value.id], self._oldValueDic[value.id], value.num)
            self._oldValueDic[value.id] = value.num
        end
    end
end

function QUIWidgetRecycleForBatch:_showNumberEffect(tf, numUpdate, updateCallback, startNum, endNum)
    if not tf then return end

    if endNum > startNum and numUpdate then
        self:_nodeAddEffect(tf)
        numUpdate:addUpdate(startNum, endNum, updateCallback, 1)
    else
        tf:setString(endNum)
    end
end

function QUIWidgetRecycleForBatch:_nodeAddEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

function QUIWidgetRecycleForBatch:_onTriggerLeft()
    if self.isPlaying then return end
    if self._listView then
        if self._leftScheduler == nil then
            self._leftScheduler = scheduler.performWithDelayGlobal(function()
                self._ccbOwner.node_arrowLeft:setVisible(false)
            end, 0.5)
        end
        self._listView:startScrollToPosScheduler(self._width * 0.9, 0.8, false, function ()
                if self._ccbView then
                    if self._leftScheduler ~= nil then
                        scheduler.unscheduleGlobal(self._leftScheduler)
                        self._leftScheduler = nil
                    end
                    self._ccbOwner.node_arrowRight:setVisible(true)
                end
            end, true)
    end
end

function QUIWidgetRecycleForBatch:_onTriggerRight()
    if self.isPlaying then return end
    if self._listView then
        if self._rightScheduler == nil then
            self._rightScheduler = scheduler.performWithDelayGlobal(function()
                self._ccbOwner.node_arrowRight:setVisible(false)
            end, 0.5)
        end
        self._listView:startScrollToPosScheduler(-self._width * 0.9, 0.8, false, function ()
                if self._ccbView then
                    if self._rightScheduler ~= nil then
                        scheduler.unscheduleGlobal(self._rightScheduler)
                        self._rightScheduler = nil
                    end
                    self._ccbOwner.node_arrowLeft:setVisible(true)
                end
            end, true)
    end
end

return QUIWidgetRecycleForBatch
