--[[
	2015年10月20日22:13:36
	wangyanwei
	福神降临
]]

_G.ActivityMascotCome = setmetatable({},{__index=BaseActivity});
-- ActivityModel:RegisterActivity(ActivityMascotCome);
ActivityModel:RegisterActivityClass(ActivityConsts.T_MascotCome,ActivityMascotCome)
ActivityMascotCome.currentChooseMascotComeActivityID = 0;

function ActivityMascotCome:RegisterMsg()
	MsgManager:RegisterCallBack(MsgType.SC_MascotComeType,		self,	self.MascotComeType);		--福神降临(抢门活动)进入类型
	MsgManager:RegisterCallBack(MsgType.SC_MascotComeInfo,		self,	self.MascotComeInfo);		--福神降临(抢门活动)副本内信息
	MsgManager:RegisterCallBack(MsgType.SC_MascotComeResult,	self,	self.MascotComeResult);		--福神降临(抢门活动)结局面板
	MsgManager:RegisterCallBack(MsgType.SC_MascotComePortalNum,	self,	self.MascotComePortalNum);	--福神降临(抢门活动)传送门剩余数量
end

ActivityMascotCome.dungeonType = 0;
function ActivityMascotCome:MascotComeType(msg)
	self.dungeonType	= msg.type;
	MainMenuController:HideRight();
	MainMenuController:HideRightTop();
	UIMascotComeInfo:Show();
	self:TimeChange();
	-- trace('=================')
	-- debug.debug();
	-- Notifier:sendNotification(NotifyConsts.MascotComeType);
end

ActivityMascotCome.wave = 0;
ActivityMascotCome.oldWave = 0;
ActivityMascotCome.monsterNum = 0;
function ActivityMascotCome:MascotComeInfo(msg)
	self.wave 			= msg.wave;				--波数
	self.monsterNum 	= msg.monsterNum;		--怪物数量
	-- trace(msg)
	-- debug.debug();
	Notifier:sendNotification(NotifyConsts.MascotComeUpDate);
end

ActivityMascotCome.resultState = 0;
function ActivityMascotCome:MascotComeResult(msg)
	self.resultState 	= msg.result;			--挑战结果 0成功
	-- trace(msg)
	-- debug.debug();
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	UIMascotComeInfo:Hide();
	UIMoscotComeResult:Show();
end

function ActivityMascotCome:OnEnter()
	-- UIMascotComeInfo:Show();
end
-- 切换完场景后执行
function ActivityMascotCome:OnSceneChange()
	AutoBattleController:OpenAutoBattle()  --自动挂机
end
function ActivityMascotCome:OnQuit()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	UIMascotComeInfo:Hide();
	UIMoscotComeResult:Hide();
	self.dungeonType = 0;
	self.wave = 0;
	self.monsterNum = 0;
end

--开始计时
function ActivityMascotCome:TimeChange()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local constsCfg = t_consts[120];
	if not constsCfg then return end
	local timeNum = constsCfg.fval * 60;
	local func = function()
		Notifier:sendNotification(NotifyConsts.MascotComeTime,{timeNum = timeNum});
		timeNum = timeNum - 1;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end


ActivityMascotCome.mascotComeNoticeNum = 0;
ActivityMascotCome.mascotComeNoticeMapID = 0;
function ActivityMascotCome:MascotComePortalNum(msg)
	self.mascotComeNoticeNum = msg.num;
	self.mascotComeNoticeMapID = msg.mapID;
	
	if not UIMoscotComeNotice:IsShow() then
		UIMoscotComeNotice:UpDateNotice();
	else
		Notifier:sendNotification(NotifyConsts.MascotComeNotice,{timeNum = timeNum});
	end
end


--活动状态改变
function ActivityMascotCome:OnStateChange()
	local activity = ActivityModel:GetActivity(ActivityConsts.MascotCome);
	if not activity then return end
	if activity:GetId() == ActivityConsts.MascotCome then
		MascotComeNoticeManager:CloseCfg();
	end
end


----------===========>>>>>paneldata<<<<<==========------------

--获取传送门地图ID
function ActivityMascotCome:GetPortalMapID()
	return self.mascotComeNoticeMapID;
end

--获取传送门数量
function ActivityMascotCome:GetPortalNum()
	return self.mascotComeNoticeNum;
end

--副本类型
function ActivityMascotCome:GetDungeonType()
	return self.dungeonType;
end

--波数
function ActivityMascotCome:GetWaveNum()
	return self.wave;
end

--怪物数量
function ActivityMascotCome:GetMonsterNum()
	return self.monsterNum;
end

--获取结局类型
function ActivityMascotCome:GetResult()
	return self.resultState;
end

function ActivityMascotCome:GetNoticeOpenTimeStr()
	return "全天定时开启";
end