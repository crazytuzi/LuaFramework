--[[
邀请入帮提醒队列
]]

_G.RemindGuildInviteQueue = RemindQueue:new();

--time key(30秒无操作确认面板自动关闭)
RemindGuildInviteQueue.timerKey = nil;
RemindGuildInviteQueue.confirmUID = nil; -- 确认面板UID

function RemindGuildInviteQueue:GetType()
	return RemindConsts.Type_GuildInvite;
end

function RemindGuildInviteQueue:GetLibraryLink()
	return "RemindGuildInvite";
end

function RemindGuildInviteQueue:GetPos()
	return 2;
end

function RemindGuildInviteQueue:GetShowIndex()
	return 28;
end

function RemindGuildInviteQueue:GetBtnWidth()
	return 60;
end

function RemindGuildInviteQueue:AddData(data)
	for i, vo in ipairs(self.datalist) do
		if vo.inviterId == data.inviterId then
			return;
		end
	end
	table.insert(self.datalist, data);
end

function RemindGuildInviteQueue:DoClick()
	if #self.datalist <= 0 then return; end
	local data = table.remove(self.datalist, 1);
	self:RefreshData();

	local content = string.format( StrConfig["union36"], data.guildName );
	local confirmFunc = function()
		UnionController:ReqInviteToGuildResult(data.inviterId, UnionConsts.AgreeJoinGuild)
		self:StopTimer();
	end
	local cancelFunc = function()
		UnionController:ReqInviteToGuildResult(data.inviterId, UnionConsts.RejectJoinGuild)
		self:StopTimer();
	end
	self.confirmUID = UIConfirm:Open( content, confirmFunc, cancelFunc, StrConfig['confirmName4'], StrConfig['confirmName5'] );
	self:OnUIConfirmOpen();
end

function RemindGuildInviteQueue:OnUIConfirmOpen()
	self:StartTimer();
end

function RemindGuildInviteQueue:StartTimer()
	local func = function() self:OnTimeUp(); end
	self.timerKey = TimerManager:RegisterTimer( func, TeamConsts.AutoRefuseTime, 2 );
end

function RemindGuildInviteQueue:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--30秒未处理，自动关闭
function RemindGuildInviteQueue:OnTimeUp()
	self:StopTimer();
	UIConfirm:Close(self.confirmUID);
end