--
-- Author: Kumo.Wang
-- 仙品养成重生
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbReborn = class("QUIWidgetMagicHerbReborn", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroRebornCompensation = import("..dialogs.QUIDialogHeroRebornCompensation")
local QRichText = import("...utils.QRichText")
local QUIWidgetMagicHerbEffectBox = import("..widgets.QUIWidgetMagicHerbEffectBox")
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetMagicHerbReborn.REBORN_NA = "魂师大人，此仙品已经是初始状态，不需要重生了～"
QUIWidgetMagicHerbReborn.MAGICHERB_NA = "魂师大人，请先选择仙品"
QUIWidgetMagicHerbReborn.REBORN_TITLE = "仙品重生后将返还以下资源，是否确认重生该仙品"
QUIWidgetMagicHerbReborn.MAGICHERB_REBORN_EQUIPPED = "魂师大人，无法重生已装备的仙品，请将仙品卸下后重生～"

QUIWidgetMagicHerbReborn.MAGICHERB_SELECTED = "QUIWidgetMagicHerbReborn_.MAGICHERB_SELECTED"

local tipOffsetX = 135

function QUIWidgetMagicHerbReborn:ctor(options, dialogOptions)
    local ccbFile = "ccb/Widget_HeroRecover_MagicHerb.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self.onTriggerSelect)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self.onTriggerOK)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self.onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self.onTriggerRule)},
        {ccbCallbackName = "onTriggerMonthCard", callback = handler(self, self._onTriggerMonthCard)},
    }

    QUIWidgetMagicHerbReborn.super.ctor(self,ccbFile,callBacks,options)

    self._magicHerb = dialogOptions and dialogOptions.magicHerb 

    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0
    self._rebornType = options.type

    -- self._ccbOwner.pieceText:setVisible(self._rebornType == 1)
    -- self._ccbOwner.rebornText:setVisible(self._rebornType == 2)   
    self._ccbOwner.rebornText:setVisible(true)
    self._ccbOwner.pieceText:setVisible(false)
    self._ccbOwner.node_month_card:setVisible(false)

    self._ccbOwner.buttonName:setString(self._rebornType == 1 and "分 解" or "重 生")
    setShadow5(self._ccbOwner.magicHerbName, UNITY_COLOR.black)

    self:update(self._magicHerb)
    self:initExplainTTF()
end

--创建底部说明文字
function QUIWidgetMagicHerbReborn:initExplainTTF()
    local richText = QRichText.new({
        -- {oType = "font", content = "100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还仙品经验值，仙品重生为",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "1级",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "，不重置附加属性",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetMagicHerbReborn:onEnter()
    self._magicHerbProxy = cc.EventProxy.new(remote.magicHerb)
    self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_SELECTED_MAGIC_HERB, handler(self, self._onMagicHerbSelected))
end

function QUIWidgetMagicHerbReborn:onExit()
    self._magicHerbProxy:removeAllEventListeners()
end

function QUIWidgetMagicHerbReborn:update(magicHerb)
    self._ccbOwner.selectedNode:removeAllChildren()
    if magicHerb then
        local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(magicHerb.sid)
        local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerb.itemId)
        local itemConfig = db:getItemByID(magicHerbItemInfo.itemId)
        local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]]
        local name = magicHerbConfig.name
        local  breedLevel = magicHerb.breedLevel or 0
        if breedLevel == remote.magicHerb.BREED_LV_MAX then
            fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour + 1]]
        elseif breedLevel > 0 then
            name = name.."+"..breedLevel
        end

        self._ccbOwner.magicHerbName:setString(name)
        self._ccbOwner.magicHerbName:setColor(fontColor)

        self._ccbOwner.selectedNode:removeAllChildren()
        local icon = QUIWidgetMagicHerbEffectBox.new()
        self._ccbOwner.selectedNode:addChild(icon)
        icon:setInfo(magicHerb.sid, true)
        icon:hideName()
        icon:setPositionY(-50)
    else
        if self:getOptions().type == 1 then
            self._ccbOwner.token:setVisible(false)
        else
            self._ccbOwner.token:setVisible(true)

            self._price = QStaticDatabase.sharedDatabase():getConfigurationValue("MAGIC_HERB_RETURN")
            self._ccbOwner.tf_token:setString(self._price)
        end
    end

    self._ccbOwner.heroUnselected_foreground:setVisible(not magicHerb)
    self._ccbOwner.heroSelected_foreground:setVisible(not (not magicHerb))
    
    self._ccbOwner.node_month_card:setVisible(false)
    if remote.activity:checkMonthCardActive(1) then
        self._ccbOwner.node_month_card:setVisible(true)
        self._price = 0
    end
end

function QUIWidgetMagicHerbReborn:_onMagicHerbSelected(event)
    self._magicHerb = event.magicHerbInfo
    self:update(event.magicHerbInfo)
end

function QUIWidgetMagicHerbReborn:compensations(magicHerb)
    self:rebornMagicHerb(magicHerb)
end

-- 重生，返还突破和强化的
function QUIWidgetMagicHerbReborn:rebornMagicHerb(magicHerb)
    -- 升星
    local gradeItemNum, gradeItemId = self:_getGradeItemNum(magicHerb)
    -- 升級
    local uplevelItemNum, uplevelItemId = self:_getUpLevelItemNum(magicHerb)
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
    insertFunc(refineItemId, refineItemNum)
    insertFunc(breedItemId, breedItemNum)
end

function QUIWidgetMagicHerbReborn:_getGradeItemNum(magicHerb)
    local sid = magicHerb.sid
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
    local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)

    local magicHerbGradeConfigs = db:getStaticByName("magic_herb_grade")
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

