require("scripts/game/beast_palace/beast_palace_data")
require("scripts/game/beast_palace/beast_palace_view")

--------------------------------------------------------
-- 圣兽宫殿(跨服BOSS)
--------------------------------------------------------

BeastPalaceCtrl = BeastPalaceCtrl or BaseClass(BaseController)

function BeastPalaceCtrl:__init()
	if	BeastPalaceCtrl.Instance then
		ErrorLog("[BeastPalaceCtrl]:Attempt to create singleton twice!")
	end
	BeastPalaceCtrl.Instance = self

	self.data = BeastPalaceData.New()
	self.view = BeastPalaceView.New(ViewDef.BeastPalace)

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function BeastPalaceCtrl:__delete()
	BeastPalaceCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

end

--登记所有协议
function BeastPalaceCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBeastPalaceNumber, "OnBeastPalaceNumber") -- 接收"圣兽宫殿"次数
end

function BeastPalaceCtrl:RecvMainInfoCallBack()
	if IS_ON_CROSSSERVER then
		BeastPalaceCtrl.SendBeastPalaceNumberReq(1)
	end
end

----------圣兽宫殿次数----------

-- 接收"圣兽宫殿"次数 请求(144, 10)
function BeastPalaceCtrl:OnBeastPalaceNumber(protocol)
	self.data:SetNumber(protocol)
end

-- 请求"圣兽宫殿"次数 返回(144, 10)
function BeastPalaceCtrl.SendBeastPalaceNumberReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBeastPalaceNumberReq)
	protocol.index = index
	protocol:EncodeAndSend()
end

--------------------
