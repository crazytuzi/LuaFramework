---
--- Created by  Administrator
--- DateTime: 2019/4/19 14:24
---
GodCeleRankLevelItem = GodCeleRankLevelItem or class("GodCeleRankLevelItem", BaseCloneItem)
local this = GodCeleRankLevelItem

function GodCeleRankLevelItem:ctor(obj, parent_node, parent_panel)
    GodCeleRankLevelItem.super.Load(self)
    self.events = {}
end

function GodCeleRankLevelItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function GodCeleRankLevelItem:LoadCallBack()
    self.nodes = {
        "bg","starParent/stra6","starParent/stra1","starParent/stra5","starParent/stra4","starParent/stra2","starParent/stra3","icon","select",
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.stra1 = GetImage(self.stra1)
    self.stra2 = GetImage(self.stra2)
    self.stra3 = GetImage(self.stra3)
    self.stra4 = GetImage(self.stra4)
    self.stra5 = GetImage(self.stra5)
    self.stra6 = GetImage(self.stra6)

    self:InitUI()
    self:AddEvent()
end

function GodCeleRankLevelItem:InitUI()

end

function GodCeleRankLevelItem:AddEvent()
    local function call_back()
        GlobalEvent:Brocast(GodCeleEvent.SevenDayRankClickLevelItem, self.data,self.index)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function GodCeleRankLevelItem:SetData(data,index)
    self.data = data
    self.index = index
    local link  = String2Table(self.data.panel)
    local abName,assetName =  GetLinkAbAssetName(link[1][1],link[1][2])
    lua_resMgr:SetImageTexture(self, self.icon, abName, assetName, true, nil, false)
    local starNum = self.data.recommend
    local stars = {[1] = self.stra1,[2] = self.stra2,[3] = self.stra3,[4]=self.stra4,[5]=self.stra5,[6]=self.stra6}
    for i = 1, #stars do
        if i<= starNum then
            lua_resMgr:SetImageTexture(self, stars[i], "sevenDayActive_image", "sevenDayActive_star", true, nil, false)
        end
    end


end

function GodCeleRankLevelItem:SetSelect(show)
    SetVisible(self.select,show)
end