-- @Author: liaoxianbo
-- @Date:   2020-03-01 15:04:14
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-07 13:03:41
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulFire = class("QUIWidgetSoulFire", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetSoulFire:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_fire.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetSoulFire.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetSoulFire:setSoulFireInfo( fireColor,isActive)

	if isActive then
		self:showFireEffect(fireColor)
		makeNodeFromGrayToNormal(self._ccbOwner.node_soulFire)
	else
		self:hideFireEffect()
		makeNodeFromNormalToGray(self._ccbOwner.node_soulFire)
	end
end

function QUIWidgetSoulFire:showFireEffect( fireColor )
	self._ccbOwner.node_effect_1:setVisible(fireColor == 1)
	self._ccbOwner.node_effect_2:setVisible(fireColor == 2)
	self._ccbOwner.node_effect_3:setVisible(fireColor == 3)
end

function QUIWidgetSoulFire:setActionShowSoulFire( fireColor )
	if self._ccbOwner["node_effect_"..fireColor] then
		makeNodeFromGrayToNormal(self._ccbOwner.node_soulFire)
		self._ccbOwner["node_effect_"..fireColor]:setVisible(true)
		self._ccbOwner["node_effect_"..fireColor]:setOpacity(0)
		self._ccbOwner["node_effect_"..fireColor]:runAction(CCFadeIn:create(0.8))
	end
end

function QUIWidgetSoulFire:hideFireEffect( )
	for ii=1,3 do
		self._ccbOwner["node_effect_"..ii]:setVisible(false)
	end
end
function QUIWidgetSoulFire:onEnter()
end

function QUIWidgetSoulFire:onExit()
end

function QUIWidgetSoulFire:getContentSize()
end

return QUIWidgetSoulFire
