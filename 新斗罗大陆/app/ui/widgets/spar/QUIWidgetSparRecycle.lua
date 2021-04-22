-- @Author: xurui
-- @Date:   2017-04-10 17:50:24
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-13 10:58:23
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparRecycle = class("QUIWidgetSparRecycle", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QRichText = import("....utils.QRichText")
local QUIWidgetSparBox = import("...widgets.spar.QUIWidgetSparBox")
local QUIDialogSparRecycleSelection = import("...dialogs.QUIDialogSparRecycleSelection")
local QNotificationCenter = import("....controllers.QNotificationCenter")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")

QUIWidgetSparRecycle.REBORN_NA = "魂师大人，这颗外附魂骨已经是初始状态，不需要重生了～"
QUIWidgetSparRecycle.GEM_NA = "魂师大人，请先选择一个外附魂骨"
QUIWidgetSparRecycle.REBORN_TITLE = "外附魂骨重生后将返还以下资源，是否确认重生该外附魂骨"
QUIWidgetSparRecycle.RECYCLE_TITLE = "外附魂骨分解后将返还以下资源，是否确认分解该外附魂骨"
QUIWidgetSparRecycle.GEM_RECYCLE_EQUIPPED = "魂师大人，无法分解已装备的外附魂骨，请将外附魂骨卸下后分解～"
QUIWidgetSparRecycle.GEM_REBORN_EQUIPPED = "魂师大人，无法重生已装备的外附魂骨，请将外附魂骨卸下后重生～"

QUIWidgetSparRecycle.SPAR_SELECTED = "SPAR_SELECTED"

local tipOffsetX = 135

function QUIWidgetSparRecycle:ctor(options, dialogOptions)
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

	QUIWidgetSparRecycle.super.ctor(self,ccbFile,callBacks,options)

	self._sparInfo = dialogOptions and dialogOptions.sparInfo 
	self:update(self._sparInfo)
    self:initExplainTTF()
    q.setButtonEnableShadow(self._ccbOwner.btn_spar_shop)

    -- self._ccbOwner.recycleText:setVisible(options.type == 1)
    -- self._ccbOwner.rebornText:setVisible(options.type == 2)   

    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0

    self._ccbOwner.buttonName:setString(options.type == 1 and "分 解" or "重 生")
    setShadow5(self._ccbOwner.gemName, UNITY_COLOR.black)

    if options.type == 1 then
    	self._ccbOwner.tf_choose_content:setString("选择需要分解的外附魂骨")
	elseif options.type == 2 then 
    	self._ccbOwner.tf_choose_content:setString("选择需要重生的外附魂骨")
	end
    self._ccbOwner.tf_choose_content:setVisible(true)
    self._ccbOwner.rebornText:setVisible(false)
    self._ccbOwner.recycleText:setVisible(false)
    
    self._ccbOwner.node_spar_shop:setVisible(true)
    self._ccbOwner.store:setVisible(false)

    self._ccbOwner.sp_item_shadow:setDisplayFrame(QSpriteFrameByPath(QResPath("spar_item_shadow")))
    self._ccbOwner.sp_item_shadow:setPositionY(11)
    self._ccbOwner.sp_item_shadow:setPositionX(-12)
end

--创建底部说明文字
function QUIWidgetSparRecycle:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还养成的资源与材料、外附魂骨",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "变为最低星",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})
    if self:getOptions().type == 1 then
        richText = QRichText.new({
            {oType = "font", content = "S外骨50%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "返还",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "地狱币，100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
            {oType = "font", content = "返还养成的资源与材料",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        },790,{autoCenter = true})
    end

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetSparRecycle:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogSparRecycleSelection.SPAR_CLICK, self.onSparSelect, self)
end

function QUIWidgetSparRecycle:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogSparRecycleSelection.SPAR_CLICK, self.onSparSelect, self)
end

function QUIWidgetSparRecycle:update(sparInfo)
    self._ccbOwner.selectedNode:removeAllChildren()
	if sparInfo then
        local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(sparInfo.itemId)
        self._stone = QUIWidgetSparBox.new()
        self._stone:setGemstoneInfo(sparInfo)
        self._stone:setNameVisible(false)
        self._ccbOwner.selectedNode:addChild(self._stone)
        self._stone:setPositionY(-50)

        -- Show title 
        self._ccbOwner.gemName:setString(itemConfig.name)
        self._ccbOwner.gemName:setColor(UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]])

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

    self._ccbOwner.heroUnselected_foreground:setVisible(not sparInfo)
    self._ccbOwner.heroSelected_foreground:setVisible(not (not sparInfo))

    self._token = db:getConfiguration()["HERO_RECYCLE"].value or 0
    self._ccbOwner.tf_token:setString(self._token)
    self._ccbOwner.node_month_card:setVisible(false)
    if self:getOptions().type == 2 and remote.activity:checkMonthCardActive(1) then
        self._ccbOwner.node_month_card:setVisible(true)
        self._token = 0
    end
end

function QUIWidgetSparRecycle:onSparSelect(event)
    self._sparInfo = event.sparInfo
    self:update(event.sparInfo)

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetSparRecycle.SPAR_SELECTED, sparInfo = self._sparInfo})
end

function QUIWidgetSparRecycle:compensations(sparInfo)
    if self:getOptions().type == 1 then
        self:recycleGem(sparInfo)
    else
        self:rebornGem(sparInfo)
    end
end

-- 分解，返还重生的和合成碎片
function QUIWidgetSparRecycle:recycleGem(sparInfo)
    self:rebornGem(sparInfo, true)

    --合成碎片
    local config = QStaticDatabase:sharedDatabase():getItemCraftByItemId(sparInfo.itemId)

    local need = config.component_num_1
    local itemId = config.component_id_1

    self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + config.price

    if self._tempCompensations["fragment"] then
        self._tempCompensations["fragment"].count = self._tempCompensations["fragment"].count + need
    elseif need > 0 then
        self._tempCompensations["fragment"] = {id = itemId, count = need}
    end

    local fragments = self._tempCompensations["fragment"]
    local itemNum = QStaticDatabase:sharedDatabase():getItemByID(fragments.id).item_recycle
    itemNum = string.split(itemNum, "^")
    if #itemNum >=2 then --如果配置item_recycle 说明可以分解碎片 否则直接返回分解碎片后的货币
        self._tempCompensations["jewelryMoney"] = fragments.count * tonumber(itemNum[2] or 0)
        self._tempCompensations["fragment"] = nil
    end
end

-- 重生，返还升星碎片和强化的材料
function QUIWidgetSparRecycle:rebornGem(sparInfo, isRecycle)
	--升星碎片
    self:compensationForHero(sparInfo.itemId, sparInfo.grade, isRecycle)
    --吸收的s外骨
    self:compensationForInherit(sparInfo, isRecycle)
    
    --强化材料
    local sparInfo, index = remote.spar:getSparsIndexBySparId(sparInfo.sparId)
  	local returnMaterial = {10000009, 10000008, 10000007} -- It is hardcoded to return material
    if sparInfo.level > 1 or sparInfo.exp > 0 then
        local exp = (sparInfo.exp or 0) + QStaticDatabase:sharedDatabase():getJewelryStrengthenTotalExpByLevel(sparInfo.level, index, "jewelry_exp")

        local heightMaterialExp = QStaticDatabase:sharedDatabase():getItemByID(returnMaterial[1])
        local advancedMaterialExp = QStaticDatabase:sharedDatabase():getItemByID(returnMaterial[2])
        local cheapMaterialExp = QStaticDatabase:sharedDatabase():getItemByID(returnMaterial[3])
        heightMaterialExp = string.split(heightMaterialExp.exp_num, "^")
        advancedMaterialExp = string.split(advancedMaterialExp.exp_num, "^")
        cheapMaterialExp = string.split(cheapMaterialExp.exp_num, "^")
        heightMaterialExp = tonumber(heightMaterialExp[2]) or 0
        advancedMaterialExp = tonumber(advancedMaterialExp[2]) or 0
        cheapMaterialExp = tonumber(cheapMaterialExp[2]) or 0

        local heightMaterial = math.floor(exp/heightMaterialExp)
        local advancedMaterial = math.floor(exp%heightMaterialExp/advancedMaterialExp)
        local cheapMaterial = math.floor(exp%heightMaterialExp%advancedMaterialExp/cheapMaterialExp)

        if heightMaterial > 0 then
            self._tempCompensations[returnMaterial[1]] = (self._tempCompensations[returnMaterial[1]] or 0) + heightMaterial
        end
        if advancedMaterial > 0 then
            self._tempCompensations[returnMaterial[2]] = (self._tempCompensations[returnMaterial[2]] or 0) + advancedMaterial
        end
        if cheapMaterial > 0 then
            self._tempCompensations[returnMaterial[3]] = (self._tempCompensations[returnMaterial[3]] or 0) + cheapMaterial
        end
    end
end

function QUIWidgetSparRecycle:compensationForHero(sparId, grade, isRecycle)
    local need = 0
    local itemId = nil

    for i = 1, grade, 1 do
        local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(sparId, i)
        local money = gradeConfig.money or 0
        if isRecycle then
            local config = QStaticDatabase:sharedDatabase():getItemCraftByItemId(gradeConfig.soul_gem)
            if config then
                need = need + config.component_num_1 * gradeConfig.soul_gem_count
                itemId = config.component_id_1
                self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + money + (config.price*gradeConfig.soul_gem_count)
            else
                need = need + gradeConfig.soul_gem_count
                itemId = gradeConfig.soul_gem
                self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + money
            end

        else
            need = need + gradeConfig.soul_gem_count
            itemId = gradeConfig.soul_gem
            self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + money
        end
    end  

    if self._tempCompensations["fragment"] then
        self._tempCompensations["fragment"].count = self._tempCompensations["fragment"].count + need
    elseif need > 0 then
        self._tempCompensations["fragment"] = {id = itemId, count = need}
    end

    if not isRecycle then
        if self._tempCompensations["fragment"] == nil then
            self._tempCompensations["fragment"] = {id = sparId, count = 1}
        elseif sparId == itemId then
            self._tempCompensations["fragment"].count = self._tempCompensations["fragment"].count + 1
        else
            self._tempCompensations["Spar"] = {id = sparId, count = 1}
        end
    end
end


function QUIWidgetSparRecycle:compensationForInherit(sparInfo, isRecycle)
    if not self._sparInfo.consumeItems or q.isEmpty(self._sparInfo.consumeItems) then  return end

    local inheritSpars = {}
    for k,v in pairs(self._sparInfo.consumeItems or {}) do
       table.insert(inheritSpars, {id = v.type, value = v.count})
    end

    if isRecycle then
        for i,v in ipairs(inheritSpars or {}) do
            local  sparItemId = v.id
            local  sparItemNum = v.value
            local config = QStaticDatabase:sharedDatabase():getItemCraftByItemId(sparItemId)
            if config then
                self._tempCompensations["money"] = (self._tempCompensations["money"] or 0) + config.price * sparItemNum
                local need = config.component_num_1
                local itemId = config.component_id_1
                local itemNum = db:getItemByID(itemId).item_recycle
                itemNum = string.split(itemNum, "^")
                if #itemNum >=2 then --如果配置item_recycle 说明可以分解碎片 否则直接返回分解碎片后的货币
                    self._tempCompensations["jewelryMoney"] =(self._tempCompensations["jewelryMoney"] or 0) + need * tonumber(itemNum[2] or 0) * sparItemNum
                else
                    self._tempCompensations[itemId] = (self._tempCompensations[itemId] or 0) + need  * sparItemNum
                end
            end
        end
    else
        for i,v in ipairs(inheritSpars or {}) do
            self._tempCompensations[v.id] = v.value
        end
    end



end

function QUIWidgetSparRecycle:sortCompensations(compensations)
    if compensations["money"] then
        if compensations["money"] > 0 then
            table.insert(self._compensations, {id = "money", value = compensations["money"]})
        end
        compensations["money"] = nil
    end
    if compensations["jewelryMoney"]  then
        table.insert(self._compensations, {id = "jewelryMoney", value = compensations["jewelryMoney"]})
        compensations["jewelryMoney"] = nil
    end
    if compensations["fragment"] then
        table.insert(self._compensations, {id = compensations["fragment"].id, value = compensations["fragment"].count})
        compensations["fragment"] = nil
    end
    if compensations["Spar"] then
        table.insert(self._compensations, {id = compensations["Spar"].id, value = compensations["Spar"].count})
        compensations["Spar"] = nil
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
function QUIWidgetSparRecycle:onTriggerSelect()
	if self._playing then return end
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparRecycleSelection", options = {type = self:getOptions().type}}, {isPopCurrentDialog = false})
end

