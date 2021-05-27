require("scripts/game/super_after_vip/super_after_vip_data")
require("scripts/game/super_after_vip/super_after_vip_view")

SuperAfterVipCtrl = PraCtrl or BaseClass(BaseController)

function SuperAfterVipCtrl:__init()
	if SuperAfterVipCtrl.Instance then
		ErrorLog("[SuperAfterVipCtrl] attempt to create singleton twice!")
		return
	end
	SuperAfterVipCtrl.Instance = self
	self:CreateRelatedObjs()
end

function SuperAfterVipCtrl:__delete()
end	

function SuperAfterVipCtrl:CreateRelatedObjs()
	self.data = SuperAfterVipData.New()
	self.view = SuperAfterVipView.New(ViewName.SuperAfter)
end