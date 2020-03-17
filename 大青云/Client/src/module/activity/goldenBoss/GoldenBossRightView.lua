--[[
    Created by IntelliJ IDEA.
    User: Hongbin Yang
    Date: 2016/7/13
    Time: 10:36
    黄金boss(财神降临)活动面板的右侧部分
   ]]

_G.UIGoldenBossRight = BaseUI:new('UIGoldenBossRight');

UIActivity:RegisterChild(ActivityConsts.T_GoldenBoss, UIGoldenBossRight)


UIGoldenBossRight.activityId = 0;
UIGoldenBossRight.activityType = 0;
function UIGoldenBossRight:Create()
	self:AddSWF("goldenBossActivityRightPanel.swf", true, nil);
end

function UIGoldenBossRight:OnLoaded(objSwf)
	objSwf.btnEnter.htmlLabel = UIStrConfig['activity005'];
	objSwf.btnEnter.click = function() self:OnBtnEnterClick(); end;
	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;

	objSwf.rewardlist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardlist.itemRollOut = function () TipsManager:Hide(); end
end

function UIGoldenBossRight:OnShow()
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	local cfg = activity:GetCfg();
	if not cfg then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bgLoader.source = ResUtil:GetActivityJpgUrl(cfg.bg);
	objSwf.nameLoader.source = ResUtil:GetActivityUrl(cfg.nameIcon.."_b");
	objSwf.explainLoader.source = ResUtil:GetActivityUrl(cfg.explain);

	local cfg = t_activity[self.activityId];
	if not cfg then return end
	self.activityType = cfg.type;
	--[[if cfg.openTime == '00:00:00' and cfg.duration == 0 and cfg.enter_time == 0 then
		objSwf.tfTime.text = StrConfig['worldBoss501'];
	else
		local openTimeList = activity:GetOpenTime();
		local str = "";
		for i,openTime in ipairs(openTimeList) do
			local startHour,startMin = CTimeFormat:sec2format(openTime.startTime);
			local endHour,endMin = CTimeFormat:sec2format(openTime.endTime);
			str = str .. string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);
			str = str .. " ";
		end
		objSwf.tfTime.text = str;
	end

	if cfg.needLvl <= MainPlayerModel.humanDetailInfo.eaLevel then
		objSwf.tfLevel.htmlText = string.format(StrConfig["activity001"],cfg.needLvl);
	else
		objSwf.tfLevel.htmlText = string.format(StrConfig["activity002"],cfg.needLvl);
	end]]
	objSwf.result.htmlText = StrConfig["activity_type_"..self.activityType]
	if activity:CanIn() == 1 then
		objSwf.btnEnter.disabled = false;
	else
		objSwf.btnEnter.disabled = true;
	end
	objSwf.rewardlist.dataProvider:cleanUp();
	local rewardStr = "";
	local rewardlist = activity:GetRewardList();
	if rewardlist then
		for i,vo in ipairs(rewardlist) do
			rewardStr = rewardStr .. vo.id .. "," .. vo.count;
			if i < #rewardlist then
				rewardStr = rewardStr .. "#";
			end
		end
	end
	local rewardStrList = RewardManager:Parse(rewardStr);

	objSwf.rewardlist.dataProvider:push(unpack(rewardStrList));
	objSwf.rewardlist:invalidateData();
end

function UIGoldenBossRight:OnHide()

end

function UIGoldenBossRight:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if StrConfig["activityru_type_"..self.activityType] then
		TipsManager:ShowBtnTips(StrConfig["activityru_type_"..self.activityType],TipsConsts.Dir_RightDown);
	end
end

--检查是否可进入
function UIGoldenBossRight:CheckCanIn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	if activity:CanIn() == 1 then
		objSwf.btnEnter.disabled = false;
	else
		objSwf.btnEnter.disabled = true;
	end
end

function UIGoldenBossRight:OnBtnEnterClick()
	if TeamModel:IsInTeam() then    --组队状态下不能进入
	local func = function ( )
		TeamController:QuitTeam()
		self:limitClick()
	end
	UIConfirm:Open(StrConfig['fubenentertema001'],func)
	else
		self:limitClick()
	end
end

--限制频繁点击
function UIGoldenBossRight:limitClick()
	if self.timeKey then
		return
	end
	local func = function ()
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,3000,1);
	ActivityController:EnterActivity(self.activityId);
end

function UIGoldenBossRight:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.ActivityState then
		if body.id == self.activityId then
			self:CheckCanIn();
		end
	end
end

function UIGoldenBossRight:ListNotificationInterests()
	return {NotifyConsts.ActivityState};
end

function UIGoldenBossRight:SignUpPhase()

end

