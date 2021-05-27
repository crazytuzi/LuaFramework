require("scripts/game/role/skill/skill_data")
--------------------------------------------------------------
--技能相关
--------------------------------------------------------------
SkillCtrl = SkillCtrl or BaseClass(BaseController)
function SkillCtrl:__init()
	if SkillCtrl.Instance then
		ErrorLog("[SkillCtrl] Attemp to create a singleton twice !")
	end
	SkillCtrl.Instance = self

	self.skill_data = SkillData.New()

	self:RegisterAllProtocols()

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
end

function SkillCtrl:__delete()
	SkillCtrl.Instance = nil

	self.skill_data:DeleteMe()
	self.skill_data = nil
end

function SkillCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSkillListInfoAck, "OnSkillListInfoAck")
	self:RegisterProtocol(SCUpSkillResult, "OnUpSkillResult")
	self:RegisterProtocol(SCLearnSkillResult, "OnLearnSkillResult")
	self:RegisterProtocol(SCSkillExpChange, "OnSkillExpChange")
	self:RegisterProtocol(SCTemporaryDelSkillCD, "OnTemporaryDelSkillCD")
	self:RegisterProtocol(SCSkillSwitch, "OnSkillSwitch")
	self:RegisterProtocol(SCDelSkillBook, "OnDelSkillBook")
	self:RegisterProtocol(SCForgetSkill, "OnForgetSkill")
	self:RegisterProtocol(SCSetSkillCD, "OnSetSkillCD")
end

function SkillCtrl:OnRecvMainRoleInfo()
	self:SendSkillInfoReq()
	self.skill_data:InitAllSkillList()
end

function SkillCtrl:SendSkillInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSkillInfoReq)
	protocol:EncodeAndSend()
end

function SkillCtrl:OnSkillListInfoAck(protocol)
	self.skill_data:SetSkillList(protocol.skill_list)
	ViewManager.Instance:FlushView(ViewName.Role, {TabIndex.role_skill_select, TabIndex.role_skill})
	GlobalEventSystem:Fire(OtherEventType.INIT_SKILL_LIST)
end

function SkillCtrl:OnUpSkillResult(protocol)
	self.skill_data:SetSkillLevel(protocol.skill_id, protocol.skill_level)
end

function SkillCtrl:OnLearnSkillResult(protocol)
end

function SkillCtrl:OnSkillExpChange(protocol)
	self.skill_data:SetSkillExp(protocol.skill_id, protocol.skill_exp)
end

function SkillCtrl:OnTemporaryDelSkillCD(protocol)
	-- self.skill_data:SetSkillCD(protocol.skill_id, protocol.skill_cd)
end

function SkillCtrl:OnSkillSwitch(protocol)
	self.skill_data:SetSkillIsDisable(protocol.skill_id, 0 ~= protocol.switch)
end

function SkillCtrl:OnDelSkillBook(protocol)
	self.skill_data:SetSkillBookStuffId(protocol.skill_id, 0)
end

function SkillCtrl:OnForgetSkill(protocol)
	self.skill_data:RemoveSkill(protocol.skill_id)
end

function SkillCtrl:OnSetSkillCD(protocol)
	self.skill_data:SetSkillCD(protocol.skill_id, protocol.skill_cd)
end
