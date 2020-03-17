--[[
世界Boss活动(基类)
lizhuangzhuang
2014年12月4日16:13:47
]]

_G.ActivityWorldBoss = setmetatable({},{__index=BaseActivity});
ActivityModel:RegisterActivityClass(ActivityConsts.T_WorldBoss,ActivityWorldBoss);

ActivityWorldBoss.worldBossList = {};
ActivityWorldBoss.hurtInfo = nil;
ActivityWorldBoss.meDamage = 0;--我造成的伤害
ActivityWorldBoss.hp = 0;
ActivityWorldBoss.maxHp = 0;
ActivityWorldBoss.state = 0; -- 状态：0或者，1死亡
ActivityWorldBoss.worldBossLineList = {}

function ActivityWorldBoss:RegisterMsg()
	MsgManager:RegisterCallBack(MsgType.WC_WorldBoss,self,self.OnWorldBossList);
	--同一时间只会受到一个世界boss的信息,直接放父类
	MsgManager:RegisterCallBack(MsgType.SC_WorldBossHurt,self,self.OnWorldBossHurt);
	MsgManager:RegisterCallBack(MsgType.SC_WorldBossDamage,self,self.OnWorldBossDamage);
end

function ActivityWorldBoss:GetType()
	return ActivityConsts.T_WorldBoss;
end

--获取活动对应的世界BossId
function ActivityWorldBoss:GetWorldBossId()
	local cfg = self:GetCfg();
	if not cfg then return 0; end
	return cfg.param1;
end

--获取世界Boss配表
function ActivityWorldBoss:GetWorldBossCfg()
	local cfg = self:GetCfg();
	if not cfg then return nil; end
	return t_worldboss[cfg.param1];
end

--获取活动奖励列表
--@return list {id,count} override
function ActivityWorldBoss:GetRewardList()
	local cfg = self:GetWorldBossCfg();
	if not cfg then return; end
	if cfg.display_reward == "" then return; end
	local t = split(cfg.display_reward,"#");
	for index, rewardStr in pairs(t) do
		t[index] = split( rewardStr, ',' )[1]
	end
	local list = {};
	for i,id in ipairs(t) do
		local vo = {};
		vo.id = toint(id);
		vo.count = 1;
		table.push(list,vo);
	end
	return list;
end


--返回世界Boss列表
function ActivityWorldBoss:OnWorldBossList(msg)
	self.worldBossLineList = {}
	for i,vo in ipairs(msg.list) do
		self.worldBossList[vo.id] = vo;
		--设置活动线
		local list = ActivityModel:GetActivityByType(self:GetType());
		for i,activity in ipairs(list) do
			if activity:GetWorldBossId() == vo.id then
				activity:SetLine(vo.line);
				activity:SetState(vo.state);
				local voo = {}
				voo.line = vo.line
				voo.bossId = vo.id
				table.push(self.worldBossLineList,voo) 
			end
		end
	end
	Notifier:sendNotification( NotifyConsts.WorldBossUpdate );
end

function ActivityWorldBoss:GetBossLine(bossId)
	if #self.worldBossLineList == 0 then return 0 end
	local bossLine = 0
	for k,v in pairs(self.worldBossLineList) do
		if v.bossId == bossId then
			bossLine = v.line
		end	
	end
	return bossLine
end
--返回活动内世界Boss受伤信息
--很蛋疼的写法,父类里要向子类塞数据(虽然同一时间只有一份数据,但是也不要用父类存储数据,fuckfuck)
function ActivityWorldBoss:OnWorldBossHurt(msg)
	local list = ActivityModel:GetActivityByType(self:GetType());
	for i,activity in ipairs(list) do
		if activity:GetWorldBossId() == ActivityController:GetCurrId() then
			activity:SetHurtInfo(msg);
		end
	end
end

function ActivityWorldBoss:OnSceneChange()
	UIWorldBossHurt:OnAutoFunc()
end

--返回我造成的伤害信息(父类行为)
function ActivityWorldBoss:OnWorldBossDamage(msg)
	local list = ActivityModel:GetActivityByType(self:GetType());
	for i,activity in ipairs(list) do
		if activity:GetWorldBossId() == ActivityController:GetCurrId() then
			activity:SetMeDemage(msg.damage);
		end
	end
end

