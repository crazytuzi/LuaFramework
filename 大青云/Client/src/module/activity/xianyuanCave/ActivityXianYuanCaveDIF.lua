--[[
	2015年9月19日, PM 04:49:16
	wangyanwei
	困难级别的仙缘洞府
]]

_G.ActivityDIFXuanYuanCave = BaseActivity:new(ActivityConsts.T_DaBaoMiJing);
ActivityModel:RegisterActivity(ActivityDIFXuanYuanCave);

ActivityDIFXuanYuanCave.hurtInfo = {};
ActivityDIFXuanYuanCave.maxHp = 0;
ActivityDIFXuanYuanCave.damage = 0;

function ActivityDIFXuanYuanCave:RegisterMsg()
	MsgManager:RegisterCallBack(MsgType.SC_XianYuanCaveBossState,self,self.ChangeBossState);
	MsgManager:RegisterCallBack(MsgType.SC_MiJingBossHurt,self,self.BackMiJingBossHurtData);
	MsgManager:RegisterCallBack(MsgType.SC_MiJingBossDamage,self,self.BackMiJingBossDamageData);
	MsgManager:RegisterCallBack(MsgType.SC_MiJingBossReward, self,self.MiJingBossExpResult)
end

-- 进入活动执行方法
function ActivityDIFXuanYuanCave:OnEnter()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

-- 秘境获得经验提示
function ActivityDIFXuanYuanCave:MiJingBossExpResult(msg)
	UIXianYuanCaveInfo:OnAllExpBack(msg.expday)
	UIXianYuanCaveInfo:OnExpBack(msg.exp)
end

function ActivityDIFXuanYuanCave:Update()
	if not self.startTime then return end
	if GetCurTime(true) - self.startTime >= 180 then
		local player = MainPlayerController:GetPlayer()
		if not player or player:IsDead() or player:IsMoveState() or AutoBattleController:GetAutoHang() then
			self.startTime = nil
			return
		end
		self:GotoFight()
	end
end

local funcSplit = function(str)
	local list = {}
	local list1 = split(str, "#")
	for i, v in ipairs(list1) do
		local lvPos = split(v, ",")
		table.insert(list, lvPos)
	end
	return list
end

function ActivityDIFXuanYuanCave:OnSceneChange()
	self.startTime = GetCurTime(true)
	self:GotoFight()
end

function ActivityDIFXuanYuanCave:GotoFight()
	local pos = self:GetMonsterPos()
	if pos then
		local autoBattleFunc = function() AutoBattleController:SetAutoHang(); end
		MainPlayerController:DoAutoRun(toint(pos[1]), _Vector3.new(toint(pos[2]), toint(pos[3]), 0), autoBattleFunc)
	end
	UIXianYuanCave:Hide();
	UIXianYuanCaveInfo:Show();
end

--- 获取坐标
function ActivityDIFXuanYuanCave:GetMonsterPos()
	local lv = MainPlayerModel.humanDetailInfo.eaLevel
	local mapId =  CPlayerMap:GetCurMapID()
	local cfg = self:GetCfg()
	local acMapId = split(cfg.mapid, ",")
	for k, v in pairs(acMapId) do
		if mapId == toint(v) then
			local xianyuanCfg = t_xianyuancave[k]
			if not xianyuanCfg then return end
			local lvPos = funcSplit(xianyuanCfg.monsterPos)
			local posid
			for i, v in ipairs(lvPos) do
				if toint(v[1]) <= lv then
					posid = toint(v[2])
					self.name = v[3]
				else
					break
				end
			end
			if posid then
				local posCfg = t_position[posid]
				if posCfg then
					local posT = split(posCfg.pos, "|")
					local posStr = posT[math.random(#posT)]
					self.pos = split(posStr, ",")
					return self.pos, self.name
				end
			end
		end
	end
end

--- 获取层数
function ActivityDIFXuanYuanCave:GetFloor()
	local mapId =  CPlayerMap:GetCurMapID()
	local cfg = self:GetCfg()
	local acMapId = split(cfg.mapid, ",")
	for k, v in ipairs(acMapId) do
		if mapId == toint(v) then
			return k
		end
	end
end

-- 退出活动执行方法
function ActivityDIFXuanYuanCave:OnQuit()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.pos = nil
	self.name = nil
	self.startTime = nil
	UIXianYuanCaveInfo:Hide();
	self.hurtInfo = {};
	self.maxHp = 0;
	self.damage = 0
end

ActivityDIFXuanYuanCave.bossID = 0;
ActivityDIFXuanYuanCave.bossState = 0;
function ActivityDIFXuanYuanCave:ChangeBossState(msg)
	local obj = msg;
	self.bossID = msg.id;
	self.bossState = msg.num;
	self.pos = nil
	
	Notifier:sendNotification(NotifyConsts.CaveBossState);
	
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

function ActivityDIFXuanYuanCave:GetBossID()
	return self.bossID;
end

function ActivityDIFXuanYuanCave:GetBossState()
	return self.bossState;
end

function ActivityDIFXuanYuanCave:IsExcessivePilao()
	local pilaoValue = MainPlayerModel.humanDetailInfo.eaPiLao;
	local caveCons	= t_consts[62];
	return pilaoValue >= caveCons.val1
end

-- 返回boss伤害
function ActivityDIFXuanYuanCave:BackMiJingBossHurtData( msg )
	self.hurtInfo = {}
	self.maxHp = msg.maxHp
	for i,vo in ipairs(msg.list) do
		if vo.roleID ~= "0_0" then
			table.push(self.hurtInfo,vo);
		end
	end
	Notifier:sendNotification( NotifyConsts.CaveBossHurt );
end

--返回总伤害总量
function ActivityDIFXuanYuanCave:BackMiJingBossDamageData( msg )
	self.damage = msg.damage
	Notifier:sendNotification( NotifyConsts.CaveDamage );
end

-- 获取伤害总量
function ActivityDIFXuanYuanCave:GetMiJingBossDamageData( )
	return self.damage
end

--获取boss伤害排行
function ActivityDIFXuanYuanCave:GetBossHurtData()
	return self.hurtInfo;
end

-- 获取Boss总血量
function ActivityDIFXuanYuanCave:GetMaxBossHp()
	return self.maxHp
end
