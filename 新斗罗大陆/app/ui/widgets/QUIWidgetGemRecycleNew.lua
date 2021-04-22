--
-- Author: Kumo.Wang
-- 魂骨分解新版
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemRecycleNew = class("QUIWidgetGemRecycleNew", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroRebornCompensation = import("..dialogs.QUIDialogHeroRebornCompensation")
local QRichText = import("...utils.QRichText")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QActorProp = import("...models.QActorProp")
local QListView = import("...views.QListView")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

QUIWidgetGemRecycleNew.REBORN_NA = "魂师大人，这颗魂骨已经是初始状态，不需要重生了～"
QUIWidgetGemRecycleNew.GEM_NA = "魂师大人，请先选择一颗魂骨"
QUIWidgetGemRecycleNew.REBORN_TITLE = "魂骨重生后将返还以下资源，是否确认分解该魂骨"
QUIWidgetGemRecycleNew.RECYCLE_TITLE = "魂骨分解后将返还以下资源，是否确认分解该魂骨"
QUIWidgetGemRecycleNew.GEM_RECYCLE_EQUIPPED = "魂师大人，无法分解已装备的魂骨，请将魂骨卸下后分解～"
QUIWidgetGemRecycleNew.GEM_REBORN_EQUIPPED = "魂师大人，无法重生已装备的魂骨，请将魂骨卸下后重生～"

QUIWidgetGemRecycleNew.NUMBER_TIME = 1

local tipOffsetX = 135

function QUIWidgetGemRecycleNew:ctor(options, dialogOptions)
	local ccbFile = "ccb/Widget_HeroRecover_Gem_new.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIWidgetGemRecycleNew.onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, QUIWidgetGemRecycleNew.onTriggerRight)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetGemRecycleNew.onTriggerOK)},
        {ccbCallbackName = "onTriggerAutoSelect", callback = handler(self, QUIWidgetGemRecycleNew.onTriggerAutoSelect)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetGemRecycleNew.onTriggerRule)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, QUIWidgetGemRecycleNew.onTriggerShop)},
	}
	QUIWidgetGemRecycleNew.super.ctor(self,ccbFile,callBacks,options)

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
function QUIWidgetGemRecycleNew:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还养成的资源与材料、魂骨",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "变为1级",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})
    if self:getOptions().type == 1 then
        richText = QRichText.new({
            {oType = "font", content = "分解返还部分",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "魂骨币",size = 20,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "（详见帮助）和全部",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "养成材料",size = 20,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        },790,{autoCenter = true})
    end

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetGemRecycleNew:onEnter()
    self._scheduler = scheduler.performWithDelayGlobal(function()
        self:update()
    end, 0)
end

function QUIWidgetGemRecycleNew:onExit()
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

function QUIWidgetGemRecycleNew:_initData()
    self._data = {}
    self._selectedItemInfoDic = {}

    self._data = remote.gemstone:getGemstoneByWear(false)
    table.sort(self._data, function (a, b)
            if a.gemstoneQuality ~= b.gemstoneQuality then
                return a.gemstoneQuality < b.gemstoneQuality
            elseif a.mix_level ~= b.mix_level then
                return a.mix_level < b.mix_level
            elseif a.refine_level ~= b.refine_level then
                return a.refine_level < b.refine_level                
            elseif a.craftLevel ~= b.craftLevel then
                return a.craftLevel < b.craftLevel
            elseif a.level ~= b.level then
                return a.level < b.level
            else
                if a.itemId ~= b.itemId then
                    return a.itemId < b.itemId
                else
                    return a.sid < a.sid
                end 
            end
        end)
    self:_initListView()
end

function QUIWidgetGemRecycleNew:_initListView()
    self._itemWidth = 90
    self._itemHeight = 100
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

function QUIWidgetGemRecycleNew:setItemInfo( item, itemData )
    if not item._itemNode then
        item._itemNode = QUIWidgetGemstonesBox.new()
        item._itemNode:setPosition(ccp(self._itemWidth/2, self._itemHeight/2))
        item._itemNode:setScale(0.8)

        item._ccbOwner.parentNode:addChild(item._itemNode)
        item._ccbOwner.parentNode:setContentSize(CCSizeMake(self._itemWidth, self._itemHeight))
    end
    item._itemNode:setGemstoneInfo(itemData)

    local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(itemData.itemId)
    local name = itemConfig.name
    name = string.gsub(name, "头骨", "\n头骨")
    name = string.gsub(name, "腿骨", "\n腿骨")
    name = string.gsub(name, "手骨", "\n手骨")
    name = string.gsub(name, "躯干骨", "\n躯干骨")
    item._itemNode:setName(name)
    item._itemNode:setNameVisible(true)

    local color = remote.gemstone:getSABC(itemData.gemstoneQuality).color
    local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
    item._itemNode:getName():setColor(fontColor)
    setShadowByFontColor(item._itemNode:getName(), fontColor)

    item._itemNode:setSelectedForFood(false)
    local key = itemData.sid
    if self._selectedItemInfoDic[key] then
        item._itemNode:setSelectedForFood(true)
    end
end

function QUIWidgetGemRecycleNew:_onTriggerClick( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local selectData = self._data[touchIndex]
    local item = listView:getItemByIndex(touchIndex)
    local changeSelected = item._itemNode:onSelectChangeForFood()
    local key = selectData.sid
    if changeSelected then
        self._selectedItemInfoDic[key] = {touchIndex = touchIndex, count = 1}
    else
        self._selectedItemInfoDic[key] = nil
    end
    if changeSelected then
        self:showSelectAnimation(selectData, item)
    end
    self:updatePreviewInfo()
end

function QUIWidgetGemRecycleNew:showSelectAnimation(selectData, item)
    local icon = QUIWidgetGemstonesBox.new()
    icon:setGemstoneInfo(selectData)

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

function QUIWidgetGemRecycleNew:setNodeCascadeOpacityEnabled( node )
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

function QUIWidgetGemRecycleNew:update()
    self:_initData()
end


function QUIWidgetGemRecycleNew:compensations()
    for key, value in pairs(self._selectedItemInfoDic) do
        local gemstone = self._data[value.touchIndex]
        self:recycleGem(gemstone)
    end
end

-- 回收，返还重生的和碎片
function QUIWidgetGemRecycleNew:recycleGem(gemstone)
    self:rebornGem(gemstone)

    local config = QStaticDatabase:sharedDatabase():getItemCraftByItemId(gemstone.itemId)
    local count = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId).gemstone_recycle
    local item_recycle = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId).item_recycle
    self._tempCompensations["silvermineMoney"] = (self._tempCompensations["silvermineMoney"] or 0) + count
    self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + (config.price or 0)
    if item_recycle then
        local items = string.split(item_recycle, ";")
        for k, v in ipairs(items) do
            local item = string.split(v, "^")
            local id = tonumber(item[1])
            local count = item[2]
            self._tempCompensations[id] = (self._tempCompensations[id] or 0) + (count or 0)
        end
    end  
