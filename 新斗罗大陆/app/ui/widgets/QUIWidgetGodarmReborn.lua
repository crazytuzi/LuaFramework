-- @Author: liaoxianbo
-- @Date:   2020-01-03 16:58:28
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-10 18:15:53
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmReborn = class("QUIWidgetGodarmReborn", QUIWidget)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroRebornCompensation = import("..dialogs.QUIDialogHeroRebornCompensation")
local QUIWidgetShopTap = import("..widgets.QUIWidgetShopTap")
local QRichText = import("...utils.QRichText")
local QUIDialogGodarmOverView = import("..dialogs.QUIDialogGodarmOverView")

QUIWidgetGodarmReborn.REBORN_NA = "魂师大人，此神器已经是初始状态，不需要重生了～"
QUIWidgetGodarmReborn.MOUNT_NA = "魂师大人，请先选择神器"
QUIWidgetGodarmReborn.REBORN_TITLE = "神器重生后将返还以下资源，是否确认重生该神器"
QUIWidgetGodarmReborn.MOUNT_REBORN_EQUIPPED = "魂师大人，无法重生已装备的神器，请将神器卸下后重生～"

QUIWidgetGodarmReborn.GODARM_SELECTED = "QUIWidgetGodarmReborn_GODARM_SELECTED"

local tipOffsetX = 135

function QUIWidgetGodarmReborn:ctor(options, dialogOptions)
    local ccbFile = "ccb/Widget_herorecover_godarm.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self.onTriggerSelect)},
        {ccbCallbackName = "onTriggerRecycle", callback = handler(self, self.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self.onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self.onTriggerRule)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, self.onTriggerExchange)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self.onTriggerShop)},
        {ccbCallbackName = "onTriggerMonthCard", callback = handler(self, self._onTriggerMonthCard)},
    }

    QUIWidgetGodarmReborn.super.ctor(self,ccbFile,callBacks,options)

    self._godarmId = dialogOptions and dialogOptions.godarmId 
    self:initExplainTTF()

    q.setButtonEnableShadow(self._ccbOwner.btn_store)
    
    -- self._ccbOwner.recycleText:setVisible(options.type == 1)
    -- self._ccbOwner.rebornText:setVisible(options.type == 2)   
    self._ccbOwner.rebornText:setVisible(true)
    self._ccbOwner.recycleText:setVisible(false)
    self._ccbOwner.node_month_card:setVisible(false)

    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0

    self._ccbOwner.buttonName:setString(options.type == 1 and "分 解" or "重 生")
    setShadow5(self._ccbOwner.mountName, UNITY_COLOR.black)
    self._ccbOwner.rebornText:setString("选择需要重生的神器")
    self._ccbOwner.recycleText:setString("选择需要分解的神器")
    self:update(self._godarmId)
end

--创建底部说明文字
function QUIWidgetGodarmReborn:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还养成的资源与材料、神器",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "变为碎片",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetGodarmReborn:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogGodarmOverView.GODARM_CLICK, self.onMountSelected, self)
end

function QUIWidgetGodarmReborn:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogGodarmOverView.GODARM_CLICK, self.onMountSelected, self)
end

function QUIWidgetGodarmReborn:update(godarmId)
    self._ccbOwner.selectedNode:removeAllChildren()
    self._godarmId = godarmId
    local showForce = false
    if godarmId then
    	showForce = true
	    local character = QStaticDatabase:sharedDatabase():getCharacterByID(godarmId)
	    self._ccbOwner.mountName:setString(character.name)

	    local avatar = QUIWidgetActorDisplay.new(godarmId)
	    self._ccbOwner.selectedNode:addChild(avatar)
        -- avatar:setScaleX(-1)
        self._ccbOwner.selectedNode:setScaleX(-0.8)
        self._ccbOwner.selectedNode:setScaleY(0.8)
    else
        if self:getOptions().type == 1 then
            self._ccbOwner.token:setVisible(false)
        else
            self._ccbOwner.token:setVisible(true)
        end
    end

    self._ccbOwner.heroUnselected_foreground:setVisible(not showForce)
    self._ccbOwner.heroSelected_foreground:setVisible(not (not showForce))

    self._token = db:getConfiguration()["HERO_RECYCLE"].value or 0
    self._ccbOwner.tf_token:setString(self._token)
    self._ccbOwner.node_month_card:setVisible(false)
    if remote.activity:checkMonthCardActive(1) then
        self._ccbOwner.node_month_card:setVisible(true)
        self._token = 0
    end
