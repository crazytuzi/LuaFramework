require("scripts/game/escort/escort_data")
require("scripts/game/escort/escort_view")

EscortCtrl = EscortCtrl or BaseClass(BaseController)
function EscortCtrl:__init()
	if EscortCtrl.Instance then
		ErrorLog("[EscortCtrl] Attemp to create a singleton twice !")
	end
	EscortCtrl.Instance = self

	self.view = EscortView.New(ViewDef.Escort)
	self.data = EscortData.New()
	self:CreateConfirDlgs()
	self:RegisterAllProtocols()
end

function EscortCtrl:__delete()
	EscortCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.notDoubleEscConfDlg1 then
		self.notDoubleEscConfDlg1:DeleteMe()
		self.notDoubleEscConfDlg1 = nil
	end

	if self.notDoubleEscConfDlg2 then
		self.notDoubleEscConfDlg2:DeleteMe()
		self.notDoubleEscConfDlg2 = nil
	end
end

function EscortCtrl:CreateConfirDlgs()
	if not self.notDoubleEscConfDlg1 then
		self.notDoubleEscConfDlg1 = Alert.New()
		self.notDoubleEscConfDlg1:SetShowCheckBox(true)
		self.notDoubleEscConfDlg1:SetLableString(Language.Escort.ConfirmDlgContent[2])
		self.notDoubleEscConfDlg1:SetOkFunc(BindTool.Bind(self.ConfirmNormalEscort, self))
	end

	if not self.notDoubleEscConfDlg2 then
		self.notDoubleEscConfDlg2 = Alert.New()
		self.notDoubleEscConfDlg2:SetShowCheckBox(true)
		self.notDoubleEscConfDlg2:SetLableString(Language.Escort.ConfirmDlgContent[2])
		self.notDoubleEscConfDlg2:SetOkFunc(BindTool.Bind(self.ConfirmInsureEscDlg, self))
	end
end

--确定普通护送
function EscortCtrl:ConfirmNormalEscort()
	EscortCtrl.StartEscortingReq(0)
end

--打开确定保险护送弹窗
function EscortCtrl:ConfirmInsureEscDlg()
	self.view:OpenConfirmInsureEscDlg()
end

function EscortCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRefreshQualityResultPost, "OnRefreshQuality")
	self:RegisterProtocol(SCEscortLeftTimes, "OnEscortLeftTimes")
end

--镖车刷新品质(145 24)
function EscortCtrl:OnRefreshQuality(protocol)
	self.data:SetRefreQualityData(protocol)
	self.view:Flush(0, "refre_quality")
end

function EscortCtrl:OnEscortLeftTimes(protocol)
	self.data:SetEscortLeftTimes(protocol)
end

--请求刷新个人镖车(返回145 24)
function EscortCtrl.RefreEscortCarReq(is_onekey_to_top, is_buy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRefreshQualityReq)
	protocol.is_onekey_to_top = is_onekey_to_top
	protocol.is_buy_token = is_buy
	protocol:EncodeAndSend()
end

--请求开始押镖(139 13, 145 21)
function EscortCtrl.StartEscortingReq(is_insure)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStartEscortingReq)
	protocol.is_buy_insure = is_insure
	protocol:EncodeAndSend()
end

-- 请求交镖(返回139 13)
function EscortCtrl.SubmitEscortrReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSubmitEscortReq)
	protocol:EncodeAndSend()
end