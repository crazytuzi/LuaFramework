---
--- Created by R2D2.
--- DateTime: 2019/6/11 11:12
---

PetBossDungeonLeftCenter = PetBossDungeonLeftCenter or class("PetBossDungeonLeftCenter", BaseItem)
local this = PetBossDungeonLeftCenter

function PetBossDungeonLeftCenter:ctor(parent_node, bossid)
    self.abName = "dungeon"
    self.image_ab = "dungeon_image"
    self.assetName = "PetBossDungeonLeftCenter"
    self.layer = "Bottom"

    self.model = DungeonModel.GetInstance()
    self.bossid = bossid
    self.currentGroup = self:GetSelectedGroup()

    self.events = {}
    self.schedules = {}

    self.items = {}
    self.show = true
    PetBossDungeonLeftCenter.super.Load(self)
end

function PetBossDungeonLeftCenter:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
    end

    destroyTab(self.items)
    self.items = {}

    if self.kick_countdown then
        self.kick_countdown:destroy()
    end
    self.kick_countdown = nil

    if(self.toggleTexts) then
        for _, v in ipairs(self.toggleTexts) do
            v = nil
        end
        self.toggleTexts = nil
    end

    local panel = lua_panelMgr:GetPanel(DungeonExpelPanel)
    if panel then
        panel:Close()
    end
end

function PetBossDungeonLeftCenter:LoadCallBack()
    self.nodes = {
        "contents/ScrollView", "contents/ScrollView/Viewport/Content", "contents/ItemPrefab",
        "contents/angry", "contents/angry/angryblood", "contents/angry/angry_text",
        "contents/angry/countdown_bg", "contents/angry/countdown_bg/countdown_label", "contents/angry/countdown_bg/countdown_text",
        "contents/Toggles", "contents/Toggles/Toggle1", "contents/Toggles/Toggle2",
        "contents/Toggles/Toggle1/Label1", "contents/Toggles/Toggle2/Label2",
    }
    self:GetChildren(self.nodes)

    local sceneId = SceneManager:GetInstance():GetSceneId()
    self.floor = self.model:GetFloorBySceneId(sceneId)

    self:AddEvents()
    self:InitUI()
    self:CheckMove()
    --self:HandleSavageData()
    self:RefreshBossList()
    DungeonCtrl:GetInstance():RequestBossAnger()

    if not self.show then
        SetVisible(self.gameObject, false)
    end
end

function PetBossDungeonLeftCenter:GetSelectedGroup()
    local selectedId = self.model:GetSelectedPetId()
    if selectedId then
        local cfg = Config.db_boss[selectedId]
        if (cfg) then
            return cfg.group
        end
    end
    return 1
end

function PetBossDungeonLeftCenter:InitUI()

    self.itemParent = self.Content
    self.itemPrefab = self.ItemPrefab.gameObject
    self.itemSize = self.ItemPrefab.sizeDelta

    self.angry_text = GetText(self.angry_text)
    self.angryblood = BossBloodItem(self.angryblood, 3)
    self.angryblood:UpdateCurrentBloodImmi(100, 100)
    self.angry.gameObject:SetActive(false)

    self.lowToggle = GetToggle(self.Toggle1)
    self.highToggle = GetToggle(self.Toggle2)
    self.toggleTexts = {}
    table.insert(self.toggleTexts, GetText(self.Label1))
    table.insert(self.toggleTexts, GetText(self.Label2))

    self.countdown_text = GetText(self.countdown_text)

    local tg = GetToggleGroup(self.Toggles)
    self.lowToggle.isOn = self.currentGroup == 1
    self.highToggle.isOn = self.currentGroup == 2
    self.lowToggle.group = tg
    self.highToggle.group = tg

    self:RefreshToggleText(self.currentGroup)
    SetGameObjectActive(self.countdown_bg, false)
    SetVisible(self.ItemPrefab, false)
end

