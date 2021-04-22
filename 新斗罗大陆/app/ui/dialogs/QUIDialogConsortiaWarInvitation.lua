-- 
-- zxs
-- 精英赛邀请
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogConsortiaWarInvitation = class("QUIDialogConsortiaWarInvitation", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QConsortiaWarDefenseArrangement = import("...arrangement.QConsortiaWarDefenseArrangement")

function QUIDialogConsortiaWarInvitation:ctor(options)
	local ccbFile = "ccb/Dialog_Sanctuary_open.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
		{ccbCallbackName = "onTriggerBack", callback = handler(self, self._onTriggerBack)},
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
		{ccbCallbackName = "onTriggerChangeTeam", callback = handler(self,self._onTriggerChangeTeam)}
	}
	QUIDialogConsortiaWarInvitation.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	self._callback = options.callback
end

function QUIDialogConsortiaWarInvitation:viewDidAppear()
	QUIDialogConsortiaWarInvitation.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogConsortiaWarInvitation:viewWillDisappear()
	QUIDialogConsortiaWarInvitation.super.viewWillDisappear(self)
end

function QUIDialogConsortiaWarInvitation:setInfo()
	self._ccbOwner.btn_normal:setVisible(false)
	self._ccbOwner.btn_back:setVisible(false)
	self._ccbOwner.btn_ok:setVisible(false)
	self._ccbOwner.btn_changeTeam:setVisible(false)
	self._ccbOwner.btn_ok:setPositionX(202)
	

	local richText = QRichText.new({}, 400)
	richText:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.node_desc:addChild(richText)

    local state = remote.consortiaWar:getStateAndNextStateAt()
    if state == remote.consortiaWar.STATE_NONE then
    	richText:setString({
			{oType = "font", content = "宗门战将于下周一开启，敬请期待！", size = 22, color = GAME_COLOR_SHADOW.normal},
	    })
    	self._ccbOwner.btn_ok:setVisible(true)
    	self._ccbOwner.btn_changeTeam:setVisible(true)
    	self._ccbOwner.btn_ok:setPositionX(102)
    	self._ccbOwner.tf_ok:setString("确定")
		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("union_war_show_title")[3])
	else
	    local consortiaName = remote.user.userConsortia.consortiaName or ""
		richText:setString({
	        {oType = "font", content = consortiaName, size = 22, color = GAME_COLOR_SHADOW.stress},
			{oType = "font", content = "宗门的各位魂师大人，本周", size = 22, color = GAME_COLOR_SHADOW.normal},
	        {oType = "font", content = "宗门战", size = 22, color = GAME_COLOR_SHADOW.stress},
	        {oType = "font", content = "开启，请配合宗主和各位堂主做好战斗准备，大干一场！", size = 22, color = GAME_COLOR_SHADOW.normal},
	    })
	    self._ccbOwner.btn_normal:setVisible(true)
    	self._ccbOwner.btn_back:setVisible(true)
		QSetDisplayFrameByPath(self._ccbOwner.sp_title, QResPath("union_war_show_title")[2])
	end
	QSetDisplayFrameByPath(self._ccbOwner.sp_image, QResPath("union_war_show_title")[1])
	self._ccbOwner.sp_image:setPositionX(self._ccbOwner.sp_image:getPositionX() - 100)
end

function QUIDialogConsortiaWarInvitation:_onTriggerOk( event )
	if q.buttonEventShadow(event, self._ccbOwner.button_ok) == false then return end
	self:viewAnimationOutHandler()

	if remote.consortiaWar:checkGameShowTips() then
		remote.consortiaWar:openDialog()
	end
end

function QUIDialogConsortiaWarInvitation:_onTriggerGo(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_normal) == false then return end
	self:viewAnimationOutHandler()

	if remote.consortiaWar:checkGameShowTips() then
		remote.consortiaWar:openDialog()
	end
end

function QUIDialogConsortiaWarInvitation:_onTriggerBack(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_back) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogConsortiaWarInvitation:_onTriggerChangeTeam( event )
	if q.buttonEventShadow(event, self._ccbOwner.button_change) == false then return end
  	app.sound:playSound("common_close")
  	
  	self:viewAnimationOutHandler()

	local consortiaWarDefenseArrangement1 = QConsortiaWarDefenseArrangement.new({teamKey = remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM1})
	local consortiaWarDefenseArrangement2 = QConsortiaWarDefenseArrangement.new({teamKey = remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM2})
	local dialog = app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
		options = {arrangement1 = consortiaWarDefenseArrangement1, arrangement2 = consortiaWarDefenseArrangement2, defense = true, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo"}})

end
function QUIDialogConsortiaWarInvitation:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogConsortiaWarInvitation:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogConsortiaWarInvitation:viewAnimationOutHandler()
    self:popSelf()
	if self._callback then
		self._callback()
	end
end

return QUIDialogConsortiaWarInvitation