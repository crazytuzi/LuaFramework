require("scripts/game/activity_brilliant/activity_brilliant_data")
require("scripts/game/activity_brilliant/activity_limit_charge/act_limit_charge_view")

ActLimitChargeCtrl = ActLimitChargeCtrl or BaseClass(BaseController)
function  ActLimitChargeCtrl:__init()
	if ActLimitChargeCtrl.Instance then
		ErrorLog("[ ActLimitChargeCtrl]:Attempt to create singleton twice!")
	end
	 ActLimitChargeCtrl.Instance = self

	self.view = ActLimitChargeView.New(ViewDef.LimitCharge)
end

function  ActLimitChargeCtrl:__delete()
	 ActLimitChargeCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil
end

