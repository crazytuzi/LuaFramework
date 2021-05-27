require("scripts/game/supervip/super_vip_view")
require("scripts/game/supervip/super_vip_data")

-- 超级VIP
SuperVipCtrl = SuperVipCtrl or BaseClass(BaseController)

function SuperVipCtrl:__init()
	if SuperVipCtrl.Instance ~= nil then
		ErrorLog("[SuperVipCtrl] Attemp to create a singleton twice !")
	end
	SuperVipCtrl.Instance = self

	self.vip_view = SuperVipView.New(ViewName.SuperVip)
	self.vip_data = SuperVipData.New()
end

function SuperVipCtrl:__delete()
	self.vip_view:DeleteMe()
	self.vip_view = nil

	self.vip_data:DeleteMe()
	self.vip_data = nil

	SuperVipCtrl.Instance = nil
end

function SuperVipCtrl:ObjBuffChange(obj)
	if obj:GetType() == SceneObjType.MainRole then
		if RoleData.HasBuffGroup(BUFF_GROUP.VIP_MULTI_EXP) then
			self:SentVipInfoReq()
		end
	end
end

function SuperVipCtrl:GetAllVipInfo()
	VipCtrl.Instance:SentVipInfoReq()
end
