-- @Author: liaoxianbo
-- @Date:   2020-07-03 17:53:51
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-17 11:03:15
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAchievementCollectionCell = class("QUIWidgetAchievementCollectionCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetAchievementCollectionCell:ctor(options)
	local ccbFile = "ccb/Widget_achievementCollection_cell.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetAchievementCollectionCell.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetAchievementCollectionCell:onEnter()
end

function QUIWidgetAchievementCollectionCell:onExit()
end

function QUIWidgetAchievementCollectionCell:setInfo(info)
	if q.isEmpty(info) then return end
	self._info = info

	local myCellInfo = remote.achievementCollege:getMyCellCondtionInfoById(self._info.id)
	if myCellInfo and self._info.conditions_number then
		local str = (self._info.name or "").." "..(myCellInfo.processNum or 0).."/"..(self._info.num)
		self._ccbOwner.tf_btn_name:setString(str)
	else
		self._ccbOwner.tf_btn_name:setString(self._info.name or "")
	end

	local collegeState = remote.achievementCollege:checkMyCellCondtionState(self._info.id)
	self._ccbOwner.sp_is_collected:setVisible(collegeState)
	self._ccbOwner.sp_have_Bg:setVisible(collegeState)
end

function QUIWidgetAchievementCollectionCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetAchievementCollectionCell
