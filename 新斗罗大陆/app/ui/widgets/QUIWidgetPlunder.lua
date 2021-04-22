--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林巢穴
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunder = class("QUIWidgetPlunder", QUIWidget)

local QUIWidgetPlunderIcon = import("..widgets.QUIWidgetPlunderIcon")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

QUIWidgetPlunder.EVENT_OK = "QUIWIDGETPLUNDER_EVENT_OK"
QUIWidgetPlunder.EVENT_INFO = "QUIWIDGETPLUNDER_EVENT_INFO"

function QUIWidgetPlunder:ctor(options)
	local ccbFile = "ccb/Widget_plunder_main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetPlunder._onTriggerOK)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, QUIWidgetPlunder._onTriggerInfo)},
	}
	QUIWidgetPlunder.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._mineId = options.mineId
    self._consortiaId = options.consortiaId

    self._config = remote.plunder:getMineConfigByMineId(self._mineId)
    self._quality = self._config.mine_quality
    self._ccbam = nil

	self:_init()
end

function QUIWidgetPlunder:onEnter()
end

function QUIWidgetPlunder:onExit()
	self._isShowHammer = false

	if self._updateHammer then
		scheduler.unscheduleGlobal(self._updateHammer)
		self._updateHammer = nil
	end

	-- print("[Kumo] QUIWidgetPlunder:onExit() : ", self._mineId)
end

function QUIWidgetPlunder:update(consortiaId)
	-- print("[Kumo] QUIWidgetPlunder:update() : ", consortiaId)
	self._consortiaId = consortiaId
	self:_update()
end

-- function QUIWidgetPlunder:_onEvent(event)
-- 	if event.name == QUIWidgetPlunderIcon.EVENT_OK then
-- 		if self._lordType == LORD_TYPE.BOSS then 
-- 			app.tip:floatTip("魂师大人，这块魂兽区尚未开放")
-- 			return 
-- 		end
-- 		self:dispatchEvent( {name = QUIWidgetPlunder.EVENT_OK, mineId = self._mineId} )
-- 	end
-- end

function QUIWidgetPlunder:_onTriggerOK()
	if self._lordType == LORD_TYPE.BOSS then 
		app.tip:floatTip("魂师大人，这块魂兽区尚未开放")
		return 
	end
	self:dispatchEvent( {name = QUIWidgetPlunder.EVENT_OK, mineId = self._mineId, isMyMine = self._isMyMine} )
end

function QUIWidgetPlunder:_onTriggerInfo()
	if self._lordType == LORD_TYPE.BOSS then return end
	self:dispatchEvent( {name = QUIWidgetPlunder.EVENT_INFO, mineId = self._mineId} )
end

function QUIWidgetPlunder:show()
	if self._isPlaying then return end
	if remote.plunder:getIsNeedShowMineId() == self._mineId then
		self._isPlaying = true
		self:_updateWinCCB(true)
	end
end

function QUIWidgetPlunder:_init()
	self._ccbam = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
	self._ccbam:runAnimationsForSequenceNamed("normal")
	self._isShowHammer = false
	-- local icon = QUIWidgetPlunderIcon.new({quality = self._quality})
	-- icon:addEventListener(QUIWidgetPlunderIcon.EVENT_OK, handler(self, self._onEvent))
	-- self._ccbOwner.node_icon:removeAllChildren()
	-- self._ccbOwner.node_icon:addChild(icon)

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

