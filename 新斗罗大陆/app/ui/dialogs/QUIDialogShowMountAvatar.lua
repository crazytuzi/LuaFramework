--
-- Author: wkwang
-- Date: 2014-08-07 12:34:26
--
local QUIDialog = import(".QUIDialog")
local QUIDialogShowMountAvatar = class("QUIDialogShowMountAvatar", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogHeroOverview = import(".QUIDialogHeroOverview")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QUIDialogPreview = import("..dialogs.QUIDialogPreview")
local QUIWidgetHeroSkillCell = import("..widgets.QUIWidgetHeroSkillCell")

function QUIDialogShowMountAvatar:ctor(options)
	local ccbFile = "ccb/Dialog_AchieveHero.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerHeroOverView", callback = handler(self, QUIDialogShowMountAvatar._onTriggerHeroOverView)},
        {ccbCallbackName = "onTriggerClickSkillButton", callback = handler(self, self._onTriggerClickSkillButton)}
    }
    QUIDialogShowMountAvatar.super.ctor(self, ccbFile, callBacks, options)

    self._ccbOwner.node_title_silver:setVisible(false)
    self._ccbOwner.node_title_normal:setVisible(false)
    self._ccbOwner.node_title_gold:setVisible(false)
    self._ccbOwner.node_buy:setVisible(false)
    self._ccbOwner.node_money:setVisible(false)
    self._ccbOwner.node_tokenMoney:setVisible(false)
    self._ccbOwner.node_next_tips:setVisible(false)
    self._ccbOwner.bule_light:setVisible(false)
    self._ccbOwner.orange_light:setVisible(false)
    self._ccbOwner.purple_light:setVisible(false)

    self._canCloseDialog = false

    if options.tokenType == ITEM_TYPE.TOKEN_MONEY then
        self._ccbOwner.node_title_silver:setVisible(true)
    elseif options.tokenType == ITEM_TYPE.MONEY then
        self._ccbOwner.node_title_normal:setVisible(true)
    else
        self._ccbOwner.node_title_gold:setVisible(true)
    end
   
    self._information = QUIWidgetHeroInformation.new({actorId = options.actorId})
    self._information:setBackgroundVisible(false)
    self._ccbOwner.node_hero:addChild(self._information:getView())   
    self._information:setAvatarPositionOffset(-5, 30)
    self._information:setStarPositionOffset(0, -30)
    self._information:setProfessionPositionOffset(-175, 0)
    self._information:setNameVisible(false)
    -- self._information:setProPositionOffset(0, -30)
    local characherConfig = QStaticDatabase:sharedDatabase():getCharacterByID(options.actorId)
    if characherConfig ~= nil then
        self._information:setAvatar(options.actorId, 1.25)
        -- self._information:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY, true)
    end
    local heroDisplay = QStaticDatabase:sharedDatabase():getCharacterByID(options.actorId)
    local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(options.actorId)
    if heroInfo ~= nil then
        if heroInfo.colour == 3 then
            self._ccbOwner.bule_light:setVisible(true)
        elseif heroInfo.colour == 4 then
            self._ccbOwner.purple_light:setVisible(true)
        elseif heroInfo.colour == 5 then
            self._ccbOwner.orange_light:setVisible(true)
        end

        -- Show SABC
        local sabc = heroInfo.aptitude
        if sabc then
            self._information:setSabcPosition(250, 40)
            self._information:setSabcVisible(true)
            self._information._ccbOwner.node_sabc:setVisible(false)
            self._information:setSabcValue(sabc)
            scheduler.performWithDelayGlobal(self:safeHandler(function()
                self._information:setSabcVisible(true, true, sabc)
            end), 1)
            -- self._information:setSabcVisible(true, true, sabc)
            self._information:setStarVisible(false)
        else
            self._information:setSabcVisible(false)
            self._information:setStarVisible(true)
        end

        -- show hero genre
        -- self._ccbOwner.tf_genre_name:setString("类型：")
        -- self._ccbOwner.tf_genre:setString(heroInfo.label)
        self._ccbOwner.tf_genre_name:setString("")
        self._ccbOwner.tf_genre:setString("")

        -- hero quality
        local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(options.actorId)
        self._ccbOwner.hero_name:setString(heroInfo.name)
        self._ccbOwner.hero_name:setColor(UNITY_COLOR_LIGHT[aptitudeInfo.color])
    end
    self._actorId = options.actorId
    self.callBack = options.callBack
    self._popAvatar = options.popAvatar

    if self:getOptions().isHavePast == nil then
        self._isHavePast = remote.herosUtil:checkHeroHavePast(self._actorId, true)
        self:getOptions().isHavePast = self._isHavePast
    else
        self._isHavePast = self:getOptions().isHavePast
    end

    self:setHeroInfo()

    self._scheduler = scheduler.performWithDelayGlobal(function()
            self._canCloseDialog = true
        end, 1)
end


function QUIDialogShowMountAvatar:setHeroInfo()
    local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
    self._ccbOwner.hero_dec:setString(heroInfo.brief or "")

    local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._actorId, 0)
    if gradeConfig ~= nil then
        local skillIds = string.split(gradeConfig.zuoqi_skill_ms, ";")
        self._skillId = tonumber(skillIds[1])
        self._skillInfo = QStaticDatabase:sharedDatabase():getSkillByID(self._skillId)
        self._ccbOwner.skill_name:setString(self._skillInfo.name or "")
        self:setIconPath(self._skillInfo.icon)
    end
end 

function QUIDialogShowMountAvatar:setIconPath(path)
    if self._skillIcon == nil then
            self._skillIcon = CCSprite:create()
            self._ccbOwner.node_icon:addChild(self._skillIcon)
        end
    self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogShowMountAvatar:viewDidAppear()
    QUIDialogShowMountAvatar.super.viewDidAppear(self)

end

function QUIDialogShowMountAvatar:viewWillDisappear()
    QUIDialogShowMountAvatar.super.viewWillDisappear(self)
    if self._scheduler ~= nil then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
end

function QUIDialogShowMountAvatar:_onTriggerClickSkillButton(event)
    -- local slot = {slotLevel = 1, slotId = 3}
    app.tip:skillTip(self._skillId, 1, true)
end

function QUIDialogShowMountAvatar:_onTriggerHeroOverView()
    if self._popAvatar then 
        app:getNavigationManager():popViewController(self:getOptions().layerIndex, QNavigationController.POP_TOP_CONTROLLER)
    end
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPreview", 
        options = {tavernType = QUIDialogPreview.GENERAL_TAVERN, genreType = self._genreIndex}},{isPopCurrentDialog = false})
end

function QUIDialogShowMountAvatar:_backClickHandler(options)
    if self._canCloseDialog == false then return end

    local actorId = self._actorId
    local callback = self.callBack
    app:getNavigationManager():popViewController(self:getOptions().layerIndex, QNavigationController.POP_TOP_CONTROLLER)

    if self._isHavePast == false then
        app.tip:assistSkillTip(actorId, callback)
    else
        if callback then
            callback()
        end
    end
end

return QUIDialogShowMountAvatar