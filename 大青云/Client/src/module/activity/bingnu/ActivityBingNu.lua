--[[
活动解封冰奴基类
zhangshuhui
2015年1月7日20:16:36
]]

_G.ActivityBingNu = setmetatable({},{__index=BaseActivity});
ActivityModel:RegisterActivityClass(ActivityConsts.T_BingNu,ActivityBingNu);

--解封数量
ActivityBingNu.bingnucount = 0;
--累计获得奖励
ActivityBingNu.totalrewardlist = {};
--倒计时时间
ActivityBingNu.sourceTime = 0;


ActivityBingNu.timerKey = nil;
function ActivityBingNu:RegisterMsg()
	MsgManager:RegisterCallBack(MsgType.SC_JieFengResult,self,self.OnJieFengResult);
end

function ActivityBingNu:GetType()
	return ActivityConsts.T_BingNu;
end

--获取活动对应的Id
function ActivityBingNu:GetBingNuId()
	local cfg = self:GetCfg();
	if not cfg then return 0; end
	return cfg.id;
end

function ActivityBingNu:InitData()
	self:SetSourceTime(self:GetEndLastTime());
end

function ActivityBingNu:OnEnter()
	local list = ActivityModel:GetActivityByType(self:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			activity:StartTimer();
		end
	end
	
	UIActivity:Hide();
	UIBingNuMainView:Show();
	UIBingNuFloat:Show();
end

function ActivityBingNu:OnQuit()
	UIBingNuMainView:Hide();
	
	local list = ActivityModel:GetActivityByType(self:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			activity:DelTimerKey();
		end
	end
end

function ActivityBingNu:StartTimer()
	self:InitData();
	
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,1000,0);
end

function ActivityBingNu:DelTimerKey()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
		self.sourceTime = 0;
	end
end

function ActivityBingNu:SetSourceTime(lasttime)
	self.sourceTime = lasttime;
end

--计时器
function ActivityBingNu:OnTimer()
	local list = ActivityModel:GetActivityByType(ActivityBingNu:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			activity.sourceTime = activity.sourceTime -1;
			local t,s,m  = ActivityBingNu:GetTime(activity.sourceTime)
			UIBingNuMainView:UpdateTimeInfo(s,m)
		end
	end
end;

function ActivityBingNu:GetTime(time)
	if not time then return end;
	if time <= 0 then return "00","00","00" end;
	local ti = time / 60 -- 分
	local tim = (ti % 1)*60 + 0.1
	local m = toint(tim)
	if m < 10 then 
		m = "0"..m
	end;
	local s = toint(ti)
	local t = 0;
	if s >= 60 then 
		t = toint(s/60);
		s = s%60;
	end;

	if s < 10 then 
		s = "0"..s
	end;

	if t < 10 then 
		t = "0"..t;
	end;

	return t,s,m
end;

-- 请求快速解封
function ActivityBingNu:ReqQuickJieFeng(bingnuId, count)
	local msg = ReqQuickJieFengMsg:new()
	msg.Id = bingnuId;
	msg.count = count;
	MsgManager:Send(msg)
end


--返回解封结果
--很蛋疼的写法,父类里要向子类塞数据(虽然同一时间只有一份数据,但是也不要用父类存储数据,fuckfucktoo)
function ActivityBingNu:OnJieFengResult(msg)
	local list = ActivityModel:GetActivityByType(self:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			activity:JieFengInfoMsg(msg);
		end
	end
end

--返回解封信息
function ActivityBingNu:JieFengInfoMsg(msg)
	--每一个类型区分开，便于处理不同的情况
	if msg.type == 1 then
		self:SetJieFengRetInfo(msg);
	elseif msg.type == 2 then
		self:SetJieFengInfo(msg);
	elseif msg.type == 3 then
		self:SetQuickJieFengInfo(msg);
	end
end

--设置解封信息
function ActivityBingNu:SetJieFengRetInfo(msg)
	--清空
	for i,vo in pairs(self.totalrewardlist) do
		if vo then
			self.totalrewardlist[i] = nil;
		end
	end
	
	--当前解封数量
	self.bingnucount = msg.count;
	
	--解封奖励信息列表
	for i,vo in pairs(msg.list) do
		if vo then
			self.totalrewardlist[vo.type] = vo.num;
		end
	end
	
	Notifier:sendNotification( NotifyConsts.JieFengBingNuInfo, {count=msg.count} );
end

--设置解封信息
function ActivityBingNu:SetJieFengInfo(msg)
	self.bingnucount = msg.count;
	
	--解封奖励信息列表
	for i,vo in pairs(msg.list) do
		if vo then
			if not self.totalrewardlist[vo.type] then
				self.totalrewardlist[vo.type] = vo.num;
			else
				self.totalrewardlist[vo.type] = self.totalrewardlist[vo.type] + vo.num;
			end
			
			local txt = "";
			if vo.type == enAttrType.eaBindGold then
				txt = string.format( StrConfig["bingnu015"], vo.num);
			elseif vo.type == enAttrType.eaZhenQi then
				txt = string.format( StrConfig["bingnu016"], vo.num);
			elseif vo.type == enAttrType.eaBindMoney then
				txt = string.format( StrConfig["bingnu017"], vo.num);
			elseif vo.type == enAttrType.eaExp then
				txt = string.format( StrConfig["bingnu014"], vo.num);
			end
			UIBingNuFloat:ShowCenter(txt);
		end
	end
	
	Notifier:sendNotification( NotifyConsts.JieFengBingNuInfo, {count=msg.count} );
end

--设置快速解封信息
function ActivityBingNu:SetQuickJieFengInfo(msg)
	self.bingnucount = msg.count;
	
	--解封奖励信息列表
	for i,vo in pairs(msg.list) do
		if vo then
			if not self.totalrewardlist[vo.type] then
				self.totalrewardlist[vo.type] = vo.num;
			else
				self.totalrewardlist[vo.type] = self.totalrewardlist[vo.type] + vo.num;
			end
		end
	end
	
	Notifier:sendNotification( NotifyConsts.JieFengBingNuInfo, {count=msg.count} );
end