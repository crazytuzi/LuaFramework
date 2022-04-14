---
--- Created by  Administrator
--- DateTime: 2019/11/11 15:40
---
BabyRankItem = BabyRankItem or class("BabyRankItem", BaseCloneItem)
local this = BabyRankItem

function BabyRankItem:ctor(obj, parent_node, parent_panel)
    BabyRankItem.super.Load(self)
    self.events = {}
    self.model = BabyModel:GetInstance()
end

function BabyRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function BabyRankItem:LoadCallBack()
    self.nodes = {
        "rankImg","zanNums","bg","titleBg","babyName","rank","select","playerName",
    }
    self:GetChildren(self.nodes)
    self.rankImg = GetImage(self.rankImg)
    self.zanNums = GetText(self.zanNums)
    self.bgImg = GetImage(self.bg)
    self.babyName = GetText(self.babyName)
    self.playerName = GetText(self.playerName)
    self.rank = GetText(self.rank)
    self:InitUI()
    self:AddEvent()
end

function BabyRankItem:InitUI()

end

function BabyRankItem:AddEvent()

    local function call_back()
        self.model:Brocast(BabyEvent.BabyRankClick,self.data.rank)
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.playerName)
        panel:Open(self.data.base)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function BabyRankItem:SetData(data)
    self.data = data
    self:SetInfo()
end

function BabyRankItem:SetInfo()
    if self.data.rank <= 3 then
        SetVisible(self.rankImg.transform,true)
        SetVisible(self.rank,false)
        SetVisible(self.bg,true)
        SetVisible(self.titleBg,false)

        lua_resMgr:SetImageTexture(self, self.bgImg, "baby_image", "arena_rankbg"..self.data.rank, true, nil, false)
        lua_resMgr:SetImageTexture(self, self.rankImg, "baby_image", "arena_rank"..self.data.rank, true, nil, false)
    else
        SetVisible(self.rankImg.transform,false)
        SetVisible(self.titleBg,true)
        SetVisible(self.rank,true)
        if  self.data.rank % 2 == 0 then
            lua_resMgr:SetImageTexture(self, self.bgImg, "baby_image", "arena_rankbg4", true, nil, false)
            self.bgImg.color = Color(1,1,1,1)
        else
            self.bgImg.color = Color(1,1,1,1/255)
        end
       -- SetVisible(self.bg,self.data.rank % 2 == 0)
        --self.bgImg.color = Color(1,1,1,1/255)
        self.rank.text = self.data.rank
    end

    if not table.isempty(self.data.data) then
        local babyID = self.data.data.baby_id
        local cfg = Config.db_baby_order[babyID.."@"..0]
        self.babyName.text = cfg.name
    end
    self.playerName.text = self.data.base.name
    self.zanNums.text = self.data.sort
end

function BabyRankItem:SetSelect(isShow)
    SetVisible(self.select,isShow)
end