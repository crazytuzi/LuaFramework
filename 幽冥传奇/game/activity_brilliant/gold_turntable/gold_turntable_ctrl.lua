-- require("scripts/game/activity_brilliant/activity_brilliant_data")
require("scripts/game/activity_brilliant/gold_turntable/gold_turntable_view")
GoldTurntableCtrl = GoldTurntableCtrl or BaseClass(BaseController)
function GoldTurntableCtrl:__init()
	if	GoldTurntableCtrl.Instance then
		ErrorLog("[GoldTurntableCtrl]:Attempt to create singleton twice!")
	end
	GoldTurntableCtrl.Instance = self

	-- self.view = GoldTurntableView.New(ViewDef.GoldTurntable)
	-- self.data = ActivityBrilliantData.New()

end

function GoldTurntableCtrl:__delete()
	GoldTurntableCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	-- self.data:DeleteMe()
	-- self.data = nil

end

