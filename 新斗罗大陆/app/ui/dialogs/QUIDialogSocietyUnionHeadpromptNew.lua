--[[	
	文件名称：QUIDialogSocietyUnionHeadpromptNew.lua
	创建时间：2016-03-25 12:00:59
	作者：nieming
	描述：QUIDialogSocietyUnionHeadpromptNew
]]

local QUIDialog = import(".QUIDialog")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogSocietyUnionHeadpromptNew = class("QUIDialogSocietyUnionHeadpromptNew", QUIDialog)
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QFriendArrangement = import("...arrangement.QFriendArrangement")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIViewController = import("..QUIViewController")
local QUIDialogUnionAnnouncement = import(".QUIDialogUnionAnnouncement")

--初始化
function QUIDialogSocietyUnionHeadpromptNew:ctor(options)
	local ccbFile = "Dialog_society_union_headprompt_new.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, QUIDialogSocietyUnionHeadpromptNew._onTriggerDetail)},
		{ccbCallbackName = "onTriggerFight", callback = handler(self, QUIDialogSocietyUnionHeadpromptNew._onTriggerFight)},
		{ccbCallbackName = "onTriggerChat", callback = handler(self, QUIDialogSocietyUnionHeadpromptNew._onTriggerChat)},
		{ccbCallbackName = "onTriggerBtn1", callback = handler(self, QUIDialogSocietyUnionHeadpromptNew._onTriggerBtn1)},
		{ccbCallbackName = "onTriggerBtn2", callback = handler(self, QUIDialogSocietyUnionHeadpromptNew._onTriggerBtn2)},
		{ccbCallbackName = "onTriggerBtn3", callback = handler(self, QUIDialogSocietyUnionHeadpromptNew._onTriggerBtn3)},
		{ccbCallbackName = "onTriggerBtn4", callback = handler(self, QUIDialogSocietyUnionHeadpromptNew._onTriggerBtn4)},
		{ccbCallbackName = "onTriggerBtn5", callback = handler(self, QUIDialogSocietyUnionHeadpromptNew._onTriggerBtn5)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyUnionHeadpromptNew._onTriggerClose)},
	}
	QUIDialogSocietyUnionHeadpromptNew.super.ctor(self,ccbFile,callBacks,options)

	self._ccbOwner.frame_tf_title:setString("玩家信息")
	
	if (remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "") then
		app:alert({content = "您被移出宗门！", title = "系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
            	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            end
        end},false,true)
		return
	end
	
	if not options or not options.info then
		return
	end
	self._index = options.index

	self._impeachTime1 = db:getConfiguration()["AFK_1"].value	--副宗主弹劾时间
	self._impeachTime2 = db:getConfiguration()["AFK_2"].value   --成员弹劾时间

	self:setInfo(options.info)
	self.isAnimation = true
end

function QUIDialogSocietyUnionHeadpromptNew:_onTriggerDetail(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_detail) == false then return end
    app.sound:playSound("common_small")
	app:getClient():arenaQueryDefenseHerosRequest(self._info.userId, function(data)
			self._info.fighterInfo = data.arenaResponse
			self:showDetailByFighterInfo()
		end)
end

function QUIDialogSocietyUnionHeadpromptNew:showDetailByFighterInfo()
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

function QUIDialogSocietyUnionHeadpromptNew:_onTriggerFight(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_fight) == false then return end
    app.sound:playSound("common_small")

	if remote.user.userId == self._info.userId then
		app.tip:floatTip("魂师大人，放过自己吧！")
		return
	end

	if app.unlock:checkLock("UNLOCK_SOLO_DOUBLE") then

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogFriendChooseTeam",
			options = {userId = self._info.userId}}, {isPopCurrentDialog = true})
	else 
		app:getClient():arenaQueryDefenseHerosRequest(self._info.userId, function(data)
			if self:safeCheck() == false then return end
			if self._clickCallback then
		    	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
			end

			self._info.fighterInfo = data.arenaResponse
			self:startPK()
		end)
	end
end

function QUIDialogSocietyUnionHeadpromptNew:startPK()
	local fighter = self._info.fighterInfo.mySelf
	fighter.userId = self._info.userId
	fighter.name = self._info.name
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

