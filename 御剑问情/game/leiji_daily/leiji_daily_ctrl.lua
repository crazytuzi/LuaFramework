require ("game/leiji_daily/leiji_daily_view")

LeiJiRDailyCtrl = LeiJiRDailyCtrl or BaseClass(BaseController)

function LeiJiRDailyCtrl:__init()
	if 	LeiJiRDailyCtrl.Instance ~= nil then
		print("[LeiJiRDailyCtrl] attempt to create singleton twice!")
		return
	end
	LeiJiRDailyCtrl.Instance = self
	self.view = LeiJiDailyView.New(ViewName.LeiJiDailyView)
end

function LeiJiRDailyCtrl:LoadCallBack()

end

function LeiJiRDailyCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	LeiJiRDailyCtrl.Instance = nil
end

function LeiJiRDailyCtrl:FlusView()
	if self.view then
		self.view:Flush()
	end
end

function LeiJiRDailyCtrl:SetBiPinState(state)
	self.view:BiPinState(state)
end

function LeiJiRDailyCtrl:SetLeijiViewNextCurrentIndex()
	if self.view:IsOpen() then
		self.view:SetNextCurrentIndex()
	end
end