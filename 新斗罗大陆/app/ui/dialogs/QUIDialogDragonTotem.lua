local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogDragonTotem = class("QUIDialogDragonTotem", QUIDialogBaseUnion)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetDragonTotem = import("..widgets.totem.QUIWidgetDragonTotem")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogDragonTotem:ctor(options)
	local ccbFile = "ccb/Dialog_Weever.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
        {ccbCallbackName = "onTriggerQuickUpgrade", callback = handler(self, self._onTriggerQuickUpgrade)},
        {ccbCallbackName = "onTriggerProp", callback = handler(self, self._onTriggerProp)},        
	}
	QUIDialogDragonTotem.super.ctor(self,ccbFile,callBacks,options)

    CalculateUIBgSize(self._ccbOwner.sp_background)

    self._page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._page.topBar:showWithStyle({ITEM_TYPE.MONEY, TOP_BAR_TYPE.DRAGON_STONE, TOP_BAR_TYPE.DRAGON_SOUL, ITEM_TYPE.BATTLE_FORCE})
    self:setSocietyNameVisible(false)

    self:updateInfo()

    self:checkTutorial()
end

function QUIDialogDragonTotem:checkTutorial()
    if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        if page and page.class.__cname == "QUIPageMainMenu" then
            page:buildLayer()
            local haveTutorial = false
            if app.tutorial:getStage().dragonTotem == app.tutorial.Guide_Start then
                local maxTotemLevel = remote.dragonTotem:getMaxTotemLevel()
                if maxTotemLevel > 1 then
                    app.tutorial:getStage().dragonTotem = 1
                else
                    haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_DragonTotem)
                end
            end
            if haveTutorial == false then
                page:cleanBuildLayer()
            end
        end
    end
end

function QUIDialogDragonTotem:updateInfo()
    if self.totems == nil then self.totems = {} end
    for i=1,6 do
        if self.totems[i] == nil then
            self.totems[i] = QUIWidgetDragonTotem.new()
            self.totems[i]:addEventListener(QUIWidgetDragonTotem.EVENT_CLICK,handler(self, self._totemClickHandler))
            self._ccbOwner["node"..i]:addChild(self.totems[i])
        end
        self.totems[i]:setIndex(i)
    end

    local dragonInfo = remote.dragon:getDragonInfo()
    local _dragonId = dragonInfo and dragonInfo.dragonId or 1
    if self._dragonId ~= _dragonId then
        self._dragonId = _dragonId
        self._ccbOwner.node_avatar:removeAllChildren()
        local fca, name, dragonConfig = remote.dragonTotem:getDragonAvatarFcaAndNameByDragonId(_dragonId)
        if fca then
            local avatar = QUIWidgetFcaAnimation.new(fca, "actor", {backSoulShowEffect = dragonConfig.effect})
            avatar:setScaleX(-global.dragon_spine_scale)
            avatar:setScaleY(global.dragon_spine_scale)
            avatar:setPositionY(global.dragon_spine_offsetY)
            self._ccbOwner.node_avatar:addChild(avatar)
        end
        self._ccbOwner.tf_name:setString(name)
    end

    local totemInfo = remote.dragonTotem:getTotemInfo()
    local gradeLevel = 1
    if totemInfo ~= nil then
        gradeLevel = totemInfo.grade or 1
    end
    self._ccbOwner.tf_level:setString("Lv."..gradeLevel)
    -- local config = remote.dragonTotem:getConfigByIdAndLevel(7, gradeLevel)
    -- self._ccbOwner.tf_desc:setString(self:getSkillStr(config))
    self:checkTips()
end

-- function QUIDialogDragonTotem:getSkillStr(config)
--     local skillId = config.skill_id
--     if skillId ~= nil then
--         local skillData = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillId, config.level)
--         return skillData.description_1 or ""
--     end
-- end

