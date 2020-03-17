--[[
任务主面板
lizhuangzhuang
2014年7月22日12:22:40
]]

_G.UIQuest = BaseUI:new("UIQuest");

UIQuest.tabButton = {};
UIQuest.firstShowTab = "trunk";

function UIQuest:Create()
	self:AddSWF("taskMainPanel.swf", true, "center");
	

	if QuestConsts.IsOpenTrunk then
		self:AddChild(UIQuestTrunk,"trunk");
	end
	self:AddChild(UIQuestDay,"day");
end

function UIQuest:OnLoaded(objSwf, name)
	--set child container
	if QuestConsts.IsOpenTrunk then
		self:GetChild("trunk"):SetContainer(objSwf.childPanel);
	end
	self:GetChild("day"):SetContainer(objSwf.childPanel);
	--
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	-- objSwf.btnTrunk.visible = QuestConsts.IsOpenTrunk;
	-- objSwf.btnDay.visible = QuestConsts.IsOpenTrunk;
	-- self.tabButton["trunk"] = objSwf.btnTrunk;
	-- self.tabButton["day"] = objSwf.btnDay;
	-- for name, btn in pairs(self.tabButton) do
	-- 	btn.data = name;
	-- end
	-- objSwf._buttonGroup_tab.change = function(e) self:OnTabChange(e); end
end

-- function UIQuest:OnDelete()
-- 	for k,_ in pairs(self.tabButton) do
-- 		self.tabButton[k] = nil;
-- 	end
-- end

function UIQuest:OnShow(name)
	self:ShowTab( self:GetNextFirstShowTab() );
end
function UIQuest:GetPanelType()
	return 1;
end
--面板加载的附带资源
function UIQuest:WithRes()
	return { "taskDayPanel.swf", "taskTrunkPanel.swf" };
end

function UIQuest:GetWidth(szName)
	return 696;
end

--点击关闭按钮
function UIQuest:OnBtnCloseClick()
	self:Hide();
end

--切换标签
-- function UIQuest:OnTabChange(e)
-- 	local name = e.data;
-- 	if not name then return; end
-- 	if name == "day" then -- 日环如未开启，提示
-- 		if QuestModel:GetDQState() == QuestConsts.QuestDailyStateNone then
-- 			local tabBtn = e.item;
-- 			tabBtn.selected = false;
-- 			FloatManager:AddCenter( string.format( StrConfig['quest002'], QuestConsts:GetDQOpenLevel() ) );
-- 			self:ShowTab(self.currentTab);
-- 			return;
-- 		end
-- 	end
-- 	self:ShowTab(name);
-- end

--显示分页
function UIQuest:ShowTab(name)
	-- if not self.tabButton[name] then
	-- 	return;
	-- end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self:ShowChild(name);
	-- local tabBtn = self.tabButton[name];
	-- if tabBtn then
	-- 	tabBtn.selected = true;
	-- end
	self.currentTab = name;
end

function UIQuest:GetNextFirstShowTab()
	local firstShowTab = self.firstShowTab;
	if firstShowTab then
		self.firstShowTab = nil;
		return firstShowTab;
	end
	return "trunk";
end

function UIQuest:SetNextFirstShowTab( panelName )
	self.firstShowTab = panelName;
end

function UIQuest:Open(tabType)
	if tabType == QuestConsts.Type_Trunk then
		if not self:IsShow() then
			self:SetNextFirstShowTab("trunk")
			self:Show();
		else
			self:ShowTab("trunk");
		end
	elseif tabType == QuestConsts.Type_Day then
		if not self:IsShow() then
			self:SetNextFirstShowTab("day")
			self:Show();
		else
			self:ShowTab("day");
		end
	end
end