function QUIWidgetPlunder:_update()
	self._ccbOwner.node_boss:setVisible(false)
	self._ccbOwner.node_player:setVisible(false)
	self._ccbOwner.node_friend:setVisible(false)
	self:_updateMyMineCCB(false)
	self._ccbOwner.btn_info:setVisible(false)
	self._ccbOwner.btn_info:setEnabled(false)
	self._ccbOwner.sp_player_buff_3:setVisible(false)
	self._ccbOwner.sp_player_buff_4:setVisible(false)
	self._ccbOwner.sp_player_buff_5:setVisible(false)
	self._ccbOwner.sp_friend_buff_3:setVisible(false)
	self._ccbOwner.sp_friend_buff_4:setVisible(false)
	self._ccbOwner.sp_friend_buff_5:setVisible(false)

	local myMineId = remote.plunder:getMyMineId()
	-- print("[Kumo] QUIWidgetPlunder:_update() ", myMineId, self._mineId)
    if myMineId then
		self._isMyMine = myMineId == self._mineId
	else
		self._isMyMine = false
	end

	local mineInfo = remote.plunder:getMineInfoByMineId( self._mineId )
	-- QPrintTable(mineInfo)
	if mineInfo then
		if self._ownerId ~= mineInfo.ownerId then
			-- print("[Kumo] 消除小锤子 QUIWidgetPlunder:_update(1) id： ", self._mineId)
			self._isShowHammer = false
			self._ccbOwner.node_hammer:removeAllChildren()
		end
		self._ownerId = mineInfo.ownerId
		-- 有人狩猎
		if mineInfo.ownerId == remote.plunder:getMyUserId() or (mineInfo.consortiaId and mineInfo.consortiaId == remote.plunder:getMyConsortiaId() and mineInfo.consortiaId ~= "") then
			self._lordType = LORD_TYPE.SOCIETY
		else
			self._lordType = LORD_TYPE.NORMAL
		end
		-- if remote.plunder:getIsNeedShowMineId() ~= self._mineId then
		-- 	-- print("[Kumo] 播放小锤子 QUIWidgetPlunder:_update() id： ", self._mineId)
		-- 	self:_showHammer()
		-- end
	else
		-- 无人狩猎，即为BOSS狩猎
		self._lordType = LORD_TYPE.BOSS
		if self._isShowHammer then
			-- print("[Kumo] 消除小锤子 QUIWidgetPlunder:_update(2) id： ", self._mineId)
			self._isShowHammer = false
			self._ccbOwner.node_hammer:removeAllChildren()
		end
	end
	
	if self._lordType == LORD_TYPE.BOSS then
        self._ccbOwner.tf_boss_name:setString("未开放")
        self._ccbOwner.tf_boss_battle_force:setString("0")
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

		self._ccbOwner.tf_player_score_count:setString(math.floor((mineInfo.occupyScore or 0) * remote.plunder:getPlunderProportion()))
		-- print("[Kumo] QUIWidgetPlunder:_update() player ", mineInfo.consortiaId, self._consortiaId)
		if mineInfo.consortiaId and self._consortiaId == mineInfo.consortiaId and mineInfo.consortiaId ~= "" then
			local width = self._ccbOwner.tf_player_society_name:getContentSize().width
			local x = self._ccbOwner.tf_player_society_name:getPositionX()
			-- self._ccbOwner.node_player_buff:setPositionX( x + width + 10)
			self._ccbOwner.node_player_buff:setVisible(true)
			local caveId = remote.plunder:getCaveIdByMineId(self._mineId)
			local _, member = remote.plunder:getSocietyBuffInfoByCaveId(caveId)
			self._ccbOwner["sp_player_buff_"..member]:setVisible(true)
		else
			self._ccbOwner.node_player_buff:setVisible(false)
		end
		if remote.plunder:getIsNeedShowMineId() ~= self._mineId then
			self._ccbOwner.node_player:setVisible(true)
			if mineInfo.ownerId == remote.plunder:getMyUserId() then
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
		self._ccbOwner.tf_friend_score_count:setString(math.floor((mineInfo.occupyScore or 0) * remote.plunder:getPlunderProportion()))
		-- print("[Kumo] QUIWidgetPlunder:_update() friend ", mineInfo.consortiaId, self._consortiaId)
		if mineInfo.consortiaId and self._consortiaId == mineInfo.consortiaId and mineInfo.consortiaId ~= "" then
			local width = self._ccbOwner.tf_friend_society_name:getContentSize().width
			local x = self._ccbOwner.tf_friend_society_name:getPositionX()
			-- self._ccbOwner.node_friend_buff:setPositionX( x + width + 10)
			self._ccbOwner.node_friend_buff:setVisible(true)
			-- print("[Kumo] QUIWidgetPlunder:_update() sp_friend_buff  true")
			local caveId = remote.plunder:getCaveIdByMineId(self._mineId)
			local _, member = remote.plunder:getSocietyBuffInfoByCaveId(caveId)
			self._ccbOwner["sp_friend_buff_"..member]:setVisible(true)

		else
			self._ccbOwner.node_friend_buff:setVisible(false)
			-- print("[Kumo] QUIWidgetPlunder:_update() sp_friend_buff  false")
		end
		if remote.plunder:getIsNeedShowMineId() ~= self._mineId then
			self._ccbOwner.node_friend:setVisible(true)
			if mineInfo.ownerId == remote.plunder:getMyUserId() then
				self._isMyMine = true
				self:_updateMyMineCCB(true)
			end
			self._ccbOwner.btn_info:setVisible(true)
		end
		self._ccbOwner.btn_info:setEnabled(true)
	end
