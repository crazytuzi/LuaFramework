--
-- Kumo.Wang
-- 回收站，批量回收界面——神器碎片回收
--
local QUIWidgetRecycleForBatch = import("..widgets.QUIWidgetRecycleForBatch")
local QUIWidgetRecycleForGodarmFragmentRecover = class("QUIWidgetRecycleForGodarmFragmentRecover", QUIWidgetRecycleForBatch)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")

local QListView = import("...views.QListView")
local QUIWidgetItemsBoxEnchant = import("..widgets.QUIWidgetItemsBoxEnchant")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QRichText = import("...utils.QRichText")

function QUIWidgetRecycleForGodarmFragmentRecover:ctor(options)
	QUIWidgetRecycleForGodarmFragmentRecover.super.ctor(self, options)
end

function QUIWidgetRecycleForGodarmFragmentRecover:onEnter()
    QUIWidgetRecycleForGodarmFragmentRecover.super.onEnter(self)
end

function QUIWidgetRecycleForGodarmFragmentRecover:onExit()
    QUIWidgetRecycleForGodarmFragmentRecover.super.onExit(self)
end

function QUIWidgetRecycleForGodarmFragmentRecover:init()
    -- 初始化商店按鈕icon
    local config = remote.items:getWalletByType(ITEM_TYPE.GOD_ARM_MONEY)
    local spf = QSpriteFrameByPath(config.alphaIcon)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 1)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 2)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 4)
    self._ccbOwner.tf_store_name:setString("圣柱商店")

    QUIWidgetRecycleForGodarmFragmentRecover.super.init(self)

    self.itemClassName = "QUIWidgetItemsBox"

    -- 初始化貨幣組件
    local widgetResource = CCBuilderReaderLoad("ccb/Widget_Recycle_Resource_One.ccbi", CCBProxy:create(), self.resourceOwner)
    self._ccbOwner.node_resource:addChild(widgetResource)
    -- 更換貨幣icon
    QSetDisplayFrameByPath(self.resourceOwner.sp_resource, config.alphaIcon)
    self.resourceOwner.tf_resource:setString("0")
end

function QUIWidgetRecycleForGodarmFragmentRecover:initExplain()
    QUIWidgetRecycleForGodarmFragmentRecover.super.initExplain(self)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "神器碎片分解为"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "圣柱币"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "，碎片"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "品质越高"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "圣柱币"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "越多"},
        }, 680, {autoCenter = true})
    richText:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.node_tf_explain:addChild(richText)
end

function QUIWidgetRecycleForGodarmFragmentRecover:initMenu()
    QUIWidgetRecycleForGodarmFragmentRecover.super.initMenu(self)

    self._ccbOwner.node_btn_help:setVisible(true)
    self._ccbOwner.node_btn_store:setVisible(true)

    self._ccbOwner.node_btn_autoSelect:setVisible(false)
    self._ccbOwner.node_btn_recycle:setPositionX(0)
end

function QUIWidgetRecycleForGodarmFragmentRecover:updateData()
    local allRecycleMaterial = remote.items:getAllGodarmFragment()
    self.data = {}
    for _, v in pairs(allRecycleMaterial) do
        -- Here v.type is the item id
        table.insert(self.data, {id = v.type, count = v.count, selectedCount = 0})
    end
    table.sort(self.data, function (a, b) 
        local configA = db:getItemByID(a.id)
        local configB = db:getItemByID(b.id)
        if configA.gemstone_quality ~= configB.gemstone_quality then
            return configA.gemstone_quality < configB.gemstone_quality
        elseif a.count ~= b.count then
            return a.count > b.count 
        else
            return a.id < b.id
        end
    end)
    QKumo(self.data)
end

