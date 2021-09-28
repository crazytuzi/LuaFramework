RegistModules("Recharge1/RechargeModel")
RegistModules("Recharge1/RechargeConst")
RegistModules("Recharge1/view/GrowUpPanel")
RegistModules("Recharge1/view/RechargeDailyPanel")
RegistModules("Recharge1/view/AllWelfareItem")
RegistModules("Recharge1/view/JijinItem")
RegistModules("Recharge1/view/RewardItem")
RegistModules("Recharge1/view/RechargePanel")

RegistModules("Recharge1/View/TombContent")
RegistModules("Recharge1/View/TombCell")
RegistModules("Recharge1/View/TombPopLayer")
RegistModules("Recharge1/View/TombRewardShow")
RegistModules("Recharge1/View/TurnContent")

RegistModules("Recharge1/View/SevenRechargeContent")
RegistModules("Recharge1/View/SevenRechargePop")

RechargeController = BaseClass(LuaController)

function RechargeController:GetInstance()
	if RechargeController.inst == nil then
		RechargeController.inst = RechargeController.New()
	end
	return RechargeController.inst
end

function RechargeController:__init()
	self.model = RechargeModel:GetInstance()
	resMgr:AddUIAB("Recharge")
	resMgr:AddUIAB("Pay")
	resMgr:AddUIAB("Welfare")
	
	self:Config()
	self:AddEvent()
	self:RegistProto()
	self:C_GetPayActData()
end

function RechargeController:Open(idx)
	if not self.rechargePanel or not self.rechargePanel.isInited then
		self.rechargePanel = RechargePanel.New()
	end
	self.rechargePanel:Open(idx)
end

function RechargeController:AddEvent()
	self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()
		if self.inst then
			self.inst:Destroy()
		end
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
		self:CheckOpenSevenRecharge()
	end)
end

function RechargeController:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function RechargeController:Config()
	self:C_GetTurntableData()
	self:C_GetSevenPayData()
end

function RechargeController:RegistProto()
	self:RegistProtocal("S_GetPayActData")
	self:RegistProtocal("S_GetDailyRrechargeReward")
	self:RegistProtocal("S_GetGrowthFund")
	self:RegistProtocal("S_GetNationalWelfare")
	self:RegistProtocal("S_BuyGrowthFound")
	--陵墓探宝
	self:RegistProtocal("S_GetTombData", "HandleGetTomb")
	self:RegistProtocal("S_Tomb", "HandleTombResult")
	self:RegistProtocal("S_ChangeTomb", "HandleChangeTomb")
	--转盘
	self:RegistProtocal("S_GetTurntableData", "OnGetTurntableData")
	self:RegistProtocal("S_TurntableDraw", "OnTurntableDraw")
	self:RegistProtocal("S_GetTurnRecList", "OnGetTurnRecList")
	--七天累计
	self:RegistProtocal("S_GetSevenPayData", "OnGetSevenPayData")
	--self:RegistProtocal("S_GetSevenPayReward", "OnGetSevenPayReward")
end	

function RechargeController:S_GetPayActData(buffer)                --获取充值相关数据
	local msg = self:ParseMsg(activity_pb.S_GetPayActData(), buffer)
	self.model.dailyRecharge = msg.dailyRrecharge
	self.model.isbuyGrowthFund = msg.isbuyGrowthFund

	if msg.buyGrowthFundNum >= self.model.buyGrowthFundNum then
		self.model.buyGrowthFundNum = msg.buyGrowthFundNum
	end
	
	self.model.dailyRewardState = {} 
	self.model.growRewardState = {}
	self.model.allRewardState = {}

	SerialiseProtobufList( msg.drRewardList, function ( item )       --每日累计奖励领取状态
		table.insert(self.model.dailyRewardState, item)
	end )

	SerialiseProtobufList( msg.gfRewardList, function ( item )       --成长基金领取状态
		table.insert(self.model.growRewardState, item)
	end )

	SerialiseProtobufList( msg.nwRewardList, function ( item )       --全民福利领取状态
		table.insert(self.model.allRewardState, item)
	end )

	ConsumModel:GetInstance():SetTotalRecharge( msg.totalSpend )       --累计消费

	ConsumModel:GetInstance():SetRewardIdList( msg.tsRewardList )		--已领取累计消费奖励列表

	self.model:DispatchEvent(RechargeConst.DailyRechargeData)

	local getedRewardList = {}
	SerialiseProtobufList(msg.trRewardList , function (item)
		table.insert(getedRewardList , item)
	end)

	self.model:ShowRedTips()
	GlobalDispatcher:DispatchEvent(EventName.UpdateTotalRechargeData , {totalRecharge = msg.totalRrecharge , getedRewardList = getedRewardList})	
end

function RechargeController:S_GetDailyRrechargeReward(buffer)                --获取到每日累计奖励
	local msg = self:ParseMsg(activity_pb.S_GetDailyRrechargeReward(), buffer)
	table.insert(self.model.dailyRewardState, msg.id)
	self.model:DispatchEvent(RechargeConst.DailyRechargeGet)
end

