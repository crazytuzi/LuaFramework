require("game/appearance/ling_qi/ling_qi_data")
-- require("game/appearance/ling_qi/ling_qi_huan_hua_view")

LingQiCtrl = LingQiCtrl or BaseClass(BaseController)

function LingQiCtrl:__init()
	if LingQiCtrl.Instance ~= nil then
		ErrorLog("[LingQiCtrl] attempt to create singleton twice!")
		return
	end

	LingQiCtrl.Instance = self
	self.data = LingQiData.New()
	-- self.huanhua_view = LingQiHuanHuaView.New(ViewName.LingQiHuanHua)

	self:RegisterLingQiProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function LingQiCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	-- if self.huanhua_view then
	-- 	self.huanhua_view:DeleteMe()
	-- 	self.huanhua_view = nil
	-- end

	LingQiCtrl.Instance = nil
end

-- 注册协议
function LingQiCtrl:RegisterLingQiProtocols()
	self:RegisterProtocol(SCLingQiInfo, "OnLingQiInfo")
	self:RegisterProtocol(SCLingQiAppeChange, "OnLingQiAppeChange")
	self:RegisterProtocol(CSUseLingQiImage)
	self:RegisterProtocol(CSLingQiSpecialImgUpgrade)
	self:RegisterProtocol(CSLingQiGetInfo)
	self:RegisterProtocol(CSUpgradeLingQi)
end

function LingQiCtrl:OnLingQiInfo(protocol)
	self.data:SetLingQiInfo(protocol.lingqi_info)

	if not self.is_fire_remind then
		self.is_fire_remind = true
		
		RemindManager.Instance:Fire(RemindName.LingQi_UpGrade)
		RemindManager.Instance:Fire(RemindName.LingQi_ZiZhi)
		RemindManager.Instance:Fire(RemindName.LingQi_HuanHua)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingqi")
	end
end

function LingQiCtrl:OnLingQiAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		obj:SetAttr("lingqi_used_imageid", protocol.lingqi_appeid)
	end
end

-- 请求使用形象
function LingQiCtrl:SendUseLingQiImage(image_id, is_temporary_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseLingQiImage)
	send_protocol.image_id = image_id or 0
	send_protocol.is_temporary_image = is_temporary_image or 0
	send_protocol:EncodeAndSend()
end

-- 头饰特殊形象进阶
function LingQiCtrl:SendLingQiSpecialImgUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingQiSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id or 0
	send_protocol:EncodeAndSend()
end

-- 请求头饰信息
function LingQiCtrl:SendLingQiGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingQiGetInfo)
	send_protocol:EncodeAndSend()
end

-- 头饰进阶请求
function LingQiCtrl:SendUpgradeLingQi(repeat_times, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeLingQi)
	send_protocol.repeat_times = repeat_times or 0
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function LingQiCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingqi_upgrade", {result})
	end
end

function LingQiCtrl:MainuiOpenCreate()
	self:SendLingQiGetInfo()
end