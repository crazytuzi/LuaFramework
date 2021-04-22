-- @Author: xurui
-- @Date:   2019-10-29 14:57:00
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-29 14:58:39
local QUIWidgetTopBarCell = import("..widgets.QUIWidgetTopBarCell")
local QUIWidgetUnionWarTopBarCell = class("QUIWidgetUnionWarTopBarCell", QUIWidget)
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetUnionWarTopBarCell:ctor(options)
	QUIWidgetUnionWarTopBarCell.super.ctor(self, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self:showUnionWarBattleBuff()

end

function QUIWidgetUnionWarTopBarCell:onEnter( ... )
end

function QUIWidgetUnionWarTopBarCell:showUnionWarBattleBuff( num )
	if num and num > 0 then
		self._ccbOwner.node_buff_up:setVisible(true)
		self._ccbOwner.node_fire:setVisible(true)
		self._ccbOwner.tf_buff_num:setString(num.."%")
	else
		self._ccbOwner.node_buff_up:setVisible(false)
		self._ccbOwner.node_fire:setVisible(false)
		self._ccbOwner.tf_buff_num:setString("")
	end

	if ENABLE_PVP_FORCE then
		self._ccbOwner.node_buff_up:setPositionX(139)
	else
		self._ccbOwner.node_buff_up:setPositionX(85)
	end
end

return QUIWidgetUnionWarTopBarCell
