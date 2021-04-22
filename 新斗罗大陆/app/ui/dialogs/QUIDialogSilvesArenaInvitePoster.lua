--
-- Kumo.Wang
-- 西尔维斯大斗魂场邀请弹脸
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaInvitePoster = class("QUIDialogSilvesArenaInvitePoster", QUIDialog)

local QRichText = import("...utils.QRichText") 
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogSilvesArenaInvitePoster:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_Invite_Poster.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
        {ccbCallbackName = "onTriggerFight", callback = handler(self, self._onTriggerFight)},
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogSilvesArenaInvitePoster.super.ctor(self,ccbFile,callBacks,options)

	self._sendInfo = options.sendInfo

	local rt = QRichText.new(nil, 400)

	local level = "LV."..self._sendInfo.teamLevel
	local name = self._sendInfo.nickname
	local fightForce = self._sendInfo.fightForce
    local num, unit = q.convertLargerNumber(fightForce)
    local force = num..(unit or "")

    local tfTbl = {}
    table.insert(tfTbl, {oType = "font", content = "魂师大人，", size = 24, color = COLORS.a})
    table.insert(tfTbl, {oType = "font", content = string.format("%s（战力：%s）", name, force), size = 24, color = COLORS.M})
    table.insert(tfTbl, {oType = "font", content = " 邀请您组队，是否前往？ ", size = 24, color = COLORS.a})
    rt:setString(tfTbl)
    rt:setAnchorPoint(ccp(0, 1))

    self._ccbOwner.tf_text:addChild(rt)

    self._isSelected = false
    self:showSelectState()
end

function QUIDialogSilvesArenaInvitePoster:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogSilvesArenaInvitePoster:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogSilvesArenaInvitePoster:_onTriggerCancel(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_jujue) == false then return end
	app.sound:playSound("common_cancel")
	remote.silvesArena:silvesArenaInviteRejectRequest(self._sendInfo.userId, function()
        if self._isSelected then
            remote.silvesArena.rejectInviteUserIdDict[self._sendInfo.userId] = q.serverTime()
        end
		self:popSelf()
	end)
end

function QUIDialogSilvesArenaInvitePoster:_onTriggerFight(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
	app.sound:playSound("common_confirm")
	self:popSelf()
    
	remote.silvesArena:silvesArenaJoinTeamRequest(self._sendInfo.teamId, function ()
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TO_CURRENT_PAGE)
        
        remote.silvesArena:openDialog()
        -- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockTeam"})
    end)
end

return QUIDialogSilvesArenaInvitePoster