end

-- 重生，返还突破和强化的
function QUIWidgetGemRecycleNew:rebornGem(gemstone)
    if gemstone.enhanceMoneyConsume > 0 then
        self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + gemstone.enhanceMoneyConsume
    end
    if gemstone.enhanceStoneConsume > 0 then
        self._tempCompensations["gemstone_energy"] = (self._tempCompensations["gemstone_energy"] or 0) + gemstone.enhanceStoneConsume
    end
    
    local config = QStaticDatabase:sharedDatabase():getGemstoneBreakThrough(gemstone.itemId)
    for i = gemstone.craftLevel, 1, -1 do
        local id1 = config[i + 1].component_id_1
        local id2 = config[i + 1].component_id_2
        self._tempCompensations[id1] = (self._tempCompensations[id1] or 0) + config[i + 1].component_num_1
        self._tempCompensations[id2] = (self._tempCompensations[id2] or 0) + config[i + 1].component_num_2
        self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + config[i + 1].price
    end

    if gemstone.godLevel and gemstone.godLevel > 0 then
        local advancedConfig = db:getGemstoneEvolutionAllPropBygodLevel(gemstone.itemId,gemstone.godLevel)
        if advancedConfig then
            for _,v in pairs(advancedConfig) do
                if v.evolution_consume_type_1 then
                    local id = v.evolution_consume_type_1
                    self._tempCompensations[id] = (self._tempCompensations[id] or 0) + (v.evolution_consume_1 or 0)
                    print("时光精华222=",self._tempCompensations[id])
                end
                if v.evolution_consume_type_2 then
                    local id = v.evolution_consume_type_2
                    self._tempCompensations[id] = (self._tempCompensations[id] or 0) + (v.evolution_consume_2 or 0)
                    print("天劫石222=",self._tempCompensations[id])
                end                  
            end
        end
    end
    
    if gemstone.refine_level and gemstone.refine_level > 0 then
        local refineHistory = remote.gemstone:getRefineHistoryItems(gemstone.sid)
        local refineConfig = db:getStaticByName("gemstone_refine")
        local itemConfig = refineConfig[tostring(gemstone.itemId)]
        if itemConfig then
            -- 本身返还的money
            for key,value in ipairs(itemConfig) do
                if tonumber(value.level) <= (gemstone.refine_level or 0) then
                    self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + (value.cost_money or 0)
                else
                    break
                end
            end

            -- 历史消耗的碎片
            for _,item in ipairs(refineHistory) do
                local itemInfo = db:getItemByID(item.id)
                local itemRecycle = remote.items:analysisServerItem(itemInfo.item_recycle)
                for _, recycel in ipairs(itemRecycle) do
                    self._tempCompensations[recycel.id] = (self._tempCompensations[recycel.id] or 0) + (recycel.count or 0) * item.count
                end
                self._tempCompensations["silvermineMoney"] = (self._tempCompensations["silvermineMoney"] or 0) + (itemInfo.gemstone_recycle or 0) * item.count
            end
        end
    end
    if gemstone.mix_level and gemstone.mix_level > 0 then
        local itemId = db:getConfigurationValue("GEMSTONE_MIX_ITEM") or 601007
        local mixConfigs = remote.gemstone:getGemstoneMixConfigListById(gemstone.itemId)
        for i,mixConfig in ipairs(mixConfigs) do
            if tonumber(mixConfig.mix_level) <= gemstone.mix_level then
                self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + (mixConfig.cost_money or 0)
                self._tempCompensations[itemId] = (self._tempCompensations[itemId] or 0) + (mixConfig.cost_num or 0)
            end
        end
    end
    
