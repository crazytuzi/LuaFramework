require("game/dress_up/headwear/headwearhuanhua/headwear_huan_hua_view")

HeadwearHuanHuaCtrl = HeadwearHuanHuaCtrl or BaseClass(BaseController)

function HeadwearHuanHuaCtrl:__init()
	if HeadwearHuanHuaCtrl.Instance then
		print_error("[HeadwearHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	HeadwearHuanHuaCtrl.Instance = self

	self.huan_hua_view = HeadwearHuanHuaView.New(ViewName.HeadwearHuanHua)
end

function HeadwearHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	HeadwearHuanHuaCtrl.Instance = nil
end

function HeadwearHuanHuaCtrl:HeadwearSpecialImaUpgrade(special_image_id)
	HeadwearCtrl.Instance:SendHeadwearReq(UGS_REQ.REQ_TYPE_UP_GRADE_IMG,special_image_id)
end

function HeadwearHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end