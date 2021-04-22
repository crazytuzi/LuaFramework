--
-- Author: Kumo.Wang
-- 仙品养成分解新版
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbPieceNew = class("QUIWidgetMagicHerbPieceNew", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroRebornCompensation = import("..dialogs.QUIDialogHeroRebornCompensation")
local QRichText = import("...utils.QRichText")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QActorProp = import("...models.QActorProp")
local QListView = import("...views.QListView")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

QUIWidgetMagicHerbPieceNew.MAGICHERB_NA = "魂师大人，请先选择仙品"
QUIWidgetMagicHerbPieceNew.REBORN_TITLE = "仙品分解后将返还以下资源，是否确认分解"
QUIWidgetMagicHerbPieceNew.MAGICHERB_REBORN_EQUIPPED = "魂师大人，无法分解已装备的仙品，请将仙品卸下后分解～"

QUIWidgetMagicHerbPieceNew.MAGICHERB_SELECTED = "QUIWidgetMagicHerbPieceNew_.MAGICHERB_SELECTED"

QUIWidgetMagicHerbPieceNew.NUMBER_TIME = 1

local tipOffsetX = 135

function QUIWidgetMagicHerbPieceNew:ctor(options, dialogOptions)
    local ccbFile = "ccb/Widget_HeroRecover_MagicHerb_new.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIWidgetMagicHerbPieceNew.onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, QUIWidgetMagicHerbPieceNew.onTriggerRight)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetMagicHerbPieceNew.onTriggerOK)},
        {ccbCallbackName = "onTriggerAutoSelect", callback = handler(self, QUIWidgetMagicHerbPieceNew.onTriggerAutoSelect)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetMagicHerbPieceNew.onTriggerRule)},
    }
    QUIWidgetMagicHerbPieceNew.super.ctor(self,ccbFile,callBacks,options)

    self._compensations = {}
    self._tempCompensations = {}

    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height

    self._selectEffectLayer = CCNode:create()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:getView():addChild(self._selectEffectLayer)

    self:_resetTF()
    self:initExplainTTF()
end

--创建底部说明文字
function QUIWidgetMagicHerbPieceNew:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还仙品养成道具，仙品",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "转化为强化道具",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "，",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "蛇涎",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "转化为仙草精华",size = 22,color =  ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "。",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetMagicHerbPieceNew:onEnter()
    self._scheduler = scheduler.performWithDelayGlobal(function()
        self:update()
    end, 0)
end

function QUIWidgetMagicHerbPieceNew:onExit()
    if self._scheduler ~= nil then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
    if self._leftScheduler ~= nil then
        scheduler.unscheduleGlobal(self._leftScheduler)
        self._leftScheduler = nil
    end
    if self._rightScheduler ~= nil then
        scheduler.unscheduleGlobal(self._rightScheduler)
        self._rightScheduler = nil
    end
    if self._forceUpdateDic and next(self._forceUpdateDic) then
        for _, fu in pairs(self._forceUpdateDic) do
            if fu then
                fu:stopUpdate()
                fu = nil
            end
        end
    end
end

