--[[
日环任务：任务追踪面板
2014年12月12日11:19:54
郝户
]]

_G.UIQuestDayGuide = BaseUI:new("UIQuestDayGuide");

function UIQuestDayGuide:Create()
	self:AddSWF("taskDayGuidePanel.swf", true, "center");
end

function UIQuestDayGuide:OnLoaded( objSwf )
	objSwf.btnConfirm.click         = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click          = function() self:OnBtnCancelClick(); end
	objSwf.starIndicator.rollOver   = function() self:OnStarRollOver(); end
	objSwf.starIndicator.rollOut    = function() self:OnStarRollOut(); end
	objSwf.btnAddStar.click         = function() self:OnBtnAddStarClick(); end
	objSwf.btnAddStar.rollOver      = function() self:OnBtnAddStarRollOver(); end
	objSwf.btnAddStar.rollOut       = function() self:OnBtnAddStarRollOut(); end
	-- objSwf.lblAutoAddStarPrompt.text = string.format( StrConfig['quest121'], QuestConsts.QuestDailyMaxStar )
	objSwf.starIndicator.maximum    = QuestConsts.QuestDailyMaxStar;
	-- objSwf.txtStar.text             = StrConfig['quest118'];
	-- objSwf.lblReward.text           = StrConfig['quest120'];
	-- objSwf.lblRewardtitle.text           = StrConfig['quest0000000120'];
end

function UIQuestDayGuide:OnShow()
	self:UpdateShow();
	self:StartTimer();
end

function UIQuestDayGuide:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local dailyVO = QuestModel:GetDailyQuest();
	if not dailyVO then
		return;
	end
	local cfg = dailyVO:GetCfg();
	objSwf.txtName.htmlText = string.format( StrConfig['quest117'], cfg.name );
	self:ShowStarInfo();
	self:ShowReward();
end

function UIQuestDayGuide:OnHide()
	self:StopTimer()
end

function UIQuestDayGuide:ShowStarInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local dailyVO = QuestModel:GetDailyQuest();
	local star = dailyVO:GetStarLvl();
	objSwf.starIndicator.value = star;
	objSwf.btnAddStar._visible = star < QuestConsts.QuestDailyMaxStar;
	objSwf.btnAddStar._visible = false;
--	objSwf.addStarEffect._visible = dailyVO:IsNeedStarPrompt()
	objSwf.addStarEffect._visible = false;
end


function UIQuestDayGuide:ShowReward()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local dailyVO = QuestModel:GetDailyQuest();
	local rewardExp, rewardMoney, rewardZhenqi, itemReward, rewardJingYuan = dailyVO:GetRewards();
	objSwf.txtExp.text = rewardExp;
	objSwf.txtMoney.text = rewardMoney;
	-- objSwf.txtZhenqi.text = rewardZhenqi;
	local item = t_item[toint(GetCommaTable(itemReward)[1])];
	objSwf.txtJingYuan.text = GetCommaTable(itemReward)[2];
	--title
	objSwf.txtExpTitle.text = enAttrTypeName[enAttrType.eaExp]
	objSwf.txtMoneyTitle.text = enAttrTypeName[enAttrType.eaUnBindGold]
	objSwf.txtJingYuanTitle.text = item.name;
end

function UIQuestDayGuide:OnBtnConfirmClick()
	self:DoGuide()
	self:Hide();
end

function UIQuestDayGuide:DoGuide()
	local quest = QuestModel:GetDailyQuest();
	if not quest then return end
	--如果地图不能传送
	local mapId = MainPlayerController:GetMapId();
	if not MapUtils:IsQuestDailyCanTeleportMap(mapId) then return; end
	quest:ToTargetPos(true);
end

function UIQuestDayGuide:OnBtnCancelClick()
	self:Hide();
end

function UIQuestDayGuide:OnStarRollOver()
--	TipsManager:ShowBtnTips( StrConfig['quest402'] );
end

function UIQuestDayGuide:OnStarRollOut()
	TipsManager:Hide();
end

function UIQuestDayGuide:OnBtnAddStarClick()
	local questDailyVO = QuestModel:GetDailyQuest();
	if not questDailyVO then return; end
	QuestController:ReqAddStar( questDailyVO:GetId() )
end

function UIQuestDayGuide:OnBtnAddStarRollOver()
	TipsManager:ShowBtnTips( string.format( StrConfig['quest107'], QuestConsts:GetAddStarCost() ) );
end

function UIQuestDayGuide:OnBtnAddStarRollOut()
	TipsManager:Hide();
end

--监听消息
function UIQuestDayGuide:ListNotificationInterests()
	return {
		NotifyConsts.QuestDailyFullStar,
		NotifyConsts.QuestAdd,
	};
end

--消息处理
function UIQuestDayGuide:HandleNotification( name, body )
	if name == NotifyConsts.QuestDailyFullStar then
		self:ShowStarInfo();
		self:ShowReward();
	elseif name == NotifyConsts.QuestAdd then
		if QuestUtil:IsDailyQuest( body.id ) then
			self:UpdateShow();
		end
	end
end


-------------------------------------倒计时处理------------------------------------------

local timerKey;
local time;
function UIQuestDayGuide:StartTimer()
	local func = function() self:OnTimer(); end
	time = QuestConsts.QuestDaily1KeyFinishCountDown;
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	self:UpdateTimeShow()
end

function UIQuestDayGuide:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:StopTimer();
		self:OnTimeUp();
	end
	self:UpdateTimeShow()
end

function UIQuestDayGuide:UpdateTimeShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local textField = objSwf.txtTime
	textField._visible = timerKey ~= nil
	textField.htmlText = string.format( StrConfig['quest116'], time );
end

function UIQuestDayGuide:OnTimeUp()
	self:DoGuide()
	self:Hide();
end

function UIQuestDayGuide:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
	end
end

function UIQuestDayGuide:Open()
	-- 在活动场景时不显示
	if MapUtils:CanTeleport() then
		self:Show()
	end
end