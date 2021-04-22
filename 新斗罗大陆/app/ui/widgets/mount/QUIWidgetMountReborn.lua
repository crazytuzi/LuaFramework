
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountReborn = class("QUIWidgetMountReborn", QUIWidget)

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

QUIWidgetMountReborn.REBORN_NA = "魂师大人，此暗器已经是初始状态，不需要重生了～"
QUIWidgetMountReborn.MOUNT_NA = "魂师大人，请先选择暗器"
QUIWidgetMountReborn.REBORN_TITLE = "暗器重生后将返还以下资源，是否确认重生该暗器"
QUIWidgetMountReborn.MOUNT_REBORN_EQUIPPED = "魂师大人，无法重生已装备的暗器，请将暗器卸下后重生～"
QUIWidgetMountReborn.MOUNT_REBORN_WEARED = "魂师大人，当前暗器装备了配件暗器，请先卸下配件暗器后重生～"

QUIWidgetMountReborn.MOUNT_SELECTED = "QUIWidgetMountReborn_MOUNT_SELECTED"

local tipOffsetX = 135

function QUIWidgetMountReborn:ctor(options, dialogOptions)
    local ccbFile = "ccb/Widget_herorecover_mount.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self.onTriggerSelect)},
        {ccbCallbackName = "onTriggerRecycle", callback = handler(self, self.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self.onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self.onTriggerRule)},
        {ccbCallbackName = "onTriggerExchange", callback = handler(self, self.onTriggerExchange)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, self.onTriggerShop)},
        {ccbCallbackName = "onTriggerMonthCard", callback = handler(self, self._onTriggerMonthCard)},
    }

    QUIWidgetMountReborn.super.ctor(self,ccbFile,callBacks,options)
    q.setButtonEnableShadow(self._ccbOwner.btn_shop)

    self._mount = dialogOptions and dialogOptions.mount 
    self:initExplainTTF()

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

    self:update(self._mount)
end

--创建底部说明文字
function QUIWidgetMountReborn:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还养成的资源与材料、暗器",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "变为1级",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetMountReborn:onEnter()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogMountOverView.MOUNT_CLICK, self.onMountSelected, self)
end

function QUIWidgetMountReborn:onExit()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogMountOverView.MOUNT_CLICK, self.onMountSelected, self)
end

function QUIWidgetMountReborn:update(mount)
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

    self._token = db:getConfiguration()["HERO_RECYCLE"].value or 0
    self._ccbOwner.tf_token:setString(self._token)
    self._ccbOwner.node_month_card:setVisible(false)
    if remote.activity:checkMonthCardActive(1) then
        self._ccbOwner.node_month_card:setVisible(true)
        self._token = 0
    end
end

function QUIWidgetMountReborn:onMountSelected(event)
    self._mount = event.mount
    self:update(event.mount)

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMountReborn.MOUNT_SELECTED, mount = self._mount})
end

function QUIWidgetMountReborn:compensations(mount)
    self:rebornMount(mount)
end

-- 重生，返还突破和强化的
function QUIWidgetMountReborn:rebornMount(mount)
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

    self:compensationForHero(mount.zuoqiId, mount.grade)
    self:compensationForHeroGrade(mount.zuoqiId, mount.grade)
    self:compensationForReform(mount.zuoqiId, mount.reformLevel)
    self:compensationForGrave(mount.zuoqiId)

    self._tempCompensations["money"] = self._totalMoney
end

function QUIWidgetMountReborn:compensationForReform(actorId, reformLevel)
    if not reformLevel or reformLevel == 0 then
        return
    end
    local mountConfig = db:getCharacterByID(actorId)
    local itemId = nil
    local need = 0
    local money = 0
    for i = 1, reformLevel do
        local curConfig = db:getReformConfigByAptitudeAndLevel(mountConfig.aptitude, i)
        local itemTbl1 = string.split(curConfig.consume_1, "^")
        local itemTbl2 = string.split(curConfig.consume_2, "^")
        itemId = tonumber(itemTbl1[1])
        need = need + tonumber(itemTbl1[2])
        money = money + tonumber(itemTbl2[2])
    end
    self._tempCompensations[itemId] = need
    self._totalMoney = self._totalMoney + money
