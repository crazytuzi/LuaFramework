local QUIWidget = import("..QUIWidget")
local QUIWidgetBlackRockTeamPlayer = class("QUIWidgetBlackRockTeamPlayer", QUIWidget)

local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")
local QUIWidgetBlackRockTeamDungeon = import(".QUIWidgetBlackRockTeamDungeon")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QChatDialog = import("....utils.QChatDialog")
local QUIWidgetTeamChat = import("...widgets.QUIWidgetTeamChat")
local QChatDialog = import("....utils.QChatDialog")

QUIWidgetBlackRockTeamPlayer.EVENT_KICK = "EVENT_KICK"
QUIWidgetBlackRockTeamPlayer.EVENT_INVITE = "EVENT_INVITE"
QUIWidgetBlackRockTeamPlayer.EVENT_CHANGEPOS = "EVENT_CHANGEPOS"

function QUIWidgetBlackRockTeamPlayer:ctor(options)
	local ccbFile = "ccb/Widget_Black_mountain.ccbi"

	local callBacks = {
        {ccbCallbackName = "onTriggerKick", callback = handler(self, self._onTriggerKick)},
        {ccbCallbackName = "onTriggerInvite", callback = handler(self, self._onTriggerInvite)},
        {ccbCallbackName = "onTriggerChange", callback = handler(self,self._onTriggerChange)},
    }
	QUIWidgetBlackRockTeamPlayer.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetBlackRockTeamPlayer:setPlayerInfo(playerInfo, progress, leader)
	if self._alertDialog ~= nil then
		self._alertDialog:popSelf()
		self._alertDialog = nil
	end
	self._playerInfo = playerInfo
	self._progress = progress
	self._leader = leader
	self._useId = playerInfo and playerInfo.userId or nil

	if playerInfo ~= nil then
		self._ccbOwner.node_role:setVisible(true)
		self._ccbOwner.node_invite:setVisible(false)
		self._ccbOwner.node_tiren:setVisible(leader.userId == remote.user.userId and playerInfo.userId ~= remote.user.userId)
		self._ccbOwner.node_exchange:setVisible(playerInfo.userId ~= remote.user.userId and leader.userId ~= remote.user.userId)
		self._ccbOwner.node_other:setVisible(playerInfo.userId ~= remote.user.userId)
		if playerInfo.isNpc == true then
			self._ccbOwner.tf_name:setString("LV."..(playerInfo.level or 0)..(playerInfo.name or ""))
			self._ccbOwner.tf_server:setString("【佣兵】") --playerInfo.game_area_name or "佣兵")
			self._ccbOwner.tf_force:setString("【佣兵】")
			self._ccbOwner.tf_force:setColor(ccc3(255,255,255))		
			self._ccbOwner.tf_achievement_title:setString("今日最佳战绩：")
			self._ccbOwner.tf_achievement:setString("【暂无】")
			self:setIsReady(true)
		else
			self._ccbOwner.tf_name:setString("LV."..(playerInfo.level or 0).." "..(playerInfo.name or ""))
			self._ccbOwner.tf_server:setString(playerInfo.game_area_name or "")

			local num,uint = q.convertLargerNumber(playerInfo.topnForce or 0)
			self._ccbOwner.tf_force:setString(num..(uint or ""))

		    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(playerInfo.topnForce),true)
			local color = string.split(fontInfo.force_color, ";")
			self._ccbOwner.tf_force:setColor(ccc3(color[1], color[2], color[3]))
				
			local level = playerInfo.level or 0
			local unlockConfig = app.unlock:getConfigByKey("UNLOCK_CHUANLINGTA_SAODANG")
			local unlockConfigWeek = app.unlock:getConfigByKey("UNLOCK_CHUANLINGTA_SAODANG2")
			local titleStr = ""
			if level >= unlockConfigWeek.team_level then
				titleStr = "本周扫荡战绩："
			elseif level >= unlockConfig.team_level then
				titleStr = "今日扫荡战绩："
			else
				titleStr = "今日最佳战绩："
			end

			local achievementStr = "暂无"
			if playerInfo.todayPerfectPassInfo and playerInfo.todayPerfectPassInfo ~= "" then
				local teamInfo = remote.blackrock:getTeamInfo()
				local passBossInfo = string.split(playerInfo.todayPerfectPassInfo,";")
				local curPassBossInfo = ""
				for _, info in ipairs(passBossInfo) do
					if string.find(info, tostring(teamInfo.chapterId)) ~= nil then
						curPassBossInfo = info
					end
				end
				local tbl = string.split(curPassBossInfo, "^")
				if tbl and #tbl > 0 then
    				local chapterConfigs = remote.blackrock:getChapterById(teamInfo.chapterId)
					local combatTeamId = tonumber(tbl[2])
					for _, config in ipairs(chapterConfigs) do
						if config.combat_team_id == combatTeamId then
							achievementStr = config.monster_name
							break
						end
					end
				end
			end
			self._ccbOwner.tf_achievement_title:setString(titleStr)
			self._ccbOwner.tf_achievement:setString("【"..achievementStr.."】")

			if playerInfo.userId == leader.userId then
				self:setIsReady(true)
			else
				self:setIsReady(progress.memberSts == 3)
			end
		end

		if self._avatar ~= nil then
			self._avatar:removeFromParent()
			self._avatar = nil
		end

		self._avatar = QUIWidgetTeamChat.new()
		self._ccbOwner.node_avatar:addChild(self._avatar)
		self._avatar:setInfo(playerInfo,playerInfo.userId == leader.userId)
		self._avatar:setTouchSwallowEnabled(true)
	else
		self._ccbOwner.node_role:setVisible(false)
		self._ccbOwner.node_invite:setVisible(true)
		self._ccbOwner.node_other:setVisible(true)
	end
	self:updateBossInfo()
	self:setUnionName()
