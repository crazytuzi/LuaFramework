require("game/appearance/waist/waist_data")
require("game/appearance/waist/waist_huan_hua_view")

WaistCtrl = WaistCtrl or BaseClass(BaseController)

function WaistCtrl:__init()
	if WaistCtrl.Instance ~= nil then
		ErrorLog("[WaistCtrl] attempt to create singleton twice!")
		return
	end

	WaistCtrl.Instance = self
	self.data = WaistData.New()
	self.huanhua_view = WaistHuanHuaView.New(ViewName.WaistHuanHua)

	self:RegisterWaistProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function WaistCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	WaistCtrl.Instance = nil
end

-- 注册协议
function WaistCtrl:RegisterWaistProtocols()
	self:RegisterProtocol(SCYaoShiInfo, "OnYaoShiInfo")
	self:RegisterProtocol(SCYaoShiAppeChange, "OnYaoShiAppeChange")
	self:RegisterProtocol(CSUseYaoShiImage)
	self:RegisterProtocol(CSYaoShiSpecialImgUpgrade)
	self:RegisterProtocol(CSYaoShiGetInfo)
	self:RegisterProtocol(CSUpgradeYaoShi)
end

function WaistCtrl:OnYaoShiInfo(protocol)
	self.data:SetYaoShiInfo(protocol.yaoshi_info)

	if not self.is_fire_remind then
		self.is_fire_remind = true
		
		RemindManager.Instance:Fire(RemindName.Waist_UpGrade)
		RemindManager.Instance:Fire(RemindName.Waist_ZiZhi)
		RemindManager.Instance:Fire(RemindName.Waist_HuanHua)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "waist")
	end

	if self.huanhua_view and self.huanhua_view:IsOpen() then
		self.huanhua_view:Flush("flush_item")
	end
end

function WaistCtrl:OnYaoShiAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		local vo = obj:GetVo()
		if vo.appearance then
			vo.appearance.yaoshi_used_imageid = protocol.yaoshi_appeid
			obj:SetAttr("appearance", vo.appearance)
		end
	end
end

-- 请求使用形象
function WaistCtrl:SendUseYaoShiImage(image_id, is_temporary_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseYaoShiImage)
	send_protocol.image_id = image_id or 0
	send_protocol.is_temporary_image = is_temporary_image or 0
	send_protocol:EncodeAndSend()
end

-- 腰饰特殊形象进阶
function WaistCtrl:SendYaoShiSpecialImgUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSYaoShiSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id or 0
	send_protocol:EncodeAndSend()
end

-- 请求腰饰信息
function WaistCtrl:SendYaoShiGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSYaoShiGetInfo)
	send_protocol:EncodeAndSend()
end

-- 腰饰进阶请求
function WaistCtrl:SendUpgradeYaoShi(repeat_times, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeYaoShi)
	send_protocol.repeat_times = repeat_times or 0
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function WaistCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "waist_upgrade", {result})
	end
end

function WaistCtrl:MainuiOpenCreate()
	self:SendYaoShiGetInfo()
end