function QUIWidgetMagicHerbPieceNew:_initData()
    self._data = {}
    self._selectedItemInfoDic = {}

    local magicHerbItemList = remote.magicHerb:getMagicHerbItemList()
    local noWearList = {}
    for _, value in ipairs(magicHerbItemList) do
        if (not value.actorId or value.actorId == 0) and not value.isLock then
            local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(value.itemId)
            local itemConfig = db:getItemByID(value.itemId)

            table.insert(noWearList,{magicHerbInfo = value ,magicHerbConfig = magicHerbConfig , itemConfig = itemConfig})
        end
    end

    self._data = noWearList
            
    table.sort( self._data, function(a, b)
            if a.magicHerbInfo.breedLevel ~= b.magicHerbInfo.breedLevel then
                return a.magicHerbInfo.breedLevel < b.magicHerbInfo.breedLevel
            elseif a.magicHerbConfig.aptitude ~= b.magicHerbConfig.aptitude then
                return a.magicHerbConfig.aptitude < b.magicHerbConfig.aptitude
            elseif a.magicHerbInfo.grade ~= b.magicHerbInfo.grade then
                return a.magicHerbInfo.grade < b.magicHerbInfo.grade
            elseif a.magicHerbInfo.level ~= b.magicHerbInfo.level then
                return a.magicHerbInfo.level < b.magicHerbInfo.level
            else
                return a.magicHerbInfo.itemId < b.magicHerbInfo.itemId
            end
        end )
    -- QPrintTable(self._data)
    local wildConfigList = remote.magicHerb:getAllWildMagicHerbConfigList()
    table.sort(wildConfigList, function(a, b)
            return a.magic_herb_grade > b.magic_herb_grade
        end)
    for _, wildConfig in ipairs(wildConfigList) do
        if remote.items:getItemsNumByID(wildConfig.id) > 0 then
            table.insert(self._data, 1, {itemConfig = wildConfig })
        end
    end

    --高级蛇涎

    local items = db:getConfigurationValue("magic_herb_recover_item")
    local itemIds = string.split(items, ";")

    if not q.isEmpty(itemIds) then
        for i,v in ipairs(itemIds or {}) do
            local itemId = tonumber(v)
            if remote.items:getItemsNumByID(itemId) > 0 then
            local itemConfig = db:getItemByID(itemId)
                table.insert(self._data, 1, {itemConfig = itemConfig })
            end    
        end
    end

    -- if remote.items:getItemsNumByID(17100042) > 0 then
    --     local itemConfig = db:getItemByID(17100042)
    --     table.insert(self._data, 1, {itemConfig = itemConfig })
    -- end    
    -- --普通蛇涎
    -- if remote.items:getItemsNumByID(17100041) > 0 then
    --     local itemConfig = db:getItemByID(17100041)
    --     table.insert(self._data, 1, {itemConfig = itemConfig })
    -- end    

    self:_initListView()
end

function QUIWidgetMagicHerbPieceNew:_initListView()
    self._itemWidth = 110   
    self._itemHeight = 130
    local _totalNumber = #self._data
    local _scrollEndCallBack
    local _scrollBeginCallBack
    _scrollEndCallBack = function ()
        print("_scrollEndCallBack")
        if self._ccbView then
            self._ccbOwner.arrowRight:setVisible(false)
            self._ccbOwner.arrowLeft:setVisible(true)
        end
    end

    _scrollBeginCallBack = function ()
        print("_scrollBeginCallBack")
        if self._ccbView then
            self._ccbOwner.arrowRight:setVisible(true)
            self._ccbOwner.arrowLeft:setVisible(false)
        end
    end
    self._ccbOwner.arrowRight:setVisible(true)
    self._ccbOwner.arrowLeft:setVisible(false)
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                -- print("renderItemCallBack    ", list:getCurTouchIndex(), list:getCurStartIndex(), list:getCurEndIndex())
                if self._ccbView then
                    if self._leftScheduler ~= nil then
                        scheduler.unscheduleGlobal(self._leftScheduler)
                        self._leftScheduler = nil
                    end
                    if self._rightScheduler ~= nil then
                        scheduler.unscheduleGlobal(self._rightScheduler)
                        self._rightScheduler = nil
                    end
                    self._ccbOwner.arrowLeft:setVisible(list:getCurStartIndex() > 1)
                    self._ccbOwner.arrowRight:setVisible(list:getCurEndIndex() < _totalNumber)
                end
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetQlistviewItem.new()
                    isCacheNode = false
                end

                self:setItemInfo(item, itemData)

                info.item = item
                info.size = CCSizeMake(self._itemWidth, self._itemHeight)

                list:registerBtnHandler(index, "btn_click", handler(self, self._onTriggerClick))
                
                return isCacheNode
            end,
            isVertical = false,
            multiItems = 1,
            enableShadow = false,
            curOffset = 0,
            contentOffsetX = 10,
            ignoreCanDrag = false,
            autoCenter = true,
            scrollEndCallBack = _scrollEndCallBack,
            scrollBeginCallBack = _scrollBeginCallBack,
            totalNumber = _totalNumber,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = _totalNumber})
    end
end

function QUIWidgetMagicHerbPieceNew:setItemInfo( item, itemData )
    if not item._itemNode then
        item._itemNode = QUIWidgetMagicHerbBox.new()
        item._itemNode:setPosition(ccp(self._itemWidth/2, self._itemHeight/2))
        item._itemNode:setScale(0.9)

        item._ccbOwner.parentNode:addChild(item._itemNode)
        item._ccbOwner.parentNode:setContentSize(CCSizeMake(self._itemWidth, self._itemHeight))
    end
    local key = nil
    if itemData.magicHerbConfig == nil then
        item._itemNode:setItemByItemId(itemData.itemConfig.id , nil, 0)
        key = itemData.itemConfig.id
        
    else
        item._itemNode:setInfo(itemData.magicHerbInfo.sid)
        key = itemData.magicHerbInfo.sid
    end
    item._itemNode:setNameFormat("破碎", "\n破碎")
    item._itemNode:setSelectedForFood(false)

    if self._selectedItemInfoDic[key] then
        item._itemNode:setSelectedForFood(true)
        item._itemNode:setSelectedFoodNum(self._selectedItemInfoDic[key].count)
        item._itemNode:setItemSelectedCount(self._selectedItemInfoDic[key].count)
    end
end

function QUIWidgetMagicHerbPieceNew:_onTriggerClick( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local selectData = self._data[touchIndex]
    local item = listView:getItemByIndex(touchIndex)

    local isSelected = item._itemNode:getIsSelectedForFood()
    local changeSelected
    if isSelected then
        -- 已經被選取，則做減法
        changeSelected = item._itemNode:onSubFood()
    else
        -- 未被選取，則做加法
        changeSelected = item._itemNode:onAddFood()
    end
    local key = selectData.itemConfig.id
    if selectData.magicHerbConfig then
        key = selectData.magicHerbInfo.sid
    end
    -- print("key = ", key, tonumber(key))
    if changeSelected then
        local itemCount = item._itemNode:getSelectedFoodNum()
        self._selectedItemInfoDic[key] = {touchIndex = touchIndex, count = itemCount}
        if tonumber(key) then
            item._itemNode:setItemSelectedCount(itemCount)
        end
    else
        self._selectedItemInfoDic[key] = nil

        if tonumber(key) then
            item._itemNode:setItemSelectedCount(0)
        end
    end
    if not isSelected then
        self:showSelectAnimation(selectData, item)
    end
    self:updatePreviewInfo()
end

function QUIWidgetMagicHerbPieceNew:showSelectAnimation(selectData, item)
    local icon = QUIWidgetMagicHerbBox.new()
    if selectData.magicHerbConfig == nil then
        icon:setItemByItemId(selectData.itemConfig.id, nil, 0)
    else
        icon:setInfo(selectData.magicHerbInfo.sid)
    end

    self:setNodeCascadeOpacityEnabled(icon)

    local p = item._itemNode:convertToWorldSpaceAR(ccp(0,0))
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
    arr:addObject(CCSpawn:createWithTwoActions(bezierTo, CCDelayTime:create(0.2)))
    arr:addObject(CCCallFunc:create(function()
            icon:removeFromParentAndCleanup(true)
        end))
    local seq = CCSequence:create(arr)
    icon:runAction(seq)
end

function QUIWidgetMagicHerbPieceNew:setNodeCascadeOpacityEnabled( node )
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

function QUIWidgetMagicHerbPieceNew:update()
    self:_initData()
end

function QUIWidgetMagicHerbPieceNew:compensations()
    for key, value in pairs(self._selectedItemInfoDic) do
        if tonumber(key) then
            self:rebornMagicHerbWild(tonumber(key), value.count)
        else
            local magicHerbItem = remote.magicHerb:getMaigcHerbItemBySid(key)
            if magicHerbItem then
                self:rebornMagicHerb(magicHerbItem)
            end
        end
    end
end

function QUIWidgetMagicHerbPieceNew:rebornMagicHerbWild( id, count )
    local itemConfig = db:getItemByID(id)
    local tbl = string.split(itemConfig.item_recycle, "^")
    local itemId = tonumber(tbl[1])
    local itemNum = tonumber(tbl[2]) * count
    if self._tempCompensations[itemId] == nil then
        self._tempCompensations[itemId] = itemNum
    else
        self._tempCompensations[itemId] = self._tempCompensations[itemId] + itemNum
    end
end

-- 分解，返还突破和强化的
function QUIWidgetMagicHerbPieceNew:rebornMagicHerb(magicHerb)
    -- 升星
    local gradeItemNum, gradeItemId = self:_getGradeItemNum(magicHerb)
    -- 升級
    local uplevelItemNum, uplevelItemId = self:_getUpLevelItemNum(magicHerb)
    -- 轉化強化道具
    local changeItemNum, changeItemId = self:_getChangeItemNum(magicHerb)
    -- 轉生
    local refineItemNum, refineItemId = self:_getRefineItemNum(magicHerb)
    -- 培育
    local breedItemNum, breedItemId = self:_getBreedItemNum(magicHerb)

    local insertFunc = function(id, num)
        if num <= 0 then return end 
        if self._tempCompensations[id] == nil then
            self._tempCompensations[id] = num
        else
            self._tempCompensations[id] = self._tempCompensations[id] + num
        end
    end
    insertFunc(gradeItemId, gradeItemNum)
    insertFunc(uplevelItemId, uplevelItemNum)
    insertFunc(changeItemId, changeItemNum)
    insertFunc(refineItemId, refineItemNum)
    insertFunc(breedItemId, breedItemNum)
end

function QUIWidgetMagicHerbPieceNew:_getGradeItemNum(magicHerb)
    local sid = magicHerb.sid
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
    local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerb.itemId)
    local magicHerbGradeConfigs = QStaticDatabase.sharedDatabase():getStaticByName("magic_herb_grade")
    local configList = magicHerbGradeConfigs[tostring(magicHerbItemInfo.itemId)] or {}
    local gradeItemNum = 0
    for _, value in ipairs(configList) do
        if value.grade <= magicHerb.grade and value.consum_num then
            gradeItemNum = gradeItemNum + value.consum_num
        end
    end

    local gradeItemId = 17100039
    local wildConfig = remote.magicHerb:getWildMagicHerbByAptitude(magicHerbConfig.aptitude)
    if wildConfig then
        gradeItemId = wildConfig.id
    end

    return gradeItemNum, gradeItemId
end

function QUIWidgetMagicHerbPieceNew:_getUpLevelItemNum(magicHerb)
    local sid = magicHerb.sid
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)

    local magicHerbEnchantConfigs = QStaticDatabase.sharedDatabase():getStaticByName("magic_herb_enhance")
    local configList = magicHerbEnchantConfigs[tostring(magicHerbItemInfo.itemId)] or {}
    local upLevelItemId = 0
    local upLevelItemNum = 0
    for _, value in ipairs(configList) do
        if value.level <= magicHerb.level and value.consum then
            local tbl = string.split(value.consum, "^")
            if upLevelItemId == 0 then
                upLevelItemId = tonumber(tbl[1])
            end
            upLevelItemNum = upLevelItemNum + tonumber(tbl[2])
        end
    end
    return upLevelItemNum, upLevelItemId
end

function QUIWidgetMagicHerbPieceNew:_getChangeItemNum(magicHerb)
    local changeItemId = 0
    local changeItemNum = 0
    local sid = magicHerb.sid
    local itemConfig = db:getItemByID(magicHerb.itemId)
    if itemConfig and itemConfig.item_recycle then
        local tbl = string.split(itemConfig.item_recycle, "^")
        changeItemId = tonumber(tbl[1])
        changeItemNum = tonumber(tbl[2])
    end

    return changeItemNum, changeItemId
end

function QUIWidgetMagicHerbPieceNew:_getRefineItemNum(magicHerb)
    local sid = magicHerb.sid
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
    local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)

    local refineItemId = remote.magicHerb:getRefineItemIdAndPriceByAptitude( magicHerbConfig.aptitude )
    local refineItemNum = 0
    local num1 = math.floor((magicHerbItemInfo.extendsAttributesRefineConsume or 0) * 0.3)
    local num2 = math.floor((magicHerbItemInfo.attributesRefineConsume or 0) * 0.3)
    refineItemNum = num1 + num2
    
    return refineItemNum, refineItemId
end


function QUIWidgetMagicHerbPieceNew:_getBreedItemNum(magicHerb)

    local breedItemId = 0
    local breedLevel = magicHerb.breedLevel or 0 
    local breedItemNum = 0
    if breedLevel > 0 then
        for i=1,breedLevel do
            local breedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(magicHerb.itemId, i)
            if breedConfig then
                breedItemNum = breedItemNum + breedConfig.breed_num
                breedItemId = breedConfig.breed_item
            end
        end
    end
    return breedItemNum , breedItemId
end

function QUIWidgetMagicHerbPieceNew:sortCompensations(compensations)
    local tempCompensations = {}

    for k, v in pairs(compensations) do
        if v > 0 then
            table.insert(tempCompensations, {id = k, value = v})
        end
    end
    table.sort(tempCompensations, function(x, y)
            return x.id < y.id
        end)
    for _, v in ipairs(tempCompensations) do
        table.insert(self._compensations, v)
    end
end

function QUIWidgetMagicHerbPieceNew:_resetTF()
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

function QUIWidgetMagicHerbPieceNew:updatePreviewInfo()
    self._compensations = {}
    self._tempCompensations = {} 
    self:_resetTF()
    self:compensations()  
    self:sortCompensations(self._tempCompensations)

    -- QPrintTable(self._compensations)
    for _, info in ipairs(self._compensations) do
        local index = 0
        if tostring(info.id) == "17100042" then
            index = 1
        elseif tostring(info.id) == "17100041" then
            index = 2
        elseif tostring(info.id) == "17100043" then
            index = 3
        elseif tostring(info.id) == "17100037" then
            index = 4
        elseif tostring(info.id) == "17100038" then
            index = 5
        elseif tostring(info.id) == "17100039" then
            index = 6
        elseif tostring(info.id) == "17100044" then
            index = 7
        end

        local tf = self._ccbOwner["tf_"..index]
        if tf then
            -- tf:setString(info.value)
            if not self._oldValueDic then
                self._oldValueDic = {}
            end
            if not self._oldValueDic[info.id] then
                self._oldValueDic[info.id] = 0
            end
            if not self._forceUpdateDic then
                self._forceUpdateDic = {}
            end
            if not self._forceUpdateDic[info.id] then
                self._forceUpdateDic[info.id] = QTextFiledScrollUtils.new()
            end
            if not self._onForceUpdateDic then
                self._onForceUpdateDic = {}
            end
            if not self._onForceUpdateDic[info.id] then
                self._onForceUpdateDic[info.id] = function (value)
                    tf:setString(tostring(math.ceil(value)))
                end
            end

            self:updateNumber(tf, self._forceUpdateDic[info.id], self._onForceUpdateDic[info.id], self._oldValueDic[info.id], info.value)
            self._oldValueDic[info.id] = info.value
        end
    end
end

function QUIWidgetMagicHerbPieceNew:onTriggerOK(event)
    if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")

    if next(self._selectedItemInfoDic) == nil then
        app.tip:floatTip(QUIWidgetMagicHerbPieceNew.MAGICHERB_NA, tipOffsetX) 
        return
    end

     self._compensations = {}
     self._tempCompensations = {} 
     self:compensations()  

    local function callRecycleAPI()
        local itemList = {}
        local sidList = {}
        for key, value in pairs(self._selectedItemInfoDic) do
            if value.count > 1 then
                -- 破碎仙品，道具
                table.insert(itemList, {type = tonumber(key), count = value.count})
            else
                if tonumber(key) then
                    -- 破碎仙品，道具
                    table.insert(itemList, {type = tonumber(key), count = value.count})
                else
                    table.insert(sidList, key)
                end
            end
        end
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        remote.magicHerb:magicHerbRecoverRequest(sidList, itemList, function()
                if self._ccbView then
                    self:onTriggerRecycleFinished()
                    self:_resetTF()
                end
            end)
    end
    
     self:sortCompensations(self._tempCompensations)

     app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
         options = {compensations = self._compensations, callFunc = callRecycleAPI, title = self:getTitle(), tips = "提示：分解后，该仙品/蛇涎将彻底消失"}})
    --callRecycleAPI()
end

function QUIWidgetMagicHerbPieceNew:onTriggerAutoSelect(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_autoSelect) == false then return end

    local func = function( planIndex )
        local minIndex = 999999
        for index, value in ipairs(self._data) do
            local key = value.itemConfig.id
            --只分解仙品与破碎仙品
            if ITEM_CONFIG_TYPE.MAGICHERB_WILD == value.itemConfig.type or ITEM_CONFIG_TYPE.MAGICHERB == value.itemConfig.type then

                local itemCount = remote.items:getItemsNumByID(key)
                if value.magicHerbConfig then
                    key = value.magicHerbInfo.sid
                    itemCount = 1
                end

                if (planIndex == 1 and (value.magicHerbConfig and value.magicHerbConfig.aptitude == 15 or value.magic_herb_grade == 15)) 
                    or (planIndex == 2 and (value.magicHerbConfig and value.magicHerbConfig.aptitude == 18 or value.magic_herb_grade == 18)) 
                    or planIndex == 3 then

                    self._selectedItemInfoDic[key] = {touchIndex = index, count = itemCount}
                    if index < minIndex then minIndex = index end
                    if self._listView then
                        local item = self._listView:getItemByIndex(index)
                        if item then
                            if tonumber(key) then
                                item._itemNode:setSelectedFoodNum(itemCount)
                                item._itemNode:setItemSelectedCount(itemCount)
                            end
                            item._itemNode:setSelectedForFood(true)
                        end
                    end
                else
                    self._selectedItemInfoDic[key] = nil
                    if self._listView then
                        local item = self._listView:getItemByIndex(index)
                        if item then
                            if tonumber(key) then
                                item._itemNode:setSelectedFoodNum(0)
                                item._itemNode:setItemSelectedCount(0)
                            end
                            item._itemNode:setSelectedForFood(false)
                        end
                    end
                end

                self:updatePreviewInfo()

            end


        end
        local isNotAutoState = self._listView:getItemByIndex(7)
        if minIndex ~= 999999 then
            if isNotAutoState then
                self._listView:startScrollToIndex(minIndex, false, 1000)
            end
            app.tip:floatTip("选择成功")
        else
            app.tip:floatTip("当前没有该仙品")
        end
    end

    local planList = {}
    planList = {
        {
            callback = func, -- 回調
            titleName = "添加A级仙品", -- 標題名
            instruction = "自动添加背包中未装备和未锁定的A级仙品", -- 說明內容
        },
        {
            callback = func, -- 回調
            titleName = "添加A+级仙品", -- 標題名
            instruction = "自动添加背包中未装备和未锁定的A+级仙品", -- 說明內容
        },
        {
            callback = func, -- 回調
            titleName = "全部添加", -- 標題名
            instruction = "自动添加背包中未装备和未锁定的所有仙品", -- 說明內容
        },
    }
    
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAutoSelection", options = {planList = planList}}, {isPopCurrentDialog = false})
end

function QUIWidgetMagicHerbPieceNew:getTitle()
    local title = QUIWidgetMagicHerbPieceNew.REBORN_TITLE

    return title
end

function QUIWidgetMagicHerbPieceNew:onTriggerRecycleFinished()
    self._playing = true
    local magicHerb = self._magicHerb
    self._magicHerb = nil

    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.effect:addChild(effect)
    local animation = self:getOptions().type == 1 and "effects/HeroRecoverEffect_up2.ccbi" or "effects/HeroRecoverEffect_up.ccbi"
    effect:playAnimation(animation, function()
        end, 
        function()
            effect:removeFromParentAndCleanup(true)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                options = {compensations = self._compensations, type = 10, subtitle = "仙品分解返还以下资源"}}, {isPopCurrentDialog = false})
            self:update()
            self._playing = false
        end)
end

function QUIWidgetMagicHerbPieceNew:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 18}}, {isPopCurrentDialog = false})
end

function QUIWidgetMagicHerbPieceNew:onTriggerLeft()
    if self._playing then return end
    if self._listView then
        if self._leftScheduler == nil then
            self._leftScheduler = scheduler.performWithDelayGlobal(function()
                self._ccbOwner.arrowLeft:setVisible(false)
            end, 0.5)
        end
        self._listView:startScrollToPosScheduler(self._width * 0.9, 0.8, false, function ()
                if self._ccbView then
                    if self._leftScheduler ~= nil then
                        scheduler.unscheduleGlobal(self._leftScheduler)
                        self._leftScheduler = nil
                    end
                    self._ccbOwner.arrowRight:setVisible(true)
                end
            end, true)
    end
end

function QUIWidgetMagicHerbPieceNew:onTriggerRight()
    if self._playing then return end
    if self._listView then
        if self._rightScheduler == nil then
            self._rightScheduler = scheduler.performWithDelayGlobal(function()
                self._ccbOwner.arrowRight:setVisible(false)
            end, 0.5)
        end
        self._listView:startScrollToPosScheduler(-self._width * 0.9, 0.8, false, function ()
                if self._ccbView then
                    if self._rightScheduler ~= nil then
                        scheduler.unscheduleGlobal(self._rightScheduler)
                        self._rightScheduler = nil
                    end
                    self._ccbOwner.arrowLeft:setVisible(true)
                end
            end, true)
    end
end

function QUIWidgetMagicHerbPieceNew:updateNumber(tf, forceUpdate, updateCallBack, startNum, endNum)
    print("QUIWidgetMagicHerbPieceNew:updateNumber(tf, startNum, endNum) ", tf, startNum, endNum)
    if not tf then return end

    if endNum > startNum or not forceUpdate or not updateCallBack then
        self:nodeEffect(tf)
    else
        tf:setString(endNum)
        return
    end

    forceUpdate:addUpdate(startNum, endNum, updateCallBack, QUIWidgetMagicHerbPieceNew.NUMBER_TIME)
end

function QUIWidgetMagicHerbPieceNew:nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

return QUIWidgetMagicHerbPieceNew