end

function QUIWidgetGodarmReborn:onMountSelected(event)
    self._godarm = event.godarmId
    self:update(event.godarmId)

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetGodarmReborn.GODARM_SELECTED, godarmId = self._godarm})
end

function QUIWidgetGodarmReborn:compensations(godarmInfo)
    if next(godarmInfo) == nil then
        return
    end
    self:rebornMount(godarmInfo)
end

-- 重生，返还突破和强化的
function QUIWidgetGodarmReborn:rebornMount(godarmInfo)
    QPrintTable(godarmInfo)
    local enhanceExp = db:getGodarmEnhanceTotalExpByLevel(godarmInfo.aptitude, godarmInfo.level) + (godarmInfo.exp or 0)
    print("enhanceExp=",enhanceExp)
    local expItems = remote.godarm.EXP_ITEMS

    local returnMaterial = {tonumber(expItems[3]), tonumber(expItems[2]), tonumber(expItems[1])}
    local heightMaterialExp = db:getItemByID(returnMaterial[1]).exp
    local advancedMaterialExp = db:getItemByID(returnMaterial[2]).exp
    local cheapMaterialExp = db:getItemByID(returnMaterial[3]).exp
    print("heightMaterialExp,advancedMaterialExp,cheapMaterialExp",heightMaterialExp,advancedMaterialExp,cheapMaterialExp)

    local heightMaterial = math.floor(enhanceExp/heightMaterialExp)
    local advancedMaterial = math.floor((enhanceExp%heightMaterialExp)/advancedMaterialExp)
    local cheapMaterial = math.floor(((enhanceExp%heightMaterialExp)%advancedMaterialExp)/cheapMaterialExp)

    print("heightMaterial,advancedMaterial,cheapMaterial",heightMaterial,advancedMaterial,cheapMaterial)

    if heightMaterial > 0 then
        self._tempCompensations[returnMaterial[1]] = (self._tempCompensations[returnMaterial[1]] or 0) + heightMaterial
    end
    if advancedMaterial > 0 then
        self._tempCompensations[returnMaterial[2]] = (self._tempCompensations[returnMaterial[2]] or 0) + advancedMaterial
    end
    if cheapMaterial > 0 then
        self._tempCompensations[returnMaterial[3]] = (self._tempCompensations[returnMaterial[3]] or 0) + cheapMaterial
    end

    self:compensationForHero(godarmInfo.id, godarmInfo.grade)
    self:compensationForHeroGrade(godarmInfo.id, godarmInfo.grade)

    self._tempCompensations["money"] = self._totalMoney
end

function QUIWidgetGodarmReborn:compensationForHero(actorId, grade)
    local need = 0
    local itemId = nil
    for i = 0, grade, 1 do
        local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(actorId, i)
        need = need + config.soul_gem_count
        itemId = config.soul_gem
    end  

    if self._tempCompensations["fragment"] then
        self._tempCompensations["fragment"].count = self._tempCompensations["fragment"].count + need
    elseif need > 0 then
        self._tempCompensations["fragment"] = {id = itemId, count = need}
    end
end

