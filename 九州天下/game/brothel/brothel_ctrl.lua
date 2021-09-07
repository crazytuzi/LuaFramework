require("game/brothel/brothel_view")
require("game/brothel/brothel_data")

BrothelCtrl = BrothelCtrl or BaseClass(BaseController)
function BrothelCtrl:__init()
	if BrothelCtrl.Instance then
		print_error("[BrothelCtrl] Attemp to create a singleton twice !")
	end
	BrothelCtrl.Instance = self

	self.brothel_data = BrothelData.New()
	self.brothel_view = BrothelView.New(ViewName.BrothelView)

	self:RegisterAllProtocols()

	self.data_change_callback = BindTool.Bind1(self.DataChangeCallBack, self)
	LianFuDailyCtrl.Instance:NotifyWhenParamChange(self.data_change_callback)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.data_change_callback)
end

function BrothelCtrl:__delete()
	BrothelCtrl.Instance = nil

	if self.brothel_view then
		self.brothel_view:DeleteMe()
		self.brothel_view = nil
	end

	if self.brothel_data then
		self.brothel_data:DeleteMe()
		self.brothel_data = nil
	end
end

function BrothelCtrl:RegisterAllProtocols()

end

function BrothelCtrl:SendBuyBuffReq(param1, param2) -- p1:0听曲，1喝酒，2按摩
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossXYCityReq)
	protocol.opera_type = CROSS_XYCITY_REQ_TYPE.OP_BUY_BUFF or 3
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

function BrothelCtrl:DataChangeCallBack()
	if self.brothel_view:IsOpen() then
		self.brothel_view:Flush()
	end
end