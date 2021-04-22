-- @Author: liaoxianbo
-- @Date:   2019-06-24 16:45:38
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-02 15:43:09

local QUIDialog = import(".QUIDialog")
local QUIDialogBlackRockJoinTeam = class("QUIDialogBlackRockJoinTeam", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIDialogBlackRockJoinTeam.SEARCH_ALERT = "SEARCH_ALERT"
QUIDialogBlackRockJoinTeam.CHANGE_PASSWORD_ALERT = "CHANGE_PASSWORD_ALERT"

function QUIDialogBlackRockJoinTeam:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_room2.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogBlackRockJoinTeam._onTriggerCancel)},
		{ccbCallbackName = "onTriggerJoin", callback = handler(self, QUIDialogBlackRockJoinTeam._onTriggerJoin)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogBlackRockJoinTeam._onTriggerClose)},
	}
	QUIDialogBlackRockJoinTeam.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	if options then
		self._teamInfo = options.teamInfo
		self._chapterId = options.chapterId
		self._callback = options.callback
		self._teamType = options.teamType
	end
	self._joinSuccess = false

	-- add input text box
    self._editBox = ui.newEditBox({
    	image = "ui/none.png", 
    	listener = function () end, 
    	size = CCSize(448, 40),
    })
	self._editBox:setInputFlag(kEditBoxInputFlagPassword)
	self._editBox:setPlaceHolder("请输入队伍密码")
    self._editBox:setFont(global.font_default, 24)
    self._editBox:setMaxLength(20)
    self._ccbOwner.comment:addChild(self._editBox)
end

function QUIDialogBlackRockJoinTeam:viewDidAppear()
    QUIDialogBlackRockJoinTeam.super.viewDidAppear(self)

    self:setInfo()
end

function QUIDialogBlackRockJoinTeam:viewWillDisappear()
    QUIDialogBlackRockJoinTeam.super.viewWillDisappear(self)
end

function QUIDialogBlackRockJoinTeam:setInfo()
	self._ccbOwner.frame_tf_title:setString("队伍号:"..self._teamInfo.symbol)
	self._ccbOwner.tf_server:setString(self._teamInfo.leader.game_area_name or "")
	local name = self._teamInfo.leader.name or ""
	self._ccbOwner.tf_level:setString("LV."..self._teamInfo.leader.level.." "..name)
	-- local teamNum = remote.blackrock:showTeamNum(self._teamInfo.symbol)
	self._ccbOwner.tf_team:setString("队伍人数："..self._teamInfo.memberCnt.."/3")

	local force = self._teamInfo.leader.topnForce or 0
	local num,uint = q.convertLargerNumber(force)
	self._ccbOwner.tf_force:setString(num..(uint or ""))
end

function QUIDialogBlackRockJoinTeam:_onTriggerCancel(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_cancle) == false then return end
	app.sound:playSound("common_cancel")

	self:_onTriggerClose()
end

function QUIDialogBlackRockJoinTeam:_onTriggerJoin(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_join) == false then return end
	app.sound:playSound("common_confirm")

	self:setPassWord()
end

function QUIDialogBlackRockJoinTeam:setPassWord()
	local callback = function()
		app.tip:floatTip("指挥官，您已加入房间~")

		self._joinSuccess = true
		self:popSelf()
		app:getServerChatData():refreshTeamChatInfo()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockTeam"})		
	end

	local requestFunc = function(passWord)
		remote.blackrock:blackRockJoinTeamRequest(self._teamInfo.teamId, self._chapterId, passWord, 0,function()
			if self:safeCheck() then
				callback()
			end
		end, function()
			self._editBox:setText("")
			app.tip:floatTip("密码错误，重新输入")
		end)
	end

	local passWord = self._editBox:getText()
	if passWord == nil or passWord == "" then
		app.tip:floatTip("队伍密码不能为空")
		return
	end

	requestFunc(passWord)
end

function QUIDialogBlackRockJoinTeam:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBlackRockJoinTeam:_onTriggerClose(e)
	if e ~= nil then
		app.sound:playSound("common_cancel")
	end
    self:playEffectOut()
end

function QUIDialogBlackRockJoinTeam:viewAnimationOutHandler()
	local callback = self._callback

    self:popSelf()

    if self._joinSuccess and callback then
    	callback()
    end
end

return QUIDialogBlackRockJoinTeam