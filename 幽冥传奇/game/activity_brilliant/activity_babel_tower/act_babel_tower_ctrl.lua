-- require("scripts/game/activity_brilliant/activity_brilliant_data")
require("scripts/game/activity_brilliant/activity_babel_tower/act_babel_tower_view")

ActBabelTowerCtrl = ActBabelTowerCtrl or BaseClass(BaseController)
function  ActBabelTowerCtrl:__init()
	if	 ActBabelTowerCtrl.Instance then
		ErrorLog("[ ActBabelTowerCtrl]:Attempt to create singleton twice!")
	end
	 ActBabelTowerCtrl.Instance = self

	self.view = ActBabelTowerView.New(ViewDef.ActBabelTower)
end

function  ActBabelTowerCtrl:__delete()
	 ActBabelTowerCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil
end

