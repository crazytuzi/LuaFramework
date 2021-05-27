-- require("scripts/game/activity_brilliant/activity_brilliant_data")
require("scripts/game/activity_brilliant/activity_canbaoge/act_canbaoge_view")
require("scripts/game/activity_brilliant/activity_canbaoge/act_canbao_duihuan_view")

ActCanbaogeCtrl = ActCanbaogeCtrl or BaseClass(BaseController)
function  ActCanbaogeCtrl:__init()
	if	 ActCanbaogeCtrl.Instance then
		ErrorLog("[ ActCanbaogeCtrl]:Attempt to create singleton twice!")
	end
	 ActCanbaogeCtrl.Instance = self

	self.view = ActCanbaogeView.New(ViewDef.ActCanbaoge)
	self.duihuan_view = ActCanbaoDuihuanView.New(ViewDef.ActCanbaogeDuiHuan)
end

function  ActCanbaogeCtrl:__delete()
	 ActCanbaogeCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil
end

