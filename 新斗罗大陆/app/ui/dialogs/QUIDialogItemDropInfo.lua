----
-- Author: wkwang
-- Date: 2014-08-27 10:28:31
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogItemDropInfo = class("QUIDialogItemDropInfo", QUIDialog)

local QUIWidgetItemDropInfoCell = import("..widgets.QUIWidgetItemDropInfoCell")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
-- local QScrollView = import("...views.QScrollView")
local QScrollContain = import("..QScrollContain")
local QUIWidgetEquipmentCompose = import("..widgets.QUIWidgetEquipmentCompose")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogItemDropInfo:ctor(options)
    local ccbFile = "ccb/Dialog_ItemDropInfo.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerRobot", callback = handler(self, self._onTriggerRobot)},
        {ccbCallbackName = "onTriggerSetting", callback = handler(self, self._onTriggerSetting)},
    }
    QUIDialogItemDropInfo.super.ctor(self, ccbFile, callBacks, options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self.isAnimation = false

    self._dungeonLockDrop = {}

    -- 整理options里的数据
    self._isfromHeroInfo = options.isfromHeroInfo or true
    -- self._quickType = options.dropType
    -- self._walletInfo = options.walletInfo
    local id = options.itemId or options.itemID or options.id
    -- self._count = options.count

    -- Initialize scroll view
    -- self._topScroll = QScrollView.new(self._ccbOwner.topSheet, self._ccbOwner.top_sheet_layout:getContentSize(), {sensitiveDistance = 10})
    local scrollOptions = {}
    scrollOptions.sheet = self._ccbOwner.topSheet
    scrollOptions.sheet_layout = self._ccbOwner.top_sheet_layout
    scrollOptions.direction = QScrollContain.directionX
    scrollOptions.touchLayerOffsetY = 10
    scrollOptions.touchLayerOffsetY = -self._ccbOwner.top_sheet_layout:getContentSize().height
    self._topScroll = QScrollContain.new(scrollOptions)
    self._topScroll:setIsCheckAtMove(true)

    -- 根据物品的种类（itemconfig里面category）变更界面
    local category = remote.robot:getItemCategoryByID(id)
    local itemType = remote.robot:getItemTypeByID(id)
    if options.count and options.count > 0 and id ~= tonumber(ITEM_TYPE.POWERFUL_PIECE) and remote.robot:checkRobotUnlock() and category and category == ITEM_CONFIG_CATEGORY.SOUL then
        self._robotType = remote.robot.SOUL
        self:_showRobot( true )
    elseif options.count and options.count > 0 and id ~= tonumber(ITEM_TYPE.POWERFUL_PIECE) and remote.robot:checkRobotUnlock() and category and category == ITEM_CONFIG_CATEGORY.MATERIAL and itemType and itemType == ITEM_CONFIG_TYPE.MATERIAL then
        self._robotType = remote.robot.MATERIAL
        if remote.robot:isComposeItemByID( id ) then
            -- 合成类材料，不显示
            self:_showRobot( false )
        else
            self:_showRobot( true )
        end
    else
        self:_showRobot( false )
    end

    self._itemList = {}
    table.insert(self._itemList, {id = id, count = options.count, quickType = options.dropType, walletInfo = options.walletInfo})
    self._items = {}

    self._topSheetPositionX, self._topSheetPositionY = self._ccbOwner.topSheet:getPosition()
    self._topSheetSize = self._ccbOwner.top_sheet_layout:getContentSize()

    self:_update()
end

function QUIDialogItemDropInfo:_showRobot( isShowRobot )
    if self._mainScroll then
        self._mainScroll:clear()
        self._mainScroll = nil
    end
    local scrollOptions = {}
    scrollOptions.sheet = self._ccbOwner.mainSheet
    scrollOptions.direction = QScrollContain.directionY
    scrollOptions.touchLayerOffsetY = 10
    scrollOptions.touchLayerOffsetY = -self._ccbOwner.main_sheet_layout_robot:getContentSize().height

    if isShowRobot then
        self._ccbOwner.node_robot:setVisible(true)
        self._ccbOwner.node_bg:setVisible(false)
        self._ccbOwner.node_btn:setVisible(true)
        self._ccbOwner.node_mask_btn:setPositionY(-288)
        scrollOptions.sheet_layout = self._ccbOwner.main_sheet_layout_robot
        -- self._mainScroll = QScrollView.new(self._ccbOwner.mainSheet, self._ccbOwner.main_sheet_layout_robot:getContentSize(), {sensitiveDistance = 10})
        
        --xurui:检查扫荡功能解锁提示
        self._ccbOwner.node_reduce_effect:setVisible(app.tip:checkReduceUnlokState("battleRobot"))
    else
        self._ccbOwner.node_robot:setVisible(false)
        self._ccbOwner.node_bg:setVisible(true)
        self._ccbOwner.node_btn:setVisible(false)
        self._ccbOwner.node_mask_btn:setPositionY(-355)
        scrollOptions.sheet_layout = self._ccbOwner.main_sheet_layout
        -- self._mainScroll = QScrollView.new(self._ccbOwner.mainSheet, self._ccbOwner.main_sheet_layout:getContentSize(), {sensitiveDistance = 10})
    end
    self._mainScroll = QScrollContain.new(scrollOptions)
    self._mainScroll:setIsCheckAtMove(true)
end

function QUIDialogItemDropInfo:update(options)
    local id = options.itemId or options.itemID or options.id
    table.insert(self._itemList, {id = id, count = options.count, quickType = options.dropType, walletInfo = options.walletInfo})
    self:_update()
end

--[[
    更新上下2个区域
]]
function QUIDialogItemDropInfo:_update()
    self:_removeItemEvent()

    -- main bar 显示list里面最后的一个item
    local activatedItem = self._itemList[#self._itemList]

    if self._robotType and self._robotType == 2 then
        if not activatedItem or remote.robot:isComposeItemByID( activatedItem.id ) then
            -- 合成类材料，不显示
            self:_showRobot( false )
        else
            self:_showRobot( true )
        end
    end

    self:_updateTopBar(self._itemList)
    self:_checkDropType(activatedItem.id)
    self:_updateMainBar(activatedItem.id, activatedItem.count, activatedItem.quickType, activatedItem.walletInfo)
end

function QUIDialogItemDropInfo:_checkDropType( itemID )
    -- 判断是否是item表里的物品，不是的话就是resource表里的货币
    if not itemID then
        -- 货币
        self._dropType = DROP_TYPE.RESOURCE_ITEM
    else
        if QStaticDatabase.sharedDatabase():getItemCraftByItemId(itemID) then
            -- 合成类item
            self._dropType = DROP_TYPE.COMPOSE_ITEM
        else
            -- 普通item
            self._dropType = DROP_TYPE.NORMAL_ITEM
        end
    end
end

function QUIDialogItemDropInfo:_updateTopBar( itemList )
    self._topScroll:clear()

    local index = 0
    for k, v in ipairs(itemList) do
        self:_checkDropType(v.id) -- 判断list里面每个item的drop type
        if index > 0 then
            -- 获得小箭头图标， 当list里面不止一个item时，item中间会显示小箭头
            local sprite = CCSprite:create("ui/common2/arrow_g_small.png")
            sprite:setPosition(index * 120, -35)
            self._topScroll:addChild(sprite)
        end

        local item = QUIWidgetItemsBox.new()

        if self._dropType == DROP_TYPE.RESOURCE_ITEM then
            -- 这里只有货币类的item需要单独处理
            if not v.quickType and not v.walletInfo then
                assert(nil, "[QUIDialogItemDropInfo:_updateTopBar] no quickType and walletInfo.")
            else
                local resourceInfo = {}
                if v.walletInfo and table.nums(v.walletInfo) > 0 then
                    resourceInfo = v.walletInfo
                else
                    _, resourceInfo = QQuickWay:getItemInfoByDropType(v.quickType)
                end

                item:setGoodsInfo(v.id, resourceInfo.name, 0)
            end
        else
            item:setGoodsInfo(v.id, ITEM_TYPE.ITEM, 0)
        end

        if index == 0 then
            item:setScale(1)
        else
            item:setScale(0.7)
        end
        item:setPosition(index * 120 + 50, -60)
        item:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._topItemSelected))
        table.insert(self._items, item)
        item:setNeedshadow( false )
        self._topScroll:addChild(item)

        index = index + 1
    end

    local activatedItem = self._itemList[#self._itemList]
    self:_checkDropType(activatedItem.id)
    local itemID = activatedItem.id

    if self._dropType == DROP_TYPE.RESOURCE_ITEM then
        print("resource")
        local resourceInfo = {}
        if not activatedItem.quickType and not activatedItem.walletInfo then
            assert(nil, "[QUIDialogItemDropInfo:_updateMainBar] no quickType and walletInfo.")
        else
            if activatedItem.walletInfo and table.nums(activatedItem.walletInfo) > 0 then
                resourceInfo = activatedItem.walletInfo
            else
                _, resourceInfo = QQuickWay:getItemInfoByDropType(activatedItem.quickType)
            end
        end

        if table.nums(resourceInfo) == 0 then return end

        self._ccbOwner.tf_name:setString(resourceInfo.nativeName)

        local fontColor = EQUIPMENT_COLOR[resourceInfo.colour]
        self._ccbOwner.tf_name:setColor(fontColor)
        self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

        self._ccbOwner.tf_num:setString("")

        self._ccbOwner.tf_explain:setString(resourceInfo.description or "")
    else
        print("not resource")
        local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(itemID)

        self._ccbOwner.tf_name:setString(itemConfig.name)

        local fontColor = EQUIPMENT_COLOR[itemConfig.colour]
        self._ccbOwner.tf_name:setColor(fontColor)
        self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

        -- if itemConfig.type == ITEM_CONFIG_TYPE.SOUL then end
        self._ccbOwner.tf_num:setString("（拥有："..remote.items:getItemsNumByID(itemID).."）")
        self._ccbOwner.tf_explain:setString(itemConfig.description or "")
    end

    if index > 1 then
        self._ccbOwner.tf_explain:setString("")
    end

    local nameSize = self._ccbOwner.tf_name:getContentSize()
    local numSize = self._ccbOwner.tf_num:getContentSize()
    local explainSize = self._ccbOwner.tf_explain:getContentSize()
    -- print("[Kumo] explainSize.height : ", explainSize.height)
    local height = 0
    if index > 1 then
        height = nameSize.height
    else
        height = nameSize.height + explainSize.height
    end
    local offsetY = (self._topSheetSize.height - height)/2 + 5

    local nameX = self._topSheetPositionX + index * 100 + index * 10
    local nameY = self._topSheetPositionY - offsetY
    self._ccbOwner.tf_name:setPositionX(nameX)
    self._ccbOwner.tf_name:setPositionY(nameY)

    if nameX + nameSize.width + self._ccbOwner.tf_num:getContentSize().width > 340 then --超出外框就上下显示
        self._ccbOwner.tf_num:setPositionX(nameX)
        self._ccbOwner.tf_num:setPositionY(nameY - numSize.height/2 - 4)
        self._ccbOwner.tf_name:setPositionY(nameY + numSize.height/2 + 4)
    else
        self._ccbOwner.tf_num:setPositionX(nameX + nameSize.width)
        self._ccbOwner.tf_num:setPositionY(nameY - (nameSize.height - numSize.height) / 2)
    end


    self._ccbOwner.tf_explain:setPositionX(nameX)
    self._ccbOwner.tf_explain:setPositionY(nameY - nameSize.height)

    -- 获取选择效果的发光底框
    if index > 1 then
        local sprite = CCSprite:create("ui/HeroSystem/Equipment_jinhua.png")
        sprite:setPosition(index * 120 - 70, -55)
        sprite:setScale(1.1)
        sprite:setZOrder(-1) --更改显示层级
        self._topScroll:addChild(sprite)
    end
    self._topScroll:setRect(0, -self._ccbOwner.top_sheet_layout:getContentSize().height, 0, index * 120)
end

function QUIDialogItemDropInfo:_updateMainBar( itemID, count, quickType, walletInfo )
    self._mainScroll:clear()
    self._ccbOwner.node_tips:setVisible(false)
    
    self._dungeonLockDrop = {}
    self._robotList = {}
    self._robotEliteList = {}
    self._robotNormalList = {}
    self._tmpTbl = {} 

    self._robotTargetID = itemID
    self._robotNeedCount = count
    self._robotNeedBet = 1

    if self._dropType == DROP_TYPE.COMPOSE_ITEM then
        -- 合成类item
        print("[Kumo] QUIDialogItemDropInfo COMPOSE_ITEM")
        -- local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(itemID)
        -- self._ccbOwner.tf_name:setString(itemConfig.name)
        -- self._ccbOwner.tf_name:setColor(EQUIPMENT_COLOR[itemConfig.colour])

        local widget = QUIWidgetEquipmentCompose.new({id = itemID})
        widget:setPosition(self._ccbOwner.node_item_compose:getPosition())
        widget:addEventListener(QUIWidgetEquipmentCompose.NEW_EQUIPMENT_SELECTED, handler(self, self._addTopItem))
        widget:addEventListener(QUIWidgetEquipmentCompose.EQUIPMENT_COMPOSED, handler(self, self._itemComposed))
        widget:addEventListener(QUIWidgetEquipmentCompose.EQUIPMENT_START_COMPOSED, handler(self, self._itemStartCompose))
        widget:addEventListener(QUIWidgetEquipmentCompose.EQUIPMENT_END_COMPOSED, handler(self, self._itemEndCompose))                
        self._mainScroll:addChild(widget)
        table.insert(self._items, widget)
    elseif self._dropType == DROP_TYPE.NORMAL_ITEM then
        -- 普通item
        print("[Kumo] QUIDialogItemDropInfo NORMAL_ITEM")
        local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(itemID)
        -- self._ccbOwner.tf_name:setString(itemConfig.name)
        -- self._ccbOwner.tf_name:setColor(EQUIPMENT_COLOR[itemConfig.colour])

        self._totalHeight = 0
        local shortcutInfo = {}

        if itemConfig.shortcut_approach_new then
            shortcutInfo = string.split(itemConfig.shortcut_approach_new, ";")
        end

        if not shortcutInfo or table.nums(shortcutInfo) == 0 then
            self._ccbOwner.node_tips:setVisible(true)
            self:_showRobot( false )
            return
        end
        self._ccbOwner.node_tips:setVisible(false)

        for i = 1, #shortcutInfo, 1 do
            local shortcutID = tonumber(shortcutInfo[i])
            if shortcutID == 12001 then
                -- 普通副本掉落，但不包括BOSS宝箱
                self:_showItemDungeonDropInfo( DUNGEON_TYPE.NORMAL, shortcutID, itemID, count )
            elseif shortcutID == 13001 then
                -- 精英副本掉落，但不包括BOSS宝箱
                self:_showItemDungeonDropInfo( DUNGEON_TYPE.ELITE, shortcutID, itemID, count )
            else
                self:_showItemOtherDropInfo( shortcutID, itemID, count )
            end
        end
    elseif self._dropType == DROP_TYPE.RESOURCE_ITEM then
        -- 货币
        print("[Kumo] QUIDialogItemDropInfo RESOURCE_ITEM")
        local resourceInfo = {}
        if not quickType and not walletInfo then
            assert(nil, "[QUIDialogItemDropInfo:_updateMainBar] no quickType and walletInfo.")
        else
            if walletInfo and table.nums(walletInfo) > 0 then
                resourceInfo = walletInfo
            else
                _, resourceInfo = QQuickWay:getItemInfoByDropType(quickType)
            end
        end

        if table.nums(resourceInfo) == 0 then return end

        -- self._ccbOwner.tf_name:setString(resourceInfo.nativeName)
        -- self._ccbOwner.tf_name:setColor(EQUIPMENT_COLOR[resourceInfo.colour])

        self._totalHeight = 0
        local shortcutInfo = {}

        if resourceInfo.shortcut_approach_new then
            shortcutInfo = string.split(resourceInfo.shortcut_approach_new, ";")
        end

        if not shortcutInfo or table.nums(shortcutInfo) == 0 then
            self._ccbOwner.node_tips:setVisible(true)
            return
        end
        self._ccbOwner.node_tips:setVisible(false)

        for i = 1, #shortcutInfo, 1 do
            local shortcutID = tonumber(shortcutInfo[i])
            if shortcutID == 12001 and itemID then
                -- 普通副本掉落，但不包括BOSS宝箱
                self:_showItemDungeonDropInfo( DUNGEON_TYPE.NORMAL, shortcutID, itemID, count )
            elseif shortcutID == 13001 and itemID then
                -- 精英副本掉落，但不包括BOSS宝箱
                self:_showItemDungeonDropInfo( DUNGEON_TYPE.ELITE, shortcutID, itemID, count )
            elseif shortcutID == 47001 then
                if ENABLE_UNION_DUNGEON then
                    self:_showItemOtherDropInfo( shortcutID, itemID, count )
                end
            else
                if shortcutID == 24001 then
                    if remote.items:getItemsNumByID(25) + remote.items:getItemsNumByID(26) + remote.items:getItemsNumByID(27) > 0 then
                        self:_showItemOtherDropInfo( shortcutID, itemID, count )
                    end
                else
                    self:_showItemOtherDropInfo( shortcutID, itemID, count )
                end
            end
        end
    end
end

function QUIDialogItemDropInfo:_showItemDungeonDropInfo( dungeonType, shortcutID, itemID, count )
    print("[Kumo] QUIDialogItemDropInfo DungeonDrop", dungeonType, shortcutID, itemID, count)
    
    if not itemID then return end
    if not dungeonType or dungeonType == "" then dungeonType = DUNGEON_TYPE.ALL end

    local dropInfo = remote.instance:getDropInfoByItemId(itemID, dungeonType)
    -- -- 没有掉落途径
    -- if #dropInfo == 0 then
    --     self:_showItemOtherDropInfo( shortcutID, itemID, count )
    --     return
    -- end

    table.sort(dropInfo, function (a,b)
        if a.map.isLock == true and b.map.isLock == false then
            return true
        end
        if a.map.isLock == false and b.map.isLock == true then
            return false
        end
        if a.map.dungeon_type == DUNGEON_TYPE.NORMAL and b.map.dungeon_type ~= DUNGEON_TYPE.NORMAL then
            return true
        end
        if a.map.dungeon_type ~= DUNGEON_TYPE.NORMAL and b.map.dungeon_type == DUNGEON_TYPE.NORMAL then
            return false
        end
        return a.map.id < b.map.id
    end)

    local shortcutInfo = clone(db:getShortcutByID(shortcutID))
    local unlockCount = 0
    local offsetY = -5
    local lineDistance = 0
    for _, value in pairs(dropInfo) do
        if value.map.unlock_team_level < 130 then
            if not value.map.isLock then
                unlockCount = unlockCount + 1
                if unlockCount >= 2 then
                    break
                end
                table.insert(self._dungeonLockDrop, value)
                break
            end
            
            value.ccbFile = "ccb/Widget_ItemDropInfo.ccbi"
            value.targetId = itemID
            value.needNum = count
            value.icon = shortcutInfo.icon
            value.name = shortcutInfo.name

            local item = QUIWidgetItemDropInfoCell.new(value)
            item:addEventListener(QUIWidgetItemDropInfoCell.EVENT_LINK, handler(self, self.onEvent))
            item:setPosition(ccp(4, -(self._totalHeight+lineDistance + offsetY)))
            self._totalHeight = self._totalHeight + item:getContentSize().height + lineDistance

            table.insert(self._items, item)

            self._mainScroll:addChild(item)

            self:addRobotList( value )
        end
    end

    self:makeRobotList()

    if dungeonType == DUNGEON_TYPE.ELITE then
        for _, value in pairs(self._dungeonLockDrop) do
            if value.map.unlock_team_level < 130 then
                value.ccbFile = "ccb/Widget_ItemDropInfo.ccbi"
                value.targetId = itemID
                value.needNum = count
                value.icon = shortcutInfo.icon
                if value.map.dungeon_type == DUNGEON_TYPE.NORMAL then
                    value.name = "普通副本"
                    value.icon = "icon/item/putong_fuben_g.png"
                else
                    value.name = "精英副本"
                    value.icon = "icon/item/jingying_icon.png"
                end

                local item = QUIWidgetItemDropInfoCell.new(value)
                item:addEventListener(QUIWidgetItemDropInfoCell.EVENT_LINK, handler(self, self.onEvent))
                item:setPosition(ccp(4, -(self._totalHeight+lineDistance + offsetY)))
                self._totalHeight = self._totalHeight + item:getContentSize().height + lineDistance 

                table.insert(self._items, item)

                self._mainScroll:addChild(item)
            end
        end
    end

    self._mainScroll:setRect(0, -self._totalHeight, 0, self._ccbOwner.main_sheet_layout:getContentSize().width)
end

function QUIDialogItemDropInfo:_showItemOtherDropInfo( shortcutID, itemID, count )
    print("[Kumo] QUIDialogItemDropInfo OtherDrop", shortcutID, itemID, count)

    if not shortcutID or shortcutID == 0 or shortcutID == "" then return end

    local shortcutInfo = q.cloneShrinkedObject(db:getShortcutByID(shortcutID))
    -- printTable(shortcutInfo)
    if string.find(shortcutInfo.cname, "SHOP") and itemID then
        -- by 董洁需求，当item配置的shortcut_approach_new_level小于等于战队等级时，不显示商店类的快捷途径。
        local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(itemID)
        if itemConfig.shortcut_approach_new_level and itemConfig.shortcut_approach_new_level <= remote.user.level then
            return
        end
    end
    shortcutInfo.ccbFile = "ccb/Widget_ItemDropInfo.ccbi"
    shortcutInfo.targetId = itemID
    shortcutInfo.needNum = count

    local offsetY = -5
    local lineDistance = 0
    local item = QUIWidgetItemDropInfoCell.new(shortcutInfo)
    item:addEventListener(QUIWidgetItemDropInfoCell.EVENT_LINK, handler(self, self.onEvent))
    item:setPosition(ccp(4, -(self._totalHeight+lineDistance + offsetY)))
    self._totalHeight = self._totalHeight + item:getContentSize().height + lineDistance

    table.insert(self._items, item)

    self._mainScroll:addChild(item)
    self._mainScroll:setRect(0, -self._totalHeight, 0, self._ccbOwner.main_sheet_layout:getContentSize().width)
end

function QUIDialogItemDropInfo:onEvent(event)
    printTable(event, "onEvent>>")
    if event.name == QUIWidgetItemDropInfoCell.EVENT_LINK then
        if event.shortcutInfo then
            local shortcutInfo = event.shortcutInfo
            if shortcutInfo.cname == "COMMON" or shortcutInfo.name == "ELITE" then
                -- 普通副本和精英副本的event中没有shortcutInfo数据，所以这里不做处理
            elseif shortcutInfo.cname == "UPGRADE" then
                shortcutInfo.needHero = shortcutInfo.targetId
            end
            self:popSelf()
            QQuickWay:clickGoto(shortcutInfo)
        else
            if table.nums(self._itemList) == 1 then
                app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
            end
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogInstance", 
                options = {instanceType = event.info.dungeon_type, needPassId = event.info.dungeon_id, targetId = event.targetId, targetNum = event.targetNum, isQuickWay = true, 
                            isfromHeroInfo = self._isfromHeroInfo}})
        end
    end
