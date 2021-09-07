require("game/advance/wing/winghuanhua/wing_huan_hua_view")

WingHuanHuaCtrl = WingHuanHuaCtrl or BaseClass(BaseController)

function WingHuanHuaCtrl:__init()
	if WingHuanHuaCtrl.Instance then
		print_error("[WingHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	WingHuanHuaCtrl.Instance = self

	self.huan_hua_view = WingHuanHuaView.New(ViewName.WingHuanHua)

	self:RegisterAllProtocols()
end

function WingHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	WingHuanHuaCtrl.Instance = nil
end

function WingHuanHuaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSWingSpecialImgUpgrade)
end

function WingHuanHuaCtrl:WingSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function WingHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end