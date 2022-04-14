---
--- Created by  Administrator
--- DateTime: 2019/8/1 10:22
---
PeakArenaTargetPanel = PeakArenaTargetPanel or class("PeakArenaTargetPanel", BaseItem)
local this = PeakArenaTargetPanel

function PeakArenaTargetPanel:ctor(parent_node, parent_panel)
	
	self.abName = "peakArena";
	self.image_ab = "peakArena_image";
	self.assetName = "PeakArenaTargetPanel"
	self.layer = "UI"
	self.events = {}
	self.rightItems = {}
	self.model = PeakArenaModel:GetInstance()
	PeakArenaTargetPanel.super.Load(self)
end

function PeakArenaTargetPanel:dctor()
	GlobalEvent:RemoveTabListener(self.events)
	for k, v in pairs(self.rightItems) do
		v:destroy()
	end
	self.rightItems = {}
end

function PeakArenaTargetPanel:LoadCallBack()
	self.nodes = {
		"topObj/mySoccerBG/mySoccerTex","topObj/myRankBG/myRankTex",
		"topObj/rankBG/curRank","PeakArenaTargetItem","ScrollView/Viewport/Content",
	}
	self:GetChildren(self.nodes)
	self.mySoccerTex = GetText(self.mySoccerTex)
	self.myRankTex = GetText(self.myRankTex)
	self:InitUI()
	self:AddEvent()
	RankController:GetInstance():RequestRankListInfo(1012,1)
end

function PeakArenaTargetPanel:InitUI()
	local cfg = self.model:GetGoalCfg()
	for i = 1, #cfg do
		local item = self.rightItems[i]
		if not item then
			item = PeakArenaTargetItem(self.PeakArenaTargetItem.gameObject,self.Content,"UI")
			self.rightItems[i] = item
		end
		item:SetData(cfg[i])
	end
	self.mySoccerTex.text = self.model.score
end

function PeakArenaTargetPanel:AddEvent()
	self.events[#self.events + 1] = GlobalEvent:AddListener(RankEvent.RankReturnList, handler(self, self.RankReturnList))
	--self.events[#self.events + 1] = self.model:AddListener(PeakArenaEvent.ShowPanelLeftClick,handler(self,self.ShowPanelLeftClick))
end

function PeakArenaTargetPanel:RankReturnList(data)
	--dump(data)
	local rank = data.mine.rank 
	if rank == 0 then
		self.myRankTex.text = "Didn't make list"
	else
		self.myRankTex.text = rank
	end
	
end