end

function QUIDialogItemDropInfo:_addTopItem(event)
    for k, v in ipairs(self._itemList) do
        if not v.id then break end
        if v.id == event.id then
            assert("This equipment " .. event.id .. " is already in the equipment composite chain")
            return
        end
    end
    table.insert(self._itemList, {id = event.id, count = event.count})

    self:_update()
end

function QUIDialogItemDropInfo:_topItemSelected(event)
    local toDelete = false
    for k, v in ipairs(self._itemList) do
        if toDelete then
            table.remove(self._itemList, k)
        else
            if not v.id then break end
            if v.id == event.itemID and k ~= #self._itemList then
                toDelete = true
            end
        end
    end

    if toDelete then
        self:_update()
    end
end

function QUIDialogItemDropInfo:_itemComposed(event)
    self.isCompose = true
    self.composeAniamtion = false
    self:_onTriggerClose()
end

function QUIDialogItemDropInfo:_itemStartCompose(event)
    self.composeAniamtion = true
end

function QUIDialogItemDropInfo:_itemEndCompose(event)
    self.composeAniamtion = false
end

function QUIDialogItemDropInfo:_removeItemEvent()
    if self._items ~= nil then 
        for _, item in pairs(self._items) do
            item:removeAllEventListeners()
        end
    end
    self._items = {}
    self._dungeonLockDrop = {}
