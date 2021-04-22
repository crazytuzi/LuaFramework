--
-- Kumo.Wang
-- 回收站，单个回收界面——神器重生
--
local QUIWidgetRecycleForAlone = import("..widgets.QUIWidgetRecycleForAlone")
local QUIWidgetRecycleForGodarmReset = class("QUIWidgetRecycleForGodarmReset", QUIWidgetRecycleForAlone)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QRichText = import("...utils.QRichText")
local QUIDialogGodarmOverView = import("..dialogs.QUIDialogGodarmOverView")

function QUIWidgetRecycleForGodarmReset:ctor(options)
	QUIWidgetRecycleForGodarmReset.super.ctor(self, options)
end

function QUIWidgetRecycleForGodarmReset:onEnter()
    QUIWidgetRecycleForGodarmReset.super.onEnter(self)

    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogGodarmOverView.GODARM_CLICK, self._onItemSelected, self)
end

function QUIWidgetRecycleForGodarmReset:onExit()
    QUIWidgetRecycleForGodarmReset.super.onExit(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogGodarmOverView.GODARM_CLICK, self._onItemSelected, self)
end

function QUIWidgetRecycleForGodarmReset:_onItemSelected(event)
    if self.isPlaying then return end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()
    if event.godarmId == nil then return end

    self.id = event.godarmId
    self.info = remote.godarm:getGodarmById(self.id)

    self:update()
end

function QUIWidgetRecycleForGodarmReset:init()
    -- 初始化商店按鈕icon
    local config = remote.items:getWalletByType(ITEM_TYPE.GOD_ARM_MONEY)
    local spf = QSpriteFrameByPath(config.alphaIcon)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 1)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 2)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 4)
    self._ccbOwner.tf_store_name:setString("圣柱商店")

    QUIWidgetRecycleForGodarmReset.super.init(self)

    self.itemClassName = "QUIWidgetActorDisplay"

    -- 初始化剪影
    QSetDisplayFrameByPath(self._ccbOwner.sp_sketch, QResPath("recycleSketch")[7])
    self._ccbOwner.sp_sketch:setFlipX(true)
    self._ccbOwner.tf_unselect_tips:setString("选择需要重生的神器")
end

function QUIWidgetRecycleForGodarmReset:initExplain()
    QUIWidgetRecycleForGodarmReset.super.initExplain(self)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "100%"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "返还养成的资源与材料，神器"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "变为碎片"},
        }, 680, {autoCenter = true})
    richText:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.node_tf_explain:addChild(richText)
end

function QUIWidgetRecycleForGodarmReset:initMenu()
    QUIWidgetRecycleForGodarmReset.super.initMenu(self)

    self._ccbOwner.node_btn_help:setVisible(true)
    self._ccbOwner.node_btn_store:setVisible(true)
end

function QUIWidgetRecycleForGodarmReset:updateData()
    if self.id then
        self._ccbOwner.node_unselected:setVisible(false)
        self._ccbOwner.node_selected:setVisible(true)
        self._ccbOwner.node_avatar:removeAllChildren()

        if not self.itemClass then
            self.itemClass = import(app.packageRoot .. ".ui.widgets." .. self.itemClassName)
        end

        self.avatar = self.itemClass.new(self.id)
        self.avatar:setScaleX(-0.8)
        self.avatar:setScaleY(0.8)
        self._ccbOwner.node_avatar:addChild(self.avatar:getView())

        -- Show title 
        local characherConfig = db:getCharacterByID(self.id)
        if characherConfig then
            local nameStr = characherConfig.name
            local aptitudeInfo = db:getActorSABC(self.id)
            local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
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

