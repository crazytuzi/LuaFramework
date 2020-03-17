--[[
活动右侧双倍刷怪
zhangshuhui
2015年9月28日15:42:57
]]

_G.UIDoubleExpRightView = BaseUI:new("UIDoubleExpRightView");
UIActivity:RegisterChild(ActivityConsts.T_DoubleExp,UIDoubleExpRightView)
UIDoubleExpRightView.activityId = 0;

function UIDoubleExpRightView:Create()
	self:AddSWF("doubleexpRightPanel.swf",true,nil);
end

function UIDoubleExpRightView:OnLoaded(objSwf)
	RewardManager:RegisterListTips(objSwf.rewardlist);
	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;
end

function UIDoubleExpRightView:OnShow()
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

function UIDoubleExpRightView:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if StrConfig["activityru"..self.activityId] then
		TipsManager:ShowBtnTips(StrConfig["activityru"..self.activityId],TipsConsts.Dir_RightDown);
	end
end