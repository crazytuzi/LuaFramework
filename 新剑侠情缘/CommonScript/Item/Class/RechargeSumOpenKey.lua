
local tbItem = Item:GetClass("RechargeSumOpenKey");

function tbItem:OnClientUse( it )
	local tbItems = me.FindItemInBag("RechargeSumOpenBox")
	if not tbItems or not next(tbItems) then
		me.CenterMsg("您没有充值返利宝箱")
		return 1
	end
	local pBox = tbItems[1]

	local tbAct = self:GetAct()
	local nLevel = tbAct:GetKeyOpenLevel(it.dwTemplateId)
	local tbItemBox = Item:GetClass("RechargeSumOpenBox");
	local nCurLevel = tbItemBox:GetCurOpenLevel(pBox)
	print(nCurLevel, nLevel, "aaa")
	if nLevel  ~= nCurLevel then
		me.CenterMsg("当前层数尚未解锁")
		return 1
	end
	Item:ClientUseItem(pBox.dwId)
	return 1;
end

function tbItem:GetAct(  )
	local tbAct = MODULE_GAMESERVER and Activity:GetClass("RechargeSumOpenBox") or Activity.RechargeSumOpenBox
	return tbAct
end