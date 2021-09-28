require("game/appearance/mask/mask_data")
require("game/appearance/mask/mask_huan_hua_view")

MaskCtrl = MaskCtrl or BaseClass(BaseController)

function MaskCtrl:__init()
	if MaskCtrl.Instance ~= nil then
		ErrorLog("[MaskCtrl] attempt to create singleton twice!")
		return
	end

	MaskCtrl.Instance = self
	self.data = MaskData.New()
	self.huanhua_view = MaskHuanHuaView.New(ViewName.MaskHuanHua)

	self:RegisterMaskProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function MaskCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	MaskCtrl.Instance = nil
end

-- 注册协议
function MaskCtrl:RegisterMaskProtocols()
	self:RegisterProtocol(SCMaskInfo, "OnMaskInfo")
	self:RegisterProtocol(SCMaskAppeChange, "OnMaskAppeChange")
	self:RegisterProtocol(CSUseMaskImage)
	self:RegisterProtocol(CSMaskSpecialImgUpgrade)
	self:RegisterProtocol(CSMaskGetInfo)
	self:RegisterProtocol(CSUpgradeMask)
end

function MaskCtrl:OnMaskInfo(protocol)
	self.data:SetMaskInfo(protocol.mask_info)

	if not self.is_fire_remind then
		self.is_fire_remind = true
		
		RemindManager.Instance:Fire(RemindName.Mask_UpGrade)
		RemindManager.Instance:Fire(RemindName.Mask_ZiZhi)
		RemindManager.Instance:Fire(RemindName.Mask_HuanHua)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "mask")
	end

	if self.huanhua_view and self.huanhua_view:IsOpen() then
		self.huanhua_view:Flush("flush_item")
	end
end

function MaskCtrl:OnMaskAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		local vo = obj:GetVo()
		if vo.appearance then
			vo.appearance.mask_used_imageid = protocol.mask_appeid
			obj:SetAttr("appearance", vo.appearance)
		end
	end
end

-- 请求使用形象
function MaskCtrl:SendUseMaskImage(image_id, is_temporary_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseMaskImage)
	send_protocol.image_id = image_id or 0
	send_protocol.is_temporary_image = is_temporary_image or 0
	send_protocol:EncodeAndSend()
end

-- 头饰特殊形象进阶
function MaskCtrl:SendMaskSpecialImgUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMaskSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id or 0
	send_protocol:EncodeAndSend()
end

-- 请求头饰信息
function MaskCtrl:SendMaskGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMaskGetInfo)
	send_protocol:EncodeAndSend()
end

-- 头饰进阶请求
function MaskCtrl:SendUpgradeMask(repeat_times, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeMask)
	send_protocol.repeat_times = repeat_times or 0
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function MaskCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "mask_upgrade", {result})
	end
end

function MaskCtrl:MainuiOpenCreate()
	self:SendMaskGetInfo()
end