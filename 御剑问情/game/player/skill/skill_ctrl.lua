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
end

function SkillCtrl:__delete()
	SkillCtrl.Instance = nil

	self.skill_data:DeleteMe()
	self.skill_data = nil
end

function SkillCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSkillListInfoAck, "OnSkillListInfoAck")
	self:RegisterProtocol(SCSkillInfoAck, "OnSkillInfoAck")
	self:RegisterProtocol(SCSkillOtherSkillInfo, "OnSkillOtherSkillInfo")

	self:RegisterProtocol(SCUpGradeSkillInfo, "OnUpGradeSkillInfo")		-- 进阶装备技能改变

	self:RegisterProtocol(CSRoleSkillLearnReq)
end

function SkillCtrl:OnSkillListInfoAck(protocol)
	self.skill_data:CheckIsNew(protocol.skill_list, protocol.is_init)
	self.skill_data:SetDefaultSkillIndex(protocol.default_skill_index)
	self.skill_data:SetSkillList(protocol.skill_list)
	if ViewManager.Instance:IsOpen(ViewName.Player) then
		ViewManager.Instance:FlushView(ViewName.Player)
	end
	RemindManager.Instance:Fire(RemindName.PlayerSkill)
	MainUICtrl.Instance:FlushView("general_bianshen", {"skill"})
	MainUICtrl.Instance:FlushView("check_skill")
end

function SkillCtrl:OnSkillInfoAck(protocol)
	self.skill_data:SetSkillInfo(protocol.skill_info)
	RemindManager.Instance:Fire(RemindName.PlayerSkill)
end

--刺客暴击
function SkillCtrl:OnSkillOtherSkillInfo(protocol)
	self.skill_data:SetSkillOtherSkillInfo(protocol)
end

--技能学习 one_key_learn 1 一键学习
function SkillCtrl:SendRoleSkillLearnReq(skill_id, one_key_learn)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleSkillLearnReq)
	protocol.skill_id = skill_id
	protocol.one_key_learn = one_key_learn or 0
	protocol:EncodeAndSend()
end

function SkillCtrl:OnUpGradeSkillInfo(protocol)
	PlayerData.Instance:SetAttr("upgrade_next_skill", protocol.upgrade_next_skill)
	PlayerData.Instance:SetAttr("upgrade_cur_calc_num", protocol.upgrade_cur_calc_num)

	GlobalEventSystem:Fire(MainUIEventType.JINJIE_EQUIP_SKILL_CHANGE)
end
