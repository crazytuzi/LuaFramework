--[[
	2015年11月28日15:14:09
	帮派王城战活动战场提示
]]

_G.RemindUnionCityWarQueue = setmetatable({},{__index=RemindQueue});

RemindUnionCityWarQueue.showTime = "";
RemindUnionCityWarQueue.curid = 0;
RemindUnionCityWarQueue.havetimenum = 0;

function RemindUnionCityWarQueue:GetType()
	return RemindConsts.Type_UnionCityWar;
end;

function RemindUnionCityWarQueue:GetLibraryLink()
	return "UnionActivityNoticeItem";
end;

--是否显示
function RemindUnionCityWarQueue:GetIsShow()
	return self.isshow;
end

function RemindUnionCityWarQueue:GetPos()
	return 4;
end;

function RemindUnionCityWarQueue:GetShowIndex()
	return 36;
end;

function RemindUnionCityWarQueue:GetBtnWidth()
	return 137;
end

function RemindUnionCityWarQueue:GetBtnHeight()
	return 111;
end

function RemindUnionCityWarQueue:AddData(data)
	self.curid = data.id;
	self.havetimenum = data.num;
	self.isshow = true;
	self:RefreshData();
	self:StartTime();
end

function RemindUnionCityWarQueue:OnBtnInit()
	if self.button then
		local cfg = t_guildActivity[self.curid];
		self.showName = cfg.name;
		local t,s,m = self:GetCurtime(self.havetimenum)
		self.showTime = string.format(StrConfig['unionActivity001'],s,m)
		self.imgScore = ResUtil:GetUnionActivityNameURL(cfg.notice_img,true);
		self.button.tf2.text = self.showTime;
		self.button.btnClose.click = function () self:OnCloseClick(); end
		if self.button.iconLoader.source ~= self.imgScore then 
			self.button.iconLoader.source = self.imgScore;
		end;
	end
end

function RemindUnionCityWarQueue:ShowDaoJiShi()
	if self.button then
		local t,s,m = self:GetCurtime(self.havetimenum)
		self.showTime = string.format(StrConfig['unionActivity001'],s,m)
		self.button.tf2.text = self.showTime;
	end
end

function RemindUnionCityWarQueue:OnCloseClick()
	self.isshow = false;
	self:RefreshData();
	self:DeleteTimekey();
end

function RemindUnionCityWarQueue:OnBtnShow()
	if not self.button then
		return 
	end
end

function RemindUnionCityWarQueue:DoClick()
	UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
	FuncManager:OpenFunc(FuncConsts.Guild)
end

function RemindUnionCityWarQueue:GetCurtime(tim)
	local t,s,m = CTimeFormat:sec2format(tim)
	if t < 10 then
		t= "0"..t;
	end;
	if s < 10 then 
		s = "0"..s;
	end;
	if m < 10 then 
		m = "0"..m;
	end;
	return t,s,m
end;

function RemindUnionCityWarQueue:DoRollOver()
	UIUnionActivityNoticeTips:ShowTips(self.curid)
end
--鼠标移出处理
function RemindUnionCityWarQueue:DoRollOut()
	UIUnionActivityNoticeTips:Hide();
end

function RemindUnionCityWarQueue:StartTime()
	--启动定时器,每秒检测一次活动提醒
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()
		self:UpdateTime();
	end,1000,0);
end

function RemindUnionCityWarQueue:DeleteTimekey()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
end

function RemindUnionCityWarQueue:UpdateTime()
	self:TimeJian();
	self:ShowDaoJiShi()
end

function RemindUnionCityWarQueue:TimeJian()
	self.havetimenum = self.havetimenum - 1;
	if self.havetimenum < 0 then
		self.havetimenum = 0;
		self.isshow = false;
		self:RefreshData();
		self:DeleteTimekey();
	end
end