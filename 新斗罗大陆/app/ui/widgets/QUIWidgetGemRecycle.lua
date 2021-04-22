--
-- Author: qinyuanji
-- Date: 2015-04-02 17:14:49
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemRecycle = class("QUIWidgetGemRecycle", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroRebornCompensation = import("..dialogs.QUIDialogHeroRebornCompensation")
local QUIWidgetShopTap = import("..widgets.QUIWidgetShopTap")
local QRichText = import("...utils.QRichText")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIDialogGemRecycleSelection = import("..dialogs.QUIDialogGemRecycleSelection")

QUIWidgetGemRecycle.REBORN_NA = "魂师大人，这颗魂骨已经是初始状态，不需要重生了～"
QUIWidgetGemRecycle.GEM_NA = "魂师大人，请先选择一颗魂骨"
QUIWidgetGemRecycle.REBORN_TITLE = "魂骨重生后将返还以下资源，是否确认分解该魂骨"
QUIWidgetGemRecycle.RECYCLE_TITLE = "魂骨分解后将返还以下资源，是否确认分解该魂骨"
QUIWidgetGemRecycle.GEM_RECYCLE_EQUIPPED = "魂师大人，无法分解已装备的魂骨，请将魂骨卸下后分解～"
QUIWidgetGemRecycle.GEM_REBORN_EQUIPPED = "魂师大人，无法重生已装备的魂骨，请将魂骨卸下后重生～"

QUIWidgetGemRecycle.GEM_SELECTED = "QUIWidgetGemRecycle_GEM_SELECTED"

local tipOffsetX = 135

function QUIWidgetGemRecycle:ctor(options, dialogOptions)
	local ccbFile = "ccb/Widget_HeroRecover_baoshi2.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self.onTriggerSelect)},
		{ccbCallbackName = "onTriggerRecycle", callback = handler(self, self.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self.onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self.onTriggerRule)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, self.onTriggerExchange)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self.onTriggerShop)},
        {ccbCallbackName = "onTriggerMonthCard", callback = handler(self, self._onTriggerMonthCard)},
	}

	QUIWidgetGemRecycle.super.ctor(self,ccbFile,callBacks,options)

	self._gemstone = dialogOptions and dialogOptions.gemStone 
	self:update(self._gemstone)
    self:initExplainTTF()
    q.setButtonEnableShadow(self._ccbOwner.btn_spar_shop)
    self._ccbOwner.recycleText:setVisible(options.type == 1)
    self._ccbOwner.rebornText:setVisible(options.type == 2)   

    self._compensations = {}
    self._tempCompensations = {} 

    self._ccbOwner.buttonName:setString(options.type == 1 and "分 解" or "重 生")
    setShadow5(self._ccbOwner.gemName, UNITY_COLOR.black)
end

--创建底部说明文字
function QUIWidgetGemRecycle:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还养成的资源与材料、魂骨",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "变为1级",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})
    if self:getOptions().type == 1 then
        richText = QRichText.new({
            {oType = "font", content = "70%~83%",size = 20,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "返还",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "魂骨币",size = 20,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "，魂骨的",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "品质越高",size = 20,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "返还比例",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "越高，100%",size = 20,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "返还养成的资源与材料",size = 20,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        },790,{autoCenter = true})
    end

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetGemRecycle:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogGemRecycleSelection.GEM_CLICK, self.onGemSelected, self)
end

function QUIWidgetGemRecycle:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogGemRecycleSelection.GEM_CLICK, self.onGemSelected, self)
end

