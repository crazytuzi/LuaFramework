local tbItem = Item:GetClass("Toy")
function tbItem:OnUse(it)
--[[
	local nId = KItem.GetItemExtParam(it.dwTemplateId, 1)
	if not nId or nId <= 0 then
		Log("[x] Toy:OnUse, cfg err", it.dwTemplateId, nId)
		me.CenterMsg("道具配置错误")
		return 0
	end
	if not Toy:Unlock(me, nId) then
        local tbSetting = Toy:GetSetting(nId) or {}
        me.CenterMsg(string.format("您已经激活过该天工道具%s", tbSetting.szName or ""))
        return 0
    end
    ]]

	me.CenterMsg("道具未开放!")
	return 1
end