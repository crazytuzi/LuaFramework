require("scripts/game/activity_brilliant/activity_brilliant_data")
require("scripts/game/activity_brilliant/activity_charge_fanli/act_charge_fanli_view")

ActChargeFanliCtrl = ActChargeFanliCtrl or BaseClass(BaseController)
function  ActChargeFanliCtrl:__init()
	if	 ActChargeFanliCtrl.Instance then
		ErrorLog("[ ActChargeFanliCtrl]:Attempt to create singleton twice!")
	end
	 ActChargeFanliCtrl.Instance = self

	self.view = ActChargeFanliView.New(ViewDef.ActChargeFanli)
end

function  ActChargeFanliCtrl:__delete()
	 ActChargeFanliCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil
end

