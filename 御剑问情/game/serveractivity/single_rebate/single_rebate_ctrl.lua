require("game/serveractivity/single_rebate/single_rebate_data")
require("game/serveractivity/single_rebate/single_rebate_view")

SingleRebateCtrl = SingleRebateCtrl or BaseClass(BaseController)

function SingleRebateCtrl:__init()
	if SingleRebateCtrl.Instance ~= nil then
		print("[SingleRebateCtrl]error:create a singleton twice")
	end

	SingleRebateCtrl.Instance = self
	self.view = SingleRebateView.New(ViewName.SingleRebateView)
	self.data = SingleRebateData.New()
end

function SingleRebateCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function SingleRebateCtrl:Open()
	self.view:Open()
end

function SingleRebateCtrl:Close()
	self.view:Close()	
end
