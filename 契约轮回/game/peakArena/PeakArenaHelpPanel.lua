---
--- Created by  Administrator
--- DateTime: 2019/8/1 10:22
---
PeakArenaHelpPanel = PeakArenaHelpPanel or class("PeakArenaHelpPanel", BaseItem)
local this = PeakArenaHelpPanel

function PeakArenaHelpPanel:ctor(parent_node, parent_panel)
	
	self.abName = "peakArena";
	self.image_ab = "peakArena_image";
	self.assetName = "PeakArenaHelpPanel"
	self.layer = "UI"
	self.events = {}
	self.model = PeakArenaModel:GetInstance()
	PeakArenaHelpPanel.super.Load(self)
end

function PeakArenaHelpPanel:dctor()
	self.model:RemoveTabListener(self.events)
end

function PeakArenaHelpPanel:LoadCallBack()
	self.nodes = {
		"des"
	}
	self:GetChildren(self.nodes)
	self.des = GetText(self.des)
	self:InitUI()
	self:AddEvent()
end

function PeakArenaHelpPanel:InitUI()
	self.des.text = HelpConfig.Com1V1.Help
end

function PeakArenaHelpPanel:AddEvent()
	
	--self.events[#self.events + 1] = self.model:AddListener(PeakArenaEvent.ShowPanelLeftClick,handler(self,self.ShowPanelLeftClick))
end

