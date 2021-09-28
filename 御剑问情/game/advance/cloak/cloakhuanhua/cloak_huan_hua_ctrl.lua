require("game/advance/cloak/cloakhuanhua/cloak_huan_hua_view")

CloakHuanHuaCtrl = CloakHuanHuaCtrl or BaseClass(BaseController)

function CloakHuanHuaCtrl:__init()
	if CloakHuanHuaCtrl.Instance then
		return
	end
	CloakHuanHuaCtrl.Instance = self

	-- self.huan_hua_view = CloakHuanHuaView.New(ViewName.CloakHuanHua)
end

function CloakHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	CloakHuanHuaCtrl.Instance = nil
end

function CloakHuanHuaCtrl:CloakSpecialImaUpgrade(special_image_id)
	CloakCtrl.SendFootOperate(FOOTPRINT_OPERATE_TYPE.FOOTPRINT_OPERATE_TYPE_UP_SPECIAL_IMAGE, special_image_id)
end

function CloakHuanHuaCtrl:FlushView(...)
	-- self.huan_hua_view:Flush(...)
end