end

function QUIDialogItemDropInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogItemDropInfo:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    if self.composeAniamtion == true then
        return
    end
    self:playEffectOut()
end

function QUIDialogItemDropInfo:_onTriggerRobot(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_robot) == false then return end
    print("[Kumo] QUIDialogItemDropInfo:_onTriggerRobot(e)")
    self._isStartRobot = false

    --xurui:设置扫荡功能解锁提示
    if app.tip:checkReduceUnlokState("battleRobot") then
        app.tip:setReduceUnlockState("battleRobot", 2)
        self._ccbOwner.node_reduce_effect:setVisible(false)
    end

    if self._robotType == remote.robot.MATERIAL then
        if not app:getUserOperateRecord():hasRobotMaterialSetting() or (remote.robot:getAutoMaterialInvasion() and not app:getUserOperateRecord():hasRobotInvasionSetting()) then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotSetting",
                options = {robotType = self._robotType, targetID = self._robotTargetID, robotEliteList = self._robotList["Elite"], robotNormalList = self._robotList["Normal"]}}, {isPopCurrentDialog = false})
            return
        end
    end

    if self._robotType == remote.robot.SOUL then
        if not app:getUserOperateRecord():hasRobotSoulSetting() or (remote.robot:getAutoSoulInvasion() and not app:getUserOperateRecord():hasRobotInvasionSetting()) then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotSetting",
                options = {robotType = self._robotType, targetID = self._robotTargetID, robotEliteList = self._robotList["Elite"], robotNormalList = self._robotList["Normal"]}}, {isPopCurrentDialog = false})
            return
        end
    end

    if self._robotType == remote.robot.MATERIAL then
        if not self._robotList then
            app.tip:floatTip("魂师大人，当前没有可以扫荡的关卡哦~")
            return
        else
            local count = 0
            if remote.robot:getAutoMaterialElite() then
                if self._robotList["Elite"] and #self._robotList["Elite"] > 0 then
                    local tbl = remote.robot:getTotalEliteAttackListByBaseList(self._robotList["Elite"], self._robotType)
                    count = count + #tbl
                end
                
            end
            if self._robotList["Normal"] and remote.robot:getAutoMaterialNormal() then
                count = count + #self._robotList["Normal"]
            end
            if count == 0 then
                app.tip:floatTip("魂师大人，当前没有可以扫荡的关卡哦~")
                return
            end
        end

        -- if self._robotNeedCount and self._robotTargetID then
        --     local inPackCount = remote.items:getItemsNumByID( self._robotTargetID )
        --     if inPackCount >= self._robotNeedCount then
        --         app.tip:floatTip("魂师大人，您已经拥有足够的物品，无需扫荡～")
        --         return 
        --     end
        -- end

        if self._robotNeedCount and self._robotTargetID then
            local inPackCount = remote.items:getItemsNumByID( self._robotTargetID )
            while inPackCount >= self._robotNeedCount * self._robotNeedBet do
                self._robotNeedBet = self._robotNeedBet + 1
            end
        end
        
        if self._robotNeedBet > 1 then
            for _, list in pairs(self._robotList["Elite"]) do
                list.needNum = list.needNum * self._robotNeedBet
            end
            for _, list in pairs(self._robotList["Normal"]) do
                list.needNum = list.needNum * self._robotNeedBet
            end
        end
    end
    
    if self._robotType == remote.robot.SOUL then
        if not self._robotList or not self._robotList["Elite"] or #self._robotList["Elite"] == 0 then 
            app.tip:floatTip("魂师大人，当前没有可以扫荡的关卡哦~")
            return
        end

        local tbl, hasFree, minPrice = remote.robot:getTotalEliteAttackListByBaseList(self._robotList["Elite"], self._robotType)
        if #tbl == 0 then
            app.tip:floatTip("魂师大人，当前没有可以扫荡的关卡哦~")
            return
        end
        if not hasFree and remote.user.token < tonumber(minPrice) then
            QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
            return
        end
        if self._robotNeedCount and self._robotTargetID then
            local inPackCount = remote.items:getItemsNumByID( self._robotTargetID )
            while inPackCount >= self._robotNeedCount * self._robotNeedBet do
                self._robotNeedBet = self._robotNeedBet + 1
            end
        end
        
        if self._robotNeedBet > 1 then
            for _, list in pairs(self._robotList["Elite"]) do
                list.needNum = list.needNum * self._robotNeedBet
            end
        end
    end

    self._isStartRobot = true
    self:playEffectOut()
