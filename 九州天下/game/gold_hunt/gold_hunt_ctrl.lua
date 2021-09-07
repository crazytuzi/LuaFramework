require("game/gold_hunt/gold_hunt_data")
require("game/gold_hunt/gold_hunt_view")
require("game/gold_hunt/gold_hunt_exchange_view")

GoldHuntCtrl = GoldHuntCtrl or BaseClass(BaseController)
function GoldHuntCtrl:__init()
	if GoldHuntCtrl.Instance then
		print_error("[GoldHuntCtrl] Attemp to create a singleton twice !")
	end
	GoldHuntCtrl.Instance = self
	self.data = GoldHuntData.New()
	self.view = GoldHuntView.New(ViewName.GoldHuntView)
	self.exchange_view = GoldHuntExchangeView.New(ViewName.GoldHuntExchangeView)
	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.GOLDHUNT)
end

function GoldHuntCtrl:__delete()
	self.data:DeleteMe()
	self.view:DeleteMe()
	GoldHuntCtrl.Instance = nil
	if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function GoldHuntCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMineAllInfo, "OnSCRAMineAllInfo")
end

function GoldHuntCtrl:OnSCRAMineAllInfo(protocol)
	self.data:OnSCRAMineAllInfo(protocol)
	self.view:Flush()
	self.exchange_view:Flush()
	RemindManager.Instance:Fire(RemindName.GOLDHUNT)
end

--[[
	param_1的传值:
	opera_type==1 //是否使用元宝 1是,0否
	opera_type==2 //矿石的索引
	opera_type==3 //奖励索引
	opera_type==4 //兑换索引
--]]
function GoldHuntCtrl.SendRandActivityOperaReq(rand_activity_type, opera_type, param_1, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type or 0 --趣味挖矿编号为2111
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

function GoldHuntCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_MINE)
	if is_open then
		GoldHuntCtrl.SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_TYPE_QUERY_INFO)
	end
end


function GoldHuntCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.GOLDHUNT then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_MINE, num > 0)
	end
end