end

function QUIWidgetBlackRockTeamPlayer:getAvatar()
	return self._avatar
end
function QUIWidgetBlackRockTeamPlayer:updateBossInfo()

    local progressInfo = remote.blackrock:getProgressByPos(self._index)
    for ii=1,3 do
        local contain = self._ccbOwner["node_boss"..ii]
        contain:removeAllChildren()
    end
    for index,stepInfo in ipairs(progressInfo.stepInfo) do
        local widget = QUIWidgetBlackRockTeamDungeon.new()
        local contain = self._ccbOwner["node_boss"..index]
        contain:addChild(widget)
        widget:setDungeonId(stepInfo.stepId, stepInfo.isNpc)
    end
    local teamInfo = remote.blackrock:getTeamInfo()
    local chapters = remote.blackrock:getChapterById(teamInfo.chapterId)
    local chapterName = ""
    if chapters ~= nil and #chapters > 0 then
        chapterName = chapters[1].name or ""
    end

end

function QUIWidgetBlackRockTeamPlayer:setUnionName() 
	if self._playerInfo == nil then return end
	local unionName = self._playerInfo.consortiaName or ""
end

function QUIWidgetBlackRockTeamPlayer:refresh()
	self:setPlayerInfo(self._playerInfo, self._progress, self._leader)
end


function QUIWidgetBlackRockTeamPlayer:setAvatarVisible(b)
	if self._avatar ~= nil then
		self._avatar:setVisible(b)
		self:setIsReady(b)
	end
end

function QUIWidgetBlackRockTeamPlayer:getPlayerInfo()
	return self._playerInfo
end

function QUIWidgetBlackRockTeamPlayer:getAvatarPos()
	return self._ccbOwner.node_avatar:convertToWorldSpaceAR(ccp(0,0))
end

function QUIWidgetBlackRockTeamPlayer:setIsReady(isReady)
	if isReady == true then
		self._ccbOwner.sp_ready:setVisible(true)
	else
		self._ccbOwner.sp_ready:setVisible(false)
	end
end

function QUIWidgetBlackRockTeamPlayer:setIndex(index)
	self._index = index
end

function QUIWidgetBlackRockTeamPlayer:getIndex()
	return self._index
end

--xurui: 展示聊天信息
function QUIWidgetBlackRockTeamPlayer:showChatMessage(message)
	if message == nil then return end

    if self._chat == nil then
        self._chat = QChatDialog.new({colorful = true})
        self._ccbOwner.node_tips:addChild(self._chat)
    end
    self._chat:setString(message or "")
    self._chat:setDuration(3)

end

function QUIWidgetBlackRockTeamPlayer:getUserId()
	return self._useId
end

function QUIWidgetBlackRockTeamPlayer:_onTriggerKick( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_tiren) == false then return end
    app.sound:playSound("common_return")
    if not self._playerInfo then
    	return
    end
    local playerInfo = self._playerInfo
    local userId = playerInfo.userId
    self._alertDialog = app:alert({content = "确认踢出此队员？", title = "系统提示", callback = function (state)
        self._alertDialog = nil
        if state == ALERT_TYPE.CONFIRM then
			remote.blackrock:blackRockKickOffTeamRequest(userId, function ()
				-- if self:safeCheck() then
				    local nickName = playerInfo.name or ""
				    local topnForce = playerInfo.topnForce or 0
				    local num,unit = q.convertLargerNumber(topnForce)
			        local message = string.format("%s(战力：%s)已被踢出队伍", nickName, (num..(unit or "")))
			        local misc = {type = "admin"}
			        local severChatData = app:getServerChatData()
			        severChatData:_onMessageReceived(4, nil, nil, message, q.OSTime(), misc)
					self:dispatchEvent({name = QUIWidgetBlackRockTeamPlayer.EVENT_KICK})
				-- end
			end)
        end
    end})
end

function QUIWidgetBlackRockTeamPlayer:_onTriggerInvite( ... )
	self:dispatchEvent({name = QUIWidgetBlackRockTeamPlayer.EVENT_INVITE})
end

function QUIWidgetBlackRockTeamPlayer:_onTriggerChange(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_change) == false then return end
	
	local randomMess = math.random(1,10)
	local messageContent = QStaticDatabase:sharedDatabase():getConfigurationValue("blackrock_exchange_words"..randomMess)
	if not messageContent then
		messageContent = QStaticDatabase:sharedDatabase():getConfigurationValue("blackrock_exchange_words1")
	end
	local content = string.format(messageContent,tostring(self._index))
	app:getClient():sendTeamChatMessage(content,1, nil, nil)

	--本地通知
	-- self:dispatchEvent({name = QUIWidgetBlackRockTeamPlayer.EVENT_CHANGEPOS,message = content})
end

return QUIWidgetBlackRockTeamPlayer