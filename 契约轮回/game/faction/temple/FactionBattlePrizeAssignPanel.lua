---
--- Created by R2D2.
--- DateTime: 2019/2/21 15:53
---
---主宰神殿->奖励分配
FactionBattlePrizeAssignPanel = FactionBattlePrizeAssignPanel or class("FactionBattlePrizeAssignPanel", WindowPanel)
local FactionBattlePrizeAssignPanel = FactionBattlePrizeAssignPanel

function FactionBattlePrizeAssignPanel:ctor()
    self.abName = "faction"
    self.assetName = "FactionBattlePrizeAssignPanel"
    self.layer = "UI"

    self.panel_type = 5
    self.model = FactionModel:GetInstance()
    self.dataModel = FactionBattleModel.GetInstance()
    self.show_sidebar = false
end

function FactionBattlePrizeAssignPanel:dctor()
    for _, v in pairs(self.itemList) do
        v:destroy()
    end
    self.itemList = {}
end

function FactionBattlePrizeAssignPanel:Open(awardType)
    self.AwardType = awardType
    FactionBattlePrizeAssignPanel.super.Open(self)
end


function FactionBattlePrizeAssignPanel:LoadCallBack()
    self:SetTileTextImage("faction_image", "faction_title_PrizeAssign")
    self.nodes = {
        "ScrollView","ItemPrefab","ScrollView/Viewport/Content","OkBtn",
    }

    self:GetChildren(self.nodes)
    self:InitUI()
    self:AddEvent()
end

function FactionBattlePrizeAssignPanel:InitUI()
    self.toggleGroup = GetToggleGroup(self.ScrollView)
    self.contentRect = self.Content:GetComponent("RectTransform")
    self.itemSize = self.ItemPrefab.sizeDelta
    self.itemList = {}

    local data = self.model.members
    local count = #data
    local fullH = count * self.itemSize.y
    local baseY = (fullH - self.itemSize.y) / 2

    self.contentRect.sizeDelta = Vector2(self.contentRect.sizeDelta.x, fullH)

    self:CreateItems(data, baseY)
    self.ItemPrefab.gameObject:SetActive(false)
end

function FactionBattlePrizeAssignPanel:AddEvent()
    local OnAssign = function()
        if (self.SelectRole) then
            FactionBattleController:GetInstance():RequestAllotAward(self.SelectRole.base.id, self.AwardType)
            self:Close()
        else
            Notify.ShowText(ConfigLanguage.FactionBattle.NotSelectWhenAssign)
        end
    end
    AddClickEvent(self.OkBtn.gameObject, OnAssign)
end

function FactionBattlePrizeAssignPanel:CreateItems(dataList, baseY)

    local function OnSelectRole(roleInfo)
        self.SelectRole = roleInfo
    end

    for i = 1, #dataList, 1 do
        local tempItem = FactionBattlePrizeAssignItemView(newObject(self.ItemPrefab), dataList[i])
        tempItem:SetCallBack(self.toggleGroup, OnSelectRole)
        tempItem.transform:SetParent(self.contentRect)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        tempItem.transform.anchoredPosition3D = Vector3(0, baseY - (i - 1) * self.itemSize.y, 0)
        self.itemList[i] = tempItem
    end
end

