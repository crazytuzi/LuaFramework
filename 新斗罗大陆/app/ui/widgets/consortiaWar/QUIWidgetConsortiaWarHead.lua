-- @Author: zhouxiaoshu
-- @Date:   2019-04-30 16:58:32
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-24 15:24:35
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetConsortiaWarHead = class("QUIWidgetConsortiaWarHead", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

function QUIWidgetConsortiaWarHead:ctor(options)
	local ccbFile = "ccb/Widget_Unionwar_head.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetConsortiaWarHead.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetConsortiaWarHead:resetAll()
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_force:setVisible(false)
    self._ccbOwner.node_no:setVisible(true)
    self._ccbOwner.node_icon:removeAllChildren()
    self._userId = 0
end

function QUIWidgetConsortiaWarHead:setInfo(info)
	self:resetAll()
	if not info or not info.memberFighter then
		return
	end
	self._info = info
    self._userId = info.memberId

	local avatar = QUIWidgetAvatar.new()
	avatar:setSpecialInfo(info.memberFighter.avatar)
	avatar:setSilvesArenaPeak(info.memberFighter.championCount)
    self._ccbOwner.node_icon:addChild(avatar)
    self._ccbOwner.node_no:setVisible(false)

	self._ccbOwner.tf_name:setVisible(true)
	self._ccbOwner.tf_name:setString(info.memberFighter.name or "")
    	
    local num, uint = q.convertLargerNumber(info.memberFighter.force)
	self._ccbOwner.tf_force:setVisible(true)
	self._ccbOwner.tf_force:setString("战力："..num..uint)
end

function QUIWidgetConsortiaWarHead:hideNameForce()
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_force:setVisible(false)
end

function QUIWidgetConsortiaWarHead:getUserId()
	return self._userId
end

return QUIWidgetConsortiaWarHead
