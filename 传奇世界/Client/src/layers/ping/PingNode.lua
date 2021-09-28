PingNode = class("PingNode", function() return cc.Node:create() end)

local path = "res/ping/"

function PingNode:ctor()
	self.NetState = {}
	self.NetState.good = {tag=1, res="bg2.png", tip="ping_tip_good", color=MColor.gree, time=0.1}
	self.NetState.normal = {tag=2, res="bg2.png", tip="ping_tip_normal", color=MColor.yellow,  time=1}
	self.NetState.bad = {tag=3, res="bg1.png", tip="ping_tip_bad", color=MColor.red,  time=2}
	self.netBadCount = 0
	self.netBadCountMax = 2
	self.isNetBadTip = true
	self.netBadTip = nil
	self.bg = createSprite(self, path.."bg2.png", cc.p(0, 0), cc.p(0.5, 0.5), nil, nil)
	self.bg:setVisible(false)
	--self:setState(self.NetState.good)

	--客户端不正常心跳计数器 防止使用加速软件
	self.heartSpeedBadCount = 0
	--高于该次数会对玩家强制处理
	self.heartSpeedBadCountMax = 3
	--记录上一次的服务器时间
	self.heartLastServerTime = nil
	--记录上一次的本地时间
	self.heartLastLocalTime = nil
	--低于该时间确认为异常时间
	self.heartSpeedBadTime = 10
	self.heartSpeedBadMinTime = 1
end

function PingNode:getServerTime()
	return self.heartLastServerTime
end

function PingNode:setState(state)
	self.bg:setTexture(path..state.res)
	if self.tip == nil then
		self.tip = createLabel(self.bg, game.getStrByKey(state.tip), cc.p(28, self.bg:getContentSize().height/2), cc.p(0, 0.5), 16, nil, nil, nil, state.color)
		self.tip:setVisible(false)
	else
		self.tip:setString(game.getStrByKey(state.tip))
	end

	if state == self.NetState.good then
		self:setVisible(false)
	else
		self:setVisible(true)
	end
end

function PingNode:check(netMessage, buff)
	--log("PingNode:check "..netMessage)
	if netMessage == FRAME_CG_HEART_BEAT then
		self.sendTime = os.clock()
		--停到可能存在的模拟心跳回包
		self:stopAllActions()
		--5秒后模拟一个心跳回包 防止出现网络阻塞包的状况而导致网络状态不更新
		performWithDelay(self, function() self:check(FRAME_GW_HEART_BEAT, nil) end, self.NetState.bad.time)
	elseif netMessage == FRAME_GW_HEART_BEAT then
		self.receiveTime = os.clock()
		if self.sendTime and self.sendTime ~= -1 then
			local time = self.receiveTime - self.sendTime
			--print("time = "..time, self.receiveTime, self.sendTime)
			if time < self.NetState.normal.time then
				self:clearNetBadCount()
			else
				self:addNetBadCount()
			end
			if userInfo then
				userInfo.pingNum = math.floor(time * 500)
			end
		end
		self.sendTime = -1 -- 无效时间

		if buff then
			local retTable = g_msgHandlerInst:convertBufferToTable("FrameHeartBeatRet", buff)
			local serverTime = retTable.nowtick
			self:checkHeartSpeed(serverTime)
			UpdateGTimeInfo(serverTime)
		end
	end
end

function PingNode:clearNetBadCount()
	self.netBadCount = 0
end

function PingNode:addNetBadCount()
	self.netBadCount = self.netBadCount + 1
	self:checkNetBadCount()
end

function PingNode:checkNetBadCount()
	log("PingNode:checkNetBadCount")
	--log("self.netBadCount = "..self.netBadCount)
	if self.isNetBadTip then
		if self.netBadCount >= self.netBadCountMax then
			if self.netBadTip == nil then
				local knowBtnFunc = function()
					self:clearNetBadCount()
					self.netBadCountMax = 15 * 6
					self.netBadTip = nil
				end
				local noMoreBtnFunc = function()
					self:clearNetBadCount()
					self.netBadTip = nil
					self.isNetBadTip = false
				end
				self.netBadTip = MessageBoxYesNoEx(nil,game.getStrByKey("ping_tip_net_bad") ,knowBtnFunc ,noMoreBtnFunc,game.getStrByKey("ping_btn_know"), game.getStrByKey("ping_btn_no_more"),true)
			end
		end
	end
