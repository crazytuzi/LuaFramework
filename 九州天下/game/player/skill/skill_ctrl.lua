require("game/player/skill/skill_data")

--------------------------------------------------------------
--技能相关
--------------------------------------------------------------
SkillCtrl = SkillCtrl or BaseClass(BaseController)
function SkillCtrl:__init()
	if SkillCtrl.Instance then
		print_error("[SkillCtrl] Attemp to create a singleton twice !")
	end
	SkillCtrl.Instance = self

	self.skill_data = SkillData.New()

	self:RegisterAllProtocols()

	self.is_first_enter = true
end

function SkillCtrl:__delete()
	SkillCtrl.Instance = nil

	self.skill_data:DeleteMe()
	self.skill_data = nil

	RemindManager.Instance:UnRegister(RemindName.SkillActive)
	RemindManager.Instance:UnRegister(RemindName.SkillPassive)

	self.is_first_enter = false
end

function SkillCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSkillListInfoAck, "OnSkillListInfoAck")
	self:RegisterProtocol(SCSkillInfoAck, "OnSkillInfoAck")
	self:RegisterProtocol(SCSkillOtherSkillInfo, "OnSkillOtherSkillInfo")

	self:RegisterProtocol(SCUpGradeSkillInfo, "OnUpGradeSkillInfo")		-- 进阶装备技能改变

	self:RegisterProtocol(CSRoleSkillLearnReq)

	--战场变身
	self:RegisterProtocol(CSBianshenOnDieReq)
	self:RegisterProtocol(SCBianshenInfo, "OnSCBianshenInfo")

	RemindManager.Instance:Register(RemindName.SkillActive, BindTool.Bind(self.SkillActiveRemind, self))
	RemindManager.Instance:Register(RemindName.SkillPassive, BindTool.Bind(self.SkillPassiveRemind, self))
end

function SkillCtrl:OnSkillListInfoAck(protocol)
	local is_change = false
	local is_has_war = false
	local war_scene_cfg = self.skill_data:GetWarSceneCfg()
	for k,v in pairs(war_scene_cfg) do
		if v and self.skill_data:GetSkillInfoById(v.skill_id) ~= nil then
			is_has_war = true
			break
		end
	end

	if protocol.active_skill_add then
		self.skill_data:SetSkillExperLevel(protocol.active_skill_add)
	end

	local new_has_war = false
	for k,v in pairs(protocol.skill_list) do
		if v ~= nil and self.skill_data:CheckIsWarSceneSkill(v.skill_id) then
			new_has_war = true
			break
		end
	end

	is_change = is_has_war ~= new_has_war

	if not self.is_first_enter or not IS_AUDIT_VERSION then
		self.skill_data:CheckIsNew(protocol.skill_list, protocol.is_init)
	end
	self.skill_data:SetDefaultSkillIndex(protocol.default_skill_index)
	self.skill_data:SetSkillList(protocol.skill_list)
	GlobalEventSystem:Fire(SkillEventType.SKILL_FLUSH)
	RemindManager.Instance:Fire(RemindName.SkillActive)
	RemindManager.Instance:Fire(RemindName.SkillPassive)
	AdvanceCtrl.Instance:FlushOpenView()
	MainUICtrl.Instance:FlushView("general_bianshen", {"skill"})
	MainUICtrl.Instance:FlushView("check_skill", {is_change = is_change})
end

function SkillCtrl:OnSkillInfoAck(protocol)
	self.skill_data:SetSkillInfo(protocol.skill_info)
	RemindManager.Instance:Fire(RemindName.SkillActive)
	RemindManager.Instance:Fire(RemindName.SkillPassive)
end

--刺客暴击
function SkillCtrl:OnSkillOtherSkillInfo(protocol)
	self.skill_data:SetSkillOtherSkillInfo(protocol)
end

--技能学习 one_key_learn 1 一键学习
function SkillCtrl:SendRoleSkillLearnReq(skill_id, one_key_learn, is_auto_learn)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleSkillLearnReq)
	protocol.skill_id = skill_id
	protocol.one_key_learn = one_key_learn or 0
	protocol.is_auto_learn = is_auto_learn or 0
	protocol:EncodeAndSend()
end

function SkillCtrl:OnUpGradeSkillInfo(protocol)
	PlayerData.Instance:SetAttr("upgrade_next_skill", protocol.upgrade_next_skill)
	PlayerData.Instance:SetAttr("upgrade_cur_calc_num", protocol.upgrade_cur_calc_num)

	GlobalEventSystem:Fire(MainUIEventType.JINJIE_EQUIP_SKILL_CHANGE)
	RemindManager.Instance:Fire(RemindName.SkillActive)
	RemindManager.Instance:Fire(RemindName.SkillPassive)
end

function SkillCtrl:SkillPassiveRemind()
	return RoleSkillData.Instance:SkillPassiveRemind()
end
function SkillCtrl:SkillActiveRemind()
	return RoleSkillData.Instance:IsShowActiveRedPoint()
end

function SkillCtrl:SendUseWarSceneSkill()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBianshenOnDieReq)
	protocol:EncodeAndSend()
end

function SkillCtrl:OnSCBianshenInfo(protocol)
	self.skill_data:SetBianShenInfo(protocol)
end