end


function QUIWidgetMountReborn:compensationForHero(actorId, grade)
    local need = 0
    local itemId = nil
    for i = 1, grade, 1 do
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

function QUIWidgetMountReborn:compensationForHeroGrade(actorId, gradeLevel)
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

function QUIWidgetMountReborn:compensationForGrave(mountId)
    local mountInfo = remote.mount:getMountById(mountId)
    if mountInfo and mountInfo.grave_consume then
        local tblCusume = string.split(mountInfo.grave_consume,";")
        for k,v in pairs(tblCusume or {}) do
            local tbl = string.split(v,"^")
            local itemId = tonumber(tbl[1])
            local itemCount = tonumber(tbl[2] or 0)
            if itemId and itemCount > 0 then
                self._tempCompensations[itemId] = itemCount
            end
        end
    end
end

function QUIWidgetMountReborn:sortCompensations(compensations)
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
function QUIWidgetMountReborn:onTriggerSelect()
    if self._playing then return end
    app.sound:playSound("common_small")
    local hasMount = false
    local haveMounts = remote.mount:getMountMap()
    for _, mount in pairs(haveMounts) do
        if mount.actorId == 0 and (mount.enhanceLevel ~= 1 or mount.grade ~= 0 or mount.grave_level ~= 0) then
            hasMount = true
            break
        end
    end
    if hasMount then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
            options = {isReborn = true}})
    else
        app.tip:floatTip("没有可以重生的暗器~")
    end
end

function QUIWidgetMountReborn:onTriggerRecycle(event)
    if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_recycle) == false then return end
    app.sound:playSound("common_small")

    if not self._mount then
        app.tip:floatTip(QUIWidgetMountReborn.MOUNT_NA, tipOffsetX) 
        return
    end

    if self._mount.actorId and self._mount.actorId ~= 0 then
        app.tip:floatTip(QUIWidgetMountReborn.MOUNT_REBORN_EQUIPPED, tipOffsetX)
        return
    end

    if self._mount.wearZuoqiInfo then
        -- app.tip:floatTip(QUIWidgetMountReborn.MOUNT_REBORN_WEARED, tipOffsetX)
        -- return
    end

    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0
    self:compensations(self._mount)  

    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        if self._mount.wearZuoqiInfo then
            app.tip:floatTip("已自动卸下装备的配件暗器")
        end
        remote.mount:mountReborn(self._mount.zuoqiId, function()
                self:onTriggerRecycleFinished()
            end)
    end

    self:sortCompensations(self._tempCompensations)
    QPrintTable(self._compensations)
    
    if next(self._compensations) == nil then
        app.tip:floatTip(QUIWidgetMountReborn.REBORN_NA, tipOffsetX)
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {heroId = self._heroId, compensations = self._compensations, 
                    callFunc = callRecycleAPI, title = self:getTitle()}})
end

function QUIWidgetMountReborn:getTitle()
    local title = QUIWidgetMountReborn.REBORN_TITLE

    return title
end

function QUIWidgetMountReborn:onTriggerRecycleFinished()
    self._playing = true
    local mount = self._mount
    self._mount = nil
    self._totalMoney = 0
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMountReborn.MOUNT_SELECTED, mount = nil})

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
                options = {compensations = self._compensations, type = 5, subtitle = "暗器重生返还以下资源"}}, {isPopCurrentDialog = false})
            self._ccbOwner.selectedNode:setVisible(true)
            self:update(self._mount)
            self._playing = false
        end)
end

function QUIWidgetMountReborn:onTriggerClose()
    if self._playing then return end
 
    self._mount = nil 
    self:update(self._mount)
end

function QUIWidgetMountReborn:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 9}}, {isPopCurrentDialog = false})
end

function QUIWidgetMountReborn:onTriggerExchange()
    if self._playing then return end

    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.metalCityShop)
end

function QUIWidgetMountReborn:onTriggerShop()
    if self._playing then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.metalCityShop)
end

function QUIWidgetMountReborn:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

return QUIWidgetMountReborn
