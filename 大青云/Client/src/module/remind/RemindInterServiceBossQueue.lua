--[[
	2015年11月28日15:14:09
	跨服boss活动提示
]]

_G.RemindInierServiceBossQueue = setmetatable({},{__index=RemindQueue});

RemindInierServiceBossQueue.showTime = "";
RemindInierServiceBossQueue.curid = 0;
RemindInierServiceBossQueue.havetimenum = 0;

function RemindInierServiceBossQueue:GetType()
	return RemindConsts.Type_InterBoss;
end;

function RemindInierServiceBossQueue:GetLibraryLink()
	return "UnionActivityNoticeItem";
end;

--是否显示
function RemindInierServiceBossQueue:GetIsShow()
	return self.isshow;
end

function RemindInierServiceBossQueue:GetPos()
	return 2;
end;

function RemindInierServiceBossQueue:GetShowIndex()
	return 37;
end;

function RemindInierServiceBossQueue:GetBtnWidth()
	return 137;
end

function RemindInierServiceBossQueue:GetBtnHeight()
	return 111;
end

function RemindInierServiceBossQueue:AddData(data)
	self.curid = data.id;
	self.havetimenum = data.num;
	self.isshow = true;
	self:RefreshData();
	self:StartTime();
end

function RemindInierServiceBossQueue:OnBtnInit()
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

function RemindInierServiceBossQueue:ShowDaoJiShi()
	if self.button then
		local t,s,m = self:GetCurtime(self.havetimenum)
		self.showTime = string.format(StrConfig['interServiceDungeon56'],s,m)
		self.button.tf2.text = self.showTime;
	end
end

function RemindInierServiceBossQueue:OnCloseClick()
	self.isshow = false;
	self:RefreshData();
	self:DeleteTimekey();
end

function RemindInierServiceBossQueue:OnBtnShow()
	if not self.button then
		return 
	end
end

function RemindInierServiceBossQueue:DoClick()	
	FuncManager:OpenFunc(FuncConsts.KuaFuPVP,true,'uiInterServiceBoss');
end

function RemindInierServiceBossQueue:GetCurtime(tim)
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

function RemindInierServiceBossQueue:DoRollOver()
	UIInterServiceNoticeTips:ShowTips(self.curid)	
end
--鼠标移出处理
function RemindInierServiceBossQueue:DoRollOut()
	UIInterServiceNoticeTips:Hide();
end

function RemindInierServiceBossQueue:StartTime()
	--启动定时器,每秒检测一次活动提醒
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()
		self:UpdateTime();
	end,1000,0);
end

function RemindInierServiceBossQueue:DeleteTimekey()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
end

function RemindInierServiceBossQueue:UpdateTime()
	self:TimeJian();
	self:ShowDaoJiShi()
end

function RemindInierServiceBossQueue:TimeJian()
	self.havetimenum = self.havetimenum - 1;
	if self.havetimenum < 0 then
		self.havetimenum = 0;
		self.isshow = false;
		self:RefreshData();
		self:DeleteTimekey();
	end
end