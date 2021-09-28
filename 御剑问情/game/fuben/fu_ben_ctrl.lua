require("game/fuben/fu_ben_view")
require("game/fuben/fu_ben_phase_view")
-- require("game/fuben/fu_ben_exp_view")
require("game/fuben/fu_ben_vip_view")
require("game/fuben/fu_ben_tower_view")
require("game/fuben/fu_ben_story_view")
require("game/fuben/fu_ben_data")
require("game/fuben/fu_ben_victory_finish_view")
require("game/fuben/fu_ben_fail_finish_view")
require("game/fuben/fu_ben_info_phase_view")
require("game/fuben/fu_ben_info_guard_view")
require("game/fuben/fu_ben_info_exp_view")
require("game/fuben/fu_ben_info_yaoshou_view")
-- require("game/fuben/fu_ben_info_story_view")
require("game/fuben/fu_ben_info_tower_view")
require("game/fuben/fu_ben_info_vip_view")
require("game/fuben/fu_ben_info_quality_view")
require("game/fuben/fu_ben_info_push_view")
require("game/fuben/fu_ben_info_team_special_view")
require("game/fuben/fu_ben_icon_view")
require("game/fuben/fu_ben_wing_story_view")
require("game/fuben/fu_ben_many_fb_view")
require("game/fuben/fu_ben_quality_view")
require("game/fuben/fu_ben_guard_view")
require("game/fuben/fu_ben_finish_star_view")
require("game/fuben/fu_ben_push_common_view")
require("game/fuben/fu_ben_push_special_view")
require("game/fuben/tower_mojie_view")
require("game/tips/tips_exp_inspire_fuben_view")


FuBenCtrl = FuBenCtrl or BaseClass(BaseController)

local FLUSH_REDPOINT_CD = 600

function FuBenCtrl:__init()
	if FuBenCtrl.Instance ~= nil then
		print_error("[FuBenCtrl] Attemp to create a singleton twice !")
		return
	end
	FuBenCtrl.Instance = self
	self.fu_ben_view = FuBenView.New(ViewName.FuBen)
	self.fu_ben_data = FuBenData.New()
	self.fu_ben_victory_view = FuBenVictoryFinishView.New(ViewName.FBVictoryFinishView)
	self.fu_ben_star_view = FuBenFinishStarView.New(ViewName.FBFinishStarView)
	self.fu_ben_fail_view = FuBenFailFinishView.New(ViewName.FBFailFinishView)
	self.phase_info_view = FuBenInfoPhaseView.New(ViewName.FuBenPhaseInfoView)
	self.guard_info_view = FuBenInfoGuardView.New(ViewName.FuBenGuardInfoView)
	self.exp_info_view = FuBenInfoExpView.New(ViewName.FuBenExpInfoView)
	self.yaoshou_info_view = FuBenInfoYaoShouView.New(ViewName.FuBenInfoYaoShouView)

	-- self.story_info_view = FuBenInfoStoryView.New(ViewName.FuBenStoryInfoView)
	self.tower_info_view = FuBenInfoTowerView.New(ViewName.FuBenTowerInfoView)
	-- self.vip_info_view = FuBenInfoVipView.New(ViewName.FuBenVipInfoView)
	self.quality_info_view = FuBenInfoQualityView.New(ViewName.FuBenQualityInfoView)
	self.push_info_view = FuBenInfoPushView.New(ViewName.FuBenPushInfoView)
	self.team_special_info_view = FuBenInfoTeamSpecialView.New(ViewName.FuBenTeamSpecialInfoView)
	self.fu_ben_icon_view = FbIconView.New(ViewName.FbIconView)
	self.fu_ben_wing_story_view = FuBenWingStoryView.New(ViewName.FBWingStoryView)
	-- self.many_fb_view = ManyFbView.New()
	self.tips_exp_inspire_fuben_view = TipsExpInSprieFuBenView.New()
	self.tower_mojie_view = TowerMojieView.New(ViewName.TowerMoJieView)

	self.scene_load_complete = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.SceneLoadComplete, self))
	self.fuben_quit = GlobalEventSystem:Bind(OtherEventType.FUBEN_QUIT, BindTool.Bind(self.FubenQuit, self))
	self:RegisterAllProtocols()

	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self.time_quest = {}

	self:CreateFlushTeam()
end

