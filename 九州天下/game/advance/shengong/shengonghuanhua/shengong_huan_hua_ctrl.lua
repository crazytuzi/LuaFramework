require("game/advance/shengong/shengonghuanhua/shengong_huan_hua_view")

ShengongHuanHuaCtrl = ShengongHuanHuaCtrl or BaseClass(BaseController)

function ShengongHuanHuaCtrl:__init()
	if ShengongHuanHuaCtrl.Instance then
		print_error("[ShengongHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	ShengongHuanHuaCtrl.Instance = self

	self.huan_hua_view = ShengongHuanHuaView.New(ViewName.ShengongHuanHua)

	self:RegisterAllProtocols()
end

function ShengongHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	ShengongHuanHuaCtrl.Instance = nil
end

function ShengongHuanHuaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSShengongSpecialImgUpgrade)
end

function ShengongHuanHuaCtrl:ShengongSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShengongSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function ShengongHuanHuaCtrl:FlushView(...)
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:Flush(...)
	end
end