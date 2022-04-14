---
--- Created by  Administrator
--- DateTime: 2019/11/26 19:37
---
CompeteRankItem = CompeteRankItem or class("CompeteRankItem", BaseCloneItem)
local this = CompeteRankItem

function CompeteRankItem:ctor(obj, parent_node, parent_panel)
    CompeteRankItem.super.Load(self)
    self.events = {}
    self.model = CompeteModel:GetInstance()
end

function CompeteRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function CompeteRankItem:LoadCallBack()
    self.nodes = {
        "select","rank","roleName","titleBg","lv","guild","rankImg","group","bg"
    }
    self:GetChildren(self.nodes)
    self.rank = GetText(self.rank)
    self.rankImg = GetImage(self.rankImg)
    self.roleName = GetText(self.roleName)
    self.guild = GetText(self.guild)
    self.group = GetText(self.group)
    self.lv = GetText(self.lv)
    self.bgImg = GetImage(self.bg)
    self:InitUI()
    self:AddEvent()
end

function CompeteRankItem:InitUI()

end

function CompeteRankItem:AddEvent()

    local function call_back()
        self.model:Brocast(CompeteEvent.CompeteRankItemClick,self.data.rank)
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.roleName)
        panel:Open(self.data.base)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function CompeteRankItem:SetData(data)
    self.data = data
  --  self.rank.text = self.data.rank
    self.roleName.text = self.data.base.name
    local gName = ""
    if self.data.base.gname == ""  then
        gName = "No guild yet"
    else
        gName = self.data.base.gname
    end
    self.guild.text = gName
    local group = "Heaven List"
    if tonumber(self.data.rank) > 16 then
        group = "Earth list"
    end
    self.group.text = group
    self.lv.text = self.data.base.level

    if self.data.rank <= 3 then
        SetVisible(self.rankImg.transform,true)
        SetVisible(self.rank,false)
        SetVisible(self.bg,true)
        SetVisible(self.titleBg,false)

        lua_resMgr:SetImageTexture(self, self.bgImg, "compete_image", "arena_rankbg"..self.data.rank, true, nil, false)
        lua_resMgr:SetImageTexture(self, self.rankImg, "compete_image", "arena_rank"..self.data.rank, true, nil, false)
    else
        SetVisible(self.rankImg.transform,false)
        SetVisible(self.titleBg,true)
        SetVisible(self.rank,true)
        if  self.data.rank % 2 == 0 then
            lua_resMgr:SetImageTexture(self, self.bgImg, "compete_image", "arena_rankbg4", true, nil, false)
            self.bgImg.color = Color(1,1,1,1)
        else
            self.bgImg.color = Color(1,1,1,1/255)
        end
        -- SetVisible(self.bg,self.data.rank % 2 == 0)
        --self.bgImg.color = Color(1,1,1,1/255)
        self.rank.text = self.data.rank
    end
end

function CompeteRankItem:SetSelect(isShow)
    SetVisible(self.select,isShow)
end