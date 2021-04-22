--
-- Kumo.Wang
-- 回收站，单个回收界面——魂骨重生
--
local QUIWidgetRecycleForAlone = import("..widgets.QUIWidgetRecycleForAlone")
local QUIWidgetRecycleForGemReset = class("QUIWidgetRecycleForGemReset", QUIWidgetRecycleForAlone)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QRichText = import("...utils.QRichText")
local QUIDialogGemRecycleSelection = import("..dialogs.QUIDialogGemRecycleSelection")

function QUIWidgetRecycleForGemReset:ctor(options)
	QUIWidgetRecycleForGemReset.super.ctor(self, options)
end

function QUIWidgetRecycleForGemReset:onEnter()
    QUIWidgetRecycleForGemReset.super.onEnter(self)

    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogGemRecycleSelection.GEM_CLICK, self._onItemSelected, self)
end

function QUIWidgetRecycleForGemReset:onExit()
    QUIWidgetRecycleForGemReset.super.onExit(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogGemRecycleSelection.GEM_CLICK, self._onItemSelected, self)
end

function QUIWidgetRecycleForGemReset:_onItemSelected(event)
    if self.isPlaying then return end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()
    if event.gemstone == nil then return end

    self.info = event.gemstone
    self:update()
end

function QUIWidgetRecycleForGemReset:init()
    -- 初始化商店按鈕icon
    local config = remote.items:getWalletByType(ITEM_TYPE.SILVERMINE_MONEY)
    local spf = QSpriteFrameByPath(config.alphaIcon)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 1)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 2)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 4)
    self._ccbOwner.tf_store_name:setString("魂骨商店")

    QUIWidgetRecycleForGemReset.super.init(self)

    self.itemClassName = "QUIWidgetGemstonesBox"
    self.priceKey = "GEMSTONE_RECYCLE"
    
    -- 初始化剪影
    QSetDisplayFrameByPath(self._ccbOwner.sp_sketch, QResPath("recycleSketch")[2])
    self._ccbOwner.sp_sketch:setFlipX(true)
    self._ccbOwner.sp_sketch:setPositionX(self._ccbOwner.sp_sketch:getPositionX() + 10)
    self._ccbOwner.tf_unselect_tips:setString("选择需要重生的魂骨")

    self._tfNamePositionX = self._ccbOwner.tf_name:getPositionX()
end

function QUIWidgetRecycleForGemReset:initExplain()
    QUIWidgetRecycleForGemReset.super.initExplain(self)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "100%"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "返还养成的资源与材料，魂骨"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "变为1级"},
        }, 680, {autoCenter = true})
    richText:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.node_tf_explain:addChild(richText)
end

function QUIWidgetRecycleForGemReset:initMenu()
    QUIWidgetRecycleForGemReset.super.initMenu(self)

    self._ccbOwner.node_btn_help:setVisible(true)
    self._ccbOwner.node_btn_store:setVisible(true)
end

function QUIWidgetRecycleForGemReset:updateData()
    if self.info then
        self._ccbOwner.node_unselected:setVisible(false)
        self._ccbOwner.node_selected:setVisible(true)
        self._ccbOwner.node_avatar:removeAllChildren()

        if not self.itemClass then
            self.itemClass = import(app.packageRoot .. ".ui.widgets." .. self.itemClassName)
        end

        self.avatar = self.itemClass.new()
        self.avatar:setGemstoneInfo(self.info)
        self._ccbOwner.node_avatar:addChild(self.avatar:getView())

        -- Show title 
        local itemConfig = db:getItemByID(self.info.itemId)
        if itemConfig then
            local nameStr = itemConfig.name
            local level, color = remote.herosUtil:getBreakThrough(self.info.craftLevel) 
            local fontColor = UNITY_COLOR_LIGHT[color]
            self._ccbOwner.tf_name:setColor(fontColor)
            setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
            if level > 0 then
                nameStr = nameStr .. "＋".. level
                self._ccbOwner.tf_name:setPositionX(self._tfNamePositionX - 30)
            else
                self._ccbOwner.tf_name:setPositionX(self._tfNamePositionX)
            end
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

function QUIWidgetRecycleForGemReset:updateRecyclePreviewInfo()
    local info = {}
    self.importantKeysList = {"money", "gemstone_energy", "silvermineMoney"}

    if not self.info then return info end

    if self.info.enhanceMoneyConsume > 0 then
        info["money"] = (info["money"] or 0) + self.info.enhanceMoneyConsume
    end
    if self.info.enhanceStoneConsume > 0 then
        info["gemstone_energy"] = (info["gemstone_energy"] or 0) + self.info.enhanceStoneConsume
    end
    local config = db:getGemstoneBreakThrough(self.info.itemId)
    for i = self.info.craftLevel, 1, -1 do
        local id1 = config[i + 1].component_id_1
        local id2 = config[i + 1].component_id_2
        info[id1] = (info[id1] or 0) + config[i + 1].component_num_1
        info[id2] = (info[id2] or 0) + config[i + 1].component_num_2
        info["money"] = (info["money"] or 0) + config[i + 1].price
    end

    if self.info.godLevel and self.info.godLevel > 0 then
        local advancedConfig = db:getGemstoneEvolutionAllPropBygodLevel(self.info.itemId, self.info.godLevel)
        if advancedConfig then
            for _,v in pairs(advancedConfig) do
                if v.evolution_consume_type_1 then
                    local id = v.evolution_consume_type_1
                    info[id] = (info[id] or 0) + (v.evolution_consume_1 or 0)
                end
                if v.evolution_consume_type_2 then
                    local id = v.evolution_consume_type_2
                    info[id] = (info[id] or 0) + (v.evolution_consume_2 or 0)
                end                
            end
        end
    end

    return info
end

function QUIWidgetRecycleForGemReset:onTriggerRecycle()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    if not self.info then
        app.tip:floatTip("请先选择一个需要重生的魂骨") 
        return
    end

    if self.info.actorId and self.info.actorId ~= 0 then
        app.tip:floatTip("魂师大人，无法重生已装备的魂骨，请将魂骨卸下后重生～")
        return
    end

    if remote.user.token < self.price then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end

    local function callRebornAPI(finalRecycleInfo)
        remote.gemstone:gemReborn(self.info.sid, function ()
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
        app.tip:floatTip("魂师大人，该魂骨已经是初始状态，不需要重生了～")
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = finalRecycleInfo, token = self.price, title = "魂骨重生后将返还以下资源，是否确认分解该魂骨", callFunc = callRebornAPI}})
end
function QUIWidgetRecycleForGemReset:_onTriggerRecycleFinished(finalRecycleInfo)
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
                    options = {compensations = finalRecycleInfo, type = 4, subtitle = "魂骨重生返还以下资源"}}, {isPopCurrentDialog = false})
                self.id = nil
                self.info = nil
                self:update()
                self.isPlaying = false
            end
        end)
end

function QUIWidgetRecycleForGemReset:onTriggerStore()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.silverShop)
end

function QUIWidgetRecycleForGemReset:onTriggerHelp()
    if self.isPlaying then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", options = {type = 8}}, {isPopCurrentDialog = false})
end

function QUIWidgetRecycleForGemReset:onTriggerSelect()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemRecycleSelection", options = {type = 2}}, {isPopCurrentDialog = false})
end

return QUIWidgetRecycleForGemReset
