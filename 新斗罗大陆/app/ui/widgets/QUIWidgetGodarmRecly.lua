-- @Author: liaoxianbo
-- @Date:   2020-01-03 19:25:22
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-10 18:16:21
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmRecly = class("QUIWidgetGodarmRecly", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
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


QUIWidgetGodarmRecly.REBORN_NA = "魂师大人，此神器已经是初始状态，不需要分解了～"
QUIWidgetGodarmRecly.MOUNT_NA = "魂师大人，请先选择神器"
QUIWidgetGodarmRecly.REBORN_TITLE = "神器分解后将返还以下资源，是否确认分解该神器"
QUIWidgetGodarmRecly.MOUNT_REBORN_EQUIPPED = "魂师大人，无法分解已装备的神器，请将神器卸下后分解～"

QUIWidgetGodarmRecly.MOUNT_SELECTED = "QUIWidgetGodarmRecly_MOUNT_SELECTED"

local tipOffsetX = 135

function QUIWidgetGodarmRecly:ctor(options, dialogOptions)
    local ccbFile = "ccb/Widget_herorecover_godarm.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self.onTriggerSelect)},
        {ccbCallbackName = "onTriggerRecycle", callback = handler(self, self.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self.onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self.onTriggerRule)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, self.onTriggerExchange)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self.onTriggerShop)},
    }

    QUIWidgetGodarmRecly.super.ctor(self,ccbFile,callBacks,options)

    self._godarmId = dialogOptions and dialogOptions.godarmId 
    self:update(self._godarmId)
    self:initExplainTTF()

    q.setButtonEnableShadow(self._ccbOwner.btn_store)

    -- self._ccbOwner.recycleText:setVisible(options.type == 1)
    -- self._ccbOwner.rebornText:setVisible(options.type == 2)   
    self._ccbOwner.rebornText:setVisible(false)
    self._ccbOwner.recycleText:setVisible(true)
    self._ccbOwner.node_month_card:setVisible(false)

    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0

    self._ccbOwner.buttonName:setString("分 解")
    setShadow5(self._ccbOwner.mountName, UNITY_COLOR.black)

    self._ccbOwner.rebornText:setString("选择需要重生的神器")
    self._ccbOwner.recycleText:setString("选择需要分解的神器")

end

--创建底部说明文字
function QUIWidgetGodarmRecly:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "75%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "圣柱币，100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还养成的资源与材料",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetGodarmRecly:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogGodarmOverView.GODARM_CLICK, self.onMountSelected, self)
end

function QUIWidgetGodarmRecly:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogGodarmOverView.GODARM_CLICK, self.onMountSelected, self)
end

function QUIWidgetGodarmRecly:update(godarmId)
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
end

function QUIWidgetGodarmRecly:onMountSelected(event)
    self._godarm = event.godarmId
    self:update(event.godarmId)

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetGodarmRecly.MOUNT_SELECTED, godarmId = self._godarm})
end

function QUIWidgetGodarmRecly:compensations(mount)
    if next(mount) == nil then
        return
    end
    self:rebornMount(mount)
end

-- 重生，返还突破和强化的
function QUIWidgetGodarmRecly:rebornMount(godarmInfo)
    local enhanceExp = db:getGodarmEnhanceTotalExpByLevel(godarmInfo.aptitude, godarmInfo.level) + (godarmInfo.exp or 0)
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
    QPrintTable( self._tempCompensations)
    self:compensationForHeroGrade(godarmInfo.id, godarmInfo.grade)

    self._tempCompensations["money"] = self._totalMoney
end

