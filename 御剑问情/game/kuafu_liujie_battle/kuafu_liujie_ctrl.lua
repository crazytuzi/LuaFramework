require("game/kuafu_liujie_battle/kuafu_liujie_data")
require("game/kuafu_liujie_battle/kuafu_liujie_view")
require("game/kuafu_liujie_battle/kuafu_liujie_scene_view")
require("game/kuafu_liujie_battle/kuafu_liujie_task_view")
require("game/kuafu_liujie_battle/kuafu_liujie_record_view")
require("game/kuafu_liujie_battle/kuafu_liujie_task_view_2")
require("game/kuafu_liujie_battle/kuafu_task_record_view")
require("game/kuafu_liujie_battle/kuafu_liujie_tips_reward_view")
require("game/kuafu_liujie_battle/kuafu_liujie_pre_view")
require("game/kuafu_liujie_battle/kuafu_liujie_battle_record_view")
require("game/kuafu_liujie_battle/kuafu_liujie_tj_fight_view")
require("game/kuafu_liujie_battle/kuafu_liujie_sw_fight_view")

KuafuGuildBattleCtrl = KuafuGuildBattleCtrl or BaseClass(BaseController)
InKuaFuLiuJieActivity = false
function KuafuGuildBattleCtrl:__init()
	if KuafuGuildBattleCtrl.Instance ~= nil then
		print_error("[KuafuGuildBattleCtrl] Attemp to create a singleton twice !")
	end
	KuafuGuildBattleCtrl.Instance = self

	self.view = KuafuGuildBattleView.New(ViewName.KuaFuBattle)
	self.data = KuafuGuildBattleData.New()

	self.scene_Panle = KuafuGuildBattleScenePanle.New(ViewName.KuaFuFightView)
	self.rank_view = KuafuTaskFollowView.New(ViewName.KuafuTaskView)
	self.rank_view_2 = KuafuGuildTaskDailyView.New(ViewName.DailyTaskView)
	self.record_view = KuafuGuildRecordView.New(ViewName.KuaFuRecordView)

	self.task_record_view = KuafuTaskRecordView.New(ViewName.KuafuTaskRecordView)
	self.battle_record_view = KuafuGuildBattleRecordView.New(ViewName.KuafuTaskBattleRecordView)
	self.kuafu_liujie_tips = KfLiujieRewardTip.New(ViewName.KuafuLiujieRewardTip)
	self.pre_view = KuafuLiujiePreView.New(ViewName.KuaFuLiuJiePre)
	self.kuafu_boss_tj_view = KuaFuBossTjFightView.New(ViewName.KuaFuBossTjFightView)
	self.kuafu_boss_sw_view = KuaFuBossSwFightView.New(ViewName.KuaFuBossSwFightView)
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnMainuiComplete, self))
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:RegisterAllProtocols()

	self.remind_timestamp = 0

end

