--
-- Kumo.Wang
-- 回收站，单个回收界面——仙品重生
--
local QUIWidgetRecycleForAlone = import("..widgets.QUIWidgetRecycleForAlone")
local QUIWidgetRecycleForMagicHerbReset = class("QUIWidgetRecycleForMagicHerbReset", QUIWidgetRecycleForAlone)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QRichText = import("...utils.QRichText")

function QUIWidgetRecycleForMagicHerbReset:ctor(options)
	QUIWidgetRecycleForMagicHerbReset.super.ctor(self, options)
end

function QUIWidgetRecycleForMagicHerbReset:onEnter()
    QUIWidgetRecycleForMagicHerbReset.super.onEnter(self)

    self._magicHerbProxy = cc.EventProxy.new(remote.magicHerb)
    self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_SELECTED_MAGIC_HERB, handler(self, self._onItemSelected))
end

function QUIWidgetRecycleForMagicHerbReset:onExit()
    QUIWidgetRecycleForMagicHerbReset.super.onExit(self)

    self._magicHerbProxy:removeAllEventListeners()
end

function QUIWidgetRecycleForMagicHerbReset:_onItemSelected(event)
    if self.isPlaying then return end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()
    if event.magicHerbInfo == nil then return end

    self.info = event.magicHerbInfo
    self:update()
end

function QUIWidgetRecycleForMagicHerbReset:init()
    QUIWidgetRecycleForMagicHerbReset.super.init(self)

    self.itemClassName = "QUIWidgetMagicHerbEffectBox"

    -- 初始化剪影
    QSetDisplayFrameByPath(self._ccbOwner.sp_sketch, QResPath("recycleSketch")[5])
    self._ccbOwner.sp_sketch:setPositionX(self._ccbOwner.sp_sketch:getPositionX() - 10)
    self._ccbOwner.tf_unselect_tips:setString("选择需要重生的仙品")
end

function QUIWidgetRecycleForMagicHerbReset:initExplain()
    QUIWidgetRecycleForMagicHerbReset.super.initExplain(self)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "返还仙品经验值，仙品重生为"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "1级"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "，不重置附加属性"},
        }, 680, {autoCenter = true})
    richText:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.node_tf_explain:addChild(richText)
end

function QUIWidgetRecycleForMagicHerbReset:initMenu()
    QUIWidgetRecycleForMagicHerbReset.super.initMenu(self)

    self._ccbOwner.node_btn_help:setVisible(true)
end

function QUIWidgetRecycleForMagicHerbReset:updateData()
    if self.info then
        self._ccbOwner.node_unselected:setVisible(false)
        self._ccbOwner.node_selected:setVisible(true)
        self._ccbOwner.node_avatar:removeAllChildren()

        if not self.itemClass then
            self.itemClass = import(app.packageRoot .. ".ui.widgets." .. self.itemClassName)
        end

        self.avatar = self.itemClass.new()
        self.avatar:setInfo(self.info.sid, true)
        self.avatar:hideName()
        self._ccbOwner.node_avatar:addChild(self.avatar:getView())

        -- Show title 
        local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self.info.sid)
        local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)
        local itemConfig = db:getItemByID(magicHerbItemInfo.itemId)
        if magicHerbItemInfo and magicHerbConfig then
            local nameStr = magicHerbConfig.name
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
        self._avatarAction = self.avatar:getNodeIcon():runAction(CCRepeatForever:create(CCSequence:create(actions)))
    else
        self._ccbOwner.node_unselected:setVisible(true)
        self._ccbOwner.node_selected:setVisible(false)
    end
end

function QUIWidgetRecycleForMagicHerbReset:updateRecyclePreviewInfo()
    local info = {}
    self.importantKeysList = {}

    if not self.info then return info end

    -- 升星
    local gradeItemNum, gradeItemId = self:_getGradePreviewInfo()
    -- 升級
    local uplevelItemNum, uplevelItemId = self:_getLevelPreviewInfo()
    -- 轉生
    local refineItemNum, refineItemId = self:_getRefinePreviewInfo()

    local insertFunc = function(id, num)
        if info[id] == nil then
            info[id] = num
        else
            info[id] = info[id] + num
        end
    end
    insertFunc(gradeItemId, gradeItemNum)
    insertFunc(uplevelItemId, uplevelItemNum)
    insertFunc(refineItemId, refineItemNum)

    return info
end

