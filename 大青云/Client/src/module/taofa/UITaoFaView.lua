--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/6
    Time: 16:12
   ]]

_G.UITaoFaView = BaseUI:new("UITaoFaView");

function UITaoFaView:Create()
	self:AddSWF("taofaPanel.swf", true, "center");
end

function UITaoFaView:InitView()
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

	local totalTimes = TaoFaUtil:GetDayMaxCount();
	objSwf.guize.htmlText = string.format(StrConfig["taofa1"], totalTimes);

	self:UpdateRight();
end

function UITaoFaView:OnShow()
	self:InitView();
end

function UITaoFaView:Open()
	if not FuncManager:GetFuncIsOpen(FuncConsts.LieMo) then return; end
	local quest = QuestModel:GetTaoFaQuest();
	if not quest then return; end

	if self:IsShow() then
		self:InitView();
	else
		self:Show();
	end
end

function UITaoFaView:UpdateProgress(value)
	if not value then
		value = TaoFaModel.curFinishedTimes;
	end
	local totalTimes = TaoFaUtil:GetDayMaxCount();
	self.objSwf.progressBar.maximum = totalTimes;
	self.objSwf.progressBar.minimum = 0;
	self.objSwf.progressBar.value = value;
	self.objSwf.txt_jindu.text = string.format(StrConfig["taofa2"], value, totalTimes);
end


function UITaoFaView:UpdateRight()

	local quest = QuestModel:GetTaoFaQuest();
	if not quest then return; end
	self.objSwf.gotPanel.btnGoal.htmlLabel = quest:GetContentLabel();

	local questRewards = quest:GetShowRewards();
	self.objSwf.gotPanel.list.dataProvider:cleanUp();
	self.objSwf.gotPanel.list.dataProvider:push(unpack(questRewards));
	self.objSwf.gotPanel.list:invalidateData();
	self.objSwf.gotPanel.list.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	self.objSwf.gotPanel.list.itemRollOut = function() TipsManager:Hide(); end

	local totalS = { self.objSwf.gotPanel.item1, self.objSwf.gotPanel.item2, self.objSwf.gotPanel.item3, self.objSwf.gotPanel.item4 }
	UIDisplayUtil:HCenterLayout(#questRewards, totalS, 64, 75, 212);
	totalS = nil;
end

function UITaoFaView:OnBtnTeleportClicked()
	local quest = QuestModel:GetTaoFaQuest();
	if quest then
		quest:Teleport();
	end
	self:Hide();
end

function UITaoFaView:OnBtnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function UITaoFaView:OnBtnTeleportRollOut()
	TipsManager:Hide();
end


function UITaoFaView:OnGoPosClicked()
	local quest = QuestModel:GetTaoFaQuest();
	quest:OnContentClick();
	self:Hide();
end

function UITaoFaView:OnQuicklyFinishedClicked()
	local quest = QuestModel:GetTaoFaQuest();
	local questId = quest:GetQuestId();
	local needBY = toint(GetCommaTable(t_taofa[questId].consume)[2])
	local hasBY = MainPlayerModel.humanDetailInfo.eaBindMoney;
	local needYB = toint(GetCommaTable(t_taofa[questId].consume2)[2])
	local hasYB = MainPlayerModel.humanDetailInfo.eaUnBindMoney;
	local func = function()
		if hasBY < needBY and hasYB < needYB then
			FloatManager:AddNormal(string.format(StrConfig['taofa3'], needYB, needBY));
			return;
		end
		--一键完成
		TaoFaController:ReqQuickFinishTaoFaTask();
		--self:ClearInfo();
	end
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	self.confirmID = UIConfirm:Open(string.format(StrConfig['taofa4'], needYB, needBY), func);
end

function UITaoFaView:OnHide()
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
end

--点击关闭按钮
function UITaoFaView:OnBtnCloseClick()
	self:Hide();
end

function UITaoFaView:ListNotificationInterests()
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

function UITaoFaView:HandleNotification(name, body)
	if name == NotifyConsts.QuestAdd or
			name == NotifyConsts.QuestUpdate or name == NotifyConsts.QuestRefreshList then
		self:InitView();
	end
	if name == NotifyConsts.QuestRemove then
		self:Hide();
	end
end


function UITaoFaView:IsTween()
	return true;
end

function UITaoFaView:GetPanelType()
	return 1;
end