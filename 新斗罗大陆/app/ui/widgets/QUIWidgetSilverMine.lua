--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林巢穴
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMine = class("QUIWidgetSilverMine", QUIWidget)

local QUIWidgetSilverMineIcon = import("..widgets.QUIWidgetSilverMineIcon")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

QUIWidgetSilverMine.EVENT_OK = "QUIWIDGETSILVERMINE_EVENT_OK"
QUIWidgetSilverMine.EVENT_INFO = "QUIWIDGETSILVERMINE_EVENT_INFO"
-- QUIWidgetSilverMine.EVENT_ASSIST = "QUIWIDGETSILVERMINE_EVENT_ASSIST"

function QUIWidgetSilverMine:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_Main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetSilverMine._onTriggerOK)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, QUIWidgetSilverMine._onTriggerInfo)},
		{ccbCallbackName = "onTriggerAssistOK", callback = handler(self, QUIWidgetSilverMine._onTriggerAssistOK)},
		{ccbCallbackName = "onTriggerAttack", callback = handler(self, QUIWidgetSilverMine._onTriggerAttack)},
	}
	QUIWidgetSilverMine.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._mineId = options.mineId
    self._consortiaId = options.consortiaId
    
    self._config = remote.silverMine:getMineConfigByMineId(self._mineId)
    self._quality = self._config.mine_quality
    self._battleForce = self._config.battle_force or 0
    self._isMyMine = false
    self._ccbam = nil

	self:_init()
end

function QUIWidgetSilverMine:onEnter()
	if remote.silverMine:getIsNeedShowMineId() == self._mineId then
		if self._lordType == LORD_TYPE.NORMAL then
			self._ccbOwner.node_player:setVisible(false)
		elseif self._lordType == LORD_TYPE.SOCIETY then
			self._ccbOwner.node_friend:setVisible(false)
		end
	end
end

function QUIWidgetSilverMine:onExit()
	self._isShowHammer = false

	if self._updateHammer then
		scheduler.unscheduleGlobal(self._updateHammer)
		self._updateHammer = nil
	end
end

function QUIWidgetSilverMine:update(consortiaId)
	self._consortiaId = consortiaId
	self:_update()
end

function QUIWidgetSilverMine:_onTriggerAttack(event)
	self:dispatchEvent( {name = QUIWidgetSilverMine.EVENT_OK, mineId = self._mineId} )
end

function QUIWidgetSilverMine:_onTriggerOK()
	self:dispatchEvent( {name = QUIWidgetSilverMine.EVENT_OK, mineId = self._mineId, isMyMine = self._isMyMine} )
end

function QUIWidgetSilverMine:_onTriggerInfo()
	if self._lordType == LORD_TYPE.BOSS then return end
	self:dispatchEvent( {name = QUIWidgetSilverMine.EVENT_INFO, mineId = self._mineId} )
end

--点击协助
function QUIWidgetSilverMine:_onTriggerAssistOK()
	local mineInfo = remote.silverMine:getMineInfoByMineId(self._mineId)
	local occupy = remote.silverMine:getMineOccupyInfoByMineID(self._mineId)
	local count = 0
	if occupy ~= nil then
		count = #(occupy.assistUserInfo or {})
	end
	if count >= 3 then
		app.tip:floatTip("狩猎者的协助位已满~")
		return
	end
	if mineInfo ~= nil then

		remote.silverMine:silverMineAssistRequest(mineInfo.oriOccupyId, mineInfo.ownerId, function (data)
			self:_update()
			local assistAnimationPlayer = QUIWidgetAnimationPlayer.new()
			self:getView():addChild(assistAnimationPlayer)
			assistAnimationPlayer:playAnimation("ccb/Widget_SilverMine_Xiezhu.ccbi",nil, function ()
				assistAnimationPlayer:removeFromParent()
			end)
	
	        --xurui: 更新每日建设活跃任务
	        remote.union.unionActive:updateActiveTaskProgress(20005, 1)

		    local chatData = app:getServerChatData():getMsgReceived(mineInfo.ownerId)
		    local seq = 0
		    for k, v in ipairs(chatData) do
		    	if v.misc.assist == mineInfo.oriOccupyId then
		    		seq = v.misc.seq
		    	else
		    		if v.misc.assist ~= 0 and v.misc.assist ~= -1 then
				    	app:getServerChatData():updateLocalReceivedMessage(mineInfo.ownerId, v.misc.seq, {misc = {assist = -1}})
				    end		    		
		    	end
		    end
		    app:getServerChatData():updateLocalReceivedMessage(mineInfo.ownerId, seq, {misc = {assist = 0}})
		end, function (data)
		    local caveId = remote.silverMine:getCaveIdByMineId( self._mineId )
		    remote.silverMine:silvermineGetCaveInfoRequest(caveId)
		end)
	end
end

function QUIWidgetSilverMine:show()
	if self._isPlaying then return end
	if remote.silverMine:getIsNeedShowMineId() == self._mineId then
		self._isPlaying = true
		self:_updateWinCCB(true)
	end
end

function QUIWidgetSilverMine:_init()
	self._ccbam = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
	self._ccbam:runAnimationsForSequenceNamed("normal")
	self._isShowHammer = false

	--展示怪物形象
	local monsterId = self._config.show_monster_id or 3170 
	local scale = self._config.show_monster_size or 1
	local isTurn = self._config.show_monster_turn
	if self._monsterAvatar == nil then
		self._monsterAvatar = QUIWidgetActorDisplay.new(monsterId)
		self._monsterAvatar:setScaleY(scale)
		if isTurn then
			scale = -scale
		end
		self._monsterAvatar:setScaleX(scale)
		self._ccbOwner.node_icon:addChild(self._monsterAvatar) 
	end

	self:_update()
end

function QUIWidgetSilverMine:_update()
	-- print("[Kumo] QUIWidgetSilverMine:_update()")
	self._ccbOwner.node_boss:setVisible(false)
	self._ccbOwner.node_player:setVisible(false)
	self._ccbOwner.node_friend:setVisible(false)
	self:_updateMyMineCCB(false)
	self._ccbOwner.btn_info:setVisible(false)
	self._ccbOwner.btn_info:setEnabled(false)
	self._ccbOwner.node_assist:setVisible(false)
	self._ccbOwner.node_assist_status3:setVisible(false)
	self._ccbOwner.node_assist_status2:setVisible(false)
	self._ccbOwner.node_assist_status1:setVisible(false)
	self._ccbOwner.sp_player_buff_3:setVisible(false)
	self._ccbOwner.sp_player_buff_4:setVisible(false)
	self._ccbOwner.sp_player_buff_5:setVisible(false)
	self._ccbOwner.sp_friend_buff_3:setVisible(false)
	self._ccbOwner.sp_friend_buff_4:setVisible(false)
	self._ccbOwner.sp_friend_buff_5:setVisible(false)

	local mineInfo = remote.silverMine:getMineInfoByMineId( self._mineId )
	if mineInfo then
		if self._ownerId ~= mineInfo.ownerId then
			self._isShowHammer = false
			self._ccbOwner.node_hammer:removeAllChildren()
			self._ccbOwner.node_hammer_di:removeAllChildren()
		end
		self._ownerId = mineInfo.ownerId
		-- 有人狩猎
		self._isMyMine = false
		if mineInfo.ownerId == remote.silverMine:getMyUserId() or (mineInfo.consortiaId and mineInfo.consortiaId == remote.silverMine:getMyConsortiaId() and mineInfo.consortiaId ~= "") then
			self._lordType = LORD_TYPE.SOCIETY
		else
			self._lordType = LORD_TYPE.NORMAL
		end
		if remote.silverMine:getIsNeedShowMineId() ~= self._mineId then
			self:_showHammer()
		end
		self:assistInfo(mineInfo)
	else
		-- 无人狩猎，即为BOSS狩猎
		self._lordType = LORD_TYPE.BOSS
		if self._isShowHammer then
			self._isShowHammer = false
			self._ccbOwner.node_hammer:removeAllChildren()
			self._ccbOwner.node_hammer_di:removeAllChildren()
		end
	end

	if self._lordType == LORD_TYPE.BOSS then
		local bossInfo = remote.silverMine:getNPCInfoById( self._config.dungeon_monster_id )
        self._ccbOwner.tf_boss_name:setString(bossInfo.name)
        self._ccbOwner.tf_boss_battle_force:setString(self._config.battle_force)
		self._ccbOwner.node_boss:setVisible(true)
	elseif self._lordType == LORD_TYPE.NORMAL then
		self._ccbOwner.tf_player_name:setString(mineInfo.ownerName or "")
		local force = mineInfo.defenseForce or 0
		local num, unit = q.convertLargerNumber(force)
		self._ccbOwner.tf_player_battle_force:setString(num..(unit or ""))
		self._ccbOwner.tf_player_society_name:setString(mineInfo.consortiaName or "")
		if mineInfo.consortiaId == "" then
			self._ccbOwner.tf_player_society_name:setString("无")
		end
		if mineInfo.consortiaId and self._consortiaId == mineInfo.consortiaId and mineInfo.consortiaId ~= "" then
			local width = self._ccbOwner.tf_player_society_name:getContentSize().width
			local x = self._ccbOwner.tf_player_society_name:getPositionX()
			self._ccbOwner.node_player_buff:setVisible(true)
			local caveId = remote.silverMine:getCaveIdByMineId(self._mineId)
			local _, member = remote.silverMine:getSocietyBuffInfoByCaveId(caveId)
			self._ccbOwner["sp_player_buff_"..member]:setVisible(true)
		else
			self._ccbOwner.node_player_buff:setVisible(false)
		end
		if remote.silverMine:getIsNeedShowMineId() ~= self._mineId then
			self._ccbOwner.node_player:setVisible(true)
			if mineInfo.ownerId == remote.silverMine:getMyUserId() then
				self._isMyMine = true
				self:_updateMyMineCCB(true)
			end
			self._ccbOwner.btn_info:setVisible(true)
		end
		self._ccbOwner.btn_info:setEnabled(true)
	elseif self._lordType == LORD_TYPE.SOCIETY then
		self._ccbOwner.tf_friend_name:setString(mineInfo.ownerName or "")
		local force = mineInfo.defenseForce or 0
		local num, unit = q.convertLargerNumber(force)
		self._ccbOwner.tf_friend_battle_force:setString(num..(unit or ""))
		self._ccbOwner.tf_friend_society_name:setString(mineInfo.consortiaName or "")
		if mineInfo.consortiaId == "" then
			self._ccbOwner.tf_friend_society_name:setString("无")
		end
		if mineInfo.consortiaId and self._consortiaId == mineInfo.consortiaId and mineInfo.consortiaId ~= "" then
			local width = self._ccbOwner.tf_friend_society_name:getContentSize().width
			local x = self._ccbOwner.tf_friend_society_name:getPositionX()
			self._ccbOwner.node_friend_buff:setVisible(true)
			local caveId = remote.silverMine:getCaveIdByMineId(self._mineId)
			local _, member = remote.silverMine:getSocietyBuffInfoByCaveId(caveId)
			self._ccbOwner["sp_friend_buff_"..member]:setVisible(true)
		else
			self._ccbOwner.node_friend_buff:setVisible(false)
		end
		if remote.silverMine:getIsNeedShowMineId() ~= self._mineId then
			self._ccbOwner.node_friend:setVisible(true)
			if mineInfo.ownerId == remote.silverMine:getMyUserId() then
				self._isMyMine = true
				self:_updateMyMineCCB(true)
			end
			self._ccbOwner.btn_info:setVisible(true)
		end
		self._ccbOwner.btn_info:setEnabled(true)
	end
end

--协助信息
function QUIWidgetSilverMine:assistInfo(mineInfo)
	local myAssist = false --自己是否协助
	local myInvite = false --自己是否被邀请协助
	local assistEmpty = true
	local assistUserInfo = mineInfo.assistUserInfo or {}
	local inviteAssistUserId = mineInfo.inviteAssistUserId or {}

	for _,info in ipairs(assistUserInfo) do
		if info.userId == remote.user.userId then
			myAssist = true
		end
		assistEmpty = false
	end

	if myAssist == false then --如果自己未协助则查看自己是否被邀请协助
		for _,userId in ipairs(inviteAssistUserId) do
			if userId == remote.user.userId then
				myInvite = true
			end
		end
	end

	local assistCount = remote.silverMine.assistCount or 0
	if myAssist == false and myInvite == true and #assistUserInfo < remote.silverMine:getAssistTotalCount() and assistCount > 0 then --如果自己未协助且被邀请协助则显示协助图标
		self._ccbOwner.node_assist:setVisible(true)
	elseif assistEmpty == false then
		local totalCount = remote.silverMine:getAssistTotalCount()
		for i=1,totalCount do
			local status = 3 --状态 1:别人 2:自己 3:没人
			if assistUserInfo[i] ~= nil then
				if assistUserInfo[i].userId == remote.user.userId then
					status = 2
				else
					status = 1
				end
			end
			self:_showAssistInfoByIndex(i, status)
		end
	end
end

--[[
	显示协助信息
	@param index 第几个
	@param status 状态 1:别人 2:自己 3:没人
]]--
function QUIWidgetSilverMine:_showAssistInfoByIndex(index,status)
	local node = self._ccbOwner["node_assist_status"..index]
	node:setVisible(true)
	node:removeAllChildren()
	local sp = display.newSprite(QResPath("yingkuangzhan_ren")[status])
	node:addChild(sp)
end

