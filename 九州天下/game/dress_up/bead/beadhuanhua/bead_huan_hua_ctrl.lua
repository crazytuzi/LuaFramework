require("game/dress_up/bead/beadhuanhua/bead_huan_hua_view")

BeadHuanHuaCtrl = BeadHuanHuaCtrl or BaseClass(BaseController)

function BeadHuanHuaCtrl:__init()
	if BeadHuanHuaCtrl.Instance then
		print_error("[BeadHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	BeadHuanHuaCtrl.Instance = self

	self.huan_hua_view = BeadHuanHuaView.New(ViewName.BeadHuanHua)
end

function BeadHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	BeadHuanHuaCtrl.Instance = nil
end

function BeadHuanHuaCtrl:BeadSpecialImaUpgrade(special_image_id)
	BeadCtrl.Instance:SendBeadReq(UGS_REQ.REQ_TYPE_UP_GRADE_IMG,special_image_id)
end

function BeadHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end