SevenLoginModel = BaseClass(LuaModel)

--七天登录福利--------------------------------

function SevenLoginModel:__init( ... )
	self:Reset()
	self:AddEvent()
end

function SevenLoginModel:Reset()
	self.lastShowRedTipsFlag  = false
	self.totleLoginDay = 0
	self.rewardGetState = {}

	self.isClose = 1
end

function SevenLoginModel:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()  --全局事件
		self:Reset()
	end)
end

function SevenLoginModel:IsClose()
	local isClose = false
	local list = self:GetRewardList()
	if self.isClose == 1 then
		if #list <= #self.rewardGetState then
			self.isClose = 0
		else
			self.isClose = 1
		end
	else
		self.isClose = 0
	end
	if self.isClose == 0 then
		isClose = true
	end
	return isClose
end

function SevenLoginModel:GetRewardList()
	local sevenLoginData = {}
	local sevenLoginCfg = GetCfgData("reward")
	for k , v in pairs(sevenLoginCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.SevenLogin then    
			table.insert(sevenLoginData, {v.id, v.reward, v.condition})
		end
	end

	table.sort(sevenLoginData , function(a , b)
		return a[1] < b[1]
	end)

	return sevenLoginData
end

function SevenLoginModel:IsCanGetReward()
	local isRed = false
	if self.totleLoginDay > #self.rewardGetState then
		isRed = true
	end
	return isRed
end

function SevenLoginModel:ShowRed()
	local isShowRed = self:IsCanGetReward()
	--if self.lastShowRedTipsFlag ~= isShowRed then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS, {moduleId = FunctionConst.FunEnum.SevenLogin , state = isShowRed })
		self.lastShowRedTipsFlag = isShowRed
	--end
end

function SevenLoginModel:GetInstance()
	if SevenLoginModel.inst == nil then
		SevenLoginModel.inst = SevenLoginModel.New()
	end
	return SevenLoginModel.inst
end

function SevenLoginModel:__delete()                                --清除
	GlobalDispatcher:RemoveEventListener(self.handler0)
	SevenLoginModel.inst = nil
end