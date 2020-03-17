--[[
战场活动右侧报名面部
wangshuai
]]

_G.UIZCRightPanel = BaseUI:new("UIZCRightPanel")

UIActivity:RegisterChild(ActivityConsts.T_ZhanChang,UIZCRightPanel)

UIZCRightPanel.isSignUp = false;
UIZCRightPanel.activityId = 0;
function UIZCRightPanel : Create()
	--
	self:AddSWF("zhanchangRightPanel.swf", true, nil);
end;

function UIZCRightPanel:OnLoaded(objSwf)
	objSwf.btnEnter.click = function() self:OnBtnEnterClick(); end
	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;

	RewardManager:RegisterListTips(objSwf.rewardlist);
end

function UIZCRightPanel:OnShow()
	-- 参加活动
	self.objSwf.btnEnter.htmlLabel = string.format(StrConfig["zhanchang102"]);
		-- 是否报名 
	self:SignUpPhase();

	self.objSwf.result.htmlText = StrConfig["activity"..self.activityId]

	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	local cfg = activity:GetCfg();
	if not cfg then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bgLoader.source = ResUtil:GetActivityJpgUrl(cfg.bg);
	objSwf.nameLoader.source = ResUtil:GetActivityUrl(cfg.nameIcon.."_b");
	if objSwf.explainLoader then
		objSwf.explainLoader.source = ResUtil:GetActivityUrl(cfg.explain);
	end
	local openTimeList = activity:GetOpenTime();
	local str = "";


	--[[for i,openTime in ipairs(openTimeList) do
		--print(i,openTime.startTime,openTime.endTime,"这是刁毛东西？")
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
	
	self.timerKey = TimerManager:RegisterTimer(function()
		self:CheckCanIn();
	end,1000,0);
end

function UIZCRightPanel:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if StrConfig["activityru"..self.activityId] then
		TipsManager:ShowBtnTips(StrConfig["activityru"..self.activityId],TipsConsts.Dir_RightDown);
	end
end


function UIZCRightPanel:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
end

--检查是否可进入
function UIZCRightPanel:CheckCanIn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local activity = ActivityModel:GetActivity(self.activityId);
	if not activity then return; end
	if activity:CanIn() == 1 then
		self:SignUpPhase();
	else
		self:SignUpPhase();
	end
end
function UIZCRightPanel:SignUpPhase()
--	print("计数")
	local activity = ActivityModel:GetActivity(self.activityId);
--	print(activity:GetOpenLastTime())
--	print(activity:GetOpenLastTime(),"战场")
	if tonumber(activity:GetOpenLastTime()) <= 500 then 
		if tonumber(activity:GetOpenLastTime()) <= 0 then 
			self.objSwf.btnEnter.htmlLabel = string.format(StrConfig["zhanchang102"]);
			self.objSwf.btnEnter.disabled = false;
			self.isSignUp = false;
			return
		end;
			local isSingUp = ActivityZhanChang.IsSignUp;
			if isSingUp == 1 then 
				self.objSwf.btnEnter.htmlLabel = string.format(StrConfig["zhanchang117"]);
				self.objSwf.btnEnter.disabled = false;
				self.isSignUp = true;
				return 
			end;
			self.objSwf.btnEnter.htmlLabel = string.format(StrConfig["zhanchang101"]);
			self.objSwf.btnEnter.disabled = false;
			self.isSignUp = true;
			return
	end;
	if tonumber(activity:GetOpenLastTime()) > 500 then 
			self.objSwf.btnEnter.htmlLabel = string.format(StrConfig["zhanchang102"]);
			self.objSwf.btnEnter.disabled = true;
			return 
	end;
end;

function UIZCRightPanel:OnPopWindow()
	local okfun = function () self:NextFun(); end;
	local nofun = function () end;
	UIConfirm:Open(UIStrConfig["equip224"],okfun,nofun);
end

function UIZCRightPanel:OnBtnEnterClick()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end;
	if mapCfg.can_teleport == false then 
		FloatManager:AddSysNotice(2005014);--已达上限
		--FloatManager:AddNormal(StrConfig["arena139"]);
		return 
	end;

	if self.isSignUp == true then 
		-- 报名阶段
		ActivityZhanChang:ReqZhancSingUp()
	else
		-- 立即参加
		ActivityController:EnterActivity(self.activityId);
	end;
end