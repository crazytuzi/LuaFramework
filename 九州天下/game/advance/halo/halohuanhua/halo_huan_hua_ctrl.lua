require("game/advance/halo/halohuanhua/halo_huan_hua_view")

HaloHuanHuaCtrl = HaloHuanHuaCtrl or BaseClass(BaseController)

function HaloHuanHuaCtrl:__init()
	if HaloHuanHuaCtrl.Instance then
		print_error("[HaloHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	HaloHuanHuaCtrl.Instance = self

	self.huan_hua_view = HaloHuanHuaView.New(ViewName.HaloHuanHua)

	self:RegisterAllProtocols()
end

function HaloHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	HaloHuanHuaCtrl.Instance = nil
end

function HaloHuanHuaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSHaloSpecialImgUpgrade)

end

function HaloHuanHuaCtrl:HaloSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHaloSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function HaloHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end