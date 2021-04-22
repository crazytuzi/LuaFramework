--
-- zxs
-- 精英赛报名
--

local QUIWidget = import("..QUIWidget")
local QUIWidgetSanctuaryRegister = class("QUIWidgetSanctuaryRegister", QUIWidget)

local QUIWidgetSanctuaryAvatar = import(".QUIWidgetSanctuaryAvatar")
local QSanctuaryDefenseArrangement = import("....arrangement.QSanctuaryDefenseArrangement")
local QUIViewController = import("....ui.QUIViewController")
local QVIPUtil = import("....utils.QVIPUtil")
local QChatDialog = import("....utils.QChatDialog")

function QUIWidgetSanctuaryRegister:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary_Register.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSign", callback = handler(self, self._onTriggerSign)},
        {ccbCallbackName = "onTriggerAutoSign", callback = handler(self, self._onTriggerAutoSign)},
	}
	QUIWidgetSanctuaryRegister.super.ctor(self,ccbFile,callBacks,options)

	self:switchState()
end

function QUIWidgetSanctuaryRegister:onEnter()
	QUIWidgetSanctuaryRegister.super.onEnter(self)

	self._sanctuaryProxy = cc.EventProxy.new(remote.sanctuary)
	self._sanctuaryProxy:addEventListener(remote.sanctuary.EVENT_SANCTUARY_AUTO_SIGNUP, handler(self, self.updateAutoSignUp))
end

function QUIWidgetSanctuaryRegister:onExit()
	QUIWidgetSanctuaryRegister.super.onExit(self)
	
	if self._sanctuaryProxy ~= nil then
		self._sanctuaryProxy:removeAllEventListeners()
		self._sanctuaryProxy = nil
	end
end

function QUIWidgetSanctuaryRegister:switchState()
	self._ccbOwner.node_sign:setVisible(false)
	self._ccbOwner.node_signed:setVisible(false)
	self._ccbOwner.node_auto_sign:setVisible(false)
	self._ccbOwner.node_tips:removeAllChildren()
	self._ccbOwner["tf_name1"]:setVisible(true)
	self._ccbOwner["tf_server1"]:setVisible(true)

	local myInfo = remote.sanctuary:getSanctuaryMyInfo()
	--是否自动报名
	self._isAutoSign = myInfo.autoSignUp or false
	self._ccbOwner.sp_select:setVisible(self._isAutoSign)

	self._ccbOwner.node_auto_sign:setPositionY(0)
	local state = remote.sanctuary:getState()
	if state == remote.sanctuary.STATE_REGISTER then
		if myInfo.signUp == true then
			self._ccbOwner.node_signed:setVisible(true)
		else
			self._ccbOwner.node_sign:setVisible(true)
		end
		self._ccbOwner.node_auto_sign:setPositionY(-20)
		self._ccbOwner.node_auto_sign:setVisible(true)
	elseif state == remote.sanctuary.STATE_MATCH_OPPONENT then
		if myInfo.signUp == true then
			self._ccbOwner.node_signed:setVisible(true)
			self._ccbOwner.node_auto_sign:setPositionY(-20)
		end
	end

	self._fighter = QUIWidgetSanctuaryAvatar.new()
	self._ccbOwner.node_avatar1:addChild(self._fighter)
	self._fighter:setVisible(false)
	self._ccbOwner["tf_name1"]:setVisible(false)
	self._ccbOwner["tf_server1"]:setVisible(false)

	local championFighter = remote.sanctuary:getChampionFighter()
	if championFighter then
		self._fighter:setVisible(true)
		self._fighter:setInfo(championFighter)
		self._fighter:setShowInfo(false)
		self._fighter:setAvatarScaleX(-1)

		self._ccbOwner["tf_name1"]:setVisible(true)
		self._ccbOwner["tf_server1"]:setVisible(true)
		self._ccbOwner["tf_name1"]:setString(championFighter.name)
		self._ccbOwner["tf_server1"]:setString(championFighter.game_area_name)

		local wordWidget = QChatDialog.new()
		self._ccbOwner.node_tips:addChild(wordWidget)
		wordWidget:setPositionX(50)
		wordWidget:setString("想击败我成为新的王者吗，快来报名吧！")
	end
end

--点击报名
function QUIWidgetSanctuaryRegister:updateAutoSignUp()
    local myInfo = remote.sanctuary:getSanctuaryMyInfo()
	self._isAutoSign = myInfo.autoSignUp
	self._ccbOwner.sp_select:setVisible(self._isAutoSign)
	if self._isAutoSign then
		app.tip:floatTip("自动报名选择成功")
	else
		app.tip:floatTip("自动报名取消成功")
	end
end

--点击报名
function QUIWidgetSanctuaryRegister:_signUp(callback)
	local sanctuaryDefenseArrangement1 = QSanctuaryDefenseArrangement.new({teamKey = remote.teamManager.SANCTUARY_DEFEND_TEAM1, isSign = true})
	local sanctuaryDefenseArrangement2 = QSanctuaryDefenseArrangement.new({teamKey = remote.teamManager.SANCTUARY_DEFEND_TEAM2, isSign = true})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
		options = {arrangement1 = sanctuaryDefenseArrangement1, arrangement2 = sanctuaryDefenseArrangement2, onConfirm = callback, defense = true, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo"}})
	app.tip:floatTip("魂师大人，请您上传您的参赛阵容")
end

--点击报名
function QUIWidgetSanctuaryRegister:_onTriggerSign(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_sign) == false then return end
    app.sound:playSound("common_small")

    self:_signUp()
end

--点击报名
function QUIWidgetSanctuaryRegister:_onTriggerAutoSign()
    app.sound:playSound("common_small")

	local value = db:getConfiguration()["sanctuary_war_auto_sign_vip"].value or 6
	if QVIPUtil:VIPLevel() < value then
		app.tip:floatTip(string.format("魂师大人,VIP等级达到%d级才可以勾选自动报名哦~", value))
		return 
	end
	
	local callback = function()
		remote.sanctuary:sanctuaryWarAutoSignUpRequest(not self._isAutoSign)
	end
	local defense = remote.sanctuary:getSanctuaryDefense()
	if not defense or not defense.armyForce or defense.armyForce == 0 then
    	self:_signUp(callback)
		return
	else
		callback()
	end
end

return QUIWidgetSanctuaryRegister