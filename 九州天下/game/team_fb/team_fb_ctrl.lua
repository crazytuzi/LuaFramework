require("game/team_fb/team_fb_data")
require("game/team_fb/team_fb_towerselect_view")
require("game/team_fb/team_fb_towerskill_view")
require("game/team_fb/team_fb_content")
require("game/team_fb/team_fb_info")

-- 组队副本Ctrl
TeamFbCtrl = TeamFbCtrl or BaseClass(BaseController)

function TeamFbCtrl:__init()
	if TeamFbCtrl.Instance then
		print_error("[TeamFbCtrl]:Attempt to create singleton twice!")
	end
	TeamFbCtrl.Instance = self
	self.data = TeamFbData.New()

	self.tower = TowerSelectView.New(ViewName.TowerSelectView)			--组队界面技能选择
	self.tower_skill = TowerSkillView.New(ViewName.TowerSkillView)
	self.team_tower = TeamFuBenInfoView.New(ViewName.TeamFuBenInfoView)
	self:RegisterAllProtocols()
	-- ViewManager.Instance:Open(ViewName.TowerSelectView)
end

function TeamFbCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
	self.tower:DeleteMe()
	self.tower = nil
	self.tower_skill:DeleteMe()
	self.tower_skill = nil
	if self.team_tower then
		self.team_tower:DeleteMe()
		self.team_tower = nil
	end
	TeamFbCtrl.Instance = nil

end

function TeamFbCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTeamFBUserInfo, "SCTeamFBUserInfo")  						--返回是否第一次進入副本
	self:RegisterProtocol(SCTeamTowerDefendInfo, "OnTeamTowerDefendInfo")				--组队塔防信息
	self:RegisterProtocol(SCTeamTowerDefendAttrType, "OnTeamTowerDefendAttrType")  		--组队塔防加成属性类型
	self:RegisterProtocol(SCTeamTowerDefendSkill, "OnTeamTowerDefendSkill")				--组队释放技能
	self:RegisterProtocol(SCEquipFBInfo,"OnSCEquipFBInfo")
end

function TeamFbCtrl:OnTeamTowerDefendInfo(protocol)
	self.data:TeamTowerInfo(protocol)
	self.team_tower:Flush()
	self.tower_skill:Flush()
end

function TeamFbCtrl:OnTeamTowerDefendAttrType(protocol)
	self.data:TeamTowerDefendAttrType(protocol)
	FuBenCtrl.Instance:FlushFbViewByParam("team")
end

function TeamFbCtrl:SendTeamTowerDefendSetAttrType(uid, attr_type) 						--请求设置组队塔防加成属性类型
	local protocol = ProtocolPool.Instance:GetProtocol(CSTeamTowerDefendSetAttrType)
	protocol.uid = uid or 0
	protocol.attr_type = attr_type or 0
	protocol:EncodeAndSend()

end

function TeamFbCtrl:SCFBInfo(type,protocol)
	TeamFbData.Instance:SetTeamFBInfo(type,protocol)
	if self.fb_info_callback then
		self.fb_info_callback()
	end
	RemindManager.Instance:Fire(RemindName.FuBenPeople)
end

function TeamFbCtrl:SetInfoCallBack(func)
	self.fb_info_callback = func
end

function TeamFbCtrl:SCTeamFBUserInfo(protocol)
	self.data:IsFirstEnter(protocol)
end

function TeamFbCtrl:OnTeamTowerDefendSkill(protocol)
	self.data:SetTeamTowerDefendSkill(protocol)
	ViewManager.Instance:FlushView(ViewName.TowerSkillView, "CD")
end

function TeamFbCtrl:OnFlushTeamFBContent()
	if self.tower:IsOpenView() then
		self.tower:SetPos()
	end
end

function TeamFbCtrl:OnSCEquipFBInfo(protocol)
	self.data:SetEquipInfo(protocol)
	FuBenCtrl.Instance:FlushManyPeopleRewardView()
end

function TeamFbCtrl:SedReqEquipInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipFBGetInfo)
	protocol.operate_type = 0
	protocol:EncodeAndSend()
end