require("game/advance/fazhen/fazhenhuanhua/fazhen_huan_hua_view")

FaZhenHuanHuaCtrl = FaZhenHuanHuaCtrl or BaseClass(BaseController)

function FaZhenHuanHuaCtrl:__init()
	if FaZhenHuanHuaCtrl.Instance then
		print_error("[FaZhenHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	FaZhenHuanHuaCtrl.Instance = self
	self.huan_hua_view = FaZhenHuanHuaView.New(ViewName.FaZhenHuanHua)

	self:RegisterAllProtocols()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ChangeItemFlushView, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function FaZhenHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	FaZhenHuanHuaCtrl.Instance = nil

	if self.item_data_event ~= nil then
 		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
  		self.item_data_event = nil
 	end
end

function FaZhenHuanHuaCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(CSFightMountSpecialImgUpgrade)

end

function FaZhenHuanHuaCtrl:MountSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function FaZhenHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end

function FaZhenHuanHuaCtrl:ChangeItemFlushView()
	self.huan_hua_view:Flush("fazhenhuanhua")
end