function FuBenCtrl:__delete()
	if self.fu_ben_view ~= nil then
		self.fu_ben_view:DeleteMe()
		self.fu_ben_view = nil
	end

	if self.fu_ben_data ~= nil then
		self.fu_ben_data:DeleteMe()
		self.fu_ben_data = nil
	end

	if self.push_info_view ~= nil then
		self.push_info_view:DeleteMe()
		self.push_info_view = nil
	end

	if self.tips_exp_inspire_fuben_view ~= nil then
		self.tips_exp_inspire_fuben_view:DeleteMe()
		self.tips_exp_inspire_fuben_view = nil
	end

	if self.tower_mojie_view ~= nil then
		self.tower_mojie_view:DeleteMe()
		self.tower_mojie_view = nil
	end

	if self.fu_ben_star_view ~= nil then
		self.fu_ben_star_view:DeleteMe()
		self.fu_ben_star_view = nil
	end

	if self.quality_info_view ~= nil then
		self.quality_info_view:DeleteMe()
		self.quality_info_view = nil
	end

	if nil ~= self.many_fb_view then
		self.many_fb_view:DeleteMe()
		self.many_fb_view = nil
	end

	if nil ~= self.team_special_info_view then
		self.team_special_info_view:DeleteMe()
		self.team_special_info_view = nil
	end

	-- if self.story_info_view ~= nil then
	-- 	self.story_info_view:DeleteMe()
	-- 	self.story_info_view = nil
	-- end

	if self.phase_info_view ~= nil then
		self.phase_info_view:DeleteMe()
		self.phase_info_view = nil
	end

	if self.guard_info_view ~= nil then
		self.guard_info_view:DeleteMe()
		self.guard_info_view = nil
	end

	if self.tower_info_view ~= nil then
		self.tower_info_view:DeleteMe()
		self.tower_info_view = nil
	end

	if self.exp_info_view ~= nil then
		self.exp_info_view:DeleteMe()
		self.exp_info_view = nil
	end

	if self.vip_info_view ~= nil then
		self.vip_info_view:DeleteMe()
		self.vip_info_view = nil
	end

	if self.fu_ben_fail_view ~= nil then
		self.fu_ben_fail_view:DeleteMe()
		self.fu_ben_fail_view = nil
	end

	if self.fu_ben_victory_view ~= nil then
		self.fu_ben_victory_view:DeleteMe()
		self.fu_ben_victory_view = nil
	end

	if self.fu_ben_icon_view ~= nil then
		self.fu_ben_icon_view:DeleteMe()
		self.fu_ben_icon_view = nil
	end

	if self.fu_ben_wing_story_view ~= nil then
		self.fu_ben_wing_story_view:DeleteMe()
		self.fu_ben_wing_story_view = nil
	end

	if self.yaoshou_info_view ~= nil then
		self.yaoshou_info_view:DeleteMe()
		self.yaoshou_info_view = nil
	end

	if self.scene_load_complete ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_complete)
		self.scene_load_complete = nil
	end

	if self.fuben_quit ~= nil then
		GlobalEventSystem:UnBind(self.fuben_quit)
		self.fuben_quit = nil
	end

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	for k, v in pairs(self.time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.time_quest = {}

	if self.delay_flush_timer then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end

	FuBenCtrl.Instance = nil
end

function FuBenCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCPhaseFBInfo, "GetPhaseFBInfoReq")
	self:RegisterProtocol(SCFBSceneLogicInfo, "GetFBSceneLogicInfoReq")
	self:RegisterProtocol(SCDailyFBRoleInfo, "OnSCDailyFBRoleInfo")
	self:RegisterProtocol(SCStoryFBInfo, "GetStoryFBInfoReq")
	self:RegisterProtocol(SCVipFbAllInfo, "GetVipFBInfoReq")
	self:RegisterProtocol(SCPataFbAllInfo, "GetTowerFBInfoReq")
	self:RegisterProtocol(SCFunOpenWingInfo, "GetWingStoryInfoReq")
	self:RegisterProtocol(SCFbPickItemInfo, "OnFbPickItemInfoReq")
	self:RegisterProtocol(SCExpFbInfo, "OnExpFbInfo")
	self:RegisterProtocol(SCTeamEquipFbInfo, "OnTeamEquipFbInfo")
	self:RegisterProtocol(SCTeamEquipFbDropCountInfo, "OnTeamEquipFbDropCountInfo")
	self:RegisterProtocol(CSPhaseFBInfoReq)
	self:RegisterProtocol(SCTeamFbRoomList, "OnTeamFbRoomList")
	self:RegisterProtocol(SCTeamFbRoomEnterAffirm, "OnTeamFbRoomEnterAffirm")
	self:RegisterProtocol(CSChallengeFBOP)
	self:RegisterProtocol(SCChallengeFBInfo, "OnChallengeFBInfo")
	self:RegisterProtocol(SCChallengePassLevel, "OnChallengePassLevel")
	self:RegisterProtocol(SCChallengeLayerInfo, "OnChallengeLayerInfo")

	self:RegisterProtocol(SCTowerDefendRoleInfo, "OnTowerDefendRoleInfo")
	self:RegisterProtocol(SCAutoFBRewardDetail2, "OnAutoFBRewardDetail2")
	self:RegisterProtocol(SCTowerDefendWarning, "OnTowerDefendWarning")
	self:RegisterProtocol(SCTowerDefendInfo, "OnTowerDefendInfo")
	self:RegisterProtocol(SCFBDropInfo, "OnFBDropInfo")
	self:RegisterProtocol(SCTowerDefendResult, "OnTowerDefendResult")
	self:RegisterProtocol(SCFBFinish, "OnFBFinish")

	-- self:RegisterProtocol(CSTuituFbOperaReq)
	-- self:RegisterProtocol(SCTuituFbInfo, "OnTuituFbInfo")
	-- self:RegisterProtocol(SCTuituFbResultInfo, "OnTuituFbResultInfo")
	-- self:RegisterProtocol(SCTuituFbSingleInfo, "OnTuituFbSingleInfo")
	-- self:RegisterProtocol(SCTuituFbFetchResultInfo, "OnTuituFbFetchResultInfo")

	self:RegisterProtocol(CSEquipFBBuy)
	self:RegisterProtocol(CSEquipFBGetInfo)
	self:RegisterProtocol(CSEquipFBJumpReq)
	self:RegisterProtocol(SCEquipFBResult, "OnEquipFBResult")
	self:RegisterProtocol(SCEquipFBInfo, "OnEquipFBInfo")
	self:RegisterProtocol(SCEquipFBTotalPassExp, "OnEquipFBTotalPassExp")

	self:RegisterProtocol(SCYsjtTeamFbSceneLogicInfo, "OnYsjtTeamFbSceneLogicInfo")
