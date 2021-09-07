require("game/lianfu_activity/lianfu_daily/lianfu_daily_data")
require("game/lianfu_activity/lianfu_daily/lianfu_daily_view")
require("game/lianfu_activity/lianfu_daily/lianfu_rank_view")
require("game/lianfu_activity/lianfu_daily/lianfu_server_group_view")
require("game/lianfu_activity/lianfu_daily/lianfu_midao_boss_view")

LianFuDailyCtrl = LianFuDailyCtrl or BaseClass(BaseController)

function LianFuDailyCtrl:__init()
	if LianFuDailyCtrl.Instance ~= nil then
		print_error("[LianFuDailyCtrl] Attemp to create a singleton twice !")
	end
	LianFuDailyCtrl.Instance = self
	self.view = LianFuDailyView.New(ViewName.LianFuDailyView)
	self.rank_view = LianFuRankView.New(ViewName.LianFuRankView)
	self.server_group_view = LianFuServerGroupView.New(ViewName.LianFuServerGroupView)
	self.midao_boss_view = MiDaoBossInfoView.New(ViewName.LianFuMiDaoBossView)
	self.data = LianFuDailyData.New()

	self:RegisterAllProtocols()

	self.role_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChangeHandler, self))
	self.param_change_callback_list = {}

	self.rank_change_event = GlobalEventSystem:Bind(OtherEventType.CROSS_RANK_CHANGE, BindTool.Bind(self.OnRankChange, self))
	self.scene_loaded = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT,BindTool.Bind(self.OnSceneLoaded, self))
end

function LianFuDailyCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	if self.server_group_view then
		self.server_group_view:DeleteMe()
		self.server_group_view = nil
	end

	if self.midao_boss_view then
		self.midao_boss_view:DeleteMe()
		self.midao_boss_view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.role_pos_change then
		GlobalEventSystem:UnBind(self.role_pos_change)
		self.role_pos_change = nil
	end

	if self.rank_change_event then
		GlobalEventSystem:UnBind(self.rank_change_event)
		self.rank_change_event = nil
	end

	if self.scene_loaded then
		GlobalEventSystem:UnBind(self.scene_loaded)
		self.scene_loaded = nil
	end

	self.param_change_callback_list = nil
	LianFuDailyCtrl.Instance = nil
end

function LianFuDailyCtrl:RegisterAllProtocols()
	self:RegisterProtocol(ServerGroupScoreParam, "OnServerGroupScoreParam")
	self:RegisterProtocol(SCCrossXYJDJudianInfo, "OnCrossXYJDJudianInfo")
	self:RegisterProtocol(SCCrossXYCityFBInfo, "OnCrossXYCityFBInfo")
	self:RegisterProtocol(SCCampBattleServerGroupInfoAck, "OnSCCampBattleServerGroupInfoAck")
	self:RegisterProtocol(SCCrossMiDaoInfo, "OnCrossMiDaoInfo")

	self:RegisterProtocol(CSCrossXYCityReq)
	self:RegisterProtocol(CSCampBattleServerGroupInfoReq)
end

function LianFuDailyCtrl:OnServerGroupScoreParam(protocol)
	self.data:SetServerGroupScoreParam(protocol)
	if self.view then
		self.view:Flush("score_info")
		self.view:Flush("belong_server")
	end
	self:DoNotify()
end

function LianFuDailyCtrl:OnCrossXYJDJudianInfo(protocol)
	self.data:SetCrossXYJDJudianInfo(protocol)
	if self.view then
		self.view:Flush("judian_info")
		self.view:Flush("belong_server")
	end
end

function LianFuDailyCtrl:OnCrossXYCityFBInfo(protocol)
	self.data:SetCrossXYCityFBInfo(protocol)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local xycity_cfg = LianFuDailyData.Instance:GetXYCityGroupCfg(vo.server_group)
	if xycity_cfg ~= nil and xycity_cfg.midao_npc ~= nil then
		local npc = Scene.Instance:GetNpcByNpcId(xycity_cfg.midao_npc)
		if npc ~= nil then
			npc:UpdateArrow()
		end
	end
	if self.view then
		self.view:Flush("midao_info")
	end
end

function LianFuDailyCtrl:OnSCCampBattleServerGroupInfoAck(protocol)
	self.data:SetCampBattleServerGroupInfo(protocol)
	if self.server_group_view then
		self.server_group_view:Flush()
	end
end

function LianFuDailyCtrl:SendCrossXYCityReq(opera_type, param1, param2)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCrossXYCityReq)
	protocol_send.opera_type = opera_type or 0
	protocol_send.param1 = param1 or 0
	protocol_send.param2 = param2 or 0
	protocol_send:EncodeAndSend()
end

function LianFuDailyCtrl:SendCampBattleServerGroupInfoReq()
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCampBattleServerGroupInfoReq)
	protocol_send:EncodeAndSend()
end

function LianFuDailyCtrl:OnMainRolePosChangeHandler(x, y)
	if Scene.Instance:GetSceneId() == 3156 then
		local value = self.data:GetIsInJuDianRange(x, y) 
		if self.view then
			self.view:ShowProgress(value)
		end
	end
end

function LianFuDailyCtrl:DoNotify()
	for k,v in pairs(self.param_change_callback_list) do
		v()
	end
end

function LianFuDailyCtrl:NotifyWhenParamChange(callback)
	if nil == callback then return end
	self.param_change_callback_list[callback] = callback
end

function LianFuDailyCtrl:UnNotifyWhenParamChange(callback)
	if nil == callback then return end
	self.param_change_callback_list[callback] = nil
end

function LianFuDailyCtrl:OnRankChange(rank_type)
	if rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_SERVER_GROUP_1_CONTRIBUTE or rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_SERVER_GROUP_2_CONTRIBUTE then
		if self.rank_view then
			self.rank_view:Flush()
		end
	end
end

function LianFuDailyCtrl:OnSceneLoaded(old_scene_type, new_scene_type)
	if self.view then
		self.view:Flush("task_view", {is_show = new_scene_type ~= SceneType.XianYangCheng})
	end
end

function LianFuDailyCtrl:FlushTaskList()
	if self.view then
		self.view:FlushTaskList()
	end
end

function LianFuDailyCtrl:FlushBossList()
	if self.view then
		self.view:FlushBossList()
	end
end

function LianFuDailyCtrl:OnCrossMiDaoInfo(protocol)
	self.data:SetCrossMiDaoInfo(protocol)
	if self.midao_boss_view then
		self.midao_boss_view:Flush()
	end
end