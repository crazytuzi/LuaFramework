--[[
主界面：等级任务追踪标题
2015年9月29日17:31:05
haohu
]]

_G.UIMainLvQuestTitle = BaseUI:new("UIMainLvQuestTitle");

UIMainLvQuestTitle.PANEL = "panel";

function UIMainLvQuestTitle:Create()
	self:AddSWF("mainPageTask.swf", true, "bottom");
	self:AddChild( UIMainLvQuest, UIMainLvQuestTitle.PANEL );
end

function UIMainLvQuestTitle:NeverDeleteWhenHide()
	return true
end

function UIMainLvQuestTitle:OnLoaded( objSwf )
	self:GetChild( UIMainLvQuestTitle.PANEL ):SetContainer( objSwf.childPanel );
	local btnTitle = self:CreateTitleBtn()
	btnTitle.click = function(e) self:OnBtnTitleClick(e) end
	UIMainQuest:LayoutMainLvQuestView();
end

function UIMainLvQuestTitle:CreateTitleBtn()
	local objSwf = self.objSwf
	if not objSwf then return end
   	local depth = objSwf:getNextHighestDepth()
	local btnTitle = objSwf:attachMovie("BtnTitle2", "btnTitle", depth)
	btnTitle._x = 14
	btnTitle._y = 26
	btnTitle.toggle = true
	return btnTitle
end

function UIMainLvQuestTitle:OnShow()
	self:ShowChild( UIMainLvQuestTitle.PANEL )
	self:ToggleShowState()
	UIMainQuest:LayoutMainLvQuestView()
end

function UIMainLvQuestTitle:OnBtnTitleClick(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	local selected = e.target.selected
	local panel = objSwf.childPanel
	panel._visible = not selected
	panel.hitTestDisable = selected
end
function UIMainLvQuestTitle:GetWidth()
	return 270;
end

function UIMainLvQuestTitle:GetHeight()
	return 240;
end

function UIMainLvQuestTitle:ListNotificationInterests()
	return {
		NotifyConsts.QuestAdd,
		NotifyConsts.QuestRemove,
	};
end

--消息处理
function UIMainLvQuestTitle:HandleNotification( name, body )
	if name == NotifyConsts.QuestRemove or NotifyConsts.QuestAdd then
		self:ToggleShowState()
	end
end

function UIMainLvQuestTitle:ToggleShowState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local hasLevelQuest = QuestModel:HasLevelQuest()
	objSwf._visible = hasLevelQuest
	objSwf.hitTestDisable = not hasLevelQuest
end

--面板加载的附带资源
function UIMainLvQuestTitle:WithRes()
	return { "mainPageTaskLv.swf"};
end