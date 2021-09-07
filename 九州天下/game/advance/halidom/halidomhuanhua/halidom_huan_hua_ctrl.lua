require("game/advance/halidom/halidomhuanhua/halidom_huan_hua_view")

HalidomHuanHuaCtrl = HalidomHuanHuaCtrl or BaseClass(BaseController)

function HalidomHuanHuaCtrl:__init()
	if HalidomHuanHuaCtrl.Instance then
		print_error("[HalidomHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	HalidomHuanHuaCtrl.Instance = self

	self.huan_hua_view = HalidomHuanHuaView.New(ViewName.HalidomHuanhua)

	self:RegisterAllProtocols()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ChangeItemFlushView, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function HalidomHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	HalidomHuanHuaCtrl.Instance = nil
	if self.item_data_event ~= nil then
 		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
  		self.item_data_event = nil
 	end
end

function HalidomHuanHuaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSJinglingFazhenSpecialImgUpgrade)

end

-- 圣物特殊形象进阶
function HalidomHuanHuaCtrl:SendSpiritFazhenSpecialImgUpgrade(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJinglingFazhenSpecialImgUpgrade)
	send_protocol.special_image_id = image_id or 0
	send_protocol:EncodeAndSend()
end

function HalidomHuanHuaCtrl:FlushView(...)
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:Flush(...)
	end
end

function HalidomHuanHuaCtrl:ChangeItemFlushView()
	self.huan_hua_view:Flush("halidomhuanhua")
end