function QUIDialogSocietyUnionHeadpromptNew:_onTriggerBtn1(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_click1) == false then return end
	app.sound:playSound("common_small")
	if self._triggerBtn1CallBack then
		self._triggerBtn1CallBack()
	end
end

function QUIDialogSocietyUnionHeadpromptNew:_onTriggerBtn2(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_click2) == false then return end
	app.sound:playSound("common_small")
	if self._triggerBtn2CallBack then
		self._triggerBtn2CallBack()
	end
end

function QUIDialogSocietyUnionHeadpromptNew:_onTriggerBtn3(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_click3) == false then return end
	 app.sound:playSound("common_small")
	if self._triggerBtn3CallBack then
		self._triggerBtn3CallBack()
	end
end

function QUIDialogSocietyUnionHeadpromptNew:_onTriggerBtn4(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_click4) == false then return end
	 app.sound:playSound("common_small")
	if self._triggerBtn4CallBack then
		self._triggerBtn4CallBack()
	end
end

function QUIDialogSocietyUnionHeadpromptNew:_onTriggerBtn5(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_click5) == false then return end
	 app.sound:playSound("common_small")
	if self._triggerBtn5CallBack then
		self._triggerBtn5CallBack()
	end
end

-- 私聊
function QUIDialogSocietyUnionHeadpromptNew:_onTriggerChat(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_chat) == false then return end
	if remote.friend:checkIsBlackedByUserId(self._info.userId) == true then
		app.tip:floatTip("该玩家已经在您的黑名单中无法与其私聊")
		return
	end
	self:close()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChat", 
        options = {initTab = "onTriggerPrivate", force = true, effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth", 
        			initChatter = {userId = self._info.userId, nickName = self._info.name, avatar = self._info.avatar}}})
end

-- 踢人
function QUIDialogSocietyUnionHeadpromptNew:goOutMember()
    app.sound:playSound("common_small")
	app:alert({content = "把该宗门成员踢出宗门", title = "踢出宗门", callback = function (state)
		if state == ALERT_TYPE.CONFIRM then
		 	remote.union:unionKickLeaveRequest(self._info.userId, function(data)
		       	self:close()
				QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_CONSORTIA_KICKED_OTHER, index = self._index})
		    end)
		 end
    end},false)
end

--弹劾
function QUIDialogSocietyUnionHeadpromptNew:_impeachment()
	if self._info.rank == SOCIETY_OFFICIAL_POSITION.BOSS then
		local lastLeaveTime = self._info.lastLeaveTime/1000/DAY
		
		if (self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.MEMBER or self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.ELITE) and lastLeaveTime < self._impeachTime2 then
			app.tip:floatTip("宗主离线时间未到"..self._impeachTime2.."天，无法进行弹劾哦！~")
			return
		elseif self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.ADJUTANT and lastLeaveTime < self._impeachTime1 then
			app.tip:floatTip("宗主离线时间未到"..self._impeachTime1.."天，无法进行弹劾哦！~")
			return
		end
	end

	app:alert({content = "是否确认要弹劾宗主", title = "弹 劾", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
	            remote.union:unionImpeachRequest(function (data)
			       	remote.union:unionOpenRequest(function (data)
						self:popSelf()

					    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionImpeachDialog", 
					        options = {}})

						QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_INFO_UPDATE})
					end)
			    end)
	        end
        end},false)
	
end

-- 轉為老大
function QUIDialogSocietyUnionHeadpromptNew:jobToBoss()
	 app:alert({content = "是否确定转让宗主给"..self._info.name, title = "转让宗主", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                remote.union:unionRoleUpdateRequest(self._info.userId, SOCIETY_OFFICIAL_POSITION.BOSS, function (data)
					self:close()
					remote.mark:cleanMark(remote.mark.MARK_CONSORTIA_APPLY)
			        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_INFO_UPDATE})
			    end)
            end
        end},false)
end

-- 轉為副官
function QUIDialogSocietyUnionHeadpromptNew:jobToAdjutant()
	remote.union:unionRoleUpdateRequest(self._info.userId, SOCIETY_OFFICIAL_POSITION.ADJUTANT, function (data)
    	self:close()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_INFO_UPDATE})
    end)
