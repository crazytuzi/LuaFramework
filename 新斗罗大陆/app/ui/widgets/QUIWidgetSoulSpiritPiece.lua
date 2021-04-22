--
-- Author: Kumo.Wang
-- 魂灵养成分解
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritPiece = class("QUIWidgetSoulSpiritPiece", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogHeroRebornCompensation = import("..dialogs.QUIDialogHeroRebornCompensation")
local QRichText = import("...utils.QRichText")
local QUIWidgetSoulSpiritEffectBox = import("..widgets.QUIWidgetSoulSpiritEffectBox")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

QUIWidgetSoulSpiritPiece.MAGICHERB_NA = "魂师大人，请先选择魂灵"
QUIWidgetSoulSpiritPiece.REBORN_TITLE = "魂灵分解后将返还以下资源，是否确认分解该魂灵"
QUIWidgetSoulSpiritPiece.MAGICHERB_REBORN_EQUIPPED = "魂师大人，无法分解已装备的魂灵，请将魂灵卸下后分解～"
QUIWidgetSoulSpiritPiece.REBORN_TIP = "提示：分解后该魂灵将彻底消失"



local tipOffsetX = 135

function QUIWidgetSoulSpiritPiece:ctor(options, dialogOptions)
    local ccbFile = "ccb/Widget_HeroRecover_MagicHerb.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, QUIWidgetSoulSpiritPiece.onTriggerSelect)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetSoulSpiritPiece.onTriggerOK)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIWidgetSoulSpiritPiece.onTriggerClose)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetSoulSpiritPiece.onTriggerRule)},
    }

    QUIWidgetSoulSpiritPiece.super.ctor(self,ccbFile,callBacks,options)

    self._soulSpirit = dialogOptions and dialogOptions.soulSpirit 

    self._compensations = {}
    self._tempCompensations = {} 
    self._totalMoney = 0
    self._rebornType = options.type

    self._ccbOwner.rebornText:setVisible(false)
    self._ccbOwner.pieceText:setVisible(true)
    self._ccbOwner.pieceText:setString("选择需要分解的魂灵")
    self._ccbOwner.node_month_card:setVisible(false)

    self._ccbOwner.buttonName:setString(self._rebornType == 1 and "分 解" or "重 生")
    setShadow5(self._ccbOwner.magicHerbName, UNITY_COLOR.black)

    self._ccbOwner.sp_sketch:setDisplayFrame(QSpriteFrameByPath(QResPath("soul_spirit_shadow")))
    self._ccbOwner.sp_sketch:setPositionY(3)
    self._ccbOwner.sp_sketch:setPositionX(-12)

    self._ccbOwner.sp_plus:setPositionY(72)
    
    self:update(self._soulSpirit)
    self:initExplainTTF()
end

--创建底部说明文字
function QUIWidgetSoulSpiritPiece:initExplainTTF()
    local richText = QRichText.new({
        {oType = "font", content = "100%",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "返还魂灵升级道具、金魂币，",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "魂灵转化为传灵币",size = 22,color = ccc3(0,252,255),strokeColor=ccc3(0,0,0)},
        {oType = "font", content = "。",size = 22,color = ccc3(255,232,191),strokeColor=ccc3(0,0,0)},
    },790,{autoCenter = true})

    self._ccbOwner.explainTTF:addChild(richText)
end

function QUIWidgetSoulSpiritPiece:onEnter()
    self._soulSpiritProxy = cc.EventProxy.new(remote.soulSpirit)
    self._soulSpiritProxy:addEventListener(remote.soulSpirit.EVENT_SELECTED_SOULSPIRIT, handler(self, self._onSelected))
end

function QUIWidgetSoulSpiritPiece:onExit()
    self._soulSpiritProxy:removeAllEventListeners()
end

