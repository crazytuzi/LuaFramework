require("game/goddess/huanhua/goddess_huanhua_view")
GoddessHuanHuaCtrl = GoddessHuanHuaCtrl or BaseClass(BaseController)

function GoddessHuanHuaCtrl:__init()
	if GoddessHuanHuaCtrl.Instance then
		return
	end
	GoddessHuanHuaCtrl.Instance = self

	self.huan_hua_view = GoddessHuanHuaView.New(ViewName.GoddessHuanHua)

end

function GoddessHuanHuaCtrl:GetView()
	return self.huan_hua_view
end

function GoddessHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	GoddessHuanHuaCtrl.Instance = nil
end

function GoddessHuanHuaCtrl:Flush()
	self.huan_hua_view:Flush()
end