-- 绑定事件bangding
function KuafuGuildBattleCtrl:OnMainuiComplete()
	KuafuGuildBattleCtrl.Instance:SendCrossTianjiangOperatorReq(CROSS_TIANJIANG_BOSS_OPER_TYPE.CROSS_TIANJIANG_BOSS_OPER_TYPE_BOSS_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossShenWuOperatorReq(CROSS_SHENWU_BOSS_OPER_TYPE.CROSS_SHENWU_BOSS_OPER_TYPE_BOSS_INFO)
end

function KuafuGuildBattleCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end
	if self.rank_view_2 then
		self.rank_view_2:DeleteMe()
		self.rank_view_2 = nil
	end
	if self.task_record_view then
		self.task_record_view:DeleteMe()
		self.task_record_view = nil
	end
	if self.battle_record_view then
		self.battle_record_view:DeleteMe()
		self.battle_record_view = nil
	end
	if self.kuafu_liujie_tips then
		self.kuafu_liujie_tips:DeleteMe()
		self.kuafu_liujie_tips = nil
	end
	if self.pre_view then
		self.pre_view:DeleteMe()
		self.pre_view = nil
	end

	if self.record_view then
		self.record_view:DeleteMe()
		self.record_view = nil
	end
	if self.scene_Panle then
		self.scene_Panle:DeleteMe()
		self.scene_Panle = nil
	end
	KuafuGuildBattleCtrl.Instance = nil
	GlobalEventSystem:UnBind(self.main_ui_open)
	if self.remind_boss then
		GlobalTimerQuest:CancelQuest(self.remind_boss)
		self.remind_boss = nil
	end
	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
end

function KuafuGuildBattleCtrl:RemindBoss()
	local is_remind_time,time_index = self.data:IsInRemindTime()
	local open_level = OpenFunData.Instance:GetKuaFuBattleOpenLevel()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if is_remind_time and time_index ~= self.time_index and role_level >= open_level and self.remind_timestamp - TimeCtrl.Instance:GetServerTime() <= 0 then
		local ok_call_back = function()
			local born_x = 0
			local born_y = 0
			local scene_id = Scene.Instance:GetSceneId()
			if self.data:CheckOpen() and not self.data:IsLiuJieScene(scene_id) then
				ViewManager.Instance:Open(ViewName.KuaFuBattle,TabIndex.activity_kuafu_boss)
			end
			if self.data:CheckOpen() and self.data:IsLiuJieScene(scene_id) then
				local boss_list = self.data:GetBossList()
				local list = KuafuGuildBattleData.Instance:GetBossCfg()
				for k,v in pairs(list) do
					if v.boss_id == boss_list[1].boss_id then
						born_x = v.born_x
						born_y = v.born_y
					end
				end
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(1450, born_x, born_y, 10, 10)
			end
		end
		local close_call_back = function(cd)
			self.remind_timestamp = cd + 60 + TimeCtrl.Instance:GetServerTime()
		end
		TipsCtrl.Instance:ShowBossFocusTip(38000, BOSS_ENTER_TYPE.KUA_FU_BOSS, ok_call_back, close_call_back)
		self.time_index = time_index
	end
end

function KuafuGuildBattleCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.KF_GUILDBATTLE and status == ACTIVITY_STATUS.OPEN then
		self:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_INFO)
		self:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
		if status ~= InKuaFuLiuJieActivity and self.data:CheckOpen() then
			self:Open()
		end
	end
end
function KuafuGuildBattleCtrl:RegisterAllProtocols()

	self:RegisterProtocol(SCCrossGuildBattleInfo, "OnCrossGuildBattleInfo")
	self:RegisterProtocol(SCCrossGuildBattleNotifyInfo, "OnCrossGuildBattleNotifyInfo")
	self:RegisterProtocol(SCCrossGuildBattleSceneInfo, "OnCrossGuildBattleSceneInfo")
	self:RegisterProtocol(SCCrossGuildBattleGetRankInfoResp, "OnCrossGuildBattleRankInfoResp")
	self:RegisterProtocol(SCCrossGuildBattleTaskInfo, "SCCrossGuildBattleTaskInfo")
	self:RegisterProtocol(SCMonsterGeneraterList, "SCMonsterGeneraterList")
	self:RegisterProtocol(SCCrossGuildBattleBossInfo, "SCCrossGuildBattleBossInfo")
	self:RegisterProtocol(SCCrossGuildBattleDropLog, "SCCrossGuildBattleDropLog")
    self:RegisterProtocol(SCCrossGuildBattleGetMonsterInfoResp, "SCCrossGuildBattleGetMonsterInfoResp")
	self:RegisterProtocol(CSCrossGuildBattleOperate)
	self:RegisterProtocol(CSCrossGuildBattleGetRankInfoReq)

	self:RegisterProtocol(CSCrossTianjiangOperatorReq)
	self:RegisterProtocol(CSCrossShenwuOperatorReq)
	self:RegisterProtocol(SCCrossTianjiangBossInfo, "OnCrossTianjiangBossInfo")
	self:RegisterProtocol(SCCrossTianjiangBossStatusInfo, "OnCrossTianjiangBossStatusInfo")
	self:RegisterProtocol(SCCrossShenwuBossInfo, "OnCrossShenwuBossInfo")
	self:RegisterProtocol(SCCrossShenwuBossStatusInfo, "OnCrossShenwuBossStatusInfo")
	self:RegisterProtocol(SCCrossTianjiangBossAngryInfo, "OnTianjiangBossAngryInfo")
	self:RegisterProtocol(SCCrossShenwuBossSceneInfo, "OnCrossShenwuBossSceneInfo")

	self.main_ui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))

end


function KuafuGuildBattleCtrl:MainuiOpenCreate()
	self.server_id = GameVoManager.Instance:GetMainRoleVo().server_id
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_BOSS_INFO, 1450)
	if self.remind_boss then
		GlobalTimerQuest:CancelQuest(self.remind_boss)
		self.remind_boss = nil
	end
	self.remind_boss = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.RemindBoss, self), 1)
	RemindManager.Instance:Fire(RemindName.ShowKfBattlePreRemind)
end


function KuafuGuildBattleCtrl:Open()
	self:SendGuildBattleGetRankInfoReq()
	self.view:Open()
end

function KuafuGuildBattleCtrl:OpenScenePanle()
	self.scene_Panle:Open()
end

function KuafuGuildBattleCtrl:CloseScenePanle()
	self.scene_Panle:Close()
end


function KuafuGuildBattleCtrl:OpenRankPanle()
	if InKuaFuLiuJieActivity == ACTIVITY_STATUS.OPEN then
		self.rank_view:Open()
	else
		self.rank_view_2:Open()
	end
end

function KuafuGuildBattleCtrl:CloseRankPanle()
	if InKuaFuLiuJieActivity == ACTIVITY_STATUS.OPEN then
		self.rank_view_2:Close()
		self.rank_view:Close()
	else
		self.rank_view:Close()
		self.rank_view_2:Close()
	end
end

function KuafuGuildBattleCtrl:ActivityChange()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == nil then
		return
	end
	if KuafuGuildBattleData.Instance:IsLiuJieScene(scene_id) then
		self:CloseRankPanle()
		self:OpenRankPanle()
	end
end


function KuafuGuildBattleCtrl:OpenRecordPanle()
	self:SendGuildBattleGetRankInfoReq()
	self.record_view:Open()
end

function KuafuGuildBattleCtrl:OpenBattleRecordPanle()
	local local_scene_id = Scene.Instance:GetSceneId()
	self:OpenBattleRecordScene(local_scene_id)
	self.battle_record_view:Open()
end

function KuafuGuildBattleCtrl:CloseBattleRecordPanle()
	self.battle_record_view:Close()
end

function KuafuGuildBattleCtrl:SendGuildBattleGetRankInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossGuildBattleGetRankInfoReq)
	protocol:EncodeAndSend()
end

function KuafuGuildBattleCtrl:SendGuildBattleGetMonsterInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossGuildBattleGetMonsterInfoReq)
	protocol:EncodeAndSend()
end

function KuafuGuildBattleCtrl:SendKuaFuLiuJieLogInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossGuildBattleDropLog)
	protocol:EncodeAndSend()
end

function KuafuGuildBattleCtrl:OpenBattleRecordScene(scene_id)
	self:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_SCENE_RANK_INFO, scene_id)
end

function KuafuGuildBattleCtrl:SendCrossGuildBattleOperateReq(req_type, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossGuildBattleOperate)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol:EncodeAndSend()

end

function KuafuGuildBattleCtrl:OnCrossGuildBattleInfo(protocol)
	self.data:SetGuildBattleInfo(protocol)
	self.view:Flush()
	if self.view.show_info_panel then
		self.view.show_info_panel:Flush()
	end
	RemindManager.Instance:Fire(RemindName.ku_guild_battle)
end

function KuafuGuildBattleCtrl:Flush()
	self.view:Flush()
