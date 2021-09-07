require("game/dimai/dimai_data")
require("game/dimai/dimai_view")
require("game/dimai/dimai_fb_info_view")

DiMaiCtrl = DiMaiCtrl or BaseClass(BaseController)

function DiMaiCtrl:__init()
	if DiMaiCtrl.Instance ~= nil then
		print_error("[DiMaiCtrl]error:create a singleton twice")
		return
	end
	DiMaiCtrl.Instance = self

	self.data = DiMaiData.New()
	self.view = DiMaiView.New(ViewName.DiMai)
	self.fb_info_view = DiMaiFbInfoView.New(ViewName.DiMaiFbInfoView)

	self:RegisterAllProtocols()

	-- 监听系统事件
	self:BindGlobalEvent(OtherEventType.DAY_COUNT_CHANGE, BindTool.Bind(self.DayCountChange, self))
end

function DiMaiCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.fb_info_view then
		self.fb_info_view:DeleteMe()
		self.fb_info_view = nil
	end

	DiMaiCtrl.Instance = nil
end

function DiMaiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFBDimaiInfo, "OnFBDimaiInfo")
	self:RegisterProtocol(SCRoleDimaiInfo, "OnRoleDimaiInfo")
	self:RegisterProtocol(SCLayerDimaiInfo, "OnLayerDimaiInfo")
	self:RegisterProtocol(SCSingleDimaiInfo, "OnSingleDimaiInfo")
end

function DiMaiCtrl:DayCountChange(day_counter_id)
	if day_counter_id == -1 or day_counter_id == DAY_COUNT.DAYCOUNT_ID_DIMAI_FB_CHALLENGE_TIMES then
		local day_count = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_DIMAI_FB_CHALLENGE_TIMES) or 0
		self.data:SetDiMaiChallengeCount(day_count)
		if self.view then
			self.view:Flush("flush_dimai_content")
		end
		RemindManager.Instance:Fire(RemindName.DiMaiTask)
	end
end

-- 申请玩家地脉信息
-- DIMAI_OPERA_TYPE 地脉操作类型
function DiMaiCtrl:SendReqDimaiOpera(opera_type, param_1, param_2)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSDimaiOpera)
	protocol_send.opera_type = opera_type or 0
	protocol_send.param_1 = param_1 or 0
	protocol_send.param_2 = param_2 or 0
	protocol_send:EncodeAndSend()
end

-- 地脉副本信息
function DiMaiCtrl:OnFBDimaiInfo(protocol)
	self.data:SetFBDimaiInfo(protocol)

	if self.fb_info_view then
		self.fb_info_view:Flush()
	end

	if protocol.is_finish >= 1 then
		local dimai_cfg = DiMaiData.Instance:GetDiMaiInfoCfg(protocol.layer, protocol.point)
		if dimai_cfg then
			local reward_list = dimai_cfg.challenge_rewards or {}
			if protocol.is_win >= 1 then
				local data = {}
				for k,v in pairs(reward_list) do
					table.insert(data, v)
				end
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = data})
			else
				ViewManager.Instance:Open(ViewName.FBFailFinishView, nil, "item_finish", {data = reward_list})
			end
		end
	end
end

-- 玩家地脉信息
function DiMaiCtrl:OnRoleDimaiInfo(protocol)
	self.data:SetRoleDimaiInfo(protocol)
	if self.view then
		self.view:Flush("flush_dimai_content")
		TipsCtrl.Instance:FlushDiMaiTargetTaskTip()									-- 刷新每日目标
		TipsCtrl.Instance:FlushDiMaiCampBuffTip(protocol.camp_dimai_list)			-- 刷新国家Buff
	end
	RemindManager.Instance:Fire(RemindName.DiMaiTask)
end

-- 一层地脉信息
function DiMaiCtrl:OnLayerDimaiInfo(protocol)
	self.data:SetLayerDimaiInfo(protocol)
	if self.view then
		self.view:Flush()
	end
end

-- 单个地脉信息
function DiMaiCtrl:OnSingleDimaiInfo(protocol)
	self.data:SetSingleDimaiInfo(protocol)
	if self.view then
		local dimai_info = {}
		dimai_info.is_challenging = protocol.is_challenging
		dimai_info.dimai_info = protocol.dimai_info
		TipsCtrl.Instance:FlushDiMaiChallengeTip(dimai_info)
	end
end