require("scripts/game/activity_brilliant/activity_brilliant_data")
require("scripts/game/activity_brilliant/activity_ms_gift/act_ms_gift_view")
 ActMsGiftCtrl =  ActMsGiftCtrl or BaseClass(BaseController)
function  ActMsGiftCtrl:__init()
	if	 ActMsGiftCtrl.Instance then
		ErrorLog("[ ActMsGiftCtrl]:Attempt to create singleton twice!")
	end
	 ActMsGiftCtrl.Instance = self

	self.view = ActMsGiftView.New(ViewName.ActMsGift)
	-- self.data = ActivityBrilliantData.New()

end

function  ActMsGiftCtrl:__delete()
	 ActMsGiftCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	-- self.data:DeleteMe()
	-- self.data = nil
end

