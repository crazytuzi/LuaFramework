require("game/cross_server/kuafu_mining/kuafu_mining_data")
require("game/cross_server/kuafu_mining/kuafu_mining_view")
require("game/cross_server/kuafu_mining/kuafu_mining_gather_view")
require("game/cross_server/kuafu_mining/kuafu_mining_info_view")

KuaFuMiningCtrl = KuaFuMiningCtrl or BaseClass(BaseController)

function KuaFuMiningCtrl:__init()
	if nil ~= KuaFuMiningCtrl.Instance then
		print("[KuaFuMiningCtrl] attempt to create singleton twice!")
		return
	end
	KuaFuMiningCtrl.Instance = self

	self.data = KuaFuMiningData.New()
	self.view = KuaFuMiningView.New()

	self.last_state = 0
	self.mining_state = false
	self:RegisterAllProtocols()
end

function KuaFuMiningCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.delay_set_attached then
		GlobalTimerQuest:CancelQuest(self.delay_set_attached)
		self.delay_set_attached = nil
	end
	KuaFuMiningCtrl.Instance = nil
end

-- 注册协议
function KuaFuMiningCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossMiningRoleInfo, "OnCrossMiningRoleInfo")
	self:RegisterProtocol(SCCrossMiningRankInfo, "OnCrossMiningRankInfo")
	self:RegisterProtocol(SCCrossMiningResultInfo, "OnCrossMiningResultInfo")
	self:RegisterProtocol(SCCrossMiningGatherPosInfo, "OnCrossMiningGatherPosInfo")
	self:RegisterProtocol(SCCrossMiningRefreshNotiy, "OnSCCrossMiningRefreshNotiy")
	self:RegisterProtocol(SCCrossMiningBeStealedInfo, "OnSCCrossMiningBeStealedInfo")
end

function KuaFuMiningCtrl:SendCSCrossMiningOperaReq(req_type, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossMiningOperaReq)
	send_protocol.req_type = req_type
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
	-- print_warning("SendCSCrossMiningOperaReq",req_type,param1)
end

function KuaFuMiningCtrl:OnCrossMiningRoleInfo(protocol)
	self.data:SetMiningRoleInfo(protocol)
	self.view:Flush()

	if self.last_state ~= protocol.status and protocol.status == SPECIAL_CROSS_MINING_ROLE_STATUS.SPECIAL_CROSS_MINING_ROLE_STATUS_AUTO_MINING then
		self.view:Flush("gather_view")
	end

	self.last_state = protocol.status
end

function KuaFuMiningCtrl:OnCrossMiningRankInfo(protocol)
	self.data:SetMiningRankInfo(protocol)
	self.view:Flush("rank_view")
end

function KuaFuMiningCtrl:OnCrossMiningResultInfo(protocol)
	self.data:SetMiningResultInfo(protocol)

	local result_type = protocol.result_type
	if result_type == CROSS_MINING_EVENT_TYPE.CROSS_MINING_EVENT_TYPE_REWARD_MINE
	or result_type == CROSS_MINING_EVENT_TYPE.CROSS_MINING_EVENT_TYPE_ROBBER then
		self.view:Flush("box_view")
	elseif result_type == CROSS_MINING_EVENT_TYPE.CROSS_MINING_EVENT_TYPE_ADD_CHANCE then
		SysMsgCtrl.Instance:ErrorRemind(Language.KuaFuFMining.MineAddtimes)
	end
end

function KuaFuMiningCtrl:OnCrossMiningGatherPosInfo(protocol)
	self.data:SetMiningGatherPosInfo(protocol)
end

function KuaFuMiningCtrl:OnSCCrossMiningBeStealedInfo(protocol)
	self.data:SetMiningBeStealedInfo(protocol)
end

function KuaFuMiningCtrl:OnSCCrossMiningRefreshNotiy(protocol)
	 --矿物重新刷新
	SysMsgCtrl.Instance:ErrorRemind(Language.KuaFuFMining.MineRefresh)
	if KuaFuMiningData.Instance:GetMiningIsAuto() then
		self.view:Flush("gather_view")
	end
end

function KuaFuMiningCtrl:OpenFubenView()
	if self.view then
		self.view:Open()

		-- if self.delay_set_attached == nil then
		-- 	self.delay_set_attached = GlobalTimerQuest:AddDelayTimer(function ()
		-- 		self:SendCSCrossMiningOperaReq(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_JOIN)
		-- 	end, 5)
		-- end

	end
end

function KuaFuMiningCtrl:CloseFubenView()
	if self.view then
		self.view:Close()
	end
end

function KuaFuMiningCtrl:SetShowText(is_show)
	self.view:SetShowText(is_show)
end

function KuaFuMiningCtrl:SetBoxVisable(is_show)
	self.view:SetBoxViewVisable(is_show)
end

function KuaFuMiningCtrl:SetRankViewVisable(is_show)
	self.view:SetRankViewVisable(is_show)
end

function KuaFuMiningCtrl:SetGatherVisable(is_show)
	self.view:SetGatherVisable(is_show)
	self.mining_state = is_show
end

function KuaFuMiningCtrl:SetCloseGiftViewTime()
	self.view:SetCloseGiftViewTime()
end

function KuaFuMiningCtrl:GetMiningState()
	return self.mining_state
end

function KuaFuMiningCtrl:StopMining()
	self.view:StopMining()
end

function KuaFuMiningCtrl:StopAutoMining()
	local mining_info = KuaFuMiningData.Instance:GetMiningRoleInfo()
	if mining_info.status == SPECIAL_CROSS_MINING_ROLE_STATUS.SPECIAL_CROSS_MINING_ROLE_STATUS_AUTO_MINING then
		self:SendCSCrossMiningOperaReq(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_CANCEL_AUTO_MINING)
	end
	if self:GetGuideState() then
		self:SetGuideState(false)
	end
end

function KuaFuMiningCtrl:SetGuideState(value)
	if self.view then
		self.view:SetGuideState(value)
	end
end

function KuaFuMiningCtrl:GetGuideState()
	if self.view then
		return self.view:GetGuideState()
	end
	return false
end