---
--- Created by  Administrator
--- DateTime: 2019/12/5 17:04
---
CompeteDungeReadyRankItem = CompeteDungeReadyRankItem or class("CompeteDungeReadyRankItem", BaseCloneItem)
local this = CompeteDungeReadyRankItem

function CompeteDungeReadyRankItem:ctor(obj, parent_node, parent_panel)
    CompeteDungeReadyRankItem.super.Load(self)
    self.events = {}
end

function CompeteDungeReadyRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function CompeteDungeReadyRankItem:LoadCallBack()
    self.nodes = {
        "role_rank","score","rankicon","selected","role_name",
    }
    self:GetChildren(self.nodes)
    self.role_rank = GetText(self.role_rank)
    self.role_name = GetText(self.role_name)
    self.score = GetText(self.score)
    self.rankicon = GetImage(self.rankicon)
    self:InitUI()
    self:AddEvent()
    SetVisible(self.selected,false)
end

function CompeteDungeReadyRankItem:InitUI()

end

function CompeteDungeReadyRankItem:AddEvent()

end

function CompeteDungeReadyRankItem:SetData(data,index)
    SetVisible(self.rankicon,index <= 3)
    SetVisible(self.role_rank,index>3)
    lua_resMgr:SetImageTexture(self, self.rankicon, "compete_image", "arena_rank"..index, true, nil, false)
    self.role_rank.text = index
    if not data then
        self.role_name.text = "Nobody made the list yet"
        self.score.text = " "
        return
    end
    self.data = data
    self.role_name.text = self.data.name
    self.score.text = self.data.score
    SetVisible(self.selected,self.data.role == RoleInfoModel:GetInstance():GetMainRoleData().id)
end