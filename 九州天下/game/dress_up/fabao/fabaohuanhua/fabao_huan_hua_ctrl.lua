require("game/dress_up/fabao/fabaohuanhua/fabao_huan_hua_view")

FaBaoHuanHuaCtrl = FaBaoHuanHuaCtrl or BaseClass(BaseController)

function FaBaoHuanHuaCtrl:__init()
	if FaBaoHuanHuaCtrl.Instance then
		print_error("[FaBaoHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	FaBaoHuanHuaCtrl.Instance = self

	self.huan_hua_view = FaBaoHuanHuaView.New(ViewName.FaBaoHuanHua)
end

function FaBaoHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	FaBaoHuanHuaCtrl.Instance = nil
end

function FaBaoHuanHuaCtrl:FaBaoSpecialImaUpgrade(special_image_id)
	FaBaoCtrl.Instance:SendFaBaoReq(UGS_REQ.REQ_TYPE_UP_GRADE_IMG,special_image_id)
end

function FaBaoHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end