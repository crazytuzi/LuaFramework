--[[
	北仓界右侧面板
	2015年5月13日, PM 09:54:43
	wangyanwei
]]
_G.UIBeicangjieRight = BaseUI:new('UIBeicangjieRight');

UIActivity:RegisterChild(ActivityConsts.T_Beicangjie,UIBeicangjieRight)


UIBeicangjieRight.activityId = 0;
function UIBeicangjieRight:Create()
	self:AddSWF("beicangjieRightPanel.swf", true, nil);
end

function UIBeicangjieRight:OnLoaded(objSwf)
	objSwf.btnEnter.click = function() self:OnBtnEnterClick(); end;
	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;
	
	objSwf.rewardlist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardlist.itemRollOut = function () TipsManager:Hide(); end
	
	--商店
	objSwf.btnShop.click = function () self:OnBeicangjieShop(); end
	objSwf.btn_rank.click = function () self:OnShowRankReward() end 
	objSwf.btnShop.rollOver = function () TipsManager:ShowBtnTips(StrConfig['shop551'],TipsConsts.Dir_RightDown); end
	objSwf.btnShop.rollOut = function () TipsManager:Hide(); end

	-- 暂时屏蔽排行榜
	objSwf.btn_rank._visible = false
end

function UIBeicangjieRight:OnBeicangjieShop()
	if UIBeicangjieShop:IsShow() then
		UIBeicangjieShop:Hide();
		return
	end
	UIBeicangjieShop:Show();
end

-- 打开排行榜奖励
function UIBeicangjieRight:OnShowRankReward()
	if ActivityBeicangjieRankView:IsShow() then
		return;
	else
		ActivityBeicangjieRankView:Show()
	end
end

function UIBeicangjieRight:OnShow()
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	local cfg = activity:GetCfg();
	if not cfg then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnShop.visible = false;
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

function UIBeicangjieRight:OnHide()

end

function UIBeicangjieRight:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if StrConfig["activityru"..self.activityId] then
		TipsManager:ShowBtnTips(StrConfig["activityru"..self.activityId],TipsConsts.Dir_RightDown);
	end
end

--检查是否可进入
function UIBeicangjieRight:CheckCanIn()
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

function UIBeicangjieRight:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if StrConfig["activityru"..self.activityId] then
		TipsManager:ShowBtnTips(StrConfig["activityru"..self.activityId],TipsConsts.Dir_RightDown);
	end
end

-- function UIActivityDefault:OnBtnRuleOut()
-- 	TipsManager:Hide();
-- end

function UIBeicangjieRight:OnBtnEnterClick()
	--[[
	if TeamModel:IsInTeam() then    --组队状态下不能进入
		local func = function ( )
			TeamController:QuitTeam()
			self:limitClick()
		end
		UIConfirm:Open(StrConfig['fubenentertema001'],func)
	else
		self:limitClick()
	end
	--]]
	self:limitClick()

end

--限制频繁点击
function UIBeicangjieRight:limitClick()
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

function UIBeicangjieRight:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.ActivityState then
		if body.id == self.activityId then
			self:CheckCanIn();
		end
	end
end

function UIBeicangjieRight:ListNotificationInterests()
	return {NotifyConsts.ActivityState};
end

function UIBeicangjieRight:SignUpPhase()

end