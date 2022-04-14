---
--- Created by  Administrator
--- DateTime: 2020/5/26 17:11
---
FactionSerWardEndPanel = FactionSerWardEndPanel or class("FactionSerWardEndPanel", BasePanel)
local this = FactionSerWardEndPanel

function FactionSerWardEndPanel:ctor()
    self.abName = "faction";
    self.assetName = "FactionSerWardEndPanel"
    self.layer = "Bottom"

    self.events = {};
    self.itemHeight1 = 60
    self.itemHeight2 = 50
    self.model = FactionSerWarModel.GetInstance()
end

function FactionSerWardEndPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function FactionSerWardEndPanel:LoadCallBack()
    self.nodes = {
        "Contents",
        "Contents/ScrollView", "Contents/ScrollView/Viewport", "Contents/ScrollView/Viewport/Content", "Contents/ItemPrefab",
        "Contents/Self/JobTitle", "Contents/Self/Vip", "Contents/Self/RoleName", "Contents/Self/Rank", "Contents/Self/score",
        "Contents/Self/Occupy","Contents/Self/Kill",
    }
    self:GetChildren(self.nodes)

    LayerManager:GetInstance():AddOrderIndexByCls(self, self.Contents, nil, true, nil, false, 10)

    SetLocalPosition(self.transform, 0, 0, 0)

    self:InitUI()
    self:AddEvent();
end

function FactionSerWardEndPanel:InitUI()
    local data = {}
    data.isClear = self.model.IsWin
    data.IsCancelAutoSchedule = true

    self.endItem = DungeonEndItem(self.transform, data);
    self.contentRect = self.Content:GetComponent("RectTransform")
    self.itemSize = self.ItemPrefab.sizeDelta

    self.selfRankText = GetText(self.Rank)
    self.selfVipText = GetText(self.Vip)
    self.selfJobTitleText = GetText(self.JobTitle)
    self.TitleOutline = self.JobTitle:GetComponent('Outline')
    self.selfNameText = GetText(self.RoleName)
    self.selfScore = GetText(self.score)
    self.selfKillText = GetText(self.Kill)
    self.selfOccupyText = GetText(self.Occupy)

    self:RefreshList()
    self:RefreshSelfInfo()
end

function FactionSerWardEndPanel:AddEvent()

end


function FactionSerWardEndPanel:RefreshSelfInfo()
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local tab = self.model:GetJobTitleInfoById(role.figure.jobtitle.model)
    local rank = self.model:GetRank(role.id)

    if(tab) then
        SetOutLineColor(self.TitleOutline, tab.r, tab.g, tab.b, tab.a)
        self.selfJobTitleText.text = tab.n
    else
        self.selfJobTitleText.text = ""
    end

    self.selfVipText.text = "V" .. RoleInfoModel:GetInstance():GetMainRoleVipLevel()
    self.selfNameText.text = role.name

    self.selfRankText.text = tostring(rank)
    self.selfContributionText.text = tostring(self.model.MyRank.contrib)
    self.selfKillText.text = tostring(self.model.MyRank.kill)
    self.selfOccupyText.text =  tostring(self.model.MyRank.occupy)
end


function FactionSerWardEndPanel:RefreshList()
    self.itemList = {}

    local data = self.model.RankList
    local count = #data
    local fullH = 0
    if (count <= 3) then
        fullH = count * self.itemHeight1
    else
        fullH = 3 * self.itemHeight1 + (count - 3) * self.itemHeight2
    end

    local baseY = (fullH - self.itemSize.y) / 2
    self.contentRect.sizeDelta = Vector2(self.contentRect.sizeDelta.x, fullH)
    self:CreateItems(data, baseY)

    self.ItemPrefab.gameObject:SetActive(false)
end

function FactionSerWardEndPanel:CreateItems(dataList, baseY)

    local posOffset = 0

    for i = 1, #dataList, 1 do
        local tempItem = FactionBattleSettlementItemView(newObject(self.ItemPrefab), dataList[i])
        tempItem.transform:SetParent(self.contentRect)

        SetLocalScale(tempItem.transform, 1, 1, 1)
        if (i > 1) then
            if (i < 4) then
                posOffset = posOffset + self.itemHeight1
            else
                posOffset = posOffset + self.itemHeight2
            end
        end

        tempItem.transform.anchoredPosition3D = Vector3(0, baseY - posOffset, 0)
        tempItem:SetHeight(i < 4 and self.itemHeight1 or self.itemHeight2)
        tempItem:SetBgVisible(i % 2 == 1)
        self.itemList[i] = tempItem
    end
end

