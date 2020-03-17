--[[
日环首次引导
lizhuangzhuang
2015年8月29日18:12:27
]]

_G.UIQuestDayFirstGuide = BaseUI:new("UIQuestDayFirstGuide");

function UIQuestDayFirstGuide:Create()
	self:AddSWF("taskDayFirstGuide.swf",true,"center");
end

function UIQuestDayFirstGuide:OnLoaded(objSwf)
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click = function() self:Hide(); end
	--
	objSwf.tfContent.htmlText = StrConfig['quest706'];
	objSwf.btnConfirm.label = StrConfig['quest707'];
	objSwf.btnCancel.label = StrConfig['quest708'];
end

function UIQuestDayFirstGuide:OnShow()
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfTime.htmlText = string.format(StrConfig["quest913"],10);
	self.autoTimerKey = TimerManager:RegisterTimer(function(count)
		if count == 10 then
			self.autoTimerKey = nil;
			self:OnBtnConfirmClick();
		else
			if not self.objSwf then return; end
			objSwf.tfTime.htmlText = string.format(StrConfig["quest913"],10-count);
		end
	end,1000,10);
end

function UIQuestDayFirstGuide:OnHide()
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
end

function UIQuestDayFirstGuide:OnBtnConfirmClick()
	QuestGuideManager:DoDayGuide();
	self:Hide();
end
