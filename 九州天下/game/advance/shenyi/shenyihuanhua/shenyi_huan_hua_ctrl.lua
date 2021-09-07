require("game/advance/shenyi/shenyihuanhua/shenyi_huan_hua_view")

ShenyiHuanHuaCtrl = ShenyiHuanHuaCtrl or BaseClass(BaseController)

function ShenyiHuanHuaCtrl:__init()
	if ShenyiHuanHuaCtrl.Instance then
		print_error("[ShenyiHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	ShenyiHuanHuaCtrl.Instance = self

	self.huan_hua_view = ShenyiHuanHuaView.New(ViewName.ShenyiHuanHua)

	self:RegisterAllProtocols()
end

function ShenyiHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	ShenyiHuanHuaCtrl.Instance = nil
	if self.item_data_event ~= nil then
 		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
  		self.item_data_event = nil
 	end
end

function ShenyiHuanHuaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSShenyiSpecialImgUpgrade)
	self.item_data_event = BindTool.Bind1(self.ChangeItemFlushView, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ShenyiHuanHuaCtrl:ShenyiSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenyiSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function ShenyiHuanHuaCtrl:FlushView(...)
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:Flush(...)
	end
end

function ShenyiHuanHuaCtrl:ChangeItemFlushView()
	self.huan_hua_view:Flush("shenyihuanhua")
end