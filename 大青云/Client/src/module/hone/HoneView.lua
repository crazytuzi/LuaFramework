--[[
    Created by IntelliJ IDEA.
    历练 奇遇任务面板
    User: Hongbin Yang
    Date: 2016/9/5
    Time: 16:54
   ]]

_G.UIHoneView = BaseUI:new("UIHoneView");

UIHoneView.itemIDs = {180800001, 180800002, 180800003, 180800004}
UIHoneView.slots = {};
UIHoneView.signs = {};
UIHoneView.radioBtns = {};
UIHoneView.acceptItemID = 0;
UIHoneView.acceptItemIndex = 0;
UIHoneView.selectedItemIndex = -1;
UIHoneView.playEffectOnce = false;
local isClickedQuicklyFinished = false;

function UIHoneView:Create()
	self:AddSWF("lilian.swf", true, "center");
end

function UIHoneView:InitView()
	local objSwf = self.objSwf;
	-- 界面加载完成后的
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	objSwf.btnget.click = function() self:OnBtnGetClicked(); end;
	objSwf.btnHeCheng.click = function() self:OnBtnHeChengClicked() end
	objSwf.btnHeCheng.htmlLabel = UIStrConfig["honeview3"];
	objSwf.btnRule.rollOver = function () TipsManager:ShowBtnTips(StrConfig['hone8'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function () TipsManager:Hide(); end

	objSwf.gotPanel.btnGoal.click = function() self:OnGoPosClicked() end
	objSwf.gotPanel.btnTeleport.click = function() self:OnBtnTeleportClicked() end
	objSwf.gotPanel.btnTeleport.rollOver = function() self:OnBtnTeleportRollOver() end
	objSwf.gotPanel.btnTeleport.rollOut = function() self:OnBtnTeleportRollOut() end
	objSwf.gotPanel.gopos.click = function() self:OnGoPosClicked() end
	objSwf.gotPanel.getreward.click = function() self:OnGetRewardClicked() end
	objSwf.gotPanel.quickfinish.click = function() self:OnQuicklyFinishedClicked() end

	local totalTimes = RandomQuestConsts:GetRoundsPerDay();
	objSwf.progressBar.trackWidthGap = 26;
	objSwf.progressBar.maximum = totalTimes;
	self:UpdateProgress();

	objSwf.guize.htmlText = string.format(StrConfig["hone1"], totalTimes);

	--处理选择道具显示
	self.slots = {objSwf.resItem1, objSwf.resItem2, objSwf.resItem3, objSwf.resItem4};
	self.signs = {objSwf.signRewardMc1, objSwf.signRewardMc2, objSwf.signRewardMc3, objSwf.signRewardMc4};
	self.radioBtns = {objSwf.rewardBtn1, objSwf.rewardBtn2, objSwf.rewardBtn3, objSwf.rewardBtn4 }
	self.citems = {objSwf.citem1, objSwf.citem2, objSwf.citem3, objSwf.citem4}
	for k, v in pairs(self.citems) do
		v._visible = false;
	end

	for k, v in pairs(self.slots) do
		v.button.click = function() UIHoneView:OnItemClick(k) end
		v.button.rollOver = function() UIHoneView:OnItemRollOver(v) end
		v.button.rollOut = function() UIHoneView:OnItemRollOut() end
	end

	for k, v in pairs(self.radioBtns) do
		v.click = function() self:OnItemRadioBtnClicked(k) end
	end


	self:UpdateItemView();
	self:UpdateRight()
end

function UIHoneView:ClearInfo()
	self.acceptItemID = 0;
	self.acceptItemIndex = 0;
end

function UIHoneView:UpdateAcceptInfo(questId)
	local acceptQuestID = questId;
	local cfg = t_questrandom[acceptQuestID];
	if cfg then
		self.acceptItemID = toint(GetCommaTable(cfg.item)[1]);
		for k, v in pairs(self.itemIDs) do
			if v == self.acceptItemID then
				self.acceptItemIndex = k;
				break;
			end
		end
	end
end

function UIHoneView:OnShow()
	self.playEffectOnce = false;
	self.acceptItemID = 0;
	self.acceptItemIndex = 0;
	if #self.args > 0 then
		self:UpdateAcceptInfo(self.args[1]);
	end
	self:InitView();
end

function UIHoneView:UpdateProgress(value)
	if not value then
		value = QuestModel.randomQuestFinishedCount;
	end
	local totalTimes = RandomQuestConsts:GetRoundsPerDay();
	self.objSwf.progressBar.maximum = totalTimes;
	self.objSwf.progressBar.minimum = 0;
	self.objSwf.progressBar.value = value;
	self.objSwf.txt_jindu.text = string.format(StrConfig["hone2"], value, totalTimes);
end

function UIHoneView:UpdateItem()
	local item = {};
	for k, v in pairs(self.itemIDs) do
		local itemCount = BagModel:GetItemNumInBag(v);
		local vo = BagSlotVO:new();
		vo.tid = v;
		vo.count = itemCount;
		vo.opened = true;
		vo.hasItem = true;
		vo.showCount = true;
		vo.bindState = BagConsts.Bind_None;
		vo.bagType = BagConsts.BagType_None;
		table.push(item, vo:GetUIData());
	end

	for i = 1, 4 do
		local slot = self.slots[i];
		slot:setData(item[i]);
	end
end

function UIHoneView:UpdateItemView()
	self:UpdateItem();

	for i = 1, 4 do
		local sign = self.signs[i];
		local radio = self.radioBtns[i];
		if self.acceptItemIndex == i then
			sign._visible = true;
			radio.selected = true;
		else
			sign._visible = false;
			radio.selected = false;
		end
	end
	self:OnItemRadioBtnClicked(self.acceptItemIndex)
	--自动选择一个
	if self.acceptItemIndex <= 0 then
		for k, v in pairs(self.itemIDs) do
			local itemCount = BagModel:GetItemNumInBag(v);
			if itemCount > 0 then
				self:OnItemRadioBtnClicked(k)
				self.radioBtns[k].selected = true;
			end
		end
	end
end

function UIHoneView:UpdateRight()
	if self.acceptItemIndex > 0 then
		--接取了任务
		self.objSwf.btnget._visible = false;

		self.objSwf.gotPanel._visible = true;
		self.objSwf.nonePanel._visible = false;

		local quest = QuestModel:GetRandomQuest();
		if not quest then return; end
		self.objSwf.gotPanel.btnGoal.htmlLabel = quest:GetGoal():GetGoalLabel();

		local questRewards = quest:GetShowRewards();
		self.objSwf.gotPanel.list.dataProvider:cleanUp();
		self.objSwf.gotPanel.list.dataProvider:push(unpack(questRewards));
		self.objSwf.gotPanel.list:invalidateData();
		self.objSwf.gotPanel.list.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
		self.objSwf.gotPanel.list.itemRollOut = function () TipsManager:Hide(); end

		local totalS = {self.objSwf.gotPanel.item1, self.objSwf.gotPanel.item2, self.objSwf.gotPanel.item3, self.objSwf.gotPanel.item4}
		UIDisplayUtil:HCenterLayout(#questRewards, totalS, 64, 75, 212);
		totalS = nil;

		--任务可以领奖的时候才可以点击
		if quest:GetState() == QuestConsts.State_CanFinish and isClickedQuicklyFinished == false then
			self.objSwf.gotPanel.gopos._visible = false;
			self.objSwf.gotPanel.getreward._visible = true;
			self.objSwf.gotPanel.getreward:showEffect(ResUtil:GetButtonEffect10());
			self.objSwf.gotPanel.quickfinish.disabled = true;
			if self.playEffectOnce == false then
				self.objSwf.questFinishEffect._visible = true;
				self.objSwf.questFinishEffect:playEffect(1);
				self.playEffectOnce = true;
			end
		else
			self.objSwf.gotPanel.gopos._visible = true;
			self.objSwf.gotPanel.getreward._visible = false;
			self.objSwf.gotPanel.getreward:clearEffect();
			self.objSwf.gotPanel.quickfinish.disabled = false;
			self.objSwf.questFinishEffect._visible = false;
		end
		self.objSwf.gotPanel.btnTeleport._visible = quest:CanTeleport();
	else
		--未接取
		self.objSwf.btnget._visible = true;

		self.objSwf.gotPanel._visible = false;
		self.objSwf.nonePanel._visible = true;
		self.objSwf.questFinishEffect._visible = false;
		--判断完成了多少次
		local curTimes = QuestModel.randomQuestFinishedCount;
		local totalTimes = RandomQuestConsts:GetRoundsPerDay();
		if curTimes < totalTimes then
			self.objSwf.nonePanel.nowork._visible = true;
			self.objSwf.nonePanel.finished._visible = false;
		else
			self.objSwf.nonePanel.nowork._visible = false;
			self.objSwf.nonePanel.finished._visible = true;
		end
	end
end

function UIHoneView:OnBtnGetClicked()
	if self.selectedItemIndex <= 0 then
		FloatManager:AddNormal( StrConfig['hone3'] );
		return;
	end
	local selectedItemID = self.itemIDs[self.selectedItemIndex];
	local itemCount = BagModel:GetItemNumInBag(selectedItemID);
	if itemCount <= 0 then
		FloatManager:AddNormal( StrConfig['hone4'] );
		UIQuickBuyConfirm:Open(self, selectedItemID);
		return;
	end
	local totalTimes = RandomQuestConsts:GetRoundsPerDay();
	if QuestModel.randomQuestFinishedCount >= totalTimes then
		FloatManager:AddNormal( StrConfig['hone5'] );
		return;
	end

	local questid = 0;
	local selectedItemID = self.itemIDs[self.selectedItemIndex];
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	for k, v in pairs(t_questrandom) do
		local cfgItemID = toint(GetCommaTable(v.item)[1]);
		if level >= v.lv_min and level <= v.lv_max and cfgItemID == selectedItemID then
			questid = v.id;
			break;
		end
	end
	if questid <= 0 then
		return;
	end
	isClickedQuicklyFinished = false;
	QuestController:AcceptQuest(questid);
	self:ClearInfo();
	self:UpdateAcceptInfo(questid);
	self.playEffectOnce = true;
end

function UIHoneView:OnBtnHeChengClicked()
	FuncManager:OpenFunc(FuncConsts.HeCheng, true, self.itemIDs[2]);
end

function UIHoneView:OnBtnTeleportClicked()
	local quest = QuestModel:GetRandomQuest();
	quest:Teleport();
	self:Hide();
end

function UIHoneView:OnBtnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function UIHoneView:OnBtnTeleportRollOut()
	TipsManager:Hide();
end


function UIHoneView:OnGoPosClicked()
	local quest = QuestModel:GetRandomQuest();
	quest:OnContentClick();
	self:Hide();
end

function UIHoneView:OnGetRewardClicked()
	local quest = QuestModel:GetRandomQuest();
	QuestController:FinishQuest(quest:GetId());
	self:ClearInfo();
end

function UIHoneView:OnQuicklyFinishedClicked()
	local quest = QuestModel:GetRandomQuest();
	local questId = quest:GetId();
	local needBY = toint(GetCommaTable(t_questrandom[questId].quick_finish)[2]);
	local hasBY = MainPlayerModel.humanDetailInfo.eaBindMoney;
	local needYB = toint(GetCommaTable(t_questrandom[questId].quick_finish2)[2]);
	local hasYB = MainPlayerModel.humanDetailInfo.eaUnBindMoney;
	local func = function()
		if hasBY < needBY and hasYB < needYB then
			FloatManager:AddNormal(string.format(StrConfig['hone6'], needYB, needBY));
			return;
		end
		isClickedQuicklyFinished = true;
		--一键完成
		QuestController:FinishQuest(questId, 1, 1);
--		QuestGuideManager:DoIdleQuest();
		self:ClearInfo();
	end
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	self.confirmID = UIConfirm:Open(string.format(StrConfig['hone7'], needYB, needBY), func);
end

function UIHoneView:OnItemRadioBtnClicked(index)
	self.selectedItemIndex = index;
	for k, v in pairs(self.citems) do
		v._visible = index == k;
	end
end

function UIHoneView:OnItemClick(index)
	self:OnItemRadioBtnClicked(index);
	self.radioBtns[index].selected = true;
end

function UIHoneView:OnItemRollOver(item)
	local data = item.userdata;
	TipsManager:ShowItemTips(data.tid);
end
function UIHoneView:OnItemRollOut()
	TipsManager:Hide();
end

function UIHoneView:OnHide()
	self.objSwf.gotPanel.getreward:clearEffect();
	self.acceptItemID = 0;
	self.acceptItemIndex = 0;
	self.selectedItemIndex = -1;
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
end

function UIHoneView:IsTween()
	return true;
end

function UIHoneView:GetPanelType()
	return 0;
end

function UIHoneView:ESCHide()
	return true;
end

function UIHoneView:IsShowLoading()
	return true;
end

function UIHoneView:IsShowSound()
	return true;
end

function UIHoneView:ListNotificationInterests()
	return {
		NotifyConsts.QuestAdd,
		NotifyConsts.QuestRemove,
		NotifyConsts.QuestUpdate,
		NotifyConsts.QuestRefreshList,
		NotifyConsts.QuestFinish,
		NotifyConsts.BagItemNumChange,
	}
end

function UIHoneView:HandleNotification( name, body )
	if name == NotifyConsts.QuestAdd or name == NotifyConsts.QuestRemove or
			name == NotifyConsts.QuestUpdate or name == NotifyConsts.QuestRefreshList then
		if body.questType ~= QuestConsts.Type_Random then return; end
		local curTimes = QuestModel.randomQuestFinishedCount;
		local totalTimes = RandomQuestConsts:GetRoundsPerDay();
		if curTimes >= totalTimes then
			self:Hide();
			return;
		end
		self:InitView();
	end
	if name == NotifyConsts.QuestFinish then
		if body.questType ~= QuestConsts.Type_Random then return; end
		local questId = body.id;
		local quest = QuestModel:GetQuest(questId);
		if not quest then return; end
		if quest:GetType() == QuestConsts.Type_Random then
			self:ClearInfo();
			self:InitView();
		end
	end
	if name == NotifyConsts.BagItemNumChange then
		for k, v in pairs(self.itemIDs) do
			if v == body.id then
				self:UpdateItem();
				return;
			end
		end
	end
end

--点击关闭按钮
function UIHoneView:OnBtnCloseClick()
	self:Hide();
end