end

function KuafuGuildBattleCtrl:OnCrossGuildBattleNotifyInfo(protocol)
	self.data:SetGuildBattleNotifyInfo(protocol)
	self.rank_view:Flush()
	RemindManager.Instance:Fire(RemindName.ku_guild_battle)
end


function KuafuGuildBattleCtrl:OnCrossGuildBattleSceneInfo(protocol)
	-- self.data:SetGuildBattleSceneInfo(protocol)
	-- -- FuBenData.Instance:SetKuafuGuildBattleInfo(protocol)
	-- self.rank_view:Flush()
	-- self.scene_Panle:Flush()

	local scene_id = protocol.scene_id
	local now_scene_id = Scene.Instance:GetSceneId()
	-- self.data:SetGuildBattleSceneInfo(protocol)

	-- 刷新地图
	self.data:SetGuildBattleSceneMapInfo(protocol)
	if self.scene_Panle:IsOpen() then
		self.scene_Panle:Flush()
	end

	if scene_id == now_scene_id then
		self.data:SetGuildBattleSceneInfo(protocol)
		self.rank_view:Flush()
	end

	local rank_scene_id = self.battle_record_view:GetSceneId()
	if scene_id == rank_scene_id then
		self.data:SetGuildBattleSceneInfoIn(protocol)
		self.battle_record_view:Flush()
	end

	self.scene_Panle:Flush()

	for i=1, CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE do
		local monster_obj = Scene.Instance:GetMonsterList()[protocol.flag_list[i].monster_id]
		if nil ~= monster_obj then
			monster_obj:ReloadUIName()
		end
	end
end


function KuafuGuildBattleCtrl:OnCrossGuildBattleRankInfoResp(protocol)
	self.info_type = protocol.info_type
	self.data:SetGuildBattleRankInfoResp(protocol)
	self.record_view:Flush()
	if self.info_type == 1 then
		self:CloseBattleRecordPanle()
		self:OpenRecordPanle()
	end
end

function KuafuGuildBattleCtrl:CheckKfGuildRemind(remind_id)
	local num = self.data:GetKfRewardNum()
	local guild_info = self.data:GetGuildBattleInfo()
	if num > 0 then
		return 1
	end
	for i,v in ipairs(guild_info.kf_battle_list) do
		if self.data:GetIsGuildOwn(v.index) and self.data:GetGuildRewardFlag(v.index) then
			return 1
		end
	end
	return 0
end

function KuafuGuildBattleCtrl:SCCrossGuildBattleTaskInfo(protocol)
	self.data:SetGuildbattleTaskInfo(protocol)
	if self.rank_view_2 then
		self.rank_view_2:Flush()
	end
	self.view:Flush()
	self.task_record_view:Flush()
	RemindManager.Instance:Fire(RemindName.ShowKfBattleRemind)
	-- MainUICtrl.Instance:FlushView("show_kf_battle_remind", {[1] = KuafuGuildBattleData.Instance:HasGuildBattleTask()})
end

function KuafuGuildBattleCtrl:SCCrossGuildBattleGetMonsterInfoResp(protocol)
	self.data:SetCrossGuildBattleMonsterInfo(protocol)
	self.view:FlushBossInfoView()
end

function KuafuGuildBattleCtrl:SCMonsterGeneraterList(protocol)
	self.data:SetMonsterData(protocol)
	MainUICtrl.Instance:FlushView("change_monster_list")
end

function KuafuGuildBattleCtrl:CSReqMonsterGeneraterList(scene_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSReqMonsterGeneraterList)
	send_protocol.scene_id = scene_id or Scene.Instance:GetSceneId()
	send_protocol:EncodeAndSend()
end

function KuafuGuildBattleCtrl:OpenRewardTip(items, show_gray, ok_callback, show_button, title_id, top_title_id, act_type)
	self.kuafu_liujie_tips:SetData(items, show_gray, ok_callback, show_button, title_id, top_title_id, act_type)
	self.kuafu_liujie_tips:Open()