function QUIWidgetGodarmRecly:compensationForHeroGrade(actorId, gradeLevel)
    local grade = QStaticDatabase:sharedDatabase():getGradeByHeroId(actorId)
    local minGrade = QStaticDatabase:sharedDatabase():getCharacterByID(actorId).grade

    local fragment = 0
    local fragmentId = 0
    for k, v in pairs(grade) do
        if v.grade_level <= gradeLevel then
            if v.grade_level >= minGrade then
                self._totalMoney = self._totalMoney + (v.money or 0)
            end
            fragment = fragment + v.soul_gem_count
            fragmentId = v.soul_gem
        end
    end

    if fragment > 0 then
        local stormMoney = fragment * QStaticDatabase:sharedDatabase():getItemByID(fragmentId).soul_recycle
        self._tempCompensations["godArmMoney"] = stormMoney

        local itemRecycle = QStaticDatabase:sharedDatabase():getItemByID(fragmentId).item_recycle
        if itemRecycle then
            local items = string.split(itemRecycle, ";")
            for k, v in ipairs(items) do
                local item = string.split(v, "^")
                local id = tonumber(item[1])
                local count = item[2]
                self._tempCompensations[id] = (self._tempCompensations[id] or 0) + (count or 0)*fragment
            end
        end
    end
end

function QUIWidgetGodarmRecly:sortCompensations(compensations)
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
            if type(x.id) ~= type(y.id) then
                return type(x.id) == "string"
            elseif type(x.id) == "string" then
                return x.value > y.value
            end
            return x.id < y.id
        end)
    for _, v in ipairs(tempCompensations) do
        table.insert(self._compensations, v)
    end
end

-- Callbacks
function QUIWidgetGodarmRecly:onTriggerSelect()
    if self._playing then return end
    app.sound:playSound("common_small")
    -- local hasMount = false
    -- local haveGodarms = remote.godarm:getHaveGodarmList() or {}
    -- if next(haveGodarms) ~= nil then
    -- 	hasMount = true
    -- end
    -- if hasMount then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmOverView", 
            options = {isRecly = true}})
    -- else
    --     app.tip:floatTip("没有可以分解的神器~",tipOffsetX)
    -- end
end

function QUIWidgetGodarmRecly:onTriggerRecycle(event)
    if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

    if not self._godarmId then
        app.tip:floatTip(QUIWidgetGodarmRecly.MOUNT_NA, tipOffsetX) 
        return
    end
    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0

    local godarmInfo = remote.godarm:getGodarmById(self._godarmId)

    self:compensations(godarmInfo)  

    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

        remote.godarm:godarmReclyRequest(self._godarmId, function()
                self:onTriggerRecycleFinished()
            end)
    end

    self:sortCompensations(self._tempCompensations)
    
    if next(self._compensations) == nil then
        app.tip:floatTip(QUIWidgetGodarmRecly.REBORN_NA, tipOffsetX)
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {heroId = self._heroId, compensations = self._compensations, 
                    callFunc = callRecycleAPI, title = self:getTitle(), tips = "提示：分解后，该神器将彻底消失"}})
end

function QUIWidgetGodarmRecly:getTitle()
    local title = QUIWidgetGodarmRecly.REBORN_TITLE

    return title
end

function QUIWidgetGodarmRecly:onTriggerRecycleFinished()
    self._playing = true
    local godarmId = self._godarmId
    self._godarmId = nil
    self._totalMoney = 0
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetGodarmRecly.MOUNT_SELECTED, mount = nil})

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
                options = {compensations = self._compensations, type = 15, subtitle = "神器分解返还以下资源"}}, {isPopCurrentDialog = false})
            self._ccbOwner.selectedNode:setVisible(true)
            self:update(self._godarmId)
            self._playing = false
        end)
end

function QUIWidgetGodarmRecly:onTriggerClose()
    if self._playing then return end
 
    self._mount = nil 
    self:update(self._mount)
end

function QUIWidgetGodarmRecly:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 23}}, {isPopCurrentDialog = false})
end

function QUIWidgetGodarmRecly:onTriggerExchange()
    if self._playing then return end

    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.godarmShop)
end

function QUIWidgetGodarmRecly:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.godarmShop)
end
return QUIWidgetGodarmRecly
