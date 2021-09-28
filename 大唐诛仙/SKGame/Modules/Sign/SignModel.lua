SignModel = BaseClass(LuaModel)

function SignModel:___init()
	self:InitData()
end

function SignModel:InitData()
	self.signMsg = LoginModel:GetInstance():GetSignMsg() or {}
	local conData = GetCfgData("conSignReward")
	-- 记录连续签到表的天数索引
	self.conIdxTab = {}
	for k, v in pairs(conData) do
		table.insert(self.conIdxTab, tonumber(k))
	end
	table.sort(self.conIdxTab, function(v1, v2)
		return v1 < v2
	end)
	-- 连续签到天数
	self.rewardDays = self.signMsg.conSignDay or 0
	-- 已签次数
	self.qiandaoDay = self.signMsg.signNum or 0
	self:SetLock(false)
	-- test
	-- self.signMsg.day = 30
	-- self.signMsg.state = 1
	-- wq("curDay ==>> " .. self.signMsg.day)
end

function SignModel:GetRed()
	local redState = false 
	if self:GetState() == 0 and self:GetQiandaoDay()< SignConst.NUM_DAYS then
		redState = true
	end
	return redState
end

function SignModel:GetQiandaoDay()
	return self.qiandaoDay or 0
end

function SignModel:GetRewardTab(idx)
	local index = self.conIdxTab[idx] or 1
	local conData = GetCfgData("conSignReward") or {}
	return conData:Get(index).reward[1] 
end

function SignModel:GetRewardMaxDay()
	return self.conIdxTab[#self.conIdxTab] or 0
end

-- @param : idx ==>> 1, 2, 3
-- @ret   : 3, 6, 9
function SignModel:GetRewardIdx(idx)
	return self.conIdxTab[idx] or 3
end

-- @desc : 连续签到奖励是否已经领取
-- @param : idx ==>> 1, 2, 3
-- @ret : bool
function SignModel:CheckGiftGot(idx)
	local day = self:GetRewardIdx(idx)
	for _, v in pairs(self.signMsg.rewardList) do
		if v == day then
			return true
		end
	end
	return false
end

-- 礼包状态
function SignModel:GetGiftState(idx)
	local needDay = self.conIdxTab[idx] or 0
	local state = SignConst.STATE_REWARD.CANNOT_LINGQU
	if self.rewardDays >= needDay then
		if self:CheckGiftGot(idx) then
			state = SignConst.STATE_REWARD.YILINGQU
		else
			state = SignConst.STATE_REWARD.CAN_LINGQU
		end
	end
	return state
end

-- 当前连续天数
function SignModel:GetRewardDays()
	return self.rewardDays or 0
end

function SignModel:GetSignMsg()
	local msg = self.signMsg or {}   --检测，防止day为0
	if (not msg.day) or msg.day == 0 then
		msg.day = 1
	end
	return msg
end

-- @ ret ==>> gift : {3,0,10000,1} 
--			  data.doubleReward : 0 or 1
function SignModel:GetData(day)
	local data = GetCfgData("signReward"):Get(day)
	local role = LoginModel:GetInstance():GetLoginRole()
	local career = role.career
	local gift = nil
	local num = nil
	if #data.reward > 1 then -- reward长度大于1，根据职业显示奖励
		 gift = data.reward[career]
	else
		 gift = data.reward[1]
	end

	return gift, data.doubleReward
end

function SignModel:GetDay() -- 当前天数
	return self.signMsg.day or 1
end

function SignModel:GetState() -- 当前状态
	if not self.signMsg then return 0 end
	return self.signMsg.state or 0
end

function SignModel:GetInstance()
	if SignModel.inst == nil then
		SignModel.inst = SignModel.New()
	end
	return SignModel.inst
end


function SignModel:__delete()
	SignModel.inst = nil
end

-- 单格状态
function SignModel:GetGridState(idx)
	local curDay = self.signMsg.day

	local bGot = false
	if self:GetState() > 0 then
		bGot = true
	end

	if idx <= self.qiandaoDay then
		return SignConst.STATE_GRID.YILINGQU
	else
		if idx <= curDay then
			if (not bGot) and idx == self.qiandaoDay + 1 then
				return SignConst.STATE_GRID.CAN_LINGQU
			else
				return SignConst.STATE_GRID.CAN_BUQIAN
			end
		else
			return SignConst.STATE_GRID.CANNOT_BUQIAN
		end
	end
end

-- 签到按钮状态
function SignModel:GetBtnState()
	local curDay = self.signMsg.day

	if self.qiandaoDay >= SignConst.NUM_DAYS then
		return SignConst.STATE_GRID.YILINGQU
	end

	local bGot = false
	if self:GetState() > 0 then
		bGot = true
	end

	if self.qiandaoDay >= curDay then
		return SignConst.STATE_GRID.YILINGQU
	else
		if bGot then
			return SignConst.STATE_GRID.CAN_BUQIAN
		else
			return SignConst.STATE_GRID.CAN_LINGQU
		end
	end
end

-- 补签消耗元宝数
function SignModel:GetBuqianCost()
	return (self.signMsg.reSignNum + 1) * SignConst.BUQIAN_COST_FACTOR
end

--------------------------------->>>>>>>>> s2c change data start

function SignModel:SetSignInfo(signMsg)
	self.signMsg = signMsg or {}
	self.rewardDays = self.signMsg.conSignDay or 0
	self.qiandaoDay = self.signMsg.signNum or 0
	self:SetLock(false)
	self:DispatchEvent(SignConst.SignMsgChange)
	GlobalDispatcher:DispatchEvent(EventName.SignRedChange, self:GetRed())  
end

function SignModel:SetConReward(signNum)
	local list = self.signMsg.rewardList
	if list then
		local exist = false
		for i = 1, #list do
			if list[i] == signNum then
				exist = true
			end
		end
		if not exist then
			table.insert(self.signMsg.rewardList, signNum)
		end
	end
	self:DispatchEvent(SignConst.ConSignGotOne, signNum)
end

----------------------------------<<<<<<<<<< s2c change data end

function SignModel:SetLock(bLock)
	self.bLock = bLock
end

function SignModel:GetLock()
	return self.bLock
end