end

-- 轉為精英
function QUIDialogSocietyUnionHeadpromptNew:jobToElite()
	 remote.union:unionRoleUpdateRequest(self._info.userId, SOCIETY_OFFICIAL_POSITION.ELITE, function (data)
           	self:close()
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_INFO_UPDATE})
        end)
end

-- 轉為成員
function QUIDialogSocietyUnionHeadpromptNew:jobToMember()
	 remote.union:unionRoleUpdateRequest(self._info.userId, SOCIETY_OFFICIAL_POSITION.MEMBER, function (data)
           	self:close()
			QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_INFO_UPDATE})
        end)
end

--添加好友
function QUIDialogSocietyUnionHeadpromptNew:_addFriend(index)
	if remote.friend:checkIsFriendByUserId(self._info.userId) then
		self._ccbOwner["btn"..index.."Label"]:setString("删除好友")
		self["_triggerBtn"..index.."CallBack"] = function (  )
			app:alert({content="删除好友？",title="系统提示", callback=function (state)
				if state == ALERT_TYPE.CONFIRM then
					remote.friend:apiUserDeleteFriendRequest(self._info.userId, false, function()
						app.tip:floatTip("删除好友成功！")
						self:setInfo(self._info)
					end)	
				end
			end}, false)
		end
	else
		self._ccbOwner["btn"..index.."Label"]:setString("添加好友")
		self["_triggerBtn"..index.."CallBack"] = function ()
			if not app.unlock:getUnlockFriend() then
				app.tip:floatTip("魂师大人，您的好友功能尚未开启，暂时无法使用该功能")
				return
			end
			if remote.friend:checkIsBlackedByUserId(self._info.userId) == true then
				app.tip:floatTip("该玩家已经在您的黑名单中")
				return
			end
			if self._isAlreadySendFriendApply then
				app.tip:floatTip("已经发送申请，等待批准！")
			else
				remote.friend:apiUserApplyFriendRequest(self._info.userId,self._info.name,function ()
        			app.tip:floatTip("已经发送申请，等待批准！")
        			self._isAlreadySendFriendApply = true
        		end)
			end
			
		end
	end
end

--拉黑
function QUIDialogSocietyUnionHeadpromptNew:_addBlack(index)
	if remote.friend:checkIsBlackedByUserId(self._info.userId) then
		self._ccbOwner["btn"..index.."Label"]:setString("取消拉黑")
		self["_triggerBtn"..index.."CallBack"] = function ()
			remote.friend:apiUserDeleteBlackFriendRequest(self._info.userId, function ()
				app.tip:floatTip("移出黑名单成功！")
				self:setInfo(self._info)
				return
			end)
		end
	else
		self._ccbOwner["btn"..index.."Label"]:setString("拉黑")
		self["_triggerBtn"..index.."CallBack"] = function ()
			if not app.unlock:getUnlockFriend() then
				app.tip:floatTip("魂师大人，您的好友功能尚未开启，暂时无法使用该功能")
				return
			end
			if remote.friend:checkIsBlackedByUserId(self._info.userId) == true then
				app.tip:floatTip("该玩家已经在您的黑名单中")
				return
			end
			app:alert({content="拉入黑名单？",title="系统提示", callback=function (state)
				if state == ALERT_TYPE.CONFIRM then
					remote.friend:apiUserDeleteFriendRequest(self._info.userId, true, function ()
						self:setInfo(self._info)
					end)
					app:getServerChatData():deleteMessage(self._info.userId, self._info.userId)
				end
			end}, false)
		end
	end
end

function QUIDialogSocietyUnionHeadpromptNew:normalAction(index, label, handler )
	self._ccbOwner["btn"..index.."Label"]:setString(label)
	self["_triggerBtn"..index.."CallBack"] = handler
end

