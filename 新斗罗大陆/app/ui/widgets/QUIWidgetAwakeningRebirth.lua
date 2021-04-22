--
-- 觉醒重生
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAwakeningRebirth = class("QUIWidgetAwakeningRebirth", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")
local QActorProp = import("...models.QActorProp")
local QListView = import("...views.QListView")

local QUIWidgetItemsBoxEnchant = import("..widgets.QUIWidgetItemsBoxEnchant")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")


-- 没有选择时的提示语
QUIWidgetAwakeningRebirth.TEXT_NO_SELECTED = "魂师大人，请先选择一颗觉醒饰品"
-- 选择重生时弹出的确定框标题
QUIWidgetAwakeningRebirth.TEXT_DIALOG_TITLE = "觉醒材料重生后，将返还以下资源，是否确认重生觉醒材料"
-- 选择重生时弹出的确定框Tip
QUIWidgetAwakeningRebirth.TEXT_DIALOG_TIP = "" -- "提醒：重生后该觉醒材料将彻底消失"
-- 重生完毕后返回页面的subTitle
QUIWidgetAwakeningRebirth.TEXT_FINISHED_SUBTITLE = "觉醒重生返还以下资源"
-- tfNode名称和分解后给的道具ID对照表
QUIWidgetAwakeningRebirth.TF_LIST = {
    ["80"] = 'tf_1', 
    ["81"] = 'tf_2',
    ["82"] = 'tf_3',
    ["93"] = 'tf_4',
    ["94"] = 'tf_5',
    ["95"] = 'tf_6',
}


function QUIWidgetAwakeningRebirth:ctor(options, dialogOptions)
	local ccbFile = "ccb/Widget_HeroRecover_awakening.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIWidgetAwakeningRebirth.onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, QUIWidgetAwakeningRebirth.onTriggerRight)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetAwakeningRebirth.onTriggerOK)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetAwakeningRebirth.onTriggerRule)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, QUIWidgetAwakeningRebirth.onTriggerExchange)},
	}
    QUIWidgetAwakeningRebirth.super.ctor(self,ccbFile,callBacks,options)
    
    self:_init()
end

-- 初始化
function QUIWidgetAwakeningRebirth:_init()
    self._rebornRuleIndex = 24

    self._itemWidth = 90
    self._itemHeight = 100

    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height

    -- 获取数据类
    self._data = remote.awakeningRebirth
    self:_resetTF() 
    self:initExplainTTF()
end

-- 获取ccb中itemID对应分解的tf节点
function QUIWidgetAwakeningRebirth:_getTfNode(itemId)
    local key = QUIWidgetAwakeningRebirth.TF_LIST[tostring(itemId)]
    return self._ccbOwner[key]
end

-- 重置分解道具显示数量
function QUIWidgetAwakeningRebirth:_resetTF()
    local index = 1
    while true do
        local tf = self._ccbOwner["tf_"..index]
        if tf then
            tf:setString(0)
            index = index + 1
        else
            break
        end
    end
end

-- 初始化底部文本
function QUIWidgetAwakeningRebirth:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "重生ss，ss+及以上",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "品质",size = 20,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "的觉醒饰品，返还对应",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "种类",size = 20,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "和",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "数量",size = 20,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "的觉醒饰品",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

-- 刷新数据
function QUIWidgetAwakeningRebirth:update()
    -- 重置数据
    self._data:initData(handler(self, self._getTfNode))
    self:_resetTF() 
    self:_initListView()
end

function QUIWidgetAwakeningRebirth:onEnter()
    self:update()

    self._selectEffectLayer = CCNode:create()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:getView():addChild(self._selectEffectLayer)
end

function QUIWidgetAwakeningRebirth:onExit()
    if self._scheduler ~= nil then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end

    if self._selectEffectLayer ~= nil then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:getView():removeChild(self._selectEffectLayer, true)
        self._selectEffectLayer = true
    end

    -- 停止所有顶部数字更新
    self._data:stopUpdata()
end

-- 初始化listView
function QUIWidgetAwakeningRebirth:_initListView()
    self._items = {}

    if not self._listView then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemFunc),
            scrollDelegate = handler(self, self._onListViewTouch),
            isVertical = false,
            enableShadow = false,
            ignoreCanDrag = true,
            --autoCenter = true,
            curOffset = 10,
            curOriginOffset = 10,
            spaceX = 5,
            totalNumber = self._data:getDataCount(),
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = self._data:getDataCount()})
    end

    self._ccbOwner.arrowLeft:setVisible(false)
    self._ccbOwner.arrowRight:setVisible(self._data:getDataCount() > 6)
end

-- listView被触碰时调用，确定左右两个箭头是否显示的
function QUIWidgetAwakeningRebirth:_onListViewTouch(dragx,dragy)
    local filpDragPos = -dragx
    if self._data:getDataCount() > 6 then
        self._ccbOwner.arrowLeft:setVisible(filpDragPos > 100)
        self._ccbOwner.arrowRight:setVisible(filpDragPos < (self._width - 100))
    end
end

-- listView渲染函数
function QUIWidgetAwakeningRebirth:_renderItemFunc(list, index, info)
    local isCacheNode = true
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end
    self:_setItemInfo(item, index)
    info.item = item
    info.size = CCSizeMake(self._itemWidth, self._itemHeight)
    list:registerTouchHandler(index, "onTouchListView")
    return isCacheNode
end

