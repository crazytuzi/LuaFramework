--
-- Kumo.Wang
-- 回收站，批量回收界面——材料回收
--
local QUIWidgetRecycleForBatch = import("..widgets.QUIWidgetRecycleForBatch")
local QUIWidgetRecycleForMaterial = class("QUIWidgetRecycleForMaterial", QUIWidgetRecycleForBatch)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")

local QListView = import("...views.QListView")
local QUIWidgetItemsBoxEnchant = import("..widgets.QUIWidgetItemsBoxEnchant")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QRichText = import("...utils.QRichText")

function QUIWidgetRecycleForMaterial:ctor(options)
	QUIWidgetRecycleForMaterial.super.ctor(self, options)
end

function QUIWidgetRecycleForMaterial:onEnter()
    QUIWidgetRecycleForMaterial.super.onEnter(self)
end

function QUIWidgetRecycleForMaterial:onExit()
    QUIWidgetRecycleForMaterial.super.onExit(self)
end

function QUIWidgetRecycleForMaterial:init()
    QUIWidgetRecycleForMaterial.super.init(self)

    self.itemClassName = "QUIWidgetItemsBox"

    -- 初始化貨幣組件
    local widgetResource = CCBuilderReaderLoad("ccb/Widget_Recycle_Resource_One.ccbi", CCBProxy:create(), self.resourceOwner)
    self._ccbOwner.node_resource:addChild(widgetResource)
    -- 更換貨幣icon
    QSetDisplayFrameByPath(self.resourceOwner.sp_resource, "icon/item/yingling_icon.png")
    self.resourceOwner.tf_resource:setString("0")
end

function QUIWidgetRecycleForMaterial:initExplain()
    QUIWidgetRecycleForMaterial.super.initExplain(self)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "分解魂环和材料可获得"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "灵魂石"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "，材料"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "品质越高"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "灵魂石"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "越多"},
        }, 680, {autoCenter = true})
    richText:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.node_tf_explain:addChild(richText)
end

function QUIWidgetRecycleForMaterial:initMenu()
    QUIWidgetRecycleForMaterial.super.initMenu(self)

    self._ccbOwner.node_btn_help:setVisible(true)
    self._ccbOwner.node_btn_store:setVisible(true)
end

function QUIWidgetRecycleForMaterial:updateData()
    local allRecycleMaterial = remote.items:getAllRecycleMaterial()
    self.data = {}
    for _, v in pairs(allRecycleMaterial) do
        -- Here v.type is the item id
        table.insert(self.data, {id = v.type, count = v.count, selectedCount = 0})
    end
    table.sort(self.data, function (a, b) 
        local configA = db:getItemByID(a.id)
        local configB = db:getItemByID(b.id)
        if configA.break_through ~= configB.break_through then
            return configA.break_through < configB.break_through
        elseif a.count ~= b.count then
            return a.count > b.count 
        else
            return a.id < b.id
        end
    end)
    QKumo(self.data)
end

function QUIWidgetRecycleForMaterial:setItemInfo( item, itemData )
    if not item._itemNode then
        if not self.itemClass then
            self.itemClass = import(app.packageRoot .. ".ui.widgets." .. self.itemClassName)
        end
        item._itemNode = self.itemClass.new()
        item._ccbOwner.node_item:addChild(item._itemNode)
        item:setScale(1)
    end

    self:setItemGoodsInfo(item._itemNode, itemData.id, ITEM_TYPE.ITEM, itemData.selectedCount .. "/" .. itemData.count, true)
    item:setNodeMinusVisible(itemData.selectedCount > 0)
    
    local itemInfo = db:getItemByID(itemData.id)
    local fontColor = EQUIPMENT_COLOR[itemInfo.colour]
    item:setTFNameVisible(true)
    item:setTFNameValue(itemInfo.name or "")
    item:setTFNameColor(fontColor, true)
end

function QUIWidgetRecycleForMaterial:updateRecyclePreviewInfo()
    for _, value in ipairs(self.data) do
        if value.selectedCount and value.selectedCount > 0 then
            local itemInfo = db:getItemByID(value.id)
            if itemInfo then
                local soulCount = itemInfo.soul_recycle or 0
                self.recycleCountTbl[ITEM_TYPE.SOULMONEY] = (self.recycleCountTbl[ITEM_TYPE.SOULMONEY]  or 0) + soulCount * value.selectedCount
            end
        end
    end

    local info = {}
    for k, v in pairs(self.recycleCountTbl) do
        table.insert(info, {tf = self.resourceOwner.tf_resource, id = k, num = v})
    end

    return info
end


function QUIWidgetRecycleForMaterial:getIconBySelectData(selectData)
    if not self.itemClass then return end 

    local icon = self.itemClass.new()
    self:setItemGoodsInfo(icon, selectData.id, ITEM_TYPE.ITEM, 0)

    return icon
end

function QUIWidgetRecycleForMaterial:onTriggerRecycle()
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
        options = {compensations = compensations,title = "材料分解后将返还以下资源，是否确认分解材料", callFunc = callRecycleAPI}})
end
function QUIWidgetRecycleForMaterial:_onTriggerRecycleFinished()
    local items = {}
    for _, v in pairs(self.data) do
        if v.selectedCount > 0 then
            table.insert(items, {type = v.id, count = v.selectedCount})
        end
    end

    app:getClient():materialRecycle(items, 1, function()
            self:showRecycleFinishAnimation()
        end)
end
function QUIWidgetRecycleForMaterial:showRecycleFinishAnimation()
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
                table.insert(awards, {id = id, typeName = remote.items:getItemType(id), count = count})
            end
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAwardsAlert",
                    options = {awards = awards}}, {isPopCurrentDialog = false})
            self:update(true)
            effect:stopAnimation()
        end))

    local action = CCSequence:create(arr)
    self._ccbOwner.node_effect:runAction(action)
end


function QUIWidgetRecycleForMaterial:onTriggerAutoSelect()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    
    local func = function (reservedCount, saveSoulMaterial)
        if reservedCount == -1 then
            return
        end
        
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
            QKumo(self.data)
            for _, v in ipairs(self.data) do
                local itemInfo = db:getItemByID(v.id)
                if itemInfo.break_through < minBreakthrough then
                    if saveSoulMaterial ~= true or itemInfo.soul_circle_dot ~= 1 then
                        v.selectedCount = math.max(v.count - reservedCount, 0)
                        if v.selectedCount > 0 then
                            selected = true
                        end
                    end
                end
            end
            if selected then
                self:update()
            end
        end
        if not selected then
            app.tip:floatTip("当前没有可自动分解的材料,请手动添加")
        end
    end
    if #self.data > 0 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaterialRecycleSelect",
            options = {callBack = func}}, {isPopCurrentDialog = false})
    end
end

function QUIWidgetRecycleForMaterial:onTriggerStore()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    if app.unlock:checkLock("UNLOCK_SOUL_SHOP", true) then
        remote.stores:openShopDialog(SHOP_ID.soulShop)
    end
end

function QUIWidgetRecycleForMaterial:onTriggerHelp()
    if self.isPlaying then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", options = {type = 3}}, {isPopCurrentDialog = false})
end

return QUIWidgetRecycleForMaterial