function PetBossDungeonLeftCenter:AddEvents()

    AddValueChange(self.Toggle1.gameObject, handler(self, self.OnToggleChange, 1))
    AddValueChange(self.Toggle2.gameObject, handler(self, self.OnToggleChange, 2))

    GlobalEvent.AddEventListenerInTab(DungeonEvent.WORLD_BOSS_LIST, handler(self, self.HandleBossList), self.events)
    GlobalEvent.AddEventListenerInTab(DungeonEvent.WORLD_BOSS_INFO, handler(self, self.HandleBossInfo), self.events)
    GlobalEvent.AddEventListenerInTab(DungeonEvent.DUNGEON_SAVAGE_ANGRY_DATA, handler(self, self.HandleSavageData), self.events)

    GlobalEvent.AddEventListenerInTab(DungeonEvent.BOSS_CHANGE_Event, handler(self, self.HandleBossChange), self.events)
    GlobalEvent.AddEventListenerInTab(DungeonEvent.BOSS_WEAK_STOP_Event, handler(self, self.HandleBossWeakStop), self.events)

    GlobalEvent.AddEventListenerInTab(MainEvent.MAIN_MIDDLE_LEFT_LOADED, handler(self, self.HandleMainMiddleLeftLoaded), self.events)

    GlobalEvent.AddEventListenerInTab(EventName.GameReset, function()
        self:destroy()
    end, self.events)

    local function call_back()
        local sceneid = SceneManager:GetInstance():GetSceneId()
        local sceneCfg = Config.db_scene[sceneid]

        if sceneCfg and sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_BOSS and sceneCfg.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_PET then
            --self:InitTogs(1)
            self:CheckMove()
        else
            self:destroy()
        end
    end
    GlobalEvent.AddEventListenerInTab(EventName.ChangeSceneEnd, call_back, self.events)
end

function PetBossDungeonLeftCenter:CheckMove()

    local call_back = function()
        if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end
    end

    if self.items then
        if DungeonModel:GetInstance().SelectedDungeonID then
            local data = Config.db_boss[DungeonModel:GetInstance().SelectedDungeonID]
            if data then
                local tab = data
                local coord = String2Table(tab.coord)
                local main_role = SceneManager:GetInstance():GetMainRole()
                local main_pos = main_role:GetPosition()
                TaskModel:GetInstance():StopTask()--先停掉任务,因为任务优先级高
                OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = coord[1], y = coord[2] }, call_back)
                DungeonModel:GetInstance().SelectedDungeonID = nil
                return
            end
        end
    end
end

function PetBossDungeonLeftCenter:OnToggleChange(obj, isOn, index)
    if (isOn) then
        self:RefreshBossList(index)
        self:RefreshToggleText(index)
    end
end

function PetBossDungeonLeftCenter:RefreshToggleText(index)
    for i, v in ipairs(self.toggleTexts) do
        if (index == i) then
            SetColor(v, 255, 255, 180)
        else
            SetColor(v, 162, 162, 162)
        end
    end
end

function PetBossDungeonLeftCenter:RefreshBossList(group)
    self.items = self.items or {}
    self.currentGroup = group or self.currentGroup
    local bossList = self.model:GetPetBossList(self.floor, self.currentGroup)

    local count = #bossList
    local fullH = count * self.itemSize.y
    local baseY = (fullH - self.itemSize.y) * 0.5

    SetSizeDeltaY(self.itemParent, fullH)
    self:CreateBossItem(count, baseY, self.itemSize.y)

    local selectedId = self.model:GetSelectedPetId(true)
    local selectedItem = nil

    for i, v in ipairs(bossList) do

        if (selectedId and v.id == selectedId) then
            selectedItem = self.items[i]
        end
        SetAnchoredPosition( self.items[i].transform, 0, baseY - (i - 1) * self.itemSize.y)
        self.items[i]:SetData(v)
        self.items[i]:SetCallBack(handler(self, self.OnSelectBossItem))
        self.items[i]:SetSelected(false)
        SetVisible(self.items[i], true)
    end

    for i = #bossList + 1, #self.items do
        SetVisible(self.items[i], false)
    end

    ---暂时保存ID的
    if (selectedItem) then
        self:OnSelectBossItem(selectedItem)
    end
end

