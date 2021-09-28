require("game/advance/foot/foothuanhua/foot_huan_hua_view")

FootHuanHuaCtrl = FootHuanHuaCtrl or BaseClass(BaseController)

function FootHuanHuaCtrl:__init()
	if FootHuanHuaCtrl.Instance then
		return
	end
	FootHuanHuaCtrl.Instance = self

	self.huan_hua_view = FootHuanHuaView.New(ViewName.FootHuanHua)

	self:RegisterAllProtocols()
end

function FootHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	FootHuanHuaCtrl.Instance = nil
end

function FootHuanHuaCtrl:RegisterAllProtocols()
end

function FootHuanHuaCtrl:FootSpecialImaUpgrade(special_image_id)
	FootCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_SPECIAL_IMAGE, special_image_id)
end

function FootHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end