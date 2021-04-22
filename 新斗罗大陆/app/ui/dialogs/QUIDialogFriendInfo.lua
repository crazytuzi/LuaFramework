local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFriendInfo = class("QUIDialogFriendInfo", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")
local QUIViewController = import("..QUIViewController")
local QFriendArrangement = import("...arrangement.QFriendArrangement")

function QUIDialogFriendInfo:ctor(options)
 	local ccbFile = "ccb/Dialog_Friend_information.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerBlack", callback = handler(self, QUIDialogFriendInfo._onTriggerBlack)},
	    {ccbCallbackName = "onTriggerAdd", callback = handler(self, QUIDialogFriendInfo._onTriggerAdd)},
	    {ccbCallbackName = "onTriggerDelete", callback = handler(self, QUIDialogFriendInfo._onTriggerDelete)},
	    {ccbCallbackName = "onTriggerChat", callback = handler(self, QUIDialogFriendInfo._onTriggerChat)},
	    {ccbCallbackName = "onTriggerPK", callback = handler(self, QUIDialogFriendInfo._onTriggerPK)},
	    {ccbCallbackName = "onTriggerDetail", callback = handler(self, QUIDialogFriendInfo._onTriggerDetail)},
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogFriendInfo._onTriggerClose)},
	}
	QUIDialogFriendInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._ccbOwner.frame_tf_title:setString("玩家信息")
	self._info = options.info
	self._fromChat = options.fromChat
	self._ccbOwner.tf_name:setString("")
	local num,unit = q.convertLargerNumber(self._info.force)
	self._ccbOwner.tf_battleforce:setString(num..(unit or ""))
	if self._info.consortiaId == nil or self._info.consortiaId == "" then
		self._ccbOwner.tf_uion_name:setString("没有宗门")
	else
		self._ccbOwner.tf_uion_name:setString((self._info.consortiaName or ""))
	end
	if self._avatar == nil then
    	self._avatar = QUIWidgetAvatar.new(self._info.avatar)
    	self._avatar:setSilvesArenaPeak(self._info.championCount)
    	self._ccbOwner.node_avatar:addChild(self._avatar)
	else
		self._avatar:setInfo(self._info.avatar)
	end
	self._clickCallback = options.clickCallback

	local vipLevel = options.vip_level or self._info.vipLevel
	local teamLevel = options.level or self._info.teamLevel
	if self._fromChat then
		self._ccbOwner.friendNode:setVisible(false)
		self._ccbOwner.vip_level:setString("VIP"..(vipLevel or 1))
		self._ccbOwner.tf_level:setString("LV." ..(teamLevel or 1).." "..(self._info.nickname or ""))
		if not options.consortiaName or options.consortiaName == "" then
			self._ccbOwner.tf_uion_name:setString("没有宗门")
		else
			self._ccbOwner.tf_uion_name:setString(options.consortiaName)
		end
	else
		self._ccbOwner.vip_level:setString("VIP"..(vipLevel or 1))
		self._ccbOwner.tf_level:setString("LV." ..(teamLevel or 1).." "..(self._info.nickname or ""))
		self._ccbOwner.friendNode:setVisible(true)
	end

	if remote.friend:checkIsFriendByUserId(self._info.user_id) then
		self._ccbOwner.node_delete:setVisible(true)
		self._ccbOwner.node_add:setVisible(false)
	else
		self._ccbOwner.node_delete:setVisible(false)
		self._ccbOwner.node_add:setVisible(true)
	end
end

function QUIDialogFriendInfo:_onTriggerBlack(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_black) == false then return end
    app.sound:playSound("common_small")
	if not app.unlock:getUnlockFriend() then
		app.tip:floatTip("魂师大人，您的好友功能尚未开启，暂时无法使用该功能")
		return
	end
	if remote.friend:checkIsBlackedByUserId(self._info.user_id) == true then
		app.tip:floatTip("该玩家已经在您的黑名单中")
		return
	end
	app:alert({content="拉入黑名单？",title="系统提示",callback=function (state)
		if state == ALERT_TYPE.CONFIRM then
			remote.friend:apiUserDeleteFriendRequest(self._info.user_id, true)
			app:getServerChatData():deleteMessage(self._info.user_id, self._info.user_id)
			if self._clickCallback then
				self._clickCallback(2)
			end
			self:close()
		end
	end}, false)
