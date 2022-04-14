---
--- Created by  Administrator
--- DateTime: 2019/5/8 19:25
---
ArenaRankItem = ArenaRankItem or class("ArenaRankItem", BaseCloneItem)
local this = ArenaRankItem

function ArenaRankItem:ctor(obj, parent_node, parent_panel)
    ArenaRankItem.super.Load(self)
    self.events = {}
    self.model = ArenaModel:GetInstance()
end

function ArenaRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ArenaRankItem:LoadCallBack()
    self.nodes = {
        "bg","textObj/power","textObj/name","rankText/rank","textObj/level","rankImg","rankText","select"
    }
    self:GetChildren(self.nodes)
    self.bgImg = GetImage(self.bg)
    self.rankImg = GetImage(self.rankImg)
    self.rank = GetText(self.rank)
    self.name = GetText(self.name)
    self.level = GetText(self.level)
    self.power = GetText(self.power)
    self:InitUI()
    self:AddEvent()
end

function ArenaRankItem:InitUI()

end

function ArenaRankItem:AddEvent()

    local function call_back()
        self.model:Brocast(ArenaEvent.ArenaRankItemClick,self.index)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function ArenaRankItem:SetData(data,index)
    self.data = data
    self.index = index
    self:SetInfo()
end

function ArenaRankItem:SetInfo()
    if self.data.rank <= 3 then
        SetVisible(self.rankImg.transform,true)
        SetVisible(self.rankText,false)
        SetVisible(self.bg,true)
        self.bgImg.color = Color(1,1,1,1)
        lua_resMgr:SetImageTexture(self, self.bgImg, "arena_image", "arena_rankbg"..self.data.rank, true, nil, false)
        lua_resMgr:SetImageTexture(self, self.rankImg, "arena_image", "arena_rank"..self.data.rank, true, nil, false)
    else
        SetVisible(self.rankImg.transform,false)
        SetVisible(self.rankText,true)
       -- SetVisible(self.bg,false)
        self.bgImg.color = Color(1,1,1,1/255)
        self.rank.text = self.data.rank

    end
    self.name.text = self.data.base.name
    self.level.text = self.data.base.level

    self.power.text = self.data.base.power

end

function ArenaRankItem:SetSelect(show)
    SetVisible(self.select,show)
end