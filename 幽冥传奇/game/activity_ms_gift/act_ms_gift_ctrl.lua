require("scripts/game/activity_brilliant/activity_brilliant_data")
require("scripts/game/activity_ms_gift/act_ms_gift_view")
 ActMsGift =  ActMsGift or BaseClass(BaseController)
function  ActMsGift:__init()
	if	 ActMsGift.Instance then
		ErrorLog("[ ActMsGift]:Attempt to create singleton twice!")
	end
	 ActMsGift.Instance = self

	self.view = ActMsGiftView.New(ViewName.ActMsGift)
	-- self.data = ActivityBrilliantData.New()

end

function  ActMsGift:__delete()
	 ActMsGift.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	-- self.data:DeleteMe()
	-- self.data = nil

end

