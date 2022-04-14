---
--- Created by  Administrator
--- DateTime: 2020/5/18 16:13
---
FactionSerWarRewardPanel = FactionSerWarRewardPanel or class("FactionSerWarRewardPanel", WindowPanel)
local this = FactionSerWarRewardPanel

function FactionSerWarRewardPanel:ctor(parent_node, parent_panel)
    self.abName = "faction"
    self.assetName = "FactionSerWarRewardPanel"
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 5
    self.curTimes = 1
    self.views = {}
    self.btnSelects = {}
    self.btnSelectsTex = {}
    self.rankItems = {}
    self.model = FactionSerWarModel:GetInstance()
end

function FactionSerWarRewardPanel:dctor()
    self.model:RemoveTabListener(self.events)
    self.views = nil
    self.btnSelects = nil
    self.btnSelectsTex = nil
    if not table.isempty(self.rankItems) then
        for i, v in pairs(self.rankItems) do
            v:destroy()
        end
        self.rankItems = {}
    end
end

function FactionSerWarRewardPanel:LoadCallBack()
    self.nodes = {
        "rankObj/rankScrollView/Viewport/rankContent","btns/weekBtn","btns/rankBtn",
        "btns/rankBtn/rankSelect","rankObj","btns/rankBtn/rankBtnText",
        "btns/weekBtn/weekBtnText","btns/weekBtn/weekSelect","FactionSerWarRewardRankItem",
        "noObj","weekTitleObj","rankTitleObj",
    }
    self:GetChildren(self.nodes)


    self.rankBtnText = GetText(self.rankBtnText)
    self.weekBtnText = GetText(self.weekBtnText)
    self.views[1] = self.rankTitleObj
    self.views[2] = self.weekTitleObj
    self.btnSelects[1] = self.rankSelect
    self.btnSelects[2] = self.weekSelect
    self.btnSelectsTex[1] = self.rankBtnText
    self.btnSelectsTex[2] = self.weekBtnText

    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("faction_image", "FactionSerWar_title2");
    FactionSerWarController:GetInstance():RequstRankInfo()

end

function FactionSerWarRewardPanel:InitUI()

end

function FactionSerWarRewardPanel:AddEvent()
    local function call_back()
        self:Click(1)
    end
    AddClickEvent(self.rankBtn.gameObject,call_back)


    local function call_back()
        self:Click(2)
    end
    AddClickEvent(self.weekBtn.gameObject,call_back)


    self.events[#self.events + 1] = self.model:AddListener(FactionSerWarEvent.RankInfo,handler(self,self.RankInfo))
end

function FactionSerWarRewardPanel:Click(index)
    if self.index == index then
        return
    end
    self.index = index
    for i = 1, #self.btnSelects do
        if index == i then
            SetVisible(self.btnSelects[i],true)
            SetVisible(self.views[i],false)
            SetColor(self.btnSelectsTex[i], 133, 132, 176, 255)
        else
            SetVisible(self.btnSelects[i],false)
            SetVisible(self.views[i],true)
            SetColor(self.btnSelectsTex[i], 255, 255, 255, 255)
        end
    end
    self:UpdateRankItems()
end

function FactionSerWarRewardPanel:RankInfo(data)
    self.ranking = data.ranking
    SetVisible(self.noObj,table.isempty(data.ranking))
    self:Click(1)
end

function FactionSerWarRewardPanel:UpdateRankItems()
    --self.index
    if table.isempty(self.ranking) then
        return
    end
    table.sort(self.ranking, function(a,b)
        return a.rank < b.rank
    end)
    for i = 1,#self.ranking do
        local item = self.rankItems[i]
        if not item then
            item = FactionSerWarRewardRankItem(self.FactionSerWarRewardRankItem.gameObject,self.rankContent,"UI")
            self.rankItems[i] = item
        end
        item:SetData(self.ranking[i],self.index)
    end
end