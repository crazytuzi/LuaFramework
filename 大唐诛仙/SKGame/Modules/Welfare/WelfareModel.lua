WelfareModel =BaseClass(LuaModel)

function WelfareModel:__init()
	self:InitData()
	self:InitEvent()
end

function WelfareModel:__delete()
	self:RemoveOnLineTimer()
	WelfareModel.inst = nil
end

function WelfareModel:GetInstance()
	if WelfareModel.inst == nil then
		WelfareModel.inst = WelfareModel.New()
	end
	return WelfareModel.inst
end

function WelfareModel:InitData()
	self.onlineRewardData = {} --在线时长奖励数据
	self.onlineTime = 0 --玩家每天在线时间(秒)
	self.onlineTimerKey = "WelfareModelOnlineTimerKey"
	self.onlineRewardTimeKey = "onlineRewardTimeKey"
	self:InitOnlineRewardData()
	self.lastShowRedTipsFlag = false
end

function WelfareModel:InitEvent()

end
--疯狂冲级 与冲战力 活动时间
function WelfareModel:GetHuoDongTime()
	local serverNo = LoginModel:GetInstance():GetLastServerNo()
	local serverTime = TimeTool.GetCurTime()
	local openServerTime = LoginModel:GetInstance():GetServerOpenDateByServerNo(serverNo)


	--时间差值
	local differTime = serverTime  - openServerTime
	if differTime < 0 then
		differTime = 0
	end
	local day = GetCfgData("constant"):Get(72).value
	local shengYuTime = day * 86400000 - differTime
	return shengYuTime
end 

function WelfareModel:GetPanelTabData()
	local rtnTabData = {}
	local cfgData = GetCfgData("system"):Get(3)
		if cfgData then
			cfgData = cfgData.data
			local n = 0 
			local t = self:GetHuoDongTime()
			for i = 1, #cfgData do													
				if i == 3 or i == 4 then 
					if  t > 0 then
						n = n + 1
						local cfgInfo = StringSplit(cfgData[i], "_")

						table.insert(rtnTabData, {cfgInfo[1], cfgInfo[2]})
					end
				else
					if i ~= 0 then
						n = n + 1							
						local cfgInfo = StringSplit(cfgData[i], "_")
						table.insert(rtnTabData, {cfgInfo[1], cfgInfo[2]})
					end
				end				
			end
		end
	return rtnTabData
end

