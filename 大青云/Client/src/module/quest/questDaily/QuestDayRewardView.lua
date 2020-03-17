--[[
日环任务：奖励面板
2014年12月11日12:17:29
郝户
]]

_G.UIQuestDayReward = BaseUI:new("UIQuestDayReward");

UIQuestDayReward.questDailyVO = nil;
UIQuestDayReward.questDailyVORound = 0;

function UIQuestDayReward:Create()
	self:AddSWF("taskDayRewardPanel.swf", true, "center");
end

function UIQuestDayReward:new( name )
	local ui = BaseUI:new( name );
	for k, v in pairs(self) do
		if type(v) == "function" then
			ui[k] = v;
		end
	end
	return ui;
end

function UIQuestDayReward:OnLoaded( objSwf )
	self:InitRewardBtns( objSwf )
	RewardManager:RegisterListTips( objSwf.list );
end

function UIQuestDayReward:InitRewardBtns( objSwf )

	objSwf.btnConfirm1.click = function() self:OnBtnConfirm1Click(); end
	-- objSwf.btnConfirm2.click = function() self:OnBtnConfirm2Click(); end
	objSwf.btnConfirm2._visible = false
	objSwf.btnConfirm3.click = function() self:OnBtnConfirm3Click(); end
	-- objSwf.btnConfirm2.rollOver = function() self:ShowAddTxt(2); end
	objSwf.btnConfirm3.rollOver = function() self:ShowAddTxt(3); end
	-- objSwf.btnConfirm2.rollOut = function() self:HideTxt(); end
	objSwf.btnConfirm3.rollOut = function() self:HideTxt(); end

	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
end

function UIQuestDayReward:OnShow()
	self:StartTimer();
	self:ShowBtnLabels();
	self:UpdateShow();
end

function UIQuestDayReward:ShowBtnLabels()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local multipleInfoMap = QuestConsts:GetDQMultipleRewardMap()
	objSwf.btnConfirm1.htmlLabel = multipleInfoMap[1].label
	-- objSwf.btnConfirm2.htmlLabel = multipleInfoMap[2].label
	objSwf.btnConfirm3.htmlLabel = multipleInfoMap[3].label
end

function UIQuestDayReward:OnChangeScene()
	-- 切换到活动场景后，关闭日环领奖界面
	if not MapUtils:CanTeleport() then
		if self:IsShow() then
			self:OnBtnConfirm1Click()
		end
	end
end

function UIQuestDayReward:ShowAddTxt(_type)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if _type == 1 then 
		return 
	end
	local cfg = t_consts[74];
	if not cfg then return end
	local questVO = self.questDailyVO
	if not questVO then return end
	local rewardValCfg = split(cfg.param,'#');
	local rewardVal = 1;
	if _type == 2 then
		rewardVal = split(rewardValCfg[2],',')[1];
	elseif _type == 3 then
		rewardVal = split(rewardValCfg[3],',')[1];
	end
	local rewardExp, rewardMoney, rewardZhenqi, itemReward, rewardJingYuan = questVO:GetRewards();
	local jingyuanNum = 0;
	jingyuanNum = toint(GetCommaTable(itemReward)[2]);
	rewardExp, rewardMoney, rewardZhenqi, jingyuanNum = rewardExp * (rewardVal - 1.3), rewardMoney * (rewardVal - 1.3), rewardZhenqi  * (rewardVal - 1.3), jingyuanNum * (rewardVal - 1.3);
	objSwf.txt_addExp._visible = true;
	objSwf.txt_addMoney._visible = true;
	-- objSwf.txt_addZhenqi._visible = true;
	objSwf.txt_addJingYuan._visible = true;
	objSwf.txt_addExp.text = '+' .. _G.getNumShow( rewardExp );
	objSwf.txt_addMoney.text = '+' .. _G.getNumShow( rewardMoney );
	-- objSwf.txt_addZhenqi.text = '+' .. _G.getNumShow( rewardZhenqi );
	objSwf.txt_addJingYuan.text  = '+' .. _G.getNumShow( math.ceil(jingyuanNum ))
end

function UIQuestDayReward:HideTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.txt_addExp._visible = false;
	objSwf.txt_addMoney._visible = false;
	objSwf.txt_addJingYuan._visible = false;
	-- objSwf.txt_addZhenqi._visible = false;
end

function UIQuestDayReward:OnHide()
	self:StopTimer();
	self.questDailyVO = nil;
	QuestDayFlow:OnRewardPanelClose();
	self:ClosePayPrompt()
end

function UIQuestDayReward:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local questVO = self.questDailyVO
	if not questVO then return end
	-- 特效
	self:ShowEffect();
	-- 文本显示
	objSwf.txtPrompt.htmlText = string.format( StrConfig['quest111'], questVO:GetRound() )
	self.questDailyVORound = questVO:GetRound()
	-- 奖励
	local rewardExp, rewardMoney, rewardZhenqi, itemReward, rewardJingYuan = questVO:GetRewards()
	-- 文本
	objSwf.txtExp.text    = _G.getNumShow( rewardExp )
	objSwf.txtMoney.text  = _G.getNumShow( rewardMoney )
	-- objSwf.txtZhenqi.text = _G.getNumShow( rewardZhenqi )
