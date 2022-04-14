---
--- Created by  Administrator
--- DateTime: 2019/8/5 15:02
---
PeakArenaTargetItem = PeakArenaTargetItem or class("PeakArenaTargetItem", BaseCloneItem)
local this = PeakArenaTargetItem

function PeakArenaTargetItem:ctor(obj, parent_node, parent_panel)
    PeakArenaTargetItem.super.Load(self)
    self.events = {}
	self.itemicon = {}
	self.model = PeakArenaModel:GetInstance()
end

function PeakArenaTargetItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
	for i, v in pairs(self.itemicon) do
		v:destroy()
	end
	self.itemicon = {}
end

function PeakArenaTargetItem:LoadCallBack()
    self.nodes = {
		"name","iconParent"
    }
    self:GetChildren(self.nodes)
	self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function PeakArenaTargetItem:InitUI()

end

function PeakArenaTargetItem:AddEvent()

end

function PeakArenaTargetItem:SetData(data)
	self.data = data
	self:CreatIcons()
	self:SetInfo()
end

function PeakArenaTargetItem:SetInfo()
	local des
	if self.data.grade == 0 then  --排名奖励
		if self.data.min == self.data.max then
			des = "Ranking:"..self.data.min
		else
			des = string.format("Rank: %s-%s",self.data.min,self.data.max)
		end
	else  --段位
		des = string.format("Grase: %s point",self.model:GetGradeCfg()[self.data.grade].name)
	end
	self.name.text = des
end

function PeakArenaTargetItem:CreatIcons()
	local rewardTab = String2Table(self.data.reward)
	for i = 1, #rewardTab do
		--self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
		if self.itemicon[i] == nil then
			self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
		end
		local param = {}
		param["model"] = BagModel
		param["item_id"] = rewardTab[i][1]
		param["num"] = rewardTab[i][2]
		--param["bind"] = rewardTab[i][3]
		param["can_click"] = true
		param["size"] = {x = 78,y = 78}
		self.itemicon[i]:SetIcon(param)
	end
end