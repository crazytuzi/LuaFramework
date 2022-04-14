---
--- Created by  Administrator
--- DateTime: 2020/4/3 10:35
---
ThroneStarShowItem = ThroneStarShowItem or class("ThroneStarShowItem", BaseCloneItem)
local this = ThroneStarShowItem

function ThroneStarShowItem:ctor(obj, parent_node, parent_panel)
    ThroneStarShowItem.super.Load(self)
    self.events = {}
end

function ThroneStarShowItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ThroneStarShowItem:LoadCallBack()
    self.nodes = {
        "bossName","bg","selected",
    }
    self:GetChildren(self.nodes)
    self.bossName = GetText(self.bossName)
    self.bg = GetImage(self.bg)
    self:InitUI()
    self:AddEvent()
end

function ThroneStarShowItem:InitUI()

end

function ThroneStarShowItem:AddEvent()
    local function call_back()
        ThroneStarModel:GetInstance():Brocast(ThroneStarEvent.ThroneStarShowItemClick,self.data)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function ThroneStarShowItem:SetData(data)
    self.data = data
    local creep = Config.db_creep[self.data.id]
    self.bossName.text = string.format("%s", self.data.name)
    lua_resMgr:SetImageTexture(self,self.bg, 'iconasset/icon_boss_image', self.data.boss_res,true)
end

function ThroneStarShowItem:SetSelect(isShow)
    SetVisible(self.selected,isShow)
end