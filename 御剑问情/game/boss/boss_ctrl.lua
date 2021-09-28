require("game/boss/boss_view")
require("game/boss/boss_data")
require("game/boss/kf_boss_data")
require("game/boss/world_boss_fight_view")
require("game/boss/kf_boss_info")
require("game/boss/dabao_fam_fight_view")
require("game/boss/boss_family_fight_view")
require("game/boss/active_fam_fight_view")
require("game/boss/secret_boss_fight_view")
require("game/boss/baby_boss_fight_view")
require("game/boss/world_boss_rand_reward_view")
BossCtrl = BossCtrl or  BaseClass(BaseController)

function BossCtrl:__init()
	if BossCtrl.Instance ~= nil then
		print_error("[BossCtrl] attempt to create singleton twice!")
		return
	end
	BossCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = BossView.New(ViewName.Boss)
	self.kf_boss_data = KfBossData.New()
	self.data = BossData.New()
	self.world_boss_rand_reward_view = WorldBossRankRewardView.New()
	self.world_boss_fight_view = WorldBossFightView.New()
	self.dabao_fam_fight_view = DabaoFamFightView.New(ViewName.DabaoBossInfoView)
	self.active_fam_fight_view = ActiveFamFightView.New(ViewName.ActiveBossInfoView)
	self.boss_family_fight_view = BossFamilyFightView.New(ViewName.BossFamilyInfoView)
	self.secret_boss_fight_view = SecretBossFightView.New(ViewName.SecretBossFightView)
	self.baby_boss_fight_view = BabyBossFightView.New(ViewName.BabyBossFightView)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function BossCtrl:GetView()
	return self.view
end

function BossCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.world_boss_rand_reward_view ~= nil then
		self.world_boss_rand_reward_view:DeleteMe()
		self.world_boss_rand_reward_view = nil
	end

	if self.kf_boss_data ~= nil then
		self.kf_boss_data:DeleteMe()
		self.kf_boss_data = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.world_boss_fight_view then
		self.world_boss_fight_view:DeleteMe()
		self.world_boss_fight_view = nil
	end

	if self.dabao_fam_fight_view ~= nil then
		self.dabao_fam_fight_view:DeleteMe()
		self.dabao_fam_fight_view = nil
	end

	if self.boss_family_fight_view ~= nil then
		self.boss_family_fight_view:DeleteMe()
		self.boss_family_fight_view = nil
	end

	if self.secret_boss_fight_view ~= nil then
		self.secret_boss_fight_view:DeleteMe()
		self.secret_boss_fight_view = nil
	end

	if self.kf_boss_info_view ~= nil then
		self.kf_boss_info_view:DeleteMe()
		self.kf_boss_info_view = nil
	end

	if self.active_fam_fight_view ~= nil then
		self.active_fam_fight_view:DeleteMe()
		self.active_fam_fight_view = nil
	end

	if self.babay_boss_view ~= nil then
		self.babay_boss_view:DeleteMe()
		self.babay_boss_view = nil
	end

	if self.baby_boss_fight_view ~= nil then
		self.baby_boss_fight_view:DeleteMe()
		self.baby_boss_fight_view = nil
	end

	if self.welfare_count_down then
		CountDown.Instance:RemoveCountDown(self.welfare_count_down)
		self.welfare_count_down = nil
	end

	if self.scene_loaded then
		GlobalEventSystem:UnBind(self.scene_loaded)
		self.scene_loaded = nil
	end

	self:RemoveDelayTime()
	self:RemoveDelayTime2()
	self:RemoveDelayBossTime()

	BossCtrl.Instance = nil
end

function BossCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossShenwuBossCanEnterNotice, "SCCrossShenwuBossCanEnterNotice")
	self:RegisterProtocol(SCWorldBossInfo, "OnWorldBossInfo")
	self:RegisterProtocol(SCWorldBossBorn, "OnWorldBossBorn")
	self:RegisterProtocol(SCWorldBossSendPersonalHurtInfo, "OnWorldBossSendPersonalHurtInfo")
	self:RegisterProtocol(SCWorldBossSendGuildHurtInfo, "OnWorldBossSendGuildHurtInfo")
	self:RegisterProtocol(SCWorldBossWeekRankInfo, "OnWorldBossWeekRankInfo")
	self:RegisterProtocol(SCWorldBossCanRoll, "OnWorldBossCanRoll")
	self:RegisterProtocol(SCWorldBossRollInfo, "OnWorldBossRollInfo")
	self:RegisterProtocol(SCWorldBossRollTopPointInfo, "OnWorldBossRollTopPointInfo")

	self:RegisterProtocol(SCDabaoBossInfo, "OnDabaoBossInfo")			--打宝boss信息
	self:RegisterProtocol(SCFamilyBossInfo, "OnFamilyBossInfo")			--boss之家boss信息
	self:RegisterProtocol(SCMikuBossInfo, "OnMikuBossInfo")			--秘窟boss信息
	self:RegisterProtocol(SCMikuMonsterInfo, "OnMikuMonsterInfo")			--秘窟精英怪物信息（在场景内才会收到该协议，数量对应场景）
	self:RegisterProtocol(SCBossRoleInfo, "OnSCBossRoleInfo")			--秘窟疲劳值信息
	self:RegisterProtocol(SCDabaoBossNextFlushInfo, "OnSCDabaoBossNextFlushInfo")			--打宝信息
	self:RegisterProtocol(SCBossInfoToAll, "OnSCBossInfoToAll")				--所有boss信息
	self:RegisterProtocol(SCWorldBossInfoToAll, "OnSCWorldBossInfoToAll")	--广播世界boss信息
	self:RegisterProtocol(SCBossKillerList, "OnSCBossKillerList")			--击杀boss信息
	self:RegisterProtocol(SCWorldBossKillerList, "OnSCWorldBossKillerList")				--击杀世界boss信息
	self:RegisterProtocol(SCFollowBossInfo, "OnSCFollowBossInfo")				--boss关注列表信息
	self:RegisterProtocol(SCWorldBossWearyInfo, "SCWorldBossWearyInfo")				--boss疲劳值复活信息
	self:RegisterProtocol(SCActiveBossNextFlushInfo, "OnSCActiveBossNextFlushInfo")				--活跃boss刷新时间信息
	self:RegisterProtocol(SCActiveBossInfo, "OnActiveBossInfo")				--活跃boss信息


	---------------跨服BOSS-----------------------------
	self:RegisterProtocol(SCCrossBossPlayerInfo, "OnCrossBossPlayerInfo")				--跨服BOSS玩家信息
	self:RegisterProtocol(SCCrossBossSceneBossInfo, "OnCrossBossSceneBossInfo")		--跨服boss场景里的boss列表
	self:RegisterProtocol(SCServerShutdownNotify, "OnServerShutdownNotify")				--服务器即将关闭通知
	self:RegisterProtocol(SCCrossBossBossInfoAck, "OnCrossBossBossInfoAck")				--跨服boss信息

	self:RegisterProtocol(CSCrossBossBuyReliveTimes)					--跨服BOSS购买复活次数
	---------------跨服BOSS end--------------------------

	self:RegisterProtocol(CSGetWorldBossInfo)							--获取世界boss信息

	self:RegisterProtocol(SCBossDpsFlag, "OnBossDpsInfo")

	self:RegisterProtocol(CSWorldBossHPInfoReq)
	self:RegisterProtocol(SCWorldBossHPInfo, "OnBossHpInfo")

	--密藏BOSS
	self:RegisterProtocol(SCPreciousBossTaskInfo, "OnBossTaskInfo")
	self:RegisterProtocol(SCPreciousBossInfo, "OnPreciousBossInfo")
	self:RegisterProtocol(SCPreciousPosInfo, "OnPreciousPosInfo")
	--END

	--仙戒boss
	self:RegisterProtocol(SCXianjieBossInfo, "OnXianjieBossInfo")						--仙戒boss所有信息
	self:RegisterProtocol(SCXianjieBossPosInfo, "OnXianjieBossPosInfo")					--仙戒boss位置信息
	self:RegisterProtocol(CSXianjieBossPosReq)
	self:RegisterProtocol(CSXianjieBossInfo)

	--宝宝boss
	self:RegisterProtocol(CSBabyBossOperate)
	self:RegisterProtocol(SCBabyBossRoleInfo, "OnBabyBossRoleInfo")						--宝宝boss人物信息
	self:RegisterProtocol(SCAllBabyBossInfo, "OnBabyBossAllInfo")						--宝宝boss信息
	self:RegisterProtocol(SCSingleBabyBossInfo, "OnBabyBossSingleInfo")					--单个宝宝boss信息

	--奇遇boss
	self:RegisterProtocol(CSJingLingAdvantageBossEnter)
	self:RegisterProtocol(SCJingLingAdvantageBossInfo, "OnEncounterBossInfo")			--奇遇boss刷新信息

	--掉落日志
	self:RegisterProtocol(CSGetDropLog)
	self:RegisterProtocol(SCDropLogRet, "OnDropLogRet")

	--活跃Boss伤害排行信息
	self:RegisterProtocol(SCActiveBossHurtRankInfo, "OnActiveBossHurtRankInfo")
