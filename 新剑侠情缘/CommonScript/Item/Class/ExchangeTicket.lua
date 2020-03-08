local tbItem = Item:GetClass("ExchangeTicket")
tbItem.tbAct = {
	[8396] = "ExchangeTicketAct",
	[8397] = "ExchangeTicketAct",
	[8398] = "ExchangeTicketAct",
}
tbItem.tbOnProcessAct = tbItem.tbOnProcessAct or {}

function tbItem:GetUseSetting(nItemTId)
	local szAct = self.tbAct[nItemTId]
	if szAct and Activity:__IsActInProcessByType(szAct) then
		return {}
	end

    return {szFirstName = "出售",  fnFirst = "SellItem"}
end