function RechargeController:S_GetGrowthFund(buffer)                --获取到成长基金奖励
	local msg = self:ParseMsg(activity_pb.S_GetGrowthFund(), buffer)
	table.insert(self.model.growRewardState, msg.id)
	self.model:DispatchEvent(RechargeConst.LQJijinData)
end

function RechargeController:S_GetNationalWelfare(buffer)                --获取到全民福利奖励
	local msg = self:ParseMsg(activity_pb.S_GetNationalWelfare(), buffer)
	table.insert(self.model.allRewardState, msg.id)
	self.model:DispatchEvent(RechargeConst.allRewardData)
end

function RechargeController:S_BuyGrowthFound(buffer)                --收到购买成长基金
	local msg = self:ParseMsg(activity_pb.S_BuyGrowthFound(), buffer)
	if msg.state == 0 then
		GlobalDispatcher:DispatchEvent(EventName.BuyJiJinSuccess)
	end
end


------------------------------------------发送协议-----------------------------------------------------------

function RechargeController:C_GetPayActData()                --获取充值相关数据
	self:SendEmptyMsg(activity_pb, "C_GetPayActData")
end

function RechargeController:C_GetDailyRrechargeReward(id)    --获取每日累计奖励
	local msg = activity_pb.C_GetDailyRrechargeReward()
	msg.id = id
	self:SendMsg("C_GetDailyRrechargeReward", msg)
end

function RechargeController:C_GetGrowthFund(id)    --获取成长基金奖励
	local msg = activity_pb.C_GetGrowthFund()
	msg.id = id
	self:SendMsg("C_GetGrowthFund", msg)
end

function RechargeController:C_GetNationalWelfare(id)    --获取全民福利奖励
	local msg = activity_pb.C_GetNationalWelfare()
	msg.id = id
	self:SendMsg("C_GetNationalWelfare", msg)
end

function RechargeController:C_BuyGrowthFound()
	self:SendEmptyMsg(activity_pb, "C_BuyGrowthFound")  --购买成长基金
end

function RechargeController:__delete()
	self:RemoveEvent()
	RechargeController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model=nil
end

-- 陵墓part
--进入时请求陵墓总数据
function RechargeController:C_GetTombData()
	self:SendEmptyMsg(activity_pb, "C_GetTombData")
end
--探索陵墓
function RechargeController:C_Tomb(tombIndex)
	if tombIndex then
		local msg = activity_pb:C_Tomb()
		msg.tombIndex = tombIndex - 1
		self:SendMsg("C_Tomb", msg)
	end
end
--切换陵墓
function RechargeController:C_ChangeTomb()
	self:SendEmptyMsg(activity_pb, "C_ChangeTomb")
end

function RechargeController:HandleGetTomb(msgParam)
	local msg = self:ParseMsg(activity_pb:S_GetTombData(), msgParam)
	if msg then
		self.model:HandleGetTomb(msg)
	end
end

function RechargeController:HandleTombResult(msgParam)
	local msg = self:ParseMsg(activity_pb:S_Tomb(), msgParam)
	if msg then
		self.model:HandleTombResult(msg)
	end
end

function RechargeController:HandleChangeTomb(msgParam)
	local msg = self:ParseMsg(activity_pb:S_ChangeTomb(), msgParam)
	if msg then
		self.model:HandleChangeTomb(msg)
	end
end

function RechargeController:GetTombPanel()
	if not self:IsExistTombPanel() then
		self.tombPanel = TombContent.New()
	end
	return self.tombPanel
end

function RechargeController:IsExistTombPanel()
	return self.tombPanel
end

function RechargeController:DestroyTombPanel()
	if self:IsExistTombPanel() then
		self.tombPanel:Destroy()
	end
	self.tombPanel = nil
end

function RechargeController:OpenTombRewardShow()
	local layer = TombRewardShow.New()
	-- UIMgr.ShowPopup(layer, false, -352, 25, function()
	-- end)
	UIMgr.ShowPopupToPos(layer, 385, 175, function()
	end)
end

function RechargeController:OpenTombChangePop()
	local layer = TombPopLayer.New()
	local data = {tType = 2}
	layer:SetData(data)
	UIMgr.ShowCenterPopup(layer, function()
	end)
end

function RechargeController:OpenTombSure(idx)
	local layer = TombPopLayer.New()
	local data = {tType = 1, idx = idx}
	layer:SetData(data)
	UIMgr.ShowCenterPopup(layer, function()
	end)
end

--转盘part
--获取转盘相关数据
function RechargeController:C_GetTurntableData()
	self:SendEmptyMsg(activity_pb, "C_GetTurntableData")
end
--转盘抽奖
--@param tType : 抽奖类型（1: 首抽, 2: 非元宝, 3: 元宝）
function RechargeController:C_TurntableDraw(tType)
	if tType then
		local msg = activity_pb:C_TurntableDraw()
		msg.type = tType
		self:SendMsg("C_TurntableDraw", msg)
	end
end
--获取转盘抽奖榜单信息
--@param start : 起始; offset: 数量
function RechargeController:C_GetTurnRecList(start, offset)
	offset = offset or self.model:GetHistoryOnePageNum()
	if start then
		local msg = activity_pb:C_GetTurnRecList()
		msg.start = start
		msg.offset = offset
		self.model:SetTurnRetListIdx(start, offset)
		self:SendMsg("C_GetTurnRecList", msg)
	end
end

function RechargeController:TurnInitRequest()
	self:C_GetTurntableData()
	self:C_GetTurnRecList(RechargeConst.TURN_LIST_START_IDX, self.model:GetHistoryOnePageNum())
end

function RechargeController:OnGetTurntableData(msgParam)
	local msg = self:ParseMsg(activity_pb:S_GetTurntableData(), msgParam)
	if msg then
		self.model:OnGetTurntableData(msg)
	end
end

function RechargeController:OnTurntableDraw(msgParam)
	local msg = self:ParseMsg(activity_pb:S_TurntableDraw(), msgParam)
	if msg then
		self.model:OnTurntableDraw(msg)
	end
end

function RechargeController:OnGetTurnRecList(msgParam)
	local msg = self:ParseMsg(activity_pb:S_GetTurnRecList(), msgParam)
	if msg then
		self.model:OnGetTurnRecList(msg)
	end
end

function RechargeController:GetTurnPanel()
	if not self:IsExistTurnPanel() then
		self.turnPanel = TurnContent.New()
	end
	return self.turnPanel
end

function RechargeController:IsExistTurnPanel()
	return self.turnPanel
end

function RechargeController:DestroyTurnPanel()
	if self:IsExistTurnPanel() then
		self.turnPanel:Destroy()
	end
	self.turnPanel = nil
end

-- 七天累计充值
--获取七天累计充值数据
function RechargeController:C_GetSevenPayData()
	self:SendEmptyMsg(activity_pb, "C_GetSevenPayData")
end

--领取七天累计充值奖励
-- function RechargeController:C_GetSevenPayReward(id)
-- 	if id then
-- 		local msg = activity_pb:C_GetSevenPayReward()
-- 		msg.id = id
-- 		self:SendMsg("C_GetSevenPayReward", msg)
-- 	end
-- end

--获取七天累计充值数据
function RechargeController:OnGetSevenPayData(msgParam)
	local msg = self:ParseMsg(activity_pb:S_GetSevenPayData(), msgParam)
	if msg then
		self.model:OnGetSevenPayData(msg)
	end
end

--领取七天累计充值奖励
-- function RechargeController:OnGetSevenPayReward()
-- 	local msg = self:ParseMsg(activity_pb:S_GetSevenPayReward(), msgParam)
-- 	if msg then
-- 		self.model:OnGetSevenPayReward(msg)
-- 	end
-- end

function RechargeController:GetSevenRechargePanel()
	if not self:IsExistSevenRechargePanel() then
		self.sevenPanel = SevenRechargeContent.New()
	end
	return self.sevenPanel
end

function RechargeController:IsExistSevenRechargePanel()
	return self.sevenPanel
end

function RechargeController:DestroySevenRechargePanel()
	if self:IsExistSevenRechargePanel() then
		self.sevenPanel:Destroy()
	end
	self.sevenPanel = nil
end

function RechargeController:PushToPopList(isShow)
	if isShow then
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.SevenRecharge, show = true, openCb = self.ShowSevenOpen, args = {self}})
	else
		GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.SevenRecharge, show = false, isClose = false})
	end
end

function RechargeController:CheckOpenSevenRecharge()
	if self.handler1 then
		GlobalDispatcher:RemoveEventListener(self.handler1)
		self.handler1 = nil
	end
	local isShow = self:ShouldSevenPush()
	self:PushToPopList(isShow)
end

function RechargeController:ShouldSevenPush()
	local open = false
	local model = RechargeModel:GetInstance()
	local state, idx = model:GetSevenState()
	local cfg = GetCfgData("chargeActivity"):Get(idx)
	local tab = MainUIModel:GetInstance():GetMainUIVoListById(FunctionConst.FunEnum.carnival)
	if tab and tab:GetState() ==  MainUIConst.MainUIItemState.Open then
		if state == RechargeConst.SevenState.Open and cfg then
			for i = 1, 3 do
				local rewardId = cfg.rewardStr[i]
				if not model:IsSevenRewardGot(rewardId) then
					open = true
				end
			end
		end
	end
	return open
end

function RechargeController:GetSevenRechargePopPanel()
	if not self:IsExistSevenRechargePopPanel() then
		self.sevenPopPanel = SevenRechargePop.New()
	end
	return self.sevenPopPanel
end

function RechargeController:IsExistSevenRechargePopPanel()
	return self.sevenPopPanel and self.sevenPopPanel.isInited
end

function RechargeController:DestroySevenRechargePopPanel()
	if self:IsExistSevenRechargePopPanel() then
		self.sevenPopPanel:Destroy()
	end
	self.sevenPopPanel = nil
end

function RechargeController:ShowSevenOpen()
	if not self:IsExistSevenRechargePopPanel() then
		local panel = self:GetSevenRechargePopPanel()
		panel:Open()
		self:C_GetSevenPayData()
	end
end