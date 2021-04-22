--
-- Author: Kumo.Wang
-- 仙品养成分解
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbPiece = class("QUIWidgetMagicHerbPiece", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroRebornCompensation = import("..dialogs.QUIDialogHeroRebornCompensation")
local QRichText = import("...utils.QRichText")
local QUIWidgetMagicHerbEffectBox = import("..widgets.QUIWidgetMagicHerbEffectBox")
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetMagicHerbPiece.MAGICHERB_NA = "魂师大人，请先选择仙品"
QUIWidgetMagicHerbPiece.REBORN_TITLE = "仙品分解后将返还以下资源，是否确认分解该仙品"
QUIWidgetMagicHerbPiece.MAGICHERB_REBORN_EQUIPPED = "魂师大人，无法分解已装备的仙品，请将仙品卸下后分解～"

QUIWidgetMagicHerbPiece.MAGICHERB_SELECTED = "QUIWidgetMagicHerbPiece_.MAGICHERB_SELECTED"

local tipOffsetX = 135

function QUIWidgetMagicHerbPiece:ctor(options, dialogOptions)
    local ccbFile = "ccb/Widget_HeroRecover_MagicHerb.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, QUIWidgetMagicHerbPiece.onTriggerSelect)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetMagicHerbPiece.onTriggerOK)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIWidgetMagicHerbPiece.onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetMagicHerbPiece.onTriggerRule)},
    }

    QUIWidgetMagicHerbPiece.super.ctor(self,ccbFile,callBacks,options)

    self._magicHerb = dialogOptions and dialogOptions.magicHerb 

    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0
    self._rebornType = options.type

    -- self._ccbOwner.pieceText:setVisible(self._rebornType == 1)
    -- self._ccbOwner.rebornText:setVisible(self._rebornType == 2)   
    self._ccbOwner.rebornText:setVisible(false)
    self._ccbOwner.pieceText:setVisible(true)
    self._ccbOwner.node_month_card:setVisible(false)

    self._ccbOwner.buttonName:setString(self._rebornType == 1 and "分 解" or "重 生")
    setShadow5(self._ccbOwner.magicHerbName, UNITY_COLOR.black)

    self:update(self._magicHerb)
    self:initExplainTTF()
end

--创建底部说明文字
function QUIWidgetMagicHerbPiece:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还仙品养成道具，仙品",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "转化为强化道具",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "。",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetMagicHerbPiece:onEnter()
    self._magicHerbProxy = cc.EventProxy.new(remote.magicHerb)
    self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_SELECTED_MAGIC_HERB, handler(self, self._onMagicHerbSelected))
end

function QUIWidgetMagicHerbPiece:onExit()
    self._magicHerbProxy:removeAllEventListeners()
end

function QUIWidgetMagicHerbPiece:update(magicHerb)
    self._ccbOwner.selectedNode:removeAllChildren()
    if magicHerb then
        local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerb.itemId)
        local maigcHerbItemConfig = db:getItemByID(maigcHerb.itemId)

        self._ccbOwner.magicHerbName:setString(magicHerbConfig.name)
        local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[maigcHerbItemConfig.colour]]
        self._ccbOwner.magicHerbName:setColor(fontColor)

        self._ccbOwner.selectedNode:removeAllChildren()
        local icon = QUIWidgetMagicHerbEffectBox.new()
        self._ccbOwner.selectedNode:addChild(icon)
        icon:setInfo(magicHerb.sid, true)
        icon:hideName()
    else
        if self:getOptions().type == 1 then
            self._ccbOwner.token:setVisible(false)
        else
            self._ccbOwner.token:setVisible(true)

            self._price = 0
            self._ccbOwner.tf_token:setString(price)
        end
    end

    self._ccbOwner.heroUnselected_foreground:setVisible(not magicHerb)
    self._ccbOwner.heroSelected_foreground:setVisible(not (not magicHerb))
end

function QUIWidgetMagicHerbPiece:_onMagicHerbSelected(event)
    self._magicHerb = event.magicHerbInfo
    self:update(event.magicHerbInfo)
end

function QUIWidgetMagicHerbPiece:compensations(magicHerb)
    self:rebornMagicHerb(magicHerb)
end

-- 分解，返还突破和强化的
function QUIWidgetMagicHerbPiece:rebornMagicHerb(magicHerb)
    -- 升星
    local gradeItemNum, gradeItemId = self:_getGradeItemNum(magicHerb)
    -- 升級
    local uplevelItemNum, uplevelItemId = self:_getUpLevelItemNum(magicHerb)
    -- 轉化強化道具
    local changeItemNum, changeItemId = self:_getChangeItemNum(magicHerb)
    -- 轉生
    local refineItemNum, refineItemId = self:_getRefineItemNum(magicHerb)

    local insertFunc = function(id, num)
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
end

