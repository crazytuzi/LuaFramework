-- @Author: liaoxianbo
-- @Date:   2020-04-13 14:57:59
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-04-13 14:59:48
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTowerRankCell = class("QUIWidgetSoulTowerRankCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetSoulTowerRankCell:ctor(options)
	local ccbFile = "ccb/Widget_SoulTower_Rank_cell.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetSoulTowerRankCell.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetSoulTowerRankCell:onEnter()
end

function QUIWidgetSoulTowerRankCell:onExit()
end

function QUIWidgetSoulTowerRankCell:setInfo(param)
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

	local score = self._info.intrusionAllHurt or 0
	self._ccbOwner.scoreLable:setString("个人荣誉:")
	if param.awardsType == 3 then
		score = self._info.worldBossHurt or 0
		self._ccbOwner.scoreLable:setString("宗门荣誉:")
	end
	local num, str = q.convertLargerNumber(math.floor(score/1000))
	self._ccbOwner.score:setString(num..(str or ""))

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

    if self._info.gameAreaName == nil and self._info.game_area_name == nil then
    	self._ccbOwner.tf_name2:setString("")
    	self._ccbOwner.serverName:setString("")
    else
		self._ccbOwner.serverName:setString(self._info.gameAreaName or self._info.game_area_name)
	end
end

function QUIWidgetSoulTowerRankCell:getContentSize()
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetSoulTowerRankCell
