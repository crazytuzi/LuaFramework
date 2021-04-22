-- @Author: xurui
-- @Date:   2016-11-10 16:44:16
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-11-11 10:23:42
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUnionActiveRankClientCell = class("QUIWidgetUnionActiveRankClientCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetUnionActiveRankClientCell:ctor(options)
	local ccbFile = "ccb/Widget_society_huoyuepaihang_client.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetUnionActiveRankClientCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetUnionActiveRankClientCell:onEnter()
end

function QUIWidgetUnionActiveRankClientCell:onExit()
end

function QUIWidgetUnionActiveRankClientCell:setInfo(param)
	self._info = param.info

	self._ccbOwner.first:setVisible(false)
	self._ccbOwner.second:setVisible(false)
	self._ccbOwner.third:setVisible(false)
	self._ccbOwner.other:setVisible(false)
	if self._info.rank == 1 then
		self._ccbOwner.first:setVisible(true)

	elseif self._info.rank == 2 then
		self._ccbOwner.second:setVisible(true)
	elseif self._info.rank == 3 then
		self._ccbOwner.third:setVisible(true)
	else
		self._ccbOwner.other:setVisible(true)
		self._ccbOwner.other:setString(self._info.rank )
	end

	self._ccbOwner.tf_name:setString(self._info.name or "")
	self._ccbOwner.tf_level:setString(string.format("LV.%d",self._info.level or 1))

	self._ccbOwner.tf_value1:setString(self._info.consortiaDailyActiveness or 0)
	self._ccbOwner.tf_value2:setString(self._info.consortiaWeekActiveness or 0)

	if self._info.vip then
		self._ccbOwner.tf_vip:setString("VIP "..self._info.vip)
	else
		self._ccbOwner.tf_vip:setVisible(false)
	end

	if self._avatar ~= nil then
		self._avatar:removeFromParent()
		self._avatar = nil
	end
	local avatar = self._info.avatar
	self._avatar = QUIWidgetAvatar.new()
	self._avatar:setInfo(avatar)
	self._avatar:setSilvesArenaPeak(self._info.championCount)
    self._ccbOwner.node_head:addChild(self._avatar)

	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(self._info.nightmareDungeonPassCount or 0)
	if config ~= nil then
		self._ccbOwner.node_badge:setVisible(true)
		self._ccbOwner.node_badge:addChild(CCSprite:create(config.alphaicon))
		self._ccbOwner.tf_name:setPositionX(-35)
	else
		self._ccbOwner.node_badge:setVisible(false)
		self._ccbOwner.tf_name:setPositionX(-68)
	end
end

function QUIWidgetUnionActiveRankClientCell:getContentSize()
	return self._ccbOwner.background:getContentSize()
end


return QUIWidgetUnionActiveRankClientCell