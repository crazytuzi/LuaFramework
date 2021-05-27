require("scripts/game/role/skill/skill_data")
-- require("scripts/game/role/skill/skill_view")
require("scripts/game/role/skill/skill_main_view")

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
	self.skill_view = SkillMainView.New(ViewDef.Skill)

	self:RegisterAllProtocols()

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
	self.equip_data_event = BindTool.Bind(self.OnEquipDataChanged, self)
	EquipData.Instance:NotifyDataChangeCallBack(self.equip_data_event)
end

function SkillCtrl:__delete()
	SkillCtrl.Instance = nil

	self.skill_view:DeleteMe()
	self.skill_view = nil
	
	self.skill_data:DeleteMe()
	self.skill_data = nil

	if EquipData.Instance then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_event)
		self.equip_data_event = nil
	end
end

function SkillCtrl:OnEquipDataChanged()
	self.skill_data:SetRefineSkillBuff()
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
	self:RegisterProtocol(SCPerformFireSkill, "OnPerformFireSkill")
end

function SkillCtrl:OnRecvMainRoleInfo()
	self:SendSkillInfoReq()
	self.skill_data:InitAllSkillList()
end

function SkillCtrl:SendSkillInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSkillInfoReq)
	protocol:EncodeAndSend()
end

-- 下发已经学习的技能列表(5, 1)
function SkillCtrl:OnSkillListInfoAck(protocol)
	self.skill_data:SetSkillList(protocol.skill_list)
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
	print("<<<<<<<<<<", protocol.skill_id, protocol.skill_cd)
	self.skill_data:SetSkillCD(protocol.skill_id, protocol.skill_cd)
end

-- 使用经验丹请求
function SkillCtrl.SendUseSkillDanReq(skill_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUseSkillDanReq)
	protocol.skill_id = skill_id
	protocol:EncodeAndSend()
end

-- 升级技能
function SkillCtrl.SendUpSkillReq(skill_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpSkillReq)
	protocol.skill_id = skill_id
	protocol:EncodeAndSend()
end


function SkillCtrl:OnPerformFireSkill(protocol)
	local atker = Scene.Instance:GetObjectByObjId(protocol.atker_obj_id)
	if nil == atker then
		return
	end

	local beatker = Scene.Instance:GetObjectByObjId(protocol.beatker_obj_id)
	local fire_obj = atker.GetFireObj and atker:GetFireObj()
	if nil == fire_obj or nil == beatker then
		return
	end

	fire_obj:ReadyDoFireAttack(beatker)
end
