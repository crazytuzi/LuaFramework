require("game/marry_notice/marry_notice_view")
require("game/marry_notice/marry_blessing_view")
require("game/marry_notice/marry_notice_data")

MarryNoticeCtrl = MarryNoticeCtrl or BaseClass(BaseController)

function MarryNoticeCtrl:__init()
	if MarryNoticeCtrl.Instance ~= nil then
		print_error("[MarryNoticeCtrl] attempt to create singleton twice!")
		return
	end
	MarryNoticeCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = MarryNoticeView.New(ViewName.MarryNoticeView)
	self.blessing_view = MarryBlessingView.New(ViewName.MarryBlessingView)
	self.data = MarryNoticeData.New()
end

function MarryNoticeCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.blessing_view then
		self.blessing_view:DeleteMe()
		self.blessing_view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	MarryNoticeCtrl.Instance = nil
end

function MarryNoticeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSMarryZhuheSend)

	self:RegisterProtocol(SCMarryNotic, "OnMarryNotic")
	self:RegisterProtocol(SCMarryZhuheShou, "OnMarryZhuheShou")
end

function MarryNoticeCtrl:OnMarryNotic(protocol)
	AvatarManager.Instance:SetAvatarKey(protocol.uid1, protocol.avatar_key_big1, protocol.avatar_key_small1)
	AvatarManager.Instance:SetAvatarKey(protocol.uid2, protocol.avatar_key_big2, protocol.avatar_key_small2)
	local main_role_id = Scene.Instance:GetMainRole().vo.role_id
	if main_role_id ~= protocol.uid1 and main_role_id ~= protocol.uid2 then
		if OpenFunData.Instance:CheckIsHide(string.lower(ViewName.MarryNoticeView)) then
			ViewManager.Instance:Open(ViewName.MarryNoticeView)
		end
		ViewManager.Instance:FlushView(ViewName.MarryNoticeView, "info", protocol)
	end
end

function MarryNoticeCtrl:OnMarryZhuheShou(protocol)
	self.data:AddBlessing({blessing_type = protocol.type, name = protocol.name})
	self.blessing_view:Flush()
	if not self.blessing_view:IsOpen() then
		MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.MarryNoticeView), MainUIViewChat.IconList.MarryBlessing, true)
	end
end

-- 祝贺新人
function MarryNoticeCtrl:SendMarryZhuheReq(uid, send_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMarryZhuheSend)
	protocol.uid = uid or 0
	protocol.type = send_type or 0
	protocol:EncodeAndSend()
end