function WelfareModel:InitOnlineRewardData()
	local rewardCfg = GetCfgData("reward")
	for k , v in pairs(rewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.OnlineReward then
			table.insert(self.onlineRewardData , {id = v.id , state = WelfareConst.OnlineRewardState.None})
		end
	end
	self:SortOnlineRewardData()
end

function WelfareModel:ResetOnlineRewardData()
	for k , v in pairs(self.onlineRewardData) do
		if self.onlineRewardData[k] then
			self.onlineRewardData[k].state = WelfareConst.OnlineRewardState.None
		end
	end
	self:SortOnlineRewardData()
end

--[[
	权重排序: 状态为已经领取的排后面，其次以奖励Id排
]]
function WelfareModel:SortOnlineRewardData()
	table.sort(self.onlineRewardData, function(a, b) 
		return a.id < b.id
	end)
end

function WelfareModel:GetOnlineRewardData()
	return self.onlineRewardData
end

function WelfareModel:HandleGetReward(data)
	if data then
		if data.id ~= 0 then
			local idx = self:GetIndexByRewardId(data.id)
			if idx ~= 0 and (not TableIsEmpty(self.onlineRewardData[idx]))  then
				self.onlineRewardData[idx].state = data.state
			end
		end
	end
end

function WelfareModel:GetIndexByRewardId(rewardId)
	local rtnIndex = 0
	if rewardId ~= nil then
		for k , v in pairs(self.onlineRewardData) do
			if v.id == rewardId then
				rtnIndex = k
				break
			end
		end
	end
	return rtnIndex
end

function WelfareModel:SetOnlineTime(sec)
	if sec then
		self.onlineTime = sec
	end
end

function WelfareModel:GetOnlineTime()
	return self.onlineTime
end

function WelfareModel:SetOnlineRewardList(listReward)
	if listReward then
		for index = 1, #listReward do
			local curRewardId = listReward[index].id
			if curRewardId ~= 0 then
				-- if not TableIsEmpty(self.onlineRewardData[curRewardId]) then
				-- 	self.onlineRewardData[curRewardId].state = listReward[index].state
				-- end
				local idx = self:GetIndexByRewardId(curRewardId)
				if idx ~= 0 and (not TableIsEmpty(self.onlineRewardData[idx]))  then
					self.onlineRewardData[idx].state = listReward[index].state
				end
			end
		end
	end
	self:SetOnlineRewardState()
	self:SortOnlineRewardData()
end

function WelfareModel:SetOnlineRewardState()
	for id, value in pairs(self.onlineRewardData) do
		if  self.onlineRewardData[id].state ~= WelfareConst.OnlineRewardState.HasGet then
			if self:IsCanGetReward(self.onlineRewardData[id].id) == true then
				self.onlineRewardData[id].state = WelfareConst.OnlineRewardState.CanGet
			else
				self.onlineRewardData[id].state = WelfareConst.OnlineRewardState.CannotGet
			end
		end
	end
end

function WelfareModel:GetOnlineRewradCfgById(id)
	local rtnRewardData = {}
	if id then
		rtnRewardData = GetCfgData("reward"):Get(id) or {}
	end
	return rtnRewardData
end

function WelfareModel:IsCanGetReward(rewardId)
	local rtnIsCan = false
	if rewardId then
		local rewardCfg = self:GetOnlineRewradCfgById(rewardId)
		if not TableIsEmpty(rewardCfg) then
			if rewardCfg.condition < (self.onlineTime / 60) then
				rtnIsCan = true
			end
		end
	end
	return rtnIsCan
end

function WelfareModel:GetOnlineRewardDataById(id)
	local rtnRewardData = {}
	local idx = self:GetIndexByRewardId(id)
	if idx ~= 0 and (not TableIsEmpty(self.onlineRewardData[idx]))  then
		rtnRewardData = self.onlineRewardData[idx]
	end
	return rtnRewardData
end

function WelfareModel:IsOnlineRewardHasGet(id)
	local rtnHas = false
	if id then
		local idx = self:GetIndexByRewardId(id)
		local curRewardData = self.onlineRewardData[idx]
		if curRewardData and curRewardData.state == WelfareConst.OnlineRewardState.HasGet then
			rtnHas = true
		end
	end
	return rtnHas
end

function WelfareModel:IsOnlineRewardCanGet(id)
	local rtnCan = false
	if id then
		local idx = self:GetIndexByRewardId(id)
		local curRewardData = self.onlineRewardData[idx]
		if curRewardData and curRewardData.state == WelfareConst.OnlineRewardState.CanGet then
			rtnCan = true
		end
	end
	return rtnCan
end

function WelfareModel:IsOnlineRewardCanntGet(id)
	local rtnCan = false
	if id then
		local idx = self:GetIndexByRewardId(id)
		local curRewardData = self.onlineRewardData[idx]
		if curRewardData and curRewardData.state == WelfareConst.OnlineRewardState.CannotGet then
			rtnCan = true
		end
	end
	return rtnCan
end

--设置一个在线时间计时器
function WelfareModel:SetOnLineTimer()
	RenderMgr.Add(function() 
		self:ShowRedTips()
	end, self.onlineTimerKey)		
end

function WelfareModel:RemoveOnLineTimer()
	RenderMgr.Remove(self.onlineTimerKey)
	RenderMgr.Remove(self.onlineRewardTimeKey)
end

function WelfareModel:IsHasOnlineRewardCanGet()
	local isHas = false
	for id, value in pairs(self.onlineRewardData) do
		if self.onlineRewardData[id].state ~= WelfareConst.OnlineRewardState.HasGet then
			if self:IsCanGetReward(self.onlineRewardData[id].id) == true then
				isHas = true
				break
			end
		end
	end
	return isHas
end

function WelfareModel:ShowRedTips()
	self.onlineTime = self.onlineTime  + Time.deltaTime
	local signRed = SignModel:GetInstance():GetRed()
	local isShow = self:IsHasOnlineRewardCanGet() or signRed or  PowerModel:GetInstance():IsHasOnlevelRewardCanGet() or  PowerModel:GetInstance():IsHasOnbattleRewardCanGet()
	
	if self.lastShowRedTipsFlag ~= isShow then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS, {moduleId = FunctionConst.FunEnum.welfare , state = isShow })
		self.lastShowRedTipsFlag = isShow
	end
