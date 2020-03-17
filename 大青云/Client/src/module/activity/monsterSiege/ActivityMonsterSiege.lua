--[[
	2015年8月28日, PM 02:47:26
	怪物攻城
	wangyanwei
]]

_G.ActivityMonsterSiege = BaseActivity:new(ActivityConsts.MonsterSiege);
ActivityModel:RegisterActivity(ActivityMonsterSiege);

function ActivityMonsterSiege:RegisterMsg()
	MsgManager:RegisterCallBack(MsgType.SC_MonsterSiegeWave,		self,	self.MonsterSiegeWave);			--怪物攻城波数信息
	MsgManager:RegisterCallBack(MsgType.SC_MonsterSiegeKillData,	self,	self.MonsterSiegeKillData);		--怪物攻城玩家击杀信息
	MsgManager:RegisterCallBack(MsgType.SC_MonsterSiegeData,		self,	self.MonsterSiegeData);			--怪物攻城数量信息
	MsgManager:RegisterCallBack(MsgType.SC_MonsterSiegeReward,		self,	self.MonsterSiegeReward);		--怪物攻城获得奖励
	MsgManager:RegisterCallBack(MsgType.SC_MonsterSiegeResult,		self,	self.MonsterSiegeResult);		--怪物攻城结局面板
	MsgManager:RegisterCallBack(MsgType.SC_MonsterSiegeKillRank,	self,	self.MonsterSiegeKillRank);		--怪物攻城击杀榜
end

--怪物攻城波数信息
function ActivityMonsterSiege:MonsterSiegeWave(msg)
	-- trace(msg)
	-- print('攻城信息------------------------------')
	local worldLevel 	= 	msg.worldLevel;		--世界等级
	local wave 			= 	msg.wave;			--第几波
	local killMonster 	= 	msg.killMonster;	--个人击杀怪物
	local killHuman 	= 	msg.killHuman;		--个人击杀玩家
	
	self:InitKillNum();							--初始击杀数量
	self:SetWorldLevel(worldLevel);				--世界等级
	self:SetWave(wave);
	self:SetKillMonster(killMonster);
	self:SetKillPlayer(killHuman);
	
	Notifier:sendNotification( NotifyConsts.MonsterSiegeWave);
end

--怪物攻城玩家击杀信息
function ActivityMonsterSiege:MonsterSiegeKillData(msg)
	-- trace(msg)
	-- print('state 0是怪物')
	local state			=	msg.state;			--0怪物   1 玩家
	
	self:SetKillNum(state);
	
	Notifier:sendNotification( NotifyConsts.MonsterSiegeKillInfo);
end

--怪物攻城数量信息
function ActivityMonsterSiege:MonsterSiegeData(msg)
	-- trace(msg)
	-- print('怪物数量刷新')
	local boss 			= 	msg.boss;			--boss数量
	local elite 		= 	msg.elite;			--精英数量
	local monster 		= 	msg.monster;		--怪物数量
	
	self:SetMonsterNum(boss,elite,monster);
	
	Notifier:sendNotification( NotifyConsts.MonsterSiegeMonsterData);
end

--怪物攻城获得奖励
function ActivityMonsterSiege:MonsterSiegeReward(msg)
	local list 			= 	msg.rewardlist;		--奖励列表
	-- local id 			= 	msg.id;				--奖励ID
	-- local num 			= 	msg.num;			--奖励个数
	
	self:SetRewardList(list);
	
	Notifier:sendNotification( NotifyConsts.MonsterSiegeReward);
end

--怪物攻城结局面板
function ActivityMonsterSiege:MonsterSiegeResult(msg)
	local result		=	msg.result;			--守卫结果 0成功
	
	UIMonsterSiegeResult:Show();				--打开结局面板
	UIMonsterSiegeInfo:Hide();					--关闭追踪面板
end

--BOSS击杀榜
function ActivityMonsterSiege:MonsterSiegeKillRank(msg)
	local killList = msg.killList;
	
	self:OnSetRankList(killList);
end

-----------------------------------------------------------------------

--进入活动执行方法
function ActivityMonsterSiege:OnEnter()
	UIActivity:Hide();
	UIMonsterSiegeInfo:Show();
	self:OnChangeTime();
end

function ActivityMonsterSiege:OnChangeTime()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	local num = activity:GetEndLastTime();
	local func = function ()
		num = num - 1;
		Notifier:sendNotification( NotifyConsts.BeicangjieTimeUpData,{timeNum = num} );
		if num == 0 then
			--ActivityController:QuitActivity(activity:GetId());
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			-- self:OnEnterQuit();
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000,num);
end

--退出活动执行
function ActivityMonsterSiege:OnQuit()
	UIMonsterSiegeInfo:Hide();
	UIMonsterSiegeResult:Hide();
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.rewardList = {};
	self.oldMonsterSiegeWave = 0;
end

function ActivityMonsterSiege:FinishRightQuit()
	return true;
end

--确认退出
function ActivityMonsterSiege:OnEnterQuit()
	self:DoQuit();
end

-----------------------------------set---------------------------------

--世界等级
ActivityMonsterSiege.worldLevel = 0;
function ActivityMonsterSiege:SetWorldLevel(level)
	self.worldLevel = level;
end

--波数
ActivityMonsterSiege.monsterSiegeWave = 0;
ActivityMonsterSiege.oldMonsterSiegeWave = 0;
function ActivityMonsterSiege:SetWave(wave)
	if self.oldMonsterSiegeWave ~= wave and self.oldMonsterSiegeWave ~= 0 then
		self.oldMonsterSiegeWave = wave;
		-- UIMonsterSiegeTimeTip:Open(wave);
		UIBingNuFloat:PlayDiJiLunEffect(wave);
	end
	self.monsterSiegeWave = wave;
	self.oldMonsterSiegeWave = wave;
end

--击杀数量信息

function ActivityMonsterSiege:InitKillNum()
	self.killMonsterNum = 0;
	self.killPlayerNum = 0;
end

ActivityMonsterSiege.killMonsterNum = 0;
function ActivityMonsterSiege:SetKillMonster(num)
	self.killMonsterNum = self.killMonsterNum + num;
end

ActivityMonsterSiege.killPlayerNum = 0;
function ActivityMonsterSiege:SetKillPlayer(num)
	self.killPlayerNum = self.killPlayerNum + num;
end

--击杀处理		_type类型  0怪物 1 玩家
function ActivityMonsterSiege:SetKillNum(_type)
	local _type = _type == 1;
	if _type then
		self:SetKillPlayer(1);
	else
		self:SetKillMonster(1);
	end
end

--剩余怪物数量
ActivityMonsterSiege.bossNum = 0;
ActivityMonsterSiege.eliteNum = 0;
ActivityMonsterSiege.monsterNum = 0;
function ActivityMonsterSiege:SetMonsterNum(boss,elite,monster)
	local wave = self:GetMonsterSiegeWave();
	local cfg = t_shouweibeicang[wave];
	if not cfg then return end
	local maxBoss 		= split(cfg.bossId,		',')[2] or 0;
	local maxElite 		= split(cfg.nbmonsterId,',')[2] or 0;
	local maxMonster 	= split(cfg.monsterId,	',')[2] or 0;
	
	self.bossNum	 = maxBoss 		- boss;
	self.eliteNum	 = maxElite 	- elite;
	self.monsterNum	 = maxMonster 	- monster;
end

--奖励列表
ActivityMonsterSiege.rewardList = {};
function ActivityMonsterSiege:SetRewardList(list)
	-- for i , v in pairs(list) do
		-- local haveItem = false;
		-- for j , k in pairs(self.rewardList) do
			-- if v.id == k.id then
				-- haveItem = true;
				-- k.num = k.num + v.num;
			-- end
		-- end
		-- if not haveItem then
			-- local vo = {};
			-- vo.id 	= v.id;
			-- vo.num 	= v.num;
			-- table.push(self.rewardList,vo);
		-- end
	-- end
	self.rewardList = {};
	self.rewardList = list;
end

--BOSS击杀榜list
ActivityMonsterSiege.killRank = {};
function ActivityMonsterSiege:OnSetRankList(killList)
	self.killRank = {};
	self.killRank = killList;
end

-----------------------------------get---------------------------------

--获取世界等级
function ActivityMonsterSiege:GetWorldLevel()
	return self.worldLevel;
end

--获取当前波数
function ActivityMonsterSiege:GetMonsterSiegeWave()
	return self:GetWorldLevel() * 10 + self.monsterSiegeWave;
end

function ActivityMonsterSiege:GetKillMonsterNum()
	return self.killMonsterNum;
end

function ActivityMonsterSiege:GetKillPlayerNum()
	return self.killPlayerNum;
end

--获取剩余怪物
function ActivityMonsterSiege:GetAllMonsterNum()
	return self.bossNum,self.eliteNum,self.monsterNum;
end

--获取奖励
function ActivityMonsterSiege:GetReward()
	return self.rewardList;
end

--获取当前的击杀榜list
function ActivityMonsterSiege:GetKillRank()
	return self.killRank;
end