end


function FuBenCtrl:GetFuBenView()
	return self.fu_ben_view
end

function FuBenCtrl:GetFuBenIconView()
	return self.fu_ben_icon_view
end

function FuBenCtrl:FlushFbViewByParam(...)
	self.fu_ben_view:Flush(...)
end

function FuBenCtrl:ChangeLeader()
	if self.fu_ben_view then
		self.fu_ben_view:ChangeLeader()
	end
end

-- 阶段副本信息请求
function FuBenCtrl:SendGetPhaseFBInfoReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSPhaseFBInfoReq)
	send_protocol:EncodeAndSend()
end

-- 阶段副本信息返回
function FuBenCtrl:GetPhaseFBInfoReq(protocol)
	self.fu_ben_data:SetPhaseFBInfo(protocol.info_list)
	self.fu_ben_view:Flush("phase")
	self.phase_info_view:Flush()
	self:FlushMainUIRedPoint()
end

-- 经验副本信息请求
function FuBenCtrl:SendGetExpFBInfoReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDailyFBGetRoleInfo)
	send_protocol:EncodeAndSend()
end

-- 经验副本信息返回
function FuBenCtrl:OnSCDailyFBRoleInfo(protocol)
	-- self.fu_ben_data:SetSCDailyFBRoleInfo(protocol)
	self.fu_ben_data:OnSCDailyFBRoleInfo(protocol)
	self.fu_ben_view:Flush("exp")
end

-- 经验副本首通奖励领取
function FuBenCtrl:SendGetExpFBFirstRewardReq(fetch_reward_wave)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSExpFBRetchFirstRewardReq)
	send_protocol.fetch_reward_wave = fetch_reward_wave or 0
	send_protocol:EncodeAndSend()
end

-- 剧情副本信息请求
function FuBenCtrl:SendGetStoryFBGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSStoryFBGetInfo)
	send_protocol:EncodeAndSend()
end

-- 剧情副本信息返回
function FuBenCtrl:GetStoryFBInfoReq(protocol)
	self.fu_ben_data:SetStoryFBInfo(protocol.info_list)
	self.fu_ben_view:Flush("story")
	self:FlushMainUIRedPoint()
end

-- vip副本信息请求
function FuBenCtrl:SendGetVipFBGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSVipFbAllInfoReq)
	send_protocol:EncodeAndSend()
end

-- vip副本信息返回
function FuBenCtrl:GetVipFBInfoReq(protocol)
	self.fu_ben_data:SetVipFBInfo(protocol)
	self.fu_ben_view:Flush("vip")
	-- if ViewManager.Instance:IsOpen(ViewName.FuBenVipInfoView) then
	-- 	self.vip_info_view:Flush()
	-- end
	self:FlushMainUIRedPoint()
end

-- 爬塔副本信息请求
function FuBenCtrl:SendGetTowerFBGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSPataFbAllInfo)
	send_protocol:EncodeAndSend()
end

-- 爬塔副本信息返回
function FuBenCtrl:GetTowerFBInfoReq(protocol)
	self.fu_ben_data:SetTowerFBInfo(protocol)
	self.fu_ben_view:Flush("tower")
	if ViewManager.Instance:IsOpen(ViewName.FuBenTowerInfoView) then
		self.tower_info_view:Flush()
	end
	self:FlushMainUIRedPoint()
	RemindManager.Instance:Fire(RemindName.BeStrength)
end

function FuBenCtrl:GetWingStoryInfoReq(protocol)
	-- do delay
end

-- 副本结算物品奖励信息
function FuBenCtrl:OnFbPickItemInfoReq(protocol)
	self.fu_ben_data:SetFbPickItemInfo(protocol.item_list)
end

-- 经验副本信息
function FuBenCtrl:OnExpFbInfo(protocol)
	self.fu_ben_data:SetExpFbInfo(protocol)
	self.fu_ben_data:SetFBSceneLogicTime(protocol.time_out_stamp)
	self.exp_info_view:Flush()
	self.fu_ben_view:Flush("exp")
	TipsCtrl.Instance:GetInSprieFuBenView():Flush()
	TipsCtrl.Instance:GetExpFubenView():Flush()
	if ViewManager.Instance:IsOpen(ViewName.FuBenExpInfoView) then
		self.exp_info_view:Flush()
	end
	self.fu_ben_icon_view:Flush()
	RemindManager.Instance:Fire(RemindName.TeamFbFull)
end

-- 组队装备副本信息
function FuBenCtrl:OnTeamEquipFbInfo(protocol)
	self.fu_ben_data:SetManyFbInfo(protocol)
	-- if self.many_fb_view and self.many_fb_view:IsOpen() then
	-- 	self.many_fb_view:Flush()
	-- end
end

-- 组队装备副本掉落次数信息
function FuBenCtrl:OnTeamEquipFbDropCountInfo(protocol)
	self.fu_ben_data:SetTeamEquipFbDropCountInfo(protocol)
	if self.fu_ben_view and self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Flush("manypeople")
	end
end

-- 购买经验副本次数
function FuBenCtrl:SendAutoFBReq(fb_type, param_1, param_2, param_3, param_4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSAutoFB)
	send_protocol.fb_type = fb_type
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol.param_4 = param_4 or 0
	send_protocol:EncodeAndSend()
end

-- 进入副本时，返回信息
function FuBenCtrl:GetFBSceneLogicInfoReq(protocol)
	self.fu_ben_data:SetFBSceneLogicInfo(protocol)
	self:FlushView(Scene.Instance:GetSceneType(), protocol)

	GlobalEventSystem:Fire(FuBenEventType.FUBEN_INFO_CHANGE, protocol.scene_type)

	if protocol.scene_type == SceneType.SuoYaoTowerFB then
		LianhunCtrl.Instance:OnResultInfo(protocol)
	end
end

-- 请求购买组队副本次数
function FuBenCtrl:SendTeamEquipFbBuyDropCountReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTeamEquipFbBuyDropCount)
	send_protocol:EncodeAndSend()
end

-- 请求进入副本
function FuBenCtrl:SendEnterFBReq(fb_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSEnterFB)
	send_protocol.fb_type = fb_type 	 --日常副本类型：1
	send_protocol.param_1 = param_1 or 0 --经验副本类型：0
	send_protocol.param_2 = param_2 or 0 --组队1，个人0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function FuBenCtrl:SendTeamFbRoomYaoShouReq(param1, param2, param3, param4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCreateTeam)
	-- send_protocol.operate_type = operate_type or 0
	send_protocol.must_check = param1 or 0
	send_protocol.assign_mode = param2 or 1
	send_protocol.member_can_invite = param3 or 0
	send_protocol.team_type = param4 or 0
	send_protocol:EncodeAndSend()
end

--经验副本购买鼓舞
function FuBenCtrl:SendExpFbPayGuwu()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSExpFbPayGuwu)
	send_protocol:EncodeAndSend()
end

-- 请求进入副本下一关
function FuBenCtrl:SendEnterNextFBReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFBReqNextLevel)
	send_protocol:EncodeAndSend()
end

-- 离开副本
function FuBenCtrl:SendExitFBReq()
	if IS_ON_CROSSSERVER then
		-- 跨服修罗塔
		if Scene.Instance:GetSceneType() == SceneType.Kf_XiuLuoTower or Scene.Instance:GetSceneType() == SceneType.CrossGuild
			or Scene.Instance:GetSceneType() == SceneType.CrossTianJiang_Boss or Scene.Instance:GetSceneType() == SceneType.CrossShenWu_Boss then
			CrossServerCtrl.Instance:GoBack()
			return
		end
	end

	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLeaveFB)
	send_protocol:EncodeAndSend()
end

function FuBenCtrl:SendExitHchzReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLeaveHchz)
	send_protocol:EncodeAndSend()
end

function FuBenCtrl:FlushView(param, info)
	if param == SceneType.ExpFb then
		self.exp_info_view:Flush()
	elseif param == SceneType.PataFB then
		self.tower_info_view:Flush()
	elseif param == SceneType.PhaseFb then
		self.phase_info_view:Flush()
	elseif param == SceneType.RuneTower then
		ViewManager.Instance:FlushView(ViewName.RuneTowerFbInfoView)
	elseif param == SceneType.DailyTaskFb then
		ViewManager.Instance:FlushView(ViewName.DailyTaskFb)
		if info.is_pass == 1 then
			local data = {}
			local reward_cfg = TaskData.Instance:GetTaskReward(TASK_TYPE.RI)
			if reward_cfg then
				data = {[1] = {item_id = FuBenDataExpItemId.ItemId, num = reward_cfg.exp}}
			end
			local call_back = function ()
			local exp = CommonDataManager.ConverNum(reward_cfg.exp)
				local data_list= {string.format(Language.FB.GetExp, exp), {item_id = ResPath.CurrencyToIconId.exp or 0,num = 0,is_bind = 0}}
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "expfinish", {data = data_list, leave_time = 5})
			end
			TimeScaleService.StartTimeScale(call_back)
		end
	elseif param == SceneType.TeamSpecialFb then
		ViewManager.Instance:FlushView(ViewName.FuBenTeamSpecialInfoView)
	elseif param == SceneType.SCENE_TYPE_TUITU_FB then
		local data = FuBenData.Instance:GetFBSceneLogicInfo()
		SlaughterDevilCtrl.Instance:SetFBSceneLogicInfo(data)
	end
	self.fu_ben_icon_view:Flush()
end

function FuBenCtrl:SceneLoadComplete(scene_id)
	if nil == self.fu_ben_data or self.fu_ben_data.phase_info_list or nil == next(self.fu_ben_data.phase_info_list)
		or nil == self.fu_ben_data.expfb_pass_wave or nil == next(self.fu_ben_data.expfb_pass_wave) or
		nil ==self.fu_ben_data.story_info_list or nil == next(self.fu_ben_data.story_info_list) or
		nil == self.fu_ben_data.vip_info_list or nil == next(self.fu_ben_data.vip_info_list) or
		nil == self.fu_ben_data.tower_info_list or nil == next(self.fu_ben_data.tower_info_list) then
		self:SendGetPhaseFBInfoReq()
		self:SendGetExpFBInfoReq()
		self:SendGetStoryFBGetInfo()
		self:SendGetVipFBGetInfo()
		self:SendGetTowerFBGetInfo()
		self:ReqChallengeFbInfo()
		self:SendTuituFbOperaReq()
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local name_list_t = Split(fb_scene_cfg.show_fbicon, "#")
	if #name_list_t > 0
		or BossData.IsWorldBossScene(scene_id)
		or BossData.IsDabaoBossScene(scene_id)
		or BossData.IsFamilyBossScene(scene_id)
		or BossData.IsMikuBossScene(scene_id)
		or BossData.IsActiveBossScene(scene_id)
		or BossData.IsSecretBossScene(scene_id)
		or AncientRelicsData.IsAncientRelics(scene_id)
		or RelicData.Instance:IsRelicScene(scene_id)
		or ActivityData.Instance:IsShuShanScene(scene_id)
		or JingHuaHuSongData.Instance:IsJingHuaScene(scene_id) then
		self.fu_ben_icon_view:Open()
	end
end

function FuBenCtrl:FubenQuit(scene_type)
	self.fu_ben_icon_view:Close()
	-- self.fu_ben_data:ClearFBSceneLogicInfo()
	self.fu_ben_data:ClearFBIconCache()
end

function FuBenCtrl:FlushFbView()
	self.fu_ben_view:Flush("phase")
	self.fu_ben_view:Flush("exp")
	self.fu_ben_view:Flush("story")
	self.fu_ben_view:Flush("vip")
	self.fu_ben_view:Flush("tower")
	self:FlushMainUIRedPoint()
end

function FuBenCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	-- if attr_name == "capability" then
	-- 	MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.FuBenSingle, self.fu_ben_data:IsShowFubenRedPoint())
	-- end
end

