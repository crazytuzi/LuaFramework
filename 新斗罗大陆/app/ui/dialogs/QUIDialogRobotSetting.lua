--
-- Author: Kumo
-- Date: 2014-07-14 15:41:41
-- 一键扫荡设置外框
--
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogRobotSetting = class("QUIDialogRobotSetting", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetRobotSettingForDungeon = import("..widgets.QUIWidgetRobotSettingForDungeon")
local QUIWidgetRobotSettingForInvasion = import("..widgets.QUIWidgetRobotSettingForInvasion")
local QScrollView = import("...views.QScrollView") 

function QUIDialogRobotSetting:ctor(options)
    local ccbFile = "ccb/Dialog_RobotSetting.ccbi"
    local callBacks = 
    {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
        {ccbCallbackName = "onTriggerSave", callback = handler(self, self._onTriggerSave)},
        {ccbCallbackName = "onTriggerSettingForDungeon", callback = handler(self, self._onTriggerSettingForDungeon)},
        {ccbCallbackName = "onTriggerSettingForInvasion", callback = handler(self, self._onTriggerSettingForInvasion)},
    }
    QUIDialogRobotSetting.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true
    self._isSaved = false

    -- self._list = options.list
    self._robotType = options.robotType
    self._robotTargetID = options.targetID
    self._robotEliteList = options.robotEliteList
    self._robotNormalList = options.robotNormalList

    self._settingWidget = nil

    -- self._ccbOwner.tf_btn_setting_dungeon = setShadow5(self._ccbOwner.tf_btn_setting_dungeon)
    -- self._ccbOwner.tf_btn_setting_invasion = setShadow5(self._ccbOwner.tf_btn_setting_invasion)

    self._isFirstClick = app:getUserOperateRecord():getRecordByType("robot_setting_first_click") or 0
    self._ccbOwner.sp_invasion_tips:setVisible(self._isFirstClick == 0)
    self:initScrollView()
end

function QUIDialogRobotSetting:initScrollView()
    local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setGradient(false)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewEvent))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewEvent))
end

function QUIDialogRobotSetting:_onScrollViewEvent(event)
    if event.name == QScrollView.GESTURE_MOVING then
        self._isMoving = true
    elseif event.name == QScrollView.GESTURE_BEGAN then
        self._isMoving = false
    end
end

function QUIDialogRobotSetting:viewDidAppear()
    QUIDialogRobotSetting.super.viewDidAppear(self)

    self:_onTriggerSettingForDungeon()
end

function QUIDialogRobotSetting:viewWillDisappear()
    QUIDialogRobotSetting.super.viewWillDisappear(self)
end

function QUIDialogRobotSetting:_onTriggerSettingForDungeon()
	self._ccbOwner.btn_setting_dungeon:setHighlighted(true)

	if self._curType == remote.robot.DUNGEON then return end 

	self._curType = remote.robot.DUNGEON
    self._ccbOwner.btn_setting_invasion:setHighlighted(false)

    if self._settingWidget then
    	self._settingWidget:removeFromParent()
    	self._settingWidget = nil
    end
    self._scrollView:clear()

    self._settingWidget = QUIWidgetRobotSettingForDungeon.new( {robotType = self._robotType, targetID = self._robotTargetID, robotEliteList = self._robotEliteList, robotNormalList = self._robotNormalList} )
    if self._robotType == remote.robot.MATERIAL then
        self._settingWidget:setPosition(210, -232)
    else
        self._settingWidget:setPosition(210, -212)
    end
    self._scrollView:addItemBox( self._settingWidget )
    self._scrollView:setVerticalBounce(false)
end

function QUIDialogRobotSetting:_onTriggerSettingForInvasion()
	self._ccbOwner.btn_setting_invasion:setHighlighted(true)
	
	if self._curType == remote.robot.INVASION then return end 

	self._curType = remote.robot.INVASION
    self._ccbOwner.btn_setting_dungeon:setHighlighted(false)
    self._ccbOwner.sp_invasion_tips:setVisible(false)
    if self._isFirstClick == 0 then
        app:getUserOperateRecord():setRecordByType("robot_setting_first_click", 1)
    end
    self._isFirstClick = 1

    if self._settingWidget then
    	self._settingWidget:removeFromParent()
    	self._settingWidget = nil
    end
    self._scrollView:clear()

    self._settingWidget = QUIWidgetRobotSettingForInvasion.new()
    self._settingWidget:setPosition(230, -230)
    self._scrollView:addItemBox( self._settingWidget )
    local contentSize = self._settingWidget:getContentSize()
    self._scrollView:setRect(0, -contentSize.height, 0, 0)
    self._scrollView:setVerticalBounce(true)
end

function QUIDialogRobotSetting:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    if not self._isSaved then
        app.tip:floatTip("魂师大人，您选择了关闭，当前设置变动将不会保存～")
    end
    remote.robot:giveUpSetting( handler(self, self.close) )
end

function QUIDialogRobotSetting:_onTriggerCancel(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_cancle) == false then return end
    remote.robot:giveUpSetting( handler(self, self.close) )
end

function QUIDialogRobotSetting:_onTriggerSave(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_save) == false then return end
    if self._isFirstClick == 0 then
        app:alert({content = "魂师大人，您还未设置自动攻打功能，是否前往设置", title = "系统提示", btnDesc = {"前往设置", "继续保存"}, callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                self:_onTriggerSettingForInvasion()
            elseif state == ALERT_TYPE.CANCEL then
                self._isSaved = true
                remote.robot:saveSetting( handler(self, self.close) )
            end
        end}, false, true)
    else
        self._isSaved = true
	    remote.robot:saveSetting( handler(self, self.close) )
    end
end

function QUIDialogRobotSetting:close()
	if self._curType == remote.robot.DUNGEON and not app:getUserOperateRecord():hasRobotInvasionSetting() then
    	if (self._robotType == remote.robot.MATERIAL and remote.robot:getAutoMaterialInvasion()) 
    		or (self._robotType == remote.robot.SOUL and remote.robot:getAutoSoulInvasion()) then
    		app.tip:floatTip("需要进行魂兽入侵相关设置")
    		self:_onTriggerSettingForInvasion()
    		return
    	end
    end
    app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogRobotSetting:viewAnimationOutHandler()
    self:popSelf()
end

function QUIDialogRobotSetting:_backClickHandler()
    self:_onTriggerClose()
end

return QUIDialogRobotSetting