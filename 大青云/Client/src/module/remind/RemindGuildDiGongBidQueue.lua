--[[
帮主竞标
]]

_G.RemindGuildDiGongBidQueue = RemindQueue:new();

--time key(30秒无操作确认面板自动关闭)
RemindGuildDiGongBidQueue.timerKey = nil;

function RemindGuildDiGongBidQueue:GetType()
	return RemindConsts.Type_GuildDGBid;
end

function RemindGuildDiGongBidQueue:GetLibraryLink()
	return "RemindGuildDGBid";
end

function RemindGuildDiGongBidQueue:GetPos()
	return 2;
end

--是否显示
function RemindGuildDiGongBidQueue:GetIsShow()
	return self.isShow;
end

function RemindGuildDiGongBidQueue:GetShowIndex()
	return 31;
end

function RemindGuildDiGongBidQueue:GetBtnWidth()
	return 60;
end

function RemindGuildDiGongBidQueue:AddData(data)
	if data == 0 then
		self.isShow = false
		self:HideButton()
		return
	end
	self.isShow = true
	self:RefreshData();
	self:StartTimer();
end

function RemindGuildDiGongBidQueue:DoClick()
	UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
	UIUnionDungeonMain:SetFirstPanel( UnionDungeonConsts.UnionDiGongActi );
	UIUnion:Show();
	self.isShow = false;
	self:RefreshData()
	self:StopTimer();
end

function RemindGuildDiGongBidQueue:StartTimer()
	local func = function() self:OnTimeUp();self:AddData(0); end
	local nState,havetime = UnionDiGongUtils:GetCurState();
	if nState == UnionDiGongConsts.State_Bid then
		if havetime then
			self.timerKey = TimerManager:RegisterTimer( func, havetime, 1 );
		end
	end
end

function RemindGuildDiGongBidQueue:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--30秒未处理，自动关闭
function RemindGuildDiGongBidQueue:OnTimeUp()
	self:StopTimer();
end