function QUIWidgetRecycleForGodarmReset:updateRecyclePreviewInfo()
    local info = {}
    self.importantKeysList = {"money"}

    if not self.id then return info end
    if not self.info then
        self.info = remote.godarm:getGodarmById(self.id)
    end

    local enhanceExp = db:getGodarmEnhanceTotalExpByLevel(self.info.aptitude, self.info.level) + (self.info.exp or 0)
    local expItems = remote.godarm.EXP_ITEMS

    local returnMaterial = {tonumber(expItems[3]), tonumber(expItems[2]), tonumber(expItems[1])}
    local heightMaterialExp = db:getItemByID(returnMaterial[1]).exp
    local advancedMaterialExp = db:getItemByID(returnMaterial[2]).exp
    local cheapMaterialExp = db:getItemByID(returnMaterial[3]).exp

    local heightMaterial = math.floor(enhanceExp / heightMaterialExp)
    local advancedMaterial = math.floor((enhanceExp % heightMaterialExp) / advancedMaterialExp)
    local cheapMaterial = math.floor(((enhanceExp % heightMaterialExp) % advancedMaterialExp) / cheapMaterialExp)

    if heightMaterial > 0 then
        info[returnMaterial[1]] = (info[returnMaterial[1]] or 0) + heightMaterial
    end
    if advancedMaterial > 0 then
        info[returnMaterial[2]] = (info[returnMaterial[2]] or 0) + advancedMaterial
    end
    if cheapMaterial > 0 then
        info[returnMaterial[3]] = (info[returnMaterial[3]] or 0) + cheapMaterial
    end

    self:_getFragmentPreviewInfo(info)
    self:_getGradePreviewInfo(info)

    return info
end

function QUIWidgetRecycleForGodarmReset:_getFragmentPreviewInfo(info)
    local fragmentCount = 0
    local fragmentId = nil
    for i = 0, self.info.grade, 1 do
        local config = db:getGradeByHeroActorLevel(self.id, i)
        if fragmentId ~= config.soul_gem then
            -- 記錄當前的循環fragmentId，如果不一樣，則保存之前的數據，繼續新的fragmentId循環
            if fragmentId ~= nil then
                if info[fragmentId] then
                    info[fragmentId] = info[fragmentId] + fragmentCount
                elseif fragmentCount > 0 then
                    info[fragmentId] = fragmentCount
                end
                table.insert(self.importantKeysList, 1, fragmentId)
            end
            fragmentId = config.soul_gem
        end
        fragmentCount = fragmentCount + config.soul_gem_count
    end  

    if fragmentId ~= nil then
        if info[fragmentId] then
            info[fragmentId] = info[fragmentId] + fragmentCount
        elseif fragmentCount > 0 then
            info[fragmentId] = fragmentCount
        end
        table.insert(self.importantKeysList, 1, fragmentId)
    end
end
function QUIWidgetRecycleForGodarmReset:_getGradePreviewInfo(info)
    local gradeConfig = db:getGradeByHeroId(self.id)
    local minGrade = db:getCharacterByID(self.id).grade
    for k, v in pairs(gradeConfig) do
        if v.grade_level <= self.info.grade then
            if v.grade_level > minGrade then
                local addValue = v.money or 0
                if info["money"] then
                    info["money"] = info["money"] + addValue
                elseif addValue > 0 then
                    info["money"] = addValue
                end
            end
        end
    end
end


function QUIWidgetRecycleForGodarmReset:onTriggerRecycle()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    if not self.id then
        app.tip:floatTip("请先选择一个需要重生的神器") 
        return
    end

    if self.info.actorId and self.info.actorId ~= 0 then
        app.tip:floatTip("魂师大人，无法重生已装备的神器，请将神器卸下后重生～")
        return
    end

    if remote.user.token < self.price then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end

    local function callRebornAPI(finalRecycleInfo)
        remote.godarm:godarmRebornRequest(self.id, function()
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
        app.tip:floatTip("魂师大人，该神器已经是初始状态，不需要重生了～")
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = finalRecycleInfo, token = self.price, title = "神器重生后将返还以下资源，是否确认分解该神器", callFunc = callRebornAPI}})
end
function QUIWidgetRecycleForGodarmReset:_onTriggerRecycleFinished(finalRecycleInfo)
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
                    options = {compensations = finalRecycleInfo, type = 4, subtitle = "神器重生返还以下资源"}}, {isPopCurrentDialog = false})
                self.id = nil
                self.info = nil
                self:update()
                self.isPlaying = false
            end
        end)
end

function QUIWidgetRecycleForGodarmReset:onTriggerStore()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.godarmShop)
end


function QUIWidgetRecycleForGodarmReset:onTriggerHelp()
    if self.isPlaying then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", options = {type = 22}}, {isPopCurrentDialog = false})
end

function QUIWidgetRecycleForGodarmReset:onTriggerSelect()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    local haveGodarms = remote.godarm:getHaveGodarmList()

    if next(haveGodarms) ~= nil then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmOverView", 
            options = {isReborn = true}})
    else
        app.tip:floatTip("没有可以重生的神器～")
    end
end

return QUIWidgetRecycleForGodarmReset
