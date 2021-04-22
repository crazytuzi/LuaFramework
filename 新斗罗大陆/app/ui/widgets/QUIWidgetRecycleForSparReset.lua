--
-- Kumo.Wang
-- 回收站，单个回收界面——外附魂骨重生
--
local QUIWidgetRecycleForAlone = import("..widgets.QUIWidgetRecycleForAlone")
local QUIWidgetRecycleForSparReset = class("QUIWidgetRecycleForSparReset", QUIWidgetRecycleForAlone)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QRichText = import("...utils.QRichText")
local QUIDialogSparRecycleSelection = import("..dialogs.QUIDialogSparRecycleSelection")

function QUIWidgetRecycleForSparReset:ctor(options)
	QUIWidgetRecycleForSparReset.super.ctor(self, options)
end

function QUIWidgetRecycleForSparReset:onEnter()
    QUIWidgetRecycleForSparReset.super.onEnter(self)

    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogSparRecycleSelection.SPAR_CLICK, self._onItemSelected, self)
end

function QUIWidgetRecycleForSparReset:onExit()
    QUIWidgetRecycleForSparReset.super.onExit(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogSparRecycleSelection.SPAR_CLICK, self._onItemSelected, self)
end

function QUIWidgetRecycleForSparReset:_onItemSelected(event)
    if self.isPlaying then return end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()
    if event.sparInfo == nil then return end

    self.info = event.sparInfo
    self:update()
end

function QUIWidgetRecycleForSparReset:init()
    -- 初始化商店按鈕icon
    local config = remote.items:getWalletByType(ITEM_TYPE.JEWELRY_MONEY)
    local spf = QSpriteFrameByPath(config.alphaIcon)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 1)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 2)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 4)
    self._ccbOwner.tf_store_name:setString("地狱商店")

    QUIWidgetRecycleForSparReset.super.init(self)

    self.itemClassName = "QUIWidgetSparBox"

    -- 初始化剪影
    QSetDisplayFrameByPath(self._ccbOwner.sp_sketch, QResPath("recycleSketch")[4])
    self._ccbOwner.sp_sketch:setPositionX(self._ccbOwner.sp_sketch:getPositionX() + 3)
    self._ccbOwner.tf_unselect_tips:setString("选择需要重生的外附魂骨")
end

function QUIWidgetRecycleForSparReset:initExplain()
    QUIWidgetRecycleForSparReset.super.initExplain(self)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "100%"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "返还养成的资源与材料，外附魂骨"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "变为最低星"},
        }, 680, {autoCenter = true})
    richText:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.node_tf_explain:addChild(richText)
end

function QUIWidgetRecycleForSparReset:initMenu()
    QUIWidgetRecycleForSparReset.super.initMenu(self)

    self._ccbOwner.node_btn_help:setVisible(true)
    self._ccbOwner.node_btn_store:setVisible(true)
end

function QUIWidgetRecycleForSparReset:updateData()
    if self.info then
        self._ccbOwner.node_unselected:setVisible(false)
        self._ccbOwner.node_selected:setVisible(true)
        self._ccbOwner.node_avatar:removeAllChildren()

        if not self.itemClass then
            self.itemClass = import(app.packageRoot .. ".ui.widgets." .. self.itemClassName)
        end

        self.avatar = self.itemClass.new()
        self.avatar:setGemstoneInfo(self.info)
        self.avatar:setNameVisible(false)
        self._ccbOwner.node_avatar:addChild(self.avatar:getView())

        -- Show title 
        local itemConfig = db:getItemByID(self.info.itemId)
        if itemConfig then
            local nameStr = itemConfig.name
            local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]]
            self._ccbOwner.tf_name:setColor(fontColor)
            setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
            self._ccbOwner.tf_name:setString(nameStr)
            self._ccbOwner.node_name_info:setVisible(true)
        end

        -- Show animation of stone
        local actions = CCArray:create()
        actions:addObject(CCMoveTo:create(1, CCPoint(self.avatar:getPositionX(), self.avatar:getPositionY() - 5)))
        actions:addObject(CCMoveTo:create(1, CCPoint(self.avatar:getPositionX(), self.avatar:getPositionY() + 5)))
        self._avatarAction = self.avatar:runAction(CCRepeatForever:create(CCSequence:create(actions)))
    else
        self._ccbOwner.node_unselected:setVisible(true)
        self._ccbOwner.node_selected:setVisible(false)
    end
end

function QUIWidgetRecycleForSparReset:updateRecyclePreviewInfo()
    local info = {}
    self.importantKeysList = {"money", "jewelryMoney"}

    if not self.info then return info end

    -- 回收暗器
    self:_getFragmentPreviewInfo(info)
    -- 回收強化
    self:_getBreakthroughPreviewInfo(info)

    return info
end

function QUIWidgetRecycleForSparReset:_getFragmentPreviewInfo(info)
    local fragmentCount = 0
    local fragmentId = nil
    for i = 1, self.info.grade, 1 do
        local config = db:getGradeByHeroActorLevel(self.info.itemId, i)
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

        local addValue = config.money or 0
        if info["money"] then
            info["money"] = info["money"] + addValue
        elseif addValue > 0 then
            info["money"] = addValue
        end
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
function QUIWidgetRecycleForSparReset:_getBreakthroughPreviewInfo(info)
    local sparInfo, index = remote.spar:getSparsIndexBySparId(self.info.sparId)
    local returnMaterial = {10000009, 10000008, 10000007} -- It is hardcoded to return material
    if self.info.level > 1 or self.info.exp > 0 then
        local exp = (self.info.exp or 0) + db:getJewelryStrengthenTotalExpByLevel(self.info.level, index, "jewelry_exp")
        local heightMaterialExp = db:getItemByID(returnMaterial[1])
        local advancedMaterialExp = db:getItemByID(returnMaterial[2])
        local cheapMaterialExp = db:getItemByID(returnMaterial[3])
        heightMaterialExp = string.split(heightMaterialExp.exp_num, "^")
        advancedMaterialExp = string.split(advancedMaterialExp.exp_num, "^")
        cheapMaterialExp = string.split(cheapMaterialExp.exp_num, "^")
        heightMaterialExp = tonumber(heightMaterialExp[2]) or 0
        advancedMaterialExp = tonumber(advancedMaterialExp[2]) or 0
        cheapMaterialExp = tonumber(cheapMaterialExp[2]) or 0

        local heightMaterial = math.floor(exp / heightMaterialExp)
        local advancedMaterial = math.floor(exp % heightMaterialExp / advancedMaterialExp)
        local cheapMaterial = math.floor(exp % heightMaterialExp % advancedMaterialExp / cheapMaterialExp)

        if heightMaterial > 0 then
            info[returnMaterial[1]] = (info[returnMaterial[1]] or 0) + heightMaterial
        end
        if advancedMaterial > 0 then
            info[returnMaterial[2]] = (info[returnMaterial[2]] or 0) + advancedMaterial
        end
        if cheapMaterial > 0 then
            info[returnMaterial[3]] = (info[returnMaterial[3]] or 0) + cheapMaterial
        end
    end
end

function QUIWidgetRecycleForSparReset:onTriggerRecycle()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    if not self.info then
        app.tip:floatTip("请先选择一个需要重生的外附魂骨") 
        return
    end

    if self.info.actorId and self.info.actorId ~= 0 then
        app.tip:floatTip("魂师大人，无法重生已装备的外附魂骨，请将外附魂骨卸下后重生～")
        return
    end

    if remote.user.token < self.price then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end
    
    local function callRebornAPI(finalRecycleInfo)
        remote.spar:requestSparReCover({ {returnSparInfo = {sparId = self.info.sparId, count = self.info.count}, count = 1} }, function ()
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
        app.tip:floatTip("魂师大人，该外附魂骨已经是初始状态，不需要重生了～")
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = finalRecycleInfo, token = self.price, title = "外附魂骨重生后将返还以下资源，是否确认分解该外附魂骨", callFunc = callRebornAPI}})
end
function QUIWidgetRecycleForSparReset:_onTriggerRecycleFinished(finalRecycleInfo)
    self.isPlaying = true
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(effect)
    effect:playAnimation("effects/HeroRecoverEffect_up.ccbi", function()
            if self._ccbView then
                self.avatar:stopAction(self._avatarAction)
                effect._ccbOwner.node_avatar:setVisible(false)
            end
        end, function()
            if self._ccbView then
                effect:removeFromParentAndCleanup(true)
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                    options = {compensations = finalRecycleInfo, type = 4, subtitle = "外附魂骨重生返还以下资源"}}, {isPopCurrentDialog = false})
                self.id = nil
                self.info = nil
                self:update()
                self.isPlaying = false
            end
        end)
end

function QUIWidgetRecycleForSparReset:onTriggerStore()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.sparShop)
end

function QUIWidgetRecycleForSparReset:onTriggerHelp()
    if self.isPlaying then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", options = {type = 16}}, {isPopCurrentDialog = false})
end

function QUIWidgetRecycleForSparReset:onTriggerSelect()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSparRecycleSelection", options = {type = 2}}, {isPopCurrentDialog = false})
end

return QUIWidgetRecycleForSparReset
