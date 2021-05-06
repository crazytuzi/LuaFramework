local CForetellCtrl = class("CForetellCtrl", CCtrlBase)

function CForetellCtrl.ctor(self)
	CCtrlBase.ctor(self)
end

function CForetellCtrl.GetCurrentData(self)
	for k,v in pairs(data.foretelldata.DATA) do
		if self:IsCanShow(v) then
			return v
		end
	end
	return nil
end

function CForetellCtrl.IsCanShow(self, oData)
	if oData.show_lv.min and oData.show_lv.min > g_AttrCtrl.grade then
		return false
	end
	if oData.show_lv.max and oData.show_lv.max < g_AttrCtrl.grade then
		return false
	end
	return true
end

return CForetellCtrl