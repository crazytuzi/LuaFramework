--[[
死亡遗迹右侧面板
lizhuangzhuang
2015年11月24日16:44:43
]]

_G.UISWYJRight = BaseUI:new("UISWYJRight");

UISWYJRight.activity = nil;
UISWYJRight.timerKey = nil;
UISWYJRight.statueTimerKey = nil;

function UISWYJRight:Create()
	self:AddSWF("swyjRightPanel.swf",true,"bottom");
end

function UISWYJRight:OnLoaded(objSwf)
	objSwf.btnRule.htmlLabel = StrConfig["activityswyj026"];
	objSwf.btnRule.rollOver = function() TipsManager:ShowBtnTips(StrConfig["activityswyj027"],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.tfBossKey.htmlText = StrConfig["activityswyj002"];
	objSwf.panel.tfRefreshTimeKey.htmlText = StrConfig["activityswyj003"];
	objSwf.panel.tfStatueStateKey.htmlText = StrConfig["activityswyj004"];
	objSwf.panel.tfGuildNameKey.htmlText = StrConfig["activityswyj005"];
	objSwf.panel.tfInfoKey.htmlText = StrConfig["activityswyj006"];
	objSwf.panel.tfInfo.htmlText = StrConfig["activityswyj007"];
	objSwf.panel.btnQuit.label = StrConfig["activityswyj008"];
	objSwf.panel.btnGo.htmlLabel = StrConfig["activityswyj029"];
	--
	objSwf.btnOpenClose.click = function() 
									objSwf.panel._visible = not objSwf.btnOpenClose.selected;
									objSwf.panel.hitTestDisable = not objSwf.panel._visible;
									objSwf.btnRule.visible = not objSwf.btnOpenClose.selected;
								end
	objSwf.panel.btnQuit.click = function() self:OnBtnQuitClick(); end
	objSwf.panel.btnTeleport.rollOver = function() self:OnBtnTeleportOver(); end
	objSwf.panel.btnTeleport.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.btnTeleport.click = function() self:OnBtnTeleportClick(); end
	objSwf.panel.btnGo.click = function() self:OnBtnGoClick(); end
	objSwf.panel.btnStatueState.rollOver = function() self:OnBtnStatueStateOver(); end
	objSwf.panel.btnStatueState.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.btnBossName.click = function() self:OnBtnBossNameClick(); end
end

function UISWYJRight:GetWidth()
	return 247;
end

function UISWYJRight:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnOpenClose.selected = false;
	objSwf.panel._visible = true;
	objSwf.panel.hitTestDisable = not objSwf.panel._visible;
	objSwf.btnRule.visible = true;
	--
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	if activity:GetType() ~= ActivityConsts.T_SiWangYiJi then return; end
	self.activity = activity;
	self:UpdateInfo();
end

function UISWYJRight:OnHide()
	self.activity = nil;
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	if self.statueTimerKey then
		TimerManager:UnRegisterTimer(self.statueTimerKey);
		self.statueTimerKey = nil;
	end
end

function UISWYJRight:UpdateInfo()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.panel;
	panel.tfMapName.htmlText = MapUtils:GetMapName(CPlayerMap:GetCurMapID());
	panel.tfGuildName.htmlText = self.activity:GetGuildName();
	local cfg = self.activity:GetSWYJCfg();
	if not cfg then return; end
	local bossCfg = t_monster[cfg.bossId];
	if not bossCfg then return; end
	if self.activity:GetBossStat() == 0 then
		panel.btnBossName.htmlLabel = "<font color='#cc0000'><u>" .. bossCfg.name .. "</u></font>";
		if self.timerKey then
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end
		self.timerKey = TimerManager:RegisterTimer( function()
			local time = WorldBossUtils:GetNextBirthLastTime(cfg.bossId);
			time = time<0 and 0 or time;
			local hour,min,sec = CTimeFormat:sec2format(time)
			panel.tfBossRefreshTime.htmlText = string.format(StrConfig['activityswyj015'],hour,min,sec);
		end,1000,0);
	else
		if self.timerKey then
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end
		panel.btnBossName.htmlLabel = "<font color='#2FE00D'><u>" .. bossCfg.name .. "</u></font>";
		panel.tfBossRefreshTime.htmlText = StrConfig["activityswyj014"];
	end
	--
	if self.statueTimerKey then
		TimerManager:UnRegisterTimer(self.statueTimerKey);
		self.statueTimerKey = nil;
	end
	if self.activity:GetStatueStat() == ActivitySiWangYiJi.StatueStat_NON then
		panel.btnStatueState.visible = true;
		panel.btnStatueState.label = StrConfig["activityswyj009"];
		panel.btnGo.visible = false;
		panel.btnTeleport.visible = false;
		panel.siHp.visible = false;
		panel.tfHp._visible = false;
		panel.tfStatueTime._visible = false;
		panel.tfGuildReward.text = StrConfig["activityswyj048"];
	elseif self.activity:GetStatueStat() == ActivitySiWangYiJi.StatueStat_Lock then
		panel.btnStatueState.visible = true;
		if self.activity:IsMyStatue() then
			panel.btnStatueState.label = StrConfig["activityswyj043"];
		else
			panel.btnStatueState.label = StrConfig["activityswyj010"];
		end
		panel.siHp.visible = false;
		panel.tfHp._visible = false;
		panel.btnGo.visible = not self.activity:IsMyStatue();
		panel.btnTeleport.visible = self.activity:IsMyStatue();
		panel.tfStatueTime._visible = false;
		if self.activity:IsMyStatue() then
			panel.tfGuildReward.text = StrConfig["activityswyj047"];
		else
			panel.tfGuildReward.text = StrConfig["activityswyj048"];
		end
	elseif self.activity:GetStatueStat() == ActivitySiWangYiJi.StatueStat_Boss then
		panel.btnStatueState.visible = false;
		panel.btnGo.visible = not self.activity:IsMyStatue();
		panel.btnTeleport.visible = self.activity:IsMyStatue();
		panel.siHp.visible = true;
		panel.tfHp._visible = true;
		panel.siHp.minimun = 0;
		panel.siHp.maximum = self.activity.statueMaxHp or 0;
		panel.siHp.value = self.activity.statueHp or 0;
		panel.tfHp.htmlText = panel.siHp.value .."/".. panel.siHp.maximum;
		panel.tfStatueTime._visible = true;
		self.statueTimerKey = TimerManager:RegisterTimer(function()
			local time = self.activity.statueTime-GetServerTime();
			time = time<0 and 0 or time;
			local hour,min,sec = CTimeFormat:sec2format(time)
			panel.tfStatueTime.htmlText = string.format(StrConfig['activityswyj037'],min,sec);
		end,1000,0);
		if self.activity:IsMyStatue() then
			panel.tfGuildReward.text = StrConfig["activityswyj047"];
		else
			panel.tfGuildReward.text = StrConfig["activityswyj048"];
		end
	elseif self.activity:GetStatueStat() == ActivitySiWangYiJi.StatueStat_Die then
		panel.btnStatueState.visible = true;
		if self.activity:IsMyStatue() then
			panel.btnStatueState.label = StrConfig["activityswyj044"];
		else
			panel.btnStatueState.label = StrConfig["activityswyj011"];
		end
		panel.siHp.visible = false;
		panel.tfHp._visible = false;
		panel.btnGo.visible = not self.activity:IsMyStatue();
		panel.btnTeleport.visible = self.activity:IsMyStatue();
		panel.tfStatueTime._visible = false;
		panel.tfGuildReward.text = StrConfig["activityswyj048"];
	end
end


function UISWYJRight:OnBtnQuitClick()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	if activity:GetType() ~= ActivityConsts.T_SiWangYiJi then return; end
	ActivityController:QuitActivity(activity:GetId());
end

function UISWYJRight:OnBtnStatueStateOver()
	if self.activity:GetStatueStat() == ActivitySiWangYiJi.StatueStat_NON then
		TipsManager:ShowBtnTips(StrConfig['activityswyj042']);
	elseif self.activity:GetStatueStat() == ActivitySiWangYiJi.StatueStat_Lock then
		TipsManager:ShowBtnTips(StrConfig["activityswyj012"]);
	elseif self.activity:GetStatueStat() == ActivitySiWangYiJi.StatueStat_Die then
		TipsManager:ShowBtnTips(StrConfig["activityswyj013"]);
	end
end

function UISWYJRight:OnBtnBossNameClick()
	self.activity:BossGo();
end

function UISWYJRight:OnBtnTeleportClick()
	self.activity:StatueTelport();
end

function UISWYJRight:OnBtnTeleportOver()
	if self.activity:GetStatueTelportStat() == 1 then
		TipsManager:ShowBtnTips(StrConfig["activityswyj040"]);
	else
		TipsManager:ShowBtnTips(StrConfig["activityswyj041"]);
	end
end

function UISWYJRight:OnBtnGoClick()
	self.activity:StatueGo();
end