--[[
帮派副本-主面板（无任何可视元素，只有一个childPanel加载子面板用）
haohu
2015年1月8日17:43:15
]]

_G.UIUnionDungeonMain = BaseUI:new("UIUnionDungeonMain");

UIUnionDungeonMain.firstShowPanel = nil

function UIUnionDungeonMain:Create()
	self:AddSWF("unionDungeonMainPanel.swf", true, nil);
	self:AddChild( UIUnionDungeon,     UnionDungeonConsts.TabList );
	self:AddChild( UIUnionDungeonHell, UnionDungeonConsts.TabHell );
	self:AddChild( UIUnionWar,         UnionDungeonConsts.WarActi );
	self:AddChild( UIUnionCityWar,     UnionDungeonConsts.CityWarActi );
	self:AddChild( UIUnionBoss,        UnionDungeonConsts.UnionBossActi );
	self:AddChild( UIUnionDiGong,      UnionDungeonConsts.UnionDiGongActi );
end

function UIUnionDungeonMain:OnLoaded(objSwf)
	self:GetChild( UnionDungeonConsts.TabHell ):SetContainer( objSwf.childPanel );
	self:GetChild( UnionDungeonConsts.TabList ):SetContainer( objSwf.childPanel );
	self:GetChild( UnionDungeonConsts.WarActi ):SetContainer( objSwf.childPanel );
	self:GetChild( UnionDungeonConsts.CityWarActi ):SetContainer( objSwf.childPanel );
	self:GetChild( UnionDungeonConsts.UnionBossActi ):SetContainer( objSwf.childPanel );
	self:GetChild( UnionDungeonConsts.UnionDiGongActi ):SetContainer( objSwf.childPanel );
end

function UIUnionDungeonMain:OnShow()
	self:InitShow();
end

function UIUnionDungeonMain:OnHide()
	--是否有组队提示
	TeamUtils:UnRegisterNotice(self:GetName())
end;

function UIUnionDungeonMain:InitShow()
	self:TurnToSubpanel( self:GetFirstPanel() );
end

function UIUnionDungeonMain:WithRes()
	return { "unionDungeonPanel.swf" };
end

function UIUnionDungeonMain:TurnToDungeonListPanel()
	self:TurnToSubpanel( UnionDungeonConsts.TabList )
end

function UIUnionDungeonMain:TurnToSubpanel( panelName )
	self:ShowChild( panelName );
end

function UIUnionDungeonMain:GetFirstPanel()
	if self.firstShowPanel then
		local panel = self.firstShowPanel;
		self.firstShowPanel = nil;
		return panel;
	end
	return UnionDungeonConsts.TabList;
end

-- 仅生效一次
function UIUnionDungeonMain:SetFirstPanel(panelName)
	self.firstShowPanel = panelName;
end