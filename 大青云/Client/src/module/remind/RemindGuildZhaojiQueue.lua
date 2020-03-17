--[[
帮主活动召集入帮提醒队列
]]

_G.RemindGuildZhaojiQueue = RemindQueue:new();

--time key(30秒无操作确认面板自动关闭)
RemindGuildZhaojiQueue.timerKey = nil;
RemindGuildZhaojiQueue.confirmUID = nil; -- 确认面板UID

function RemindGuildZhaojiQueue:GetType()
	return RemindConsts.Type_GuildZhaoji;
end

function RemindGuildZhaojiQueue:GetLibraryLink()
	return "RemindGuildZhaoji";
end

function RemindGuildZhaojiQueue:GetPos()
	return 2;
end

function RemindGuildZhaojiQueue:GetShowIndex()
	return 29;
end

function RemindGuildZhaojiQueue:GetBtnWidth()
	return 60;
end

function RemindGuildZhaojiQueue:AddData(data)
	-- for i, vo in ipairs(self.datalist) do
		-- if vo.inviterId == data.inviterId then
			-- return;
		-- end
	-- end
	table.insert(self.datalist, data);
end

function RemindGuildZhaojiQueue:DoClick()
	if #self.datalist <= 0 then UnionController:CheckGuildNotice() return; end
	local data = table.remove(self.datalist, 1);
	if not data.id or data.id <= 0 then UnionController:CheckGuildNotice() return end
	self:RefreshData();
	UnionController:CheckGuildNotice()
	
	local actName = t_guildassemble[data.id].name		
	local content = ''	
	if not data.text or data.text == "" then
		content = t_guildassemble[data.id].text		
	else
		content = data.text	
	end
	
	if data.id == 1 then
		local v = t_worldboss[data.param]
		actName = actName..'<font color="#2fe00d">'..t_monster[v.monster].name..'</font>'
	end
	
	local confirmFunc = function()
		if data.id == 2 or data.id == 3 or data.id == 4 then
			UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
			FuncManager:OpenFunc(FuncConsts.Guild)
		elseif data.id == 5 then
			UIActivity:Show(10007)
		elseif data.id == 1 then
			-- FTrace(data, '打开世界bossid')
			-- UIWorldBoss:Show(data.param)
			UIBossBasic:Show(data.param)
		end
		self:StopTimer();
	end
	local cancelFunc = function()
		self:StopTimer();
	end
	
	content = ChatUtil.filter:filter(content);
	self.confirmUID = UIUnionInviteDialogPanel:Open(actName, content, confirmFunc, cancelFunc,data.name,data.time);
	self:OnUIConfirmOpen();
end

function RemindGuildZhaojiQueue:OnUIConfirmOpen()
	self:StartTimer();
end

function RemindGuildZhaojiQueue:StartTimer()
	local func = function() self:OnTimeUp(); end
	self.timerKey = TimerManager:RegisterTimer( func, TeamConsts.AutoRefuseTime, 2 );
end

function RemindGuildZhaojiQueue:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--30秒未处理，自动关闭
function RemindGuildZhaojiQueue:OnTimeUp()
	self:StopTimer();
	UIUnionInviteDialogPanel:Hide()
end