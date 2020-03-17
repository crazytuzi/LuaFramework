--[[
活动右侧野外boss
zhangshuhui
2015年10月31日15:42:57
]]

_G.UIBossBaoDongRightView = BaseUI:new("UIBossBaoDongRightView");
UIActivity:RegisterChild(ActivityConsts.T_BossBaoDong,UIBossBaoDongRightView)
UIBossBaoDongRightView.activityId = 0;

function UIBossBaoDongRightView:Create()
	self:AddSWF("bossBaoDongRightPanel.swf",true,nil);
end

function UIBossBaoDongRightView:OnLoaded(objSwf)
	RewardManager:RegisterListTips(objSwf.rewardlist);
	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;
end

function UIBossBaoDongRightView:OnShow()
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	local cfg = activity:GetCfg();
	if not cfg then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bgLoader.source = ResUtil:GetActivityJpgUrl(cfg.bg);
	objSwf.nameLoader.source = ResUtil:GetActivityUrl(cfg.nameIcon.."_b");
	objSwf.explainLoader.source = ResUtil:GetActivityUrl(cfg.explain);
	--[[objSwf.tfTime.text = StrConfig["activitytime"..self.activityId];
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

function UIBossBaoDongRightView:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if StrConfig["activityru"..self.activityId] then
		TipsManager:ShowBtnTips(StrConfig["activityru"..self.activityId],TipsConsts.Dir_RightDown);
	end
end