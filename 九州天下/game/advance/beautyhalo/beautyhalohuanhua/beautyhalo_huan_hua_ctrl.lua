require("game/advance/beautyhalo/beautyhalohuanhua/beautyhalo_huan_hua_view")

BeautyHaloHuanHuaCtrl = BeautyHaloHuanHuaCtrl or BaseClass(BaseController)

function BeautyHaloHuanHuaCtrl:__init()
	if BeautyHaloHuanHuaCtrl.Instance then
		print_error("[BeautyHaloHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	BeautyHaloHuanHuaCtrl.Instance = self

	self.huan_hua_view = BeautyHaloHuanHuaView.New(ViewName.BeautyHaloHuanHua)

	self:RegisterAllProtocols()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ChangeItemFlushView, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function BeautyHaloHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	BeautyHaloHuanHuaCtrl.Instance = nil
	if self.item_data_event ~= nil then
 		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
  		self.item_data_event = nil
 	end
end

function BeautyHaloHuanHuaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSJinglingGuanghuanSpecialImgUpgrade)

end

function BeautyHaloHuanHuaCtrl:MountSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingGuanghuanSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function BeautyHaloHuanHuaCtrl:FlushView(...)
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:Flush(...)
	end
end

function BeautyHaloHuanHuaCtrl:ChangeItemFlushView()
	self.huan_hua_view:Flush("halohuanhua")
end