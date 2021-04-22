local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockInviteAlert = class("QUIDialogBlackRockInviteAlert", QUIDialog)
local QRichText = import("...utils.QRichText") 
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogBlackRockInviteAlert:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_sdyq.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
        {ccbCallbackName = "onTriggerFight", callback = handler(self, self._onTriggerFight)},
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogBlackRockInviteAlert.super.ctor(self,ccbFile,callBacks,options)

	self._sendInfo = options.sendInfo

	local rt = QRichText.new(nil, 400)

	local level = "LV."..self._sendInfo.teamLevel
	local name = self._sendInfo.nickname
	local fightForce = self._sendInfo.fightForce
    local tfTbl = {}
    local num, unit = q.convertLargerNumber(fightForce)
    local force = num..(unit or "")
    local chapterInfo = remote.blackrock:getChapterById(self._sendInfo.chapterId)[1]
    local chapterName = chapterInfo.name
    local chapterForce = chapterInfo.monster_battleforce
    local num, unit = q.convertLargerNumber(chapterForce)
    chapterForce = num..(unit or "")
    local _,chapterColor = remote.blackrock:getColorById(tonumber(self._sendInfo.chapterId))
    table.insert(tfTbl, {oType = "font", content = "魂师大人，", size = 24, color = COLORS.a})
    -- table.insert(tfTbl, {oType = "font", content = string.format("%s（战力：%s）", name, force), size = 24, color = ccc3(255,255,0), strokeColor = ccc3(0, 0, 0), fontName = global.font_name})
    table.insert(tfTbl, {oType = "font", content = string.format("%s（战力：%s）", name, force), size = 24, color = COLORS.M})
    -- table.insert(tfTbl, {oType = "font", content = level..name, size = 24, color = ccc3(123,0,0)})
    table.insert(tfTbl, {oType = "font", content = " 邀请您组队攻打 ", size = 24, color = COLORS.a})
    -- table.insert(tfTbl, {oType = "font", content = string.format("%s（战力：%s）", chapterName, chapterForce), size = 24, color = chapterColor, strokeColor = ccc3(0, 0, 0), fontName = global.font_name})
    table.insert(tfTbl, {oType = "font", content = string.format("%s（战力：%s）", chapterName, chapterForce), size = 24, color = chapterColor})    
    table.insert(tfTbl, {oType = "font", content = " ，是否前往？", size = 24, color = COLORS.a})
    rt:setString(tfTbl)
    rt:setAnchorPoint(ccp(0, 1))

    self._ccbOwner.tf_text:addChild(rt)

    self._isSelected = false
    self:showSelectState()
end


function QUIDialogBlackRockInviteAlert:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogBlackRockInviteAlert:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogBlackRockInviteAlert:_onTriggerCancel(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_jujue) == false then return end
	app.sound:playSound("common_cancel")
	remote.blackrock:blackRockInviteRejectRequest(self._sendInfo.userId,function ()
        if self._isSelected then
            remote.blackrock.rejectInviteUserIdDict[self._sendInfo.userId] = q.serverTime()
        end
		self:popSelf()
	end)
end

function QUIDialogBlackRockInviteAlert:_onTriggerFight(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
	app.sound:playSound("common_confirm")
	self:enableTouchSwallowTop()
	self:popSelf()
	local callFun = function ()
		remote.blackrock:blackRockJoinTeamRequest(self._sendInfo.teamId, self._sendInfo.chapterId, nil,2,function ()
			--xurui: 更新组队聊天信息
			app:getServerChatData():refreshTeamChatInfo()

	        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
	        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TO_CURRENT_PAGE)

			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockTeam"})
		end)
	end
    if remote.blackrock:getAwardCount() > 0 then
        callFun()
    else
        local content = "魂师大人，您当前已无领奖次数，战斗结束将无法获得奖励，是否继续？"
        app:alert({content = content, colorful = true, title = "系统提示", callback = function (type)
            if type == ALERT_TYPE.CONFIRM then
                callFun()
            elseif type == ALERT_TYPE.CANCEL then
				remote.blackrock:blackRockInviteRejectRequest(self._sendInfo.userId)
            end
        end}, false)
    end
end

return QUIDialogBlackRockInviteAlert