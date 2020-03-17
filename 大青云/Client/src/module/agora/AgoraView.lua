--[[
    Created by IntelliJ IDEA.
    任务集会所 新屠魔 新悬赏
    User: Hongbin Yang
    Date: 2016/10/22
    Time: 15:05
   ]]

_G.AgoraView = BaseUI:new("UIAgoraView");

AgoraView.uiQuestItemList = {};
AgoraView.autoRefreshTimerKey = nil;
AgoraView.canRefresh = nil;

function AgoraView:Create()
	self:AddSWF("agoraPanel.swf", true, "center");
end

function AgoraView:InitView(objSwf)
	-- 界面加载完成后的
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.curPanel.txtGoal.click = function() self:OnGoPosClicked() end
	objSwf.curPanel.btnTeleport.click = function() self:OnBtnTeleportClicked() end
	objSwf.curPanel.btnTeleport.rollOver = function() self:OnBtnTeleportRollOver() end
	objSwf.curPanel.btnTeleport.rollOut = function() self:OnBtnTeleportRollOut() end
	objSwf.curPanel.btnGiveUp.click = function() self:OnBtnGiveUpClick() end
--	objSwf.btnRefresh.click = function() self:OnBtnRefreshClick() end
	--[[objSwf.btnExplain.rollOver = function()
		TipsManager:ShowBtnTips(string.format(StrConfig['agora8'],
											t_questagora_consts[1].refresh_time,
											t_questagora_consts[1].quest_limit,
											t_questagora_consts[1].gratis_times),
		TipsConsts.Dir_RightDown)
	end;
	objSwf.btnExplain.rollOut = function() TipsManager:Hide() end]]
	objSwf.checkBoxAuto.click = function() self:OnCheckBoxAutoClick() end
	objSwf.checkBoxAuto.selected = AgoraModel.auto;
	objSwf.txtRefreshCountDown._visible = false;
	self.uiQuestItemList = {};
	for i = 1, 6 do
		table.push(self.uiQuestItemList, objSwf["item" .. i]);
	end
end

function AgoraView:OnShow()
	self:InitView(self.objSwf);
	self:UpdateView();
end

function AgoraView:UpdateView()
	self:UpdateQuestList();
	self:UpdateRight();
end

function AgoraView:UpdateQuestList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local uiList = AgoraUtils:ConvertQuestListToUIList(AgoraModel.questList);
	local uiDatas = {}
	for k, v in pairs(uiList) do
		table.push(uiDatas, UIData.encode(v));
	end
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(uiDatas));
	objSwf.list:invalidateData();

	--更新奖励显示
	for i = 1, #AgoraModel.questList do
		local v = self.uiQuestItemList[i];
		local questVO = AgoraModel.questList[i];
		v.rewardList.dataProvider:cleanUp();
		v.rewardList.dataProvider:push(unpack(questVO.rewardList));
		v.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
		v.rewardList.itemRollOut = function() TipsManager:Hide(); end
		v.rewardList:invalidateData();
		v.btnGet.click = function() self:OnBtnGetClick(questVO.questIndex) end
	end
end

function AgoraView:OnAgoraUpdateItem(item)
	if not item then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local vo = AgoraUtils:ConvertItemVOToUI(item);
	local questIndex = item.questIndex;
	local uiData = UIData.encode(vo);
	objSwf.list.dataProvider[questIndex] = uiData;
	local uiItem = objSwf.list:getRendererAt(questIndex);
	if uiItem then
		uiItem:setData(uiData);
	end


	local uiQuestItem = self.uiQuestItemList[questIndex + 1];
	uiQuestItem.rewardList.dataProvider:cleanUp();
	uiQuestItem.rewardList.dataProvider:push(unpack(item.rewardList));
	uiQuestItem.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	uiQuestItem.rewardList.itemRollOut = function() TipsManager:Hide(); end
	uiQuestItem.rewardList:invalidateData();
	uiQuestItem.btnGet.click = function() self:OnBtnGetClick(item.questIndex) end
end

function AgoraView:UpdateRight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local vo = AgoraModel:GetCurQuest();

	objSwf.txtCount.text = string.format(StrConfig["agora1"], AgoraModel.curTimes, AgoraModel:GetDayMaxCount());

	if not AgoraModel:GetCurQuest() then
		objSwf.curPanel._visible = false;
	else
		objSwf.curPanel._visible = true;
--		local goalStr = AgoraUtils:GetGoalStr(vo.questId, vo.taofaId, vo.npcId);
--		if _G.isDebug then
--			goalStr = goalStr .. " questId:" .. vo.questId;
--		end
		local questVO = QuestModel:GetAgoraQuest();
		if questVO then
			objSwf.curPanel.txtGoal.htmlLabel = questVO:GetContentLabel();
		end
		objSwf.curPanel.list.dataProvider:cleanUp();
		objSwf.curPanel.list.dataProvider:push(unpack(vo.rewardList));
		objSwf.curPanel.list:invalidateData();
		objSwf.curPanel.list.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
		objSwf.curPanel.list.itemRollOut = function() TipsManager:Hide(); end
		--布局奖励显示
		local uiRewardItemList = { objSwf.curPanel.rightRewardItem1, objSwf.curPanel.rightRewardItem2, objSwf.curPanel.rightRewardItem3 };
		UIDisplayUtil:HCenterLayout(#vo.rewardList, uiRewardItemList, 64, 155, 168);
		uiRewardItemList = nil;
	end

	--20环全部完成奖励
	local reward20 = t_questagora_consts[1].reward;
	local list20 = RewardManager:Parse(reward20);
	if #list20 > 0 then
		objSwf.allDoneReward.rollOver = function(e) TipsManager:ShowItemTips(e.target.data.id); end
		objSwf.allDoneReward.rollOut = function(e) TipsManager:Hide(); end
		objSwf.allDoneReward:setData(list20[1]);

		objSwf.txtReward20Name.text = t_item[toint(GetCommaTable(reward20)[1])].name;
	end


	--刷新任务区域
	--自动刷新时间
	local stamp = AgoraModel.autoRefreshStamp;

	if stamp > 0 then
		local sec = stamp - GetServerTime();
		objSwf.txtRefreshCountDown._visible = false;
	--[[	objSwf.txtRefreshCountDown.htmlText = string.format(StrConfig["agora10"], CTimeFormat:sec2formatMinSec(sec));
		TimerManager:UnRegisterTimer(self.autoRefreshTimerKey);
		self.autoRefreshTimerKey = TimerManager:RegisterTimer(function(curTimes)
			if curTimes >= sec then
				TimerManager:UnRegisterTimer(self.autoRefreshTimerKey);
			else
				objSwf.txtRefreshCountDown.htmlText = string.format(StrConfig["agora10"], CTimeFormat:sec2formatMinSec(sec - curTimes));
			end
		end,1000,sec);]]
	else
		objSwf.txtRefreshCountDown._visible = false;
	end

	--[[self.canRefresh = true;
	--刷新条件1
	local curFinishCount = AgoraModel:GetCurFinishedCount();
	local refreshNeedCount = AgoraModel:GetRefreshNeedCount();
	local countConditionStr = string.format(StrConfig["agora7"], refreshNeedCount, curFinishCount, refreshNeedCount);
	local calcCountStr = "";
	if curFinishCount >= refreshNeedCount then
		calcCountStr = string.format("<font color='#00FF00'>(%s/%s)</font>", curFinishCount, refreshNeedCount);
	else
		self.canRefresh = false;
		calcCountStr = string.format("<font color='#FF0000'>(%s/%s)</font>", curFinishCount, refreshNeedCount);
	end
	objSwf.txtRefreshDone.htmlText = countConditionStr .. calcCountStr;

	--刷新条件2
	local isFreeCost = AgoraModel.isFreeRefresh;
	local costStr = ""
	if isFreeCost then
		objSwf.ybIcon._visible = false;
		costStr = StrConfig["agora12"];
	else
		objSwf.ybIcon._visible = true;
		costStr = StrConfig["agora13"];
		local costInfo = GetCommaTable(t_questagora_consts[1].refresh_cost);
		local costType = toint(costInfo[1]);
		local costVal = toint(costInfo[2]);
		if MainPlayerModel.humanDetailInfo[costType] >= costVal then
			costStr = costStr .. "<font color='#00ff00'>"..costVal.."</font>";
		else
			self.canRefresh = false;
			costStr = costStr .. "<font color='#ff0000'>"..costVal.."</font>";
		end
	end
	objSwf.txtFreeTip.htmlText = costStr;

	objSwf.txtRefreshTips.text = string.format(StrConfig["agora9"], t_questagora_consts[1].gratis_times);]]
end

function AgoraView:OnBtnGetClick(questIndex)
	if AgoraModel:GetCurQuest() then
		FloatManager:AddNormal( StrConfig["agora15"] )
		return;
	end
	if AgoraModel.curTimes >= AgoraModel:GetDayMaxCount() then
		FloatManager:AddNormal( StrConfig["agora16"] )
		return;
	end
	AgoraController:ReqAcceptQuestAgora(questIndex)
end

function AgoraView:OnGoPosClicked()
	local quest = QuestModel:GetAgoraQuest();
	quest:OnContentClick();
	self:Hide();
end

function AgoraView:OnBtnTeleportClicked()
	local quest = QuestModel:GetAgoraQuest();
	quest:Teleport();
	self:Hide();
end

function AgoraView:OnBtnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function AgoraView:OnBtnTeleportRollOut()
	TipsManager:Hide();
end

function AgoraView:OnBtnGiveUpClick()
	if not AgoraModel:GetCurQuest() then return; end
	AgoraController:ReqAbandonQuestAgora(AgoraModel:GetCurQuest().questIndex)
end

function AgoraView:OnBtnRefreshClick()
	if self.canRefresh then
		AgoraController:ReqRefreshQuestAgora()
	else
		FloatManager:AddNormal( StrConfig["agora14"] )
	end
end

function AgoraView:OnCheckBoxAutoClick()
	AgoraModel.auto = self.objSwf.checkBoxAuto.selected;
end

function AgoraView:IsTween()
	return true;
end

function AgoraView:GetPanelType()
	return 1;
end

function AgoraView:IsShowSound()
	return true;
end

--点击关闭按钮
function AgoraView:OnBtnCloseClick()
	self:Hide();
end

function AgoraView:ListNotificationInterests()
	return {
		NotifyConsts.AgoraUpdateItem,
		NotifyConsts.AgoraAbandonItem,
		NotifyConsts.AgoraUpdateAll,
	}
end

function AgoraView:HandleNotification(name, body)
	if name == NotifyConsts.AgoraUpdateItem then
		self:UpdateRight();
		self:OnAgoraUpdateItem(body.item);
	end
	if name == NotifyConsts.AgoraAbandonItem then
		self:UpdateQuestList();
		self:UpdateRight();
	end
	if name == NotifyConsts.AgoraUpdateAll then
		self:UpdateQuestList();
		self:UpdateRight();
	end

end


function AgoraView:OnHide()
	self.uiQuestItemList = nil;
	TimerManager:UnRegisterTimer(self.autoRefreshTimerKey);
	self.autoRefreshTimerKey = nil;
	self.canRefresh = false;
end