end

function BossCtrl:OpenWorldBossRankRewardView(open_type)
	if self.world_boss_rand_reward_view and not self.world_boss_rand_reward_view:IsOpen() then
		self.world_boss_rand_reward_view:SetData(open_type)
		self.world_boss_rand_reward_view:Open()
	end
end
function BossCtrl:OnXianjieBossInfo(protocol)
	self.data:SetXianJieBossList(protocol.boss_list)
	if self.view:IsOpen() then
		self.view:Flush("xianjie_boss")
	end
	-- self.data:CheckXianJieBoss(protocol)
end

function BossCtrl:OnXianjieBossPosInfo(protocol)
	self.data:SetXianJieBossPos(protocol)
	-- if self.view:IsOpen() then
	-- 	self.view:Flush("xianjie_boss")
	-- end
end

function BossCtrl:RequestXianjieBossInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSXianjieBossInfo)
	protocol:EncodeAndSend()
end

--设置仙戒boss参与次数
function BossCtrl:SetXianJieBossDayCount(count)
	self.data:SetXianJieBossDayCount(count)
	if self.view:IsOpen() then
		self.view:Flush("xianjie_boss")
	end
end

function BossCtrl:SetBossHpInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossHPInfoReq)
	protocol:EncodeAndSend()
end

function BossCtrl:OnBossHpInfo(protocol)
	self.data:SetBossHpInfo(protocol)
	self.world_boss_fight_view:Flush()
end

function BossCtrl:OnBossDpsInfo(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)

	if MainUICtrl.Instance.view.target_view then
		MainUICtrl.Instance.view.target_view:OnFirstHurtChange(protocol.top_dps_flag, protocol.obj_id, protocol.boss_id)
	else
		self.scene_loaded = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
			BindTool.Bind(self.OnSceneLoaded, self, protocol.top_dps_flag, protocol.obj_id, protocol.boss_id))
	end

	if obj then
		obj:SetAttr("top_dps_flag", protocol.top_dps_flag)
		local boss_obj = Scene.Instance:GetObj(protocol.boss_id)
		if boss_obj then
			boss_obj:SetAttr("dsp_name", obj:GetName())
		end
	end
end

function BossCtrl:OnSceneLoaded(top_dps_flag, obj_id, boss_obj_id)
	MainUICtrl.Instance.view.target_view:OnFirstHurtChange(top_dps_flag, obj_id, boss_obj_id)
end

 --获取BOSS信息
function BossCtrl:SendGetWorldBossInfo(boss_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetWorldBossInfo)
	protocol.boss_type = boss_type
	protocol:EncodeAndSend()
end

function BossCtrl:MainuiOpen()
	self:SendGetWorldBossInfo(1)
	self:SendPosInfo(1)
	self.SendGetBossInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_PRECIOUS)

	self:AutoFocusManager()
end

--下发世界boss信息
function BossCtrl:OnWorldBossInfo(protocol)
	local cur_flush_time = self.data:GetBossNextReFreshTime()
	local show_welfare_icon, time_diff = self:CheckShowMainWelfareIcon(cur_flush_time, protocol.next_refresh_time)
	--打开关注tips
	self:CheckOpenWelfareTips(cur_flush_time, protocol.next_refresh_time)
	self.data:SetBossInfo(protocol)
	self.view:Flush("boss_list")
	self.world_boss_fight_view:Flush()
	--主界面显示福利boss倒计时
	if show_welfare_icon == true then
		MainUICtrl.Instance:FlushView("flush_welfare_icon", {[1] = true})
		if self.welfare_count_down then
			CountDown.Instance:RemoveCountDown(self.welfare_count_down)
			self.welfare_count_down = nil
		end
		self.welfare_count_down = CountDown.Instance:AddCountDown(math.ceil(time_diff), 1, BindTool.Bind(self.WelfareBossIconCountDown, self))
	end
end

function BossCtrl:SCCrossShenwuBossCanEnterNotice(protocol)
	KuafuGuildBattleCtrl.Instance:FoucsSwBoss(protocol)
end


-- boss出生
function BossCtrl:OnWorldBossBorn(protocol)
	self:SendGetWorldBossInfo(1)
end

function BossCtrl:GetBossFamilyFightView()
	return self.boss_family_fight_view
end

 --世界boss个人伤害排名请求
