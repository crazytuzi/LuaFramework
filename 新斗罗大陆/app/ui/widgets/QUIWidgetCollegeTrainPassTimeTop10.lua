-- @Author: liaoxianbo
-- @Date:   2019-12-19 17:09:00
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-26 16:33:39
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCollegeTrainPassTimeTop10 = class("QUIWidgetCollegeTrainPassTimeTop10", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetCollegeTrainPassTimeTop10:ctor(options)
	local ccbFile = "ccb/Widget_CollegeTrain_PassTime_tips.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetCollegeTrainPassTimeTop10.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetCollegeTrainPassTimeTop10:setRankInfo(info)
	-- table.insert(self._rankData,{rank= i,name = "豆超傻逼"..i.."号",passTime = 18258245})
	if not info then return end
	self._info = info
	self._ccbOwner.tf_rankName:setString(self._info.rank.." "..self._info.name)

	local passTime = string.format("%0.2f秒", tonumber(self._info.passTime or 0) / 1000.0)
	-- self._ccbOwner.tf_rankPassTime:setString(q.timeToHourMinuteSecond(self._info.passTime,true))
	self._ccbOwner.tf_rankPassTime:setString(passTime)
end
function QUIWidgetCollegeTrainPassTimeTop10:onEnter()
end

function QUIWidgetCollegeTrainPassTimeTop10:onExit()
end

function QUIWidgetCollegeTrainPassTimeTop10:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetCollegeTrainPassTimeTop10
