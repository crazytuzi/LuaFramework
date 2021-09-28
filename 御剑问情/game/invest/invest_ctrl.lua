require("game/invest/invest_data")
require("game/invest/invest_view")
InvestCtrl = InvestCtrl or BaseClass(BaseController)
function InvestCtrl:__init()
	if InvestCtrl.Instance then
		print_error("[InvestCtrl] Attemp to create a singleton twice !")
	end
	InvestCtrl.Instance = self
	self.data = InvestData.New()
	-- self.view = InvestView.New(ViewName.InvestView)
	self:RegisterProtocol(SCTouZiJiHuaInfo, "OnSCTouZiJiHuaInfo")
end

function InvestCtrl:__delete()
	-- self.view:DeleteMe()
	self.data:DeleteMe()
	InvestCtrl.Instance = nil
end

function InvestCtrl:OnSCTouZiJiHuaInfo(protocol)
	self.data:OnSCTouZiJiHuaInfo(protocol)
	-- if self.view.is_open then
	-- 	self.view.invest_content_one_view:SetActive(false)
	-- 	self.view.invest_content_two_view:SetActive(true)
	-- 	InvestContentTwoView.Instance:OpenCallBack()
	-- end
	RemindManager.Instance:Fire(RemindName.Invest)
	ViewManager.Instance:FlushView(ViewName.VipView)
end

--新投资计划操作
function InvestCtrl:SendChongzhiFetchReward(operate_type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSNewTouzijihuaOperate)
	protocol.operate_type = operate_type
	protocol.param = param 	--第几天的奖励0~6
	protocol:EncodeAndSend()
end

--投资奖励领取
function InvestCtrl:SendFetchTouZiJiHuaReward(plan_type, seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchTouZiJiHuaReward)
	protocol.plan_type = plan_type
	protocol.seq = seq
	protocol:EncodeAndSend()
end

--投资计划投资
function InvestCtrl:SendTouzijihuaActive(plan_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTouzijihuaActive)
	protocol.plan_type = plan_type
	protocol:EncodeAndSend()
end