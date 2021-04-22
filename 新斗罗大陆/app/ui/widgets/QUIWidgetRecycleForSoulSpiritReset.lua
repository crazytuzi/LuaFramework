--
-- Kumo.Wang
-- 回收站，单个回收界面——魂灵重生
--
local QUIWidgetRecycleForAlone = import("..widgets.QUIWidgetRecycleForAlone")
local QUIWidgetRecycleForSoulSpiritReset = class("QUIWidgetRecycleForSoulSpiritReset", QUIWidgetRecycleForAlone)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QRichText = import("...utils.QRichText")

function QUIWidgetRecycleForSoulSpiritReset:ctor(options)
	QUIWidgetRecycleForSoulSpiritReset.super.ctor(self, options)
end

function QUIWidgetRecycleForSoulSpiritReset:onEnter()
    QUIWidgetRecycleForSoulSpiritReset.super.onEnter(self)

    self._soulSpiritProxy = cc.EventProxy.new(remote.soulSpirit)
    self._soulSpiritProxy:addEventListener(remote.soulSpirit.EVENT_SELECTED_SOULSPIRIT, handler(self, self._onItemSelected))
end

function QUIWidgetRecycleForSoulSpiritReset:onExit()
    QUIWidgetRecycleForSoulSpiritReset.super.onExit(self)

    self._soulSpiritProxy:removeAllEventListeners()
end

function QUIWidgetRecycleForSoulSpiritReset:_onItemSelected(event)
    if self.isPlaying then return end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()
    if event.soulSpirit == nil then return end

    self.info = event.soulSpirit
    self:update()
end

function QUIWidgetRecycleForSoulSpiritReset:init()
    QUIWidgetRecycleForSoulSpiritReset.super.init(self)

    self.itemClassName = "QUIWidgetActorDisplay"
    self.priceKey = "SOUL_SPIRIT_RETURN"

    -- 初始化剪影
    QSetDisplayFrameByPath(self._ccbOwner.sp_sketch, QResPath("recycleSketch")[6])
    self._ccbOwner.sp_sketch:setPositionY(self._ccbOwner.sp_sketch:getPositionY() + 10)
    self._ccbOwner.tf_unselect_tips:setString("选择需要重生的魂灵")
end

function QUIWidgetRecycleForSoulSpiritReset:initExplain()
    QUIWidgetRecycleForSoulSpiritReset.super.initExplain(self)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "100%"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "返还升级道具、金魂币，"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "魂灵转换成魂灵碎片"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "，图鉴保留"},
        }, 680, {autoCenter = true})
    richText:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.node_tf_explain:addChild(richText)
end

function QUIWidgetRecycleForSoulSpiritReset:initMenu()
    QUIWidgetRecycleForSoulSpiritReset.super.initMenu(self)

    self._ccbOwner.node_btn_help:setVisible(true)
end

function QUIWidgetRecycleForSoulSpiritReset:updateData()
    if self.info then
        self._ccbOwner.node_unselected:setVisible(false)
        self._ccbOwner.node_selected:setVisible(true)
        self._ccbOwner.node_avatar:removeAllChildren()

        if not self.itemClass then
            self.itemClass = import(app.packageRoot .. ".ui.widgets." .. self.itemClassName)
        end

        self.avatar = self.itemClass.new(self.info.id)
        self.avatar:setPositionY(-100)
        self._ccbOwner.node_avatar:addChild(self.avatar:getView())

        -- Show title 
        local characherConfig = db:getCharacterByID(self.info.id)
        if characherConfig then
            local nameStr = characherConfig.name
            local color = remote.soulSpirit:getColorByCharacherId(self.info.id)
            local fontColor = QIDEA_QUALITY_COLOR[color]
            self._ccbOwner.tf_name:setColor(fontColor)
            setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
            self._ccbOwner.tf_name:setString(nameStr)
            self._ccbOwner.node_name_info:setVisible(true)
        end
    else
        self._ccbOwner.node_unselected:setVisible(true)
        self._ccbOwner.node_selected:setVisible(false)
    end
end