end

function QUIDialogFriendInfo:_onTriggerDelete(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_delete) == false then return end
    app.sound:playSound("common_small")
	app:alert({content="您确认要删除这个好友吗？",btnDesc = {"删除好友"}, btns = {ALERT_BTN.BTN_OK_RED, ALERT_BTN.BTN_CANCEL},title="系统提示",
		callback=function (state)
			if state == ALERT_TYPE.CONFIRM then
				remote.friend:apiUserDeleteFriendRequest(self._info.user_id, false)
				self:close()
			end
		end}, false)
end

function QUIDialogFriendInfo:_onTriggerAdd(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_add) == false then return end
    app.sound:playSound("common_small")
	app:alert({content="您确认要添加这个好友吗？",title="系统提示",
		callback=function (state)
			if state == ALERT_TYPE.CONFIRM then
				remote.friend:apiUserApplyFriendRequest(self._info.user_id, nil, function ()
        			app.tip:floatTip("已经发送申请，等待批准！")
				end)
				self:close()
			end
		end}, false)
end

function QUIDialogFriendInfo:_onTriggerChat(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_chat) == false then return end
    app.sound:playSound("common_small")
	if remote.friend:checkIsBlackedByUserId(self._info.user_id) == true then
		app.tip:floatTip("该玩家已经在您的黑名单中无法与其私聊")
		return
	end
	self:viewAnimationOutHandler()
	if self._clickCallback then
		self._clickCallback(1)
	else
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChat", 
	        options = {initTab = "onTriggerPrivate", force = true, effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth", 
	        			initChatter = {userId = self._info.user_id, nickName = self._info.nickname, avatar = self._info.avatar}}}, {isPopCurrentDialog = false})
   	end		
end

function QUIDialogFriendInfo:_onTriggerPK(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_pk) == false then return end
    app.sound:playSound("common_small")

	remote.friend:apiUserFightFriendStartRequest(self._info.user_id, function ()
		if self:safeCheck() == false then return end

		if app.unlock:checkLock("UNLOCK_SOLO_DOUBLE") then

			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogFriendChooseTeam",
				options = {userId = self._info.user_id}}, {isPopCurrentDialog = true})
		else 
			app:getClient():arenaQueryDefenseHerosRequest(self._info.user_id, function(data)
				if self:safeCheck() == false then return end
				if self._clickCallback then
			    	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
				end

				self._info.fighterInfo = data.arenaResponse
				self:startPK()
			end)
		end
	end)
end

function QUIDialogFriendInfo:startPK()

	local fighter = self._info.fighterInfo.mySelf
	fighter.name = self._info.nickname
	fighter.avatar = self._info.avatar
	if fighter.heros == nil or table.nums(fighter.heros) == 0 then
		app.tip:floatTip("魂师大人，对方没有魂师敢出战，饶了他吧！")
		return
	end

	local myInfo = {}
	local dungeonArrangement = QFriendArrangement.new({rivalInfo = fighter, myInfo = myInfo, teamKey = remote.teamManager.ARENA_ATTACK_TEAM})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
     	options = {arrangement = dungeonArrangement, isQuickWay = self.isQuickWay}})
end

function QUIDialogFriendInfo:_onTriggerDetail(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_detail) == false then return end
    app.sound:playSound("common_small")
	-- if self._info.fighterInfo == nil then
		app:getClient():arenaQueryDefenseHerosRequest(self._info.user_id, function(data)
			self._info.fighterInfo = data.arenaResponse
			self:showDetailByFighterInfo()
		end)
	-- else
	-- 	self:showDetailByFighterInfo()
	-- end
end

function QUIDialogFriendInfo:showDetailByFighterInfo()
	local fighter = self._info.fighterInfo.mySelf
	if fighter == nil then return end
	
	if app.unlock:checkLock("UNLOCK_SOLO_DOUBLE") then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogFriendPlayer",
			options = {fighter = fighter}}, {isPopCurrentDialog = false})
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
			options = {fighter = fighter}}, {isPopCurrentDialog = false})
	end
end

function QUIDialogFriendInfo:_onTriggerClose()
    app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogFriendInfo:close()
	self:playEffectOut()
end

function QUIDialogFriendInfo:_backClickHandler()
	self:playEffectOut()
end

function QUIDialogFriendInfo:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogFriendInfo