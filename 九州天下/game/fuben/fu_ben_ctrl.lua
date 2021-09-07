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
require("game/fuben/fu_ben_info_exp_view")
-- require("game/fuben/fu_ben_info_story_view")
require("game/fuben/fu_ben_info_tower_view")
require("game/fuben/fu_ben_info_vip_view")
require("game/fuben/fu_ben_icon_view")
require("game/fuben/fu_ben_wing_story_view")
require("game/fuben/fu_ben_guwu_view")
require("game/fuben/fu_ben_many_fb_view")
require("game/fuben/fu_ben_push_common_view")
require("game/fuben/fu_ben_push_special_view")
require("game/fuben/fu_ben_info_push_view")
require("game/fuben/fu_ben_info_guard_view")
require("game/fuben/fu_ben_guard_view")
require("game/fuben/fu_ben_info_team_special_view")


FuBenCtrl = FuBenCtrl or BaseClass(BaseController)

local FLUSH_REDPOINT_CD = 600

function FuBenCtrl:__init()
	if FuBenCtrl.Instance ~= nil then
		print_error("[FuBenCtrl]:Attempt to create singleton twice!")
		return
	end
	FuBenCtrl.Instance = self
	self.fu_ben_view = FuBenView.New(ViewName.FuBen)
	self.fu_ben_data = FuBenData.New()
	self.fu_ben_guwu_view = FuBenGuWuView.New()
	self.fu_ben_victory_view = FuBenVictoryFinishView.New(ViewName.FBVictoryFinishView)
	self.fu_ben_fail_view = FuBenFailFinishView.New(ViewName.FBFailFinishView)
	self.phase_info_view = FuBenInfoPhaseView.New(ViewName.FuBenPhaseInfoView)
	self.exp_info_view = FuBenInfoExpView.New(ViewName.FuBenExpInfoView)
	-- self.story_info_view = FuBenInfoStoryView.New(ViewName.FuBenStoryInfoView)
	self.tower_info_view = FuBenInfoTowerView.New(ViewName.FuBenTowerInfoView)
	self.vip_info_view = FuBenInfoVipView.New(ViewName.FuBenVipInfoView)
	self.fu_ben_icon_view = FbIconView.New(ViewName.FbIconView)
	self.fu_ben_wing_story_view = FuBenWingStoryView.New(ViewName.FBWingStoryView)
	self.many_fb_view = ManyFbView.New()
	self.push_info_view = FuBenInfoPushView.New(ViewName.FuBenPushInfoView)
	self.guard_info_view = FuBenInfoGuardView.New(ViewName.FuBenGuardInfoView)
	self.team_special_info_view = FuBenInfoTeamSpecialView.New(ViewName.FuBenTeamSpecialInfoView)

	self.scene_load_complete = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.SceneLoadComplete, self))
	self.fuben_quit = GlobalEventSystem:Bind(OtherEventType.FUBEN_QUIT, BindTool.Bind(self.FubenQuit, self))
	self:RegisterAllProtocols()

	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.CalToRemind, self), 600)

	self.time_quest = {}

	RemindManager.Instance:Register(RemindName.FuBenAdvance, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.FuBenAdvance))
	RemindManager.Instance:Register(RemindName.FuBenExp, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.FuBenExp))
	RemindManager.Instance:Register(RemindName.FuBenStory, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.FuBenStory))
	RemindManager.Instance:Register(RemindName.FuBenVip, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.FuBenVip))
	RemindManager.Instance:Register(RemindName.FuBenTower, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.FuBenTower))
	RemindManager.Instance:Register(RemindName.FuBenPeople, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.FuBenPeople))
	RemindManager.Instance:Register(RemindName.FuBenCommon, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.FuBenCommon))
	RemindManager.Instance:Register(RemindName.FuBenSpecial, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.FuBenSpecial))	
end

function FuBenCtrl:__delete()
	FuBenCtrl.Instance = nil
	if self.fu_ben_view ~= nil then
		self.fu_ben_view:DeleteMe()
		self.fu_ben_view = nil
	end

	if self.fu_ben_data ~= nil then
		self.fu_ben_data:DeleteMe()
		self.fu_ben_data = nil
	end

	if nil ~= self.many_fb_view then
		self.many_fb_view:DeleteMe()
		self.many_fb_view = nil
	end

	-- if self.story_info_view ~= nil then
	-- 	self.story_info_view:DeleteMe()
	-- 	self.story_info_view = nil
	-- end

	if self.phase_info_view ~= nil then
		self.phase_info_view:DeleteMe()
		self.phase_info_view = nil
	end

	if self.tower_info_view ~= nil then
		self.tower_info_view:DeleteMe()
		self.tower_info_view = nil
	end

	if self.fu_ben_guwu_view ~= nil then
		self.fu_ben_guwu_view:DeleteMe()
		self.fu_ben_guwu_view = nil
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

	if self.push_info_view ~= nil then
		self.push_info_view:DeleteMe()
		self.push_info_view = nil
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

	if self.guard_info_view ~= nil then
		self.guard_info_view:DeleteMe()
		self.guard_info_view = nil
	end

	if self.team_special_info_view ~= nil then
		self.team_special_info_view:DeleteMe()
		self.team_special_info_view = nil
	end

	self.time_quest = {}

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	RemindManager.Instance:UnRegister(RemindName.FuBenAdvance)
	RemindManager.Instance:UnRegister(RemindName.FuBenExp)
	RemindManager.Instance:UnRegister(RemindName.FuBenStory)
	RemindManager.Instance:UnRegister(RemindName.FuBenVip)
	RemindManager.Instance:UnRegister(RemindName.FuBenTower)
	RemindManager.Instance:UnRegister(RemindName.FuBenPeople)
	RemindManager.Instance:UnRegister(RemindName.FuBenCommon)
	RemindManager.Instance:UnRegister(RemindName.FuBenSpecial)	
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

	self:RegisterProtocol(CSTuituFbOperaReq)
	self:RegisterProtocol(SCTuituFbInfo, "OnTuituFbInfo")
	self:RegisterProtocol(SCTuituFbResultInfo, "OnTuituFbResultInfo")
	self:RegisterProtocol(SCTuituFbSingleInfo, "OnTuituFbSingleInfo")
	self:RegisterProtocol(SCTuituFbFetchResultInfo, "OnTuituFbFetchResultInfo")
	self:RegisterProtocol(SCFBDropCount, "OnFBDropCount")

	--个人塔防
	self:RegisterProtocol(SCTowerDefendRoleInfo, "OnTowerDefendRoleInfo")
	self:RegisterProtocol(SCTowerDefendWarning, "OnTowerDefendWarning")
	self:RegisterProtocol(SCTowerDefendInfo, "OnTowerDefendInfo")
	--self:RegisterProtocol(SCFBDropInfo, "OnFBDropInfo")
	self:RegisterProtocol(SCTowerDefendResult, "OnTowerDefendResult")

	-- 副本结束奖励
	self:RegisterProtocol(SCCommonFbGetRewardInfo, "OnCommonFbGetRewardInfo")

	--组队副本
	self:RegisterProtocol(SCEquipFBResult, "OnEquipFBResult")
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
	-- if self.fu_ben_view then
	-- 	self.fu_ben_view:DoRemind()
	-- end	
	RemindManager.Instance:Fire(RemindName.FuBenAdvance)
end

-- 经验副本信息请求
function FuBenCtrl:SendGetExpFBInfoReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDailyFBGetRoleInfo)
	send_protocol:EncodeAndSend()
end

-- 经验副本信息返回
function FuBenCtrl:OnSCDailyFBRoleInfo(protocol)
	RemindManager.Instance:Fire(RemindName.FuBenExp)
	-- self.fu_ben_data:SetSCDailyFBRoleInfo(protocol)
	self.fu_ben_data:OnSCDailyFBRoleInfo(protocol)
	self.fu_ben_view:Flush("exp")
end

-- 经验副本鼓舞请求
function FuBenCtrl:SendFbGuwuReq(is_gold,guwu_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFbGuwu)
	send_protocol.is_gold = is_gold
	send_protocol.guwu_type = guwu_type
	send_protocol:EncodeAndSend()
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
	RemindManager.Instance:Fire(RemindName.FuBenStory)	
	self.fu_ben_data:SetStoryFBInfo(protocol.info_list)
	self.fu_ben_view:Flush("story")
	-- if ViewManager.Instance:IsOpen(ViewName.FuBenStoryInfoView) then
	-- 	self.story_info_view:Flush()
	-- end
	self:FlushMainUIRedPoint()
end

-- vip副本信息请求
function FuBenCtrl:SendGetVipFBGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSVipFbAllInfoReq)
	send_protocol:EncodeAndSend()
end

-- vip副本信息返回
function FuBenCtrl:GetVipFBInfoReq(protocol)
	RemindManager.Instance:Fire(RemindName.FuBenVip)
	self.fu_ben_data:SetVipFBInfo(protocol)
	self.fu_ben_view:Flush("vip")
	if ViewManager.Instance:IsOpen(ViewName.FuBenVipInfoView) then
		self.vip_info_view:Flush()
	end
	self:FlushMainUIRedPoint()
end

-- 爬塔副本信息请求
function FuBenCtrl:SendGetTowerFBGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSPataFbAllInfo)
	send_protocol:EncodeAndSend()
end

-- 爬塔副本信息返回
function FuBenCtrl:GetTowerFBInfoReq(protocol)
	RemindManager.Instance:Fire(RemindName.FuBenTower)
	self.fu_ben_data:SetTowerFBInfo(protocol)
	self.fu_ben_view:Flush("tower")
	if ViewManager.Instance:IsOpen(ViewName.FuBenTowerInfoView) then
		self.tower_info_view:Flush()
	end
	self:FlushMainUIRedPoint()
	-- RemindManager.Instance:Fire(RemindName.BeStrength)
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
end

-- 组队装备副本信息
function FuBenCtrl:OnTeamEquipFbInfo(protocol)
	self.fu_ben_data:SetManyFbInfo(protocol)
	if self.many_fb_view and self.many_fb_view:IsOpen() then
		self.many_fb_view:Flush()
	end
end

-- 组队装备副本掉落次数信息
function FuBenCtrl:OnTeamEquipFbDropCountInfo(protocol)
	self.fu_ben_data:SetTeamEquipFbDropCountInfo(protocol)
	if self.fu_ben_view and self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Flush("manypeople")
	end
end

----------------组队副本(须臾幻境)协议--------------
function FuBenCtrl:OnEquipFBResult(protocol)
	self.fu_ben_data:SetTeamSpecialResult(protocol)
	local team_special_is_passed = protocol.is_passed
	if team_special_is_passed and team_special_is_passed == 1 then
		Scene.Instance:CreateDoorList()
	else
		Scene.Instance:DeleteObjsByType(SceneObjType.Door)
	end

	if ViewManager.Instance:IsOpen(ViewName.FuBenTeamSpecialInfoView) then
		self.team_special_info_view:Flush()
		Scene.Instance:CheckClientObj()
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
	if self.exp_info_view:IsOpen() then
		self.exp_info_view:Flush()
	end
	DailyTaskFbCtrl.Instance:PanleFlush()
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
		local scene_type = Scene.Instance:GetSceneType()
		for k,v in pairs(CrossFbType) do
			if scene_type == v then
				CrossServerCtrl.Instance:GoBack()
				return
			end
		end
	end

	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLeaveFB)
	send_protocol:EncodeAndSend()
end

function FuBenCtrl:FlushView(param, info)
	if param == SceneType.ExpFb then
		self.exp_info_view:Flush()
	-- elseif param == SceneType.StoryFB then
	-- 	self.story_info_view:Flush()
	elseif param == SceneType.VipFB then
		self.vip_info_view:Flush()
	elseif param == SceneType.PataFB then
		self.tower_info_view:Flush()
	elseif param == SceneType.PhaseFb then
		self.phase_info_view:Flush()
	elseif param == SceneType.RuneTower then
		ViewManager.Instance:FlushView(ViewName.RuneTowerFbInfoView)
	elseif param == SceneType.PushFuBen then
		ViewManager.Instance:FlushView(ViewName.FuBenPushInfoView)
	elseif param == SceneType.DailyTaskFb then
		ViewManager.Instance:FlushView(ViewName.DailyTaskFb)
		if info.is_pass == 1 then
			local data = {}
			local reward_cfg = TaskData.Instance:GetTaskReward(TASK_TYPE.RI)
			if reward_cfg then
				data = {[1] = {item_id = FuBenDataExpItemId.ItemId, num = reward_cfg.exp}}
			end
			-- ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = data, leave_time = 5})
		end
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
	end
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	local name_list_t = Split(fb_scene_cfg.show_fbicon, "#")
	if #name_list_t > 0
		or BossData.IsWorldBossScene(scene_id)
		or BossData.IsDabaoBossScene(scene_id)
		or BossData.IsFamilyBossScene(scene_id)
		or BossData.IsMikuBossScene(scene_id)
		or BossData.IsActiveBossScene(scene_id)
		or AncientRelicsData.IsAncientRelics(scene_id)
		or RelicData.Instance:IsRelicScene(scene_id)
		or BossData.IsBabyBossScene(scene_id) then
		self.fu_ben_icon_view:Open()
	end
end

function FuBenCtrl:FubenQuit(scene_type)
	self.fu_ben_icon_view:Close()
	self.fu_ben_data:ClearFBSceneLogicInfo()
	self.fu_ben_data:ClearKillInfo()
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
				--self.fu_ben_view:FlushRedPoint()
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

function FuBenCtrl:CloseView()
	if self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Close()
	end
end

-- 刷新多人副本
function FuBenCtrl:FlushManyPeopleView()
	if self.fu_ben_view and self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Flush("manypeople")
	end
end

function FuBenCtrl:FlushManyPeopleRewardView()
	if self.fu_ben_view and self.fu_ben_view:IsOpen() then
		self.fu_ben_view:Flush("manypeople_reward")
	end
end

-- 打开多人副本副本场景
function FuBenCtrl:OpenManyFbView()
	if self.many_fb_view then
		self.many_fb_view:Open()
	end
end

-- 关闭多人副本副本场景
function FuBenCtrl:CloseManyFbView()
	if self.many_fb_view then
		self.many_fb_view:Close()
	end
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
		self.fu_ben_view:Flush("manypeople")
		self.fu_ben_view:Flush("exp")
	end
end

-- 副本房间进入确认通知
function FuBenCtrl:OnTeamFbRoomEnterAffirm(protocol)
	self.fu_ben_data:SetTeamFbRoomEnterAffirm(protocol)
	TipsCtrl.Instance:ShowEnterFbView()
end

function FuBenCtrl:GuWuValue()
	-- if self.exp_info_view then
	-- 	self.exp_info_view:GuWuValue()
	-- end
	if self.fu_ben_guwu_view:IsOpen() then
		self.fu_ben_guwu_view:GuWuPet()
	end
end

function FuBenCtrl:OpenFbGuWu()
	if self.fu_ben_guwu_view then
		self.fu_ben_guwu_view:Open()
	end
end

-- 推图总协议下来
function FuBenCtrl:OnTuituFbInfo(protocol)
	self.fu_ben_data:SetTuituFbInfo(protocol)
	RemindManager.Instance:Fire(RemindName.FBPush1)
	RemindManager.Instance:Fire(RemindName.FBPush2)
	RemindManager.Instance:Fire(RemindName.FuBenCommon)
	if self.fu_ben_view:IsOpen() then
		self.fu_ben_view:OnItemDataChange()
	end
	
end

-- 推图通关协议
function FuBenCtrl:OnTuituFbResultInfo(protocol)
	self.fu_ben_data:SetTuituFbResultInfo(protocol)
	if ViewManager.Instance:IsOpen(ViewName.FuBenPushInfoView) then
		self.push_info_view:Flush()
	end

	-- if protocol.star > 0 then
	-- 	ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = protocol.reward_item_list, leave_time = 3})
	-- else
	-- 	ViewManager.Instance:Open(ViewName.FBFailFinishView)
	-- end
end

-- -- 推图信息变动
function FuBenCtrl:OnTuituFbSingleInfo(protocol)
	RemindManager.Instance:Fire(RemindName.FuBenCommon)
	self.fu_ben_data:SetTuituFbSingleInfo(protocol)
	RemindManager.Instance:Fire(RemindName.FBPush1)
	RemindManager.Instance:Fire(RemindName.FBPush2)
	if self.fu_ben_view:IsOpen() then
		self.fu_ben_view:OnItemDataChange()
	end
end

-- 领取奖励返回
function FuBenCtrl:OnTuituFbFetchResultInfo(protocol)
	if protocol.is_success == 1 and protocol.fb_type == PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL then
		FuBenData.Instance:OnPushFbFetchShowStarRewardSucc(protocol)
		--TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD)
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

-----------------
--单人塔防
-----------------
-------------
--个人塔防角色信息
function FuBenCtrl:OnTowerDefendRoleInfo(protocol)
	RemindManager.Instance:Fire(RemindName.FuBenSpecial)			
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
	if protocol.warning_type == 1 then
		self.fu_ben_data:SetTowerIsWarning(true)
		SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.TowerBeHurt)
	else
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.TowerDefend.TowerHpTooLess, protocol.percent .. "%"))
	end
end

--个人塔防信息
function FuBenCtrl:OnTowerDefendInfo(protocol)
	self.fu_ben_data:SetTowerDefendInfo(protocol)
	self.guard_info_view:Flush()
	-- if protocol.is_finish == 1 then
	-- 	if protocol.is_pass == 1 then
	-- 		ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = protocol.pick_drop_list})
	-- 	else
	-- 		GlobalTimerQuest:AddDelayTimer(function()
	-- 			ViewManager.Instance:Open(ViewName.FBFailFinishView)
	-- 		end, 2)
	-- 	end
	-- end
end

--个人塔防掉落
function FuBenCtrl:OnFBDropInfo(protocol)
	self.fu_ben_data:SetFBDropInfo(protocol)
end

--个人塔防结果
function FuBenCtrl:OnTowerDefendResult(protocol)
	if protocol.is_passed == 1 then
		local drop_item = FuBenData.Instance:GetFBDropItemList()
		ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = drop_item})
	else
		GlobalTimerQuest:AddDelayTimer(function()
			ViewManager.Instance:Open(ViewName.FBFailFinishView)
		end, 2)
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

function FuBenCtrl:OnFBDropCount(protocol)
	self.fu_ben_data:GetFBDropCount(protocol)
end

--爬塔提醒功能
function FuBenCtrl:CalToRemind()
	local scene_type = Scene.Instance:GetSceneType()
	local fb_info = FuBenData.Instance:GetTowerFBInfo()
	local tower_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
	if scene_type ~= SceneType.Common or fb_info == nil or next(fb_info) == nil or fb_info.pass_level <= 0  then return end
	--FuBenCtrl.Instance:SendGetTowerFBGetInfo()
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo().capability
    if fb_info and fb_info.today_level and #tower_cfg > fb_info.pass_level then 
    	if nil == tower_cfg[fb_info.today_level + 1] then
    		return
    	end
    	local can_enter = main_role_vo > tower_cfg[fb_info.today_level + 1].capability

   		if can_enter then
    		local ok_call_back = function()
   				--if FuBenData.Instance:IsShowTowerFBRedPoint() then
				-- 	FuBenCtrl.Instance:SetRedPointCountDown("tower")
				-- 	RemindManager.Instance:Fire(RemindName.FuBenSingle)
				-- end
				-- FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PATAFB)
				-- ViewManager.Instance:Close(ViewName.FuBen)
				ViewManager.Instance:Open(ViewName.FuBen,TabIndex.fb_tower)
   	 		end
   			TipsCtrl.Instance:OpenFocusFuBenTip("Icon_System_Instance", ok_call_back, 15)
    	end
    end
   
end

-- 副本结束奖励
function FuBenCtrl:OnCommonFbGetRewardInfo(protocol)
	local data = {}
	data.reward_list = protocol.item_list
	local extra_data = {}
	extra_data.num = protocol.param_1
	TipsCtrl.Instance:OpenActivityRewardTip(data, extra_data)
end

function FuBenCtrl:GetGemChangeRemind(remind_type)
	local flag = 0
	if remind_type == RemindName.FuBenAdvance then
		local open_flag = OpenFunData.Instance:CheckIsHide("fb_phase")
		if FuBenData.Instance:IsShowPhaseFBRedPoint() and open_flag then
			flag = 1
		end
	elseif remind_type == RemindName.FuBenExp then
		local open_flag = OpenFunData.Instance:CheckIsHide("fb_exp")
		if FuBenData.Instance:IsShowExpFBRedPoint() and open_flag then
			flag = 1
		end	
	elseif remind_type == RemindName.FuBenVip then
		local open_flag = OpenFunData.Instance:CheckIsHide("fb_vip")
		if FuBenData.Instance:IsShowVipFBRedPoint() and open_flag then
			flag = 1
		end	
	elseif remind_type == RemindName.FuBenTower then
		local open_flag = OpenFunData.Instance:CheckIsHide("fb_tower")
		if FuBenData.Instance:IsShowTowerFBRedPoint() and open_flag then
			flag = 1
		end	
	elseif remind_type == RemindName.FuBenCommon then
		local open_flag = OpenFunData.Instance:CheckIsHide("fb_push_common")
		if FuBenData.Instance:GetPushReWardRed() and open_flag then
			flag = 1
		end	
	elseif remind_type == RemindName.FuBenSpecial then
		local open_flag = OpenFunData.Instance:CheckIsHide("fb_person_guard")
		if FuBenData.Instance:IsShowGuardFBRedPoint() and open_flag then
			flag = 1
		end	
	end					
	return flag
end

function FuBenCtrl:FlushCommonView()
	if self.fu_ben_view:IsOpen() then
		self.fu_ben_view:FlushCommonView()
	end
	
end