function BossCtrl:SendWorldBossPersonalHurtInfoReq(boss_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossPersonalHurtInfoReq)
	protocol.boss_id = boss_id or 0
	protocol:EncodeAndSend()
end

 --世界boss公会伤害排名请求
function BossCtrl:SendWorldBossGuildHurtInfoReq(boss_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossGuildHurtInfoReq)
	protocol.boss_id = boss_id or 0
	protocol:EncodeAndSend()
end

 --世界boss击杀数量周榜排名请求
function BossCtrl:SendWorldBossWeekRankInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossWeekRankInfoReq)
	protocol:EncodeAndSend()
end

-- 返回世界boss个人伤害排名
function BossCtrl:OnWorldBossSendPersonalHurtInfo(protocol)
	self.data:SetBossPersonalHurtInfo(protocol)
	if self.world_boss_fight_view:IsOpen() then
		self.world_boss_fight_view:Flush()
	end
end

-- 返回世界boss公会伤害排名信息
function BossCtrl:OnWorldBossSendGuildHurtInfo(protocol)
	self.data:SetBossGuildHurtInfo(protocol)
	if self.world_boss_fight_view:IsOpen() then
		self.world_boss_fight_view:Flush()
	end
end

-- 返回世界boss击杀数量周榜排名信息
function BossCtrl:OnWorldBossWeekRankInfo(protocol)
	self.data:SetBossWeekRankInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("boss_list")
	end
end

function BossCtrl:OpenBossInfoView()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsWorldBossScene(scene_id) then
			if self.world_boss_fight_view then
				self.world_boss_fight_view:Open()
			end
		end
	end
end

function BossCtrl:CloseBossInfoView()
	if self.world_boss_fight_view:IsOpen() then
		self.world_boss_fight_view:Close()
	end
end

 --玩家请求摇点
function BossCtrl:SendWorldBossRollReq(boss_id, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossRollReq)
	protocol.boss_id = boss_id or 0
	protocol.index = index or 0
	protocol:EncodeAndSend()
end

function BossCtrl:OnWorldBossCanRoll(protocol)
	local boss_id = protocol.boss_id
	if boss_id then
		local scene_id = Scene.Instance:GetSceneId()
		if scene_id then
			if BossData.IsWorldBossScene(scene_id) then
				local temp_boss_id = self.data:GetWorldBossIdBySceneId(scene_id)
				if temp_boss_id == boss_id then
					if self.world_boss_fight_view:IsOpen() then
						self.world_boss_fight_view:SetCanRoll(protocol.index)
					end
				end
			end
		end
	end
end

function BossCtrl:OnWorldBossRollInfo(protocol)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsWorldBossScene(scene_id) then
			if self.world_boss_fight_view:IsOpen() then
				self.world_boss_fight_view:SetRollResult(protocol.roll_point, protocol.hudun_index)
			end
		end
	end
end

function BossCtrl:OnWorldBossRollTopPointInfo(protocol)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsWorldBossScene(scene_id) then
			if self.world_boss_fight_view:IsOpen() then
				self.world_boss_fight_view:SetRollTopPointInfo(protocol.boss_id, protocol.hudun_index, protocol.top_roll_point, protocol.top_roll_name)
			end
		end
	end
end

---[[
--跨服BOSS
function BossCtrl:OnCrossBossPlayerInfo(protocol)
	-- print_log("跨服BOSS玩家信息", protocol)
	self.kf_boss_data:SetPlayerInfo(protocol)
end

function BossCtrl:OnCrossBossSceneBossInfo(protocol)
	-- print_log("跨服boss场景里的boss列表", protocol)
	self.kf_boss_data:SetBossList(protocol)
	-- if self.kf_boss_info_view:IsOpen() then
	-- 	self.kf_boss_info_view:Flush()
	-- end
end

function BossCtrl:OnServerShutdownNotify(protocol)
	self.kf_boss_data:SetServerShutdown(protocol.remain_second)
end

function BossCtrl:OnCrossBossBossInfoAck(protocol)
	self.kf_boss_data:OnCrossBossBossInfoAck(protocol)
end

function BossCtrl:OnSCBossKillerList(protocol)
	local kill_data = self.data:ComBossKillerInfo(protocol.killer_info_list)
	TipsCtrl.Instance:OpenKillBossTip(kill_data)
end

function BossCtrl:OnSCWorldBossKillerList(protocol)
	local kill_data = self.data:ComBossKillerInfo(protocol.killer_info_list)
	TipsCtrl.Instance:OpenKillBossTip(kill_data)
end

function BossCtrl:OnSCFollowBossInfo(protocol)
	self.data:OnSCFollowBossInfo(protocol)
end

function BossCtrl:SCWorldBossWearyInfo(protocol)
	self.data:SetWorldBossWearyInfo(protocol)
end

function BossCtrl:CrossBossBuyReliveTimes(buy_times)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossBossBuyReliveTimes)
	protocol.buy_times = buy_times or 0
	protocol:EncodeAndSend()
end
--]]

function BossCtrl:CloseView()
	if self.view:IsOpen() then
		self.view:Close()
	end
end

function BossCtrl:ShowKfBossInfoView()
	-- self.kf_boss_info_view:Open()
	-- self.kf_boss_info_view:Flush()
end

function BossCtrl:CloseKfBossInfoView()
	-- self.kf_boss_info_view:Close()
end

function BossCtrl:OnDabaoBossInfo(protocol)
	self.data:SetDabaoBossInfo(protocol)
	self.view:Flush("dabao_boss")
	self.dabao_fam_fight_view:Flush()

	RemindManager.Instance:Fire(RemindName.Boss)
end

function BossCtrl:OnActiveBossInfo(protocol)
	self.data:SetActiveBossInfo(protocol)
	self.view:Flush("active_boss")
	-- self.data:BossFlushTips(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, 30*60)
	self.active_fam_fight_view:Flush()
end

function BossCtrl:OnFamilyBossInfo(protocol)
	self.data:SetFamilyBossInfo(protocol)
	self.view:Flush("boss_family")
	self.boss_family_fight_view:Flush("boss_family")
end

function BossCtrl:OnMikuBossInfo(protocol)
	self.data:ChangeMikuEliteCount(protocol.scene_id, protocol.elite_count)
	self.data:SetMikuBossInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Boss)
	-- self.data:CheckRedPoint()
	self.view:Flush("miku_boss")
	self.view:Flush("vip_boss")
	self.boss_family_fight_view:Flush("miku_boss")
end

function BossCtrl:OnBuyMikuWeraryChange(count)
	self.data:OnMiKuWearyChange(count)
	if self.view:IsOpen() then
		self.view:Flush("miku_boss")
		self.view:Flush("vip_boss")
	end
end

function BossCtrl:OnSCBossRoleInfo(protocol)

	self.data:SetMikuPiLaoInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Boss)
	self.view:Flush("miku_boss")
	self.view:Flush("vip_boss")
	-- self:MikuFlushTurn()
	-- self.data:BossFlushTips(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, 60*30)
end

function BossCtrl:OnSCDabaoBossNextFlushInfo(protocol)
	self.data:OnSCDabaoBossNextFlushInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Boss)
	self.dabao_fam_fight_view:Flush()
end

function BossCtrl:OnMikuMonsterInfo(protocol)
	self.data:ChangeMikuEliteCount(Scene.Instance:GetSceneId(), protocol.elite_count)
	if self.boss_family_fight_view:IsOpen() then
		self.boss_family_fight_view:Flush("elite")
	end
end

function BossCtrl:OnSCActiveBossNextFlushInfo(protocol)
	self.data:OnSCActiveBossNextFlushInfo(protocol)
	self.active_fam_fight_view:Flush()
end

function BossCtrl:OnSCBossInfoToAll(protocol)
	self.data:OnSCBossInfoToAll(protocol)
	if protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
     	self.view:Flush("boss_family")
     	self.boss_family_fight_view:Flush("boss_family")
     	GlobalTimerQuest:AddDelayTimer(function()
			self.data:CalToRemind()
		end, 5)
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
    	RemindManager.Instance:Fire(RemindName.Boss)
    	-- self.data:CheckRedPoint()
    	self.view:Flush("miku_boss")
    	self.boss_family_fight_view:Flush("miku_boss")
    	self.data:CalToRemind()
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
    	self.data:FlushDaBaoFlushInfo(protocol)
    	self.view:Flush("dabao_boss")
    	self.dabao_fam_fight_view:Flush()
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_WORLD then
    	self.view:Flush("boss_list")
		self.world_boss_fight_view:Flush()
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
    	self.data:FlushActiveFlushInfo(protocol)
    	self.view:Flush("active_boss")
    	self.active_fam_fight_view:Flush()
	elseif protocol.boss_type == BOSS_ENTER_TYPE.XIAN_JIE_BOSS then
		if protocol.status == BOSS_STATUS.EXISTENT then
			local scene_id = protocol.scene_id
			local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if scene_config and main_role_vo.level >= (scene_config.levellimit or 0) then
				local function callback()
					GuajiCtrl.Instance:FlyToScenePos(scene_id, scene_config.scenex, scene_config.sceney, 0)
				end
				-- self:SetOtherBossTips(protocol.boss_id, callback, "XianJieBossView", BOSS_ENTER_TYPE.XIAN_JIE_BOSS)
			end
		end
    end
    local my_id = GameVoManager.Instance:GetMainRoleVo().role_id
    if my_id == protocol.killer_uid and protocol.killer_uid ~= 0 then
   		TipsCtrl.Instance:TipsGarrottingBossView(protocol.boss_id)
   	end