end

function KuafuGuildBattleCtrl:FlushRewardTip()
	if self.kuafu_liujie_tips:IsOpen() then
		self.kuafu_liujie_tips:Flush()
	end
end

function KuafuGuildBattleCtrl:SCCrossGuildBattleBossInfo(protocol)
	self.data:SetBossInfo(protocol)
	if self.rank_view_2 then
		self.rank_view_2:Flush()
	end
	if self.view.boss_info_panel then
		self.view.boss_info_panel:Flush()
	end
end

function KuafuGuildBattleCtrl:SCCrossGuildBattleDropLog(protocol)
	self.data:SendKuaFuLiuJieLog(protocol)
	ViewManager.Instance:Open(ViewName.TipsLiuJieLogView)
end

function KuafuGuildBattleCtrl:GetIsFirstOpenPreView()
	if self.pre_view then
		return self.pre_view.is_first_open
	end
	return 0
end

function KuafuGuildBattleCtrl:SendCrossTianjiangOperatorReq(opera_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossTianjiangOperatorReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end

function KuafuGuildBattleCtrl:SendCrossShenWuOperatorReq(opera_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossShenwuOperatorReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end

--跨服天将boss信息
function KuafuGuildBattleCtrl:OnCrossTianjiangBossInfo(protocol)
	self.data:SetTianJiangBossEnterInfo(protocol.enter_info)
	self.view:Flush("tj_boss")
	RemindManager.Instance:Fire(RemindName.TianjiangRemind)
end

--跨服天将boss状态信息
function KuafuGuildBattleCtrl:OnCrossTianjiangBossStatusInfo(protocol)
	local monster_id, is_flush = self.data:IsTianJiangBossFlush(protocol)
	self.data:SetTianjiangBossStatusInfo(protocol)
	self.view:Flush("tj_boss")
	self.kuafu_boss_tj_view:Flush()

	local callback = function()
		ViewManager.Instance:Open(ViewName.KuaFuBattle, TabIndex.activity_tj_boss)
	end

	if is_flush then
		BossCtrl.Instance:SetOtherBossTips(monster_id, callback, nil, BOSS_ENTER_TYPE.CROSS_TIANJIANG_BOSS)
	end
end

function KuafuGuildBattleCtrl:OnTianjiangBossAngryInfo(protocol)
	self.data:SetTianjiangBossAngryInfo(protocol)
	self.view:Flush("tj_boss")
	self.kuafu_boss_tj_view:Flush()
end
--跨服神武boss信息
function KuafuGuildBattleCtrl:OnCrossShenwuBossInfo(protocol)
	self.data:SetShenWuBosswearyInfo(protocol.weary_val_info)
	self.view:Flush("sw_boss")
	RemindManager.Instance:Fire(RemindName.ShenwuRemind)
end

function KuafuGuildBattleCtrl:OnCrossShenwuBossStatusInfo(protocol)
	self.data:SetShenWuBossStatusInfo(protocol)
	self.view:Flush("sw_boss")
	self.kuafu_boss_sw_view:Flush()
end

function KuafuGuildBattleCtrl:OnCrossShenwuBossSceneInfo(protocol)
	self.data:SetShenWuBossEndTime(protocol.act_end_timestamp)
	self.kuafu_boss_sw_view:Flush("exit_time")
end

function KuafuGuildBattleCtrl:FoucsSwBoss(protocol)
	local weary_info = self.data:GetShenWuBosswearyInfo()
	local other_cfg = self.data:GetShenWuBossOther()
	if weary_info and other_cfg and weary_info.weary_val_limit < other_cfg.weary_val_limit then
		local callback = function()
			ViewManager.Instance:Open(ViewName.KuaFuBattle, TabIndex.activity_sw_boss)
		end
		BossCtrl.Instance:SetOtherBossTips(protocol.monster_id, callback, nil, BOSS_ENTER_TYPE.CROSS_SHENWU_BOSS)
	end
end

