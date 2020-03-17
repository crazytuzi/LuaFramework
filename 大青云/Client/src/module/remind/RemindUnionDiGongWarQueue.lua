--[[
	2015年11月28日15:14:09
	帮派地宫活动战场提示
]]

_G.RemindUnionDiGongWarQueue = setmetatable({},{__index=RemindQueue});

RemindUnionDiGongWarQueue.showTime = "";
RemindUnionDiGongWarQueue.curid = 0;
RemindUnionDiGongWarQueue.havetimenum = 0;

function RemindUnionDiGongWarQueue:GetType()
	return RemindConsts.Type_UnionDGWar;
end;

function RemindUnionDiGongWarQueue:GetLibraryLink()
	return "UnionActivityNoticeItem";
end;

--是否显示
function RemindUnionDiGongWarQueue:GetIsShow()
	return self.isshow;
end

function RemindUnionDiGongWarQueue:GetPos()
	return 2;
end;

function RemindUnionDiGongWarQueue:GetShowIndex()
	return 35;
end;

function RemindUnionDiGongWarQueue:GetBtnWidth()
	return 137;
end

function RemindUnionDiGongWarQueue:GetBtnHeight()
	return 111;
end

function RemindUnionDiGongWarQueue:AddData(data)
	self.curid = data.id;
	self.havetimenum = data.num;
	self.isshow = true;
	self:RefreshData();
	self:StartTime();
end

function RemindUnionDiGongWarQueue:OnBtnInit()
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

function RemindUnionDiGongWarQueue:ShowDaoJiShi()
	if self.button then
		local t,s,m = self:GetCurtime(self.havetimenum)
		self.showTime = string.format(StrConfig['unionActivity001'],s,m)
		self.button.tf2.text = self.showTime;
	end
end

function RemindUnionDiGongWarQueue:OnCloseClick()
	self.isshow = false;
	self:RefreshData();
	self:DeleteTimekey();
end

function RemindUnionDiGongWarQueue:OnBtnShow()
	if not self.button then
		return 
	end
end

function RemindUnionDiGongWarQueue:DoClick()
	UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
	UIUnionDungeonMain:SetFirstPanel( UnionDungeonConsts.UnionDiGongActi );
	FuncManager:OpenFunc(FuncConsts.Guild)
end

function RemindUnionDiGongWarQueue:GetCurtime(tim)
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

function RemindUnionDiGongWarQueue:DoRollOver()
	UIUnionActivityNoticeTips:ShowTips(self.curid)
end
--鼠标移出处理
function RemindUnionDiGongWarQueue:DoRollOut()
	UIUnionActivityNoticeTips:Hide();
end

function RemindUnionDiGongWarQueue:StartTime()
	--启动定时器,每秒检测一次活动提醒
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()
		self:UpdateTime();
	end,1000,0);
end

function RemindUnionDiGongWarQueue:DeleteTimekey()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
end

function RemindUnionDiGongWarQueue:UpdateTime()
	self:TimeJian();
	self:ShowDaoJiShi()
end

function RemindUnionDiGongWarQueue:TimeJian()
	self.havetimenum = self.havetimenum - 1;
	if self.havetimenum < 0 then
		self.havetimenum = 0;
		self.isshow = false;
		self:RefreshData();
		self:DeleteTimekey();
	end
end