function ActivityWorldBoss:SetState(state)
	if self.state ~= state then
		self.state = state
		if self.state == 0 then -- 从死亡变为活着状态，即复活时
			self:SetMeDemage(0) -- 将我的伤害清零
		end
	end
end

--设置活动伤害排行
--子类行为
function ActivityWorldBoss:SetHurtInfo(msg)
	self.hp = msg.hp;
	self.maxHp = msg.maxHp;
	self.hurtInfo = {};
	for i,vo in ipairs(msg.list) do
		if vo.roleID ~= "0_0" then
			table.push(self.hurtInfo,vo);
		end
	end
	Notifier:sendNotification( NotifyConsts.WorldBossHurt );
end

--子类行为
function ActivityWorldBoss:SetMeDemage(val)
	self.meDamage = val;
	Notifier:sendNotification( NotifyConsts.WorldBossMyDamage );
end

function ActivityWorldBoss:GetMeDamage()
	return self.meDamage;
end

--获取世界boss状态
function ActivityWorldBoss:GetWorldBossLive(id)
	if not self.worldBossList[id] then return false; end
	return self.worldBossList[id].state == 0;
end

--获取世界Boss信息
function ActivityWorldBoss:GetWorldBossInfo(id)
	return self.worldBossList[id];
end

--获取伤害排行
function ActivityWorldBoss:GetHurtInfo()
	return self.hurtInfo;
end

function ActivityWorldBoss:OnEnter()
	MainMenuController:HideRight()
	UIWorldBossHurt:Show();
end

function ActivityWorldBoss:OnQuit()
	MainMenuController:UnhideRight()
	UIWorldBossHurt:Hide();
	self.hurtInfo = nil;
	self.meDamage = 0;
	self.hp = 0;
	self.maxHp = 0;
end

function ActivityWorldBoss:DoNoticeCheck()
	if not FuncManager:GetFuncIsOpen(FuncConsts.WorldBoss) then
		return 0;
	end
	--所有世界Boss显示一个,fuck
	if self:GetId() ~= 1 then
		return 0;
	end
	if self.isNoticeClosed then
		return 0;
	end
	local cfg = self:GetWorldBossCfg();
	if not cfg then return 0; end
	local lastTime = WorldBossUtils:GetNextBirthLastTime(cfg.monster);
	if lastTime>=0 and lastTime<=300 then
		return 1;
	end
	return 0;
end

function ActivityWorldBoss:DoNoticeShow(uiItem)
	local cfg = self:GetWorldBossCfg();
	if not cfg then return; end
	local time = WorldBossUtils:GetNextBirthLastTime(cfg.monster);
	time = time<0 and 0 or time;
	uiItem.tf1.text = StrConfig['activity205'];
	local _,min,sec = CTimeFormat:sec2format(time)
	uiItem.tf2.text = string.format(StrConfig['activity206'],min,sec);
	local iconUrl = ResUtil:GetActivityNoticeUrl(self:GetCfg().noticeIcon);
	if iconUrl ~= uiItem.iconLoader.source then
		if uiItem.iconLoader.initialized then
			uiItem.iconLoader.source = iconUrl;
		else
			if not uiItem.iconLoader.init then
				uiItem.iconLoader.init = function()
					uiItem.iconLoader.source = iconUrl;
				end
			end
		end
	end
end

function ActivityWorldBoss:DoNoticeClick()
	FuncManager:OpenFunc(FuncConsts.WorldBoss,false)
end

function ActivityWorldBoss:GetNoticeOpenTimeStr()
	-- local cfg = self:GetWorldBossCfg()
	-- if not cfg then return end
	-- local birthList = WorldBossUtils:GetBirthTime( cfg.monster )
	-- local t = {}
	-- for i, time in ipairs(birthList) do
	-- 	local hour,min = CTimeFormat:sec2format(time)
	-- 	table.push( t, string.format("%02d:%02d", hour, min) )
	-- end
	-- return string.format( StrConfig['worldBoss301'], table.concat(t, '、') );
	return string.format(  StrConfig['worldBoss302'] );
end
function ActivityWorldBoss:IsOpen()
	local openLevel=t_funcOpen[FuncConsts.WorldBoss].open_level;
    return MainPlayerModel.humanDetailInfo.eaLevel>=openLevel;
end
function ActivityWorldBoss:IsExist()
    local isopenshenmo= t_consts[307].val1;
    if not isopenshenmo then return;end
	return MainPlayerModel.humanDetailInfo.eaLevel>=isopenshenmo;
end