end

function WelfareModel:Reset()
	self.onlineTime = 0 --玩家每天在线时间(秒)
	RenderMgr.Remove(self.onlineTimerKey)
	self:ResetOnlineRewardData()
	PowerModel:GetInstance():ResetleveingMadmanData()
	PowerModel:GetInstance():ResetimproveBattleData()
end

-- 实名认证
	-- 获取奖励
	function WelfareModel:GetIdentifyReward()
		local rewardCfg = GetCfgData("reward")
		for k , v in pairs(rewardCfg) do
			if type(v) ~= 'function' and v and v.type == RewardConst.Type.Identify then
				self.indentifyRewardId = v.id
				return v.reward
			end
		end
	end
	-- 获取奖励ID
	function WelfareModel:GetIdentifyRewardId()
		return self.indentifyRewardId
	end
	-- 在线时长提醒
	function WelfareModel:AlartOnlineTime(time)
		if time then
			if time >= WelfareConst.OnlineAlart[2] and time < WelfareConst.OnlineAlart[3] then
				UIMgr.Win_Alter("防沉迷提示", WelfareConst.ThreeHourTxt, "实名认证", function ()
					self:LinkIdentify()
					UIMgr.HidePopup()
				end)
			elseif time >= WelfareConst.OnlineAlart[3] and time < WelfareConst.OnlineAlart[4] then
				UIMgr.Win_Alter("防沉迷提示", WelfareConst.FiveHourTxt, "实名认证", function ()
					self:LinkIdentify()
					UIMgr.HidePopup()
				end)
			elseif time >= WelfareConst.OnlineAlart[4] then
				UIMgr.Win_Alter("提示", WelfareConst.EightHourTxt, "确定", function ()
					UIMgr.HidePopup()
				end)
			end
		end
	end
	-- 设置领取状态
	function WelfareModel:SetRewardState( state )
		-- 0:未领 1：已领
		if self.idRewardState ~= WelfareConst.IdentifyRewardState.HasGet then
			self.idRewardState = state
		end
		if self.idRewardState == 2 and self.identifyState == 1 then
			self:DispatchEvent(WelfareConst.ChangeRewardState, WelfareConst.IdentifyRewardState.HasGet)
		elseif self.idRewardState == 0 and self.identifyState == 1 then
			self:DispatchEvent(WelfareConst.ChangeRewardState, WelfareConst.IdentifyRewardState.CanGet)
		end
	end

	function WelfareModel:GetRewardState()
		return self.idRewardState
	end
	-- 设置认证状态
	function WelfareModel:SetIdentifyState( state )
		-- 0:未领 1：已领
		self.identifyState = state
		if self.idRewardState == 2 and self.identifyState == 1 then
			self:DispatchEvent(WelfareConst.ChangeRewardState, WelfareConst.IdentifyRewardState.HasGet)
		elseif self.idRewardState == 0 and self.identifyState == 1 then
			self:DispatchEvent(WelfareConst.ChangeRewardState, WelfareConst.IdentifyRewardState.CanGet)
		end
		self:DispatchEvent(WelfareConst.ChangeIDState, self.identifyState)
	end

	function WelfareModel:GetIdentifyState()
		return self.identifyState
	end
	
	function WelfareModel:LinkIdentify()
		if self:GetHuoDongTime() > 0 then
			WelfareController:GetInstance():OpenWelfarePanel(WelfareConst.WelfareType.Identify)
		else
			WelfareController:GetInstance():OpenWelfarePanel(7)	
		end
	end