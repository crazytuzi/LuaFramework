---
--- Created by  R2D2
--- DateTime: 2019/6/5 16:43
---
PetBossPanel = PetBossPanel or class("PetBossPanel", BaseItem)
local this = PetBossPanel

function PetBossPanel:ctor(parent_node, parent_panel, selectedBossId)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "PetBossPanel"
    self.layer = "Bottom"

    self.parentPanel = parent_panel
    self.selectedBossId = selectedBossId

    self.model = DungeonModel.GetInstance()
    self.events = {}
    self.items = {}
    self.toggles = {}
    self.label = {}

    self.selectedItemIndex = 1
    self.currFloor = 1
    PetBossPanel.super.Load(self)
end

function PetBossPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.CurrBossItem = nil

    for _, v in ipairs(self.items) do
        v:destroy()
    end
    self.items = {}

    for _, v in ipairs(self.toggles) do
        destroy(v)
    end
    self.toggles = {}
    self.label = {}
    self.parentPanel = nil

    if self.rewardBtn_red then
        self.rewardBtn_red:destroy()
        self.rewardBtn_red = nil
    end
end

function PetBossPanel:LoadCallBack()
    self.nodes = { "bg_layer/NumText", "bg_layer/HelpBtn", "bg_layer/Introduce",
                   "ScrollView", "ScrollView/Viewport/Content", "LayerParent",
                   "LayerPrefab", "BossPrefab", "GotoBtn",

    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if self.parentPanel and self.parentPanel.care then
        SetGameObjectActive(self.parentPanel.care.gameObject, false);
    end

    self:CreateFloorItem()
    --self:RefreshBossList()
    self.rewardBtn_red = RedDot(self.GotoBtn, nil, RedDot.RedDotType.Nor)
    self.rewardBtn_red:SetPosition(64, 18)
    DungeonCtrl:GetInstance():RequestBossList(enum.BOSS_TYPE.BOSS_TYPE_PET, self.currFloor)
end

function PetBossPanel:InitUI()

    self.bossParent = self.Content
    self.bossPrefab = self.BossPrefab.gameObject

    self.toggleGroup = GetToggleGroup(self.LayerParent)
    self.toggleParent = self.LayerParent
    self.togglePrefab = self.LayerPrefab.gameObject

    self.introduceText = GetText(self.Introduce)
    self.numText = GetText(self.NumText)

    self.scrollView = GetScrollRect(self.ScrollView)
    self.scrollViewHeight = self.ScrollView.sizeDelta.y

    SetVisible(self.togglePrefab, false)
    SetVisible(self.BossPrefab, false)
end

function PetBossPanel:AddEvent()
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(DungeonEvent.WORLD_BOSS_LIST, handler(self, self.OnBossData))

    local function call_back()
        ShowHelpTip(HelpConfig.Dungeon.PetBoss, true)
    end
    AddClickEvent(self.HelpBtn.gameObject, call_back)

    AddClickEvent(self.GotoBtn.gameObject, handler(self, self.OnRequestEntrance))
end

function PetBossPanel:OnBossData(bossData)
    if bossData.type == enum.BOSS_TYPE.BOSS_TYPE_PET then
        self:RefreshBossList()
        self:RefreshView()
    end
    self.rewardBtn_red:SetRedDotParam(self.model:GetRemainTimes() > 0)
end

---主求进入副本
function PetBossPanel:OnRequestEntrance()

    local remain, _, _ = self.model:GetRemainTimes()
    if (remain <= 0) then
        Notify.ShowText(ConfigLanguage.Dungeon.RemindTimesError)
        return
    end

    if (self.CurrBossItem == nil) or (self.CurrBossItem.data == nil) then
        Notify.ShowText(ConfigLanguage.Dungeon.PET_DUNGEON_UNSELECTED_TIP)
        return
    end


    local cfg = self.CurrBossItem.data

    --local function okFun()
    local scene = cfg.scene
    local coord = String2Table(cfg.coord)
    if scene and coord then
        self.model:SetSelectedPetId(cfg.id)
        DungeonCtrl:GetInstance():RequestEnterWorldBoss(scene, coord[1], coord[2])
    end
    --end


end

--function PetBossPanel:CheckCost(cfg)
--    local sceneConfig = Config.db_scene[cfg.scene]
--    if sceneConfig and sceneConfig.cost_type == 1 then
--        local cost = String2Table(sceneConfig.cost)
--    else
--        return true
--    end
--end

function PetBossPanel:RefreshParentView()
    self.parentPanel:InitDrops(self.CurrBossItem)
    self.parentPanel:InitModelView(self.CurrBossItem,true)
    self.parentPanel:RefreshProp(self.CurrBossItem)
end

function PetBossPanel:CreateFloorItem()
    local floorList = self.model:GetPetBossFloorList()

    for i, _ in ipairs(floorList) do
        local item = self.toggles[i]
        local isOn = (i == self.currFloor)

        if (item == nil) then
            item = newObject(self.togglePrefab)
            self:SetFloorToggle(item, i, isOn)
            table.insert(self.toggles, item)
        else
            local toggle = GetToggle(item)
            toggle.isOn = isOn
        end


    end
end

function PetBossPanel:SetFloorToggle(toggleItem, index, isOn)
    local transform = toggleItem.transform
    local toggle = GetToggle(toggleItem)
    local toggleText = GetText(GetChild(toggleItem, "Label"))

    toggle.isOn = isOn
    toggle.group = self.toggleGroup
    toggleText.text = string.format(ConfigLanguage.Dungeon.FloorString, DungeonModel.NumToChinese[index]);
    if index == 1 then
        SetColor(toggleText, 133, 132, 176)
    else
        SetColor(toggleText, 255, 255, 255)
    end

    transform.name = "floor_" .. index
    SetVisible(toggleItem, true)
    SetParent(transform, self.toggleParent)
    SetLocalPosition(transform, 0, 0, 0)
    SetLocalScale(transform, 1, 1, 1)

    self.label[index] = toggleText
    AddValueChange(toggleItem.gameObject, handler(self, self.OnToggleValueChange, index));
end

function PetBossPanel:OnToggleValueChange(toggle, isOn, index)
    if isOn and self.currFloor == index then
        return
    end
    for i = 1, #self.label do
        if i == index then
            SetColor(self.label[i], 133, 132, 176)
        else
            SetColor(self.label[i], 255, 255, 255)
        end
    end


    self.currFloor = index
    --self:RefreshBossList()
    DungeonCtrl:GetInstance():RequestBossList(enum.BOSS_TYPE.BOSS_TYPE_PET, self.currFloor)
end

function PetBossPanel:RefreshView()
    local data = self.model.PetBossInfo
    self.numText.text = tostring(data.num)

    local remain, nextVip, nextNum = self.model:GetRemainTimes()
    if (nextVip) then
        self.introduceText.text = string.format(ConfigLanguage.Dungeon.RemindTimesTip, remain > 0 and "00be00" or "ff0000", remain)
                .. ConfigLanguage.Dungeon.NextVipTimesTip --string.format(ConfigLanguage.Dungeon.NextVipTimesTip, nextVip, nextNum)
    else
        self.introduceText.text = string.format(ConfigLanguage.Dungeon.RemindTimesTip, remain > 0 and "00be00" or "ff0000", remain)
    end
end

function PetBossPanel:RefreshBossList()
    --local bossList = self.model:GetPetBossByFloor(self.currFloor, 1)
    local bossList = self.model:GetPetBossList(self.currFloor)
    local count = #bossList
    local itemSize = self.BossPrefab.sizeDelta
    local fullH = count * itemSize.y
    local baseY = (fullH - itemSize.y) * 0.5

    SetSizeDeltaY(self.bossParent, fullH)
    self:CreateBossItem(count, baseY, itemSize.y)

    local selectedId = self.model:GetSelectedPetId()
    local selectedItem = nil
    local selectedIndex = nil

    for i, v in ipairs(bossList) do

        if (selectedId and v.id == selectedId) then
            selectedItem = self.items[i]
            selectedIndex = i
        end

        self.items[i]:SetData(v, i)
        self.items[i]:SetCallBack(handler(self, self.OnSelectBossItem), handler(self, self.OnBossItemToggle), handler(self, self.OnCountDown))
        SetVisible(self.items[i], true)
    end

    for i = #bossList + 1, #self.items do
        SetVisible(self.items[i], false)
    end

    if (selectedItem) then
        self:OnSelectBossItem(selectedItem)
        self:SetScrollView(fullH, selectedIndex)
    elseif (count > 0) then
        self:OnSelectBossItem(self.items[1])
        self:SetScrollView(fullH, 1)
    end
end

function PetBossPanel:SetScrollView(fullH, index)
    local itemH = self.BossPrefab.sizeDelta.y
    local h = itemH * index
    local offset1 = h - self.scrollViewHeight
    local offset2 = fullH - self.scrollViewHeight
    local n = 1 - offset1 / offset2

    n = math.max(0, n)
    n = math.min(1, n)

    self.scrollView.verticalNormalizedPosition = n
end

function PetBossPanel:OnSelectBossItem(item)
    if (self.CurrBossItem) then
        self.CurrBossItem:SetSelected(false)
    end

    self.CurrBossItem = item
    self.selectedItemIndex = item.index
    self.CurrBossItem:SetSelected(true)

    self:RefreshParentView()
end

function PetBossPanel:OnBossItemToggle(item, isOn)
    if isOn then
        DungeonCtrl:GetInstance():RequestBossCare(enum.BOSS_TYPE.BOSS_TYPE_PET, item.data.id, 1);
    else
        DungeonCtrl:GetInstance():RequestBossCare(enum.BOSS_TYPE.BOSS_TYPE_PET, item.data.id, 2);
    end
end

---倒计时结束
function PetBossPanel:OnCountDown()
    DungeonCtrl:GetInstance():RequestBossList(enum.BOSS_TYPE.BOSS_TYPE_PET, self.currFloor)
end

function PetBossPanel:CreateBossItem(count, baseY, itemY)
    if (count <= #self.items) then
        return
    end

    for i = #self.items + 1, count do
        local tempItem = PetBossItemView(newObject(self.bossPrefab))
        tempItem.transform.name = "pet_boss_item" .. i
        SetParent(tempItem.transform, self.bossParent)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        SetAnchoredPosition(tempItem.transform, 0, baseY - (i - 1) * itemY)
        table.insert(self.items, tempItem)
    end
end

