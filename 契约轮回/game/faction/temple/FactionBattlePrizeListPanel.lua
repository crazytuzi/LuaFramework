---
--- Created by R2D2.
--- DateTime: 2019/2/20 21:21
---
---
---主宰神殿->连胜奖励
FactionBattlePrizeListPanel = FactionBattlePrizeListPanel or class("FactionBattlePrizeListPanel", WindowPanel)
local FactionBattlePrizeListPanel = FactionBattlePrizeListPanel

function FactionBattlePrizeListPanel:ctor()
    self.abName = "faction"
    self.assetName = "FactionBattlePrizeListPanel"
    self.layer = "UI"

    self.panel_type = 5
    self.dataModel = FactionBattleModel.GetInstance()
    self.show_sidebar = false
    self.events = {}
    self.modelEvents = {}
end

function FactionBattlePrizeListPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    self.dataModel:RemoveTabListener(self.modelEvents)

    for _, v in pairs(self.itemList) do
        v:destroy()
    end
    self.itemList = {}

    if self.PageScrollView ~= nil then
        self.PageScrollView:OnDestroy()
        self.PageScrollView = nil
    end
end

function FactionBattlePrizeListPanel:Open()
    FactionBattlePrizeListPanel.super.Open(self)
end

function FactionBattlePrizeListPanel:LoadCallBack()
    self:SetTileTextImage("faction_image", "faction_title_PrizeList")
    self.nodes = {
        "ScrollView", "Times", "ScrollView/Viewport/Content", "ItemPrefab",

    }

    self:GetChildren(self.nodes)
   -- self:InitUI()
    self:AddEvent()
    RoleInfoController:GetInstance():RequestWorldLevel();
end

function FactionBattlePrizeListPanel:InitUI(level)
    self.timesText = GetText(self.Times)
    self.contentRect = self.Content:GetComponent("RectTransform")
    self.itemSize = self.ItemPrefab.sizeDelta
    self.itemList = {}
    self.worldLv = level
  --  logError(self.worldLv,"11121212")
    local data = self.dataModel:GetWinningStreakReward()
    local scrollSize = self.ScrollView.sizeDelta
    local count = #data
    local fullH = count * self.itemSize.y
    --local baseX = (-scrollSize.x + self.itemSize.x) / 2
    local baseY = (fullH - self.itemSize.y) / 2

    self.contentRect.sizeDelta = Vector2(self.contentRect.sizeDelta.x, fullH)
    --(self.contentRect, self.contentRect.sizeDelta.x, fullH)
   -- self:CreateItems(data, baseY,level)
    self:CreateItem(data)
    self.ItemPrefab.gameObject:SetActive(false)

    if (self.dataModel.WinnerInfo) then
        self.timesText.text = self.dataModel.WinnerInfo.victory .. "times"
    else
        self.timesText.text = "0 times"
    end
end

