--[[
	2015年11月28日15:14:09
	跨服boss活动提示
]]

_G.RemindInierServiceContestQueue = setmetatable({},{__index=RemindQueue});

RemindInierServiceContestQueue.showTime = "";
RemindInierServiceContestQueue.curid = 0;
RemindInierServiceContestQueue.havetimenum = 0;

function RemindInierServiceContestQueue:GetType()
	return RemindConsts.Type_InterContest;
end;

function RemindInierServiceContestQueue:GetLibraryLink()
	return "UnionActivityNoticeItem";
end;

--是否显示
function RemindInierServiceContestQueue:GetIsShow()
	return self.isshow;
end

function RemindInierServiceContestQueue:GetPos()
	return 2;
end;

function RemindInierServiceContestQueue:GetShowIndex()
	return 38;
end;

function RemindInierServiceContestQueue:GetBtnWidth()
	return 137;
end

function RemindInierServiceContestQueue:GetBtnHeight()
	return 111;
end

function RemindInierServiceContestQueue:AddData(data)
	self.curid = data.id;
	self.havetimenum = data.num;
	self.isshow = true;
	self:RefreshData();
	self:StartTime();
end

function RemindInierServiceContestQueue:OnBtnInit()
	if self.button then
		local cfg = t_kuafuactivity[self.curid];
		self.showName = cfg.name;
		local t,s,m = self:GetCurtime(self.havetimenum)
		self.showTime = string.format(StrConfig['interServiceDungeon56'],s,m)
		self.imgScore = ResUtil:GetUnionActivityNameURL(cfg.notice_img,true);
		self.button.tf2.text = self.showTime;
		self.button.btnClose.click = function () self:OnCloseClick(); end
		if self.button.iconLoader.source ~= self.imgScore then 
			self.button.iconLoader.source = self.imgScore;
		end;
	end
end

function RemindInierServiceContestQueue:ShowDaoJiShi()
	if self.button then
		local t,s,m = self:GetCurtime(self.havetimenum)
		self.showTime = string.format(StrConfig['interServiceDungeon56'],s,m)
		self.button.tf2.text = self.showTime;
	end
end

function RemindInierServiceContestQueue:OnCloseClick()
	self.isshow = false;
	self:RefreshData();
	self:DeleteTimekey();
end

function RemindInierServiceContestQueue:OnBtnShow()
	if not self.button then
		return 
	end
end

function RemindInierServiceContestQueue:DoClick()	
	FuncManager:OpenFunc(FuncConsts.KuaFuPVP,true,'uiInterServiceContest');
end

function RemindInierServiceContestQueue:GetCurtime(tim)
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

function RemindInierServiceContestQueue:DoRollOver()
	UIInterServiceNoticeTips:ShowTips(self.curid)	
end
--鼠标移出处理
function RemindInierServiceContestQueue:DoRollOut()
	UIInterServiceNoticeTips:Hide();
end

function RemindInierServiceContestQueue:StartTime()
	--启动定时器,每秒检测一次活动提醒
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()
		self:UpdateTime();
	end,1000,0);
end

function RemindInierServiceContestQueue:DeleteTimekey()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
end

function RemindInierServiceContestQueue:UpdateTime()
	self:TimeJian();
	self:ShowDaoJiShi()
end

function RemindInierServiceContestQueue:TimeJian()
	self.havetimenum = self.havetimenum - 1;
	if self.havetimenum < 0 then
		self.havetimenum = 0;
		self.isshow = false;
		self:RefreshData();
		self:DeleteTimekey();
	end
end