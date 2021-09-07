require("game/boss/boss_view")
require("game/boss/boss_data")
require("game/boss/kf_boss_data")
require("game/boss/world_boss_fight_view")
require("game/boss/kf_boss_info")
require("game/boss/dabao_fam_fight_view")
require("game/boss/boss_family_fight_view")
require("game/boss/active_fam_fight_view")

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
	self.world_boss_fight_view = WorldBossFightView.New()
	self.dabao_fam_fight_view = DabaoFamFightView.New(ViewName.DabaoBossInfoView)
	self.active_fam_fight_view = ActiveFamFightView.New(ViewName.ActiveBossInfoView)
	self.boss_family_fight_view = BossFamilyFightView.New(ViewName.BossFamilyInfoView)

	self.kf_boss_info_view = KfBossInfoView.New()

	RemindManager.Instance:Register(RemindName.BossWelfareRemind, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.BossWelfareRemind))
	RemindManager.Instance:Register(RemindName.BossFamilyRemind, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.BossFamilyRemind))
end

function BossCtrl:GetView()
	return self.view
end

function BossCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
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

	if self.kf_boss_info_view ~= nil then
		self.kf_boss_info_view:DeleteMe()
		self.kf_boss_info_view = nil
	end

	if self.active_fam_fight_view ~= nil then
		self.active_fam_fight_view:DeleteMe()
		self.active_fam_fight_view = nil
	end

	if self.scene_loaded then
		GlobalEventSystem:UnBind(self.scene_loaded)
		self.scene_loaded = nil
	end

	RemindManager.Instance:UnRegister(RemindName.BossWelfareRemind)
	RemindManager.Instance:UnRegister(RemindName.BossFamilyRemind)
	BossCtrl.Instance = nil
end

function BossCtrl:RegisterAllProtocols()
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
	self:RegisterProtocol(SCBossRoleInfo, "OnSCBossRoleInfo")			--秘窟疲劳值信息
	self:RegisterProtocol(SCDabaoBossNextFlushInfo, "OnSCDabaoBossNextFlushInfo")			--秘窟疲劳值信息
	self:RegisterProtocol(SCBossInfoToAll, "OnSCBossInfoToAll")				--所有boss信息
	self:RegisterProtocol(SCWorldBossInfoToAll, "OnSCWorldBossInfoToAll")	--广播世界boss信息
	self:RegisterProtocol(SCBossKillerList, "OnSCBossKillerList")			--击杀boss信息
	self:RegisterProtocol(SCWorldBossKillerList, "OnSCWorldBossKillerList")				--击杀世界boss信息
	self:RegisterProtocol(SCFollowBossInfo, "OnSCFollowBossInfo")				--boss关注列表信息
	self:RegisterProtocol(SCWorldBossWearyInfo, "SCWorldBossWearyInfo")				--boss疲劳值复活信息
	self:RegisterProtocol(SCActiveBossNextFlushInfo, "OnSCActiveBossNextFlushInfo")				--活跃boss刷新时间信息
	self:RegisterProtocol(SCActiveBossInfo, "OnActiveBossInfo")				--活跃boss信息
	self:RegisterProtocol(SCNeutralBossInfo, "OnNeutralBossInfo")			--中立boss信息

	---------------跨服BOSS-----------------------------
	self:RegisterProtocol(SCCrossBossPlayerInfo, "OnCrossBossPlayerInfo")				--跨服BOSS玩家信息
	self:RegisterProtocol(SCCrossBossSceneBossInfo, "OnCrossBossSceneBossInfo")		--跨服boss场景里的boss列表
	self:RegisterProtocol(SCServerShutdownNotify, "OnServerShutdownNotify")				--服务器即将关闭通知
	self:RegisterProtocol(SCCrossBossBossInfoAck, "OnCrossBossBossInfoAck")				--跨服boss信息

	self:RegisterProtocol(CSCrossBossBuyReliveTimes)					--跨服BOSS购买复活次数
	---------------跨服BOSS end--------------------------

	self:RegisterProtocol(SCBossDpsFlag, "OnBossDpsInfo")
	self:RegisterProtocol(SCBossFirstHurtInfo, "OnBossFirstHurtInfo")
	self:RegisterProtocol(SCMonsterFirstHitInfo, "OnMonsterFirstHitInfo")
	self:RegisterProtocol(SCCommonActivityInfo, "OnCommonActivityInfo")			--世界BOSS活动信息
	self:RegisterProtocol(SCWorldBossDropRecord, "OnWorldBossDropRecord")		--boss击杀掉落信息


	--------------宝宝BOSS ----------------------------------------
	self:RegisterProtocol(CSBabyBossOperate)
	self:RegisterProtocol(SCSingleBabyBossInfo, "OnSCSingleBabyBossInfo")
	self:RegisterProtocol(SCBabyBossRoleInfo, "OnSCBabyBossRoleInfo")
	self:RegisterProtocol(SCAllBabyBossInfo, "OnSCAllBabyBossInfo")
