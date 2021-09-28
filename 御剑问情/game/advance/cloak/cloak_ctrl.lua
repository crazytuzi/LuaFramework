require("game/advance/cloak/cloak_data")

CloakCtrl = CloakCtrl or BaseClass(BaseController)

function CloakCtrl:__init()
	if CloakCtrl.Instance then
		return
	end
	CloakCtrl.Instance = self

	self:RegisterAllProtocols()
	self.cloak_data = CloakData.New()
end

function CloakCtrl:__delete()
	if self.cloak_data ~= nil then
		self.cloak_data:DeleteMe()
		self.cloak_data = nil
	end

	CloakCtrl.Instance = nil
end

function CloakCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCloakInfo, "CloakInfo");
	self:RegisterProtocol(CSCloakOperate)
end

function CloakCtrl.SendCloakOperate(operate_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCloakOperate)
	send_protocol.operate_type = operate_type
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function CloakCtrl:CloakInfo(protocol)
	self.cloak_data:SetCloakInfo(protocol)
	AdvanceCtrl.Instance:FlushView("cloak")
	CloakHuanHuaCtrl.Instance:FlushView("cloakhuanhua")
end

-- 发送进阶请求
function CloakCtrl:SendCloakUpLevelReq(up_level_item_index, is_auto_buy, pack_num)
	CloakCtrl.SendCloakOperate(CLOAK_OPERATE_TYPE.CLOAK_OPERATE_TYPE_UP_LEVEL, up_level_item_index - 1, is_auto_buy, pack_num)
end

-- 请求信息
function CloakCtrl:SendGetCloakInfo()
	CloakCtrl.SendCloakOperate(CLOAK_OPERATE_TYPE.CLOAK_OPERATE_TYPE_INFO_REQ)
end

--发送使用形象请求
function CloakCtrl:SendUseCloakImage(image_id)
	CloakCtrl.SendCloakOperate(CLOAK_OPERATE_TYPE.CLOAK_OPERATE_TYPE_USE_IMAGE, image_id)
end

-- 请求升特殊形象进阶
function CloakCtrl:CloakSpecialImgUplevelReq(special_image_id)
	CloakCtrl.SendCloakOperate(CLOAK_OPERATE_TYPE.CLOAK_OPERATE_TYPE_UP_SPECIAL_IMAGE, special_image_id)
end

-- 发送装备升级请求
function CloakCtrl:CloakEquipUplevelReq(equip_idx)
	CloakCtrl.SendCloakOperate(CLOAK_OPERATE_TYPE.CLOAK_OPERATE_TYPE_UP_LEVEL_EQUIP, equip_idx)
end

-- 发送技能升级请求
function CloakCtrl:CloakSkillUplevelReq(skill_idx, auto_buy)
	CloakCtrl.SendCloakOperate(CLOAK_OPERATE_TYPE.CLOAK_OPERATE_TYPE_UP_LEVEL_SKILL, skill_idx, auto_buy)
end