-- 设置经验副本、爬塔副本红点
function FuBenCtrl:SetRedPointCountDown(str_param)
	if not self.time_quest[str_param] then
		self.fu_ben_data:SetRedPointCd(str_param)
		self.time_quest[str_param] = GlobalTimerQuest:AddRunQuest(function()
			RemindManager.Instance:Fire(RemindName.FuBenSingle)
			-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.FuBenSingle, self.fu_ben_data:IsShowFubenRedPoint())
			if self.fu_ben_view:IsOpen() then
				self.fu_ben_view:FlushRedPoint()
			else
				self.fu_ben_view:Flush(str_param)
			end
			if self.time_quest[str_param] then
				GlobalTimerQuest:CancelQuest(self.time_quest[str_param])
				self.time_quest[str_param] = nil
			end
		end, FLUSH_REDPOINT_CD)
	end
end

function FuBenCtrl:FlushMainUIRedPoint()
	RemindManager.Instance:Fire(RemindName.FuBenSingle)
	-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.FuBenSingle, self.fu_ben_data:IsShowFubenRedPoint())
end

function FuBenCtrl:SetMonsterDiffTime(diff_time, index)
	self.fu_ben_icon_view:SetMonsterDiffTime(diff_time, index)
end

function FuBenCtrl:SetMonsterInfo(monster_id, index)
	self.fu_ben_icon_view:SetMonsterInfo(monster_id, index)
end

function FuBenCtrl:ShowMonsterHadFlush(enable, flush_text, index)
	self.fu_ben_icon_view:ShowMonsterHadFlush(enable, flush_text, index)
end

function FuBenCtrl:SetMonsterIconState(enable, index)
	self.fu_ben_icon_view:SetMonsterIconState(enable, index)
end

function FuBenCtrl:SetMonsterIconGray(enable, index)
	self.fu_ben_icon_view:SetMonsterIconGray(enable, index)
end

function FuBenCtrl:SetMonsterClickCallBack(call_back, index)
	self.fu_ben_icon_view:SetClickCallBack(call_back, index)
end

function FuBenCtrl:ClearMonsterClickCallBack()
	self.fu_ben_icon_view:ClearClickCallBack()
end

function FuBenCtrl:SetCountDownByTotalTime(time)
	self.fu_ben_icon_view:SetCountDownByTotalTime(time)
end

function FuBenCtrl:SetSkyMoneyTextState(value)
	self.fu_ben_icon_view:SetSkyMoneyTextState(value)
end

function FuBenCtrl:SetAutoBtnClickCallBack(call_back)
	self.fu_ben_icon_view:SetAutoBtnClickCallBack(call_back)
end

function FuBenCtrl:SetExitArrowState()
	self.fu_ben_icon_view:SetExitArrowState()
end

function FuBenCtrl:FlushFbIconView(...)
	self.fu_ben_icon_view:Flush(...)
end

function FuBenCtrl:SendMoneyTreeTime()
	self.fu_ben_icon_view:FlushMoneyTree()
end

function FuBenCtrl:CloseView()
	if self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Close()
	end
end

function FuBenCtrl:SetJingHuaHuSongNum()
	if self.fu_ben_icon_view then
		self.fu_ben_icon_view:SetJingHuaHuSongNum()
	end
end

-- 刷新多人副本
function FuBenCtrl:FlushManyPeopleView()
	if self.fu_ben_view and self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Flush("manypeople")
	end
end

-- 打开多人副本副本场景
function FuBenCtrl:OpenManyFbView()
	-- if self.many_fb_view then
	-- 	self.many_fb_view:Open()
	-- end
end

-- 关闭多人副本副本场景
function FuBenCtrl:CloseManyFbView()
	-- if self.many_fb_view then
	-- 	self.many_fb_view:Close()
	-- end
end

-- 组队副本房间请求操作
function FuBenCtrl:SendTeamFbRoomOperateReq(operate_type, param1, param2, param3, param4, param5)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTeamFbRoomOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol.param5 = param5 or 0
	send_protocol:EncodeAndSend()
end

-- 副本房间列表
function FuBenCtrl:OnTeamFbRoomList(protocol)
	self.fu_ben_data:SetTeamFbRoomList(protocol)
	if self.fu_ben_view and self.fu_ben_view:IsOpen() then
		-- self.fu_ben_view:Flush("manypeople")
		if self.fu_ben_view.cur_toggle == 2 then
			self.fu_ben_view:Flush("exp")
		elseif self.fu_ben_view.cur_toggle == 11 then
			self.fu_ben_view:Flush("team")
		end
	end
end

-- 副本房间进入确认通知
function FuBenCtrl:OnTeamFbRoomEnterAffirm(protocol)
	self.fu_ben_data:SetTeamFbRoomEnterAffirm(protocol)
	TipsCtrl.Instance:ShowEnterFbView()
end

