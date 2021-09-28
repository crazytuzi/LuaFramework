require("game/buyone_getone/buyone_getone_view")
require("game/buyone_getone/buyone_getone_data")

BuyOneGetOneCtrl = BuyOneGetOneCtrl or BaseClass(BaseController)

function BuyOneGetOneCtrl:__init()
	if BuyOneGetOneCtrl.Instance then
		print_error("[BuyOneGetOneCtrl] Attemp to create a singleton twice !")
	end
	BuyOneGetOneCtrl.Instance = self

	self.data = BuyOneGetOneData.New()
	self.view = BuyOneGetOneView.New(ViewName.BuyOneGetOneView)

	self:RegisterAllProtocols()

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChangeCallBack, self))

	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	-- RemindManager.Instance:Bind(self.remind_change, RemindName.BuyOneGetOneRemind)
end

function BuyOneGetOneCtrl:__delete()

	BuyOneGetOneCtrl.Instance = nil

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

function BuyOneGetOneCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBuyOneGetOneFreeInfo , "OnSCBuyOneGetOneFreeInfo")
end

function BuyOneGetOneCtrl:OnSCBuyOneGetOneFreeInfo(protocol)
	self.data:SetBuyOneGetOneFreeInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.BuyOneGetOneRemind)
end

function BuyOneGetOneCtrl:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE,RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE.RA_BUY_ONE_GET_ONE_FREE_OPERA_TYPE_INFO,0,0)
		end
	end
end

-- function BuyOneGetOneCtrl:RemindChangeCallBack(remind_name, num)
-- 	if remind_name == RemindName.BuyOneGetOneRemind then
-- 		self.data:FlushHallRedPoindRemind()
-- 	end
-- end