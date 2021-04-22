
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountRecycle = class("QUIWidgetMountRecycle", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QNotificationCenter = import("....controllers.QNotificationCenter")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import("..actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroRebornCompensation = import("...dialogs.QUIDialogHeroRebornCompensation")
local QUIWidgetShopTap = import("...widgets.QUIWidgetShopTap")
local QRichText = import("....utils.QRichText")
local QUIDialogMountOverView = import("...dialogs.QUIDialogMountOverView")
local QUIWidgetMountBox = import(".QUIWidgetMountBox")

QUIWidgetMountRecycle.REBORN_NA = "魂师大人，此暗器已经是初始状态，不需要分解了～"
QUIWidgetMountRecycle.MOUNT_NA = "魂师大人，请先选择暗器"
QUIWidgetMountRecycle.REBORN_TITLE = "暗器分解后将返还以下资源，是否确认分解该暗器"
QUIWidgetMountRecycle.MOUNT_REBORN_EQUIPPED = "魂师大人，无法分解已装备的暗器，请将暗器卸下后分解～"

QUIWidgetMountRecycle.MOUNT_SELECTED = "QUIWidgetMountRecycle_MOUNT_SELECTED"

local tipOffsetX = 135

function QUIWidgetMountRecycle:ctor(options, dialogOptions)
    local ccbFile = "ccb/Widget_herorecover_mount.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, QUIWidgetMountRecycle.onTriggerSelect)},
        {ccbCallbackName = "onTriggerRecycle", callback = handler(self, QUIWidgetMountRecycle.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIWidgetMountRecycle.onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetMountRecycle.onTriggerRule)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, QUIWidgetMountRecycle.onTriggerExchange)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, QUIWidgetMountRecycle.onTriggerShop)},
    }

    QUIWidgetMountRecycle.super.ctor(self,ccbFile,callBacks,options)
    q.setButtonEnableShadow(self._ccbOwner.btn_shop)

    self._mount = dialogOptions and dialogOptions.mount 
    self:update(self._mount)
    self:initExplainTTF()

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
end

--创建底部说明文字
function QUIWidgetMountRecycle:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "50%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "暗器币，100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还养成的资源与材料",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetMountRecycle:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogMountOverView.MOUNT_CLICK, self.onMountSelected, self)
end

function QUIWidgetMountRecycle:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogMountOverView.MOUNT_CLICK, self.onMountSelected, self)
end

function QUIWidgetMountRecycle:update(mount)
    self._ccbOwner.selectedNode:removeAllChildren()
    if mount then
        local character = QStaticDatabase:sharedDatabase():getCharacterByID(mount.zuoqiId)
        self._ccbOwner.mountName:setString(character.name)

        local avatar = QUIWidgetActorDisplay.new(mount.zuoqiId)
        self._ccbOwner.selectedNode:addChild(avatar)
    else
        if self:getOptions().type == 1 then
            self._ccbOwner.token:setVisible(false)
        else
            self._ccbOwner.token:setVisible(true)
        end
    end

    self._ccbOwner.heroUnselected_foreground:setVisible(not mount)
    self._ccbOwner.heroSelected_foreground:setVisible(not (not mount))
end

function QUIWidgetMountRecycle:onMountSelected(event)
    self._mount = event.mount
    self:update(event.mount)

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMountRecycle.MOUNT_SELECTED, mount = self._mount})
end

function QUIWidgetMountRecycle:compensations(mount)
    self:rebornMount(mount)
end

-- 分解，返还突破和强化的
function QUIWidgetMountRecycle:rebornMount(mount)
    local enhanceExp = db:getMountEnhanceTotalExpByLevel(mount.aptitude, mount.enhanceLevel) + mount.enhanceExp
    local expItem = db:getMountMaterialById(mount.zuoqiId)
    local expItems = string.split(expItem.shengji_daoju, "^")

    local returnMaterial = {tonumber(expItems[3]), tonumber(expItems[2]), tonumber(expItems[1])}
    local heightMaterialExp = db:getItemByID(returnMaterial[1]).zuoqi_exp
    local advancedMaterialExp = db:getItemByID(returnMaterial[2]).zuoqi_exp
    local cheapMaterialExp = db:getItemByID(returnMaterial[3]).zuoqi_exp
    local heightMaterial = math.floor(enhanceExp/heightMaterialExp)
    local advancedMaterial = math.floor(enhanceExp%heightMaterialExp/advancedMaterialExp)
    local cheapMaterial = math.floor(enhanceExp%heightMaterialExp%advancedMaterialExp/cheapMaterialExp)

    if heightMaterial > 0 then
        self._tempCompensations[returnMaterial[1]] = (self._tempCompensations[returnMaterial[1]] or 0) + heightMaterial
    end
    if advancedMaterial > 0 then
        self._tempCompensations[returnMaterial[2]] = (self._tempCompensations[returnMaterial[2]] or 0) + advancedMaterial
    end
    if cheapMaterial > 0 then
        self._tempCompensations[returnMaterial[3]] = (self._tempCompensations[returnMaterial[3]] or 0) + cheapMaterial
    end

    -- self:compensationForHero(mount.zuoqiId, mount.grade)
    self:compensationForHeroGrade(mount.zuoqiId, mount.grade)

    self._tempCompensations["money"] = self._totalMoney
