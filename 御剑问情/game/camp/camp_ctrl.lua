require("game/camp/camp_data")

CampCtrl = CampCtrl or BaseClass(BaseController)

function CampCtrl:__init()
	if CampCtrl.Instance ~= nil then
		print_error("[CampCtrl]error:create a singleton twice")
	end
	CampCtrl.Instance = self

	self.data = CampData.New()

	self.alert = Alert.New()
	self:RegisterAllProtocols()
end

function CampCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
	end

	if nil ~= self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
	CampCtrl.Instance = nil
end

function CampCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSCampNormalDuobaoOperate)
	self:RegisterProtocol(CSRoleChooseCamp)
	self:RegisterProtocol(CSCampEquipOperate)
	self:RegisterProtocol(CSGetCampInfo)
	self:RegisterProtocol(CSRoleChangeCamp)
	self:RegisterProtocol(SCCampEquipInfo, "OnCampEquipInfo")
	self:RegisterProtocol(SCCampInfo, "OnSCCampInfo")
	self:RegisterProtocol(SCCampDefendInfo, "OnCampDefendInfo")
	self:RegisterProtocol(SCChangeCampInfo, "OnSCChangeCampInfo")
end

-- 拉取阵营信息
function CampCtrl:SendGetCampInfo()
	local cmd = ProtocolPool.Instance:GetProtocol(CSGetCampInfo)
	cmd:EncodeAndSend()
end

-- 阵营信息返回
function CampCtrl:OnSCCampInfo(protocol)
	self.data:SetCampInfo(protocol.camp_info)
	self.data:SetCampPowerInfo(protocol.camp_info_power)
end

-- 阵营修改后信息返回
function CampCtrl:OnSCChangeCampInfo(protocol)
	local role = Scene.Instance:GetObj(protocol.obj_id)
	if nil == role or not role:IsRole() then
		return
	end

	if role:IsMainRole() then
		SysMsgCtrl.Instance:ErrorRemind(Language.CampChange.CampSuccess)
	end

	role:SetAttr("camp", protocol.camp)
end

-- 申请修改阵营
function CampCtrl:SendRoleChangeCamp(camp_target_type)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSRoleChangeCamp)
	protocol_send.camp = camp_target_type
	protocol_send:EncodeAndSend()
end

-- 加入阵营
function CampCtrl:OnCSRoleChooseCamp(type)
	local cmd = ProtocolPool.Instance:GetProtocol(CSRoleChooseCamp)
	cmd.camp_type = type
	cmd.is_random = type == self.data:GetRecommendCamp() and 1 or 0
	cmd:EncodeAndSend()
end

function CampCtrl:OnCampEquipInfo(protocol)
	self.data:SetCampEquipList(protocol.equip_list)
	self.data:SetBeastLevel(protocol.beast_level)
	self.data:SetBeastExp(protocol.beast_exp)
end

function CampCtrl:SendCampEquipOperate(operate, param1, param2, param3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCampEquipOperate)
	protocol.operate = operate
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol:EncodeAndSend()
end

function CampCtrl:CSCampNormalDuobaoOperate(operate, param1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCampNormalDuobaoOperate)
	protocol.operate = operate
	protocol.param1 = param1 or 0
	protocol:EncodeAndSend()
end

-- 进入阵营普通夺宝
function CampCtrl:EnterCampDuobao(scene_id)
	self:CSCampNormalDuobaoOperate(CAMP_NORMALDUOBAO_OPERATE_TYPE.ENTER, scene_id)
end

-- 离开阵营普通夺宝
function CampCtrl:LeaveCampDuobao()
	self.alert:SetContent(Language.Dungeon.ConfirmLevelCJ)
	self.alert:SetOkFunc(BindTool.Bind(function ()
		CampCtrl.Instance:CSCampNormalDuobaoOperate(CAMP_NORMALDUOBAO_OPERATE_TYPE.EXIT)
	end))

	self.alert:Open()
end

function CampCtrl:RequestGetCampSimpleInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCampDefendSimpleInfo)
	protocol:EncodeAndSend()
end

-- 守卫雕象信息
function CampCtrl:OnCampDefendInfo(protocol)
	self.data:SetStatueInfo(protocol)
	GlobalEventSystem:Fire(OtherEventType.CAMP_STATUE_CHANGE)
	--FuBenCtrl.Instance:UpdataTaskFollow()
end