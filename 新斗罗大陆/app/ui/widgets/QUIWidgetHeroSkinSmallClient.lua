-- @Author: xurui
-- @Date:   2019-01-16 20:34:46
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-01-23 15:30:03
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroSkinSmallClient = class("QUIWidgetHeroSkinSmallClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFashionHeadBox = import("..widgets.QUIWidgetFashionHeadBox")

QUIWidgetHeroSkinSmallClient.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetHeroSkinSmallClient:ctor(options)
	local ccbFile = "ccb/Widget_hero_skin_card.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetHeroSkinSmallClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetHeroSkinSmallClient:onEnter()
end

function QUIWidgetHeroSkinSmallClient:onExit()
end

function QUIWidgetHeroSkinSmallClient:setInfo(info, index)
	self._skinInfo = info
    self._index = index

    --set head 	
    if self._heroHead == nil then
    	self._heroHead = QUIWidgetFashionHeadBox.new()
    	self._ccbOwner.node_head:addChild(self._heroHead)
        self._heroHead:setScale(0.8)
    end
    self._heroHead:setInfo(self._skinInfo)

    self._ccbOwner.tf_skin_name:setString((self._skinInfo.skins_name or ""))

    self:setActivationStatus()
end

function QUIWidgetHeroSkinSmallClient:setActivationStatus()
    self._ccbOwner.tf_activity:setVisible(false)
    self._ccbOwner.tf_activation:setVisible(false)
	self._ccbOwner.ndoe_token:setVisible(false)

    if self._skinInfo.isActivation then
   	 	self._ccbOwner.tf_activation:setVisible(true)
    else
        self._ccbOwner.tf_activation:setVisible(false)
        if self._skinInfo.skins_sell == 2 then
            self._ccbOwner.tf_activity:setVisible(true)
        else
        	self._ccbOwner.ndoe_token:setVisible(true)
        	self._ccbOwner.tf_token:setString(self._skinInfo.skins_token_price or 0)
        end
    end
end

function QUIWidgetHeroSkinSmallClient:setSelectStatus(status)
	if status == false then status = false end
    
	self._ccbOwner.btn_status:setHighlighted(status)
	self._ccbOwner.btn_status:setEnabled(not status)
end

function QUIWidgetHeroSkinSmallClient:_onTriggerClick()
    self:dispatchEvent({name = QUIWidgetHeroSkinSmallClient.EVENT_CLICK, index = self._index, skinInfo = self._skinInfo})
end

function QUIWidgetHeroSkinSmallClient:getContentSize()
	return self._ccbOwner.btn_click:getContentSize()
end

return QUIWidgetHeroSkinSmallClient