function QUIWidgetGodarmReborn:compensationForHeroGrade(actorId, gradeLevel)
    local grade = QStaticDatabase:sharedDatabase():getGradeByHeroId(actorId)
    local minGrade = QStaticDatabase:sharedDatabase():getCharacterByID(actorId).grade

    for k, v in pairs(grade) do
        if v.grade_level <= gradeLevel then
            if v.grade_level > minGrade then
                self._totalMoney = self._totalMoney + (v.money or 0)
            end
        end
    end
end

function QUIWidgetGodarmReborn:sortCompensations(compensations)
    if compensations["fragment"] then
        table.insert(self._compensations, {id = compensations["fragment"].id, value = compensations["fragment"].count})
        compensations["fragment"] = nil
    end
    if compensations["money"] and compensations["money"] > 0 then
        table.insert(self._compensations, {id = "money", value = compensations["money"]})
        compensations["money"] = nil
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
function QUIWidgetGodarmReborn:onTriggerSelect()
    if self._playing then return end
    app.sound:playSound("common_small")
    local haveGodarms = remote.godarm:getHaveGodarmList()

    if next(haveGodarms) ~= nil then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmOverView", 
            options = {isReborn = true}})
    else
        app.tip:floatTip("没有可以重生的神器~",tipOffsetX)
    end
end

function QUIWidgetGodarmReborn:onTriggerRecycle(event)
    if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

    if not self._godarmId then
        app.tip:floatTip(QUIWidgetGodarmReborn.MOUNT_NA, tipOffsetX) 
        return
    end

    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0

    print("重生分姐--self._godarmId=",self._godarmId)
    local godarmInfo = remote.godarm:getGodarmById(self._godarmId)

    self:compensations(godarmInfo)  

    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

        remote.godarm:godarmRebornRequest(self._godarmId, function()
                self:onTriggerRecycleFinished()
            end)
    end

    self:sortCompensations(self._tempCompensations)
    
    if next(self._compensations) == nil then
        app.tip:floatTip(QUIWidgetGodarmReborn.REBORN_NA, tipOffsetX)
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {heroId = self._heroId, compensations = self._compensations, 
                    callFunc = callRecycleAPI, title = self:getTitle()}})
end

function QUIWidgetGodarmReborn:getTitle()
    local title = QUIWidgetGodarmReborn.REBORN_TITLE

    return title
end

function QUIWidgetGodarmReborn:onTriggerRecycleFinished()
    self._playing = true
    local godarmId = self._godarmId
    self._godarmId = nil
    self._totalMoney = 0
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetGodarmReborn.GODARM_SELECTED, mount = nil})

    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.effect:addChild(effect)

    local animation = self:getOptions().type == 1 and "effects/HeroRecoverEffect_up2.ccbi" or "effects/HeroRecoverEffect_up.ccbi"
    effect:playAnimation(animation, function()
            self._ccbOwner.mountName:setString("")
            self._ccbOwner.selectedNode:setVisible(false)

            -- local character = db:getCharacterByID(godarmId)
            -- local sprite = CCSprite:create(character.visitingCard)
            -- sprite:setPositionY(-60)
            -- effect._ccbOwner.node_avatar:addChild(sprite)
            effect._ccbOwner.node_avatar:setVisible(false)

        end, 
        function()
            effect:removeFromParentAndCleanup(true)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                options = {compensations = self._compensations, type = 14, subtitle = "神器重生返还以下资源"}}, {isPopCurrentDialog = false})
            self._ccbOwner.selectedNode:setVisible(true)
            self:update(self._mount)
            self._playing = false
        end)
end

function QUIWidgetGodarmReborn:onTriggerClose()
    if self._playing then return end
 
    self._mount = nil 
    self:update(self._mount)
end

function QUIWidgetGodarmReborn:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 22}}, {isPopCurrentDialog = false})
end

function QUIWidgetGodarmReborn:onTriggerExchange()
    if self._playing then return end

    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.godarmShop)
end

function QUIWidgetGodarmReborn:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.godarmShop)
end

function QUIWidgetGodarmReborn:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

return QUIWidgetGodarmReborn