end

-- function QUIWidgetPlunder:_showHammer( isEnforce )
	-- if not isEnforce and self._isShowHammer then return end
	-- print("[Kumo] 播放小锤子 id： ", self._mineId, remote.plunder:getIsWaitShowChangeAni())
	-- self._isShowHammer = true
	-- local pos, ccbFile = remote.plunder:getHammer()
 --    local aniPlayer = QUIWidgetAnimationPlayer.new()
 --    self._ccbOwner.node_hammer:removeAllChildren()
 --    self._ccbOwner.node_hammer:addChild(aniPlayer)
 --    aniPlayer:setPosition(pos.x, pos.y)
 --    aniPlayer:playAnimation(ccbFile, nil, function() 
	--     	-- self:_checkHammer() 
 --    	end, false)
-- end

function QUIWidgetPlunder:_updateMyMineCCB( isShow )
	if isShow then
		local pos, ccbFile = remote.plunder:getGuang()
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_my_mine:removeAllChildren()
	    self._ccbOwner.node_my_mine:addChild(aniPlayer)
	    aniPlayer:setPosition(pos.x, pos.y)
		aniPlayer:playAnimation(ccbFile, nil, nil, false)
	else
		self._ccbOwner.node_my_mine:removeAllChildren()
	end
end

function QUIWidgetPlunder:_updateWinCCB( isShow )
	if isShow then
		local pos, ccbFile = remote.plunder:getWin()
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_win:removeAllChildren()
	    self._ccbOwner.node_win:addChild(aniPlayer)
	    aniPlayer:setPosition(pos.x, pos.y)
		aniPlayer:playAnimation(ccbFile, nil, function()
				remote.plunder:setIsNeedShowMineId( 0 )
				if self._lordType == LORD_TYPE.NORMAL then
					self._ccbOwner.node_player:setVisible(true)
				elseif self._lordType == LORD_TYPE.SOCIETY then
					self._ccbOwner.node_friend:setVisible(true)
				end
				self:_updateMyMineCCB(true)
				self._ccbOwner.btn_info:setVisible(true)
				self._ccbam:stopAnimation()
				self._ccbam:runAnimationsForSequenceNamed("appear")
				self._ccbam:connectScriptHandler(function(name)
							print("[Kumo] 播放小锤子 QUIWidgetPlunder:_updateWinCCB() id： ", self._mineId)
				            -- self:_showHammer()
				            self._isPlaying = false
					    end)
			end, true)
	else
		self._ccbOwner.node_win:removeAllChildren()
	end
end

function QUIWidgetPlunder:_checkHammer()
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
end

return QUIWidgetPlunder