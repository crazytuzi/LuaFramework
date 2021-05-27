require("scripts/game/boss/boss_data")
require("scripts/game/boss/boss_refresh_remind_view")

BossCtrl = BossCtrl or BaseClass(BaseController)

function BossCtrl:__init()
	if	BossCtrl.Instance then
		ErrorLog("[BossCtrl]:Attempt to create singleton twice!")
	end
	BossCtrl.Instance = self

	self.data = BossData.New()
	self.boss_remind_view = BossRefreshRemindView.New(ViewDef.BossRefreshRemind)
	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))

end

function BossCtrl:__delete()
	self.boss_remind_view:DeleteMe()
	self.boss_remind_view = nil
	self.data:DeleteMe()
	self.data = nil
	BossCtrl.Instance = nil
end

function BossCtrl:RecvMainInfoCallBack()
	SecretBossData.Instance:SetRemindBossDataList()
end

---------------------------------------
-- 下发
---------------------------------------
function BossCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBossInfo, "OnBossInfo")
	self:RegisterProtocol(SCAllTypeBossFlagInfo, "OnAllTypeBossFlagInfo")
	self:RegisterProtocol(SCBossDie, "OnBossDie") -- boss死户接收
end

-- 全服公共boss信息
function BossCtrl:OnBossInfo(protocol)
	self.data:SetSceneBossList(protocol.boss_list)
end

-- boss死亡接收(139, 204)
function BossCtrl:OnBossDie(protocol)
	self.data:SetBossDie(protocol)
end

function BossCtrl:OnAllTypeBossFlagInfo(protocol)
	self.data:SetAllRemindFlag(protocol.flag_list)
end

-- 配置:ModBossTips
function BossCtrl.CSChuanSongBossScene(boss_type, boss_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetInBossSceneReq)
	protocol.boss_type = boss_type
	protocol.boss_id = boss_id
	protocol:EncodeAndSend()
end

function BossCtrl.SetOneTypeBossRemindFlag(type, value)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetOneTypeBossRemindFlag)
	protocol.type = type
	protocol.value = value
	protocol:EncodeAndSend()
end

--==============================--
--		旧代码
--==============================--
-- 副本boss信息
function BossCtrl:OnFubenBossInfo(protocol)
	self.data:SetSceneBossList(protocol.boss_list)
end

function BossCtrl:OnActSoulResult(protocol)
	if protocol.result == 0 then
		self.view:Flush(0, "act_soul_success")
	else
		BossCtrl.ActSoulReqList = {}
	end
end

function BossCtrl:OnSCSkyBossKillCount(protocol)
	self.data:SetSkyBossKillCount(protocol)
	self.view:Flush(TabIndex.boss_sky, "boss_info")
end

function BossCtrl:OnSkyBossAwake(protocol)
	if IS_ON_CROSSSERVER then
		return
	end

	if protocol.is_sky_boss == 0 then
		self.boss_awake_dlg:Open()
		self.boss_awake_dlg:Flush(0, "all", {boss_id = protocol.boss_id})
	elseif protocol.is_sky_boss == 1 then
		self.boss_chiyou_dlg:Open()
		self.boss_chiyou_dlg:Flush(0, "all", {boss_id = protocol.boss_id})
	elseif protocol.is_sky_boss == 2 then
		self.boss_holy_beast:Open()
		self.boss_holy_beast:Flush(0, "all", {boss_id = protocol.boss_id})
	end
end

function BossCtrl:OnDevildomFamIntegral(protocol)
	self.data:SetDevildomFamIntegral(protocol)
	self.view:Flush(TabIndex.boss_mijing)
end

function BossCtrl:OnGoBackTown(protocol)
	GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE)
	GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.LEFT)
end

function BossCtrl:OnEnterDevildomFam(protocol)
	ViewManager.Instance:Close(ViewName.Boss)
	FubenCtrl.Instance:SetFamTaskFollow()
end

function BossCtrl:OnFeixuInfo(protocol)
	self.data:SetFeixuInfo(protocol)
	self.view:Flush(TabIndex.boss_feixu)

	if MainuiCtrl.Instance:GetTaskGuideName() == MainuiTask.GUIDE_NAME.FEIXU then
		GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE, self.data:GetFeixuGuideData())
	end
end

function BossCtrl:OnOutFeixu(protocol)
	GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE)
	GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.LEFT)
end

function BossCtrl:OnEnterFeixu(protocol)
	ViewManager.Instance:Close(ViewName.Boss)
	GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE, self.data:GetFeixuGuideData())
	GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.RIGHT)
end

---------------------------------------
-- 请求
---------------------------------------
function BossCtrl:GetSkyBossKillCount(boss_id)
	local last_time = self.kill_count_delay[boss_id] and self.kill_count_delay[boss_id] or 0
	local diff = NOW_TIME - last_time
	if diff < 2 then return end 	-- 请求延迟

	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSkyBossKillCount)
	protocol.boss_id = boss_id
	protocol:EncodeAndSend()

	self.kill_count_delay[boss_id] = NOW_TIME
end

function BossCtrl.KillSkyBossReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSKillSkyBoss)
	protocol:EncodeAndSend()
end

function BossCtrl.KillChiyouReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSKillChiyouReq)
	protocol:EncodeAndSend()
end

function BossCtrl.DevildomFamReq(fam_level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDevildomFam)
	protocol.fam_level = fam_level
	protocol:EncodeAndSend()
end

function BossCtrl.BuyDevildomFamIntegralReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyDevildomFamIntegral)
	protocol:EncodeAndSend()
end

function BossCtrl.GetDevildomFamIntegralReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetDevildomFamIntegral)
	protocol:EncodeAndSend()
end

function BossCtrl.BuyFamIntegralCostReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyFamIntegralCost)
	protocol:EncodeAndSend()
end

function BossCtrl.GoBackTownReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGoBackTown)
	protocol:EncodeAndSend()
end

function BossCtrl.EnterFeixuReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSEnterFeixuReq)
	protocol:EncodeAndSend()
end

function BossCtrl.SentBuyFeixuValueReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBugFeixuValReq)
	protocol:EncodeAndSend()
end

function BossCtrl.SentFeixuInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSFeixuInfoReq)
	protocol:EncodeAndSend()
end

function BossCtrl.SentOutFeixuReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOutFeixuReq)
	protocol:EncodeAndSend()
end