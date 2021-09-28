TotalRechargeModel = BaseClass(LuaModel)

function TotalRechargeModel:__init()
	self:InitData()
	self:InitEvent()
end

function TotalRechargeModel:__delete()
	self:CleanEvent()
	self:CleanData()
	self:CleanSingleton()
end

function TotalRechargeModel:GetInstance()
	if TotalRechargeModel.inst == nil then
		TotalRechargeModel.inst = TotalRechargeModel.New()
	end
	return TotalRechargeModel.inst
end

function TotalRechargeModel:CleanSingleton()
	TotalRechargeModel.inst = nil
end

function TotalRechargeModel:InitData()
	self:InitRewardDataFromCfg()
	self:SortRewardData()
	self:InitTotalRechargeData()
	self:InitRedTipsFlag()
end

function TotalRechargeModel:CleanData()

end

function TotalRechargeModel:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.UpdateTotalRechargeData , function(tabData)
		self:UpdateTotalRechargeData(tabData)
		self:DispatchEvent(TotalRechargeConst.RefershTotalRechargeState)
	end)

	self.handler1 = GlobalDispatcher:AddEventListener(EventName.FinishPay ,function (payItemId)
		self:HandleFinishPay(payItemId)
		self:DispatchEvent(TotalRechargeConst.RefershTotalRechargeState)
	end)
end

function TotalRechargeModel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

--从reward配置表中取得累计充值奖励进行初始化
function TotalRechargeModel:InitRewardDataFromCfg()
	self.rewardData = {} --累积充值的奖励数据（配置表）
	local allRewardCfg = GetCfgData("reward")
	for k , v in pairs(allRewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.AccumulatedRecharge then
			table.insert(self.rewardData, {
				id = v.id , 
				state = TotalRechargeConst.RewardState.None , 
				condition = v.condition,
				des = v.des,
				reward = v.reward}
			)
		end
	end
end

--对累积奖励数据进行排序
function TotalRechargeModel:SortRewardData()
	table.sort(self.rewardData , function (a , b)
		--return a.id < b.id
		return a.condition < b.condition
	end)
end

function TotalRechargeModel:GetRewardData()
	return self.rewardData
end

--根据奖励编号获取奖励列表
function TotalRechargeModel:GetRewardItemsData(rewardId)
	local rtnRewardItems = {}
	if rewardId then
		local rewardData = self:GetRewardDataById(rewardId)
		local allRewardItems = rewardData.reward or {}
		if (not TableIsEmpty(rewardData)) and (not TableIsEmpty(allRewardItems)) then

			local playerVo = SceneModel:GetInstance():GetMainPlayer()
			if playerVo then
				local career = playerVo.career or 0
				for index = 1 , #allRewardItems do
					local  item = allRewardItems[index]
					if  item then
						local type = item[1];
						if type == 1 then
							local equipCfg = GoodsVo.GetEquipCfg(item[2] or 0)
							if equipCfg.needJob == 0 or equipCfg.needJob == career then
								table.insert(rtnRewardItems , item)
							end
						else 
							table.insert(rtnRewardItems , item)
						end
					end
				end
			end
		end
	end
	return rtnRewardItems
end

--通过id获取奖励数据
function TotalRechargeModel:GetRewardDataById(rewardId)
	local rtnRewardData = {}
	if rewardId then
		for _ , rewardData in pairs(self.rewardData) do
			if rewardData and rewardData.id == rewardId then
				rtnRewardData = rewardData
				break
			end
		end
	end
	return rtnRewardData
end

--设置某个奖励数据的领取状态
function TotalRechargeModel:SetRewardDataState(rewardId , stateVal)
	if not rewardId and not stateVal then return end
	for k , rewardData in pairs(self.rewardData) do
		if rewardData and rewardData.id == rewardId then
			self.rewardData[k].state = stateVal
			break
		end
	end
end

--重置奖励数据状态
function TotalRechargeModel:ResetRewardDataState()
	for k , rewardData in pairs(self.rewardData) do
		if self.rewardData[k] then
			self.rewardData[k].state = TotalRechargeConst.RewardState.None
		end
	end
end

--领取某个奖励成功后重置奖励数据状态
function TotalRechargeModel:HandleGetTotalRechargeReward(rewardId)
	if rewardId then
		self:SetRewardDataState(rewardId , TotalRechargeConst.RewardState.HasGet)
	end
end

--获取累积奖励对应的奖励物品是否含有装备
-- 奖励
-- {类型，物品编号，数量，是否绑定}
-- 装备和物品外的奖励不需填“物品编号”
-- 类型：
-- 1=装备
-- 2=物品
-- 3=金币
-- 4=钻石
-- 5=代金卷
-- 6=贡献值
-- 7=荣誉值
-- 8=经验
function TotalRechargeModel:IsHasEquipment(rewardId)
	local isHas = false
	if rewardId then
		local rewardData = self:GetRewardDataById(rewardId)
		if not TableIsEmpty(rewardData) then
			for i = 1 , #rewardData.reward do
				local rewardItem = rewardData.reward[i]
				if rewardItem then
					if rewardItem[1] == 1 then
						isHas = true
					end
				end
			end
		end
	end
	return isHas
end

--初始化累积充值
function TotalRechargeModel:InitTotalRechargeData()
	self.totalRecharge = 0
end

--设置累积充值
function TotalRechargeModel:SetTotalRechargeData(data)
	if data ~= nil then
		self.totalRecharge = data
	end
end

--获取累积充值
function TotalRechargeModel:GetTotalRechargeData()
	return self.totalRecharge
end

--重置累计充值额度
function TotalRechargeModel:ResetTotalRechargeData()
	self.totalRecharge = 0
end

--累加每次充值，设置累积充值
function TotalRechargeModel:SetTotalRechargeDataByAccumulation(data)
	if data then
		self.totalRecharge = self.totalRecharge + data
	end
end

--根据已经领取奖励，设置奖励状态
function TotalRechargeModel:SetRewardDataToHasGetState(rewardIdList)
	for index = 1 , #rewardIdList do
		if rewardIdList[index] then
			self:SetRewardDataState(rewardIdList[index] , TotalRechargeConst.RewardState.HasGet)
		end
	end
end

--根据累积充值额度，设置奖励状态
function TotalRechargeModel:SetRewardDataByTotalRecharge(totalCharge)
	local totalRecharge = self:GetTotalRechargeData()
	for k , rewardData in pairs(self.rewardData) do
		if rewardData and rewardData.state ~= TotalRechargeConst.RewardState.HasGet  then
			if rewardData.condition <= totalRecharge then
				self.rewardData[k].state = TotalRechargeConst.RewardState.CanGet
			end
		end
	end
end

--更新至最新的累积充值总额
--更新至最新已经领取的奖励
function TotalRechargeModel:UpdateTotalRechargeData(tabData)
	local totalRecharge = tabData.totalRecharge or -1
	local getedRewardList = tabData.getedRewardList or nil
	if totalRecharge ~= -1 and getedRewardList ~= nil then
		self:SetTotalRechargeData(totalRecharge)
		self:SetRewardDataToHasGetState(getedRewardList)
		self:SetRewardDataByTotalRecharge()
		--self:ShowRedTips()
		GlobalDispatcher:DispatchEvent(EventName.RefershTotalRechargeRedTipsState)
	end
end

function TotalRechargeModel:HandleFinishPay(payItemId)
	if payItemId then
		local price = PayModel:GetInstance():GetPriceByPayItem(payItemId, PayConst.GetType.Price)
		if price ~= 0 then
			self:SetTotalRechargeDataByAccumulation(price)
			self:SetRewardDataByTotalRecharge()
			--self:ShowRedTips()
			GlobalDispatcher:DispatchEvent(EventName.RefershTotalRechargeRedTipsState)
		end
	end
end

function TotalRechargeModel:InitRedTipsFlag()
	self.lastShowRedTipsFlag = false
end

--退出登录重置累积奖励领取状态值
function TotalRechargeModel:Reset()
	self:ResetRewardDataState()
	self:ResetTotalRechargeData()
end

--是否有可领取的奖励
function TotalRechargeModel:IsHasRewardCanGet()
	local rtnIsHas = false
	for k , rewardData in pairs(self.rewardData) do
		if rewardData and rewardData.state == TotalRechargeConst.RewardState.CanGet then
			rtnIsHas = true
			break
		end
	end
	return rtnIsHas
end

function TotalRechargeModel:ShowRedTips()
	local isCanShow = self:IsHasRewardCanGet()
	if self.lastShowRedTipsFlag ~= isCanShow then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS, {moduleId = FunctionConst.FunEnum.carnival , state = isCanShow })
		self.lastShowRedTipsFlag = isCanShow
	end
end