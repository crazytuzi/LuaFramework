OpenGiftModel =BaseClass(LuaModel)

function OpenGiftModel:__init()
	self:InitData()
	self:InitEvent()
	self:AddListener()
end

function OpenGiftModel:GetInstance()
	if OpenGiftModel.inst == nil then
		OpenGiftModel.inst = OpenGiftModel.New()
	end
	return OpenGiftModel.inst
end

function OpenGiftModel:InitData()
	self.redTips = false
	self.rewardList = {} -- 奖励表
	self.equipData = {} -- 武器数据
	self.buyState = OpenGiftConst.BuyState.NoBuy
	self.openState = OpenGiftConst.OpenState.Unopen
	self.isPop = OpenGiftConst.PopState.UnPop
end

function OpenGiftModel:InitEvent()
	local cfgReward = {}
	local equip = {}
	local career = LoginModel:GetInstance():GetLoginRole().career
	local allRewardCfg = GetCfgData("reward")
	for k , v in pairs(allRewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.OpenGift then
			cfgReward = v.reward
		end
	end

	for i, v in ipairs(cfgReward) do
		if v[1] == 1 then
			if self:GetEquipNeedJob(v[2]) == 0 or self:GetEquipNeedJob(v[2]) == career then
				table.insert(self.rewardList, v)
			end
		else
			table.insert(self.rewardList, v)
		end
	end

end

function OpenGiftModel:AddListener()
	-- 切换账号
	self.reloginHandler = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
		self:Clear()
	end)
end

function OpenGiftModel:GetReward()
	return self.rewardList
end

function OpenGiftModel:GetEquipNeedJob( id )
	return GetCfgData("equipment"):Get(id).needJob
end

function OpenGiftModel:RefreshBuyState( state )
	if state then
		if self.buyState ~= state then
			self.buyState = state
		end
	end	
	-- self:ShowRedTips()
end

function OpenGiftModel:RefreshOpenState( state )
	if state then
		if self.openState ~= state then
			self.openState = state
		end
	end
end

function OpenGiftModel:ShowRedTips()
	if self.buyState == OpenGiftConst.BuyState.Complete then
		self:DispatchEvent(OpenGiftConst.HadBuy)
		self.redTips = true
	end
	if self.redTips then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.OpenGift , state = true})
	end
end

function OpenGiftModel:IsGetRewardState()
	return self.buyState == OpenGiftConst.BuyState.Complete
end

-- 是否已开启活动
function OpenGiftModel:IsOpenActivity()
	return self.openState == OpenGiftConst.OpenState.Open
end

function OpenGiftModel:GetRedTips()
	return self.redTips
end

function OpenGiftModel:GetId()
	local allRewardCfg = GetCfgData("charge")
	for k , v in pairs(allRewardCfg) do
		if type(v) ~= 'function' and v and v.type == 2 then
			return v.id
		end
	end
end

function OpenGiftModel:GetEquipmentId()
	local id = 0
	for _,v in ipairs(self.rewardList) do
		if v[1] == 1 then
			id = v[2]
		end
	end
	return id
end

function OpenGiftModel:GetEquipment()
	local equipment = 0
	equipment = GetCfgData("equipment"):Get(self:GetEquipmentId()).weaponStyle
	return equipment
end

function OpenGiftModel:GetEquipmentDes()
	local des = GetCfgData("equipment"):Get(self:GetEquipmentId()).des
	des = string.gsub(des, "。", "")
	local desList = StringSplit(des, "，")
	return desList
end

function OpenGiftModel:CloseOpenGiftByState()
	if not self:IsOpenActivity() then
		MainUIModel:GetInstance():CloseOpenGift()
	end		
end

function OpenGiftModel:ClosePopPanel( isClose )
	if isClose and self.isPop == OpenGiftConst.PopState.Pop then
		self.isPop = OpenGiftConst.PopState.UnPop
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.OpenGift, show = false, isClose = true})
	end
end

function OpenGiftModel:Clear()
	OpenGiftModel.inst = nil
	self.redTips = false
	self.rewardList = nil
	self.equipData = nil
	self.buyState = OpenGiftConst.BuyState.NoBuy
	self.openState = OpenGiftConst.OpenState.Unopen
	self.isPop = OpenGiftConst.PopState.UnPop
	if OpenGiftModel.inst then
		OpenGiftModel.inst = nil
	end
end

function OpenGiftModel:__delete()
	self:Clear()
	GlobalDispatcher:RemoveEventListener(self.reloginHandler)
end
