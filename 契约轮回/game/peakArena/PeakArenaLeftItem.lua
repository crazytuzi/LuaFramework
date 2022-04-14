---
--- Created by  Administrator
--- DateTime: 2019/8/1 14:26
---
PeakArenaLeftItem = PeakArenaLeftItem or class("PeakArenaLeftItem", BaseCloneItem)
local this = PeakArenaLeftItem

function PeakArenaLeftItem:ctor(obj, parent_node, parent_panel)
    PeakArenaLeftItem.super.Load(self)
    self.events = {}
	self.model = PeakArenaModel:GetInstance()
end

function PeakArenaLeftItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function PeakArenaLeftItem:LoadCallBack()
    self.nodes = {
		"name","select","bg","icon"
    }
    self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.icon = GetImage(self.icon)
    self:InitUI()
    self:AddEvent()
end

function PeakArenaLeftItem:InitUI()
	
end

function PeakArenaLeftItem:AddEvent()
	local function callBack()
		--self.
		self.model:Brocast(PeakArenaEvent.ShowPanelLeftClick,self.data.grade)
	end
	AddClickEvent(self.bg.gameObject,callBack)
end

function PeakArenaLeftItem:SetData(data)
	self.data = data
	self.name.text = self.data.name
	local grade = self.data.grade
	lua_resMgr:SetImageTexture(self, self.icon, "peakArena_image", "PArena_rank"..grade, false, nil, false)
end

function PeakArenaLeftItem:SetShow(isShow)
	SetVisible(self.select,isShow)
end