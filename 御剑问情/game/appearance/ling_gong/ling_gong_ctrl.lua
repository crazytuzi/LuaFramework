require("game/appearance/ling_gong/ling_gong_data")
-- require("game/appearance/ling_gong/ling_gong_huan_hua_view")

LingGongCtrl = LingGongCtrl or BaseClass(BaseController)

function LingGongCtrl:__init()
	if LingGongCtrl.Instance ~= nil then
		ErrorLog("[LingGongCtrl] attempt to create singleton twice!")
		return
	end

	LingGongCtrl.Instance = self
	self.data = LingGongData.New()
	-- self.huanhua_view = LingGongHuanHuaView.New(ViewName.LingGongHuanHua)

	self:RegisterLingGongProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function LingGongCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	-- if self.huanhua_view then
	-- 	self.huanhua_view:DeleteMe()
	-- 	self.huanhua_view = nil
	-- end

	LingGongCtrl.Instance = nil
end

-- 注册协议
function LingGongCtrl:RegisterLingGongProtocols()
	self:RegisterProtocol(SCLingGongInfo, "OnLingGongInfo")
	self:RegisterProtocol(SCLingGongAppeChange, "OnLingGongAppeChange")
	self:RegisterProtocol(CSUseLingGongImage)
	self:RegisterProtocol(CSLingGongSpecialImgUpgrade)
	self:RegisterProtocol(CSLingGongGetInfo)
	self:RegisterProtocol(CSUpgradeLingGong)
end

function LingGongCtrl:OnLingGongInfo(protocol)
	self.data:SetLingGongInfo(protocol.linggong_info)

	if not self.is_fire_remind then
		self.is_fire_remind = true
		
		RemindManager.Instance:Fire(RemindName.LingGong_UpGrade)
		RemindManager.Instance:Fire(RemindName.LingGong_ZiZhi)
		RemindManager.Instance:Fire(RemindName.LingGong_HuanHua)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "linggong")
	end
end

function LingGongCtrl:OnLingGongAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		obj:SetAttr("linggong_used_imageid", protocol.linggong_appeid)
	end
end

-- 请求使用形象
function LingGongCtrl:SendUseLingGongImage(image_id, is_temporary_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseLingGongImage)
	send_protocol.image_id = image_id or 0
	send_protocol.is_temporary_image = is_temporary_image or 0
	send_protocol:EncodeAndSend()
end

-- 头饰特殊形象进阶
function LingGongCtrl:SendLingGongSpecialImgUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingGongSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id or 0
	send_protocol:EncodeAndSend()
end

-- 请求头饰信息
function LingGongCtrl:SendLingGongGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingGongGetInfo)
	send_protocol:EncodeAndSend()
end

-- 头饰进阶请求
function LingGongCtrl:SendUpgradeLingGong(repeat_times, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeLingGong)
	send_protocol.repeat_times = repeat_times or 0
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function LingGongCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.AppearanceView) then
		ViewManager.Instance:FlushView(ViewName.AppearanceView, "linggong_upgrade", {result})
	end
end

function LingGongCtrl:MainuiOpenCreate()
	self:SendLingGongGetInfo()
end