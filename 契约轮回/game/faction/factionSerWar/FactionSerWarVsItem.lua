---
--- Created by  Administrator
--- DateTime: 2020/5/25 15:03
---
FactionSerWarVsItem = FactionSerWarVsItem or class("FactionSerWarVsItem", BaseCloneItem)
local this = FactionSerWarVsItem

function FactionSerWarVsItem:ctor(obj, parent_node, parent_panel)
    FactionSerWarVsItem.super.Load(self)
    self.events = {}
end

function FactionSerWarVsItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function FactionSerWarVsItem:LoadCallBack()
    self.nodes = {
        "leftBg/leftSign","leftBg","rightBg/rightSign","rightBg","rightBg/rightName",
        "leftBg/leftName","leftBg/leftWarTypeImg","rightBg/rightWarTypeImg",
    }
    self:GetChildren(self.nodes)
    self.leftName = GetText(self.leftName)
    self.rightName = GetText(self.rightName)
    self.rightBg = GetImage(self.rightBg)
    self.leftBg = GetImage(self.leftBg)
    self:InitUI()
    self:AddEvent()
end

function FactionSerWarVsItem:InitUI()

end

function FactionSerWarVsItem:AddEvent()

end

function FactionSerWarVsItem:SetData(data)
    self.data = data
    self.leftName.text = self.data.atk_name
    self.rightName.text = self.data.def_name
    if self.data.winner == 0 or self.data.winner == "0" then
        lua_resMgr:SetImageTexture(self,self.leftBg,"faction_image","faction_b_Bg_Rank2A", true)
        lua_resMgr:SetImageTexture(self,self.rightBg,"faction_image","faction_b_Bg_Rank2B", true)
        SetVisible(self.leftSign,false)
        SetVisible(self.rightSign,false)
    else
        lua_resMgr:SetImageTexture(self,self.leftBg,"faction_image","faction_b_Bg_Rank4A", true)
        lua_resMgr:SetImageTexture(self,self.rightBg,"faction_image","faction_b_Bg_Rank4B", true)
        if self.data.winner == self.data.atk_id  then
            SetVisible(self.leftSign,true)
            SetVisible(self.rightSign,false)
        else
            SetVisible(self.leftSign,false)
            SetVisible(self.rightSign,true)
        end
    end
end