function QUIDialogDragonTotem:checkTips()
    local canUpgrade = remote.dragonTotem:checkTotemTipsById(remote.dragonTotem.TOTEM_TYPE)
    self._ccbOwner.node_tip:setVisible(false)
    self._ccbOwner.sp_tips:setVisible(canUpgrade)

    --设置一键升级状态
    local upgradeTip = false
    for i = 1, 6 do
        if remote.dragonTotem:checkTotemTipsById(i) then
            upgradeTip = true
            break
        end
    end
    self._ccbOwner.node_quickUpgrade_tip:setVisible(upgradeTip)
    if upgradeTip then
        makeNodeFromGrayToNormal(self._ccbOwner.node_auto_find)
        self._ccbOwner.btn_quick_upgrade:setEnabled(true)
        self._ccbOwner.tf_btn_quick_upgrade:enableOutline()
    else
        makeNodeFromNormalToGray(self._ccbOwner.node_auto_find)
        self._ccbOwner.btn_quick_upgrade:setEnabled(false)
        self._ccbOwner.tf_btn_quick_upgrade:disableOutline()
    end
end

function QUIDialogDragonTotem:viewDidAppear()
    QUIDialogDragonTotem.super.viewDidAppear(self)
    self._itemProxy = cc.EventProxy.new(remote.items)
    self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.checkTips))

    self._totem = cc.EventProxy.new(remote.dragonTotem)
    self._totem:addEventListener(remote.dragonTotem.EVENT_TOTEM_UPDATE, handler(self, self._totemUpdateHandler))

    self._userProxy = cc.EventProxy.new(remote.user)
    self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self._totemUpdateHandler))
end

function QUIDialogDragonTotem:viewWillDisappear()
    QUIDialogDragonTotem.super.viewWillDisappear(self)
    self._itemProxy:removeAllEventListeners()
    self._totem:removeAllEventListeners()
    self._userProxy:removeAllEventListeners()
end

--点击中间的图腾
function QUIDialogDragonTotem:_onTriggerClick(event)
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDragonTotemUpgrade", options={index = 7}})
end

--一键升级
function QUIDialogDragonTotem:_onTriggerQuickUpgrade(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_quick_upgrade) == false then return end
    app.sound:playSound("common_small")

    local oldTotemInfo = {}
    for i = 1, 6 do
        local info = remote.dragonTotem:getDragonInfoById(i)
        oldTotemInfo[i] = clone(info)
    end

    remote.dragonTotem:consortiaDragonDesignQuickImproveRequest(function ()
        if self:safeCheck() then
            self:updateInfo()

            self:showTotemUpgradeEffect(oldTotemInfo)
        end
    end)
end

function QUIDialogDragonTotem:showTotemUpgradeEffect(oldTotemInfo)
    local effectList = {}
    for i = 1, 6 do
        local info = remote.dragonTotem:getDragonInfoById(i)
        if oldTotemInfo[i] then
            local addLevel = (info.grade or 1) - (oldTotemInfo[i].grade or 1)
            if addLevel > 0 then
                effectList[#effectList+1] = {addLevel = addLevel, index = i, level = (info.grade or 1)}
            end
        end
    end

    local showEffectFunc
    showEffectFunc = function ()
        local totemInfo = effectList[1]
        table.remove(effectList, 1)

        if self._effect == nil then
            self._effect =  QUIWidgetAnimationPlayer.new()
            self._effect:setPosition(0, 70)
            self:getView():addChild(self._effect)
        else
            self._effect:setVisible(true)
        end
        self._effect:playAnimation("ccb/effects/SkillUpgarde2.ccbi", function (ccbOwner)
            local config = remote.dragonTotem:getConfigByIdAndLevel(totemInfo.index, totemInfo.level)
            ccbOwner.title_skill:setString(config.name_dragon_stone.." 等级＋"..totemInfo.addLevel)
            local currentDesc = remote.dragonTotem:getPropStr(config)
            ccbOwner.tf_desc1:setString(currentDesc)
        end, function ()
            if q.isEmpty(effectList) == false then
                showEffectFunc()
            end
        end,false)
    end

    if q.isEmpty(effectList) == false then
        showEffectFunc()
    end
end

--打开属性
function QUIDialogDragonTotem:_onTriggerProp()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDragonTotemProp"})
end

--更新图腾
function QUIDialogDragonTotem:_totemUpdateHandler()
    self:updateInfo()
end

--点击图腾
function QUIDialogDragonTotem:_totemClickHandler(event)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDragonTotemUpgrade", options={index = event.index}})
end

function QUIDialogDragonTotem:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogDragonTotem:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogDragonTotem