
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogInvasionEncounter = class("QUIDialogInvasionEncounter", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QRichText = import("...utils.QRichText")

function QUIDialogInvasionEncounter:ctor(options)
    local ccbFile = "ccb/Dialog_Panjun_yaosai.ccbi"
	local callBacks = {
                    {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogInvasionEncounter._onTriggerCancel)}, 
                    {ccbCallbackName = "onTriggerFight", callback = handler(self, QUIDialogInvasionEncounter._onTriggerFight)},
	}
    QUIDialogInvasionEncounter.super.ctor(self, ccbFile, callBacks, options)

    remote.invasion:getInvasionRequest(self:safeHandler(function ( ... )
        self:setInfo(options)
    end))
end

function QUIDialogInvasionEncounter:viewDidAppear()
    QUIDialogInvasionEncounter.super.viewDidAppear(self)
end

function QUIDialogInvasionEncounter:viewWillDisappear()
    QUIDialogInvasionEncounter.super.viewWillDisappear(self)
end

function QUIDialogInvasionEncounter:setInfo(options)
    -- Display boss character
    local avatar = QUIWidgetHeroInformation.new()
    avatar:setAvatar(options.actorId, 1)
    self._ccbOwner.avatar:addChild(avatar)
    avatar:setBackgroundVisible(false)
    avatar:setNameVisible(false)
    avatar:setStarVisible(false)

    local invasion = remote.invasion:getSelfInvasion()
    -- local prefix = "优秀"
    
    local bossColor = remote.invasion:getBossColorByType(invasion.boss_type)

    local shadowColor = getShadowColorByFontColor(bossColor)

    local character = QStaticDatabase:sharedDatabase():getCharacterByID(options.actorId)
    local data = QStaticDatabase:sharedDatabase():getCharacterDataByID(options.actorId, options.level)
    if self._txtnode ~= nil then
        self._txtnode:removeFromParent()
        self._txtnode = nil
    end
    self._txtnode = QRichText.new({
            {oType = "font", content = "魂师大人，发现", size = 24, color = ccc3(255, 225, 209)},
            {oType = "font", content = string.format(" LV.%d %s ", options.level, character.name) ,shadowColor = shadowColor, shadowOffset = 2, size = 24, color = bossColor},
            {oType = "font", content = "入侵，是否前往攻打", size = 24, color = ccc3(255, 225, 209)},
        },370)
    -- local text = QColorLabel:create(string.format("魂师大人，发现%s%s的LV.%d %s##d入侵，是否前往攻打", bossText, prefix, options.level, character.name), 360, 70, nil, nil, ccc3(65, 17, 5))
    self._txtnode:setPositionY(-40)
    self._ccbOwner.text:addChild(self._txtnode)
    self._ccbOwner.boss_name:setString(character.name)
    
end

function QUIDialogInvasionEncounter:_onTriggerFight(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_go) == false then return end
    if e ~= nil then app.sound:playSound("common_confirm") end
    if self:getOptions().fightCallback then
        self:getOptions().fightCallback()
    end

    -- scheduler.performWithDelayGlobal(function ( ... )
        if self:getOptions().inbattle then
            app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasion", 
                options = {}})
        else
            -- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            self:popSelf()
            app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
            if self:getOptions().isTeamUp == true then
                app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
            end
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasion", 
                options = {}})
        end
    -- end, 0)
end

function QUIDialogInvasionEncounter:_onTriggerCancel(e)
     if q.buttonEventShadow(e, self._ccbOwner.btn_one) == false then return end
    if e ~= nil then app.sound:playSound("common_cancel") end
    if self:getOptions().cancelCallback then
        self:getOptions().cancelCallback()
    end

    if self:getOptions().inbattle then
        app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
    else
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    end
end


return QUIDialogInvasionEncounter



