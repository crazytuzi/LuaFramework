-- @Author: xurui
-- @Date:   2019-08-30 14:46:49
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-09-02 15:45:36
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRankAwardRecordClient = class("QUIWidgetRankAwardRecordClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetRankAwardRecordClient:ctor(options)
	local ccbFile = "ccb/Widget_rank_award.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetRankAwardRecordClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetRankAwardRecordClient:onEnter()
end

function QUIWidgetRankAwardRecordClient:onExit()
end

function QUIWidgetRankAwardRecordClient:setInfo(info, rank)
	self._info = info

	self._ccbOwner.sp_first:setVisible(rank == 1)
	self._ccbOwner.sp_second:setVisible(rank == 2)
	self._ccbOwner.sp_third:setVisible(rank == 3)
	self._ccbOwner.tf_other:setVisible(rank > 3)
	self._ccbOwner.tf_other:setString(rank or 1)

	local userInfo = self._info.completeUsersInfo or {}
	local avatar = QUIWidgetAvatar.new(userInfo.avatar or (-1))
	avatar:setSilvesArenaPeak(userInfo.championCount)
	self._ccbOwner.node_avatar:addChild(avatar)

	self._ccbOwner.tf_name:setString(string.format("LV.%s %s", (userInfo.level or "1"), (userInfo.name or "")))

    local time = q.date("*t", (self._info.completeAt or 0)/1000)
	self._ccbOwner.tf_time:setString(string.format("%d/%02d/%02d %02d:%02d:%02d", time.year, time.month, time.day, time.hour, time.min, time.sec))
end

function QUIWidgetRankAwardRecordClient:getContentSize()
	return self._ccbOwner.ly_bg_size:getContentSize()
end

return QUIWidgetRankAwardRecordClient
