-- @Author: xurui
-- @Date:   2019-06-18 17:01:21
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-10-31 19:08:56
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockSearchRoom = class("QUIDialogBlackRockSearchRoom", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIDialogBlackRockSearchRoom.SEARCH_ALERT = "SEARCH_ALERT"
QUIDialogBlackRockSearchRoom.CHANGE_PASSWORD_ALERT = "CHANGE_PASSWORD_ALERT"

function QUIDialogBlackRockSearchRoom:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_room1.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSearch", callback = handler(self, self._onTriggerSearch)},
		{ccbCallbackName = "onTriggerSavePassword", callback = handler(self, self._onTriggerSavePassword)},
		{ccbCallbackName = "onTriggerDelPassword", callback = handler(self,self._onTriggerDelPassword)}
    }
    QUIDialogBlackRockSearchRoom.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._alertType = options.alertType
    	self._chapterId = options.chapterId
    end
    self._teams = {}

	-- add input text box
    self._editBox = ui.newEditBox({ image = "ui/none.png", listener = function () end, size = CCSize(420, 50), })
    -- self._editBox:setPlaceholderFontColor(COLORS.g)
    self:showBtnByType(self._alertType)

    self._editBox:setFont(global.font_default, 26)
    self._editBox:setFontColor(COLORS.k)
    self._editBox:setMaxLength(20)
	self._editBox:setPlaceholderFontColor(UNITY_COLOR.brown)
    self._ccbOwner.node_editBox:addChild(self._editBox)
    self._editBox:registerScriptEditBoxHandler(function(returnType)
    		local text = self._editBox:getText()
    		self._editBox:setText(string.sub(text or "", 1, 6))    	
	end)
end

function QUIDialogBlackRockSearchRoom:showBtnByType(alertType)
    if alertType == QUIDialogBlackRockSearchRoom.CHANGE_PASSWORD_ALERT then
    	self._ccbOwner.title:setString("设置密码")
    	self._editBox:setPlaceHolder("请输入3~6位数字密码")
    	self._ccbOwner.node_Password:setVisible(true)
    	self._ccbOwner.node_btn_search:setVisible(false)
    	self._ccbOwner.btn_search:setTouchEnabled(false)
    	self._ccbOwner.btn_cancle:setTouchEnabled(true)
    	self._ccbOwner.btn_save:setTouchEnabled(true)    	
    else
    	self._editBox:setPlaceHolder("请输入队伍号码")
    	self._ccbOwner.node_Password:setVisible(false)
    	self._ccbOwner.node_btn_search:setVisible(true)
    	self._ccbOwner.btn_search:setTouchEnabled(true)
    	self._ccbOwner.btn_cancle:setTouchEnabled(false)
    	self._ccbOwner.btn_save:setTouchEnabled(false)
    end
end
function QUIDialogBlackRockSearchRoom:viewDidAppear()
	QUIDialogBlackRockSearchRoom.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogBlackRockSearchRoom:viewWillDisappear()
  	QUIDialogBlackRockSearchRoom.super.viewWillDisappear(self)
end

function QUIDialogBlackRockSearchRoom:setInfo()

end

function QUIDialogBlackRockSearchRoom:setPassWord(savePassWord)
	local callback = function(passWord)		
		self._isCallBack = true
		if passWord ~= nil and passWord ~= "" then
			app.tip:floatTip("密码已设置")
		else
			app.tip:floatTip("队伍已无密码")
		end
		self:viewAnimationOutHandler(passWord)
	end

	local requestFunc = function(passWord)
		remote.blackrock:blackRockSetPasswordRequest(passWord, function ()
			if self:safeCheck() then
				callback(passWord)
			end
		end)
	end

	local passWord = self._editBox:getText()
	if savePassWord then
		if passWord == nil or passWord == "" then
			app.tip:floatTip("密码不能为空")
			return
		end

		if tonumber(passWord) == nil or self:checkPassWordIsNumber(passWord) == false then
			app.tip:floatTip("请输入有效密码")
			return
		end

		local passWordState = self:checkPassWord(passWord)
		if passWordState == 1 then
			app.tip:floatTip("密码少于3位数")
			return
		elseif passWordState == 2 then
			app.tip:floatTip("密码超过6位数")
			return
		end
	else
		passWord = ""
	end
	requestFunc(passWord)
end

--1，密码少于3位数；2，密码大于六位数
function QUIDialogBlackRockSearchRoom:checkPassWord(passWord)
	local c,b
	local num = string.len(passWord)

    if num < 3 then
    	return 1
    elseif num > 6 then
    	return 2
    end
	return 0
end

--1，密码少于3位数；2，密码大于六位数
function QUIDialogBlackRockSearchRoom:checkPassWordIsNumber(passWord)
	local len = string.len(passWord)
    if len == 0 then return false end

    local i = 1
    local c,b
    while true do 
        c = string.sub(passWord,i,i)
        b = string.byte(c)
        if b > 57 or b < 48 then
        	return false
        end
        i = i + 1
        if i > string.len(passWord) then
            break
        end
    end

	return true
end

function QUIDialogBlackRockSearchRoom:_onTriggerSearch(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_search) == false then return end
	if self._editBox then
		local teamId = self._editBox:getText()

		if tonumber(teamId) == nil then
			app.tip:floatTip("请输入有效号码")
		end
		self:viewAnimationOutHandler(teamId)
	end
end

function QUIDialogBlackRockSearchRoom:_onTriggerSavePassword(event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_save) == false then return end
	self:setPassWord(true)
end

function QUIDialogBlackRockSearchRoom:_onTriggerDelPassword( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_cancle) == false then return end
	self:setPassWord(false)
end
function QUIDialogBlackRockSearchRoom:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBlackRockSearchRoom:_onTriggerClose()
  	app.sound:playSound("common_close")
  	self._isClose = true
	self:playEffectOut()
end

function QUIDialogBlackRockSearchRoom:viewAnimationOutHandler(editBoxNum)
	local callback = self._callBack

	self:popSelf()
	
		
	
	if callback then
		if self._alertType == QUIDialogBlackRockSearchRoom.CHANGE_PASSWORD_ALERT then
			callback()
		elseif self._isClose ~= true then
			self._teams = remote.blackrock:searchTeamById(editBoxNum)
		    -- remote.blackrock:blackRockGetChapterTeamListRequest(self._chapterId,editBoxNum, function (data)
		    --     local teams = data.blackRockGetChapterTeamListResponse.teams or {}
		    --     callback(teams)
		    -- end)	
			callback(self._teams)
		end
	end
end

return QUIDialogBlackRockSearchRoom