-- 品质本信息下发
function FuBenCtrl:OnChallengeFBInfo(protocol)
	self.fu_ben_data:SetChallengeFbInfo(protocol)
	self.fu_ben_view:Flush("quality")
end

-- 品质副本内信息
function FuBenCtrl:OnChallengePassLevel(protocol)
	self.fu_ben_data:SetChallengeInfoList(protocol)
	if ViewManager.Instance:IsOpen(ViewName.FuBenQualityInfoView) then
		self.quality_info_view:Flush("star_info")
	end
end

-- 品质每层协议下来
function FuBenCtrl:OnChallengeLayerInfo(protocol)
	self.fu_ben_data:SetPassLayerInfo(protocol)

	local quality_fb_is_pass = self.fu_ben_data:GetChallengeFBPassResult()
	if 1 == quality_fb_is_pass then
		Scene.Instance:CreateDoorList()
	else
		Scene.Instance:DeleteObjsByType(SceneObjType.Door)
	end

	if ViewManager.Instance:IsOpen(ViewName.FuBenQualityInfoView) then
		self.quality_info_view:Flush()
	end
	self.fu_ben_icon_view:Flush()
end


-- 品质本信息请求
function FuBenCtrl:SendChallengeFBReq(fb_type, fb_level)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFBOP)
	send_protocol.type = fb_type or 0
	send_protocol.level = fb_level or 0
	send_protocol:EncodeAndSend()
end

function FuBenCtrl:ReqChallengeFbInfo()
	self:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_SEND_INFO_REQ)
end

function FuBenCtrl:FlushGuildBossButton()
	if self.fu_ben_icon_view:IsOpen() then
		self.fu_ben_icon_view:ShowGuildBossButton()
	end
end

-----------------
--单人塔防
----
-------------
--个人塔防角色信息
function FuBenCtrl:OnTowerDefendRoleInfo(protocol)
	self.fu_ben_data:SetTowerDefendRoleInfo(protocol)
	self.fu_ben_view:Flush("tower_defend")
	self.guard_info_view:Flush()
end

--个人塔防奖励
function FuBenCtrl:OnAutoFBRewardDetail2(protocol)
	self.fu_ben_data:SetAutoFBRewardDetail2(protocol)
end

--个人塔防警告
function FuBenCtrl:OnTowerDefendWarning(protocol)
	local scene_type = Scene.Instance:GetSceneType()
	if protocol.warning_type == 1 then
		self.fu_ben_data:SetTowerIsWarning(true)
		if scene_type == SceneType.TeamTower then
			SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.TowerBeHurt2)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.TowerBeHurt)
		end
	else
		if scene_type == SceneType.TeamTower then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.TowerDefend.TowerHpTooLess2, protocol.percent .. "%"))
		else
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.TowerDefend.TowerHpTooLess, protocol.percent .. "%"))
		end
	end
end

--个人塔防信息
function FuBenCtrl:OnTowerDefendInfo(protocol)
	self.fu_ben_data:SetTowerDefendInfo(protocol)
	self.guard_info_view:Flush()
	local star_num = self.fu_ben_data:GetTowerStarByDeath(protocol.death_count)
	if protocol.is_finish == 1 then
		if protocol.is_pass == 1 then
			local call_back = function ()
				ViewManager.Instance:Open(ViewName.FBFinishStarView, nil, "tower_finish", {data = protocol.death_count, star = star_num})
			end
			TimeScaleService.StartTimeScale(call_back)
		else
			GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBFailFinishView)
			end, 2)
		end
	end
end

--个人塔防掉落
function FuBenCtrl:OnFBDropInfo(protocol)
	self.fu_ben_data:SetFBDropInfo(protocol)
end

--个人塔防结果
function FuBenCtrl:OnTowerDefendResult(protocol)
	if 1 == protocol.is_passed then
		ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "teamtower",
			{data = {is_passed = protocol.is_passed, clear_wave_count = protocol.clear_wave_count}, leave_time = 5})
	end
end

--个人塔防结束
function FuBenCtrl:OnFBFinish(protocol)

end

--个人塔防购买次数
function FuBenCtrl.SendTowerDefendBuyJoinTimes()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTowerDefendBuyJoinTimes)
	send_protocol:EncodeAndSend()
end

--个人塔防刷新下一波
function FuBenCtrl.SendTowerDefendNextWave()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTowerDefendNextWave)
	send_protocol:EncodeAndSend()
end


-- 推图总协议下来
function FuBenCtrl:OnTuituFbInfo(protocol)
	self.fu_ben_data:SetTuituFbInfo(protocol)
	self.fu_ben_view:Flush("push")
	self.fu_ben_view:Flush("push_special")
end

