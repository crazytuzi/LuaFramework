--[[
活动：死亡遗迹
lizhuangzhuang
2015年11月23日23:43:32
]]

_G.ActivitySiWangYiJi = setmetatable({},{__index=BaseActivity});
ActivityModel:RegisterActivityClass(ActivityConsts.T_SiWangYiJi,ActivitySiWangYiJi);

ActivitySiWangYiJi.StatueStat_NON = 0;
ActivitySiWangYiJi.StatueStat_Lock = 1;
ActivitySiWangYiJi.StatueStat_Boss = 2;
ActivitySiWangYiJi.StatueStat_Die = 3;

ActivitySiWangYiJi.guildId = nil;
ActivitySiWangYiJi.guildName = nil;
ActivitySiWangYiJi.statueStat = 0;
ActivitySiWangYiJi.statueHp = 0;
ActivitySiWangYiJi.statueMaxHp = 0;
ActivitySiWangYiJi.bossStat = 0;
ActivitySiWangYiJi.statueTime = 0;

ActivitySiWangYiJi.hasShowEnterRemind = false;

function ActivitySiWangYiJi:GetType()
	return ActivityConsts.T_SiWangYiJi;
end

function ActivitySiWangYiJi:RegisterMsg()
	--父类
	-- MsgManager:RegisterCallBack(MsgType.SC_EnterSWYJ,self,self.OnEnterSWYJ);
	-- MsgManager:RegisterCallBack(MsgType.SC_SWYJUpdate,self,self.OnSWYJUpdate);
	-- MsgManager:RegisterCallBack(MsgType.SC_SWYJStatueOper,self,self.OnSWYJStatueOper);
	MsgManager:RegisterCallBack(MsgType.WC_SWYJStatueBeHit,self,self.OnSWYJStatueBeHit);
end

--处理消息
function ActivitySiWangYiJi:OnEnterSWYJ(msg)
	if msg.rst == 0 then
	
	else
		print("传送失败");
	end
end

function ActivitySiWangYiJi:OnSWYJUpdate(msg)
	local list = ActivityModel:GetActivityByType(self:GetType());
	for i,activity in ipairs(list) do
		if activity:GetId() == msg.id then
			activity:SetSWYJUpdate(msg.guildId,msg.guildName,msg.statueStat,msg.statueHp,msg.statueMaxHp,msg.bossStat,msg.statueTime);
		end
	end
end

function ActivitySiWangYiJi:OnSWYJStatueOper(msg)
	if msg.result == -1 then
		FloatManager:AddNormal(StrConfig["activityswyj032"]);
	elseif msg.result == -2 then
		FloatManager:AddNormal(StrConfig["activityswyj033"]);
	elseif msg.result == -3 then
		if msg.type == 1 then
			FloatManager:AddNormal(StrConfig["activityswyj031"]);
		else
			FloatManager:AddNormal(StrConfig["activityswyj020"]);
		end
	elseif msg.result == -4 then
		FloatManager:AddNormal(StrConfig["activityswyj032"]);
	elseif msg.result == -5 then
		if msg.type == 1 then
			FloatManager:AddNormal(StrConfig["activityswyj034"]);
		else
			FloatManager:AddNormal(StrConfig["activityswyj035"]);
		end
	elseif msg.result == 0 then
		print("操作成功")
	else
		print(msg.result)
	end
end

function ActivitySiWangYiJi:OnSWYJStatueBeHit(msg)
	RemindController:AddRemind(RemindConsts.Type_SWYJ,msg.id);
end

function ActivitySiWangYiJi:SetSWYJUpdate(guildId,guildName,statueStat,statueHp,statueMaxHp,bossStat,statueTime)
	self.guildId = guildId;
	self.guildName = guildName;
	self.statueStat = statueStat;
	self.statueHp = statueHp;
	self.statueMaxHp = statueMaxHp;
	self.bossStat = bossStat;
	self.statueTime = statueTime;
	self:CheckEnterRemind();
	--
	UISWYJRight:UpdateInfo();
end

function ActivitySiWangYiJi:GetSWYJCfg()
	local cfg = self:GetCfg();
	if not cfg then return nil; end
	return t_swyj[cfg.param1];
end

function ActivitySiWangYiJi:GetBossStat()
	if not self.bossStat then return 0; end
	return self.bossStat;
end

function ActivitySiWangYiJi:GetGuildName()
	if not self.guildName then return ""; end
	return self.guildName;
end

function ActivitySiWangYiJi:GetStatueStat()
	if not self.statueStat then return ActivitySiWangYiJi.StatueStat_NON; end
	return self.statueStat;
end

--是否是我的雕像
function ActivitySiWangYiJi:IsMyStatue()
	if not self.statueStat then return false; end
	if self.statueStat == ActivitySiWangYiJi.StatueStat_NON then
		return false;
	end
	if not self.guildId then return false; end
	if self.guildId == "0_0" then return false; end
	return UnionModel:GetMyUnionId()==self.guildId;
end

function ActivitySiWangYiJi:OnSceneChange()
	self:CheckEnterRemind();
end

function ActivitySiWangYiJi:OnEnter()
	UISWYJRight:Show();
end

function ActivitySiWangYiJi:OnQuit()
	UISWYJRight:Hide();
	self.guildId = nil;
	self.guildName = nil;
	self.statueStat = 0;
	self.statueHp = 0;
	self.statueMaxHp = 0;
	self.bossStat = 0;
	self.hasShowEnterRemind = false;
end

--传送到雕像
function ActivitySiWangYiJi:StatueTelport()
	if not self:IsMyStatue() then return; end
	--在当前层,直接寻路过去
	if self:GetStatueTelportStat() == 1 then
		local msg = ReqEnterSWYJMsg:new();
		msg.id = self:GetId();
		MsgManager:Send(msg);
	else
		self:StatueGo();
	end
end

--传送状态,1传送,2走过去
function ActivitySiWangYiJi:GetStatueTelportStat()
	local mapId = CPlayerMap:GetCurMapID();
	for _,cfg in pairs(t_swyj) do
		local t = split(cfg.statuePosition,",");
		if #t > 0 then
			if toint(t[1]) == mapId then
				return 2;
			end
		end
	end
	return 1;
end

--走到雕像
function ActivitySiWangYiJi:StatueGo()
	local cfg = self:GetSWYJCfg();
	if not cfg then return; end
	local t = split(cfg.statuePosition,",");
	MainPlayerController:DoAutoRun(toint(t[1]),_Vector3.new(toint(t[2]),toint(t[3]),0));
end

--走到boss
function ActivitySiWangYiJi:BossGo()
	local cfg = self:GetSWYJCfg();
	if not cfg then return; end
	local t = split(cfg.bossPosition,",");
	MainPlayerController:DoAutoRun(toint(t[1]),_Vector3.new(toint(t[2]),toint(t[3]),0),
									function()
										if self:GetBossStat() == 1 then
											AutoBattleController:SetAutoHang();
										end
									end);
end

--激活雕像
function ActivitySiWangYiJi:StatueActive()
	if self:GetStatueStat() ~= ActivitySiWangYiJi.StatueStat_Lock then return; end
	if not UnionUtils:CheckMyUnion() then
		FloatManager:AddNormal(StrConfig["activityswyj030"]);
		return;
	end
	if self:IsMyStatue() then 
		FloatManager:AddNormal(StrConfig["activityswyj038"]);
		return; 
	end
	if UnionModel.MyUnionInfo.pos < UnionConsts.DutyElder then
		FloatManager:AddNormal(StrConfig["activityswyj031"]);
		return;
	end
	local msg = ReqSWYJStatueOperMsg:new();
	msg.id = self:GetId();
	msg.type = 1;
	MsgManager:Send(msg);
end

--修复雕像
function ActivitySiWangYiJi:StatueRepair()
	if self:GetStatueStat() ~= ActivitySiWangYiJi.StatueStat_Die then return; end
	if not UnionUtils:CheckMyUnion() then
		FloatManager:AddNormal(StrConfig["activityswyj030"]);
		return;
	end
	if not self:IsMyStatue() then 
		FloatManager:AddNormal(StrConfig["activityswyj039"]);
		return; 
	end
	if UnionModel.MyUnionInfo.pos < UnionConsts.DutyElder then
		FloatManager:AddNormal(StrConfig["activityswyj020"]);
		return;
	end
	UIConfirm:Open(string.format(StrConfig["activityswyj046"],toint(t_consts[152].val1/10000,-1)),function()
		local msg = ReqSWYJStatueOperMsg:new();
		msg.id = self:GetId();
		msg.type = 2;
		MsgManager:Send(msg);
	end);
end

--进入时播放提醒
function ActivitySiWangYiJi:CheckEnterRemind()
	if self.hasShowEnterRemind then return; end
	if not self.guildId then return; end
	if self:GetStatueStat() == ActivitySiWangYiJi.StatueStat_NON then
		TimerManager:RegisterTimer(function()
			FloatManager:AddActivity(string.format(StrConfig['activityswyj045'],self.guildName));
		end,1000,1);
	else
		TimerManager:RegisterTimer(function()
			FloatManager:AddActivity(string.format(StrConfig['activityswyj028'],self.guildName));
		end,1000,1);
	end
	self.hasShowEnterRemind = true;
end

function ActivitySiWangYiJi:DoNoticeCheck()
	if not FuncManager:GetFuncIsOpen(FuncConsts.PersonalBoss) then
		return 0;
	end
	--所有Boss显示一个,fuck
	if self:GetId() ~= 10013 then
		return 0;
	end
	if self.isNoticeClosed then
		return 0;
	end
	local cfg = self:GetSWYJCfg();
	if not cfg then return; end
	local lastTime = WorldBossUtils:GetNextBirthLastTime(cfg.bossId);
	if lastTime>=0 and lastTime<=300 then
		return 1;
	end
	return 0;
end

function ActivitySiWangYiJi:DoNoticeShow(uiItem)
	local cfg = self:GetSWYJCfg();
	if not cfg then return; end
	local time = WorldBossUtils:GetNextBirthLastTime(cfg.bossId);
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

function ActivitySiWangYiJi:DoNoticeClick()
	FuncManager:OpenFunc(FuncConsts.PersonalBoss);
end

function ActivitySiWangYiJi:GetNoticeOpenTimeStr()
	return string.format(  StrConfig['worldBoss302'] );
end