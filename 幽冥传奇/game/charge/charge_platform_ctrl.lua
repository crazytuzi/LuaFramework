require("scripts/game/charge/charge_platform_data")
require("scripts/game/charge/charge_platform_view")
ChargePlatFormCtrl = ChargePlatFormCtrl or BaseClass(BaseController)

function ChargePlatFormCtrl:__init()
	if	ChargePlatFormCtrl.Instance then
		ErrorLog("[ChargePlatFormCtrl]:Attempt to create singleton twice!")
	end
	ChargePlatFormCtrl.Instance = self

	self.data = ChargePlatFormData.New()
    self.view = ChargePlatFormView.New(ViewName.ChargePlatForm) 
    self:RegisterAllProtocols()
end

function ChargePlatFormCtrl:__delete()

	if self.extract_handler then
		GlobalEventSystem:UnBind(self.extract_handler)
		self.extract_handler = nil
	end	

	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil 

	ChargePlatFormCtrl.Instance = nil
end

function ChargePlatFormCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCIssuePCanWithdrawIngotNum, "OnIssuePCanWithdrawIngotNum")
	self:RegisterProtocol(SCChargePlatformInfo, "OnChargeRebateInfo")
	self.extract_handler = GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.CanExtractReq,self))
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRechangeRebateInfo, self))
end

function ChargePlatFormCtrl:CloseAct()
	--ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
end

function ChargePlatFormCtrl:OpenTip(data)
	-- self.guide_view:SetDescData(data)
	-- self.guide_view:Open()
end

--------------------------------请求--------------------------------
-- 查询可提取元宝
function ChargePlatFormCtrl:CanExtractReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSInquireCanExtractIngot)
	protocol:EncodeAndSend()
end

-- 请求提取元宝
function ChargePlatFormCtrl:GetIngotYuanbaoReq(withdraw_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWithdrawIngotReq)
	protocol.withdraw_num = withdraw_num
	protocol:EncodeAndSend()
end

-- 请求充值返利
function ChargePlatFormCtrl:OnChargeRebate()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetChargePlafromReq)
	protocol:EncodeAndSend()
end

function ChargePlatFormCtrl:OnRechangeRebateInfo()
	self:OnChargeRebate()
end

--------------------------------下发--------------------------------
-- 玩家可提取元宝数量
function ChargePlatFormCtrl:OnIssuePCanWithdrawIngotNum(protocol)
	self.data:GetCanExtractNum(protocol)
end

-- 开服前几次返利充值
function ChargePlatFormCtrl:OnChargeRebateInfo(protocol)
	self.data:GetChangeRebate(protocol)
end