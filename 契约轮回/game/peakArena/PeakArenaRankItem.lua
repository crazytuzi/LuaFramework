---
--- Created by  Administrator
--- DateTime: 2019/8/5 17:03
---
PeakArenaRankItem = PeakArenaRankItem or class("PeakArenaRankItem", BaseCloneItem)
local this = PeakArenaRankItem

function PeakArenaRankItem:ctor(obj, parent_node, parent_panel)
    PeakArenaRankItem.super.Load(self)
    self.events = {}
	self.model = PeakArenaModel:GetInstance()
end

function PeakArenaRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function PeakArenaRankItem:LoadCallBack()
    self.nodes = {
		"rankObj/name","rankObj/soccer","rankObj/order","rankObj/ser","rankObj/bg",
		"rankObj/rankImg","rankObj","noRank","rankObj/rankBg","rankBg/rankTex",
		"rankObj/select"
    }
    self:GetChildren(self.nodes)
	self.bgImg = GetImage(self.bg)
	self.name = GetText(self.name)
	self.soccer = GetText(self.soccer)
	self.order = GetText(self.order)
	self.ser = GetText(self.ser)
	self.rankImg = GetImage(self.rankImg)
	self.rankTex = GetText(self.rankTex)
    self:InitUI()
    self:AddEvent()
end

function PeakArenaRankItem:InitUI()
	
end

function PeakArenaRankItem:AddEvent()

	local function callBack()
		if not self.data  then
			return
		end
		
		self.model:Brocast(PeakArenaEvent.RankItemClick,self.data.rank)
	end
	AddClickEvent(self.bg.gameObject,callBack)
end

function PeakArenaRankItem:SetData(data,index,curPage)
	--dump(data)
	self.data = data
	self.index = index
	self.rankTex.text = (curPage - 1) * 5 + self.index
	if not self.data then
		SetVisible(self.noRank,true) 
		SetVisible(self.rankObj,false) 
		return 
	end
	SetVisible(self.noRank,false) 
	SetVisible(self.rankObj,true) 
	local role = self.data.base
	local grade = self.data.data.grade
	local cfg = self.model:GetGradeCfg()[grade]
	self.order.text = cfg.name
	self.name.text = role.name
	self.soccer.text = self.data.sort
	self.ser.text = "S."..role.zoneid
	
	if self.data.rank <= 3 then
		SetVisible(self.rankImg.transform,true)
		SetVisible(self.rankBg,false)
		SetVisible(self.bg,true)
		self.bgImg.color = Color(1,1,1,1)
		lua_resMgr:SetImageTexture(self, self.bgImg, "peakArena_image", "arena_rankbg"..self.data.rank, true, nil, false)
		lua_resMgr:SetImageTexture(self, self.rankImg, "peakArena_image", "arena_rank"..self.data.rank, true, nil, false)
	else
		SetVisible(self.rankImg.transform,false)
		SetVisible(self.rankBg,true)
		-- SetVisible(self.bg,false)
		self.bgImg.color = Color(1,1,1,1/255)
		--self.rankTex.text = self.data.rank	
	end
	
end

function PeakArenaRankItem:SetSelect(isShow)
	SetVisible(self.select,isShow)
end