function QUIWidgetRecycleForMagicHerbReset:_getGradePreviewInfo()
    local sid = self.info.sid
    local gradeItemNum = 0
    local gradeItemId = 17100039
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
    local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)
    if magicHerbItemInfo then
        local magicHerbGradeConfigs = db:getStaticByName("magic_herb_grade")
        local configList = magicHerbGradeConfigs[tostring(magicHerbItemInfo.id)] or {}
        for _, value in ipairs(configList) do
            if value.grade <= self.info.grade and value.consum_num then
                gradeItemNum = gradeItemNum + value.consum_num
            end
        end

        local wildConfig = remote.magicHerb:getWildMagicHerbByAptitude(magicHerbConfig.aptitude)
        if wildConfig then
            gradeItemId = wildConfig.id
        end
    end

    return gradeItemNum, gradeItemId
end
function QUIWidgetRecycleForMagicHerbReset:_getLevelPreviewInfo()
    local sid = self.info.sid
    local upLevelItemId = 0
    local upLevelItemNum = 0
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
    if magicHerbItemInfo then
        local magicHerbEnchantConfigs = db:getStaticByName("magic_herb_enhance")
        local configList = magicHerbEnchantConfigs[tostring(magicHerbItemInfo.id)] or {}
        
        for _, value in ipairs(configList) do
            if value.level <= self.info.level and value.consum then
                local tbl = string.split(value.consum, "^")
                if upLevelItemId == 0 then
                    upLevelItemId = tonumber(tbl[1])
                end
                upLevelItemNum = upLevelItemNum + tonumber(tbl[2])
            end
        end
    end

    return upLevelItemNum, upLevelItemId
end
function QUIWidgetRecycleForMagicHerbReset:_getRefinePreviewInfo()
    local sid = self.info.sid
    local refineItemId = 0
    local refineItemNum = 0
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
    local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)

    if magicHerbItemInfo then
        refineItemId = remote.magicHerb:getRefineItemIdAndPriceByAptitude( magicHerbConfig.aptitude )
        refineItemNum = math.floor((magicHerbItemInfo.extendsAttributesRefineConsume or 0) * 0.3)
    end

    return refineItemNum, refineItemId
end

function QUIWidgetRecycleForMagicHerbReset:onTriggerRecycle()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    if not self.info then
        app.tip:floatTip("请先选择一个需要重生的仙品") 
        return
    end

    if self.info.actorId and self.info.actorId ~= 0 then
        app.tip:floatTip("魂师大人，无法重生已装备的仙品，请将仙品卸下后重生～")
        return
    end

    if remote.user.token < self.price then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end

    local function callRebornAPI(finalRecycleInfo)
        remote.magicHerb:magicHerbReturnRequest(self.info.sid, function()
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
        app.tip:floatTip("魂师大人，该仙品已经是初始状态，不需要重生了～")
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = finalRecycleInfo, token = self.price, title = "仙品重生后将返还以下资源，是否确认分解该仙品", callFunc = callRebornAPI}})
end
function QUIWidgetRecycleForMagicHerbReset:_onTriggerRecycleFinished(finalRecycleInfo)
    self.isPlaying = true
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(effect)
    effect:playAnimation("effects/HeroRecoverEffect_up.ccbi", function()
            if self._ccbView then
                self.avatar:getNodeIcon():stopAction(self._avatarAction)
                effect._ccbOwner.node_avatar:setVisible(false)
            end
        end, function()
            if self._ccbView then
                effect:removeFromParentAndCleanup(true)
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                    options = {compensations = finalRecycleInfo, type = 4, subtitle = "仙品重生返还以下资源"}}, {isPopCurrentDialog = false})
                self.id = nil
                self.info = nil
                self:update()
                self.isPlaying = false
            end
        end)
end

function QUIWidgetRecycleForMagicHerbReset:onTriggerHelp()
    if self.isPlaying then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", options = {type = 17}}, {isPopCurrentDialog = false})
end

function QUIWidgetRecycleForMagicHerbReset:onTriggerSelect()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    local hasMagicHerb = false
    local magicHerbItemList = remote.magicHerb:getMagicHerbItemList()
    for _, magicHerbItem in ipairs(magicHerbItemList) do
        if (not magicHerbItem.magicHerbInfo.actorId or magicHerbItem.magicHerbInfo.actorId == 0)
         and (magicHerbItem.magicHerbInfo.level > 1 or magicHerbItem.magicHerbInfo.grade > 1) then
            hasMagicHerb = true
            break
        end
    end
    if hasMagicHerb then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbCheckroom", 
            options = {isReborn = true, rebornType = 2}})
    else
        app.tip:floatTip("没有可以重生的仙品~")
    end
end

return QUIWidgetRecycleForMagicHerbReset