-- 渲染函数内部的设置item信息函数，由于itemWidget锚点位置和listView需求不符，所以中间隔了一层QUIWidgetQlistviewItem
function QUIWidgetAwakeningRebirth:_setItemInfo( item, index)
    local itemData = self._data:getDataByIndex(index)
    if not self._items[itemData.id] then
        if item._itemNode then
            item._ccbOwner.parentNode:removeAllChildren()
            item._itemNode = nil
        end

        item._itemNode = QUIWidgetItemsBoxEnchant.new()
        item._itemNode:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_CLICK, handler(self, self.itemClickHandler))
        item._itemNode:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK, handler(self, self.itemMinusClickHandler))
        item._itemNode:setPosition(ccp(self._itemWidth/2, self._itemHeight/2))

        item._ccbOwner.parentNode:addChild(item._itemNode)
        item._ccbOwner.parentNode:setContentSize(CCSizeMake(self._itemWidth, self._itemHeight))

        self._items[itemData.id] = { index = index, widget = item._itemNode}
    end
    item._itemNode:checkNeedItem()
    item._itemNode:setInfo(itemData)
end

-- item被选中时的回调
function QUIWidgetAwakeningRebirth:itemClickHandler(event)
    if self._playing then return end
    local target = self._items[event.itemID]
    local data = self._data:getDataByIndex(target.index)

    local proxyFunc = function(value)
        return value + 1
    end
    
    if self._data:updataSelected(target.index, proxyFunc) then
        target.widget:setInfo(data)
        self:_showSelectAnimation(data, target.widget)
    end
end

-- item被减去时的回调
function QUIWidgetAwakeningRebirth:itemMinusClickHandler(event)
    if self._playing then return end
    local target = self._items[event.itemID]
    local data = self._data:getDataByIndex(target.index)

    local proxyFunc = function(value)
        return value - 1
    end
    
    if self._data:updataSelected(target.index, proxyFunc) then
        target.widget:setInfo(data)
    end
end

-- 开启级联的节点透明度
function QUIWidgetAwakeningRebirth:_setNodeCascadeOpacityEnabled( node )
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

-- 展示选中item的移动动画
function QUIWidgetAwakeningRebirth:_showSelectAnimation(selectData, item)
    local icon = QUIWidgetItemsBoxEnchant.new()
    icon:setInfo(selectData)
    icon:setNumVisibility(false)
    icon:setNameVisibility(false)
    icon:showMinusButton(false)

    self:_setNodeCascadeOpacityEnabled(icon)

    local p = item:convertToWorldSpaceAR(ccp(0,0))
    icon:setPosition(p.x, p.y)
    self._selectEffectLayer:addChild(icon)
    icon:setScale(0.8)
    local targetP = self._ccbOwner.angelEffect:convertToWorldSpaceAR(ccp(0,0))
    local arr = CCArray:create()
    
    local bezierConfig = ccBezierConfig:new()
    bezierConfig.endPosition = targetP
    bezierConfig.controlPoint_1 = ccp(p.x + (targetP.x - p.x) * 0.333, p.y + (targetP.y- p.y) * 0.8)
    bezierConfig.controlPoint_2 = ccp(p.x + (targetP.x - p.x) * 0.667, p.y + (targetP.y- p.y) * 1)
    local bezierTo = CCBezierTo:create(0.4, bezierConfig)
    arr:addObject(CCSequence:createWithTwoActions(bezierTo, CCDelayTime:create(0.2)))
    arr:addObject(CCCallFunc:create(function()
            icon:removeFromParentAndCleanup(true)
        end))
    local seq = CCSequence:create(arr)
    icon:runAction(CCSpawn:createWithTwoActions(seq, CCFadeTo:create(0.6, 0)))
end

-- 点击重生
function QUIWidgetAwakeningRebirth:onTriggerOK(event)
    if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")

    if not self._data:checkIsSelected() then
        app.tip:floatTip(QUIWidgetAwakeningRebirth.TEXT_NO_SELECTED)
    else
        self._data:onAwakeningRebirth(
            QUIWidgetAwakeningRebirth.TEXT_DIALOG_TITLE, 
            QUIWidgetAwakeningRebirth.TEXT_DIALOG_TIP,
            handler(self, self.onTriggerAwakeningFinished))
    end
end

-- 重生完成播放动画
function QUIWidgetAwakeningRebirth:onTriggerAwakeningFinished()
	self._playing = true

	local effect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.effect:addChild(effect)
    local animation = "effects/HeroRecoverEffect_up.ccbi"

    local compensations = self._data:getCompensations()
	effect:playAnimation(animation, nil, function()
        effect:removeFromParentAndCleanup(true)
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
            options = {compensations = compensations, type = 17, subtitle = QUIWidgetAwakeningRebirth.TEXT_FINISHED_SUBTITLE}}, {isPopCurrentDialog = false})
        self:update()
        self._playing = false
    end)
end

-- 点击规则
function QUIWidgetAwakeningRebirth:onTriggerRule()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = self._rebornRuleIndex}}, {isPopCurrentDialog = false})
end

-- 点击积分商店
function QUIWidgetAwakeningRebirth:onTriggerExchange()
    if self._playing then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantExchange"})
end

-- 点击左箭头
function QUIWidgetAwakeningRebirth:onTriggerLeft()
    if self._playing then return end
    if self._listView then
        self._listView:startScrollToPosScheduler(self._width * 1.0, 0.8, false, function () end, true)
    end
end

-- 点击右箭头
function QUIWidgetAwakeningRebirth:onTriggerRight()
    if self._playing then return end
    if self._listView then
        self._listView:startScrollToPosScheduler(-self._width * 1.0, 0.8, false, function () end, true)
    end
end

return QUIWidgetAwakeningRebirth
