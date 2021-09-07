require("game/dress_up/waist/waisthuanhua/waist_huan_hua_view")

WaistHuanHuaCtrl = WaistHuanHuaCtrl or BaseClass(BaseController)

function WaistHuanHuaCtrl:__init()
	if WaistHuanHuaCtrl.Instance then
		print_error("[WaistHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	WaistHuanHuaCtrl.Instance = self

	self.huan_hua_view = WaistHuanHuaView.New(ViewName.WaistHuanHua)
end

function WaistHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	WaistHuanHuaCtrl.Instance = nil
end

function WaistHuanHuaCtrl:WaistSpecialImaUpgrade(special_image_id)
	WaistCtrl.Instance:SendWaistReq(UGS_REQ.REQ_TYPE_UP_GRADE_IMG,special_image_id)
end

function WaistHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end