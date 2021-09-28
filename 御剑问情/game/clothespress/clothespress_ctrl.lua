require("game/clothespress/clothespress_view")
require("game/clothespress/clothespress_data")
require("game/clothespress/suit_attr_tip_view")

ClothespressCtrl = ClothespressCtrl or BaseClass(BaseController)

function ClothespressCtrl:__init()
	if ClothespressCtrl.Instance ~= nil then
		ErrorLog("[ClothespressCtrl] attempt to create singleton twice!")
		return
	end
	ClothespressCtrl.Instance = self

	self.data = ClothespressData.New()
	self.view = ClothespressView.New(ViewName.ClothespressView)
	self.suit_attr_tip_view = SuitAttrTipView.New(ViewName.SuitAttrTipView)

	self:RegisterAllProtocols()

end

function ClothespressCtrl:__delete()
	ClothespressCtrl.Instance = nil

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.suit_attr_tip_view ~= nil then
		self.suit_attr_tip_view:DeleteMe()
		self.suit_attr_tip_view = nil
	end
end

-- 协议注册
function ClothespressCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSDressingRoomOpera)
	self:RegisterProtocol(SCDressingRoomInfo, "OnSCDressingRoomInfo")
	self:RegisterProtocol(SCDressingRoomSingleInfo, "OnSCDressingRoomSingleInfo")
end

function ClothespressCtrl:SendDressingRoomOpera()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDressingRoomOpera)
	send_protocol.opera_type = opera_type
	send_protocol:EncodeAndSend()
end

function ClothespressCtrl:OnSCDressingRoomInfo(protocol)
	self.data:SetAllSuitInfo(protocol)
	self:FlushClothespressView()
end

function ClothespressCtrl:OnSCDressingRoomSingleInfo(protocol)
	self.data:SetSingleSuitInfo(protocol)
	self:FlushClothespressView()
end

function ClothespressCtrl:FlushClothespressView()
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
end

function ClothespressCtrl:ShowSuitAttrTipView(data_index)
	if self.suit_attr_tip_view and not self.suit_attr_tip_view:IsOpen()then 
		self.suit_attr_tip_view:SetData(data_index)
	end
end