end

function QUIWidgetMountRecycle:compensationForHeroGrade(actorId, gradeLevel)
    local grade = QStaticDatabase:sharedDatabase():getGradeByHeroId(actorId)
    local minGrade = QStaticDatabase:sharedDatabase():getCharacterByID(actorId).grade

    local fragment = 0
    local fragmentId = 0
    for k, v in pairs(grade) do
        if v.grade_level <= gradeLevel then
            if v.grade_level >= minGrade then
                self._totalMoney = self._totalMoney + (v.money or 0)
            end
            fragment = fragment + v.soul_return_count
            fragmentId = v.soul_gem
        end
    end

    if fragment > 0 then
        local stormMoney = fragment * QStaticDatabase:sharedDatabase():getItemByID(fragmentId).gemstone_recycle
        self._tempCompensations["stormMoney"] = stormMoney

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

function QUIWidgetMountRecycle:sortCompensations(compensations)
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
function QUIWidgetMountRecycle:onTriggerSelect()
    if self._playing then return end
    app.sound:playSound("common_small")
    local hasMount = false
    local haveMounts = remote.mount:getMountMap()
    for _, mount in pairs(haveMounts) do
        if mount.actorId == 0 then
            hasMount = true
            break
        end
    end
    if hasMount then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
            options = {isRecycle = true}})
    else
        app.tip:floatTip("没有可以分解的暗器~")
    end
end

function QUIWidgetMountRecycle:onTriggerRecycle(event)
    if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

    if not self._mount then
        app.tip:floatTip(QUIWidgetMountRecycle.MOUNT_NA, tipOffsetX) 
        return
    end

    if self._mount.actorId and self._mount.actorId ~= 0 then
        app.tip:floatTip(QUIWidgetMountRecycle.MOUNT_REBORN_EQUIPPED, tipOffsetX)
        return
    end

    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0
    self:compensations(self._mount)  

    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

        remote.mount:zuoqiRecoverRequest(self._mount.zuoqiId, function()
                self:onTriggerRecycleFinished()
            end)
    end

    self:sortCompensations(self._tempCompensations)
    QPrintTable(self._compensations)
    
    if next(self._compensations) == nil then
        app.tip:floatTip(QUIWidgetMountRecycle.REBORN_NA, tipOffsetX)
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {heroId = self._heroId, compensations = self._compensations, 
                    callFunc = callRecycleAPI, title = self:getTitle(), tips = "提示：分解后，该暗器将彻底消失"}})
end

function QUIWidgetMountRecycle:getTitle()
    local title = QUIWidgetMountRecycle.REBORN_TITLE

    return title
end

function QUIWidgetMountRecycle:onTriggerRecycleFinished()
    self._playing = true
    local mount = self._mount
    self._mount = nil
    self._totalMoney = 0
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMountRecycle.MOUNT_SELECTED, mount = nil})

    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.effect:addChild(effect)
    local animation = self:getOptions().type == 1 and "effects/HeroRecoverEffect_up2.ccbi" or "effects/HeroRecoverEffect_up.ccbi"
    effect:playAnimation(animation, function()
            self._ccbOwner.mountName:setString("")
            self._ccbOwner.selectedNode:setVisible(false)

            local character = db:getCharacterByID(mount.zuoqiId)
            local sprite = CCSprite:create(character.visitingCard)
            sprite:setPositionY(-60)
            effect._ccbOwner.node_avatar:addChild(sprite)
        end, 
        function()
            effect:removeFromParentAndCleanup(true)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                options = {compensations = self._compensations, type = 6, subtitle = "暗器分解返还以下资源"}}, {isPopCurrentDialog = false})
            self._ccbOwner.selectedNode:setVisible(true)
            self:update(self._mount)
            self._playing = false
        end)
end

function QUIWidgetMountRecycle:onTriggerClose()
    if self._playing then return end
 
    self._mount = nil 
    self:update(self._mount)
end

function QUIWidgetMountRecycle:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 10}}, {isPopCurrentDialog = false})
end

function QUIWidgetMountRecycle:onTriggerExchange()
    if self._playing then return end

    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.metalCityShop)
end

function QUIWidgetMountRecycle:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.metalCityShop)
end

return QUIWidgetMountRecycle
