---
--- Created by  Administrator
--- DateTime: 2019/8/1 10:22
---
PeakArenaRewardPanel = PeakArenaRewardPanel or class("PeakArenaRewardPanel", BaseItem)
local this = PeakArenaRewardPanel

function PeakArenaRewardPanel:ctor(parent_node, parent_panel)
	
	self.abName = "peakArena";
	self.image_ab = "peakArena_image";
	self.assetName = "PeakArenaRewardPanel"
	self.layer = "UI"
	self.events = {}
	self.rightItems = {}
	self.model = PeakArenaModel:GetInstance()
	PeakArenaRewardPanel.super.Load(self)
end

function PeakArenaRewardPanel:dctor()
	self.model:RemoveTabListener(self.events)
	for k, v in pairs(self.rightItems) do
		v:destroy()
	end
	self.rightItems = {}
end

function PeakArenaRewardPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","PeakArenaRewardItem",
	}
	self:GetChildren(self.nodes)
	
	self:InitUI()
	self:AddEvent()
end

function PeakArenaRewardPanel:InitUI()
	--local tab =	Config.db_combat1v1_merit_reward
	local tab = self.model:GetMeritCfg()
	table.sort(tab,function(a,b)
			if self.model:IsMeritReward(a.merit) ~= self.model:IsMeritReward(b.merit) then
				return self.model:IsMeritReward(a.merit) < self.model:IsMeritReward(b.merit)
			else
				return a.merit < b.merit
			end
		
	end)
	self.rightItems = self.rightItems or {}
	for i = 1, #tab do
		local item = self.rightItems[i]
		if not item then
			item = PeakArenaRewardItem(self.PeakArenaRewardItem.gameObject,self.Content,"UI")
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

function PeakArenaRewardPanel:AddEvent()
	
	self.events[#self.events + 1] = self.model:AddListener(PeakArenaEvent.MeritReward,handler(self,self.MeritReward))
end

function PeakArenaRewardPanel:MeritReward(data)
	Notify.ShowText("Claimed")
	self:InitUI()
end

