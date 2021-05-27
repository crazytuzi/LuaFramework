require("scripts/game/call_boss/call_boss_view")
CallBossCtrl = CallBossCtrl or BaseClass(BaseController)
function CallBossCtrl:__init()
	if	CallBossCtrl.Instance then
		ErrorLog("[CallBossCtrl]:Attempt to create singleton twice!")
	end
	CallBossCtrl.Instance = self
	self.view = CallBossView.New(ViewName.CallBoss)
end

function CallBossCtrl:__delete()
	CallBossCtrl.Instance = nil
	self.view:DeleteMe()
	self.view = nil
end