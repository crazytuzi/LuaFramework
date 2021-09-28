require("game/appearance/qilin_bi/qilin_bi_data")
require("game/appearance/qilin_bi/qilin_bi_huan_hua_view")

QilinBiCtrl = QilinBiCtrl or BaseClass(BaseController)

function QilinBiCtrl:__init()
	if QilinBiCtrl.Instance ~= nil then
		ErrorLog("[QilinBiCtrl] attempt to create singleton twice!")
		return
	end

	QilinBiCtrl.Instance = self
	self.data = QilinBiData.New()
	self.huanhua_view = QilinBiHuanHuaView.New(ViewName.QilinBiHuanHua)

	self:RegisterQilinBiProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function QilinBiCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	QilinBiCtrl.Instance = nil
end

-- 注册协议
function QilinBiCtrl:RegisterQilinBiProtocols()
	self:RegisterProtocol(SCQilinBiInfo, "OnQilinBiInfo")
	self:RegisterProtocol(SCQilinBiAppeChange, "OnQilinBiAppeChange")
	self:RegisterProtocol(CSUseQilinBiImage)
	self:RegisterProtocol(CSQilinBiSpecialImgUpgrade)
	self:RegisterProtocol(CSQilinBiGetInfo)
	self:RegisterProtocol(CSUpgradeQilinBi)
end

function QilinBiCtrl:OnQilinBiInfo(protocol)
	self.data:SetQilinBiInfo(protocol.qilinbi_info)

	if not self.is_fire_remind then
		self.is_fire_remind = true
		
		RemindManager.Instance:Fire(RemindName.QilinBi_UpGrade)
		RemindManager.Instance:Fire(RemindName.QilinBi_ZiZhi)
		RemindManager.Instance:Fire(RemindName.QilinBi_HuanHua)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "qilinbi")
	end

	if self.huanhua_view and self.huanhua_view:IsOpen() then
		self.huanhua_view:Flush("flush_item")
	end
end

function QilinBiCtrl:OnQilinBiAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		local vo = obj:GetVo()
		if vo.appearance then
			vo.appearance.qilinbi_used_imageid = protocol.qilinbi_appeid
			obj:SetAttr("appearance", vo.appearance)
		end
	end
end

-- 请求使用形象
function QilinBiCtrl:SendUseQilinBiImage(image_id, is_temporary_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseQilinBiImage)
	send_protocol.image_id = image_id or 0
	send_protocol.is_temporary_image = is_temporary_image or 0
	send_protocol:EncodeAndSend()
end

-- 腰饰特殊形象进阶
function QilinBiCtrl:SendQilinBiSpecialImgUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQilinBiSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id or 0
	send_protocol:EncodeAndSend()
end

-- 请求腰饰信息
function QilinBiCtrl:SendQilinBiGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQilinBiGetInfo)
	send_protocol:EncodeAndSend()
end

-- 腰饰进阶请求
function QilinBiCtrl:SendUpgradeQilinBi(repeat_times, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeQilinBi)
	send_protocol.repeat_times = repeat_times or 0
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function QilinBiCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "qilinbi_upgrade", {result})
	end
end

function QilinBiCtrl:MainuiOpenCreate()
	self:SendQilinBiGetInfo()
end