require("game/fast_charging/fast_charging_view")
require("game/fast_charging/fast_charging_data")

FastChargingCtrl = FastChargingCtrl or BaseClass(BaseController)
function FastChargingCtrl:__init()
	if FastChargingCtrl.Instance then
		print_error("[FastChargingCtrl] Attemp to create a singleton twice !")
	end
	FastChargingCtrl.Instance = self

	self.fast_charging_data = FastChargingData.New()
	self.fast_charging_view = FastChargingView.New(ViewName.FastCharging)

	self:RegisterAllProtocols()
end

function FastChargingCtrl:__delete()
	FastChargingCtrl.Instance = nil

	if self.fast_charging_view then
		self.fast_charging_view:DeleteMe()
		self.fast_charging_view = nil
	end

	if self.fast_charging_data then
		self.fast_charging_data:DeleteMe()
		self.fast_charging_data = nil
	end
end

function FastChargingCtrl:RegisterAllProtocols()

end