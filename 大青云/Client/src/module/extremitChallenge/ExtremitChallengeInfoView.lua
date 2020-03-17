--[[
	2015年6月23日, PM 05:20:56
	追踪面板
	wangyanwei
]]

_G.UIExtremitChallengeInfo = BaseUI:new('UIExtremitChallengeInfo');

UIExtremitChallengeInfo.BossChallenge = 0;
UIExtremitChallengeInfo.MonsterChallenge = 1;

function UIExtremitChallengeInfo:Create()
	self:AddSWF('extremitChallengeInfoPanel.swf',true,'center');
end

function UIExtremitChallengeInfo:OnLoaded(objSwf)
	objSwf.smallPanel.txt_rank.htmlText = string.format(StrConfig['extremitChalleng082'],StrConfig['extremitChalleng007']);
	objSwf.smallPanel.txt_num.text = 0;
	objSwf.smallPanel.tf2.text = UIStrConfig['extremitChalleng5'];
	objSwf.smallPanel.btn_quit.click = function () self:OnQuitClick(); end
	objSwf.btn_state.click = function () 
			objSwf.btn_state.selected = objSwf.smallPanel.visible;
			objSwf.smallPanel.visible = not objSwf.smallPanel.visible; 
		end
end

function UIExtremitChallengeInfo:OnShow()
	self:OnShowChallengeType();
	self:SetUIState();
end

function UIExtremitChallengeInfo:SetUIState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.smallPanel._visible = true
	objSwf.smallPanel.hitTestDisable = false;
	objSwf.btn_state.selected = false;
end;

--请求退出副本
function UIExtremitChallengeInfo:OnQuitClick()
	local func = function () 
		ExtremitChallengeController:OnSendQuitExtremity();
	end
	self.uicomfirmID = UIConfirm:Open(StrConfig['extremitChalleng010'],func);
end

UIExtremitChallengeInfo.challengeType = nil;
function UIExtremitChallengeInfo:Open()
	self.challengeType = ExtremitChallengeModel:GetExtremityType();
	-- if self.challengeType == 0 then 
		-- return 
	-- end
	if self:IsShow() then
		return 
	else
		self:Show();
	end
end

--根据进入的副本类型show对应显示
UIExtremitChallengeInfo.endTimeNum = 0;
function UIExtremitChallengeInfo:OnShowChallengeType()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_consts[84];
	if self.challengeType == self.BossChallenge then
		objSwf.smallPanel.tf1.htmlText = StrConfig['extremitChalleng008'];
		self.endTimeNum = cfg.val2 * 60;
	elseif self.challengeType == self.MonsterChallenge then
		objSwf.smallPanel.tf1.htmlText = StrConfig['extremitChalleng009'];
		self.endTimeNum = cfg.val3 * 60;
	else
		print('Error--------------------进入类型错误')
	end
	self:OnChangeEndTime();
end

--计算倒计时
function UIExtremitChallengeInfo:OnChangeEndTime()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local num = self.endTimeNum;
	local func = function ()
		local min,sec = self:OnBackNowTime(num);
		objSwf.smallPanel.txt_time.text = min .. ':' .. sec;
		num = num - 1;
		if num < 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func();
end

function UIExtremitChallengeInfo:OnBackNowTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if min < 10 then min = '0' .. min ; end
	if sec < 10 then sec = '0' .. sec ; end
	return min,sec
end

--预估排名
function UIExtremitChallengeInfo:SetRankNum()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rankNum = ExtremitChallengeModel:OnGetRankNum();
	objSwf.smallPanel.txt_rank.htmlText = string.format(StrConfig['extremitChalleng082'],rankNum);
end

--BOSS信息变更
function UIExtremitChallengeInfo:OnBossInfoChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local bossHarm = ExtremitChallengeModel:OnGetBossHarm();
	objSwf.smallPanel.txt_num.htmlText = string.format(StrConfig['extremitChalleng080'],getNumShow(bossHarm));
end

--小怪信息变更
function UIExtremitChallengeInfo:OnMonsterInfoChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local killMonsterNum = ExtremitChallengeModel:OnGetKillMonsterNum();
	objSwf.smallPanel.txt_num.htmlText = string.format(StrConfig['extremitChalleng081'],killMonsterNum);
end

function UIExtremitChallengeInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	 objSwf.smallPanel.visible = true;
	 objSwf.smallPanel.txt_rank.htmlText = string.format(StrConfig['extremitChalleng082'],StrConfig['extremitChalleng007']);
	 objSwf.smallPanel.txt_num.text = '0';
	 if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	 end
	 objSwf.smallPanel.txt_time.text = '00:00';
	 if UIAutoBattleTip:IsShow() then
		UIAutoBattleTip:Hide();
	 end
	 UIConfirm:Close(self.uicomfirmID);
end

function UIExtremitChallengeInfo:GetWidth()
	return 238;
end

function UIExtremitChallengeInfo:GetHeight()
	return 350;
end

--改变挂机按钮文本
function UIExtremitChallengeInfo:OnChangeAutoText(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if state then
		if UIAutoBattleTip:IsShow() then
			UIAutoBattleTip:Hide();
		end
	else
		UIAutoBattleTip:Open(function()ExtremitChallengeController:OnAutoStart()end);
	end
end

function UIExtremitChallengeInfo:HandleNotification(name,body)
	if name == NotifyConsts.ExtremitChallengeBossData then
		self:OnBossInfoChange();
	elseif name == NotifyConsts.ExtremitChallengeMonsterData then
		self:OnMonsterInfoChange();
	elseif name == NotifyConsts.ExtremitChallengeRankNum then
		self:SetRankNum();
	elseif name == NotifyConsts.AutoHangStateChange then
		-- self:OnChangeAutoText(body.state);
	end
end
function UIExtremitChallengeInfo:ListNotificationInterests()
	return {
		NotifyConsts.ExtremitChallengeBossData,
		NotifyConsts.ExtremitChallengeMonsterData,
		NotifyConsts.ExtremitChallengeRankNum,
		NotifyConsts.AutoHangStateChange
	}
end