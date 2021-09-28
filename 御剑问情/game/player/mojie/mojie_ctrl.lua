require("game/player/mojie/mojie_data")
require("game/player/mojie/mojie_view")
require("game/player/mojie/mojie_reward_view")
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
	self.mojie_gift_view = MojieGiftView.New(ViewName.MojieGift)
	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.MainRoleInfo, self))
end

function MojieCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil
	
	self.mojie_gift_view:DeleteMe()
	self.mojie_gift_view = nil

	MojieCtrl.Instance = nil
end

function MojieCtrl:MainRoleInfo()
	FashionCtrl.SendMojieGetInfo()
end

function MojieCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMojieInfo, "OnMojieInfo")
end

function MojieCtrl:OnMojieInfo(protocol)
	self.data:SetMojieInfo(protocol.mojie_list)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Mojie)
end

--请求魔戒信息
function FashionCtrl.SendMojieGetInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSMojieGetInfo)
	protocol:EncodeAndSend()
end

--魔戒升级请求
function FashionCtrl.SendMojieUplevelReq(mojie_type, is_auto_buy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMojieUplevelReq)
	protocol.mojie_type = mojie_type
	protocol.is_auto_buy = is_auto_buy or 0
	protocol:EncodeAndSend()
end

--请求改变魔戒技能
function FashionCtrl.SendMojieChangeSkillReq(mojie_skill_id, mojie_skill_type, mojie_skill_level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMojieChangeSkillReq)
	protocol.mojie_skill_id = mojie_skill_id
	protocol.mojie_skill_type = mojie_skill_type
	protocol.mojie_skill_level = mojie_skill_level
	protocol:EncodeAndSend()
end