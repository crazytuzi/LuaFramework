---
--- Created by  Administrator
--- DateTime: 2019/8/1 10:09
---
PeakArenaTowPanel = PeakArenaTowPanel or class("PeakArenaTowPanel", WindowPanel)
local this = PeakArenaTowPanel

function PeakArenaTowPanel:ctor(parent_node, parent_panel)

	self.abName = "peakArena"
	self.assetName = "PeakArenaTowPanel"
	self.image_ab = "peakArena_image";
	self.layer = "UI"
	
	self.panel_type = 3
	self.model = PeakArenaModel:GetInstance()
	self.show_sidebar = true        --是否显示侧边栏
	--self.is_show_money=true
	if self.show_sidebar then
		-- 侧边栏配置
		self.sidebar_data = {
			{ text = ConfigLanguage.PeakArena.grade, id = 1 },
			{ text = ConfigLanguage.PeakArena.help , id = 2 },
		}
	end
	
end

function PeakArenaTowPanel:Open()
	WindowPanel.Open(self)
end

function PeakArenaTowPanel:dctor()
   -- GlobalEvent:RemoveTabListener(self.events)
	if self.currentView then
		self.currentView:destroy();
	end
end

function PeakArenaTowPanel:LoadCallBack()
	self:SetTileTextImage("peakArena_image", "PArena_title_text1");
end

function PeakArenaTowPanel:InitUI()

end

function PeakArenaTowPanel:AddEvent()

end

function PeakArenaTowPanel:SwitchCallBack(index)
	if self.currentView then
		self.currentView:destroy();
	end
	
	self.currentView = nil
	if index == 1 then
		self.currentView = PeakArenaShowPanel(self.transform, "UI");
		self:PopUpChild(self.currentView)
		
	elseif index == 2 then
		self.currentView = PeakArenaHelpPanel(self.transform, "UI");
		self:PopUpChild(self.currentView)
	end
	self.selectedIndex = index
	
end