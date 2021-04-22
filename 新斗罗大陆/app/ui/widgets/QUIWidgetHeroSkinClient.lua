-- @Author: xurui
-- @Date:   2019-01-08 18:40:22
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-25 11:45:29
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroSkinClient = class("QUIWidgetHeroSkinClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetFashionHeadBox = import("..widgets.QUIWidgetFashionHeadBox")
local QActorProp = import("...models.QActorProp")

QUIWidgetHeroSkinClient.EVENT_CLICK_HELP = "EVENT_CLICK_HELP"
QUIWidgetHeroSkinClient.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetHeroSkinClient:ctor(options)
	local ccbFile = "ccb/Widget_hero_skin.ccbi" 
    local callBacks = {
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
        {ccbCallbackName = "onTriggerAvatar", callback = handler(self, self._onTriggerAvatar)},
    }
    QUIWidgetHeroSkinClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._showEffect = false
    self._selectStatus = false
end

function QUIWidgetHeroSkinClient:onEnter()
end

function QUIWidgetHeroSkinClient:onExit()
end

function QUIWidgetHeroSkinClient:setInfo(info, index)
	self._skinInfo = info
    self._index = index

	-- set avatar 
    if self._skinAvatar == nil then
        self._skinAvatar = QUIWidgetHeroInformation.new()
        self._ccbOwner.node_avatar:addChild(self._skinAvatar)
    end
    self._skinAvatar:setAvatarByHeroInfo({skinId = self._skinInfo.skins_id}, self._skinInfo.character_id, 1)
    self._skinAvatar:setNameVisible(false)

    --set head 	
    if self._heroHead == nil then
    	self._heroHead = QUIWidgetFashionHeadBox.new()
    	self._ccbOwner.node_head:addChild(self._heroHead)
        self._heroHead:setScale(0.8)
    end
    self._heroHead:setInfo(self._skinInfo)
    -- self._heroHead:setHeroSkinId(self._skinInfo.skins_id)
    -- self._heroHead:setHero(self._skinInfo.character_id)
    -- self._heroHead:setBreakthrough()

    self._ccbOwner.tf_skin_name:setString((self._skinInfo.skins_name or ""))

    self:setSkinPorp()

    self:setUseStatus(self._skinInfo.isUse)

    self:setActivationStatus()
end

function QUIWidgetHeroSkinClient:setSkinPorp()
    local index = 1
    local propFields = QActorProp:getPropFields()

    for i = 1, 4 do
        self._ccbOwner["tf_name_"..i]:setVisible(false)
        self._ccbOwner["tf_prop_"..i]:setVisible(false)
    end

    self._ccbOwner.tf_no_prop:setVisible(false)
    if self._skinInfo.is_nature == 0 then
        self._ccbOwner.tf_no_prop:setVisible(true)
    else
    	for key, value in pairs(self._skinInfo) do
            if propFields[key] and self._ccbOwner["tf_name_"..index] then
                self._ccbOwner["tf_name_"..index]:setVisible(true)
                self._ccbOwner["tf_prop_"..index]:setVisible(true)

                local name = propFields[key].uiName
                if name == nil then
                    name = propFields[key].name
                end
                self._ccbOwner["tf_name_"..index]:setString((name or "")..":")
                if propFields[key].isPercent then
                    self._ccbOwner["tf_prop_"..index]:setString(string.format("+%0.1f%%", value*100))
                else
                    self._ccbOwner["tf_prop_"..index]:setString(string.format("+%s", (value or "")))
                end
                index = index + 1
            end
        end
    end
end

function QUIWidgetHeroSkinClient:setSelectStatus(status)
	if status == nil then status = false end

    self._selectStatus = status
	self._ccbOwner.sp_select:setVisible(status)
end

function QUIWidgetHeroSkinClient:setUseStatus(status)
    if status == nil then status = false end

    self._ccbOwner.sp_use:setVisible(status)
end

function QUIWidgetHeroSkinClient:setActivationStatus()
    self._ccbOwner.sp_activity:setVisible(false)
    self._ccbOwner.ly_activation:setVisible(false)
    self._ccbOwner.node_buy:setVisible(false)
    self._showEffect = true

    if self._skinInfo.isUse ~= true then
        if self._skinInfo.isActivation then
            if self._skinAvatar then
                self._skinAvatar:startAutoPlay(10)
            end
        else
            self._showEffect = false
            self._ccbOwner.ly_activation:setVisible(true)

            if self._skinInfo.skins_sell == 2 then
                self._ccbOwner.sp_activity:setVisible(true)
            else
                self._ccbOwner.node_buy:setVisible(true)
                self._ccbOwner.tf_token_num:setString(self._skinInfo.skins_token_price or 0)
            end
            if self._skinAvatar then
                self._skinAvatar:stopAutoPlay()
            end
        end
    end
end

function QUIWidgetHeroSkinClient:_onTriggerAvatar()
    if self._selectStatus and self._showEffect then
        if self._skinAvatar then
            self._skinAvatar:_onTriggerAvatar()
        end
    else
        self:_onTriggerClick()
    end
end

function QUIWidgetHeroSkinClient:getContentSize()
	return self._ccbOwner.btn_click:getContentSize()
end

function QUIWidgetHeroSkinClient:_onTriggerHelp()
    self:dispatchEvent({name = QUIWidgetHeroSkinClient.EVENT_CLICK_HELP, index = self._index, skinInfo = self._skinInfo})
end

function QUIWidgetHeroSkinClient:_onTriggerClick()
    self:dispatchEvent({name = QUIWidgetHeroSkinClient.EVENT_CLICK, index = self._index, skinInfo = self._skinInfo})
end

return QUIWidgetHeroSkinClient