function FactionBattlePrizeListPanel:AddEvent()
    local function callback(level)
        self:InitUI(level)
    end
    AddEventListenerInTab(RoleInfoEvent.QUERY_WORLD_LEVEL, callback, self.events);
   -- self.modelEvents[#self.modelEvents + 1] = self.dataModel:AddListener(FactionBattleEvent.FactionBattle_Model_AssignedWinAwardEvent, handler(self, self.OnAssignedWinAward))
end

function FactionBattlePrizeListPanel:OnAssignedWinAward()
    local isAssigned = self.dataModel.WinnerInfo.v_allot
    local visible = self:IsShowButton()
    local winTimes = 0

    if (self.dataModel.WinnerInfo) then
        winTimes = self.dataModel.WinnerInfo.victory
    end

    for _, v in pairs(self.itemList) do
        if (visible) then
            if (isAssigned) then
                v:SetButtonVisible(false, v.data.times == winTimes)
            else
                v:SetButtonVisible(v.data.times == winTimes, false)
            end
        else
            v:SetButtonVisible(false, false)
        end
    end
end

function FactionBattlePrizeListPanel:IsShowButton()
    if (self.dataModel.WinnerInfo) then

        --if (self.dataModel.WinnerInfo.v_allot) then
        --    return false
        --end

        if (self.dataModel.WinnerInfo.guild == 0) then
            return false
        else
            local gId = RoleInfoModel.GetInstance():GetMainRoleData().guild

            if (gId == self.dataModel.WinnerInfo.guild) then
                return true
            else
                return false
            end
        end
    end

    return false
end

function FactionBattlePrizeListPanel:CreateItems(dataList, baseY,level)

    local isAssigned = self.dataModel.WinnerInfo and self.dataModel.WinnerInfo.v_allot or false

    local visible = self:IsShowButton()
    local winTimes = 0

    if (self.dataModel.WinnerInfo) then
        winTimes = self.dataModel.WinnerInfo.victory
    end

    for i = 1, #dataList, 1 do
        local tempItem = FactionBattlePrizeItemView(newObject(self.ItemPrefab), dataList[i],level)
        tempItem.transform:SetParent(self.contentRect)
        if (visible) then
            if (isAssigned) then
                tempItem:SetButtonVisible(false, dataList[i].times == winTimes)
            else
                tempItem:SetButtonVisible(dataList[i].times == winTimes, false)
            end
        else
            tempItem:SetButtonVisible(false, false)
        end

        SetLocalScale(tempItem.transform, 1, 1, 1)
        tempItem.transform.anchoredPosition3D = Vector3(0, baseY - (i - 1) * self.itemSize.y, 0)
        self.itemList[i] = tempItem
    end
end

function FactionBattlePrizeListPanel:CreateItem(dataList,baseY,level)

    local isAssigned = self.dataModel.WinnerInfo and self.dataModel.WinnerInfo.v_allot or false

    local visible = self:IsShowButton()
    local winTimes = 0

    if (self.dataModel.WinnerInfo) then
        winTimes = self.dataModel.WinnerInfo.victory
    end

    --for i = 1, #dataList, 1 do
    --    local tempItem = FactionBattlePrizeItemView(newObject(self.ItemPrefab), dataList[i],level)
    --    tempItem.transform:SetParent(self.contentRect)
    --    if (visible) then
    --        if (isAssigned) then
    --            tempItem:SetButtonVisible(false, dataList[i].times == winTimes)
    --        else
    --            tempItem:SetButtonVisible(dataList[i].times == winTimes, false)
    --        end
    --    else
    --        tempItem:SetButtonVisible(false, false)
    --    end
    --
    --    SetLocalScale(tempItem.transform, 1, 1, 1)
    --    tempItem.transform.anchoredPosition3D = Vector3(0, baseY - (i - 1) * self.itemSize.y, 0)
    --    self.itemList[i] = tempItem
    --end

    local param = {}
    local cellSize = {width = 620,height = 94}
    param["scrollViewTra"] = self.ScrollView
    param["cellParent"] = self.contentRect
    param["cellSize"] = cellSize
    param["cellClass"] = FactionBattlePrizeItemView
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 5
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.UpdateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = #dataList
    self.PageScrollView = ScrollViewUtil.CreateItems(param)
end

--function FactionBattlePrizeListPanel:CreateCellCB(itemCLS)
--    self:UpdateCellCB(itemCLS)
--end

function FactionBattlePrizeListPanel:UpdateCellCB(itemCLS)
    local bagItems = self.dataModel:GetWinningStreakReward()
    local index = itemCLS.__item_index
    local isAssigned = self.dataModel.WinnerInfo and self.dataModel.WinnerInfo.v_allot or false
    local visible = self:IsShowButton()
    local winTimes = 0
    if (self.dataModel.WinnerInfo) then
        winTimes = self.dataModel.WinnerInfo.victory
    end
    itemCLS:SetData(bagItems[index],self.worldLv,visible,isAssigned,winTimes)

        --if (visible) then
        --    if (isAssigned) then
        --        itemCLS:SetButtonVisible(false, bagItems[index].times == winTimes)
        --    else
        --        itemCLS:SetButtonVisible(bagItems[index].times == winTimes, false)
        --    end
        --else
        --    itemCLS:SetButtonVisible(false, false)
        --end
end

