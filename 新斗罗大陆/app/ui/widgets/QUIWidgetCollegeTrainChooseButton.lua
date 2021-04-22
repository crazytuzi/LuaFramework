-- @Author: liaoxianbo
-- @Date:   2019-11-21 16:00:18
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-18 15:57:36
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCollegeTrainChooseButton = class("QUIWidgetCollegeTrainChooseButton", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetCollegeTrainChooseButton:ctor(options)
	local ccbFile = "ccb/Widget_CollegeTrain_button.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetCollegeTrainChooseButton.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetCollegeTrainChooseButton:onEnter()
end

function QUIWidgetCollegeTrainChooseButton:onExit()
end

function QUIWidgetCollegeTrainChooseButton:setBtnInfo(info)
	if info == nil or next(info) == nil then return end
	self._btnInfo = info
	if self._btnInfo.btnMapInfo then
		local title = CCString:create(self._btnInfo.btnMapInfo.name or "")
		self._ccbOwner.btn_click:setTitleForState(title, CCControlStateNormal)
		self._ccbOwner.btn_click:setTitleForState(title, CCControlStateHighlighted)
		self._ccbOwner.btn_click:setTitleForState(title, CCControlStateDisabled)
	end	

	if self._btnInfo.finsh then
		self._ccbOwner.sp_pass:setVisible(true)
	else
		self._ccbOwner.sp_pass:setVisible(false)
	end
end

function QUIWidgetCollegeTrainChooseButton:setSelect(b)
	self._ccbOwner.btn_click:setHighlighted(b)
	self._ccbOwner.btn_click:setEnabled(not b)
end

function QUIWidgetCollegeTrainChooseButton:getChapterInfo( ... )
	return self._btnInfo
end
function QUIWidgetCollegeTrainChooseButton:onTriggerChapterClick()
	-- body
end

function QUIWidgetCollegeTrainChooseButton:getContentSize()
	return self._ccbOwner.cell_size:getContentSize()
end

return QUIWidgetCollegeTrainChooseButton
