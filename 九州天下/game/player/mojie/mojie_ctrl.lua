require("game/player/mojie/mojie_data")
require("game/player/mojie/mojie_view")
--------------------------------------------------------------
--角色魔戒
--------------------------------------------------------------
MojieCtrl = MojieCtrl or BaseClass(BaseController)
function MojieCtrl:__init()
	if MojieCtrl.Instance then
		print_error("[MojieCtrl] 尝试生成第二个单例模式")
	end
	MojieCtrl.Instance = self
	self.data = MojieData.New()
	self.view = MojieView.New(ViewName.Mojie)
	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.MainRoleInfo, self))
end

function MojieCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	MojieCtrl.Instance = nil
end

function MojieCtrl:MainRoleInfo()
	MojieCtrl.SendMojieGetInfo()
	RemindManager.Instance:Fire(RemindName.PlayerChat)
end

function MojieCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMojieInfo, "OnMojieInfo")

	self:RegisterProtocol(CSGetGouyuInfoReq)						--勾玉信息请求
	self:RegisterProtocol(CSGouyuUplevelReq)						--勾玉升级请求
	self:RegisterProtocol(SCGouyuInfoAck, "OnGouyuInfoAck")			--勾玉信息回复
	self:RegisterProtocol(SCGouyuUplevelAck, "OnGouyuUplevelAck")	--勾玉升级回复
end

function MojieCtrl:OnMojieInfo(protocol)
	self.data:SetMojieInfo(protocol.mojie_list)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Mojie)
	RemindManager.Instance:Fire(RemindName.GouYu)
	RemindManager.Instance:Fire(RemindName.JieZhi)
	RemindManager.Instance:Fire(RemindName.GuaZhui)
end

--请求魔戒信息
function MojieCtrl.SendMojieGetInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSMojieGetInfo)
	protocol:EncodeAndSend()
end

--魔戒升级请求
function MojieCtrl.SendMojieUplevelReq(mojie_type, is_auto_buy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMojieUplevelReq)
	protocol.mojie_type = mojie_type
	protocol.is_auto_buy = is_auto_buy or 0
	protocol:EncodeAndSend()
end

--请求改变魔戒技能
function MojieCtrl.SendMojieChangeSkillReq(mojie_skill_id, mojie_skill_type, mojie_skill_level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMojieChangeSkillReq)
	protocol.mojie_skill_id = mojie_skill_id
	protocol.mojie_skill_type = mojie_skill_type
	protocol.mojie_skill_level = mojie_skill_level
	protocol:EncodeAndSend()
end

-- 勾玉信息请求
function MojieCtrl:SendGetGouyuInfoReq()
	local cmd = ProtocolPool.Instance:GetProtocol(CSGetGouyuInfoReq)
	cmd:EncodeAndSend()
end

-- 勾玉升级请求
function MojieCtrl:SendGouyuUplevelReq(equipment_type)
	local cmd = ProtocolPool.Instance:GetProtocol(CSGouyuUplevelReq)
	cmd.equipment_type = equipment_type
	cmd:EncodeAndSend()
end

--勾玉信息回复
function MojieCtrl:OnGouyuInfoAck(protocol)
	self.data:SetLevelListInfo(protocol.level_list)
	self.view:Flush()
end

--勾玉升级回复
function MojieCtrl:OnGouyuUplevelAck(protocol)
	--protocol.is_succ				-- 是否升级成功
	self.data:SetLevelListTypeInfo(protocol.equipment_type, protocol.gouyu_level)
	self.view:Flush()
	PlayerCtrl.Instance:FlushPlayerView("equip_Change")
end