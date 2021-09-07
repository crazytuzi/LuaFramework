require("game/tomb_explore/tomb_explore_data")
require("game/tomb_explore/tomb_explore_view")
require("game/tomb_explore/tomb_explore_fb_view")

TombExploreCtrl = TombExploreCtrl or BaseClass(BaseController)

function TombExploreCtrl:__init()
	if TombExploreCtrl.Instance then
		print_error("[TombExploreCtrl] Attemp to create a singleton twice !")
	end
	TombExploreCtrl.Instance = self
	self.data = TombExploreData.New()
	-- self.view = TombExploreView.New(ViewName.TombExploreView)
	self.fb_view = TombExploreFBView.New(ViewName.TombExploreFBView)
	self:RegisterAllProtocols()
end

function TombExploreCtrl:__delete()
	self.data:DeleteMe()
	self.fb_view:DeleteMe()
	TombExploreCtrl.Instance = nil
end

function TombExploreCtrl:RegisterAllProtocols()
	self:RegisterProtocol(ScWangLingExploreUserInfo, "SetTombFBInfo")
end

--玩家王陵探险信息
function TombExploreCtrl:SetTombFBInfo(protocol)
	self.data:SetTombFBInfo(protocol)
	self.fb_view:Flush()
end

function TombExploreCtrl:NotifyNoBOSS()
	self.fb_view:Flush()
end

function TombExploreCtrl:GoToBoss()
	if self.fb_view ~= nil then
		self.fb_view:BOSSClick()
	end
end
