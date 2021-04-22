-- @Author: xurui
-- @Date:   2019-01-16 16:54:00
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-02 16:18:16
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroSkinDetail = class("QUIDialogHeroSkinDetail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QActorProp = import("...models.QActorProp")

function QUIDialogHeroSkinDetail:ctor(options)
	local ccbFile = "ccb/Dialog_hero_skin_details.ccbi"
    local callBacks = { 
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    QUIDialogHeroSkinDetail.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._skinId = options.skinId
    	self._heroId = options.heroId
    end

    self._ccbOwner.frame_tf_title:setString("皮肤详情")
end

function QUIDialogHeroSkinDetail:viewDidAppear()
	QUIDialogHeroSkinDetail.super.viewDidAppear(self)

	self:setSkinInfo()
end

function QUIDialogHeroSkinDetail:viewWillDisappear()
  	QUIDialogHeroSkinDetail.super.viewWillDisappear(self)
end

function QUIDialogHeroSkinDetail:setSkinInfo()
	self._skinInfo = remote.heroSkin:getHeroSkinBySkinId(self._heroId, self._skinId)
    self._heroConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._heroId)

	-- set avatar 
    if self._skinAvatar == nil then
        self._skinAvatar = QUIWidgetHeroInformation.new()
        self._ccbOwner.node_skin_avatar:addChild(self._skinAvatar)
    	self._skinAvatar:setPositionY(65)
    	self._skinAvatar:startAutoPlay(10)
    end
    self._skinAvatar:setAvatarByHeroInfo({skinId = self._skinInfo.skins_id}, self._skinInfo.character_id, 1)
    self._skinAvatar:setNameVisible(false)

    self._ccbOwner.tf_skin_name:setString((self._skinInfo.skins_name or "") .. "·" .. (self._heroConfig.name or ""))

    self:setSkinPorp()
end

function QUIDialogHeroSkinDetail:setSkinPorp()
    local index = 1
    local propFields = QActorProp:getPropFields()

    for i = 1, 4 do
        self._ccbOwner["tf_prop_"..i]:setVisible(false)
    end

	for key, value in pairs(self._skinInfo) do
        if propFields[key] and self._ccbOwner["tf_prop_"..index] then
            self._ccbOwner["tf_prop_"..index]:setVisible(true)

            local name = propFields[key].uiName
            if name == nil then
                name = propFields[key].name
            end
            if propFields[key].isPercent then
                self._ccbOwner["tf_prop_"..index]:setString(string.format("%s+%.01f%%", name, value*100))
            else
                self._ccbOwner["tf_prop_"..index]:setString(string.format("%s+%s", name, (value or "")))
            end
            index = index + 1
        end
    end
end

function QUIDialogHeroSkinDetail:_onTriggerHelp(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
  	app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSkinTip", 
        options = {skinId = self._skinId, heroId = self._heroId}}, {isPopCurrentDialog = false})
end

function QUIDialogHeroSkinDetail:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHeroSkinDetail:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogHeroSkinDetail:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogHeroSkinDetail
