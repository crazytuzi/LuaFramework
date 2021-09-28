local CrossPVPTimer = class("CrossPVPTimer")

local CrossPVPConst = require("app.const.CrossPVPConst")

function CrossPVPTimer:ctor()
	self._timer = nil
	self._stopUpdate = false
	self._targetTime = 0 	-- 用于同步阶段的目标时间
end

function CrossPVPTimer:startTimer()
	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(1, handler(self, self._update))
	end
end

function CrossPVPTimer:closeTimer()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil

		-- 取消所有事件的监听
		uf_eventManager:removeListenerWithTarget(self)
	end
end

function CrossPVPTimer:_update()
	local pvpData = G_Me.crossPVPData

	-- get current match course and stage
	local course = pvpData:getCourse()
	local stage  = pvpData:getStage()

	-- immediately return in following situations
	if course == CrossPVPConst.COURSE_NONE or self._stopUpdate then
		return
	end

	-- 如果本阶段或本赛程已经过了，那么就步进到现在时间点应该所在的赛程和阶段
	local _, endTime = pvpData:getStageTime(stage)
	local stagePassed = false
	while G_ServerTime:getLeftSeconds(endTime) < 0 do
		self._targetTime = endTime

		if course == CrossPVPConst.COURSE_EXTRA and stage == CrossPVPConst.STAGE_REVIEW then
			-- 整场比赛结束
			--__LogTag(TAG, "----跨服夺帅全场比赛结束!")
			self._stopUpdate = true
			require("app.scenes.crosspvp.CrossPVP").exit()
			if G_SceneObserver:getSceneName() == "CrossPVPScene" then
				uf_sceneManager:getCurScene():onBackKeyEvent()
			end
			return
		else
			-- 步入下一阶段，然后再次检查下一阶段的时间是否也过了
			course, stage = pvpData:stepToNextStage()
			_, endTime 	  = pvpData:getStageTime(stage)
			stagePassed   = true
		end
	end

	-- 如果有阶段或赛程变更，就向服务器同步状态
	if stagePassed then
		-- 向服务器同步状态并暂停update
		self._stopUpdate = true
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BASE_INFO, self._onRcvBaseInfo, self)
		G_HandlersManager.crossPVPHandler:sendGetBaseInfo()
		--__LogTag(TAG, "----开始同步状态，" .. "目标时间：" .. G_ServerTime:getTimeString(self._targetTime))
	else
		self._targetTime = 0
	end
end

function CrossPVPTimer:_onRcvBaseInfo(data)
	-- 同步未完成，1秒后继续
	if data.time < self._targetTime then
		uf_funcCallHelper:callAfterDelayTime(1, nil, function()
				G_HandlersManager.crossPVPHandler:sendGetBaseInfo()
			end, nil)

		return
	end

	-- 同步完成
	self._targetTime = 0
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_PVP_GET_BASE_INFO)

	-- 到了新一轮的投注阶段，重置一些数据
	if G_Me.crossPVPData:getStage() == CrossPVPConst.STAGE_BET then
		G_Me.crossPVPData:reset()
	end

	-- 如果到了下一轮的回顾阶段，拉取回顾信息
	if G_Me.crossPVPData:needRequestReviewInfo() then
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_REVIEW_INFO, self._onRcvReviewInfo, self)
		G_HandlersManager.crossPVPHandler:sendGetReviewInfo()
	-- 如果到了战斗阶段，拉取房间号
	elseif G_Me.crossPVPData:needRequestRoomID() then
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_ROLE_SUCC, self._onRcvRoomInfo, self)
		G_HandlersManager.crossPVPHandler:sendGetCrossPvpRole()
	-- 否则直接处理事件
	else
		self:_handleEvent(CrossPVPConst.EVENT_STAGE_CHANGED)
	end
end

function CrossPVPTimer:_onRcvReviewInfo()
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_PVP_GET_REVIEW_INFO)
	self:_handleEvent(CrossPVPConst.EVENT_STAGE_CHANGED)
end

function CrossPVPTimer:_onRcvRoomInfo(isSuccess)
	-- 如果请求失败（有可能是服务器数据延迟或繁忙），等1秒再拉取一遍
	if not isSuccess then
		uf_funcCallHelper:callAfterDelayTime(1, nil, function()
			G_HandlersManager.crossPVPHandler:sendGetCrossPvpRole()
		end, nil)

		return
	end

	-- 请求成功
	uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_CROSS_PVP_GET_ROLE_SUCC)
	self:_handleEvent(CrossPVPConst.EVENT_STAGE_CHANGED)
end

function CrossPVPTimer:_handleEvent(event, param)
	local CrossPVP = require("app.scenes.crosspvp.CrossPVP")

	if CrossPVP.needDispatchEvent() then
		--__LogTag(TAG, "----切换至赛程：" .. G_Me.crossPVPData:getCourse() .. " 阶段：" .. G_Me.crossPVPData:getStage())
		uf_eventManager:dispatchEvent(event, nil, false, param)
	else
		-- 这里表示在外部界面，需要更新快捷入口按钮
		CrossPVP.updateCrossPVPTips()
	end

	self._stopUpdate = false
end

return CrossPVPTimer