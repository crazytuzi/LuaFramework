--[[
	2015年1月9日, PM 12:10:46
	仙缘洞府活动
	wangyanwei
]]
_G.ActivityXuanYuanCave = BaseActivity:new(ActivityConsts.XianYuan);
ActivityModel:RegisterActivity(ActivityXuanYuanCave);

function ActivityXuanYuanCave:RegisterMsg()
	MsgManager:RegisterCallBack(MsgType.SC_XianYuanCaveBossState,self,self.ChangeBossState);
end

-- 进入活动执行方法
function ActivityXuanYuanCave:OnEnter()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	UIXianYuanCave:Hide();
	UIXianYuanCaveInfo:Show();
end
-- 退出活动执行方法
function ActivityXuanYuanCave:OnQuit()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	UIXianYuanCaveInfo:Hide();
	self.bossID = 0 ;
	self.bossState = 0 ;
	

end

function ActivityXuanYuanCave:OnSceneChange()
	
end

ActivityXuanYuanCave.bossID = 0;
ActivityXuanYuanCave.bossState = 0;
function ActivityXuanYuanCave:ChangeBossState(msg)
	local obj = msg;
	self.bossID = msg.id;
	self.bossState = msg.num;
	-- UIXianYuanCaveInfo:OnShowCaveTxtInfo();
	-- UIXianYuanCaveInfo:OnShowCaveBossInfo();
	
	Notifier:sendNotification(NotifyConsts.CaveBossState);
	
	
	-- local tiemNum = msg.num;
	
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	
	local func = function () 
		self.bossState = self.bossState - 1;
		if self.bossState < 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function ActivityXuanYuanCave:GetBossID()
	return self.bossID;
end

function ActivityXuanYuanCave:GetBossState()
	return self.bossState;
end

function ActivityXuanYuanCave:IsExcessivePilao()
	local pilaoValue = MainPlayerModel.humanDetailInfo.eaPiLao;
	local caveCons	= t_consts[62];
	return pilaoValue >= caveCons.val1
end


