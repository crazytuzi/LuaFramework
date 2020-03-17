--[[
申请入队提醒队列
郝户
2014年10月29日16:43:15
]]

_G.RemindTeamApplyQueue = RemindQueue:new();

--time key(30秒无操作确认面板自动关闭)
RemindTeamApplyQueue.timerKey = nil;
RemindTeamApplyQueue.confirmUID = nil; -- 确认面板UID


function RemindTeamApplyQueue:GetType()
	return RemindConsts.Type_TeamApply;
end

function RemindTeamApplyQueue:GetLibraryLink()
	return "RemindTeamApply";
end

function RemindTeamApplyQueue:GetPos()
	return 2;
end

function RemindTeamApplyQueue:GetShowIndex()
	return 26;
end

function RemindTeamApplyQueue:GetBtnWidth()
	return 60;
end

function RemindTeamApplyQueue:AddData(data)
	for _, vo in pairs(self.datalist) do
		if vo.id == data.id then
			return;
		end
	end
	table.insert(self.datalist, data);
end

function RemindTeamApplyQueue:DoClick()
	if #self.datalist <= 0 then return; end
	local data = table.remove(self.datalist, 1);
	self:RefreshData();
	local content = string.format( StrConfig["team3"], data.sponsorName );
	local confirmFunc = function()
		TeamController:ApplyReply( data.id, TeamConsts.Agree );
		self:StopTimer();
	end
	local cancelFunc = function()
		TeamController:ApplyReply( data.id, TeamConsts.Refuse );
		self:StopTimer();
	end
	self.confirmUID = UIConfirm:Open( content, confirmFunc, cancelFunc, StrConfig['confirmName4'], StrConfig['confirmName5'] );
	self:OnUIConfirmOpen();
end

function RemindTeamApplyQueue:OnUIConfirmOpen()
	self:StartTimer();
end

function RemindTeamApplyQueue:StartTimer()
	local func = function() self:OnTimeUp(); end
	self.timerKey = TimerManager:RegisterTimer( func, TeamConsts.AutoRefuseTime, 1 );
end

--30秒未处理，自动关闭
function RemindTeamApplyQueue:OnTimeUp()
	self:StopTimer();
	UIConfirm:Close( self.confirmUID );
end

function RemindTeamApplyQueue:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end