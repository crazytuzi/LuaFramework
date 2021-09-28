require("game/longxing/longxing_view")
require("game/longxing/longxing_data")

LongXingCtrl = LongXingCtrl or BaseClass(BaseController)

function LongXingCtrl:__init()
	if nil ~= LongXingCtrl.Instance then
		print_error("[LongXingCtrl] Attemp to create a singleton twice !")
		return
	end
	LongXingCtrl.Instance = self

	self.view = LongXingView.New(ViewName.LongXingView)
	self.data = LongXingData.New()

	self:RegisterAllProtocols()

	--ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.LongXingRemind)

end

function LongXingCtrl:__delete()
	LongXingCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

end

function LongXingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMolongInfo, "OnSCMolongInfo")
end

function LongXingCtrl:OnSCMolongInfo(protocol)
	self.data:SetSCMolongInfo(protocol)
	self.data:SetMoLongRank(protocol.info.rank_grade)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.LongXingRemind)
end

-- 头衔升级请求操作
function LongXingCtrl:SendMolongRankInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSMolongRankInfoReq)
	protocol:EncodeAndSend()
end

function LongXingCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.LongXingRemind then
		self.data:FlushHallRedPoindRemind()
	end
end