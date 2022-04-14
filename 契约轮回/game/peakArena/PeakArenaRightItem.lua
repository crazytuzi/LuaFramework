---
--- Created by  Administrator
--- DateTime: 2019/8/1 14:26
---
PeakArenaRightItem = PeakArenaRightItem or class("PeakArenaRightItem", BaseCloneItem)
local this = PeakArenaRightItem

function PeakArenaRightItem:ctor(obj, parent_node, parent_panel)
    PeakArenaRightItem.super.Load(self)
    self.events = {}
end

function PeakArenaRightItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function PeakArenaRightItem:LoadCallBack()
    self.nodes = {
		"name","rewardTex","soccerTex","bg"
    }
    self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.rewardTex = GetText(self.rewardTex)
	self.soccerTex = GetText(self.soccerTex)
    self:InitUI()
    self:AddEvent()
end

function PeakArenaRightItem:InitUI()

end

function PeakArenaRightItem:AddEvent()

end

function PeakArenaRightItem:SetData(data,index)
	self.data = data
	self.index = index
	self.name.text = self.data.name
	self.soccerTex.text = self.data.score
	local rewardTab = String2Table(self.data.daily_reward)
	self.rewardTex.text = rewardTab[1][2]
	if self.index % 2 ~= 0 then
		SetVisible(self.bg,true)
	else
		SetVisible(self.bg,false)
	end
end