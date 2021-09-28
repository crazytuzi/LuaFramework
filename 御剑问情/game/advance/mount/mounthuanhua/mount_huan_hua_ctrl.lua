require("game/advance/mount/mounthuanhua/mount_huan_hua_view")

MountHuanHuaCtrl = MountHuanHuaCtrl or BaseClass(BaseController)

function MountHuanHuaCtrl:__init()
	if MountHuanHuaCtrl.Instance then
		return
	end
	MountHuanHuaCtrl.Instance = self

	self.huan_hua_view = MountHuanHuaView.New(ViewName.MountHuanHua)

	self:RegisterAllProtocols()
end

function MountHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	MountHuanHuaCtrl.Instance = nil
end

function MountHuanHuaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSMountSpecialImgUpgrade)
end

function MountHuanHuaCtrl:MountSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMountSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function MountHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end