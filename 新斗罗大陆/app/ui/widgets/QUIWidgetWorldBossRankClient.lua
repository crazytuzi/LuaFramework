-- @Author: xurui
-- @Date:   2016-11-01 17:18:34
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-06-20 11:28:41
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetWorldBossRankClient = class("QUIWidgetWorldBossRankClient", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUnionAvatar = import("...utils.QUnionAvatar")

function QUIWidgetWorldBossRankClient:ctor(options)
	local ccbFile = "ccb/Widget_WineGod_jifen2.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetWorldBossRankClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetWorldBossRankClient:onEnter()
end

function QUIWidgetWorldBossRankClient:onExit()
end

function QUIWidgetWorldBossRankClient:setInfo(param)
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

function QUIWidgetWorldBossRankClient:onTriggerHomeHandler(tag)

end

function QUIWidgetWorldBossRankClient:getContentSize()
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetWorldBossRankClient