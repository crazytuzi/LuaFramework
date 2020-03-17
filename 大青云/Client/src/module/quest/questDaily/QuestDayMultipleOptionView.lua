
--[[
一键完成倍数选择
2015年4月11日12:06:31
haohu
]]

_G.UIQuestDayMultipleOption = BaseUI:new("UIQuestDayMultipleOption");

function UIQuestDayMultipleOption:Create()
	self:AddSWF("taskMultipleOptionPanel.swf", true, "top");
end

function UIQuestDayMultipleOption:OnLoaded( objSwf )
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click  = function() self:OnBtnCancelClick(); end
	objSwf.btnClose.click   = function() self:OnBtnCloseClick(); end
end

function UIQuestDayMultipleOption:OnShow()
	self:UpdateShow();
end

function UIQuestDayMultipleOption:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local restRoundNum = self:GetRestRoundNum()
	local multipleInfoMap = QuestConsts:GetDQMultipleRewardMap()
	-- 倍数1
	objSwf.radioButton1.htmlLabel = StrConfig['quest302'];
	objSwf.radioButton1.data = 1;
	objSwf.radioButton1._visible = false;
	-- 倍数2
--	objSwf.radioButton2.htmlLabel = string.format( StrConfig['quest303'], multipleInfoMap[2].multiple, restRoundNum * QuestConsts:GetMultiple2Cost(true) );
	objSwf.radioButton2.htmlLabel = string.format( StrConfig['quest311'], multipleInfoMap[2].multiple, restRoundNum * QuestConsts:GetMultiple3Cost() );
	objSwf.radioButton2.data = 2;
	-- 倍数3
	objSwf.radioButton3.htmlLabel = string.format( StrConfig['quest304'], multipleInfoMap[3].multiple, restRoundNum * QuestConsts:GetMultiple3Cost() );
	objSwf.radioButton3.data = 3;
	objSwf.radioButton3._visible = false;
	local oneKeyFinishTotalCost = restRoundNum * QuestConsts:Get1KeyFinishCost();
	objSwf.txtPrompt.htmlText = string.format( StrConfig['quest310'], restRoundNum, oneKeyFinishTotalCost );
	objSwf.radioButton2.selected = true
end

-- 获取剩余未完成环数
function UIQuestDayMultipleOption:GetRestRoundNum()
	local questVO = QuestModel:GetDailyQuest()
	if not questVO then return end
	local currentRound = questVO:GetRound(); -- 当前环数
	return QuestConsts.QuestDailyNum - currentRound + 1;
end

function UIQuestDayMultipleOption:OnBtnConfirmClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end	

--	if VipController:GetOneKeyFinish() == 1 then
	local multiple = objSwf._buttonGroup_option.data;
	if multiple == 2 then
		local restRoundNum = self:GetRestRoundNum()
		if not restRoundNum then return; end
		local cost = restRoundNum * QuestConsts:GetMultiple3Cost()
		if MainPlayerModel.humanDetailInfo.eaUnBindMoney < cost then
			FloatManager:AddNormal( StrConfig['quest309'] )
			return;
		else
			QuestController:ReqOneKeyFinish(multiple);
		end
	end
--	else
--		FloatManager:AddNormal( StrConfig["quest901"] )
--	end
	
end

function UIQuestDayMultipleOption:OnBtnCancelClick()
	self:Hide();
end

function UIQuestDayMultipleOption:OnBtnCloseClick()
	self:Hide();
end
--监听消息
function UIQuestDayMultipleOption:ListNotificationInterests()
	return { NotifyConsts.QuestAdd };
end

--消息处理
function UIQuestDayMultipleOption:HandleNotification( name, body )
	if name == NotifyConsts.QuestAdd then
		if QuestUtil:IsDailyQuest(body.id) then
			self:UpdateShow()
		end
	end
end