require("scripts/game/boss_sport/boss_sport_data")
require("scripts/game/boss_sport/boss_sport_view")

BossSportCtrl = BossSportCtrl or BaseClass(BaseController)

function BossSportCtrl:__init()
	if	BossSportCtrl.Instance then
		ErrorLog("[BossSportCtrl]:Attempt to create singleton twice!")
	end
	BossSportCtrl.Instance = self

	self.data = BossSportData.New()
	self.view = BossSportView.New(ViewName.BossSportView)
	self:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
	self.pass_day_evt = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnPassDay, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.BossPersonal, true, 1)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.EquipBoss, true, 1)
end

function BossSportCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.invite_enter_team_alert ~= nil then
		self.invite_enter_team_alert:DeleteMe()
		self.invite_enter_team_alert = nil 
	end

	BossSportCtrl.Instance = nil
end

function BossSportCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.BossPersonal then
		return self.data:GetCankillPersonalBoss()
	elseif remind_name == RemindName.EquipBoss then
		self.data:CheckReqEqBossData()
		return self.data:GetEquipBossRemind()
	end
end

function BossSportCtrl:RecvMainRoleInfo()
	self:SendPersonalBossDataReq()
	self:EquipBossReq(1, 0)
end

function BossSportCtrl:OnPassDay()
	self:EquipBossReq(1, 0)
end

---------------------------------------
-- 下发
---------------------------------------
function BossSportCtrl:RegisterAllProtocols()
	-- 个人boss
	self:RegisterProtocol(SCPersonalBossData, "OnPersonalBossData")
	-- 装备Boss
	self:RegisterProtocol(SCEquipBossDataIss, "OnEquipBossDataIss")
	-- 团队Boss
	self:RegisterProtocol(SCGetPlayerAllEnterFuBenTime, "OnGetPlayerAllEnterFuBenTime")
	self:RegisterProtocol(SCGetCurAllFubenTeamList, "OnGetCurAllFubenTeamList")
	self:RegisterProtocol(SCMyTeamFubenData, "OnMyTeamFubenData")
	self:RegisterProtocol(SCPlayerHadJoinTeam, "OnPlayerHadJoinTeam")
	self:RegisterProtocol(SCHadBeExitTeam, "OnHadBeExitTeam")
	self:RegisterProtocol(SCGetInvateByFuBenTeam, "OnGetInvateByFuBenTeam")
	self:RegisterProtocol(SCAutoExitTeam, "OnAutoExitTeam")
end

function BossSportCtrl:OnPersonalBossData(protocol)
	self.data:SetSportBossInfoData(protocol)
	RemindManager.Instance:DoRemind(RemindName.BossPersonal)
	self.view:Flush(TabIndex.boss_fuben_personal)
end

function BossSportCtrl:OnEquipBossDataIss(protocol)
	self.data:SetEquipBossSportData(protocol)
	GlobalEventSystem:Fire(EquipBossEvent.EQUIP_BOSS_DATA_CHANGE)
end

--团队Boss
function BossSportCtrl:OnGetPlayerAllEnterFuBenTime(protocol)
	self.data:SetGetPlayerAllEnterFuBenTime(protocol)
	self.view:Flush(TabIndex.boss_fuben_team)
end

function BossSportCtrl:OnGetCurAllFubenTeamList(protocol)
	self.data:SetCurAllFubenTeamList(protocol)
	self.view:Flush(TabIndex.boss_fuben_team)
end

function BossSportCtrl:OnMyTeamFubenData(protocol)
	self.data:SetMyTeamListData(protocol)
	self.view:Flush(TabIndex.boss_fuben_team)
end

function BossSportCtrl:OnPlayerHadJoinTeam(protocol)
	self.data:SetHadJionTeamData(protocol)
	self.view:Flush(TabIndex.boss_fuben_team)
end

function BossSportCtrl:OnAutoExitTeam(protocol)
	self:LevelTeamSendInfo()
end

function BossSportCtrl:LevelTeamSendInfo()
	self.data:SetTeamID(0)
	local _, fuben_id = self.data:GetMyData()
	if fuben_id ~= 0 then
		BossSportCtrl.Instance:ReqFubenData(fuben_id)
	end
	self.view:Flush(TabIndex.boss_fuben_team)
end

function BossSportCtrl:OnHadBeExitTeam(protocol)
	self:LevelTeamSendInfo()
end

function BossSportCtrl:OnGetInvateByFuBenTeam(protocol)
	self.had_num = 1
	self:CheckBossInviteTip(protocol)
end

function BossSportCtrl:CheckBossInviteTip(protocol)
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.TEAM, self.had_num, function ()
		self.invite_enter_team_alert = self.invite_enter_team_alert or Alert.New()
		local content = string.format(Language.Boss.InvateInfo, protocol.invate_palyer_name, protocol.invate_team_name)
		self.invite_enter_team_alert:SetLableString(content)
		self.invite_enter_team_alert:SetOkFunc(function ()
			BossSportCtrl.Instance:ReqJoinFubenTeam(1, protocol.team_id)
		end)
		self.invite_enter_team_alert:SetShowCheckBox(false)
		self.invite_enter_team_alert:Open()
		self.had_num = 0
		self:CheckBossInviteTip(protocol)
	end)
end
---------------------------------------
-- 请求
---------------------------------------

function BossSportCtrl:SendBossDataReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetAllBossInfoRefesh)
	protocol:EncodeAndSend()
end

function BossSportCtrl:SendPersonalBossDataReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqPersonalBossData)
	protocol:EncodeAndSend()
end

--请求装备Boss
function BossSportCtrl:EquipBossReq(oper_type, fb_idx)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipBossReq)
	protocol.oper_type = oper_type
	protocol.fb_idx = fb_idx or 0
	protocol:EncodeAndSend()
end

--打开面板
function BossSportCtrl:OpenPersonalBossTip(index, data, bool)
	if self.boss_personal_tip == nil then
		self.boss_personal_tip = PersonalBossTipView.New()
	end
	self.boss_personal_tip:Open()
	self.boss_personal_tip:SetData(index, data, bool)
end

-- --团队Boss 
--(c->s)[团队副本]请求玩家的团队副本数据
function BossSportCtrl:ReqPlayerFubenData()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqPlayerAllEnterFuBenTimes)
	protocol:EncodeAndSend()
end

--(c->s)[团队副本]请求某副本的所有队伍数据
function BossSportCtrl:ReqFubenData(fuben_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqSigleFuBenAllTeamData)
	protocol.fuben_id = fuben_id 
	protocol:EncodeAndSend()
end

--(c->s)[团队副本]创建某副本的队伍
function BossSportCtrl:CreateFubenTeam(fuben_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqCreateSigleFubenTeam)
	protocol.fuben_id = fuben_id 
	protocol:EncodeAndSend()
end

--(c->s)[团队副本]队长开启团队副本
function BossSportCtrl:LeaderReqOpenFuben()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqTeamLeaderOpenFuben)
	protocol:EncodeAndSend()
end

--(c->s)[团队副本]加入某副本的队伍
function BossSportCtrl:ReqJoinFubenTeam(join_type, team_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqJoinSigleFubenTeam)
	protocol.join_type = join_type
	protocol.team_id = team_id
	protocol:EncodeAndSend()
end

--(c->s)[团队副本]本人退出副本队伍
function BossSportCtrl:ReqExitFubenTeam(team_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqExitSigleFubenTeam)
	protocol.team_id = team_id
	protocol:EncodeAndSend()
end

--(c->s)[团队副本]队长把某成员踢出副本队伍
function BossSportCtrl:ReqLeaderExitMemberSigleFubenTeam(member_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqLeaderExitMemberSigleFubenTeam)
	protocol.member_id = member_id
	protocol:EncodeAndSend()
end

--(c->s)[团队副本]队长邀请某玩家加入副本队伍
function BossSportCtrl:ReqLeaderInvateMemberSigleFubenTeam(member_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqLeaderInvateMemberSigleFubenTeam)
	protocol.member_name = member_name
	protocol:EncodeAndSend()
end

function BossSportCtrl:ReqTeamLeaderRecruitMember()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqTeamLeaderRecruitMember)
	protocol:EncodeAndSend()
end