function QUIWidgetSoulSpiritPiece:update(soulSpirit)
    self._ccbOwner.selectedNode:removeAllChildren()
    if soulSpirit then
        local characherConfig = QStaticDatabase.sharedDatabase():getCharacterByID(soulSpirit.id)
        self._ccbOwner.magicHerbName:setString(characherConfig.name)
        local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[characherConfig.colour]]
        self._ccbOwner.magicHerbName:setColor(fontColor)

        self._ccbOwner.selectedNode:removeAllChildren()
        -- local icon = QUIWidgetSoulSpiritEffectBox.new()
        -- self._ccbOwner.selectedNode:addChild(icon)
        -- icon:setInfo(soulSpirit.id, true)
        local avatar = QUIWidgetActorDisplay.new(soulSpirit.id)
        self._ccbOwner.selectedNode:addChild(avatar)
        avatar:setPositionY(-100)
        avatar:setScaleX(-1)
    else
        if self:getOptions().type == 1 then
            self._ccbOwner.token:setVisible(false)
        else
            self._ccbOwner.token:setVisible(true)

            self._price = 0
            self._ccbOwner.tf_token:setString(price)
        end
    end

    self._ccbOwner.heroUnselected_foreground:setVisible(not soulSpirit)
    self._ccbOwner.heroSelected_foreground:setVisible(not (not soulSpirit))
end

function QUIWidgetSoulSpiritPiece:_onSelected(event)
    self._soulSpirit = event.soulSpirit
    self:update(event.soulSpirit)
end

function QUIWidgetSoulSpiritPiece:compensations(soulSpirit)
    self:rebornMagicHerb(soulSpirit)
end

-- 分解，返还突破和强化的
function QUIWidgetSoulSpiritPiece:rebornMagicHerb(soulSpirit)
    -- 升星
    local gradeItemNum, gradeItemId = self:_getGradeItemNum(soulSpirit)
    -- 升級
    -- local uplevelItemNum, uplevelItemId = self:_getUpLevelItemNum(soulSpirit)
    local levelUpConsumeDic = self:_getUpLevelItemNum(soulSpirit)
    local devourConsumeDic = remote.soulSpirit:getDevourConsumeDicById(soulSpirit.id)
    QPrintTable(devourConsumeDic)


    local insertFunc = function(id, num)
        if self._tempCompensations[id] == nil then
            self._tempCompensations[id] = num
        else
            self._tempCompensations[id] = self._tempCompensations[id] + num
        end
    end
    insertFunc(gradeItemId, gradeItemNum)
    -- insertFunc(uplevelItemId, uplevelItemNum)
    if levelUpConsumeDic then
        for id, num in pairs(levelUpConsumeDic) do
            insertFunc(id, num)
        end
    end

    if devourConsumeDic then
        for id, num in pairs(devourConsumeDic) do
            insertFunc(id, num)
        end
    end
    
    local awakenConsumDic = remote.soulSpirit:getAwakenConsumeByData(soulSpirit)
    if not q.isEmpty(awakenConsumDic) then
        for i, dic in pairs(awakenConsumDic) do
            for k, value in pairs(dic) do
                insertFunc(value.id, value.count)
            end
        end
    end

end

function QUIWidgetSoulSpiritPiece:_getGradeItemNum(soulSpirit)
    local gradeConfigs = QStaticDatabase.sharedDatabase():getGradeByHeroId(soulSpirit.id)
    local gradeItemId = 0
    local gradeItemNum = 0
    for _, config in pairs(gradeConfigs) do
        if config.grade_level <= soulSpirit.grade then
            if gradeItemId == 0 then
                gradeItemId = config.soul_gem
            end
            gradeItemNum = gradeItemNum + config.soul_gem_count
        end
    end

    local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(gradeItemId)
    local changeItemId = ITEM_TYPE.TEAM_MONEY
    local changeItemNum = itemConfig.soul_recycle * gradeItemNum

    return changeItemNum, changeItemId
end

function QUIWidgetSoulSpiritPiece:_getUpLevelItemNum(soulSpirit)
    -- local characherConfig = QStaticDatabase.sharedDatabase():getCharacterByID(soulSpirit.id)
    -- local levelConfigs = remote.soulSpirit:getLevelConfigListByAptitude(characherConfig.aptitude)
    -- local totalExp = 0
    -- for _, config in pairs(levelConfigs) do
    --     if config.chongwu_level <= soulSpirit.level and config.strengthen_chongwu then
    --         totalExp = totalExp + config.strengthen_chongwu
    --     end
    -- end
    -- totalExp = totalExp + soulSpirit.exp

    -- local upLevelItemId = QStaticDatabase.sharedDatabase():getConfigurationValue("soul_spirit_convert_baisc_item")
    -- local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(upLevelItemId)
    -- local returnExp = totalExp * QStaticDatabase.sharedDatabase():getConfigurationValue("soul_spirit_piece_convert_raito") / 100
    -- local upLevelItemNum = math.floor(returnExp / itemConfig.exp)

    -- return upLevelItemNum, upLevelItemId

    local levelUpConsumeDic = remote.soulSpirit:getLevelUpConsumeDicById(soulSpirit.id)

    return levelUpConsumeDic