end

--加速器判断方法1
function PingNode:checkHeartSpeed(serverTime)
	--log("serverTime = "..serverTime)
	--log("self.heartLastServerTime = "..tostring(self.heartLastServerTime))
	local time_scale = cc.Director:getInstance():getScheduler():getTimeScale()
	if time_scale > 1.0 then
		self:addHeartSpeedBad(true)
		return
	end
	local time_cd =  os.time() - serverTime
	if not G_LOCAL_TIME_CD then
		G_LOCAL_TIME_CD = time_cd
	elseif time_cd - G_LOCAL_TIME_CD >= 15  then
		if self.bad_cd_time then
			self:addHeartSpeedBad(true)
			return
		else
			self.bad_cd_time = true
		end
	else
		self.bad_cd_time = nil
	end
	if self.heartLastServerTime == nil then
		self.heartLastServerTime = serverTime
	else
		--print("heartTime = "..(serverTime - self.heartLastServerTime))
		if (serverTime - self.heartLastServerTime) < self.heartSpeedBadTime then
			if (serverTime - self.heartLastServerTime) > self.heartSpeedBadMinTime then
				--检测加速
				--self:addHeartSpeedBad()
			end
		else
			self.heartSpeedBadCount = 0
		end
		self.heartLastServerTime = serverTime
	end
end

-- --加速器判断方法2
-- function PingNode:checkHeartSpeed(serverTime)
-- 	log("serverTime = "..serverTime)
-- 	log("self.heartLastServerTime = "..tostring(self.heartLastServerTime))
-- 	local localTimeChange
-- 	local netTimeChange

-- 	if self.heartLastServerTime == nil then
-- 		self.heartLastServerTime = serverTime
-- 	else
-- 		netTimeChange = serverTime - self.heartLastServerTime
-- 	end

-- 	if self.heartLastLocalTime == nil then
-- 		self.heartLastLocalTime = os.time()
-- 	else
-- 		localTimeChange = os.time() - self.heartLastLocalTime
-- 	end

-- 	if (localTimeChange and localTimeChange > 0) and (netTimeChange and netTimeChange > 0) then
-- 		--log("localTimeChange = "..localTimeChange)
-- 		--log("netTimeChange = "..netTimeChange)
-- 		if localTimeChange > netTimeChange then
-- 			self:addHeartSpeedBad()
-- 			self.heartLastLocalTime = nil
-- 			self.heartLastServerTime = nil
-- 		else
-- 			self.heartSpeedBadCount = 0
-- 		end
-- 	end
-- end

function PingNode:addHeartSpeedBad(bad_time_cd)
	self.heartSpeedBadCount = self.heartSpeedBadCount + 1
	if (self.heartSpeedBadCount > self.heartSpeedBadCountMax) or bad_time_cd then
		--返回登陆了界面
		game.setAutoStatus(0)
		if not self.has_send then
			if __G_ON_CREATE_ROLE then
				self:clearHeartSpeedBad()
				return
			end
			self.has_send = true
			--g_msgHandlerInst:sendNetDataByFmtExEx( FRAME_CS_BAD_HEART,"i",G_ROLE_MAIN.obj_id )
			g_msgHandlerInst:sendNetDataByTableEx( LOGIN_CG_UNLOAD_PLAYER, "LoginUnloadPlayerReq", {})
			MessageBox(game.getStrByKey("bad_heart_speed_tip"), nil, function() self:clearHeartSpeedBad() game.ToLoginScene() end)
		end
	end
end

function PingNode:clearHeartSpeedBad()
	self.heartSpeedBadCount = 0
	self.heartLastServerTime = nil
end

return PingNode