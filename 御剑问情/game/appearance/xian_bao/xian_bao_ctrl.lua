require("game/appearance/xian_bao/xian_bao_data")
-- require("game/appearance/xian_bao/xian_bao_huan_hua_view")

XianBaoCtrl = XianBaoCtrl or BaseClass(BaseController)

function XianBaoCtrl:__init()
	if XianBaoCtrl.Instance ~= nil then
		ErrorLog("[XianBaoCtrl] attempt to create singleton twice!")
		return
	end

	XianBaoCtrl.Instance = self
	self.data = XianBaoData.New()
	-- self.huanhua_view = XianBaoHuanHuaView.New(ViewName.XianBaoHuanHua)

	self:RegisterXianBaoProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function XianBaoCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	-- if self.huanhua_view then
	-- 	self.huanhua_view:DeleteMe()
	-- 	self.huanhua_view = nil
	-- end

	XianBaoCtrl.Instance = nil
end

-- 注册协议
function XianBaoCtrl:RegisterXianBaoProtocols()
	self:RegisterProtocol(SCXianBaoInfo, "OnXianBaoInfo")
	self:RegisterProtocol(SCXianBaoAppeChange, "OnXianBaoAppeChange")
	self:RegisterProtocol(CSUseXianBaoImage)
	self:RegisterProtocol(CSXianBaoSpecialImgUpgrade)
	self:RegisterProtocol(CSXianBaoGetInfo)
	self:RegisterProtocol(CSUpgradeXianBao)
end

function XianBaoCtrl:OnXianBaoInfo(protocol)
	self.data:SetXianBaoInfo(protocol.xianbao_info)

	if not self.is_fire_remind then
		self.is_fire_remind = true
		
		RemindManager.Instance:Fire(RemindName.XianBao_UpGrade)
		RemindManager.Instance:Fire(RemindName.XianBao_ZiZhi)
		RemindManager.Instance:Fire(RemindName.XianBao_HuanHua)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "xianbao")
	end
end

function XianBaoCtrl:OnXianBaoAppeChange(protocol)
	-- local obj = Scene.Instance:GetObj(protocol.obj_id)
	-- if obj then
	-- 	local vo = obj:GetVo()
	-- 	if vo.appearance then
	-- 		vo.appearance.xianbao_used_imageid = protocol.xianbao_appeid
	-- 		obj:SetAttr("appearance", vo.appearance)
	-- 	end
	-- end
end

-- 请求使用形象
function XianBaoCtrl:SendUseXianBaoImage(image_id, is_temporary_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseXianBaoImage)
	send_protocol.image_id = image_id or 0
	send_protocol.is_temporary_image = is_temporary_image or 0
	send_protocol:EncodeAndSend()
end

-- 头饰特殊形象进阶
function XianBaoCtrl:SendXianBaoSpecialImgUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXianBaoSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id or 0
	send_protocol:EncodeAndSend()
end

-- 请求头饰信息
function XianBaoCtrl:SendXianBaoGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXianBaoGetInfo)
	send_protocol:EncodeAndSend()
end

-- 头饰进阶请求
function XianBaoCtrl:SendUpgradeXianBao(repeat_times, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeXianBao)
	send_protocol.repeat_times = repeat_times or 0
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function XianBaoCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "xianbao_upgrade", {result})
	end
end

function XianBaoCtrl:MainuiOpenCreate()
	self:SendXianBaoGetInfo()
end