function QUIWidgetGemRecycle:update(gemstone)
    self._ccbOwner.selectedNode:removeAllChildren()
	if gemstone then
        self._stone = QUIWidgetGemstonesBox.new()
        self._stone:setGemstoneInfo(gemstone)
        self._ccbOwner.selectedNode:addChild(self._stone)
        self._stone:setPositionY(-50)

        -- Show title 
        local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 
        local gemName = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId).name
        if level > 0 then
            gemName = gemName .. "＋".. level
        end
        self._ccbOwner.gemName:setString(gemName)
        self._ccbOwner.gemName:setColor(UNITY_COLOR_LIGHT[color])

        -- Show animation of stone
        local arr = CCArray:create()
        arr:addObject(CCMoveTo:create(1, CCPoint(self._stone:getPositionX(), self._stone:getPositionY() - 5)))
        arr:addObject(CCMoveTo:create(1, CCPoint(self._stone:getPositionX(), self._stone:getPositionY() + 5)))
        self._stoneAction = self._stone:runAction(CCRepeatForever:create(CCSequence:create(arr)))
    else
        if self:getOptions().type == 1 then
            self._ccbOwner.token:setVisible(false)
        else
            self._ccbOwner.token:setVisible(true)
        end
	end

    self._ccbOwner.heroUnselected_foreground:setVisible(not gemstone)
    self._ccbOwner.heroSelected_foreground:setVisible(not (not gemstone))
    
    self._token = db:getConfiguration()["HERO_RECYCLE"].value or 0
    self._ccbOwner.tf_token:setString(self._token)
    self._ccbOwner.node_month_card:setVisible(false)
    if self:getOptions().type == 2 and remote.activity:checkMonthCardActive(1) then
        self._ccbOwner.node_month_card:setVisible(true)
        self._token = 0
    end
end

function QUIWidgetGemRecycle:onGemSelected(event)
    self._gemstone = event.gemstone
    self:update(event.gemstone)

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetGemRecycle.GEM_SELECTED, gemstone = self._gemstone})
end

function QUIWidgetGemRecycle:compensations(gemstone)
    if self:getOptions().type == 1 then
        self:recycleGem(gemstone)
    else
        self:rebornGem(gemstone)
    end
end

-- 回收，返还重生的和碎片
function QUIWidgetGemRecycle:recycleGem(gemstone)
    self:rebornGem(gemstone)

    local config = db:getItemCraftByItemId(gemstone.itemId)
    local count = db:getItemByID(gemstone.itemId).gemstone_recycle
    local item_recycle = db:getItemByID(gemstone.itemId).item_recycle
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

    if gemstone.godLevel and gemstone.godLevel > 0 then
        local advancedConfig = db:getGemstoneEvolutionAllPropBygodLevel(gemstone.itemId,gemstone.godLevel)
        if advancedConfig then
            for _,v in pairs(advancedConfig) do
                if v.evolution_consume_type_1 then
                    local id = v.evolution_consume_type_1
                    self._tempCompensations[id] = (self._tempCompensations[id] or 0) + (v.evolution_consume_1 or 0)
                end
                if v.evolution_consume_type_2 then
                    local id = v.evolution_consume_type_2
                    self._tempCompensations[id] = (self._tempCompensations[id] or 0) + (v.evolution_consume_2 or 0)
                end
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

-- 重生，返还突破，强化和进阶的
function QUIWidgetGemRecycle:rebornGem(gemstone)
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
                end
                if v.evolution_consume_type_2 then
                    local id = v.evolution_consume_type_2
                    self._tempCompensations[id] = (self._tempCompensations[id] or 0) + (v.evolution_consume_2 or 0)
                end                
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

    if gemstone.refine_level and gemstone.refine_level > 0 then
        local refineHistory = remote.gemstone:getRefineHistoryItems(gemstone.sid)
        local refineConfig = db:getStaticByName("gemstone_refine")
        local itemConfig = refineConfig[tostring(gemstone.itemId)]
        if itemConfig then
            for key,value in ipairs(itemConfig) do
                if tonumber(value.level) <= (gemstone.refine_level or 0) then
                    self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + (value.cost_money or 0)
                else
                    break
                end
            end
            for _,item in ipairs(refineHistory) do
                self._tempCompensations[item.id] = (self._tempCompensations[item.id] or 0) + (item.count or 0)
            end
        end
    end