function QUIWidgetSparRecycle:onTriggerRecycle(event)
	if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

	if not self._sparInfo then
		app.tip:floatTip(QUIWidgetSparRecycle.GEM_NA, tipOffsetX) 
		return
	end

    if self._sparInfo.actorId ~= nil and self._sparInfo.actorId > 0 then
        if self:getOptions().type == 1 then
            app.tip:floatTip(QUIWidgetSparRecycle.GEM_RECYCLE_EQUIPPED, tipOffsetX)
        else
            app.tip:floatTip(QUIWidgetSparRecycle.GEM_REBORN_EQUIPPED, tipOffsetX)
        end 
        return
    end

    self._compensations = {}
    self._tempCompensations = {} 
    self:compensations(self._sparInfo)	

    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        if self:getOptions().type == 1 then
            remote.spar:requestSparReturn({ {returnSparInfo = {sparId = self._sparInfo.sparId, count = self._sparInfo.count}, count = 1} }, {}, function()
                	self:onTriggerRecycleFinished()
                end)
        else
           	remote.spar:requestSparReCover({ {returnSparInfo = {sparId = self._sparInfo.sparId, count = self._sparInfo.count}, count = 1} }, function()
                    self:onTriggerRecycleFinished()
                end)
        end
    end

    self:sortCompensations(self._tempCompensations)
    
    if next(self._compensations) == nil then
        app.tip:floatTip(QUIWidgetSparRecycle.REBORN_NA, tipOffsetX)
        return 
    end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
		options = {heroId = self._heroId, compensations = self._compensations, callFunc = callRecycleAPI, title = self:getTitle(), tips = self:getTips()}})
end

function QUIWidgetSparRecycle:getTitle()
    local title = QUIWidgetSparRecycle.RECYCLE_TITLE
    if self:getOptions().type == 2 then
        title = QUIWidgetSparRecycle.REBORN_TITLE
    end

    return title
end


function QUIWidgetSparRecycle:getTips()
    local tips = "提示：分解后，该外附魂骨将彻底消失"
    if self:getOptions().type == 2 then
        tips = ""
    end
    return tips
end



function QUIWidgetSparRecycle:onTriggerRecycleFinished()
	self._playing = true
    local sparInfo = self._sparInfo
    self._sparInfo = nil
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetSparRecycle.SPAR_SELECTED, sparInfo = nil})

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
    		        options = {compensations = self._compensations, type = 7, subtitle = "外附魂骨分解返还以下资源"}}, {isPopCurrentDialog = false})
            else
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                    options = {compensations = self._compensations, type = 8, subtitle = "外附魂骨重生返还以下资源"}}, {isPopCurrentDialog = false})
            end
            self._ccbOwner.selectedNode:setVisible(true)
		    self:update(self._sparInfo)
		    self._playing = false
	    end)
end

function QUIWidgetSparRecycle:onTriggerClose()
    if self._playing then return end
 
    self._sparInfo = nil 
    self:update(self._sparInfo)
end

function QUIWidgetSparRecycle:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    local type = 15
    if self:getOptions().type == 2 then
        type = 16
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = type}}, {isPopCurrentDialog = false})
end

function QUIWidgetSparRecycle:onTriggerExchange()
    if self._playing then return end

    app.sound:playSound("common_small")
    if app.unlock:checkLock("UNLOCK_SOUL_SHOP", true) then
        remote.stores:openShopDialog(SHOP_ID.soulShop)
    end
end

function QUIWidgetSparRecycle:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    
    remote.stores:openShopDialog(SHOP_ID.sparShop)
end

function QUIWidgetSparRecycle:_onTriggerMonthCard()
    if self._playing then return end
    
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

return QUIWidgetSparRecycle