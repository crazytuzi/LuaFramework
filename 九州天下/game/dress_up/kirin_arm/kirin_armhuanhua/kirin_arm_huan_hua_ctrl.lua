require("game/dress_up/kirin_arm/kirin_armhuanhua/kirin_arm_huan_hua_view")

KirinArmHuanHuaCtrl = KirinArmHuanHuaCtrl or BaseClass(BaseController)

function KirinArmHuanHuaCtrl:__init()
	if KirinArmHuanHuaCtrl.Instance then
		print_error("[KirinArmHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	KirinArmHuanHuaCtrl.Instance = self

	self.huan_hua_view = KirinArmHuanHuaView.New(ViewName.KirinArmHuanHua)
end

function KirinArmHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	KirinArmHuanHuaCtrl.Instance = nil
end

function KirinArmHuanHuaCtrl:KirinArmSpecialImaUpgrade(special_image_id)
	KirinArmCtrl.Instance:SendKirinArmReq(UGS_REQ.REQ_TYPE_UP_GRADE_IMG,special_image_id)
end

function KirinArmHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end