end

function QUIWidgetGemRecycle:sortCompensations(compensations)
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

-- Callbacks
function QUIWidgetGemRecycle:onTriggerSelect()
	if self._playing then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemRecycleSelection", options = {type = self:getOptions().type}}, {isPopCurrentDialog = false})
end

function QUIWidgetGemRecycle:onTriggerRecycle(event)
	if self._playing then return end
    
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

	if not self._gemstone then
		app.tip:floatTip(QUIWidgetGemRecycle.GEM_NA, tipOffsetX) 
		return
	end

    if self._gemstone.actorId then
        if self:getOptions().type == 1 then
            app.tip:floatTip(QUIWidgetGemRecycle.GEM_RECYCLE_EQUIPPED, tipOffsetX)
        else
            app.tip:floatTip(QUIWidgetGemRecycle.GEM_REBORN_EQUIPPED, tipOffsetX)
        end 
        return
    end

    self._compensations = {}
    self._tempCompensations = {} 
    self:compensations(self._gemstone)	

    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        if self:getOptions().type == 1 then
            remote.gemstone:gemRecycle(self._gemstone.sid, function()
                    remote.gemstone:removeGemstones(self._gemstone.sid)
                    self:onTriggerRecycleFinished()
                end)
        else
            remote.gemstone:gemReborn(self._gemstone.sid, function()
                self:onTriggerRecycleFinished()
                end)
        end
    end

    self:sortCompensations(self._tempCompensations)
    
    if next(self._compensations) == nil then
        app.tip:floatTip(QUIWidgetGemRecycle.REBORN_NA, tipOffsetX)
        return 
    end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
		options = {heroId = self._heroId, compensations = self._compensations, 
                    callFunc = callRecycleAPI, title = self:getTitle()}})
end

function QUIWidgetGemRecycle:getTitle()
    local title = QUIWidgetGemRecycle.RECYCLE_TITLE
    if self:getOptions().type == 2 then
        title = QUIWidgetGemRecycle.REBORN_TITLE
    end

    return title
end

function QUIWidgetGemRecycle:onTriggerRecycleFinished()
	self._playing = true
    local gemstone = self._gemstone
    self._gemstone = nil
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetGemRecycle.GEM_SELECTED, gemstone = nil})

	local effect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.effect:addChild(effect)
    local animation = self:getOptions().type == 1 and "effects/HeroRecoverEffect_up2.ccbi" or "effects/HeroRecoverEffect_up.ccbi"
	effect:playAnimation(animation, function(ccbOwner)
            self._ccbOwner.selectedNode:setVisible(false)
            self._stone:stopAction(self._stoneAction)
            local pos = self._stone:convertToWorldSpaceAR(ccp(0,0))
            pos = ccbOwner.node_avatar:convertToNodeSpaceAR(pos)
            self._stone:setPosition(pos)
            self._stone:retain()
            self._stone:removeFromParent()
            ccbOwner.node_avatar:addChild(self._stone)
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
            self._ccbOwner.selectedNode:setVisible(true)
		    self:update(self._gemstone)
		    self._playing = false
	    end)
end

function QUIWidgetGemRecycle:onTriggerClose()
    if self._playing then return end
 
    self._gemstone = nil 
    self:update(self._gemstone)
end

function QUIWidgetGemRecycle:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    local type = 7
    if self:getOptions().type == 2 then
        type = 8
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = type}}, {isPopCurrentDialog = false})
end

function QUIWidgetGemRecycle:onTriggerExchange()
    if self._playing then return end

    app.sound:playSound("common_small")
    if app.unlock:checkLock("UNLOCK_SOUL_SHOP", true) then
        remote.stores:openShopDialog(SHOP_ID.soulShop)
    end
end

function QUIWidgetGemRecycle:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIWidgetGemRecycle:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

return QUIWidgetGemRecycle
