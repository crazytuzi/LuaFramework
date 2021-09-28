local CrossWarTimer = class("CrossWarTimer")

local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")

function CrossWarTimer:ctor()
	self._curState = G_Me.crossWarData:getCurState()
	self._targetState = 0
	self._timer = nil
	self._stopUpdate = false
end

function CrossWarTimer:startTimer()
	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(0, handler(self, self._update))
	end
end

function CrossWarTimer:closeTimer()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil

		-- 取消监听
		uf_eventManager:removeListenerWithTarget(self)
	end
end

-- 这个事件回调函数，用于监听在一整轮比赛结束后，与服务器进行状态同步的结果
function CrossWarTimer:_onRcvCrossWarInfo()
	-- 如果服务器状态仍未变，等1秒后再拉取
	-- (PS: 因为服务器的状态变化可能滞后一丁点时间))
	if G_Me.crossWarData:getCurState() == CrossWarCommon.STATE_AFTER_CHAMPIONSHIP then

		uf_funcCallHelper:callAfterDelayTime(1, nil, function()
				G_HandlersManager.crossWarHandler:sendGetBattleTime()
			end, nil)

		return
	end

	-- 新一轮比赛开始
	self:_dispatchEvent(CrossWarCommon.EVENT_STATE_CHANGED)
	self._stopUpdate = false

	-- 取消监听
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO)

	-- 保存新状态
	self._curState = G_Me.crossWarData:getCurState()
end

-- 这个事件回调函数，用于监听在争霸赛期间，与服务器进行状态同步的结果
function CrossWarTimer:_onRcvCrossWarInfo_middle()
	-- 如果服务器状态仍未变，等1秒后再拉取
	-- (PS: 因为服务器的状态变化可能滞后一丁点时间))
	if G_Me.crossWarData:getCurState() ~= self._targetState then

		uf_funcCallHelper:callAfterDelayTime(1, nil, function()
				G_HandlersManager.crossWarHandler:sendGetBattleInfo()
			end, nil)

		return
	end

	-- 状态已同步，发送事件并继续update
	self:_dispatchEvent(CrossWarCommon.EVENT_STATE_CHANGED)
	self._stopUpdate = false

	-- 取消监听
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO)

	-- 保存新状态
	self._curState = G_Me.crossWarData:getCurState()

	-- 拉取本阶段必需的信息
	if self._curState == CrossWarCommon.STATE_AFTER_SCORE_MATCH then
		-- 状态切到第3阶段，拉取争霸赛信息
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_ARENA_INFO, self._onRcvChampionshipInfo, self)
		G_HandlersManager.crossWarHandler:sendGetChampionshipInfo()
	elseif self._curState == CrossWarCommon.STATE_AFTER_CHAMPIONSHIP then
		-- 状态切换到第5阶段，拉取押注奖励和最终的排行榜（押注奖励在这里处理，可能需要拉多次，排行榜就不用了）
		-- NOTE:现在暂时关闭押注功能
		--uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_AWARD, self._onRcvBetAward, self)
		--G_HandlersManager.crossWarHandler:sendGetBetAward()
		G_HandlersManager.crossWarHandler:sendGetTopRanks()
	end
end


function CrossWarTimer:_onRcvChampionshipInfo(success)
	-- 如果服务器尚未准备好争霸赛信息，等1秒后再拉取
	if success == false then
		uf_funcCallHelper:callAfterDelayTime(1, nil, function()
				G_HandlersManager.crossWarHandler:sendGetChampionshipInfo()
			end, nil)
		return
	end

	-- 取消监听
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_WAR_GET_ARENA_INFO)
end

-- 收到押注奖励信息的回包
function CrossWarTimer:_onRcvBetAward(success)
	-- 如果服务器状态仍未到争霸赛结束，等1秒后再拉
	if success == false then
		uf_funcCallHelper:callAfterDelayTime(1, nil, function()
				G_HandlersManager.crossWarHandler:sendGetBetAward()
			end, nil)
		return
	end

	-- 取消监听
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_AWARD)
end

function CrossWarTimer:_update()
	-- get current match state
	local state = G_Me.crossWarData:getCurState()

	-- immediately return in 3 situations
	if state == 0 or 
	   self._stopUpdate or 
	   not G_Me.crossWarData:isBattleTimePulled() then
		return
	end

	-- if the match state has been changed externally, execute the update callback and return
	if self._curState ~= state then
		self:_dispatchEvent(CrossWarCommon.EVENT_STATE_CHANGED)
		self._curState = state
		return
	end

	-- if time has passed current state, step through until the correct state
	local endTime = G_Me.crossWarData:getTime(state).close
	local statePassed = false
	while G_ServerTime:getLeftSeconds(endTime) <= 0 do
		-- if time has passed last state, request battle time of next round
		if state == CrossWarCommon.STATE_AFTER_CHAMPIONSHIP then
			-- 监听比赛状态
			uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO, self._onRcvCrossWarInfo, self)

			-- 监听期间暂停更新
			self._stopUpdate = true

			-- 开始请求下一轮比赛的时间信息
			G_HandlersManager.crossWarHandler:sendGetBattleTime()

			-- immediately return
			return
		else
			-- step to next state, and check the time again
			G_Me.crossWarData:stepToNextState()
			state = G_Me.crossWarData:getCurState()
			endTime = G_Me.crossWarData:getTime(state).close

			statePassed = true
		end
	end

	-- if state has changed, but this round is not over, execute the update callback
	-- if state has not changed, just refresh the time
	if statePassed then
		-- 在争霸赛期间，任何状态切换，都需要跟服务器同步好状态后，才发送状态切换的事件
		if G_Me.crossWarData:isChampionshipEnabled() then
			-- 记录好目标状态
			self._targetState = state

			-- 监听比赛状态
			uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO, self._onRcvCrossWarInfo_middle, self)

			-- 暂停更新
			self._stopUpdate = true

			-- 向服务器请求实时的比赛状态
			G_HandlersManager.crossWarHandler:sendGetBattleInfo()

			-- 立即返回
			return
		end

		self:_dispatchEvent(CrossWarCommon.EVENT_STATE_CHANGED)
		self._curState = state
	else
		local d, h, m, s = G_ServerTime:getLeftTimeParts(endTime)
		local strCD = ""

		if d > 0 then
			strCD = strCD .. d .. G_lang:get("LANG_CROSS_WAR_CD_DAY")
		end
		if h > 0 then
			strCD = strCD .. h .. G_lang:get("LANG_CROSS_WAR_CD_HOUR")
		end
		if m > 0 then
			strCD = strCD .. m .. G_lang:get("LANG_CROSS_WAR_CD_MINUTE")
		end
		if d <= 0 then
			strCD = strCD .. s .. G_lang:get("LANG_CROSS_WAR_CD_SECOND")
		end

		self:_dispatchEvent(CrossWarCommon.EVENT_UPDATE_COUNTDOWN, strCD)
	end
end

function CrossWarTimer:_dispatchEvent(event, param)
	uf_eventManager:dispatchEvent(event, nil, false, param)
end

return CrossWarTimer