function QUIDialogSocietyUnionHeadpromptNew:setInfo( info )
	self._info = info
	self._myOfficialPosition = remote.user.userConsortia.rank or SOCIETY_OFFICIAL_POSITION.MEMBER

	if remote.user.userId == info.userId then
		self._ccbOwner.btn1:setVisible(true)
		self._ccbOwner.btn2:setVisible(false)
		self._ccbOwner.btn3:setVisible(false)
		self._ccbOwner.btn4:setVisible(false)
		self._ccbOwner.btn5:setVisible(false)
		self._ccbOwner.btn1:setPositionX(0)
		self._ccbOwner.btn1Label:setString("确定")
		self._triggerBtn1CallBack = function ()
			self:close()
		end
	elseif self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.MEMBER then
		-- 我是普通成员
		if info.rank ~= SOCIETY_OFFICIAL_POSITION.BOSS then
			-- 對象不是老大
			self._ccbOwner.btn5:setVisible(false)
			self._ccbOwner.btn4:setVisible(false)
			self:_addFriend(3)
			self:_addBlack(2)
			self._ccbOwner.btn1:setVisible(false)
		else
			-- 對象是老大
			self:normalAction(5, "弹劾",handler(self,QUIDialogSocietyUnionHeadpromptNew._impeachment))
			self._ccbOwner.btn5:setPositionX(-192)
			local lastLeaveTime = info.lastLeaveTime/1000
			if lastLeaveTime/DAY >= self._impeachTime2 then
				makeNodeFromGrayToNormal(self._ccbOwner.btn5)
			else
				makeNodeFromNormalToGray(self._ccbOwner.btn5)
			end
			self._ccbOwner.btn4:setVisible(false)
			self:_addFriend(3)
			self._ccbOwner.btn3:setPositionX(-0)
			self:_addBlack(2)
			self._ccbOwner.btn2:setPositionX(192)
			self._ccbOwner.btn1:setVisible(false)
		end
	elseif self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.ELITE then
		-- 我是精英
		if info.rank ~= SOCIETY_OFFICIAL_POSITION.BOSS then
			-- 對象不是老大
			self._ccbOwner.btn5:setVisible(false)
			self._ccbOwner.btn4:setVisible(false)
			self:_addFriend(3)
			self:_addBlack(2)
			self._ccbOwner.btn1:setVisible(false)
		else
			-- 對象是老大
			self:normalAction(5, "弹劾",handler(self,QUIDialogSocietyUnionHeadpromptNew._impeachment))
			self._ccbOwner.btn5:setPositionX(-192)
			local lastLeaveTime = info.lastLeaveTime/1000
			if lastLeaveTime/DAY >= self._impeachTime2 then
				makeNodeFromGrayToNormal(self._ccbOwner.btn5)
			else
				makeNodeFromNormalToGray(self._ccbOwner.btn5)
			end
			self._ccbOwner.btn4:setVisible(false)
			self:_addFriend(3)
			self._ccbOwner.btn3:setPositionX(-0)
			self:_addBlack(2)
			self._ccbOwner.btn2:setPositionX(192)
			self._ccbOwner.btn1:setVisible(false)
		end
	elseif self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
		-- 我是副宗主
		if info.rank == SOCIETY_OFFICIAL_POSITION.BOSS then
			-- 對象是老大
			self:normalAction(5, "弹劾",handler(self,QUIDialogSocietyUnionHeadpromptNew._impeachment))
			self._ccbOwner.btn5:setPositionX(-192)
			local lastLeaveTime = info.lastLeaveTime/1000
			if lastLeaveTime/DAY >= self._impeachTime1 then
				makeNodeFromGrayToNormal(self._ccbOwner.btn5)
			else
				makeNodeFromNormalToGray(self._ccbOwner.btn5)
			end
			self._ccbOwner.btn4:setVisible(false)
			self:_addFriend(3)
			self._ccbOwner.btn3:setPositionX(-0)
			self:_addBlack(2)
			self._ccbOwner.btn2:setPositionX(192)
			self._ccbOwner.btn1:setVisible(false)
		elseif info.rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
			-- 對象是副官
			self._ccbOwner.btn5:setVisible(false)
			self._ccbOwner.btn4:setVisible(false)
			self:_addFriend(3)
			self:_addBlack(2)
			self._ccbOwner.btn1:setVisible(false)
		elseif info.rank == SOCIETY_OFFICIAL_POSITION.ELITE then
			-- 對象是精英
			self:normalAction(5, "踢出宗门",handler(self,QUIDialogSocietyUnionHeadpromptNew.goOutMember))
			self._ccbOwner.btn4:setVisible(false)
			self:_addFriend(3)
			self:_addBlack(2)
			self:normalAction(1, "移除职位",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToMember))
		else
			-- 對象是成員
			self:normalAction(5, "踢出宗门",handler(self,QUIDialogSocietyUnionHeadpromptNew.goOutMember))
			self._ccbOwner.btn4:setVisible(false)
			self:_addFriend(3)
			self:_addBlack(2)
			self:normalAction(1, "升职精英",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToElite))
		end
	elseif self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.BOSS then
		-- 我是宗主
		if info.rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
			-- 對象是副官
			self:normalAction(5, "踢出宗门",handler(self,QUIDialogSocietyUnionHeadpromptNew.goOutMember))
			self._ccbOwner.btn4:setVisible(false)
			self:normalAction(3, "转让宗主",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToBoss))
			self:normalAction(2, "降职精英",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToElite))
			self:normalAction(1, "移除职位",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToMember))
		elseif info.rank == SOCIETY_OFFICIAL_POSITION.ELITE then
			-- 對象是精英
			self:normalAction(5, "踢出宗门",handler(self,QUIDialogSocietyUnionHeadpromptNew.goOutMember))
			self._ccbOwner.btn4:setVisible(false)
			self:normalAction(3, "转让宗主",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToBoss))
			self:normalAction(2, "升职副宗",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToAdjutant))
			self:normalAction(1, "移除职位",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToMember))
		else
			-- 對象是成员
			self:normalAction(5, "踢出宗门",handler(self,QUIDialogSocietyUnionHeadpromptNew.goOutMember))
			self._ccbOwner.btn4:setVisible(false)
			self:normalAction(3, "转让宗主",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToBoss))
			self:normalAction(2, "升职副宗",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToAdjutant))
			self:normalAction(1, "升职精英",handler(self,QUIDialogSocietyUnionHeadpromptNew.jobToElite))
		end
	end

	if not self._avatar then
		self._avatar = QUIWidgetAvatar.new(info.avatar)
		self._avatar:setSilvesArenaPeak(info.championCount)
	    self._ccbOwner.nodeIcon:addChild(self._avatar)
	else
		self._avatar:setInfo(info.avatar)
	end
	self._ccbOwner.memberLevel:setString("LV."..(info.level or 1))
	self._ccbOwner.memberName:setString(info.name or "")
	self._ccbOwner.vipNum:setString("VIP  "..(info.vip or ""))

	local canImpeach = false
	if info.lastLeaveTime ~= nil and info.lastLeaveTime > 0 then
		local lastLeaveTime = info.lastLeaveTime/1000
		self._ccbOwner.memberState:setColor(UNITY_COLOR.dark)
		if lastLeaveTime > HOUR then
			local hour = math.floor(lastLeaveTime/HOUR)
			if hour < 24 then
				self._ccbOwner.memberState:setString(string.format("离线%s小时", hour))
			else
				self._ccbOwner.memberState:setString(string.format("离线%s天", math.floor(hour/24)))
			end
		else
			self._ccbOwner.memberState:setString(string.format("离线%s分", math.floor(lastLeaveTime/MIN)))
		end
	else
		self._ccbOwner.memberState:setColor(UNITY_COLOR.green)
		self._ccbOwner.memberState:setString("在线")	
	end

	if info.force then
		if info.force > 1000000 then
			self._ccbOwner.fightNum:setString(math.floor(info.force/10000).."万")
		else
			self._ccbOwner.fightNum:setString(info.force)
		end
	end

	-- 活躍
	self._ccbOwner.tf_total_activity:setString(info.totalActiveDegree or 0)
	self._ccbOwner.tf_daily_activity:setString(info.todayActiveDegree or 0)
end

function QUIDialogSocietyUnionHeadpromptNew:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	self:close()
end

function QUIDialogSocietyUnionHeadpromptNew:close( )
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogSocietyUnionHeadpromptNew:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyUnionHeadpromptNew:_backClickHandler()
    self:close()
end

return QUIDialogSocietyUnionHeadpromptNew
