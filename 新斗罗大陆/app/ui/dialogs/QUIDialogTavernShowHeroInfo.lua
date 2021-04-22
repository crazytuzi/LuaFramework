--
-- Author: xurui
-- Date: 2015-04-07 09:42:51
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTavernShowHeroInfo = class("QUIDialogTavernShowHeroInfo", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")

function QUIDialogTavernShowHeroInfo:ctor(options)
	local ccbFile = "ccb/Dialog_AchieveHeroNew.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
        {ccbCallbackName = "onTriggerDoComment", callback = handler(self, self._onTriggerDoComment)},
        {ccbCallbackName = "onTriggerShareSDK", callback = handler(self, self._onTriggerShareSDK)},
	}
	QUIDialogTavernShowHeroInfo.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(true)
    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)
    
	self._actorId = options.actorId
    self._callback = options.callback
    self._tavernType = options.tavernType or TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE

    if self:getOptions().isHavePast == nil then
        self._isHavePast = remote.herosUtil:checkHeroHavePast(self._actorId, true)
        self:getOptions().isHavePast = self._isHavePast
    else
        self._isHavePast = self:getOptions().isHavePast
    end

    if self._tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
        self._ccbOwner.tf_award_title1:setVisible(true)
        self._ccbOwner.tf_award_title2:setVisible(false)
        self._ccbOwner.node_sliver_bg:removeAllChildren()
        self._ccbOwner.node_gold_bg:setVisible(true)
    else
        self._ccbOwner.tf_award_title1:setVisible(false)
        self._ccbOwner.tf_award_title2:setVisible(true)
        self._ccbOwner.node_sliver_bg:setVisible(true)
        self._ccbOwner.node_gold_bg:removeAllChildren()
    end

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_CALL_HERO_SUCCESS_END})
end

function QUIDialogTavernShowHeroInfo:viewDidAppear()
    QUIDialogTavernShowHeroInfo.super.viewDidAppear(self)
    self:setHeroInfo()
end

function QUIDialogTavernShowHeroInfo:viewWillDisappear()
    QUIDialogTavernShowHeroInfo.super.viewWillDisappear(self)
end

function QUIDialogTavernShowHeroInfo:setHeroInfo()
    local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
    local nickName = heroInfo.name or ""
    self._ccbOwner.tf_name1:setVisible(false)
    self._ccbOwner.tf_name2:setVisible(false)
    self._ccbOwner.tf_name3:setVisible(false)
    self._ccbOwner.tf_name4:setVisible(false)

    self._ccbOwner.node_share:setVisible(false)
    if heroInfo and heroInfo.aptitude >= APTITUDE.S then
        if remote.shareSDK:checkIsOpen() then
            self._ccbOwner.node_share:setVisible(true)
        end
    end
    
    self._shareInfo = remote.shareSDK:getShareConfigById(self._actorId,remote.shareSDK.HERO)
    if q.isEmpty(self._shareInfo) then
        self._ccbOwner.node_share:setVisible(false)
    end
    local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(self._actorId) or {}
    local tf = nil
    if aptitudeInfo.color == "red" then
        tf = self._ccbOwner.tf_name4
    elseif aptitudeInfo.color == "orange" then
        tf = self._ccbOwner.tf_name3
    elseif aptitudeInfo.color == "purple" then
        tf = self._ccbOwner.tf_name2
    elseif aptitudeInfo.color == "blue" then
        tf = self._ccbOwner.tf_name1
    else
        tf = self._ccbOwner.tf_name1
    end
    tf:setString(nickName)
    tf:setVisible(true)

    if #nickName >= 15 then
        local posX = self._ccbOwner.node_aptitude:getPositionX()
        self._ccbOwner.node_aptitude:setPositionX(posX-50)
    end

    self._ccbOwner.tf_hero_desc:setString(heroInfo.label or "")
    self._ccbOwner.tf_award_title1:setString(heroInfo.title or "")
    self._ccbOwner.tf_award_title2:setString(heroInfo.title or "")

    if self._avatar == nil then
        self._avatar = QUIWidgetHeroInformation.new()
        self._avatar:setPositionY(50)
        self._ccbOwner.node_hero:addChild(self._avatar)
    end
    self._avatar:setAvatarByHeroInfo(nil, self._actorId, 1.1)
    self._avatar:setNameVisible(false)
    self._avatar:setStarVisible(false)
    self._avatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY, true)

    if self._professionalIcon == nil then 
        self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
        self._ccbOwner.profession_icon:addChild(self._professionalIcon)
    end
    self._professionalIcon:setHero(self._actorId, false, 1.2)

    self._ccbOwner.pingzhi_icon:removeAllChildren()

    self:setSABC()
end 

function QUIDialogTavernShowHeroInfo:setSABC()
    local nodeOwner = {}
    local pingzhiNode = CCBuilderReaderLoad("ccb/Widget_Hero_pingzhi.ccbi", CCBProxy:create(), nodeOwner)
    self._ccbOwner.pingzhi_icon:addChild(pingzhiNode)

    local aptitudeInfo = db:getActorSABC(self._actorId)
    q.setAptitudeShow(nodeOwner, aptitudeInfo.lower)
end

function QUIDialogTavernShowHeroInfo:_onTriggerDetail(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_detail) == false then return end
    app.sound:playSound("common_small")
    
    -- 选择英雄
    local pos = 0
    local onlineHerosID = remote.handBook:getOnlineHerosID()
    for i, actorId in ipairs(onlineHerosID) do
        if tonumber(actorId) == self._actorId then
            pos = i
            break
        end
    end
    if pos > 0 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookMain",
            options = {herosID = onlineHerosID, pos = pos}}, {isPopCurrentDialog = false})
    else
        app.tip:floatTip("敬请期待")
    end
end

function QUIDialogTavernShowHeroInfo:_onTriggerDoComment(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_doComment) == false then return end
    app.sound:playSound("common_small")

    if remote.handBook:getDoCommentFuncSwitch() then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookBBS", 
            options = {actorId = self._actorId, tab = "HOT_COMMENT"}}, {isPopCurrentDialog = false})
    else
        app.tip:floatTip("敬请期待")
    end
end

function QUIDialogTavernShowHeroInfo:_onTriggerShareSDK( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_share) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogShareSDK", 
        options = {shareInfo = self._shareInfo}}, {isPopCurrentDialog = false}) 
end

function QUIDialogTavernShowHeroInfo:_backClickHandler()
    local actorId = self._actorId
    local callback = self._callback
    self:popSelf()

    if self._isHavePast == false then
        app.tip:assistSkillTip(actorId, callback)
    else
        if callback then
            callback()
        end
    end
end

return QUIDialogTavernShowHeroInfo