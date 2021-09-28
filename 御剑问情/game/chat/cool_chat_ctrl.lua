require("game/chat/cool_chat_data")
require("game/chat/cool_chat_view")
require("game/chat/head_frame/head_frame_data")

CoolChatCtrl = CoolChatCtrl or BaseClass(BaseController)

function CoolChatCtrl:__init()
	if CoolChatCtrl.Instance then
		print_error("[CoolChatCtrl]:Attempt to create singleton twice!")
	end
	CoolChatCtrl.Instance = self

	self.view = CoolChatView.New(ViewName.CoolChat)
	self.data = CoolChatData.New()
	self.head_frame_data = HeadFrameData.New()

	self:RegisterAllProtocols()
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function CoolChatCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	CoolChatCtrl.Instance = nil
end

function CoolChatCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSPersonalizeWindowOperaReq)
	self:RegisterProtocol(CSUseTuHaoJinReq)
	self:RegisterProtocol(CSBigChatFaceUpLevelReq)
	self:RegisterProtocol(CSTuhaojinUpLevelReq)

	self:RegisterProtocol(SCTuHaoJinInfo, "OnTuHaoJinInfo")
	self:RegisterProtocol(SCBigChatFaceAllInfo, "OnBigChatFaceAllInfo")
	self:RegisterProtocol(SCBubbleWindowInfo, "OnSCPersonalizeWindowBubbleRimInfo")
	self:RegisterProtocol(SCAvatarWindowInfo, "OnSCPersonalizeFrameRimInfo")
end

function CoolChatCtrl:OnTuHaoJinInfo(protocol)
	self.data:SetTuHaoJinInfo(protocol)
	self.view:Flush("gold_text")
end

function CoolChatCtrl:OnBigChatFaceAllInfo(protocol)
	self.data:SetBigChatFaceAllInfo(protocol)
	self.view:Flush("big_face")
end

-- 协议请求
function CoolChatCtrl:SendPersonalizeWindowOperaReq(req_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPersonalizeWindowOperaReq)
	protocol.req_type = req_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end

function CoolChatCtrl:OnSCPersonalizeWindowBubbleRimInfo(protocol)
	self.data:SetBubbleInfo(protocol)
	self.view:ChangeBubbleRed()
	if self.view:IsOpen() then
		self.view:Flush("bubble")
	end
end

function CoolChatCtrl:OnSCPersonalizeFrameRimInfo(protocol)
	self.head_frame_data:SetListDataInfo(protocol)
	self.view:ChangeBubbleRed()
	if self.view:IsOpen() then
		self.view:Flush("head_frame")
	end
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	AvatarManager.Instance:SetAvatarFrameKey(role_id, protocol.cur_use_avatar_type)
	GlobalEventSystem:Fire(ObjectEventType.FRAME_CHANGE)
end

function CoolChatCtrl:ShowCoolChatView()
	self.view:Open()
end

-- 使用土豪金
function CoolChatCtrl:SendUseTuHaoJinReq(color)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUseTuHaoJinReq)
	protocol.use_tohaojin_color = color or 0
	protocol.reserve_1 = 0
	protocol.reserve_2 = 0
	protocol:EncodeAndSend()
end

-- 升级大表情
function CoolChatCtrl:SendBigChatFaceUpLevelReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBigChatFaceUpLevelReq)
	protocol:EncodeAndSend()
end

-- 升级土豪金
function CoolChatCtrl:SendTuhaojinUpLevelReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTuhaojinUpLevelReq)
	protocol:EncodeAndSend()
end

function CoolChatCtrl:SetAvatarFrameImage(avatar_frame_variable, avatar_type, show_variable)
	if avatar_frame_variable then
		avatar_frame_variable:SetAsset(ResPath.GetHeadFrameIcon(avatar_type))
	end
	if show_variable then
		show_variable:SetValue(avatar_type == -1)
	end
end

function CoolChatCtrl:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	RemindManager.Instance:Fire(RemindName.CoolChat)
end