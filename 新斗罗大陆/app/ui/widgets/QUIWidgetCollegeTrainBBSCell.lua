-- @Author: liaoxianbo
-- @Date:   2019-11-22 14:49:05
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-23 11:57:37
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCollegeTrainBBSCell = class("QUIWidgetCollegeTrainBBSCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetCollegeTrainBBSCell:ctor(options)
	local ccbFile = "ccb/Widget_CollegeTrain_BBSCell.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerAdmire", callback = handler(self, self._onTriggerAdmire)},
		{ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
		{ccbCallbackName = "onTriggerTop", callback = handler(self, self._onTriggerTop)},
	}
	QUIWidgetCollegeTrainBBSCell.super.ctor(self,ccbFile,callBacks,options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetCollegeTrainBBSCell:onEnter()
end

function QUIWidgetCollegeTrainBBSCell:onExit()
end

function QUIWidgetCollegeTrainBBSCell:refreshAdmireInfo(info)
	if next(info) == nil then return end
	-- if self._info.isBtnView then return end
	self._info = info
	self:_setAdmireInfo()
end

function QUIWidgetCollegeTrainBBSCell:setInfo(info, index)
	self._info = info

	self._index = index or 0

	self._ccbOwner.node_line:setVisible(self._index > 1)

	if self._info.isBtnView then
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.node_bbs:setVisible(false)

	else
		self._ccbOwner.node_btn:setVisible(false)
		self._ccbOwner.node_bbs:setVisible(true)

		self._ccbOwner.tf_name:setString(self._info.nickname.."("..self._info.gameareaName..")")
		self._ccbOwner.tf_output:setString(self._info.content)

		self:_setAdmireInfo()
	end
end

function QUIWidgetCollegeTrainBBSCell:_setAdmireInfo()
	self._ccbOwner.tf_admire_count:setString(self._info.sumCount)
	self._ccbOwner.sp_admire_on:setVisible(self._info.isAdmire)
	self._ccbOwner.sp_admire_off:setVisible(not self._info.isAdmire)
end

function QUIWidgetCollegeTrainBBSCell:getContentSize()
	local sizeHeight = self._ccbOwner.node_size:getContentSize().height
	local sizeWidth = self._ccbOwner.node_size:getContentSize().width
	if self._info.isBtnView then
		self._ccbOwner.node_size:getContentSize().height = 86
	else
		local posY = self._ccbOwner.tf_output:getPositionY()
		local height = self._ccbOwner.tf_output:getContentSize().height
		local tmpHeight = posY + height
		if tmpHeight > self._ccbOwner.node_size:getContentSize().height then
			sizeHeight = tmpHeight
		end
	end

	return CCSize(sizeWidth,sizeHeight)
end

function QUIWidgetCollegeTrainBBSCell:_onTriggerAdmire(event)
	-- body
end

function QUIWidgetCollegeTrainBBSCell:_onTriggerRefresh(event)
	-- body
end

function QUIWidgetCollegeTrainBBSCell:_onTriggerTop(event)
	-- body
end


return QUIWidgetCollegeTrainBBSCell