end

function QUIWidgetGemRecycleNew:sortCompensations(compensations)
    if compensations["money"] then
        table.insert(self._compensations, {id = "money", value = compensations["money"]})
        compensations["money"] = nil
    end
    if compensations["gemstone_energy"] then
        table.insert(self._compensations, {id = "gemstone_energy", value = compensations["gemstone_energy"]})
        compensations["gemstone_energy"] = nil
    end
    if compensations["silvermineMoney"] then
        table.insert(self._compensations, {id = "silvermineMoney", value = compensations["silvermineMoney"]})
        compensations["silvermineMoney"] = nil
    end

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

function QUIWidgetGemRecycleNew:_resetTF()
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

function QUIWidgetGemRecycleNew:updatePreviewInfo()
    self._compensations = {}
    self._tempCompensations = {} 
    self:_resetTF()
    self:compensations()  
    self:sortCompensations(self._tempCompensations)
    local jingshengbenyuan_itemid = db:getConfigurationValue("GEMSTONE_MIX_ITEM") or 601007
    -- QPrintTable(self._compensations)
    for _, info in ipairs(self._compensations) do
        local index = 0
        if tostring(info.id) == "601004" then
            -- S魂骨兑换令
            index = 1
        elseif tostring(info.id) == "601002" then
            index = 2
        elseif tostring(info.id) == "silvermineMoney" then
            index = 3
        elseif tostring(info.id) == "gemstone_energy" then
            index = 4
        elseif tostring(info.id) == "601001" then
            index = 5
        elseif tostring(info.id) == "money" then
            index = 6
        elseif tostring(info.id) == "601005" then --天劫灵石
            index = 7
        elseif tostring(info.id) == "601006" then --头
            index = 8
        elseif tostring(info.id) == tostring(jingshengbenyuan_itemid) then --精神本源
            index = 9
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

function QUIWidgetGemRecycleNew:onTriggerOK(event)
	if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")

	if next(self._selectedItemInfoDic) == nil then
		app.tip:floatTip(QUIWidgetGemRecycleNew.GEM_NA, tipOffsetX) 
		return
	end


    self._compensations = {}
    self._tempCompensations = {} 
    self:compensations()  

    local function callRecycleAPI()
        local sidList = {}
        for key, _ in pairs(self._selectedItemInfoDic) do
            table.insert(sidList, key)
        end
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        remote.gemstone:gemRecycle(sidList, function()
                remote.gemstone:removeGemstonesByList(sidList)
                if self._ccbView then
                    self:onTriggerRecycleFinished()
                    self:_resetTF() 
                end
            end)
    end
    self:sortCompensations(self._tempCompensations)

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
         options = {compensations = self._compensations, callFunc = callRecycleAPI, title = self:getTitle(), tips = "提示：分解后，该魂骨将彻底消失"}})
    --callRecycleAPI() 
