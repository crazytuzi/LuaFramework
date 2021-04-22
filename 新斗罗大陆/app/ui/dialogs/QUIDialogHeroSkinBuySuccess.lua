-- @Author: xurui
-- @Date:   2019-01-16 16:11:25
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-28 11:57:46
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroSkinBuySuccess = class("QUIDialogHeroSkinBuySuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")

function QUIDialogHeroSkinBuySuccess:ctor(options)
	local ccbFile = "ccb/Dialog_hero_skin_huode.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
        {ccbCallbackName = "onTriggerShareSDK", callback = handler(self, self._onTriggerShareSDK)},
    }
    QUIDialogHeroSkinBuySuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    CalculateUIBgSize(self._ccbOwner.sp_bg)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._skinInfo = options.skinInfo
    end
    self._showEnd = false
end

function QUIDialogHeroSkinBuySuccess:viewDidAppear()
	QUIDialogHeroSkinBuySuccess.super.viewDidAppear(self)

	self:setInfo()

    self._showEndScheduler = scheduler.performWithDelayGlobal(function()
            self._showEnd = true
        end, 1)
end

function QUIDialogHeroSkinBuySuccess:viewWillDisappear()
  	QUIDialogHeroSkinBuySuccess.super.viewWillDisappear(self)

    if self._showEndScheduler then
        scheduler.unscheduleGlobal(self._showEndScheduler)
        self._showEndScheduler = nil
    end
end

function QUIDialogHeroSkinBuySuccess:setInfo()
	-- set avatar 
    if self._skinAvatar == nil then
        self._skinAvatar = QUIWidgetHeroInformation.new()
        self._ccbOwner.node_skin_avatar:addChild(self._skinAvatar)
    end
    self._skinAvatar:setAvatarByHeroInfo({skinId = self._skinInfo.skins_id}, self._skinInfo.character_id, 1.25)
    self._skinAvatar:startAutoPlay(10)
    self._skinAvatar:setPositionY(50)
    self._skinAvatar:setNameVisible(false)

    self._ccbOwner.tf_skin_name:setString(self._skinInfo.skins_name or "")
    if remote.shareSDK:checkIsOpen() then
        self._shareInfo = remote.shareSDK:getShareConfigById(self._skinInfo.skins_id,remote.shareSDK.SKIN)
        if q.isEmpty(self._shareInfo) then
            self._ccbOwner.node_share:setVisible(false)
        else
            self._ccbOwner.node_share:setVisible(true)
        end
    else
        self._ccbOwner.node_share:setVisible(false)
    end
end

function QUIDialogHeroSkinBuySuccess:_onTriggerDetail(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_detail) == false then return end
  	app.sound:playSound("common_small")
	
    local onlineHerosID = remote.handBook:getOnlineHerosID()
    local pos
    for i, actorId in ipairs(onlineHerosID) do
        if tonumber(actorId) == self._skinInfo.character_id then
            pos = i
            break
        end
    end

    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookMain", 
        options = {herosID = onlineHerosID, pos = pos, swithType = 2, selectSinkId = self._skinInfo.skins_id}}, {isPopCurrentDialog = false})
end

function QUIDialogHeroSkinBuySuccess:_onTriggerShare(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_xuanyao) == false then return end
  	app.sound:playSound("common_small")

    if app:getUserOperateRecord():getHeroSkinShareTimes() == false then
        return
    end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSkinShare", 
		options = {skinInfo = self._skinInfo}}, {isPopCurrentDialog = false})
end

function QUIDialogHeroSkinBuySuccess:_onTriggerShareSDK( event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_share) == false then return end
    app.sound:playSound("common_small")
    if q.isEmpty(self._shareInfo) then return end
    
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogShareSDK", 
        options = {shareInfo = self._shareInfo}}, {isPopCurrentDialog = false})     
end

function QUIDialogHeroSkinBuySuccess:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHeroSkinBuySuccess:_onTriggerClose()
  	app.sound:playSound("common_close")

    if self._showEnd then
	   self:playEffectOut()
    end
end

function QUIDialogHeroSkinBuySuccess:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogHeroSkinBuySuccess
