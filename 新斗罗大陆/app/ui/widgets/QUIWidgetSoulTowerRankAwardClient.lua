-- @Author: vicentboo
-- @Date:   2020-04-15 20:50:42
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-20 18:43:32

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTowerRankAwardClient = class("QUIWidgetSoulTowerRankAwardClient", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUnionAvatar = import("...utils.QUnionAvatar")

function QUIWidgetSoulTowerRankAwardClient:ctor(options)
	local ccbFile = "ccb/Widget_WineGod_jifen2.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetSoulTowerRankAwardClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSoulTowerRankAwardClient:onEnter()
end

function QUIWidgetSoulTowerRankAwardClient:onExit()
end

function QUIWidgetSoulTowerRankAwardClient:setInfo(param)
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

	self._ccbOwner.nickName:setString(self._info.name or "")
	self._ccbOwner.level:setString(string.format("LV.%d",self._info.level or 1))

	self._ccbOwner.scoreLable:setString("最高击退：")
	self._ccbOwner.score:setString((self._info.dungeonId or 0).."-"..(self._info.wave or 0))

	self._ccbOwner.tf_name2:setString("击退时间：")
	local passTime = string.format("%0.2f秒", tonumber(self._info.passTime or 0) / 1000.0 )	
	self._ccbOwner.serverName:setString(passTime)

	if self._info.vip then
		self._ccbOwner.vip:setString("VIP "..self._info.vip)
	else
		self._ccbOwner.vip:setVisible(false)
	end

	if self._avatar ~= nil then
		self._avatar:removeFromParent()
		self._avatar = nil
	end
	local avatar = self._info.avatar
	if self._info.avatar then
		self._avatar = QUIWidgetAvatar.new()
	elseif self._info.icon then
		self._avatar = QUnionAvatar.new()
		self._avatar:setConsortiaWarFloor(self._info.consortiaWarFloor)
		avatar = self._info.icon
	end
	self._avatar:setInfo(avatar)
	self._avatar:setSilvesArenaPeak(self._info.championCount)
    self._ccbOwner.node_headPicture:addChild(self._avatar)

end

function QUIWidgetSoulTowerRankAwardClient:onTriggerHomeHandler(tag)

end

function QUIWidgetSoulTowerRankAwardClient:getContentSize()
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetSoulTowerRankAwardClient