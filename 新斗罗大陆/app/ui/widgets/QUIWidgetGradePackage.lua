-- @Author: liaoxianbo
-- @Date:   2019-07-08 10:35:20
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-07-31 19:05:05
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGradePackage = class("QUIWidgetGradePackage", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGradePackageContent = import("..widgets.QUIWidgetGradePackageContent")
local QListView = import("...views.QListView")
local QPayUtil = import("...utils.QPayUtil")

function QUIWidgetGradePackage:ctor(options)
	local ccbFile = "ccb/Widget_Activity_GradePackage.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetGradePackage.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetGradePackage:setInfo(info,unlockTime,dialogGradePackage)
	self._dialogGradePackage = dialogGradePackage
	self._contentInfo = info
	if self._contentInfo and next(self._contentInfo) ~= nil then
		self._ccbOwner.tf_type_contentdes:setString(self._contentInfo[1].desc)
	else
		self._ccbOwner.tf_type_contentdes:setString("")
	end
	self._unlockTime = unlockTime
	self:updateUnlockTime()
	self:initContentListView()
end

function QUIWidgetGradePackage:initContentListView()
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._contentInfo[index]

	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetGradePackageContent.new()
	                isCacheNode = false
	            end
	 			item:addEventListener(QUIWidgetGradePackageContent.UPDATE_BUYSTATE, handler(self, self._onEvent))
	            item:setContentInfo(data,self)
                info.item = item
                info.size = item:getContentSize()
	       		list:registerBtnHandler(index, "btn_config", "_onTriggerConfirm", nil, true)
	       		list:registerBtnHandler(index, "btn_click", "onTriggerItemClick")
	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = true,
	        totalNumber = #self._contentInfo,

	    }  
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._contentInfo})
	end 
end

function QUIWidgetGradePackage:updateUnlockTime( )
	if not self._unlockTime then 
		self._ccbOwner.node_time_countdown:setVisible(false)
		return 
	end
	self._ccbOwner.node_time_countdown:setVisible(true)
	self:_updateTime()
	if self._schedulerUnLockTime then
		scheduler.unscheduleGlobal(self._schedulerUnLockTime)
		self._schedulerUnLockTime = nil
	end
	self._schedulerUnLockTime = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)
end

function QUIWidgetGradePackage:_updateTime()
	local isOvertime, timeStr, color = remote.gradePackage:updateTime(self._unlockTime)
	self._ccbOwner.tf_huodong_time:setColor(color)
	if not isOvertime then
		self._ccbOwner.tf_huodong_time:setString(timeStr)
	else
		self._ccbOwner.tf_huodong_time:setString("00:00:00")
		if self._schedulerUnLockTime then
			scheduler.unscheduleGlobal(self._schedulerUnLockTime)
			self._schedulerUnLockTime = nil
		end

		self._timeHandler = scheduler.performWithDelayGlobal(function()
			self._dialogGradePackage:initBtnListView()
		end, 0.5) 
	end
end

function QUIWidgetGradePackage:_onEvent( event )
	if event.name == QUIWidgetGradePackageContent.UPDATE_BUYSTATE then
		if event.type ~= 2 then
			remote.gradePackage:requestGetGradePackage(event.id,event.count,function(data)
				self._dialogGradePackage:initBtnListView(true)
	            local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	            options = {awards = event.awards}},{isPopCurrentDialog = false} )
	            dialog:setTitle("")			
			end)
		else
			self._dialogGradePackage:fastBuy(event.much_num,event.id)
		end
	end
end

function QUIWidgetGradePackage:onEnter()
end

function QUIWidgetGradePackage:onExit()
	if self._schedulerUnLockTime then
		scheduler.unscheduleGlobal(self._schedulerUnLockTime)
		self._schedulerUnLockTime = nil
	end

    if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end

function QUIWidgetGradePackage:getContentSize()
end

return QUIWidgetGradePackage
