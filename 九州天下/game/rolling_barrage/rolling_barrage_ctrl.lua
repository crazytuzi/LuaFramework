require("game/rolling_barrage/rolling_barrage_data")
require("game/rolling_barrage/rolling_barrage_view")

RollingBarrageCtrl = RollingBarrageCtrl or BaseClass(BaseController)

function RollingBarrageCtrl:__init()
	if nil ~= RollingBarrageCtrl.Instance then
		return
	end
	RollingBarrageCtrl.Instance = self

	self.data = RollingBarrageData.New()
	self.view = RollingBarrageView.New(ViewName.RollingBarrageView)
end

function RollingBarrageCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	RollingBarrageCtrl.Instance = nil
end

function RollingBarrageCtrl:OpenView(text)
	if not self.view:IsOpen() then
		self.view:Open()
	end
	self.view:SetText(text)
end