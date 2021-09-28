require("game/advance/ling_chong/ling_chong_data")
require("game/advance/ling_chong/ling_chong_huan_hua_view")

LingChongCtrl = LingChongCtrl or BaseClass(BaseController)

function LingChongCtrl:__init()
	if LingChongCtrl.Instance ~= nil then
		ErrorLog("[LingChongCtrl] attempt to create singleton twice!")
		return
	end

	LingChongCtrl.Instance = self
	self.data = LingChongData.New()
	self.huanhua_view = LingChongHuanHuaView.New(ViewName.LingChongHuanHua)

	self:RegisterLingChongProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function LingChongCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	LingChongCtrl.Instance = nil
end

-- 注册协议
function LingChongCtrl:RegisterLingChongProtocols()
	self:RegisterProtocol(SCLingChongInfo, "OnLingChongInfo")
	self:RegisterProtocol(SCLingChongAppeChange, "OnLingChongAppeChange")
	self:RegisterProtocol(CSLingChongUseImage)
	self:RegisterProtocol(CSLingChongSpecialImgUpgrade)
	self:RegisterProtocol(CSLingChongGetInfo)
	self:RegisterProtocol(CSLingChongUpgrade)
end

function LingChongCtrl:OnLingChongInfo(protocol)
	self.data:SetLingChongInfo(protocol.lingchong_info)
	
	if ViewManager.Instance:IsOpen(ViewName.Advance) then
		ViewManager.Instance:FlushView(ViewName.Advance, "lingchong")
	end
end

function LingChongCtrl:OnLingChongAppeChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		obj:SetAttr("lingchong_used_imageid", protocol.lingchong_appeid)
	end
end

-- 请求使用形象
function LingChongCtrl:SendUseLingChongImage(image_id, is_temporary_image)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingChongUseImage)
	send_protocol.image_id = image_id or 0
	send_protocol.is_temporary_image = is_temporary_image or 0
	send_protocol:EncodeAndSend()
end

-- 头饰特殊形象进阶
function LingChongCtrl:SendLingChongSpecialImgUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingChongSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id or 0
	send_protocol:EncodeAndSend()
end

-- 请求头饰信息
function LingChongCtrl:SendLingChongGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingChongGetInfo)
	send_protocol:EncodeAndSend()
end

-- 头饰进阶请求
function LingChongCtrl:SendUpgradeLingChong(repeat_times, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLingChongUpgrade)
	send_protocol.repeat_times = repeat_times or 0
	send_protocol.auto_buy = auto_buy or 0
	send_protocol:EncodeAndSend()
end

function LingChongCtrl:UpGradeResult(result)
	if ViewManager.Instance:IsOpen(ViewName.Advance) then
		ViewManager.Instance:FlushView(ViewName.Advance, "lingchong_upgrade", {result})
	end
end

function LingChongCtrl:MainuiOpenCreate()
	self:SendLingChongGetInfo()
end