function QUIWidgetSilverMine:_showHammer( isEnforce )
	if not isEnforce and self._isShowHammer then return end
	-- print("[Kumo] 播放小锤子 id： ", self._mineId, remote.silverMine:getIsWaitShowChangeAni())
	self._isShowHammer = true
	local myOccupy = remote.silverMine:getMyOccupy()
	local isOvertime = false
	if not remote.silverMine:getIsWaitShowChangeAni() then
		if myOccupy and myOccupy.mineId and myOccupy.mineId == self._mineId then
			isOvertime = remote.silverMine:updateGoldPickaxeTime(true)
		else
			isOvertime = remote.silverMine:updateGoldPickaxeTime(nil, self._mineId)
		end
	else
		isOvertime = true
	end

	-- print("[Kumo] QUIWidgetSilverMine:_showHammer() ", isEnforce, myOccupy.mineId, self._mineId, self._isGoldPickaxe, isOvertime, remote.silverMine:getIsNeedShowChangeAni())
	if myOccupy and myOccupy.mineId and myOccupy.mineId == self._mineId and not self._isGoldPickaxe and not isOvertime and remote.silverMine:getIsNeedShowChangeAni() then
		-- 普通魂兽区镐转变成诱魂草, 只针对自己的魂兽区
		self._isGoldPickaxe = not isOvertime
		remote.silverMine:setIsNeedShowChangeAni(false)
		local pos, ccbFile = remote.silverMine:getChangeEffect()
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_hammer:removeAllChildren()
	    self._ccbOwner.node_hammer:addChild(aniPlayer)
	    aniPlayer:setPosition(pos.x, pos.y)
	    aniPlayer:playAnimation(ccbFile, nil, function() 
		    	self:_showHammer( true ) 
	    	end, false)
	    return
	end
	
	local pos, ccbFile = remote.silverMine:getHammer()
	local aniPlayerDi = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_hammer_di:removeAllChildren()
    self._ccbOwner.node_hammer_di:addChild(aniPlayerDi)
    aniPlayerDi:setPosition(pos.x, pos.y)
    aniPlayerDi:playAnimation(ccbFile, nil, function() 
	    	self:_checkHammer() 
    	end, false)
    self._isGoldPickaxe = not isOvertime
	if self._isGoldPickaxe then
		pos, ccbFile = remote.silverMine:getGoldPickaxe()
		local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_hammer:removeAllChildren()
	    self._ccbOwner.node_hammer:addChild(aniPlayer)
	    aniPlayer:setPosition(pos.x, pos.y)
	    aniPlayer:playAnimation(ccbFile, nil, function() 
		    	self:_checkHammer() 
	    	end, false)
	end
	
end

function QUIWidgetSilverMine:_updateMyMineCCB( isShow )
	if isShow then
		local pos, ccbFile = remote.silverMine:getGuang()
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_my_mine:removeAllChildren()
	    self._ccbOwner.node_my_mine:addChild(aniPlayer)
	    aniPlayer:setPosition(pos.x, pos.y)
		aniPlayer:playAnimation(ccbFile, nil, nil, false)
	else
		self._ccbOwner.node_my_mine:removeAllChildren()
	end
end

function QUIWidgetSilverMine:_updateWinCCB( isShow )
	if isShow then
		local pos, ccbFile = remote.silverMine:getWin()
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_win:removeAllChildren()
	    self._ccbOwner.node_win:addChild(aniPlayer)
	    aniPlayer:setPosition(pos.x, pos.y)
		aniPlayer:playAnimation(ccbFile, nil, function()
				remote.silverMine:setIsNeedShowMineId( 0 )
				if self._lordType == LORD_TYPE.NORMAL then
					self._ccbOwner.node_player:setVisible(true)
				elseif self._lordType == LORD_TYPE.SOCIETY then
					self._ccbOwner.node_friend:setVisible(true)
				end
				self:_updateMyMineCCB(true)
				-- self._ccbOwner.btn_info:setVisible(true)
				self._ccbOwner.btn_info:setVisible(false)
				self._ccbam:stopAnimation()
				self._ccbam:runAnimationsForSequenceNamed("appear")
				self._ccbam:connectScriptHandler(function(name)
							-- print("[Kumo] 播放小锤子 QUIWidgetSilverMine:_updateWinCCB() id： ", self._mineId)
				            self:_showHammer()
				            self._isPlaying = false
					    end)
			end, true)
	else
		self._ccbOwner.node_win:removeAllChildren()
	end
end

function QUIWidgetSilverMine:_checkHammer()
	if self._isShowHammer then
		if not self._updateHammer then
			self._updateHammer = scheduler.scheduleGlobal(function() self:_checkHammer() end, 1)
		end
	else
		if self._updateHammer then
			scheduler.unscheduleGlobal(self._updateHammer)
			self._updateHammer = nil
		end
	end

	local myOccupy = remote.silverMine:getMyOccupy()
	local isOvertime = false
	if myOccupy and myOccupy.mineId and myOccupy.mineId == self._mineId then
		isOvertime = remote.silverMine:updateGoldPickaxeTime(true)
	else
		isOvertime = remote.silverMine:updateGoldPickaxeTime(nil, self._mineId)
	end
	if self._isGoldPickaxe ~= not isOvertime and self._isShowHammer then
		self:_showHammer(true)
	end
end

return QUIWidgetSilverMine