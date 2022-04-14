---
--- Created by R2D2.
--- DateTime: 2019/3/2 16:53
---
FactionBattleSettlementItemView = FactionBattleSettlementItemView or class("FactionBattleSettlementItemView", Node)
local this = FactionBattleSettlementItemView

function FactionBattleSettlementItemView:ctor(obj, tab)
    self.transform = obj.transform
    self.data = tab

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI()
    self:AddEvent()
    self:RefreshView()
end

function FactionBattleSettlementItemView:dctor()

end

function FactionBattleSettlementItemView:SetHeight(h)
    if(self.is_loaded) then
        SetSizeDeltaY(self.transform, h)
    else
        self.Height = h
    end
end

function FactionBattleSettlementItemView:SetBgVisible(visible)

    if(self.bgImage) then
        self.bgImage.enabled = visible
    else
        self.BgVisible = toBool(visible)
    end
end

function FactionBattleSettlementItemView:InitUI()
    self.is_loaded = true
    self.nodes = {"RankImg","Rank","JobTitle","RoleName","Kill","Occupy","Contribution",}
    self:GetChildren(self.nodes)

    self.bgImage = GetImage(self)
    self.rankImg = GetImage(self.RankImg)

    self.rankText = GetText(self.Rank)
    self.jobTitle = GetText(self.JobTitle)
    self.jobTitle.text = ""
    self.titleOutline = self.JobTitle:GetComponent('Outline')
    self.nameText = GetText(self.RoleName)
    self.killText = GetText(self.Kill)
    self.occupyText = GetText(self.Occupy)
    self.contributionText =GetText(self.Contribution)
end

function FactionBattleSettlementItemView:AddEvent()

end

function FactionBattleSettlementItemView:RefreshView()
    if (self.data) then

        if(self.Height) then
            self:SetHeight(self.Height)
        end

        if(self.BgVisible) then
            self:SetBgVisible(self.BgVisible)
        end

        if (self.data.rank <= 3) then
            self.rankImg.enabled = true
            self.rankText.text = ""
            local icon = "Rank_" .. self.data.rank
            lua_resMgr:SetImageTexture(self, self.rankImg, "factionbattle_image", icon);

        else
            self.rankImg.enabled = false
            self.rankText.text = tostring(self.data.rank)
        end

        self.nameText.text = self.data.role_name
        self.killText.text = tostring( self.data.kill)
        self.occupyText.text = tostring( self.data.occupy)
        self.contributionText.text = tostring( self.data.contrib)
    end
end