end

function QUIWidgetGemRecycleNew:getTitle()
    local title = QUIWidgetGemRecycleNew.RECYCLE_TITLE
    if self:getOptions().type == 2 then
        title = QUIWidgetGemRecycleNew.REBORN_TITLE
    end

    return title
end

function QUIWidgetGemRecycleNew:onTriggerRecycleFinished()
	self._playing = true
    local gemstone = self._gemstone
    self._gemstone = nil

	local effect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.effect:addChild(effect)
    local animation = self:getOptions().type == 1 and "effects/HeroRecoverEffect_up2.ccbi" or "effects/HeroRecoverEffect_up.ccbi"
	effect:playAnimation(animation, function(ccbOwner)
		end, 
        function()
	    	effect:removeFromParentAndCleanup(true)
            if self:getOptions().type == 1 then
    		    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
    		        options = {compensations = self._compensations, type = 3, subtitle = "魂骨分解返还以下资源"}}, {isPopCurrentDialog = false})
            else
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                    options = {compensations = self._compensations, type = 4, subtitle = "魂骨重生返还以下资源"}}, {isPopCurrentDialog = false})
            end
		    self:update()
		    self._playing = false
	    end)
end


function QUIWidgetGemRecycleNew:onTriggerAutoSelect(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_autoSelect) == false then return end

    local func = function( planIndex )
        local minIndex = 999999
        for index, value in ipairs(self._data) do
            local key = value.sid
            local itemCount = 1

            if (planIndex == 1 and (value.gemstoneQuality == 12 or value.gemstoneQuality == 15)) 
                or (planIndex == 2 and (value.gemstoneQuality == 18)) 
                or planIndex == 3 then
                self._selectedItemInfoDic[key] = {touchIndex = index, count = itemCount}
                if index < minIndex then minIndex = index end
                if self._listView then
                    local item = self._listView:getItemByIndex(index)
                    if item then
                        item._itemNode:setSelectedForFood(true)
                    end
                end
            else
                self._selectedItemInfoDic[key] = nil
                if self._listView then
                    local item = self._listView:getItemByIndex(index)
                    if item then
                        item._itemNode:setSelectedForFood(false)
                    end
                end
            end
        end
        local isNotAutoState = self._listView:getItemByIndex(8)
        if minIndex ~= 999999 then
            if isNotAutoState then
                self._listView:startScrollToIndex(minIndex, false, 1000)
            end
            app.tip:floatTip("选择成功")
        else
            app.tip:floatTip("当前没有该魂骨")
        end

        self:updatePreviewInfo()
    end

    local planList = {}
    planList = {
        {
            callback = func, -- 回調
            titleName = "添加B和A级魂骨", -- 標題名
            instruction = "自动添加背包中未装备的B和A级魂骨", -- 說明內容
        },
        {
            callback = func, -- 回調
            titleName = "添加A+级魂骨", -- 標題名
            instruction = "自动添加背包中未装备的A+级魂骨", -- 說明內容
        },
        {
            callback = func, -- 回調
            titleName = "全部添加", -- 標題名
            instruction = "自动添加背包中未装备的所有魂骨", -- 說明內容
        },
    }
    
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAutoSelection", options = {planList = planList}}, {isPopCurrentDialog = false})
end


function QUIWidgetGemRecycleNew:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    local type = 7
    if self:getOptions().type == 2 then
        type = 8
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = type}}, {isPopCurrentDialog = false})
end

function QUIWidgetGemRecycleNew:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIWidgetGemRecycleNew:onTriggerLeft()
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

function QUIWidgetGemRecycleNew:onTriggerRight()
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


function QUIWidgetGemRecycleNew:updateNumber(tf, forceUpdate, updateCallBack, startNum, endNum)
    print("QUIWidgetGemRecycleNew:updateNumber(tf, startNum, endNum) ", tf, startNum, endNum)
    if not tf then return end

    if endNum > startNum or not forceUpdate or not updateCallBack then
        self:nodeEffect(tf)
    else
        tf:setString(endNum)
        return
    end

    forceUpdate:addUpdate(startNum, endNum, updateCallBack, QUIWidgetGemRecycleNew.NUMBER_TIME)
end

function QUIWidgetGemRecycleNew:nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

return QUIWidgetGemRecycleNew