function QUIWidgetRecycleForGodarmFragmentRecover:setItemInfo( item, itemData )
    if not item._itemNode then
        if not self.itemClass then
            self.itemClass = import(app.packageRoot .. ".ui.widgets." .. self.itemClassName)
        end
        item._itemNode = self.itemClass.new()
        item._ccbOwner.node_item:addChild(item._itemNode)
        item:setScale(1)
    end

    local typeName = self:getRecycyleItemType()
    self:setItemGoodsInfo(item._itemNode, itemData.id, typeName, itemData.selectedCount .. "/" .. itemData.count, true)
    item:setNodeMinusVisible(itemData.selectedCount > 0)
    
    local itemInfo = db:getItemByID(itemData.id)
    local fontColor = EQUIPMENT_COLOR[itemInfo.colour]
    item:setTFNameVisible(true)
    item:setTFNameValue(itemInfo.name or "")
    item:setTFNameColor(fontColor, true)
end

function QUIWidgetRecycleForGodarmFragmentRecover:clickToAddItem(selectedCount, totalCount)
    local num = totalCount
    return num
end

function QUIWidgetRecycleForGodarmFragmentRecover:updateRecyclePreviewInfo()
    for _, value in ipairs(self.data) do
        if value.selectedCount and value.selectedCount > 0 then
            local itemInfo = db:getItemByID(value.id)
            if itemInfo then
                local soulCount = itemInfo.soul_recycle or 0
                self.recycleCountTbl[ITEM_TYPE.GOD_ARM_MONEY] = (self.recycleCountTbl[ITEM_TYPE.GOD_ARM_MONEY]  or 0) + soulCount * value.selectedCount
            end
        end
    end

    local info = {}
    for k, v in pairs(self.recycleCountTbl) do
        table.insert(info, {tf = self.resourceOwner.tf_resource, id = k, num = v})
    end

    return info
end


function QUIWidgetRecycleForGodarmFragmentRecover:getIconBySelectData(selectData)
    if not self.itemClass then return end 

    local icon = self.itemClass.new()
    local typeName = self:getRecycyleItemType()
    self:setItemGoodsInfo(icon, selectData.id, typeName, 0)

    return icon
end

function QUIWidgetRecycleForGodarmFragmentRecover:onTriggerRecycle()
    if self.isPlaying then return end
    if q.isEmpty(self.recycleCountTbl) then return end 

    local compensations = {}
    local selectCount = 0
    for id, count in pairs(self.recycleCountTbl) do
        selectCount = selectCount + count
        table.insert(compensations, {id = id, value = count})
    end

    if selectCount == 0 then return end
    app.sound:playSound("common_small")


    local callRecycleAPI = function()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        self:_onTriggerRecycleFinished() 
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = compensations,title = "神器碎片分解后将返还以下资源，是否确认分解神器碎片", callFunc = callRecycleAPI}})
end
function QUIWidgetRecycleForGodarmFragmentRecover:_onTriggerRecycleFinished()
    local items = {}
    for _, v in pairs(self.data) do
        if v.selectedCount > 0 then
            table.insert(items, {type = v.id, count = v.selectedCount})
        end
    end
    remote.godarm:godarmPiceRequest(items, function()
            self:showRecycleFinishAnimation()
        end)
end

function QUIWidgetRecycleForGodarmFragmentRecover:showRecycleFinishAnimation()
    self.isPlaying = true
    local effectName = "effects/chongsheng_huolu2.ccbi"
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(effect)
    effect:playAnimation(effectName, nil, nil, false)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(1))
    arr:addObject(CCCallFunc:create(function() 
            self.isPlaying = false 
            local awards = {}
            for id, count in pairs(self.recycleCountTbl) do
                if tonumber(id) then
                    table.insert(awards, {id = tonumber(id), typeName = ITEM_TYPE.ITEM, count = count})
                else
                    table.insert(awards, {id = id, typeName = remote.items:getItemType(id), count = count})
                end
            end
            QKumo(awards)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAwardsAlert",
                    options = {awards = awards}}, {isPopCurrentDialog = false})
            self:update(true)
            effect:stopAnimation()
        end))

    local action = CCSequence:create(arr)
    self._ccbOwner.node_effect:runAction(action)
end

function QUIWidgetRecycleForGodarmFragmentRecover:onTriggerStore()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.godarmShop)
end

function QUIWidgetRecycleForGodarmFragmentRecover:onTriggerHelp()
    if self.isPlaying then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", options = {type = 23}}, {isPopCurrentDialog = false})
end

return QUIWidgetRecycleForGodarmFragmentRecover
