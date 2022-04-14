---
--- Created by  Administrator
--- DateTime: 2019/8/1 10:22
---
PeakArenaShowPanel = PeakArenaShowPanel or class("PeakArenaShowPanel", BaseItem)
local this = PeakArenaShowPanel

function PeakArenaShowPanel:ctor(parent_node, parent_panel)

    self.abName = "peakArena";
    self.image_ab = "peakArena_image";
    self.assetName = "PeakArenaShowPanel"
    self.layer = "UI"
    self.events = {}
	self.leftItems = {}
	self.rightItems = {}
    self.model = PeakArenaModel:GetInstance()
    PeakArenaShowPanel.super.Load(self)
end

function PeakArenaShowPanel:dctor()
    self.model:RemoveTabListener(self.events)
	for k, v in pairs(self.leftItems) do
		v:destroy()
	end
	self.leftItems = {}
	
	for k, v in pairs(self.rightItems) do
		v:destroy()
	end
	self.rightItems = {}
end

function PeakArenaShowPanel:LoadCallBack()
    self.nodes = {
		"PeakArenaRightItem","leftScrollView/Viewport/leftContent",
		"PeakArenaLeftItem","rightScrollView/Viewport/rightContent",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function PeakArenaShowPanel:InitUI()
	self:InitLeftItems()
end

function PeakArenaShowPanel:AddEvent()
	
	self.events[#self.events + 1] = self.model:AddListener(PeakArenaEvent.ShowPanelLeftClick,handler(self,self.ShowPanelLeftClick))
end

function PeakArenaShowPanel:InitLeftItems()
	local cfg = Config.db_combat1v1_group
	for i = 1, #cfg do
		local item = self.leftItems[i]
		if not item then
			item = PeakArenaLeftItem(self.PeakArenaLeftItem.gameObject,self.leftContent,"UI")
			self.leftItems[i] = item
		end
		item:SetData(cfg[i])
	end
	self:ShowPanelLeftClick(self.leftItems[1].data.grade)
end

function PeakArenaShowPanel:ShowPanelLeftClick(index)
	for k, v in pairs(self.leftItems) do
		if index == v.data.grade then
			v:SetShow(true)
			self:InitRightItems(index)
		else
			v:SetShow(false)	
		end
	end
end

function PeakArenaShowPanel:InitRightItems(grade)
	local tab =	self.model:GetGradeTab(grade)
	self.rightItems = self.rightItems or {}
	for i = 1, #tab do
		local item = self.rightItems[i]
		if not item then
			item = PeakArenaRightItem(self.PeakArenaRightItem.gameObject,self.rightContent,"UI")
			self.rightItems[i] = item
		else
			item:SetVisible(true)
		end
		item:SetData(tab[i],i)
	end
	
	for i = #tab + 1,#self.rightItems do
		local buyItem = self.rightItems[i]
		buyItem:SetVisible(false)
	end
end
