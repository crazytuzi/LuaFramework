local tbItem = Item:GetClass("LotteryTicket");

function tbItem:OnUse(it)
	local bSuccess = Lottery:ExchangeTicket(me);
	if not bSuccess then
		return;
	end
	return 1;
end

function tbItem:GetTip(it)
	return string.format("本周已使用：%d 张", Lottery:GetTicketCount());
end