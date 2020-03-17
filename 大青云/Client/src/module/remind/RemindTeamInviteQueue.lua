--[[
邀请入队提醒队列
郝户
2014年11月10日22:26:53
]]

_G.RemindTeamInviteQueue = RemindQueue:new();

--time key(30秒无操作确认面板自动关闭)
RemindTeamInviteQueue.timerKey = nil;
RemindTeamInviteQueue.mailNum = nil;
function RemindTeamInviteQueue:GetType()
	return RemindConsts.Type_TeamInvite;
end

function RemindTeamInviteQueue:GetLibraryLink()
	return "RemindTeamInvite";
end

function RemindTeamInviteQueue:GetPos()
	return 2;
end

function RemindTeamInviteQueue:GetShowIndex()
	return 27;
end

function RemindTeamInviteQueue:GetBtnWidth()
	return 60;
end

--获取按钮上显示的数字
function RemindTeamInviteQueue:GetShowNum()
	return #self.datalist;
end

-- data:{sponsorName, id}
function RemindTeamInviteQueue:AddData(data)
	for _, vo in pairs(self.datalist) do
		if vo.id == data.id then
			return;
		end
	end
	local removeCb = function() self:RefreshData(); end
	local remindData = TeamRemindData:new( data.sponsorName, data.id, removeCb );
	remindData:AddInto( self.datalist );
end

function RemindTeamInviteQueue:DoClick(button)
	if #self.datalist <= 0 then return; end
	local remindData = table.remove(self.datalist, 1);
	remindData:OnRemove();

	local content = string.format( StrConfig["team2"], remindData.sponsorName );
	local confirmFunc = function()
		TeamController:InviteReply( remindData.id, TeamConsts.Agree );
	end
	local cancelFunc = function()
		TeamController:InviteReply( remindData.id, TeamConsts.Refuse );
	end
	UIConfirm:Open( content, confirmFunc, cancelFunc, StrConfig['confirmName4'], StrConfig['confirmName5'] );
end

---------------------------队伍提醒队列 data 结构----------------------------

_G.TeamRemindData = {};

TeamRemindData.sponsorName = nil;
TeamRemindData.id = nil;
TeamRemindData.timerKey = nil;
TeamRemindData.removeCb = nil;
TeamRemindData.parent = nil;

function TeamRemindData:new(sponsorName, id, removeCb)
	local data = {};
	for k,v in pairs(TeamRemindData) do
		data[k] = v;
	end
	data.sponsorName = sponsorName;
	data.id = id;
	data.removeCb = removeCb;
	return data;
end

function TeamRemindData:AddInto( parent )
	self.parent = parent;
	table.insert(parent, self);
	self:StartTimer();
end

function TeamRemindData:OnRemove()
	self:StopTimer();
	self.removeCb();
end

function TeamRemindData:StartTimer()
	local cb = function() self:OnTimeUp(); end
	self.timerKey = TimerManager:RegisterTimer( cb, TeamConsts.AutoRefuseTime );
end

function TeamRemindData:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--30秒未处理，自动拒绝
function TeamRemindData:OnTimeUp()
	self:StopTimer();
	-- 从队列中删除
	if not self.parent then return; end
	for i=#self.parent,1,-1 do
		local vo = self.parent[i];
		if vo.id == self.id then
			table.remove(self.parent, i);
			self:OnRemove();
			self.parent = nil;
			TeamController:InviteReply( self.id, TeamConsts.Refuse );
			return;
		end
	end
end