end

function BossCtrl:OnSCWorldBossInfoToAll(protocol)
	self.data:FlushWorldBossInfo(protocol)
	self.view:Flush("world_boss")
	self.world_boss_fight_view:Flush()
	local my_id = GameVoManager.Instance:GetMainRoleVo().role_id
    if my_id == protocol.killer_uid and protocol.killer_uid ~= 0 then
   		TipsCtrl.Instance:TipsGarrottingBossView(protocol.boss_id)
   	end
end

--进入Boss之家请求
function BossCtrl.SendEnterBossFamily(enter_type, scene_id, is_buy_dabao_times, boss_id)

	if not ActivityCtrl.Instance:CanNotFly() then
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSEnterBossFamily)
	protocol.enter_type = enter_type
	protocol.scene_id = scene_id or 0
	protocol.is_buy_dabao_times = is_buy_dabao_times or 0
	protocol.boss_id = boss_id or 0
	protocol:EncodeAndSend()
end

--boss之家操作
function BossCtrl.SendBossFamilyOperate(operate_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBossFamilyOperate)
	protocol.operate_type = operate_type or 0
	protocol.param_1 = param_1 or 1
	protocol:EncodeAndSend()
end

--请求boss信息
function BossCtrl.SendGetBossInfoReq(enter_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetBossInfoReq)
	protocol.enter_type = enter_type
	protocol:EncodeAndSend()
end

--请求跨服boss信息
function BossCtrl.SendCrossBossBossInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossBossBossInfoReq)
	protocol:EncodeAndSend()
end

--请求打宝，boss之家, 密窟,
function BossCtrl.SendBossKillerInfoReq(boss_type, boss_id, scene_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBossKillerInfoReq)
	protocol.boss_type = boss_type
	protocol.boss_id = boss_id
	protocol.scene_id = scene_id
	protocol:EncodeAndSend()
end

--请求世界boss击杀信息
function BossCtrl.SendWorldBossKillerInfoReq(boss_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossKillerInfoReq)
	protocol.boss_id = boss_id
	protocol:EncodeAndSend()
end

--请求关注信息(世界boss,密窟)
function BossCtrl.SendFollowBossReq(opera_type, boss_type, boss_id, scene_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFollowBossReq)
	protocol.opera_type = opera_type
	protocol.boss_type = boss_type
	protocol.boss_id = boss_id
	protocol.scene_id = scene_id
	protocol:EncodeAndSend()
end

--显示图标或打开界面的基本条件是否满足
function BossCtrl:CheckWelfareLimit(cur_flush_time, next_flush_time)
    if not OpenFunData.Instance:CheckIsHide("world_boss") then
        return false
    end

	--如果刷新时间相同,说明不是新的时间段刷新
	if next_flush_time == cur_flush_time then
		return false
	end

    local level = GameVoManager.Instance:GetMainRoleVo().level
    if level < BossData.FOCUS_WELFARE_LIMIT_LEVEL then
        return false
    end

    if not self.data:GetCanShowFocusTip() then
        return false
    end
    return true
end

--检测是否打开福利boss关注tips
function BossCtrl:CheckOpenWelfareTips(cur_flush_time, next_flush_time)
	if not self:CheckWelfareLimit(cur_flush_time, next_flush_time) then
		return
	end

	-- local ok_callback = function ()
 --        ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
 --    end

	if cur_flush_time ~= 0 then
		if not self.view:IsOpen() then
			ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
		end
		--TipsCtrl.Instance:OpenFocusBossTip(nil, ok_callback)
		return
	end
	 --如果cur_flush_time等于0,是刚上线服务端还没下发的情况
	local server_time = TimeCtrl.Instance:GetServerTime()
	if server_time > next_flush_time or server_time < next_flush_time then
		return
	end
	if not self.view:IsOpen() then
		ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
	end
    -- TipsCtrl.Instance:OpenFocusBossTip(nil, ok_callback)
end

--检测是否显示主界面福利boss图标
function BossCtrl:CheckShowMainWelfareIcon(cur_flush_time, next_flush_time)
	if not self:CheckWelfareLimit(cur_flush_time, next_flush_time) then
		return false
	end
	--有最新刷新时间
	if cur_flush_time ~= 0 then
		return true, 1800
	end

	local is_in_time, time = self.data:CheckMainWelfareBossTime(next_flush_time)
	if not is_in_time then
		return false
	end

	return true, time
end

function BossCtrl:WelfareBossIconCountDown(elapse_time, total_time)
	if elapse_time >= total_time then
		MainUICtrl.Instance:FlushView("flush_welfare_icon", {[1] = false})
	end
end

function BossCtrl:DaBaoFlushTurn()
	-- local dabao_view = self.view:GetDaBaoView()
	-- if dabao_view then
	-- 	dabao_view:FlushBossView()
	-- end
end

function BossCtrl:MikuFlushTurn()
	local miku_view = self.view:GetMiKuView()
	if miku_view then
		miku_view:FlushBossView()
	end
end

--密藏BOSS
function BossCtrl:OnBossTaskInfo(protocol)
	self.data:SetSecretTaskData(protocol)
	if self.secret_boss_fight_view:IsOpen() then
		self.secret_boss_fight_view:Flush()
	end
	if self.view:IsOpen() then
		self.view:Flush("secret_boss")
	end
end

function BossCtrl:OnPreciousBossInfo(protocol)
	self.data:SetSecretBossInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("secret_boss")
	end
	if self.secret_boss_fight_view:IsOpen() then
		self.secret_boss_fight_view:Flush()
	end
	if self.is_first then
		local boss_list,dead_list = self.data:GetSecretBossList()
		if #boss_list ~= #dead_list then
			self.data:SecretBossRedPointTimer(true)
		else
			self.data:SecretBossRedPointTimer(false)
		end
		self.is_first = false
	end
end

function BossCtrl:OnPreciousPosInfo(protocol)
	if self.kill_boss then
		self.secret_boss_fight_view:KillBoss(protocol.pos_x,protocol.pos_y)
	else
		self.data:SetTargetPos(protocol)
		self.secret_boss_fight_view:AutoDoTask()
	end
end

function BossCtrl:SendPosInfo(ctype, param, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPreciousPosReq)
	protocol.type = ctype or 0
	protocol.param = param or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

function BossCtrl:KillBoss(param)
	self.kill_boss = param
end

function BossCtrl:SetTimer()
	if not OpenFunData.Instance:CheckIsHide("secret_boss") or Scene.Instance:GetSceneType() ~= SceneType.Common then
		return
	end
	if self.boss_timer then
		return
	end
	local server_time = TimeCtrl.Instance:GetServerTime()
	self.boss_timer = GlobalTimerQuest:AddDelayTimer(function()
		local boss_list,dead_list = self.data:GetSecretBossList()
		if #boss_list ~= #dead_list then
			self.data:SecretBossRedPointTimer(true)
		else
			self.data:SecretBossRedPointTimer(false)
		end
		self:RemoveDelayBossTime()
	end,3600)
end

function BossCtrl:RemoveDelayBossTime()
	if self.boss_timer then
		GlobalTimerQuest:CancelQuest(self.boss_timer)
		self.boss_timer = nil
	end
end

local next_open_time = 0

function BossCtrl:SetOtherBossTips(boss_id, ok_callback, prefs_key, boss_type)
	-- 根据优先级排序，满足条件才进队列
	local next_time = self.data:GetRequireTime(boss_type)
	if next_time > TimeCtrl.Instance:GetServerTime() then
		return
	end
	if self.data:GetPriority() > boss_type then
		self.data:SetPriority(boss_type)
	end

	if next_open_time > TimeCtrl.Instance:GetServerTime() then
		return
	end

	local temp = {id = boss_id, ok = ok_callback, pre = prefs_key, typ = boss_type}
	self.data:SetRequireList(boss_type, temp)

	if nil == self.other_delay then
		self.other_delay = GlobalTimerQuest:AddDelayTimer(
			function()
				local _boss_type = self.data:GetPriority()
				local _next_time = self.data:GetRequireTime(_boss_type)
				if _next_time < TimeCtrl.Instance:GetServerTime() then
					local close_callback = function(cd)
						local diff = next_open_time - TimeCtrl.Instance:GetServerTime()
						if diff > 0 then
							self:RemoveDelayTime2()
							self.close_delay = GlobalTimerQuest:AddDelayTimer(
								function()
									self.data:SetRequireTime(_boss_type, TimeCtrl.Instance:GetServerTime() + cd)
									self.data:ReMoveRequireList(_boss_type)
									local next_boss = BossData.Instance:GetMaxPriorityInRequireList()
									if next_boss then
										self:SetOtherBossTips(next_boss.id, next_boss.ok, next_boss.pre, next_boss.typ)
									end
								end
							,diff)
						end
					end
					local boss_info = self.data:GetRequireList(_boss_type)
					if nil == boss_info then return end
					TipsCtrl.Instance:ShowOtherBossTip(boss_info, close_callback)
					next_open_time = TimeCtrl.Instance:GetServerTime() + 60
					self.data:SetRequireTime(_boss_type, TimeCtrl.Instance:GetServerTime() + 1800)
					self.data:ReMoveRequireList(_boss_type)
					self.data:SetPriority(100)
				end
				self:RemoveDelayTime()
			end
		, 3)
	end