function QUIWidgetMagicHerbPiece:_getGradeItemNum(magicHerb)
    local sid = magicHerb.sid
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)

    local magicHerbGradeConfigs = QStaticDatabase.sharedDatabase():getStaticByName("magic_herb_grade")
    local configList = magicHerbGradeConfigs[tostring(magicHerbItemInfo.id)] or {}
    local gradeItemNum = 0
    for _, value in ipairs(configList) do
        if value.grade <= magicHerb.grade and value.consum_num then
            gradeItemNum = gradeItemNum + value.consum_num
        end
    end

    local gradeItemId = 17100039
    local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerb.itemId)
    local wildConfig = remote.magicHerb:getWildMagicHerbByAptitude(magicHerbConfig.aptitude)
    if wildConfig then
        gradeItemId = wildConfig.id
    end

    return gradeItemNum, gradeItemId
end

function QUIWidgetMagicHerbPiece:_getUpLevelItemNum(magicHerb)
    local sid = magicHerb.sid
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)

    local magicHerbEnchantConfigs = QStaticDatabase.sharedDatabase():getStaticByName("magic_herb_enhance")
    local configList = magicHerbEnchantConfigs[tostring(magicHerbItemInfo.id)] or {}
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

function QUIWidgetMagicHerbPiece:_getChangeItemNum(magicHerb)
    local changeItemId = 0
    local changeItemNum = 0
    local sid = magicHerb.sid
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
    local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(magicHerbItemInfo.id)
    if itemConfig and itemConfig.item_recycle then
        local tbl = string.split(itemConfig.item_recycle, "^")
        changeItemId = tonumber(tbl[1])
        changeItemNum = tonumber(tbl[2])
    end

    return changeItemNum, changeItemId
end

function QUIWidgetMagicHerbPiece:_getRefineItemNum(magicHerb)
    local sid = magicHerb.sid
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
    local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerb.itemId)

    local refineItemId = remote.magicHerb:getRefineItemIdAndPriceByAptitude( magicHerbConfig.aptitude )
    local refineItemNum = 0
    local num1 = math.floor((magicHerbItemInfo.extendsAttributesRefineConsume or 0) * 0.3)
    local num2 = math.floor((magicHerbItemInfo.attributesRefineConsume or 0) * 0.3)
    refineItemNum = num1 + num2
    
    return refineItemNum, refineItemId
end

function QUIWidgetMagicHerbPiece:sortCompensations(compensations)
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
function QUIWidgetMagicHerbPiece:onTriggerSelect()
    if self._playing then return end
    app.sound:playSound("common_small")
    local hasMagicHerb = false
    local magicHerbItemList = remote.magicHerb:getMagicHerbItemList()
    for _, magicHerbItem in ipairs(magicHerbItemList) do
        if not magicHerbItem.magicHerbInfo.actorId or magicHerbItem.magicHerbInfo.actorId == 0 then
            hasMagicHerb = true
            break
        end
    end
    if hasMagicHerb then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbCheckroom", 
            options = {isReborn = true, rebornType = self._rebornType}})
    else
        app.tip:floatTip("没有可以分解的仙品~")
    end
end

function QUIWidgetMagicHerbPiece:onTriggerOK()
    if self._playing then return end
    app.sound:playSound("common_small")

    if not self._magicHerb then
        app.tip:floatTip(QUIWidgetMagicHerbPiece.MAGICHERB_NA, tipOffsetX) 
        return
    end

    if self._magicHerb.actorId and self._magicHerb.actorId ~= 0 then
        app.tip:floatTip(QUIWidgetMagicHerbPiece.MAGICHERB_REBORN_EQUIPPED, tipOffsetX)
        return
    end

    self._compensations = {}
    self._tempCompensations = {} 
    self:compensations(self._magicHerb)  

    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

        remote.magicHerb:magicHerbRecoverRequest(self._magicHerb.sid, function()
                if self._ccbView then
                    self:onTriggerRecycleFinished()
                end
            end)
    end
    
    self:sortCompensations(self._tempCompensations)
    QPrintTable(self._compensations)

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = self._compensations, callFunc = callRecycleAPI, title = self:getTitle()}})
end

function QUIWidgetMagicHerbPiece:getTitle()
    local title = QUIWidgetMagicHerbPiece.REBORN_TITLE

    return title
end

function QUIWidgetMagicHerbPiece:onTriggerRecycleFinished()
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
                options = {compensations = self._compensations, type = 10, subtitle = "仙品分解返还以下资源"}}, {isPopCurrentDialog = false})
            self._ccbOwner.selectedNode:setVisible(true)
            self:update(self._magicHerb)
            self._playing = false
        end)
end

function QUIWidgetMagicHerbPiece:onTriggerClose()
    if self._playing then return end
 
    self._magicHerb = nil 
    self:update(self._magicHerb)
end

function QUIWidgetMagicHerbPiece:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 18}}, {isPopCurrentDialog = false})
end

return QUIWidgetMagicHerbPiece
