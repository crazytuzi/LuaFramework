require("game/playpawn/playpawn_data")
require("game/playpawn/playpawn_view")

PlayPawnCtrl = PlayPawnCtrl or BaseClass(BaseController)

function PlayPawnCtrl:__init()
	if PlayPawnCtrl.Instance then
		print_error("[PlayPawnCtrl]:Attempt to create singleton twice!")
	end
	PlayPawnCtrl.Instance = self

	self.view = PlayPawnView.New()
	self.data = PlayPawnData.New()

	self:RegisterAllProtocols()
end

function PlayPawnCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	PlayPawnCtrl.Instance = nil
end

function PlayPawnCtrl:RegisterAllProtocols()
	-- 注册接收到的协议，接受骰子信息
	self:RegisterProtocol(SCGulidSaiziInfo, "OnSCGulidSaiziInfo")

	-- 注册发送的协议,抛骰子
	self:RegisterProtocol(CSGulidPaoSaizi)
	self:RegisterProtocol(CSReqGulidSaiziInfo)

end

function PlayPawnCtrl:OnSCGulidSaiziInfo(protocol)
	self.data:SetGuildPawnRankInfo(protocol)
	ChatCtrl.Instance:FlushPawnView()
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.GuildChat)
	RemindManager.Instance:Fire(RemindName.PlayPawn)
end

-- 发送抛骰子请求
function PlayPawnCtrl:SendPaoSaizi()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGulidPaoSaizi)
	protocol:EncodeAndSend()
end

-- 请求骰子信息
function PlayPawnCtrl:SendGetPaoSaiziInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqGulidSaiziInfo)
	protocol:EncodeAndSend()
end

function PlayPawnCtrl:OpenPlayPawnView()
	self.view:Open()
end

function PlayPawnCtrl:ClosePlayPawnView()
	self.view:Close()
end

