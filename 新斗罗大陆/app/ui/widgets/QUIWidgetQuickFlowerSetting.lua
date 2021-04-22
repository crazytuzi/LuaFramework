-- @Author: liaoxianbo
-- @Date:   2019-05-05 16:53:52
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-07-31 18:25:23
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetQuickFlowerSetting = class("QUIWidgetQuickFlowerSetting", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetQuickFlowerSetting:ctor(options)
	local ccbFile = "ccb/Widget_monopolyflower_setting.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerUpClick", callback = handler(self, self._onTriggerUpClick)},
		-- {ccbCallbackName = "onTriggerCancleClick", callback = handler(self, self._onTriggerCancleClick)},
    }
    QUIWidgetQuickFlowerSetting.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetQuickFlowerSetting:setBoxInfo(id,configInfo)
	self._setId = id
	self._flowerConfig = configInfo
	local setconfig = remote.monopoly:getSelectByMonopolyId(id)
	local savaId = tostring(self._flowerConfig.id)
	local flowerUp = true
	if setconfig.flowerUp then
		flowerUp = setconfig.flowerUp[self._flowerConfig.id]
	end


	if flowerUp then
		self:setSelectChoose(true)
	else
		self:setSelectChoose(false)
	end

	self._ccbOwner.tf_name:setString(self._flowerConfig.name)
	local sf = QSpriteFrameByPath(self._flowerConfig.icon)
	if sf then
		self._ccbOwner.sp_flower:setDisplayFrame(sf)
	end
end

function QUIWidgetQuickFlowerSetting:setSelectChoose(bState)
	self._ccbOwner.sp_up_select:setVisible(bState)
end

function QUIWidgetQuickFlowerSetting:_onTriggerUpClick(event )
	app.sound:playSound("common_switch")
    local checkState = self._ccbOwner.sp_up_select:isVisible()
    self:setSelectChoose(not checkState)
end
function QUIWidgetQuickFlowerSetting:getFlowerOneSetId()
	return self._flowerConfig.oneSetId
end

function QUIWidgetQuickFlowerSetting:getChooseState()
	local checkState = self._ccbOwner.sp_up_select:isVisible()
	return checkState
end
function QUIWidgetQuickFlowerSetting:onEnter()
end

function QUIWidgetQuickFlowerSetting:onExit()
end

function QUIWidgetQuickFlowerSetting:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = size.height
	return size
	-- return cc.size(500,120)		
end

return QUIWidgetQuickFlowerSetting