end

function BossCtrl:OnBossDpsInfo(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)

	if obj then
		obj:SetAttr("top_dps_flag", protocol.top_dps_flag)
	end
end

function BossCtrl:OnBossFirstHurtInfo(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)

	if obj then
		obj:SetAttr("first_hurt_flag", protocol.first_hurt_flag)
	end
end

--boss掉落归属信息
function BossCtrl:OnMonsterFirstHitInfo(protocol)
	if self.scene_loaded then
		GlobalEventSystem:UnBind(self.scene_loaded)
		self.scene_loaded = nil
	end
	if MainUICtrl.Instance.view.target_view then
		MainUICtrl.Instance.view.target_view:OnFirstHurtChange(protocol.is_show, protocol.first_hit_user_name)
	else
		self.scene_loaded = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnSceneLoaded, self, protocol.is_show, protocol.first_hit_user_name))
	end
end

function BossCtrl:OnSceneLoaded(is_show, name)
	MainUICtrl.Instance.view.target_view:OnFirstHurtChange(is_show, name)
end

 --获取BOSS信息
function BossCtrl:SendGetWorldBossInfo(boss_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetWorldBossInfo)
	protocol.boss_type = boss_type
	protocol:EncodeAndSend()
end

--下发世界boss信息
function BossCtrl:OnWorldBossInfo(protocol)
	self.data:SetBossInfo(protocol)
	self.view:Flush("world_boss")
	self.world_boss_fight_view:Flush()
	RemindManager.Instance:Fire(RemindName.BossWelfareRemind)
end

-- boss出生
function BossCtrl:OnWorldBossBorn(protocol)
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
		self.view:Flush("world_boss")
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

--玩家请求进入世界BOSS地图
function BossCtrl:SendEnterBossWorld(opera_type, boss_id)
	if opera_type ~= nil and opera_type == BossData.WORLD_BOSS_ENTER_TYPE.WORLD_BOSS_ENTER and not self.data:CheckIsCanEnterFuLi() then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NeedLeaveScene)
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldBossOperaReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = boss_id or 0
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
	if self.kf_boss_info_view:IsOpen() then
		self.kf_boss_info_view:Flush()
	end
end

function BossCtrl:OnServerShutdownNotify(protocol)
	self.kf_boss_data:SetServerShutdown(protocol.remain_second)
end

function BossCtrl:OnCrossBossBossInfoAck(protocol)
	self.kf_boss_data:OnCrossBossBossInfoAck(protocol)
end

function BossCtrl:OnSCBossKillerList(protocol)
	TipsCtrl.Instance:OpenKillBossTip(protocol.killer_info_list)
end

function BossCtrl:OnSCWorldBossKillerList(protocol)
	TipsCtrl.Instance:OpenKillBossTip(protocol.killer_info_list)
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
	self.kf_boss_info_view:Open()
	self.kf_boss_info_view:Flush()
end

function BossCtrl:CloseKfBossInfoView()
	self.kf_boss_info_view:Close()
end

function BossCtrl:OnDabaoBossInfo(protocol)
	self.data:SetDabaoBossInfo(protocol)
	self.view:Flush("dabao_boss")
	self.dabao_fam_fight_view:Flush()
end

function BossCtrl:OnActiveBossInfo(protocol)
	self.data:SetActiveBossInfo(protocol)
	self.view:Flush("active_boss")
	self.active_fam_fight_view:Flush()
end

function BossCtrl:OnFamilyBossInfo(protocol)
	self.data:SetFamilyBossInfo(protocol)
	self.view:Flush("boss_family_index")
	self.boss_family_fight_view:Flush("boss_family")
	RemindManager.Instance:Fire(RemindName.BossFamilyRemind)
end

function BossCtrl:OnMikuBossInfo(protocol)
	self.data:SetMikuBossInfo(protocol)
	-- self.data:CheckRedPoint()
	self.view:Flush("miku_boss")
	self.boss_family_fight_view:Flush("miku_boss")
end

function BossCtrl:OnNeutralBossInfo(protocol)
	self.data:SetNeutralBossInfo(protocol)
	self.view:Flush("neutral_boss")
	self.boss_family_fight_view:Flush("neutral_boss")
end

function BossCtrl:OnSCBossRoleInfo(protocol)
	self.data:SetMikuPiLaoInfo(protocol)
end

function BossCtrl:OnSCDabaoBossNextFlushInfo(protocol)
	self.data:OnSCDabaoBossNextFlushInfo(protocol)
	self.dabao_fam_fight_view:Flush()
end

function BossCtrl:OnSCActiveBossNextFlushInfo(protocol)
	self.data:OnSCActiveBossNextFlushInfo(protocol)
	self.active_fam_fight_view:Flush()
end

function BossCtrl:OnSCBossInfoToAll(protocol)
	self.data:OnSCBossInfoToAll(protocol)
	if protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
     	self.view:Flush("boss_family_index")
     	self.boss_family_fight_view:Flush("boss_family")
     	self.data:CalToRemind()
     	RemindManager.Instance:Fire(RemindName.BossFamilyRemind)
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
    	local role_vo_camp = GameVoManager.Instance:GetMainRoleVo().camp
    	if role_vo_camp == protocol.camp_type then
	    	self.view:Flush("miku_boss")
	    	self.boss_family_fight_view:Flush("miku_boss")
	    	self.data:CalToRemind()
	    end
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
    	self.data:FlushDaBaoFlushInfo(protocol)
    	self.view:Flush("dabao_boss")
    	self.dabao_fam_fight_view:Flush()
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_WORLD then
    	self.view:Flush("world_boss")
		self.world_boss_fight_view:Flush()
		RemindManager.Instance:Fire(RemindName.BossWelfareRemind)
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
    	self.data:FlushActiveFlushInfo(protocol)
    	self.view:Flush("active_boss")
    	self.active_fam_fight_view:Flush()
    elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL then
    	self.view:Flush("neutral_boss")
    	self.boss_family_fight_view:Flush("neutral_boss")
    	self.data:CalToRemind()
    end
end

function BossCtrl:OnSCWorldBossInfoToAll(protocol)
	self.data:FlushWorldBossInfo(protocol)
	self.view:Flush("world_boss")
	self.world_boss_fight_view:Flush()
	RemindManager.Instance:Fire(RemindName.BossWelfareRemind)
end

--进入Boss之家请求
function BossCtrl.SendEnterBossFamily(enter_type, scene_id, is_buy_dabao_times, boss_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEnterBossFamily)
	protocol.enter_type = enter_type
	protocol.scene_id = scene_id or 0
	protocol.is_buy_dabao_times = is_buy_dabao_times or 0
	protocol.boss_id = boss_id or 0
	protocol:EncodeAndSend()
end

--请求boss信息
function BossCtrl:SendGetBossInfoReq(enter_type)
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

function BossCtrl:GetBossFamilyFightView()
	if nil ~= self.boss_family_fight_view then
		return self.boss_family_fight_view
	end
end

function BossCtrl:GetBossWorldFightView()
	if nil ~= self.world_boss_fight_view then
		return self.world_boss_fight_view
	end
end

--福利boss
function BossCtrl:OnCommonActivityInfo(protocol)
	self.data:SetCommonActivityInfo(protocol)
	if protocol.common_activity_type == COMMON_ACTIVITY_TYPE.COMMON_ACTIVITY_TYPE_WORLD_BOSS then
		MainUICtrl.Instance:FlushView("world_boss")
	end
	RemindManager.Instance:Fire(RemindName.BossWelfareRemind)
end

-- 申请boss击杀掉落信息
function BossCtrl:SendBossKillDropInfo(operate_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSReqCommonOpreate)
	send_protocol.operate_type = operate_type
	send_protocol:EncodeAndSend()
end

-- boss击杀掉落信息返回
function BossCtrl:OnWorldBossDropRecord(protocol)
	TipsCtrl.Instance:OpenKillBossDropTip(protocol.drop_record)
end

function BossCtrl:GetGemChangeRemind(remind_type)
	local flag = 0
	if remind_type == RemindName.BossWelfareRemind then
		if OpenFunData.Instance:CheckIsHide("world_boss") and self.data:GetWelfareRedPoint() then
			flag = 1
		end
	elseif remind_type == RemindName.BossFamilyRemind then
		if OpenFunData.Instance:CheckIsHide("vip_boss") and self.data:GetFamilyRedPoint() then
			flag = 1
		end
	end
	return flag
end


----------------------宝宝boss--------------------------
function BossCtrl.SendBabyBossOpera(opera_type, param_0, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBabyBossOperate)
	protocol.operate_type = opera_type or 0
	protocol.param_0 = param_0 or 0
	protocol.param_1 = param_1 or 0

	protocol:EncodeAndSend()
end

function BossCtrl:OnSCBabyBossRoleInfo(protocol)
	self.data:SetBossBabyRoleInfo(protocol)

	if self.view:IsOpen() then
		self.view:Flush("baby_boss_role_info")
	end
end

function BossCtrl:OnSCAllBabyBossInfo(protocol)
	self.data:SetBossBabyAllInfo(protocol)

	if self.view:IsOpen() then
		self.view:Flush("baby_boss")
	end
end

function BossCtrl:OnSCSingleBabyBossInfo(protocol)
	self.data:SetBossBabyInfo(protocol)

	if self.view:IsOpen() then
		self.view:Flush("baby_boss")
	end
end