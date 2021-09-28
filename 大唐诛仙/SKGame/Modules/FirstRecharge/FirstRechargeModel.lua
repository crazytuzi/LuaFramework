
FirstRechargeModel = BaseClass(LuaModel)

function FirstRechargeModel:GetInstance()
	if FirstRechargeModel.inst == nil then
		FirstRechargeModel.inst = FirstRechargeModel.New()
	end
	return FirstRechargeModel.inst
end

function FirstRechargeModel:__init()
	self:AddListener()
	self:Config()
end

function FirstRechargeModel:AddListener()
	-- 切换账号清除信息
	self.reloginHandler = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
		self:Clear()
	end)
end

function FirstRechargeModel:Config()
	-- 初始化数据
	self.fristPayRewardState = FirstRechargeConst.RewardState.NoGet -- 0:不可领 1:可领取，2:已领取
	self.rewardId = 0 -- 读表id
	self.redTips = false -- 红点提示
	self.isPop = FirstRechargeConst.PopState.UnPop -- 是否弹出
	self.taskPop = false
end

function FirstRechargeModel:Clear()
	self.isPop = FirstRechargeConst.PopState.UnPop
	self.fristPayRewardState = FirstRechargeConst.RewardState.NoGet
	self:RedTips(false)
	self.redTips = false
	self.taskPop = false
	if FirstRechargeModel.inst then
		FirstRechargeModel.inst = nil
	end
end

-- 领取状态
function FirstRechargeModel:SetFirstPayRewardState( state )
	if state then
		self.fristPayRewardState = state
		if self.fristPayRewardState == FirstRechargeConst.RewardState.CanGet then
			self:DispatchEvent(FirstRechargeConst.CanGet, FirstRechargeConst.RewardState.CanGet)
			self:RedTips(true)
		elseif self.fristPayRewardState == FirstRechargeConst.RewardState.Received then
			self:CloseFirstRechargeByState()
			self:RedTips(false)
		end
	end
end

function FirstRechargeModel:GetFirstPayRewardState()
	return self.fristPayRewardState
end

function FirstRechargeModel:IsShowIcon()
	return self:IsGetFirstPayRewardState() == true
end

function FirstRechargeModel:IsGetFirstPayRewardState()
	return self.fristPayRewardState == FirstRechargeConst.RewardState.Received
end

function FirstRechargeModel:CloseFirstRechargeByState()
	if self:IsGetFirstPayRewardState() then
		MainUIModel:GetInstance():CloseFirstRecharge()
		MainUIModel:GetInstance():RefershMainUIVoList()
	end
end

function FirstRechargeModel:ClosePopPanel( isClose )
	if isClose and self.isPop == FirstRechargeConst.PopState.Pop then
		self.isPop = FirstRechargeConst.PopState.UnPop
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.FirstRecharge, show = false, isClose = true})
	end
end

-- 红点
function FirstRechargeModel:RedTips( bool )
	if bool ~= nil then
		self.redTips = bool
		if self.redTips then
			GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.firstRecharge , state = true})
		end
	end
end

-- 完成任务ID弹窗
function FirstRechargeModel:GetPopTaskId()
	local taskId = 0
	local pushNotice = GetCfgData("pushNotice")
	for key, v in pairs(pushNotice) do
		if type(v) ~= 'function' and v.moduleId == FunctionConst.FunEnum.firstRecharge and v.pop ~= 0 then
			taskId = v.pop
			self:SetTaskPop(true)
			break
		end
	end
	return taskId
end

function FirstRechargeModel:SetTaskPop( bool )
	self.taskPop = bool
end

-- 是否弹窗任务id
function FirstRechargeModel:IsTaskPopId( id )
	return self:GetPopTaskId() == id
end

-- 是否已弹任务弹窗
function FirstRechargeModel:HasTaskPop()
	return self.taskPop
end

function FirstRechargeModel:GetReward()
	local rtnReward = {}
	local allReward = {}
	local career = LoginModel:GetInstance():GetLoginRole().career
	local allRewardCfg = GetCfgData("reward")
	for k , v in pairs(allRewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.FirstRecharge then
			self.rewardId = v.id
			allReward = v.reward
		end
	end

	for i, v in ipairs(allReward) do
		if v[1] == 1 then
			if self:GetEquipNeedJob(v[2]) == 0 or self:GetEquipNeedJob(v[2]) == career then
				table.insert(rtnReward, v)
			end
		else
			table.insert(rtnReward, v)
		end
	end

	return rtnReward
end

function FirstRechargeModel:GetEquipNeedJob( id )
	return GetCfgData("equipment"):Get(id).needJob
end

function FirstRechargeModel:__delete()
	self:Clear()
	GlobalDispatcher:RemoveEventListener(self.reloginHandler)
end