function PetBossDungeonLeftCenter:CreateBossItem(count, baseY, itemY)
    if (count <= #self.items) then
        return
    end

    for i = #self.items + 1, count do
        local tempItem = PetBossDungeonLeftCenterItem(newObject(self.itemPrefab))
        tempItem.transform.name = "pet_boss_item" .. i
        SetParent(tempItem.transform, self.itemParent)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        SetAnchoredPosition(tempItem.transform, 0, baseY - (i - 1) * itemY)
        table.insert(self.items, tempItem)
    end
end

function PetBossDungeonLeftCenter:OnSelectBossItem(item, isRefresh)
    if self.currBossItem then
        self.currBossItem:SetSelected(false)
    end

    self.currBossItem = item
    self.currBossItem:SetSelected(true)

    ---刷新列表的选中的，就不寻路了
    if isRefresh then
        return
    end
    local coord = String2Table(item.data.config.coord)
    self:HandleMoveTo(coord[1], coord[2])
end

function PetBossDungeonLeftCenter:HandleMoveTo(x, y)

    local call_back = function()
        if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end
    end

    local main_role = SceneManager:GetInstance():GetMainRole()
    local main_pos = main_role:GetPosition()
    TaskModel:GetInstance():StopTask()--先停掉任务,因为任务优先级高
    OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = x, y = y }, call_back)
    AutoFightManager:GetInstance():SetAutoPosition({ x = x, y = y })
end

function PetBossDungeonLeftCenter:HandleBossList(data)
    self:RefreshBossList()
end

function PetBossDungeonLeftCenter:HandleMainMiddleLeftLoaded()

end

function PetBossDungeonLeftCenter:HandleBossInfo(data)
    for _, v in ipairs(self.items) do
        if (v.data.id == data.id) then
            v.data.born = data.born
            v.data.weak = data.weak
            v:RefreshView()
        end
    end
end

function PetBossDungeonLeftCenter:HandleBossChange(data)
    for _, v in ipairs(self.items) do
        if (v.data.id == data.oldid) then
            v:ChangeBoss(data.newid)
        end
    end
end

function PetBossDungeonLeftCenter:HandleBossWeakStop(data)
    for _, v in ipairs(self.items) do
        if (v.data.id == data.id) then
            v:StopWeakCountDown()
        end
    end
end

function PetBossDungeonLeftCenter:HandleSavageData()
    local data = DungeonModel:GetInstance().angryData
    if data.anger and data.kickcd then
        local anger = data.anger--增加后的愤怒值
        local kickcd = data.kickcd--愤怒值满后被踢出副本的倒计时(时间戳)
        if self.angry then
            self.angry.gameObject:SetActive(true)
        end
        if anger > 100 then
            anger = 100
        end
        anger = 100 - anger
        self.angryblood:UpdateCurrentBlood(anger, 100)
        self.angry_text.text = tostring(anger)
        if kickcd ~= 0 and not self.kick_countdown then
            SetGameObjectActive(self.countdown_bg, true)
            self.kick_countdown = CountDownText(self.countdown_bg, { formatTime = "%d", isShowMin = false, duration = 0.2, nodes = { "countdown_text" } })
            self.kick_countdown:StartSechudle(kickcd, handler(self, self.HandleCountDown), handler(self, self.HandleCDUpdate))
        end
    end
end

function PetBossDungeonLeftCenter:HandleCountDown()
    if self.countdown_bg then
        SetGameObjectActive(self.countdown_bg, false)
    end
end


function PetBossDungeonLeftCenter:HandleCDUpdate()
    local data = DungeonModel:GetInstance().angryData
    if data.kickcd then
        if data.kickcd - os.time() < 11 and (not self.expelPanelShow) then
            self.expelPanelShow = true
            local panel = lua_panelMgr:GetPanel(DungeonExpelPanel)
            if not panel then
                panel = lua_panelMgr:GetPanelOrCreate(DungeonExpelPanel)
                panel:Open()
            end
            panel:SetText( ConfigLanguage.Dungeon.PET_DUNGEON_EXPEL_TIP)
        end
    end
end

function PetBossDungeonLeftCenter:SetShow(flag)
    self.show = flag
end