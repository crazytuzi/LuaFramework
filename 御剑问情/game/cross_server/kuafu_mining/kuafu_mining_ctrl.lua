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

	local fuben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
	if fuben_icon_view:IsOpen() then
		fuben_icon_view:SetMiningBuffBubblesText() --更新buff倒计时
	end

	if self.view then
		self.view:FlushKuaFuMiningSkill()
		self.view:Flush("rank_view")       --刷新排名列表
	end
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

--设置矿物采集物状态（未被采集、被人采集中）
function KuaFuMiningCtrl:OnKuaFuMiningGatherChange(pos_x, pos_y, gather_status, role_obj_id)
	local new_pos_list = self.data:GetMinDistancePosList()
	if not new_pos_list or not next(new_pos_list) then
		return
	end
	--如果是主角的采集更变，则忽略
	if new_pos_list[1].x == pos_x and new_pos_list[1].y == pos_y 
		and gather_status == KuaFuMiningData.GatherStatus.in_gather 
		and role_obj_id == Scene.Instance:GetMainRole():GetObjId() then
		return
	end
	self.data:SetGatherStatus(pos_x, pos_y, gather_status) 
	--print_error(Scene.Instance:GetMainRole():GetObjId(), role_obj_id)
	
	--导航中，如果目标采集物被其他人采集了
	if gather_status == KuaFuMiningData.GatherStatus.in_gather and new_pos_list[1].x == pos_x and new_pos_list[1].y == pos_y then
		if KuaFuMiningData.Instance:GetMiningIsAuto() then
			self.view:Flush("gather_view") --刷新，重新寻找矿物
		end
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

--取消托管和自动导航
function KuaFuMiningCtrl:StopAutoMining()
	local mining_info = KuaFuMiningData.Instance:GetMiningRoleInfo()
	if mining_info.status == SPECIAL_CROSS_MINING_ROLE_STATUS.SPECIAL_CROSS_MINING_ROLE_STATUS_AUTO_MINING then
		self:SendCSCrossMiningOperaReq(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_CANCEL_AUTO_MINING) 	--取消托管
	end
	if self:GetGuideState() then
		self:SetGuideState(false) 	--取消自动导航
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

function KuaFuMiningCtrl:SetMiningButtonVisable(is_show)
  	if self.view then
  		self.view:SetMiningButtonVisable(is_show)
  	end
end

--打开或关闭兑换面板
function KuaFuMiningCtrl:ClickGiftViewVisable()
  	if self.view then
  		self.view:OnClickGiftViewVisable()
  	end
end

--购买无敌buff
function KuaFuMiningCtrl:BuyMiningBuff()
	if self.data:GetGatherBuffRemainTime() > 0 then 							--如果buff还有剩余时间，则提示已购买buff
		TipsCtrl.Instance:ShowSystemMsg(Language.KuaFuFMining.BoughtBuff)
	else
		self:SendCSCrossMiningOperaReq(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_BUY_BUFF)
	end
end

--使用眩晕技能
function KuaFuMiningCtrl:UseSkill()
	self:SendCSCrossMiningOperaReq(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_USE_SKILL, GuajiCache.target_obj_id)
end

function KuaFuMiningCtrl:SwitchPackageEffectState(enable)
	if self.view then
		self.view:SwitchPackageEffectState(enable)
	end
end