end

function BossCtrl:RemoveDelayTime()
	if self.other_delay then
		GlobalTimerQuest:CancelQuest(self.other_delay)
		self.other_delay = nil
	end

end

function BossCtrl:RemoveDelayTime2()

	if self.close_delay then
		GlobalTimerQuest:CancelQuest(self.close_delay)
		self.close_delay = nil
	end
end

------------------ 宝宝Boss ------------------
function BossCtrl:SendBabyBossRequest(opera_type, param_0, param_1, reserve_sh)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBabyBossOperate)
	protocol.operate_type = opera_type
	protocol.param_0 = param_0 or 0
	protocol.param_1 = param_1 or 0
	protocol.reserve_sh = reserve_sh or 0
	protocol:EncodeAndSend()
end

function BossCtrl:OnBabyBossRoleInfo(protocol)
	self.data:SetBabyBossRoleInfo(protocol)

	if self.baby_boss_fight_view:IsOpen() then
		self.baby_boss_fight_view:Flush()
	end

	if self.view:IsOpen() then
		self.view:Flush("baby_boss")
	end
end

function BossCtrl:OnBabyBossAllInfo(protocol)
	self.data:SetBabyBossAllInfo(protocol)

	if self.baby_boss_fight_view:IsOpen() then
		self.baby_boss_fight_view:Flush()
	end

	if self.view:IsOpen() then
		self.view:Flush("baby_boss")
	end
end

function BossCtrl:OnBabyBossSingleInfo(protocol)
	self.data:SetBabyBossSingleInfo(protocol)

	if self.baby_boss_fight_view:IsOpen() then
		self.baby_boss_fight_view:Flush()
	end

	if self.view:IsOpen() then
		self.view:Flush("baby_boss")
	end
end

function BossCtrl:CloseBabyBossInfoView()
	if self.baby_boss_fight_view:IsOpen() then
		self.baby_boss_fight_view:Close()
	end
end

------------------ 奇遇boss ------------------
function BossCtrl:SendJingLingAdvantageBossEnter(boss_id, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSJingLingAdvantageBossEnter)
	protocol.enter_bossid = boss_id
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end

function BossCtrl:OnEncounterBossInfo(protocol)
	local boss_id = protocol.boss_id

	function ok_callback()
		self:SendJingLingAdvantageBossEnter(boss_id)
	end
	self.data:SetEncounterBossData(boss_id, ok_callback)
	TipsCtrl.Instance:ShowEncounterBossFocusTip()
end

function BossCtrl:OnEncounterBossEnterTimesChange(time)
	self.data:SetEncounterBossEnterTimes(time)
end
-------------------------------------------------

function BossCtrl:RequestDropLog()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetDropLog)
	protocol:EncodeAndSend()
end

function BossCtrl:OnDropLogRet(protocol)
	self.data:SetDropLog(protocol.log_list)
	if self.view:IsOpen() then
		self.view:Flush("drop")
	end
end

--管理自动关注
function BossCtrl:AutoFocusManager()
	local miku_boss_focus_list = self.data:GetMiKuBossAutoFocusList()
	for k, v in ipairs(miku_boss_focus_list) do
		BossCtrl.SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, v.boss_id, v.scene_id)
	end

	local boss_family_focus_list = self.data:GetBossFamilyAutoFocusList()
	for k, v in ipairs(boss_family_focus_list) do
		BossCtrl.SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, v.boss_id, v.scene_id)
	end
end

-- 返回活跃boss伤害排名信息
function BossCtrl:OnActiveBossHurtRankInfo(protocol)
	self.data:SetActiveBossHurtInfo(protocol)
	if self.active_fam_fight_view:IsOpen() then
		self.active_fam_fight_view:Flush()
	end
end