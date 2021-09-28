require("game/appearance/ling_zhu/ling_zhu_data")
-- require("game/appearance/ling_zhu/ling_zhu_huan_hua_view")

LingZhuCtrl = LingZhuCtrl or BaseClass(BaseController)

function LingZhuCtrl:__init()
	if LingZhuCtrl.Instance ~= nil then
		ErrorLog("[LingZhuCtrl] attempt to create singleton twice!")
		return
	end

	LingZhuCtrl.Instance = self
	self.data = LingZhuData.New()
	-- self.huanhua_view = LingZhuHuanHuaView.New(ViewName.LingZhuHuanHua)

	self:RegisterLingZhuProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function LingZhuCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	-- if self.huanhua_view then
	-- 	self.huanhua_view:DeleteMe()
	-- 	self.huanhua_view = nil
	-- end

	LingZhuCtrl.Instance = nil
end

-- 注册协议
function LingZhuCtrl:RegisterLingZhuProtocols()
	self:RegisterProtocol(SCLingZhuInfo, "OnLingZhuInfo")
	self:RegisterProtocol(SCLingZhuAppeChange, "OnLingZhuAppeChange")
	self:RegisterProtocol(CSUseLingZhuImage)
	self:RegisterProtocol(CSLingZhuSpecialImgUpgrade)
	self:RegisterProtocol(CSLingZhuGetInfo)
	self:RegisterProtocol(CSUpgradeLingZhu)
end

function LingZhuCtrl:OnLingZhuInfo(protocol)
	self.data:SetLingZhuInfo(protocol.lingzhu_info)

	if not self.is_fire_remind then
		self.is_fire_remind = true
		
		RemindManager.Instance:Fire(RemindName.LingZhu_UpGrade)
		RemindManager.Instance:Fire(RemindName.LingZhu_ZiZhi)
		RemindManager.Instance:Fire(RemindName.LingZhu_HuanHua)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingzhu")
	end
end

function LingZhuCtrl:OnLingZhuAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		obj:SetAttr("lingzhu_use_imageid", protocol.lingzhu_appeid)
	end
end

-- 请求使用形象
function LingZhuCtrl:SendUseLingZhuImage(image_id, is_temporary_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseLingZhuImage)
	send_protocol.image_id = image_id or 0
	send_protocol.is_temporary_image = is_temporary_image or 0
	send_protocol:EncodeAndSend()
end

-- 头饰特殊形象进阶
function LingZhuCtrl:SendLingZhuSpecialImgUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingZhuSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id or 0
	send_protocol:EncodeAndSend()
end

-- 请求头饰信息
function LingZhuCtrl:SendLingZhuGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingZhuGetInfo)
	send_protocol:EncodeAndSend()
end

-- 头饰进阶请求
function LingZhuCtrl:SendUpgradeLingZhu(repeat_times, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeLingZhu)
	send_protocol.repeat_times = repeat_times or 0
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function LingZhuCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "lingzhu_upgrade", {result})
	end
end

function LingZhuCtrl:MainuiOpenCreate()
	self:SendLingZhuGetInfo()
end