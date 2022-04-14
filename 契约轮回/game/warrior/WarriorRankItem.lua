---
--- Created by  Administrator
--- DateTime: 2019/8/15 14:34
---
WarriorRankItem = WarriorRankItem or class("WarriorRankItem", BaseCloneItem)
local this = WarriorRankItem

function WarriorRankItem:ctor(obj, parent_node, parent_panel)
    WarriorRankItem.super.Load(self)
    self.events = {}
	self.itemicon = {}
	self.model = WarriorModel:GetInstance()
end

function WarriorRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
	for i, v in pairs(self.itemicon) do
		v:destroy()
	end
	self.itemicon = {}
end

function WarriorRankItem:LoadCallBack()
    self.nodes = {
		"name","iconParent"
    }
    self:GetChildren(self.nodes)
	self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function WarriorRankItem:InitUI()

end

function WarriorRankItem:AddEvent()
	--local function callBack()
	--	if not self.data  then
	--		return
	--	end
	--
	--	self.model:Brocast(WarriorEvent.RankItemClick,self.data.rank)
	--end
	--AddClickEvent(self.bg.gameObject,callBack)
end

function WarriorRankItem:SetData(data,index,curPage)
	self.data = data
	local des
	if self.data.rank_min == self.data.rank_max then
		des = "Ranking:"..self.data.rank_min
	else
		des = string.format("Rank: %s-%s",self.data.rank_min,self.data.rank_max)
	end
	self.name.text = des
	self:CreatIcons()
end

function WarriorRankItem:CreatIcons()
	local rewardTab = String2Table(self.data.gain)
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