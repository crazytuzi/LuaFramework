require("game/kuafu_liujie_battle/kuafu_liujie_data")
require("game/kuafu_liujie_battle/kuafu_liujie_view")
require("game/kuafu_liujie_battle/kuafu_liujie_scene_view")
require("game/kuafu_liujie_battle/kuafu_liujie_task_view")
require("game/kuafu_liujie_battle/kuafu_liujie_record_view")
require("game/kuafu_liujie_battle/kuafu_liujie_task_view_2")
require("game/kuafu_liujie_battle/kuafu_task_record_view")
require("game/kuafu_liujie_battle/kuafu_liujie_tips_reward_view")
require("game/kuafu_liujie_battle/kuafu_liujie_pre_view")


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
	self.kuafu_liujie_tips = KfLiujieRewardTip.New(ViewName.KuafuLiujieRewardTip)
	self.pre_view = KuafuLiujiePreView.New(ViewName.KuaFuLiuJiePre)
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:RegisterAllProtocols()

	
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
	if self.record_view then
		self.record_view:DeleteMe()
		self.record_view = nil
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
	if is_remind_time and time_index ~= self.time_index then
		TipsCtrl.Instance:OpenFocusBossTip(50233,function ()
			local born_x = 0
			local born_y = 0
			local scene_id = Scene.Instance:GetSceneId()
			if self.data:CheckOpen() and not self.data:IsLiuJieScene(scene_id) then
				ViewManager.Instance:Open(ViewName.KuaFuBattle,TabIndex.liujie_bossinfo)
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
				-- local map_info = KuafuGuildBattleData.Instance:GetMapInfo(self.index - 1)
				-- if nil ~= map_info then
				-- 	GuajiCtrl.Instance:StopGuaji()
				-- 	GuajiCtrl.Instance:ClearAllOperate()
				-- 	MoveCache.end_type = MoveEndType.Auto
				-- 	GuajiCtrl.Instance:MoveToScenePos(map_info.scene_id, map_info.relive_pos_x, map_info.relive_pos_y)
				-- end
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(1450, born_x, born_y, 10, 10)
			end
		end,false,false,false,true)
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
	-- self:RegisterProtocol(SCMonsterGeneraterList, "SCMonsterGeneraterList")
	self:RegisterProtocol(SCCrossGuildBattleBossInfo, "SCCrossGuildBattleBossInfo")

	self:RegisterProtocol(CSCrossGuildBattleOperate)
	self:RegisterProtocol(CSCrossGuildBattleGetRankInfoReq)
	self.main_ui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))

end


function KuafuGuildBattleCtrl:MainuiOpenCreate()
	self.server_id = GameVoManager.Instance:GetMainRoleVo().server_id
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
	-- if self.remind_boss then
	-- 	GlobalTimerQuest:CancelQuest(self.remind_boss)
	-- 	self.remind_boss = nil
	-- end
	-- self.remind_boss = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.RemindBoss, self), 1)
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
		self.rank_view_2:IsSelectBossToggle(KuafuGuildBattleData.Instance:GetSelectBoss())
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

function KuafuGuildBattleCtrl:SendGuildBattleGetRankInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossGuildBattleGetRankInfoReq)
	protocol:EncodeAndSend()
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
	self.data:SetGuildBattleSceneInfo(protocol)
	-- FuBenData.Instance:SetKuafuGuildBattleInfo(protocol)
	self.rank_view:Flush()
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
	if self.info_type == 1 and Scene.Instance:GetSceneType() == SceneType.CrossGuildBattle then
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
	RemindManager.Instance:Fire(RemindName.ShowKfBattleRemind)
	-- MainUICtrl.Instance:FlushView("show_kf_battle_remind", {[1] = KuafuGuildBattleData.Instance:HasGuildBattleTask()})

	if LianFuDailyCtrl.Instance then
		LianFuDailyCtrl.Instance:FlushTaskList()
	end
end

function KuafuGuildBattleCtrl:SCMonsterGeneraterList(protocol)
	-- print_error("SCMonsterGeneraterList")
end

function KuafuGuildBattleCtrl:CSReqMonsterGeneraterList(scene_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSReqMonsterGeneraterList)
	send_protocol.scene_id = scene_id or Scene.Instance:GetSceneId()
	send_protocol:EncodeAndSend()
end

function KuafuGuildBattleCtrl:OpenRewardTip(items,show_gray,ok_callback,show_button, title_id)
	self.kuafu_liujie_tips:SetData(items,show_gray,ok_callback,show_button, title_id)
	self.kuafu_liujie_tips:Open()
end

function KuafuGuildBattleCtrl:SCCrossGuildBattleBossInfo(protocol)
	self.data:SetBossInfo(protocol)
	if self.rank_view_2 then
		self.rank_view_2:Flush()
	end
	if self.view.boss_info_panel then
		self.view.boss_info_panel:Flush()
	end
	self:RemindBoss()

	if LianFuDailyCtrl.Instance then
		LianFuDailyCtrl.Instance:FlushBossList()
	end
end

function KuafuGuildBattleCtrl:GetIsFirstOpenPreView()
	if self.pre_view then
		return self.pre_view.is_first_open
	end
	return 0
end