function QUIWidgetRecycleForSoulSpiritReset:updateRecyclePreviewInfo()
    local info = {}
    self.importantKeysList = {}

    if not self.info then return info end

    -- 升星
    local gradeItemNum, gradeItemId = self:_getGradePreviewInfo()
    -- 升級
    local levelUpConsumeDic = remote.soulSpirit:getLevelUpConsumeDicById(self.info.id)
    local devourConsumeDic = remote.soulSpirit:getDevourConsumeDicById(self.info.id)
    QPrintTable(devourConsumeDic)
    local insertFunc = function(id, num)
        if info[id] == nil then
            info[id] = num
        else
            info[id] = info[id] + num
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
    local awakenConsumDic = remote.soulSpirit:getAwakenConsumeByData(self.info)
    if not q.isEmpty(awakenConsumDic) then
        for i, dic in pairs(awakenConsumDic) do
            for k, value in pairs(dic) do
                insertFunc(value.id, value.count)
            end
        end
    end
    
    return info
end

function QUIWidgetRecycleForSoulSpiritReset:_getGradePreviewInfo()
    local gradeConfigs = db:getGradeByHeroId(self.info.id)
    local gradeItemId = 0
    local gradeItemNum = 0
    if gradeConfigs then
        for _, config in pairs(gradeConfigs) do
            if config.grade_level <= self.info.grade then
                if gradeItemId == 0 then
                    gradeItemId = config.soul_gem
                end
                gradeItemNum = gradeItemNum + config.soul_gem_count
            end
        end
    end

    return gradeItemNum, gradeItemId
end

function QUIWidgetRecycleForSoulSpiritReset:onTriggerRecycle()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    if not self.info then
        app.tip:floatTip("请先选择一个需要重生的魂灵") 
        return
    end

    if self.info.actorId and self.info.actorId ~= 0 then
        app.tip:floatTip("魂师大人，无法重生已装备的魂灵，请将魂灵卸下后重生～")
        return
    end

    if remote.user.token < self.price then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end

    local function callRebornAPI(finalRecycleInfo)
        remote.soulSpirit:soulSpiritRecoverRequest(self.info.id, false, function()
                if self._ccbView then
                    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                    self:_onTriggerRecycleFinished(finalRecycleInfo)
                end
            end,function ()
                if self._ccbView then
                    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                    self.id = nil
                    self.info = nil
                    self:update()
                end
            end)
    end

    local info = self:updateRecyclePreviewInfo()    
    QKumo(info)
    local finalRecycleInfo = self:sortRecyclePreviewInfo(info)
    if next(finalRecycleInfo) == nil then
        app.tip:floatTip("魂师大人，该魂灵已经是初始状态，不需要重生了～")
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = finalRecycleInfo, token = self.price, title = "魂灵重生后将返还以下资源，是否确认分解该魂灵", callFunc = callRebornAPI}})
end
function QUIWidgetRecycleForSoulSpiritReset:_onTriggerRecycleFinished(finalRecycleInfo)
    self.isPlaying = true
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(effect)
    effect:playAnimation("effects/HeroRecoverEffect_up.ccbi", function()
            if self._ccbView then
                effect._ccbOwner.node_avatar:setVisible(false)
            end
        end, function()
            if self._ccbView then
                effect:removeFromParentAndCleanup(true)
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                    options = {compensations = finalRecycleInfo, type = 4, subtitle = "魂灵重生返还以下资源"}}, {isPopCurrentDialog = false})
                self.id = nil
                self.info = nil
                self:update()
                self.isPlaying = false
            end
        end)
end

function QUIWidgetRecycleForSoulSpiritReset:onTriggerHelp()
    if self.isPlaying then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", options = {type = 19}}, {isPopCurrentDialog = false})
end

function QUIWidgetRecycleForSoulSpiritReset:onTriggerSelect()
    if self.isPlaying then return end
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
            options = {isReborn = true, rebornType = 2}})
    else
        app.tip:floatTip("没有可以重生的魂灵~")
    end
end

return QUIWidgetRecycleForSoulSpiritReset
