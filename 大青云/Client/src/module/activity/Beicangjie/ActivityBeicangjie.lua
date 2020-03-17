--[[
	2015年4月2日, AM 11:00:42
	血战北仓街活动
	wangyanwei&houxudong
	这个类 类似于ActivityBeicangjieController
]]

_G.ActivityBeicangjie = BaseActivity:new(ActivityConsts.Beicangjie);
--@adder: houxudong date:2106/7/13 PM 16:21:50
--@reason: 注册活动分为两种注册模式
--@method1.一种活动类型对应一个活动id，采用RegisterActivity注册
--@method2.一种活动类型对应多个活动id，采用RegisterActivityClass注册
ActivityModel:RegisterActivityClass(ActivityConsts.T_Beicangjie,ActivityBeicangjie); 

function ActivityBeicangjie:RegisterMsg()
	MsgManager:RegisterCallBack(MsgType.SC_BackBeiCangJieIntegral,self,self.BeiCangJieIntegral);    --服务器刷新，刷新积分
	MsgManager:RegisterCallBack(MsgType.SC_BackBeiCangJieEnd,self,self.BeiCangJieEnd);
	MsgManager:RegisterCallBack(MsgType.SC_BackBeiCangJieRank,self,self.BeiCangJieRank);  --返回北仓界排行榜,排行榜信息改变就会发送更新数据
	MsgManager:RegisterCallBack(MsgType.SC_BackBeicangjieQuit,self,self.BackBeicangjieQuit);
	MsgManager:RegisterCallBack(MsgType.SC_BackBeicangjieCon,self,self.BackBeiCangJieEnter);
	MsgManager:RegisterCallBack(MsgType.SC_BackBeiCangRankIndex,self,self.BackBeiCangRankIndex);  --我的排名
	--怪物刷新协议
	MsgManager:RegisterCallBack(MsgType.SC_BackBeiCangJieBossUpDataInfo,self,self.BackBeiCangJieBossUpDataInfo);
	MsgManager:RegisterCallBack(MsgType.SC_BackBeiCangJieBossInfo,self,self.BackBeiCangJieBossInfo);
	MsgManager:RegisterCallBack(MsgType.SC_BackBeiCangJieMonsterInfo,self,self.BackBeiCangJieMonsterInfo);

	--adder:houxudong date:2016-7-16
	--累计击杀和当前击杀协议
	MsgManager:RegisterCallBack(MsgType.SC_BackBeiCangJieKill,self,self.BackBeiCangJieKillDataInfo);
end

-- function ActivityBeicangjie:OnGetIsInActivity()
	-- local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	-- if not activity then return false end
	-- if activity:GetId() == ActivityConsts.Beicangjie then
		-- if activity:IsIn() then
			-- return true
		-- end
		-- return true
	-- end
	-- return false
-- end

-- 进入活动执行方法
function ActivityBeicangjie:OnEnter()
	-- UIBeicangjieInfo:Hide();
	UIRevive.IsShowOriginLifeRevive = true;
	UIActivity:Hide();
	UIBeicangjieInfo:Show();
	local cfg = split(t_consts[50].param,'#');
	self.tegralNum = toint(cfg[1]);
	Notifier:sendNotification( NotifyConsts.BeicangjieUpData );
	self:OnChangeTime();
	UIActivityBeicangjieInTip:Show();
end

function ActivityBeicangjie:OnChangeTime()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	local num = activity:GetEndLastTime();
	local func = function ()
		num = num - 1;
		Notifier:sendNotification( NotifyConsts.BeicangjieTimeUpData,{timeNum = num} );
		if num == 0 then
			ActivityController:QuitActivity(activity:GetId());
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000,num);
end

-- 退出活动执行方法
function ActivityBeicangjie:OnQuit()
	UIBeicangjieInfo:Hide();
	UIBeicangjieBossInfo:Hide();
	UIBeicangjieResult:Hide();
	MainMenuController:UnhideRight();
	MainMenuController:UnhideRightTop();
	MapController:OnQuitBcj()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.rankList = {};
	UIRevive.IsShowOriginLifeRevive = false;
end

function ActivityBeicangjie:FinishRightQuit()
	return false;
end

--刷新积分
ActivityBeicangjie.tegralNum = 0;
function ActivityBeicangjie:BeiCangJieIntegral(msg)
	-- if self.tegralNum ~= 0 then
		-- local state;
		-- local num;
		-- if self.tegralNum < msg.num then
			-- state = 2;
			-- num = msg.num - self.tegralNum;
			-- UIActivityBeicangjieIntegal:Open(state,num); 
		-- elseif self.tegralNum > msg.num then
			-- state = 1;
			-- num = self.tegralNum - msg.num ;
			-- UIActivityBeicangjieIntegal:Open(state,num); 
		-- end
	-- end
	self.tegralNum = msg.num;
	if UIBeicangjieInfo:IsShow() then
		Notifier:sendNotification( NotifyConsts.BeicangjieUpData );
	end
end

--结局面板
function ActivityBeicangjie:BeiCangJieEnd(msg)
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	UIBeicangjieInfo:Hide();
	UIBeicangjieBossInfo:Hide();
	UIBeicangjieResult:Open(msg)
end

--排行榜
ActivityBeicangjie.rankList = {};
function ActivityBeicangjie:BeiCangJieRank(msg)
	-- trace(msg)
	self.rankList = msg.list;
	Notifier:sendNotification( NotifyConsts.BeicangjieRank );
end

function ActivityBeicangjie:GetRankData()
	return self.rankList;
end

--排行榜中自己的名次  or 未上榜
function ActivityBeicangjie:OnGetIsInRank()
	return self.myRankIndex;
end

function ActivityBeicangjie:GetMyTegralNum()
	return self.tegralNum;
end

--请求领奖退出
function ActivityBeicangjie:OnGetRewardQuit()
	local msg = ReqBeicangjieQuitMsg:new();
	-- WriteLog(LogType.Normal,true,'-------------点击退出:',GetCurTime())
	MsgManager:Send(msg);
	self:DoQuit();
end

--请求继续挑战
--changer：houxudong date:2016/8/2  封神乱斗不进入北仓殿
function ActivityBeicangjie:OnGetConBeicangjie()
	local msg = ReqBeicangjieConMsg:new();
	MsgManager:Send(msg);
end

--返回退出
function ActivityBeicangjie:BackBeicangjieQuit(msg)
	if msg.result == 1 then 
		return 
	end
	-- WriteLog(LogType.Normal,true,'-------------服务器返回:',msg.result,GetCurTime())
	MainMenuController:UnhideRight();
	MainMenuController:UnhideRightTop();
	if UIBeicangjieResult:IsShow() then
		UIBeicangjieResult:Hide();
	end
end

--退出活动
function ActivityBeicangjie:QuitActivity()
	ActivityController:QuitActivity(activity:GetId());
	UIRevive.IsShowOriginLifeRevive = false;
end

--返回进入
function ActivityBeicangjie:BackBeiCangJieEnter(msg)
	if msg.result == 1 then 
		return 
	end
	if UIBeicangjieResult:IsShow() then
		UIBeicangjieResult:Hide();
	end
	UIBeicangjieBossInfo:Show();
end

--返回BOSS信息
function ActivityBeicangjie:BackBeiCangJieBossUpDataInfo(msg)
	local timeNum = msg.timeNum;
	Notifier:sendNotification( NotifyConsts.BeicangjieBossTime,{timeNum = timeNum} );
end

function ActivityBeicangjie:BackBeiCangJieBossInfo(msg)
	local location = msg.location;
	Notifier:sendNotification( NotifyConsts.BeicangjieNewBoss,{location = location} );
end

function ActivityBeicangjie:BackBeiCangJieMonsterInfo(msg)
	local eliteNum = msg.eliteNum;
	local commonNum = msg.commonNum;
	Notifier:sendNotification( NotifyConsts.BeicangjieMonsterNum,{commonNum = commonNum,eliteNum = eliteNum} );
end

--返回我的名次
ActivityBeicangjie.myRankIndex = 0;
function ActivityBeicangjie:BackBeiCangRankIndex(msg)
	local rankIndex = msg.rankIndex
	self.myRankIndex = rankIndex;
end
ActivityBeicangjie.accountKill = 0;
ActivityBeicangjie.currKill = 0;
--返回我的积累击杀数据
function ActivityBeicangjie:BackBeiCangJieKillDataInfo(msg)
	self.accountKill = msg.accKill
	self.currKill = msg.continueKill
	Notifier:sendNotification( NotifyConsts.BeicangJieKill);
end

function ActivityBeicangjie:GetKilllData()
	return self.accountKill,self.currKill
end

-- --封神乱斗战死是否显示原点复活
-- function ActivityBeicangjie:IsShowOriginLifeRevive( )
-- 	return self.isShowReceive;
-- end