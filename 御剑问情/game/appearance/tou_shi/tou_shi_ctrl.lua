require("game/appearance/tou_shi/tou_shi_data")
require("game/appearance/tou_shi/tou_shi_huan_hua_view")

TouShiCtrl = TouShiCtrl or BaseClass(BaseController)

function TouShiCtrl:__init()
	if TouShiCtrl.Instance ~= nil then
		ErrorLog("[TouShiCtrl] attempt to create singleton twice!")
		return
	end

	TouShiCtrl.Instance = self
	self.data = TouShiData.New()
	self.huanhua_view = TouShiHuanHuaView.New(ViewName.TouShiHuanHua)

	self:RegisterTouShiProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function TouShiCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	TouShiCtrl.Instance = nil
end

-- 注册协议
function TouShiCtrl:RegisterTouShiProtocols()
	self:RegisterProtocol(SCTouShiInfo, "OnTouShiInfo")
	self:RegisterProtocol(SCTouShiAppeChange, "OnTouShiAppeChange")
	self:RegisterProtocol(CSUseTouShiImage)
	self:RegisterProtocol(CSTouShiSpecialImgUpgrade)
	self:RegisterProtocol(CSTouShiGetInfo)
	self:RegisterProtocol(CSUpgradeTouShi)
end

function TouShiCtrl:OnTouShiInfo(protocol)
	self.data:SetTouShiInfo(protocol.toushi_info)

	if not self.is_fire_remind then
		self.is_fire_remind = true
		
		RemindManager.Instance:Fire(RemindName.TouShi_UpGrade)
		RemindManager.Instance:Fire(RemindName.TouShi_ZiZhi)
		RemindManager.Instance:Fire(RemindName.TouShi_HuanHua)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "toushi")
	end

	if self.huanhua_view and self.huanhua_view:IsOpen() then
		self.huanhua_view:Flush("flush_item")
	end
end

function TouShiCtrl:OnTouShiAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		local vo = obj:GetVo()
		if vo.appearance then
			vo.appearance.toushi_used_imageid = protocol.toushi_appeid
			obj:SetAttr("appearance", vo.appearance)
		end
	end
end

-- 请求使用形象
function TouShiCtrl:SendUseTouShiImage(image_id, is_temporary_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseTouShiImage)
	send_protocol.image_id = image_id or 0
	send_protocol.is_temporary_image = is_temporary_image or 0
	send_protocol:EncodeAndSend()
end

-- 头饰特殊形象进阶
function TouShiCtrl:SendTouShiSpecialImgUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTouShiSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id or 0
	send_protocol:EncodeAndSend()
end

-- 请求头饰信息
function TouShiCtrl:SendTouShiGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTouShiGetInfo)
	send_protocol:EncodeAndSend()
end

-- 头饰进阶请求
function TouShiCtrl:SendUpgradeTouShi(repeat_times, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeTouShi)
	send_protocol.repeat_times = repeat_times or 0
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function TouShiCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "toushi_upgrade", {result})
	end
end

function TouShiCtrl:MainuiOpenCreate()
	self:SendTouShiGetInfo()
end