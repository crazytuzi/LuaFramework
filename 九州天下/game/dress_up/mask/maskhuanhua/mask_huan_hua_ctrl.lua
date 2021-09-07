require("game/dress_up/mask/maskhuanhua/mask_huan_hua_view")

MaskHuanHuaCtrl = MaskHuanHuaCtrl or BaseClass(BaseController)

function MaskHuanHuaCtrl:__init()
	if MaskHuanHuaCtrl.Instance then
		print_error("[MaskHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	MaskHuanHuaCtrl.Instance = self

	self.huan_hua_view = MaskHuanHuaView.New(ViewName.MaskHuanHua)
end

function MaskHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	MaskHuanHuaCtrl.Instance = nil
end

function MaskHuanHuaCtrl:MaskSpecialImaUpgrade(special_image_id)
	MaskCtrl.Instance:SendMaskReq(UGS_REQ.REQ_TYPE_UP_GRADE_IMG,special_image_id)
end

function MaskHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end