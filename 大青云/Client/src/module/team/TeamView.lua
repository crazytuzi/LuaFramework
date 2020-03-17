--[[
队伍:主面板
郝户
2014年9月24日16:22:09
]]


_G.UITeam = BaseUI:new("UITeam");

UITeam.tabButton = {};

function UITeam:Create()
	self:AddSWF("teamMainPanel.swf", true, "center");

	self:AddChild( UITeamMine,         TeamConsts.TabTeamMine     );
	self:AddChild( UITeamNearby,       TeamConsts.TabTeamNearby   );
	self:AddChild( UITeamPlayerNearby, TeamConsts.TabPlayerNearby );
end

function UITeam:OnLoaded(objSwf, name)
	-- set child panel
	self:GetChild( TeamConsts.TabTeamMine     ):SetContainer(objSwf.childPanel);
	self:GetChild( TeamConsts.TabTeamNearby   ):SetContainer(objSwf.childPanel);
	self:GetChild( TeamConsts.TabPlayerNearby ):SetContainer(objSwf.childPanel);
	--tab button 
	self.tabButton[ TeamConsts.TabTeamMine     ] = objSwf.btnMyTeam;
	self.tabButton[ TeamConsts.TabTeamNearby   ] = objSwf.btnTeamNearby;
	self.tabButton[ TeamConsts.TabPlayerNearby ] = objSwf.btnPlayerNearby;
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName); end;
	end
	--close button
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
end

function UITeam:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

--面板加载的附带资源
function UITeam:WithRes()
	return { "teamMinePanel.swf" };
end

function UITeam:IsTween()
	return true;
end

function UITeam:GetPanelType()
	return 1;
end

function UITeam:IsShowSound()
	return true;
end

function UITeam:OnShow(name)
	self:TurnToSubpanel( TeamConsts.TabTeamMine );
end

function UITeam:GetWidth(name)
	return 1146;
end

function UITeam:GetHeight(name)
	return 687;
end

function UITeam:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName);
end

function UITeam:TurnToSubpanel(panelName)
	local tabBtn = self.tabButton[panelName];
	if tabBtn then
		tabBtn.selected = true;
		local child = self:GetChild(panelName);
		if child and not child:IsShow() then
			self:ShowChild(panelName);
		end
	end
end

function UITeam:ShowMyTeam()
	self:TurnToSubpanel( TeamConsts.TabTeamMine );
end

function UITeam:OnBtnCloseClick()
	self:Hide();
end