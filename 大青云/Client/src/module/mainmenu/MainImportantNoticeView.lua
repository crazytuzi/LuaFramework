--[[
	2015年12月30日14:41:07
	wangyanwei
	主界面重要提醒
]]

_G.UIImportantNotice = BaseUI:new('UIImportantNotice');

function UIImportantNotice:Create()
	self:AddSWF('importantNoticePanel.swf',true,'center')
end

function UIImportantNotice:OnLoaded(objSwf)
	
end

function UIImportantNotice:OnShow()
	self:OnTime();
end

function UIImportantNotice:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil
	end
end

function UIImportantNotice:OnTime()
	local constsCfg = t_consts[191];
	if not constsCfg then return end
	local oneConstsDay = constsCfg.val1;
	local func = function ()
		self:ShowTime();
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil
	end
	self.timeKey = TimerManager:RegisterTimer(func,60000);		--1分钟算一次
	func();
end

function UIImportantNotice:ShowTime()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if #t_activityremindfirst <= 1 then return; end
	if #t_activitytime <= 1 then return; end
	
	local serverOpenDay = MainPlayerController:GetServerOpenDay();--当前开服第几天
	local serverSWeekDay = CTimeFormat:toweekEx(serverSTime) + 1;--开服是周几
	local weekDay = CTimeFormat:toweekEx(GetServerTime()) + 1;--今天是周几
	local _,_,_,currHour,currMinute = CTimeFormat:todate(GetServerTime(), true);

	for i=1,#t_activityremindfirst do
		local cfg = t_activityremindfirst[i];
		if not cfg then return; end
		if serverOpenDay < cfg.day then
			local weekNum = (serverSWeekDay + cfg.day - 1) % 7;
			if weekNum == 0 then weekNum = 7 end
			local str = string.format(StrConfig['importantNotice1'],self:GetCapitaNum(weekNum),cfg.opentime,cfg.closetime,cfg.name);
			objSwf.txt_info.htmlText = str;
			return;
		end
		local t = split(cfg.closetime,':');
		local hour,minute = toint(t[1]),toint(t[2]);
		if serverOpenDay==cfg.day and (currHour<hour or currHour==hour and currMinute<=minute) then
			local weekNum = (serverSWeekDay + cfg.day - 1) % 7;
			if weekNum == 0 then weekNum = 7 end
			local str = string.format(StrConfig['importantNotice1'],self:GetCapitaNum(weekNum),cfg.opentime,cfg.closetime,cfg.name);
			objSwf.txt_info.htmlText = str;
			return;
		end
		local nextCfg = t_activityremindfirst[i+1];
		if not nextCfg then
			break;
		end
		local t = split(nextCfg.closetime,":");
		local nextHour,nextMinute = toint(t[1]),toint(t[2]);
		if serverOpenDay<=nextCfg.day and (currHour<nextHour or currHour==nextHour and currMinute<=nextMinute) then
			local weekNum = (serverSWeekDay + nextCfg.day - 1) % 7;
			if weekNum == 0 then weekNum = 7 end
			local str = string.format(StrConfig['importantNotice1'],self:GetCapitaNum(weekNum),nextCfg.opentime,nextCfg.closetime,nextCfg.name);
			objSwf.txt_info.htmlText = str;
			return;
		end
	end
	--
	for i=1,#t_activitytime do
		local cfg = t_activitytime[i];
		if not cfg then return; end
		if weekDay < cfg.weekday then
			local str = string.format(StrConfig['importantNotice1'],self:GetCapitaNum(cfg.weekday),cfg.opentime,cfg.closetime,cfg.name);
			objSwf.txt_info.htmlText = str;
			return;
		end
		local t = split(cfg.closetime,':');
		local hour,minute = toint(t[1]),toint(t[2]);
		if weekDay==cfg.weekday and (currHour<hour or currHour==hour and currMinute<=minute) then
			local str = string.format(StrConfig['importantNotice1'],self:GetCapitaNum(cfg.weekday),cfg.opentime,cfg.closetime,cfg.name);
			objSwf.txt_info.htmlText = str;
			return;
		end
		local nextCfg = t_activitytime[i+1];
		if not nextCfg then 
			nextCfg = t_activitytime[1];
			local str = string.format(StrConfig['importantNotice1'],self:GetCapitaNum(nextCfg.weekday),nextCfg.opentime,nextCfg.closetime,nextCfg.name);
			objSwf.txt_info.htmlText = str;
			return;
		end
		local t = split(nextCfg.closetime,":");
		local nextHour,nextMinute = toint(t[1]),toint(t[2]);
		if weekDay<=nextCfg.weekday and (currHour<nextHour or currHour==nextHour and currMinute<=nextMinute) then
			local str = string.format(StrConfig['importantNotice1'],self:GetCapitaNum(nextCfg.weekday),nextCfg.opentime,nextCfg.closetime,nextCfg.name);
			objSwf.txt_info.htmlText = str;
			return;
		end
	end
end

function UIImportantNotice:GetCapitaNum(num)
	if not num then return end
	if num > 7 then return end
	return StrConfig['importantNotice0' .. num];
end