end

function QUIDialogItemDropInfo:_onTriggerSetting()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRobotSetting",
        options = {robotType = self._robotType, targetID = self._robotTargetID, robotEliteList = self._robotList["Elite"], robotNormalList = self._robotList["Normal"]}}, {isPopCurrentDialog = false})
end

function QUIDialogItemDropInfo:viewDidAppear()
    QUIDialogItemDropInfo.super.viewDidAppear(self)
end

function QUIDialogItemDropInfo:viewWillDisappear()
    QUIDialogItemDropInfo.super.viewWillDisappear(self)
    self:_removeItemEvent()
    if self._topScroll ~= nil then
        self._topScroll:disappear()
        self._topScroll = nil
    end
    if self._mainScroll then
        self._mainScroll:disappear()
        self._mainScroll = nil
    end
end

function QUIDialogItemDropInfo:viewAnimationOutHandler()
    local options = self:getOptions()
    local id = options.itemId or options.itemID or options.id
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_CLOSE_EQUIPMENT_COMPOSE_DIALOG, isCompose = self.isCompose == true, itemId = id})
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if self._isStartRobot then
        remote.robot:startRobot( self._robotList, self._robotType )
    end
end

function QUIDialogItemDropInfo:addRobotList( value )
    -- QPrintTable(value)
    if value and value.map and value.map.info and value.map.info.star == 3 then
        -- 可以扫荡
        if value.map.dungeon_type == DUNGEON_TYPE.ELITE then
            -- 精英副本
            local tbl = { id = value.map.int_dungeon_id, dungeonId = value.map.dungeon_id, dungeonType = value.map.dungeon_type, itemId = value.targetId, needNum = value.needNum, title = value.map.number, totalCount = value.map.attack_num }
            table.insert(self._robotEliteList, tbl)
        elseif value.map.dungeon_type == DUNGEON_TYPE.NORMAL then
            -- 普通副本
            -- 只添加最高一关，因为普通的可攻打次数有9999次，一关就够了
            if not self._tmpTbl or table.nums(self._tmpTbl) == 0 or value.map.id > self._tmpTbl.map.id then
                local todayPass = 0
                if q.refreshTime(remote.user.c_systemRefreshTime) <= (value.map.info.lastPassAt/1000) then
                    todayPass = value.map.info.todayPass
                end

                local num = value.map.attack_num - todayPass
                value.robotNum = num
                self._tmpTbl = value
            end
        end
    end
end

function QUIDialogItemDropInfo:makeRobotList()
    -- QPrintTable(self._tmpTbl)
    if self._tmpTbl and table.nums(self._tmpTbl) > 0 then
        for i = 1, self._tmpTbl.robotNum, 1 do
            local tbl = { id = self._tmpTbl.map.int_dungeon_id, dungeonId = self._tmpTbl.map.dungeon_id, dungeonType = self._tmpTbl.map.dungeon_type, itemId = self._tmpTbl.targetId, needNum = self._tmpTbl.needNum, title = self._tmpTbl.map.number }
            table.insert(self._robotNormalList, tbl)
        end
    end

    self._robotList["Elite"] = self._robotEliteList
    self._robotList["Normal"] = self._robotNormalList
end

return QUIDialogItemDropInfo