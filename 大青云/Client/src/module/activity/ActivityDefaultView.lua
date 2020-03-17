--[[
活动右侧默认面板
lizhuangzhuang
2014年12月4日15:42:57
]]

_G.UIActivityDefault = BaseUI:new("UIActivityDefault");

UIActivityDefault.activityId = 0;

function UIActivityDefault:Create()
	self:AddSWF("activityDefault.swf",true,nil);
end

function UIActivityDefault:OnLoaded(objSwf)
	objSwf.btnEnter.click = function() self:OnBtnEnterClick(); end
	RewardManager:RegisterListTips(objSwf.rewardlist);
	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;
end

function UIActivityDefault:OnShow()
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	local cfg = activity:GetCfg();
	if not cfg then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bgLoader.source = ResUtil:GetActivityJpgUrl(cfg.bg);
	objSwf.nameLoader.source = ResUtil:GetActivityUrl(cfg.nameIcon.."_b");
	objSwf.explainLoader.source = ResUtil:GetActivityUrl(cfg.explain);
	local openTimeList = activity:GetOpenTime();
	--[[local str = "";
	for i,openTime in ipairs(openTimeList) do
		local startHour,startMin = CTimeFormat:sec2format(openTime.startTime);
		local endHour,endMin = CTimeFormat:sec2format(openTime.endTime);
		str = str .. string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);
		str = str .. " ";
	end
	objSwf.tfTime.text = str;
	if cfg.needLvl <= MainPlayerModel.humanDetailInfo.eaLevel then
		objSwf.tfLevel.htmlText = string.format(StrConfig["activity001"],cfg.needLvl);
	else
		objSwf.tfLevel.htmlText = string.format(StrConfig["activity002"],cfg.needLvl);
	end]]
	objSwf.result.htmlText = StrConfig["activity"..self.activityId]
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


--检查是否可进入
function UIActivityDefault:CheckCanIn()
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

function UIActivityDefault:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if StrConfig["activityru"..self.activityId] then
		TipsManager:ShowBtnTips(StrConfig["activityru"..self.activityId],TipsConsts.Dir_RightDown);
	end
end

-- function UIActivityDefault:OnBtnRuleOut()
-- 	TipsManager:Hide();
-- end

function UIActivityDefault:OnBtnEnterClick()
	if TeamModel:IsInTeam() then
		return;
	end
	-- debug.debug()
	ActivityController:EnterActivity(self.activityId);
end

function UIActivityDefault:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.ActivityState then
		if body.id == self.activityId then
			self:CheckCanIn();
		end
	end
end

function UIActivityDefault:ListNotificationInterests()
	return {NotifyConsts.ActivityState};
end