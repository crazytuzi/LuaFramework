--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/6
    Time: 16:12
   ]]

_G.UILieMoView = BaseUI:new("UILieMoView");

function UILieMoView:Create()
	self:AddSWF("liemoPanel.swf", true, "center");
end

function UILieMoView:InitView()
	local objSwf = self.objSwf;
	-- 界面加载完成后的
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	objSwf.gotPanel.btnGoal.click = function() self:OnGoPosClicked() end
	objSwf.gotPanel.btnTeleport.click = function() self:OnBtnTeleportClicked() end
	objSwf.gotPanel.btnTeleport.rollOver = function() self:OnBtnTeleportRollOver() end
	objSwf.gotPanel.btnTeleport.rollOut = function() self:OnBtnTeleportRollOut() end
	objSwf.gotPanel.gopos.click = function() self:OnGoPosClicked() end
	objSwf.gotPanel.quickfinish.click = function() self:OnQuicklyFinishedClicked() end

	objSwf.progressBar.trackWidthGap = 26;
	self:UpdateProgress();

	local totalTimes = QuestLieMoConsts:GetLieMoDayNum();
	objSwf.guize.htmlText = string.format(StrConfig["liemo1"], totalTimes);

	self:UpdateRight();
end

function UILieMoView:CheckOpen()
	local quest = QuestModel:GetLieMoQuest();
	if not quest then
		FloatManager:AddNormal( StrConfig['liemo5'] );
		return false;
	end
	return true;
end

function UILieMoView:OnShow()
	local quest = QuestModel:GetLieMoQuest();
	if not quest then
		return;
	end
	self:InitView();
end

function UILieMoView:Open()
	local quest = QuestModel:GetLieMoQuest();
	if not quest then return; end

	if self:IsShow() then
		self:InitView();
	else
		self:Show();
	end
end

function UILieMoView:UpdateProgress(value)
	if not value then
		local quest = QuestModel:GetLieMoQuest();
		if not quest then return; end
		value = quest:GetRound() - 1;
	end
	local totalTimes = QuestLieMoConsts:GetLieMoDayNum();
	self.objSwf.progressBar.maximum = totalTimes;
	self.objSwf.progressBar.minimum = 0;
	self.objSwf.progressBar.value = value;
	self.objSwf.txt_jindu.text = string.format(StrConfig["liemo2"], value, totalTimes);
end


function UILieMoView:UpdateRight()
	local quest = QuestModel:GetLieMoQuest();
	if not quest then return; end
	self.objSwf.gotPanel.btnGoal.htmlLabel = quest:GetContentLabel();

	local questRewards = quest:GetShowRewards();
	if questRewards then
		self.objSwf.gotPanel.list.dataProvider:cleanUp();
		self.objSwf.gotPanel.list.dataProvider:push(unpack(questRewards));
		self.objSwf.gotPanel.list:invalidateData();
		self.objSwf.gotPanel.list.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
		self.objSwf.gotPanel.list.itemRollOut = function() TipsManager:Hide(); end

		local totalS = { self.objSwf.gotPanel.item1, self.objSwf.gotPanel.item2, self.objSwf.gotPanel.item3, self.objSwf.gotPanel.item4 }
		UIDisplayUtil:HCenterLayout(#questRewards, totalS, 64, 75, 212);
		totalS = nil;
	end
end

function UILieMoView:OnBtnTeleportClicked()
	local quest = QuestModel:GetLieMoQuest();
	quest:Teleport();
	self:Hide();
end

function UILieMoView:OnBtnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function UILieMoView:OnBtnTeleportRollOut()
	TipsManager:Hide();
end


function UILieMoView:OnGoPosClicked()
	local quest = QuestModel:GetLieMoQuest();
	quest:OnContentClick();
	self:Hide();
end

function UILieMoView:OnQuicklyFinishedClicked()
	local quest = QuestModel:GetLieMoQuest();
	local questId = quest:GetId();
	local needBY = toint(GetCommaTable(t_todayquest[questId].consume)[2])
	local hasBY = MainPlayerModel.humanDetailInfo.eaBindMoney;
	local needYB = toint(GetCommaTable(t_todayquest[questId].consume2)[2])
	local hasYB = MainPlayerModel.humanDetailInfo.eaUnBindMoney;
	local func = function()
		if hasBY < needBY and hasYB < needYB then
			FloatManager:AddNormal(string.format(StrConfig['liemo3'], needYB, needBY));
			return;
		end
		--一键完成
		QuestController:ReqLieMoOneKeyFinish()
		--self:ClearInfo();
	end
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	self.confirmID = UIConfirm:Open(string.format(StrConfig['liemo4'], needYB, needBY), func);
end

function UILieMoView:OnHide()
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
end

--点击关闭按钮
function UILieMoView:OnBtnCloseClick()
	self:Hide();
end

function UILieMoView:ListNotificationInterests()
	return {
		NotifyConsts.QuestAdd,
		NotifyConsts.QuestRemove,
		NotifyConsts.QuestUpdate,
		NotifyConsts.QuestRefreshList,
		NotifyConsts.QuestFinish,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	}
end

function UILieMoView:HandleNotification(name, body)
	if name == NotifyConsts.QuestAdd or
			name == NotifyConsts.QuestUpdate or name == NotifyConsts.QuestRefreshList then
		self:InitView();
	end
end


function UILieMoView:IsTween()
	return true;
end

function UILieMoView:GetPanelType()
	return 1;
end