end

function QUIWidgetSoulSpiritPiece:sortCompensations(compensations)
    local tempCompensations = {}

    for k, v in pairs(compensations) do
        if v > 0 then
            table.insert(tempCompensations, {id = k, value = v})
        end
    end
    table.sort(tempCompensations, function(x, y)
            if tonumber(x.id) and tonumber(y.id) then
                return x.id < y.id
            elseif tonumber(x.id) then
                return true
            else
                return false
            end
        end)
    for _, v in ipairs(tempCompensations) do
        table.insert(self._compensations, v)
    end
end

-- Callbacks
function QUIWidgetSoulSpiritPiece:onTriggerSelect()
    if self._playing then return end
    app.sound:playSound("common_small")
    local hasMagicHerb = false
    local soulSpiritList = remote.soulSpirit:getMySoulSpiritInfoList()
    for _, info in ipairs(soulSpiritList) do
        if not info.heroId or info.heroId == 0 then
            hasMagicHerb = true
            break
        end
    end
    if hasMagicHerb then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritOverView", 
            options = {isRecycle = true, rebornType = self._rebornType}})
    else
        app.tip:floatTip("没有可以分解的魂灵~")
    end
end

function QUIWidgetSoulSpiritPiece:onTriggerOK(event)
    if self._playing then return end
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")

    if not self._soulSpirit then
        app.tip:floatTip(QUIWidgetSoulSpiritPiece.MAGICHERB_NA, tipOffsetX) 
        return
    end

    if self._soulSpirit.heroId and self._soulSpirit.heroId ~= 0 then
        app.tip:floatTip(QUIWidgetSoulSpiritPiece.MAGICHERB_REBORN_EQUIPPED, tipOffsetX)
        return
    end

    self._compensations = {}
    self._tempCompensations = {} 
    self:compensations(self._soulSpirit)  

    local function callRecycleAPI()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

        remote.soulSpirit:soulSpiritRecoverRequest(self._soulSpirit.id, true, function()
                if self._ccbView then
                    self:onTriggerRecycleFinished()
                end
            end)
    end
    
    self:sortCompensations(self._tempCompensations)
    QPrintTable(self._compensations)

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = self._compensations, callFunc = callRecycleAPI, tips= QUIWidgetSoulSpiritPiece.REBORN_TIP,title = self:getTitle()}})
end

function QUIWidgetSoulSpiritPiece:getTitle()
    local title = QUIWidgetSoulSpiritPiece.REBORN_TITLE

    return title
end

function QUIWidgetSoulSpiritPiece:onTriggerRecycleFinished()
    self._playing = true
    local soulSpirit = self._soulSpirit
    self._soulSpirit = nil

    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.effect:addChild(effect)
    local animation = self:getOptions().type == 1 and "effects/HeroRecoverEffect_up2.ccbi" or "effects/HeroRecoverEffect_up.ccbi"
    effect:playAnimation(animation, function()
            -- self._ccbOwner.magicHerbName:setString("")
            -- self._ccbOwner.selectedNode:setVisible(false)

            -- local icon = QUIWidgetSoulSpiritEffectBox.new()
            -- icon:setInfo(soulSpirit.id, true)
            -- icon:setPositionY(-60)
            -- effect._ccbOwner.node_avatar:addChild(icon)
        end, 
        function()
            effect:removeFromParentAndCleanup(true)
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                options = {compensations = self._compensations, type = 11, subtitle = "魂灵分解返还以下资源"}}, {isPopCurrentDialog = false})
            self._ccbOwner.selectedNode:setVisible(true)
            self:update(self._soulSpirit)
            self._playing = false
        end)
end

function QUIWidgetSoulSpiritPiece:onTriggerClose()
    if self._playing then return end
 
    self._soulSpirit = nil 
    self:update(self._soulSpirit)
end

function QUIWidgetSoulSpiritPiece:onTriggerRule()
    if self._playing then return end

    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", 
        options = {type = 20}}, {isPopCurrentDialog = false})
end

return QUIWidgetSoulSpiritPiece