function QUIWidgetMagicHerbReborn:_getUpLevelItemNum(magicHerb)
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

function QUIWidgetMagicHerbReborn:_getRefineItemNum(magicHerb)
    local sid = magicHerb.sid
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
    local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)

    local refineItemId = remote.magicHerb:getRefineItemIdAndPriceByAptitude( magicHerbConfig.aptitude )
    local refineItemNum = math.floor((magicHerbItemInfo.extendsAttributesRefineConsume or 0) * 0.3)

    return refineItemNum, refineItemId
end

function QUIWidgetMagicHerbReborn:_getBreedItemNum(magicHerb)

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
    return breedItemNum, breedItemId
end



function QUIWidgetMagicHerbReborn:sortCompensations(compensations)
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
function QUIWidgetMagicHerbReborn:onTriggerSelect()
    if self._playing then return end
    app.sound:playSound("common_small")
    local hasMagicHerb = false
    local magicHerbItemList = remote.magicHerb:getMagicHerbItemList()
    for _, magicHerbItem in ipairs(magicHerbItemList) do
        if (not magicHerbItem.actorId or magicHerbItem.actorId == 0)
            and (magicHerbItem.level > 1 
                or magicHerbItem.grade > 1 
                or (magicHerbItem.breedLevel and magicHerbItem.breedLevel > 0)) 
         then
            hasMagicHerb = true
            break
        end
    end
    if hasMagicHerb then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbCheckroom", 
            options = {isReborn = true, rebornType = self._rebornType}})
    else
        app.tip:floatTip("没有可以重生的仙品~")
    end
end

function QUIWidgetMagicHerbReborn:onTriggerOK(event)
    if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")

    if not self._magicHerb then
        app.tip:floatTip(QUIWidgetMagicHerbReborn.MAGICHERB_NA, tipOffsetX) 
        return
    end

    if remote.user.token < self._price then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end

    if self._magicHerb.actorId and self._magicHerb.actorId ~= 0 then
        app.tip:floatTip(QUIWidgetMagicHerbReborn.MAGICHERB_REBORN_EQUIPPED, tipOffsetX)
        return
    end

    self._compensations = {}
    self._tempCompensations = {} 
    self:compensations(self._magicHerb)  

    self:sortCompensations(self._tempCompensations)
    QPrintTable(self._compensations)
    
    if next(self._compensations) == nil then
        app.tip:floatTip(QUIWidgetMagicHerbReborn.REBORN_NA, tipOffsetX)
        return 
    end

    if  self._magicHerb.breedLevel and  self._magicHerb.breedLevel >= remote.magicHerb.BREED_LV_MAX 
        and self._magicHerb.replaceAttributes and #self._magicHerb.replaceAttributes > 0 then
        app.tip:floatTip("SS仙品转生属性没有替换完成，无法重生", tipOffsetX) 
        return 
    end



    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        local breedLevel = self._magicHerb.breedLevel or 0 
        if breedLevel >= remote.magicHerb.BREED_LV_MAX then
            app:alert({content = "重生后，第三条仙品转生属性将重新锁定，培育到SS品质后会再次解锁。前两条仙品属性如果为红色，将会降为橙色，类型不变。是否确认重生？", title = "重生提示", 
                btns = {ALERT_BTN.BTN_OK ,ALERT_BTN.BTN_CANCEL},
                callback = function(state)
                    if state == ALERT_TYPE.CONFIRM then
                        remote.magicHerb:magicHerbReturnRequest(self._magicHerb.sid, function()
                            if self._ccbView then
                                self:onTriggerRecycleFinished()
                            end
                            end)  
                    end
                end, isAnimation = false}, false, true)
        else
            remote.magicHerb:magicHerbReturnRequest(self._magicHerb.sid, function()
                    if self._ccbView then
                        self:onTriggerRecycleFinished()
                    end
                end)  
        end
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = self._compensations, callFunc = callRecycleAPI, title = self:getTitle()}})
end

function QUIWidgetMagicHerbReborn:getTitle()
    local title = QUIWidgetMagicHerbReborn.REBORN_TITLE

    return title
end

function QUIWidgetMagicHerbReborn:onTriggerRecycleFinished()
    self._playing = true
    local magicHerb = self._magicHerb
    self._magicHerb = nil

    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.effect:addChild(effect)
    local animation = self:getOptions().type == 1 and "effects/HeroRecoverEffect_up2.ccbi" or "effects/HeroRecoverEffect_up.ccbi"
    effect:playAnimation(animation, function()
            self._ccbOwner.magicHerbName:setString("")
            self._ccbOwner.selectedNode:setVisible(false)

            local icon = QUIWidgetMagicHerbEffectBox.new()
            icon:setInfo(magicHerb.sid, true)
            icon:hideName()
            icon:setPositionY(-60)
            effect._ccbOwner.node_avatar:addChild(icon)
        end, 
        function()
            effect:removeFromParentAndCleanup(true)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                options = {compensations = self._compensations, type = 9, subtitle = "仙品重生返还以下资源"}}, {isPopCurrentDialog = false})
            self._ccbOwner.selectedNode:setVisible(true)
            self:update(self._magicHerb)
            self._playing = false
        end)
end

function QUIWidgetMagicHerbReborn:onTriggerClose()
    if self._playing then return end
 
    self._magicHerb = nil 
    self:update(self._magicHerb)
end

function QUIWidgetMagicHerbReborn:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 17}}, {isPopCurrentDialog = false})
end

function QUIWidgetMagicHerbReborn:_onTriggerMonthCard()
    if self._playing then return end
    
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

return QUIWidgetMagicHerbReborn
