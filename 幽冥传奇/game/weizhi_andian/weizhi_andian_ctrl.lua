require("scripts/game/weizhi_andian/weizhi_andian_view")
WeiZhiADCtrl = WeiZhiADCtrl or BaseClass(BaseController)
function WeiZhiADCtrl:__init()
	if	WeiZhiADCtrl.Instance then
		ErrorLog("[WeiZhiADCtrl]:Attempt to create singleton twice!")
	end
	WeiZhiADCtrl.Instance = self
	self.view = WeiZhiADView.New(ViewName.WeizhiAD)
end

function WeiZhiADCtrl:__delete()
	WeiZhiADCtrl.Instance = nil
	self.view:DeleteMe()
	self.view = nil
end