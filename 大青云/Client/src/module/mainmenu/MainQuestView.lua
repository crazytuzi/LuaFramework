--[[
主界面：任务追踪
2015年4月23日17:31:13
haohu
]]

_G.UIMainQuest = BaseUI:new("UIMainQuest");

UIMainQuest.TRUNK = "trunk";
UIMainQuest.ALL = "all";

UIMainQuest.currentPanel = nil;
UIMainQuest.titleSelected = false;
function UIMainQuest:Create()
	self:AddSWF("mainPageTask.swf", true, "bottomFloat");
	self:AddChild( UIMainQuestTrunk, UIMainQuest.TRUNK );
	self:AddChild( UIMainQuestAll, UIMainQuest.ALL );
end

function UIMainQuest:NeverDeleteWhenHide()
	return true;
end

function UIMainQuest:OnLoaded( objSwf )
	local btnTitle = self:CreateTitleBtn()
	btnTitle.click = function(e) self:OnBtnTitleClick(e) end
	self:GetChild( UIMainQuest.TRUNK ):SetContainer( objSwf.childPanel );
	self:GetChild( UIMainQuest.ALL ):SetContainer( objSwf.childPanel );
end

function UIMainQuest:CreateTitleBtn()
	local objSwf = self.objSwf
	if not objSwf then return end
	local depth = objSwf:getNextHighestDepth();
	local btnTitle = objSwf.buttonPanel:attachMovie("BtnTitle", "btnTitle", depth)
	btnTitle._x = 14
	btnTitle._y = 26
	btnTitle.toggle = true
	return btnTitle
end

function UIMainQuest:OnBtnTitleClick(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	local selected = e.target.selected
	self.titleSelected = selected;
	local panel = objSwf.childPanel
	panel._visible = not selected
	panel.hitTestDisable = selected
	self:LayoutMainLvQuestView();
end

function UIMainQuest:LayoutMainLvQuestView()
	local value = self.titleSelected;
	local objSwf = self.objSwf
	if not objSwf then return end
	if not UIMainLvQuestTitle.objSwf then return; end
	UIMainLvQuestTitle.objSwf._x = self.objSwf._x;
	if value then
		UIMainLvQuestTitle.objSwf._y = self.objSwf._y + 31;
	else
		UIMainLvQuestTitle.objSwf._y = self.objSwf._y + 278;
	end
	if MainQuestLvFinishedRewardView:IsShow() then
		if not MainQuestLvFinishedRewardView.objSwf then return; end
		MainQuestLvFinishedRewardView.objSwf._x, MainQuestLvFinishedRewardView.objSwf._y = MainQuestLvFinishedRewardView:GetCfgPos();
	end
end

function UIMainQuest:OnResize(dwWidth,dwHeight)
	self:LayoutMainLvQuestView();
end

function UIMainQuest:GetWidth()
	return 270;
end

--面板加载的附带资源
function UIMainQuest:WithRes()
	return { "mainPageTaskTrunk.swf", "mainPageTaskAll.swf"};
end

function UIMainQuest:OnShow()
	self:UpdateShow();
	self:LayoutMainLvQuestView();
end

function UIMainQuest:ShowTrunkGuide(visible)
	local panelName = self.currentPanel;
	if not panelName then return end
	local panel = self:GetChild( panelName );
	panel:ShowTrunkGuide( visible );
end

function UIMainQuest:ShowDailyGuide(visible)
	if self.currentPanel ~= UIMainQuest.ALL then return; end
	local panel = self:GetChild( UIMainQuest.ALL );
	panel:ShowDayGuide(visible);
end

function UIMainQuest:PlayFinishEffect()
	local panelName = self.currentPanel;
	if not panelName then return end
	local currentPanel = self:GetChild(panelName);
	--TODO 屏蔽掉 2016-9-18 yanghongbin/jianghaoran
	--currentPanel:PlayFinishEffect();
end

function UIMainQuest:UpdateShow()
	local panelName = self:GetShowPanel();
	self:ShowChild( panelName );
	self.currentPanel = panelName;

end

function UIMainQuest:GetShowPanel()
	--根据主线任务判断
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then return UIMainQuest.ALL; end
	local cfg = questVO:GetCfg();
--	if true then
--		return UIMainQuest.ALL;
--	end
	if cfg.new_headline ~= "" then
		QuestConsts.IsNewPlayerTrunk = true;
		return UIMainQuest.TRUNK;
	else
		QuestConsts.IsNewPlayerTrunk = false;
		return UIMainQuest.ALL;
	end
end

function UIMainQuest:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.QuestUpdate,
	};
end

function UIMainQuest:HandleNotification( name, body )
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:UpdateShow();
		end
	elseif name == NotifyConsts.QuestUpdate then
		self:UpdateShow();
	end
end