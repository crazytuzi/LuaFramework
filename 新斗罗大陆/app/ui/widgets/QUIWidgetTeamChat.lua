-- @Author: xurui
-- @Date:   2016-11-26 12:15:10
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-07-01 22:05:39
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTeamChat = class("QUIWidgetTeamChat", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetTeamChat:ctor(options)
	local ccbFile = "ccb/Widget_Black_mountain_chat1.ccbi"
	local callBack = {
	}
	QUIWidgetTeamChat.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._index = options.index
	end
	self._ccbOwner.node_leader:setVisible(false)
	self._ccbOwner.node_member:setVisible(false)
end

function QUIWidgetTeamChat:onEnter()
end

function QUIWidgetTeamChat:onExit()
end

function QUIWidgetTeamChat:setInfo(info,isLeader,isInitFrame)
	self._ccbOwner.node_head:removeAllChildren()
	self._ccbOwner.online:setVisible(false)
	-- if info == nil then
	-- 	self._ccbOwner.online:setVisible(false)
	-- 	return
	-- end
	if isInitFrame then
		self._ccbOwner.online:setVisible(true)
		self._ccbOwner.tf_nickName:setString(info.name or "")	
	end

	if isLeader then
		self._ccbOwner.node_leader:setVisible(true)
		self._ccbOwner.node_member:setVisible(false)
		self._ccbOwner.node_headFrame:setVisible(false)
	else
		self._ccbOwner.node_leader:setVisible(false)
		self._ccbOwner.node_member:setVisible(true)
	end

	if self._avatar then
		self._avatar:removeFromParent()
		self._avatar = nil
	end

	if info and info.avatar then
		local avatar = QUIWidgetAvatar.new()
		self._ccbOwner.node_head:addChild(avatar)
		avatar:setEnabledClick(false)
		avatar:setInfo(info.avatar)
		avatar:setSilvesArenaPeak(info.championCount)
		self._ccbOwner.node_headFrame:setVisible(false)
	else
		self._ccbOwner.node_headFrame:setVisible(true)
	end
end

return QUIWidgetTeamChat