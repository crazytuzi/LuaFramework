require("game/rebate/rebate_data")
require("game/rebate/rebate_view")
RebateCtrl = RebateCtrl or BaseClass(BaseController)
function RebateCtrl:__init()
	if RebateCtrl.Instance then
		print_error("[RebateCtrl] Attemp to create a singleton twice !")
	end
	RebateCtrl.Instance = self
	self.data = RebateData.New()
	self.view = RebateView.New(ViewName.RebateView)
	self:RegisterProtocol(SCBaiBeiFanLiInfo, "OnSCBaiBeiFanLiInfo")

	self.is_buy = true
end

function RebateCtrl:__delete()
	self.view:DeleteMe()
	self.data:DeleteMe()
	RebateCtrl.Instance = nil
end

function RebateCtrl:OnSCBaiBeiFanLiInfo(protocol)
	self:SetBuyMark(protocol.is_buy)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_REBATE_BUTTON, self.is_buy)
	RemindManager.Instance:Fire(RemindName.Rebate)
end

function RebateCtrl:SetBuyMark(is_buy)
	if is_buy ~= nil and is_buy == 0 then
		self.is_buy = true
	else
		self.is_buy = false
		if self.view:IsOpen() then
			self.view:Close()
		end
	end
end

function RebateCtrl:GetBuyState()
	return self.is_buy
end

--百倍返利
function RebateCtrl:SendBaiBeiFanLiBuy()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBaiBeiFanLiBuy)
	protocol:EncodeAndSend()
end