-- 推图通关协议
function FuBenCtrl:OnTuituFbResultInfo(protocol)
	-- self.fu_ben_data:SetTuituFbResultInfo(protocol)
	-- if ViewManager.Instance:IsOpen(ViewName.FuBenPushInfoView) then
	-- 	self.push_info_view:Flush()
	-- end
end

-- -- 推图信息变动
function FuBenCtrl:OnTuituFbSingleInfo(protocol)
	self.fu_ben_data:SetTuituFbSingleInfo(protocol)
	self.fu_ben_view:Flush("push")
	self.fu_ben_view:Flush("push_special")
end

-- 领取奖励返回
function FuBenCtrl:OnTuituFbFetchResultInfo(protocol)
	if protocol.is_success == 1 and protocol.fb_type == PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL then
		FuBenData.Instance:OnPushFbFetchShowStarRewardSucc(protocol)
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD)
	end
end


-- 妖兽祭坛信息返回
function FuBenCtrl:OnYsjtTeamFbSceneLogicInfo(protocol)
	FuBenData.Instance:SetYsjtTeamFbSceneLogicInfo(protocol)

	local is_finish = protocol.is_finish
	if is_finish == 1 then
		local str = string.format(Language.FB.KillBossText, protocol.pass_wave)
		ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "Ysjtfinish", {data = { str } })
	end

	if self.yaoshou_info_view:IsOpen()  then
		self.yaoshou_info_view:Flush()
		self.yaoshou_info_view:ChangeName()
	end
end

-- 推图本信息请求
function FuBenCtrl:SendTuituFbOperaReq(opera_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTuituFbOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function FuBenCtrl:ReturnIsGuWuFull()
	return self.tips_exp_inspire_fuben_view:IsGuWuFull()
end

function FuBenCtrl:CreateFlushTeam()
	if self.delay_flush_timer then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end

	if self.fu_ben_view == nil then
		return
	end
	self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(function()
		-- 随即名
	self.fu_ben_view:Flush("exp")
	self.fu_ben_view:Flush("team")
	self:CreateFlushTeam()
	end, 10)
end

----------------组队副本(须臾幻境)协议--------------
function FuBenCtrl:OnEquipFBResult(protocol)
	self.fu_ben_data:SetTeamSpecialResult(protocol)
	local team_special_is_passed = self.fu_ben_data:GetTeamSpecialIsPass()
	if team_special_is_passed and team_special_is_passed == 1 then
		Scene.Instance:CreateDoorList()
	else
		Scene.Instance:DeleteObjsByType(SceneObjType.Door)
	end

	if ViewManager.Instance:IsOpen(ViewName.FuBenTeamSpecialInfoView) then
		self.team_special_info_view:Flush()
		Scene.Instance:CheckClientObj()
		if protocol.is_over == 1 then
			self.team_special_info_view:SetCountDown()
		end
	end
end

function FuBenCtrl:OnEquipFBInfo(protocol)
	-- self.fu_ben_data:SetTeamSpecialInfo(protocol)
	-- if ViewManager.Instance:IsOpen(ViewName.FuBenTeamSpecialInfoView) then
	-- 	self.team_special_info_view:Flush()
	-- end
end

function FuBenCtrl:OnEquipFBTotalPassExp(protocol)
	-- self.fu_ben_data:SetTeamSpecialTotalPassExp(protocol)
	-- if ViewManager.Instance:IsOpen(ViewName.FuBenTeamSpecialInfoView) then
	-- 	self.team_special_info_view:Flush()
	-- end
end

function FuBenCtrl:SendEquipFBBuy(param_1, param_2)
	-- local send_protocol = ProtocolPool.Instance:GetProtocol(CSEquipFBBuy)
	-- send_protocol.param_1 = param_1 or 0 					-- 神秘层商品序号
	-- send_protocol.param_2 = param_2 or 0 					-- 1：单人副本，0：组队副本
	-- send_protocol:EncodeAndSend()
end

function FuBenCtrl:SendEquipFBGetInfo(param_1)
	-- local send_protocol = ProtocolPool.Instance:GetProtocol(CSEquipFBGetInfo)
	-- send_protocol.param_1 = param_1 or 0 					-- 1：请求单人装备副本信息，0：请求组队信息
	-- send_protocol:EncodeAndSend()
end

function FuBenCtrl:SendEquipFBJumpReq() 					-- 跳层请求
-- 	local send_protocol = ProtocolPool.Instance:GetProtocol(CSEquipFBJumpReq)
-- 	send_protocol:EncodeAndSend()
end
--------------------------------------------------------

function FuBenCtrl:SetFailOkCallBack(fun) 					-- 跳层请求
	self.fu_ben_fail_view:SetOKCallback(fun)
end

