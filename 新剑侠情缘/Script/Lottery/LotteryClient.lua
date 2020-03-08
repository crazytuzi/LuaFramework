
function Lottery:OnSyncState(bIsOpen, nDrawWeek)
	self.bIsLotteryOpen = bIsOpen;
	self.nDrawWeek = nDrawWeek
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_LOTTERY_DATA);
end

function Lottery:OnSyncDrawWeek(nDrawWeek)
	self.nDrawWeek = nDrawWeek
end

function Lottery:IsOpen()
    return Lottery.bIsLotteryOpen and true or false;
end

function Lottery:GetTicketCount()
	local nDrawWeek = Lottery:GetDrawWeek();
	local nWeek = me.GetUserValue(self.USER_GROUP, self.USER_KEY_WEEK);
	if nDrawWeek > nWeek then
		return 0;
	end
	return me.GetUserValue(self.USER_GROUP, self.USER_KEY_TICKET);
end