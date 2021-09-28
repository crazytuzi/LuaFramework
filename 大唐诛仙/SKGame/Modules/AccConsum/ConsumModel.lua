
ConsumModel = BaseClass(LuaModel)

function ConsumModel:GetInstance()
	if ConsumModel.inst == nil then
		ConsumModel.inst = ConsumModel.New()
	end
	return ConsumModel.inst
end

function ConsumModel:__init()
	self.idList = {} -- 需要读取的id
	self.totalRecharge = 0 -- 累计充值总金额
	self.rewardList = {} -- 已领取奖励列表
	self.rewardIdList = {} -- 已领取奖励id
	self.accVo = {} -- 奖励数据
	self.redTips = false
	self:AddHandler()
	self:Config()
end

function ConsumModel:AddHandler()
	-- 切换账号清除信息
	self.reloginHandler = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
		self:Clear()
	end)

	self.handler0 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre)
		if key == "diamond" then
			local delta = value - pre
			if delta < 0 then
				-- GlobalDispatcher:DispatchEvent(EventName.RefershConsumRed)
				self:IsHasCanGet()
			end
		end
	end)
end

function ConsumModel:Clear()
	self.idList = {}
	self.totalRecharge = 0
	self.rewardList = {}
	self.rewardIdList = {}
	self.accVo = {}
	self.redTips = false
	self:Config()
end

function ConsumModel:Config()
	-- 初始化数据
	self:GetCfgData()
	if self.rewardList then
		for i,v in ipairs(self.rewardList) do
			self:InitData( v )
		end
	end
end

function ConsumModel:InitData( v )
	local vo = {}
	vo.condition = v[1]
	vo.reward = v[2]
	vo.id = v[3]
	vo.state = ConsumConst.RewardState.NoGet
	self.accVo[vo.id] = vo
end

-- 设置领取状态
function ConsumModel:SetRewardState( id, state )
	if self.accVo[id].state ~= state then
		self.accVo[id].state = state
	end
end

-- 总金额
function ConsumModel:SetTotalRecharge( sum )
	if sum then
		self.totalRecharge = sum
	end
end

function ConsumModel:GetTotalRecharge()
	return self.totalRecharge
end

-- 已领取奖励
function ConsumModel:SetRewardIdList( list )
	self.rewardIdList = {}
	if list then
		SerialiseProtobufList( list, function ( id )
			table.insert( self.rewardIdList, id )
		end)
	end
end

function ConsumModel:GetRewardIdList()
	return self.rewardIdList
end

-- 添加已领取奖励id
function ConsumModel:AddRewardIdList( id )
	if id then
		table.insert( self.rewardIdList, id )
		self:Fire(ConsumConst.ChangeCtrl, id)
	end
end

-- 是否有可领取奖励
function ConsumModel:IsHasCanGet()
	self.redTips = false
	local canGet = {}
	local allCondition = {} 

	local allRewardCfg = GetCfgData("reward")
	for k , v in pairs(allRewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.ConsumPay then
			table.insert(allCondition, v.condition)
		end
	end

	for _, data in pairs(allCondition) do
		if self.totalRecharge >= data then
			table.insert( canGet, data )
		end
	end

	if #canGet <= 0 then
		self.redTips = false
	else
		self.redTips = true
		if #self.rewardIdList > 0 then
			if #self.rewardIdList >= #canGet then
				self.redTips = false
			else
				self.redTips = true
			end
		end
	end

	if self.redTips then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS, {moduleId = FunctionConst.FunEnum.carnival , state = true })
	end

	return self.redTips
end

function ConsumModel:GetAccVo()
	return self.accVo
end

function ConsumModel:GetIdList()
	return self.idList
end

-- 读表
function ConsumModel:GetCfgData()
	local allRewardCfg = GetCfgData("reward")
	for k , v in pairs(allRewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.ConsumPay then
			table.insert(self.idList, v.id)
			table.insert(self.rewardList, {v.condition, v.reward, v.id})
		end
	end
	table.sort( self.idList )
	table.sort( self.rewardList, function(a , b)
		return a[3] < b[3]
	end)
end

function ConsumModel:__delete()
	ConsumModel.inst = nil
	self.totalRechargeId = 0
	self.rewardList = {}
	self.rewardIdList = {}
	self.AccVo = {}
	GlobalDispatcher:RemoveEventListener(self.reloginHandler)
end