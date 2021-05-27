require("scripts/game/supply_contention/supply_contention_award_view")

SupplyContentionAwardCtrl = SupplyContentionAwardCtrl or BaseClass(BaseController)

function SupplyContentionAwardCtrl:__init()
	if SupplyContentionAwardCtrl.Instance then
		ErrorLog("[SupplyContentionAwardCtrl]:Attempt to create singleton twice!")
	end
	SupplyContentionAwardCtrl.Instance = self

	self.view = SupplyContentionAwardView.New(ViewName.SupplyContentionAwardView)
end

function SupplyContentionAwardCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

    SupplyContentionAwardCtrl.Instance = nil
end