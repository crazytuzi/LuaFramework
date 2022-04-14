---
--- Created by  Administrator
--- DateTime: 2019/8/1 10:09
---
WarriorTowPanel = WarriorTowPanel or class("WarriorTowPanel", WindowPanel)
local this = WarriorTowPanel

function WarriorTowPanel:ctor(parent_node, parent_panel)
	
	self.abName = "warrior"
	self.assetName = "WarriorTowPanel"
	self.image_ab = "warrior_image";
	self.layer = "UI"
	
	self.panel_type = 2
	self.show_sidebar = true        --是否显示侧边栏
	--self.is_show_money=true
	if self.show_sidebar then
		-- 侧边栏配置
		self.sidebar_data = {
			{ text = ConfigLanguage.Warrior.rank, id = 1 },
		}
	end
	
end

function WarriorTowPanel:Open()
	WindowPanel.Open(self)
end

function WarriorTowPanel:dctor()
	-- GlobalEvent:RemoveTabListener(self.events)
	if self.currentView then
		self.currentView:destroy();
	end
end

function WarriorTowPanel:LoadCallBack()
	self:SetTileTextImage("warrior_image", "warrior_rank_title");
end

function WarriorTowPanel:InitUI()
	
end

function WarriorTowPanel:AddEvent()
	
end

function WarriorTowPanel:SwitchCallBack(index)
	if self.currentView then
		self.currentView:destroy();
	end
	
	self.currentView = nil
	if index == 1 then
		self.currentView = WarriorRankPanel(self.transform, "UI");
		self:PopUpChild(self.currentView)
	end
	self.selectedIndex = index
	
end