--	if rewardJingYuan > 0 then
--		local jingyuanNum = rewardJingYuan;
--		objSwf.txtJingYuan.text  = _G.getNumShow( jingyuanNum )
--	end
	objSwf.txtJingYuan._visible = false;
	-- 图标
	local rewardList = RewardManager:Parse( enAttrType.eaExp .. "," .. rewardExp,
		enAttrType.eaBindGold .. "," .. rewardMoney,itemReward)
	local uiList = objSwf.list
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack(rewardList) )
	uiList:invalidateData()
	self:HideTxt();
end

function UIQuestDayReward:ShowEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.effBg:stopEffect()
	-- objSwf.effBg:playEffect(1)
end

function UIQuestDayReward:OnBtnConfirm1Click()
	self:FinishQuest(1);
end

function UIQuestDayReward:OnBtnConfirm2Click()
	self:FinishQuest(2);
end

function UIQuestDayReward:OnBtnConfirm3Click()
	self:FinishQuest(2);
end

function UIQuestDayReward:OnBtnCloseClick()
	self:FinishQuest(1);
end

function UIQuestDayReward:FinishQuest(multiple, isPrompt)
	self:StopTimer();
	if not multiple then multiple = 1 end
	if nil == isPrompt then isPrompt = true end
	-- if multiple == 2 then -- 多倍类型2，扣除银两判断
		-- local myGold = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
		-- if myGold < QuestConsts:GetMultiple2Cost(true) then
			-- if isPrompt then
				-- FloatManager:AddNormal( StrConfig['quest308'] ) --银两不足
			-- end
			-- return false
		-- end
	if multiple == 2 then -- 多倍类型2，扣除元宝判断
		local myYuanBao = MainPlayerModel.humanDetailInfo.eaUnBindMoney
		-- local myYuanBao1 = MainPlayerModel.humanDetailInfo.eaBindMoney
		-- local t = myYuanBao+myYuanBao1
		if myYuanBao < QuestConsts:GetMultiple3Cost() then
			if isPrompt then
				FloatManager:AddNormal( StrConfig['quest309'] ) --元宝不足
			end
			return false
		end
	end
	if isPrompt then
		self:OpenPayPrompt(multiple);
	else
		local questId = self.questDailyVO:GetId();
		QuestController:FinishQuest(questId, multiple);
	end
	return true
end

function UIQuestDayReward:OpenPayPrompt( multiple )
	local questId = self.questDailyVO:GetId();
	local needConfirm = QuestModel:GetPayGetRewardPrompt( multiple );
	if not needConfirm then
		QuestController:FinishQuest(questId, multiple);
		return;
	end
	local confirmFunc = function(selected)
		QuestModel:SetPayGetRewardPrompt( multiple, not selected );
		QuestController:FinishQuest(questId, multiple);
	end
	if multiple == 1 then
		QuestController:FinishQuest(questId, multiple);
		return;
	end
	local content = "";
	local multipleInfoMap = QuestConsts:GetDQMultipleRewardMap()
	local multipleInfo = multipleInfoMap[multiple]
	-- if multiple == 2 then
		-- content = string.format( StrConfig['quest305'], QuestConsts:GetMultiple2Cost(), multipleInfo.multiple );
	if multiple == 2 then
		content = string.format( StrConfig['quest306'], 10, 1.2 );
	end
	self.confirmUID = UIConfirmWithNoTip:Open( content, confirmFunc );
end

function UIQuestDayReward:ClosePayPrompt()
	if self.confirmUID then
		UIConfirmWithNoTip:Close( self.confirmUID )
		self.confirmUID = nil
	end
end

---------------------------------倒计时处理--------------------------------
local time;
local timerKey;
function UIQuestDayReward:StartTimer()
	time = QuestConsts.QuestDailyRewardCountDown;
	local func = function() self:OnTimer(); end
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	self:UpdateCountDown();
end

function UIQuestDayReward:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:StopTimer();
		self:OnTimeUp();
		return;
	end
	self:UpdateCountDown();
end

function UIQuestDayReward:OnTimeUp()
--	if not self:FinishQuest(2, false) then
		-- print("领取2倍奖励没有成功，领取1倍")
		self:FinishQuest(1)
--	else
		-- print("领取2倍奖励成功，ooo")
--	end
	self:ClosePayPrompt()
end

function UIQuestDayReward:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
		self:HideCountDown();
	end
end

function UIQuestDayReward:HideCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime._visible = false;
end

function UIQuestDayReward:UpdateCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local txtTime = objSwf.txtTime;
	if not txtTime._visible then
		txtTime._visible = true;
	end
	-- WriteLog(LogType.Normal,true,'---------------------UIQuestDayReward:UpdateCountDown()',time)
	objSwf.txtTime.htmlText = string.format( StrConfig['quest112'], time );
end

function UIQuestDayReward:Open( questDailyVO )
	self.questDailyVO = questDailyVO;
	if self:IsShow() then
		self:UpdateShow();
	else
		self:Show();
	end
end

function UIQuestDayReward:Close( questId )
	local dailyVO = self.questDailyVO;
	local currentId = dailyVO and dailyVO:GetId();
	if questId == currentId then
		self:Hide();
	end
end

--监听消息
function UIQuestDayReward:ListNotificationInterests()
	return {
		NotifyConsts.QuestRemove,
		NotifyConsts.QuestFinish,
	};
end

--消息处理
function UIQuestDayReward:HandleNotification( name, body )
	if name == NotifyConsts.QuestFinish then
		self:Close( body.id )
	elseif name == NotifyConsts.QuestRemove then
		self:Close( body.id )
	end
end