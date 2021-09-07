MainuiTraceDungeon = MainuiTraceDungeon or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

local towernpc = {
    10026,10027,10028
}

function MainuiTraceDungeon:__init(main)
    self.main = main
    self.isInit = false
    self.currId = nil
    self.task_item = nil
    self.base_taskData = nil
    self.pathfunc = function(combattype, result)
        if combattype == nil or result == 1 then
            -- local mapid = SceneManager.Instance:CurrentMapId()
            local dungeonData = DataDungeon.data_get[self.currId]
            -- local dungeonMapData = DataDungeon.data_dungeon_map[self.currId.."_"..mapid]

            if dungeonData ~= nil and dungeonData.type == 5 then
                return
            end
            LuaTimer.Add(500, function()
                self:AutoPath()
            end)
        end
    end
    self.autoflag = false
    self.stopFarmcallback = function()
        self.autoflag = false
    end
    self.ship_1endtime = 0
    self.ship_2endtime = 0
    self.ship_status = 3
    self.ship_box = 0
    self.ship_score = 0
    self.retry = 0
    DungeonManager.Instance.InfoChangeEvent:AddListener(function()
        self:ShowShippingDungeon()
    end)
    self.killTimesListener = function(list) self:OnUpdateProperty(list) end
    self.layerUpdateListener = function() self:SetId(DungeonManager.Instance.currdungeonID) end

    self.resList = {
        {file = AssetConfig.dungeon_content, type = AssetType.Main},
        {file = AssetConfig.bufficon, type = AssetType.Dep},
        {file = AssetConfig.teamquest, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceDungeon:__delete()
    self:OnHide()
    LuaTimer.Delete(self.tick)
    self.tick = nil
end

function MainuiTraceDungeon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dungeon_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.mainbg = self.transform:GetComponent(Image)
    self.task_item = self.transform:Find("taskItem").gameObject
    self.task_item1 = self.transform:Find("taskItem1").gameObject
    self.toggle = self.transform:Find("toggle").gameObject
    self.Container = self.transform:Find("Container").gameObject
    self.containerTitleObj = self.transform:Find("Container/Title").gameObject
    -- self.containerTitleImage = self.transform:Find("Container/TitleImage"):GetComponent(Image)
    self.Container1 = self.transform:Find("CountainerMask/Container1").gameObject
    self.shipContainer = self.transform:Find("CountainerShip").gameObject
    self.bossImage = self.transform:Find("bossImage").gameObject

    self.shipbegintime = self.shipContainer.transform:Find("begin/Time"):GetComponent(Text)
    self.shipstarttime = self.shipContainer.transform:Find("start/Des1"):GetComponent(Text)
    self.shipboxnum = self.shipContainer.transform:Find("start/Des2"):GetComponent(Text)
    -- self.TowerEnd = self.transform:Find("TowerEnd").gameObject
    -- self.TowerNext = self.transform:Find("TowerNext").gameObject
    self.transform:GetComponent(Button).onClick:AddListener(function()self.autoflag = true self:AutoPath() end)
    self.exitbtn = self.transform:Find("ExitButton")
    self.isInit = true
    -- self.exitbtn.gameObject:SetActive(true)
    -- self.effectGO = BaseEffectView.New({effectId = 10082, time = nil, callback = function() self:OnEffectLoaded() end})

    self.clearance = self.transform:Find("Clearance")
    self.clearanceTitleImage = self.transform:Find("Clearance/Title"):GetComponent(Image)
    self.clearanceTitleRect = self.clearanceTitleImage.gameObject:GetComponent(RectTransform)
    self.clearanceTarget = self.transform:Find("Clearance/Target"):GetComponent(Text)
    self.clearanceTargetRect = self.clearanceTarget.gameObject:GetComponent(RectTransform)
    self.extMsgText = self.transform:Find("Ext"):GetComponent(Text)
    self.extMsgTextRect = self.transform:Find("Ext"):GetComponent(RectTransform)
    self.propertyPanel = self.transform:Find("Property").gameObject
    self.propertyRect = self.propertyPanel:GetComponent(RectTransform)
    self.killTimeText = self.transform:Find("Property/Info/Value"):GetComponent(Text)
    self.attrValueText = self.transform:Find("Property/Property/Value"):GetComponent(Text)

    self.exitbtn:GetComponent(Button).onClick:AddListener(function() DungeonManager.Instance:ExitDungeon() end)
    self.transform:Find("CountainerShip/ExitButton"):GetComponent(Button).onClick:AddListener(function() self:OnShippingExit() end)
    self.currTime = Time.time
    self.tick = LuaTimer.Add(0, 200, function() self:SelfTick() end)

    self.activeTitleText = self.transform:Find("Clearance/ActiveTitle/Text"):GetComponent(Text)
    self.btnArea = self.transform:Find("BtnArea")
    self.exitSceneBtn = self.btnArea:Find("Exit"):GetComponent(Button)
    self.teamBtn = self.btnArea:Find("Team"):GetComponent(Button)

    self.tipsBuff = self.transform:Find("TipsBuff")
    self.tipsBuffButton = self.tipsBuff:GetComponent(Button)
    self.tipsIconImage = self.tipsBuff:Find("ItemBg/Icon"):GetComponent(Image)
    self.tipsNameText = self.tipsBuff:Find("Name"):GetComponent(Text)
    self.tipsStatusText = self.tipsBuff:Find("Status"):GetComponent(Text)

    -- self.propertyPanel.transform:Find("Info"):GetComponent(Text).fontSize = 16
    -- self.killTimeText.fontSize = 16
    -- self.propertyPanel.transform:Find("Property/Text"):GetComponent(Text).fontSize = 16

    self.exitSceneBtn.onClick:AddListener(function() SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0) end)
    self.teamBtn.onClick:AddListener(function()
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[4] = 47
        TeamManager.Instance.LevelOption = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
    end)

    -- self.extMsgText.text = ""
    self.extMsgText.gameObject:SetActive(false)
    self:SetId(DungeonManager.Instance.currdungeonID)
end

function MainuiTraceDungeon:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceDungeon:OnShow()
    self:SetId(DungeonManager.Instance.currdungeonID)
    if self.currId ~= 20001 then
        EventMgr.Instance:RemoveListener(event_name.map_click, self.stopFarmcallback)
        EventMgr.Instance:AddListener(event_name.map_click, self.stopFarmcallback)
        EventMgr.Instance:RemoveListener(event_name.end_fight, self.pathfunc)
        EventMgr.Instance:AddListener(event_name.end_fight, self.pathfunc)
        -- EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.pathfunc)
        -- EventMgr.Instance:AddListener(event_name.npc_list_update, self.pathfunc)
    end
    DungeonManager.Instance.onKillTimes:RemoveListener(self.killTimesListener)
    DungeonManager.Instance.onKillTimes:AddListener(self.killTimesListener)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.layerUpdateListener)
    EventMgr.Instance:AddListener(event_name.scene_load, self.layerUpdateListener)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 60000, function()
            if self.currId ~= nil then
                local mapid = SceneManager.Instance:CurrentMapId()
                local dungeonMapData = DataDungeon.data_dungeon_map[self.currId.."_"..tostring(mapid)]
                if dungeonMapData ~= nil then
                    local unit_list = dungeonMapData.unit_list
                    if dungeonMapData.floor == 9 then
                        DungeonManager.Instance:Require12120({{base_id = unit_list[#unit_list].unit_base_id[1]}})
                    end
                end
            end
        end)
    end
end

function MainuiTraceDungeon:OnHide()
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.pathfunc)
    -- EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.pathfunc)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.layerUpdateListener)
    DungeonManager.Instance.onKillTimes:RemoveListener(self.killTimesListener)
    EventMgr.Instance:RemoveListener(event_name.map_click, self.stopFarmcallback)
    self.autoflag = false
    self.gameObject:SetActive(false)
    if self.pathCycle ~= nil then
        LuaTimer.Delete(self.pathCycle)
        self.pathCycle = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function MainuiTraceDungeon:SetId(id)
    if id == nil or id == 0 then
        return
    end
    if self.transform == nil then
        LuaTimer.Add(500, function()self:SetId(id)end)
        return
    end
    self.transform:GetComponent(Image).enabled = true
    self.clearance.gameObject:SetActive(false)
    self.currId = id
    if self.currId ~= 20001 then
        EventMgr.Instance:RemoveListener(event_name.end_fight, self.pathfunc)
        EventMgr.Instance:AddListener(event_name.end_fight, self.pathfunc)
        -- EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.pathfunc)
        -- EventMgr.Instance:AddListener(event_name.npc_list_update, self.pathfunc)
        EventMgr.Instance:RemoveListener(event_name.map_click, self.stopFarmcallback)
        EventMgr.Instance:AddListener(event_name.map_click, self.stopFarmcallback)
        -- if DataDungeon.data_get[self.currId].type ~= 5 and id < 20001 and self.pathCycle == nil then
        --     self.autoflag = true
        --     self.pathCycle = LuaTimer.Add(0, 3000, function()
        --         if self.currId < 20001 and DataDungeon.data_get[self.currId].type ~= 5 and self.autoflag and (TeamManager.Instance:IsSelfCaptin()or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None) then
        --             print(string.format("data::::%s, %s, %s", tostring(self.currId), tostring(DataDungeon.data_get[self.currId].type), tostring(self.autoflag)))
        --             if not (CombatManager.Instance.isFighting or SceneManager.Instance.sceneElementsModel.autopath_data ~= nil) then
        --                 self:AutoPath()
        --             end
        --         end
        --     end)
        -- end
    end
    self:InitLayout()
    local mapid = SceneManager.Instance:CurrentMapId()
    if mapid == nil then
        return
    end
    -- print(mapid)
    local dungeonMapData = DataDungeon.data_dungeon_map[id.."_"..mapid]
    local dungeonData = DataDungeon.data_get[id]

    self.extMsgText.gameObject:SetActive(false)
    self.tipsBuff.gameObject:SetActive(false)
    self.extMsgText.transform.anchoredPosition = Vector2(0, 5)
    if mapid == 42000 then
        self.extMsgText.gameObject:SetActive(true)
        self.activeTitleText.text = TI18N("准备区")
        self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 130)
        self.shipContainer:SetActive(false)
        self.clearanceTitleImage.gameObject:SetActive(true)
    elseif dungeonData ~= nil and dungeonData.type == 5 then
        self.exitbtn.gameObject:SetActive(true)
        if dungeonMapData ~= nil then
            self:AddTask(dungeonMapData.unit_list)
        end
        self.extMsgText.gameObject:SetActive(true)
        self.shipContainer:SetActive(false)
        -- self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, self.Container.transform.sizeDelta.y + 35)
    elseif id < 20001 then
        self.exitbtn.gameObject:SetActive(true)
        self:AddTask( dungeonData.unit_list )
        self.Container:SetActive(true)
        self.Container1:SetActive(false)
        self.shipContainer:SetActive(false)
        -- if DataDungeon.data_get[self.currId].type ~= 5 and (TeamManager.Instance:IsSelfCaptin()or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None) then
        if DataDungeon.data_get[self.currId].type ~= 5 and TeamManager.Instance:IsSelfCaptin() then
            if not (CombatManager.Instance.isFighting or SceneManager.Instance.sceneElementsModel.autopath_data ~= nil) then
                self:AutoPath()
            end
        end
    elseif id == 20001 then
        self.exitbtn.gameObject:SetActive(false)
        for k,v in pairs(DungeonManager.Instance.tower_data) do
            if  v.mapid == mapid then
                local ctask = v.unit_list
                self:AddTask( ctask )
            end
        end
        self.Container:SetActive(false)
        self.Container1:SetActive(true)
        self.shipContainer:SetActive(false)
    elseif id == 30001 then  --远航副本
        self.exitbtn.gameObject:SetActive(false)
        self.transform:Find("bossImage").gameObject:SetActive(false)
        self.transform:Find("Container").gameObject:SetActive(false)
        self.transform:Find("CountainerMask").gameObject:SetActive(false)
        self.Container:SetActive(false)
        self.Container1:SetActive(false)
        self.shipContainer:SetActive(true)
        self.transform:GetComponent(Image).enabled = false
        self:ShowShippingDungeon()
    end
    if id ~= 30001 then
        LuaTimer.Add(50, function() self:Update(DungeonManager.Instance.currdungeonunit) end)
    end
    -- self:Update(DungeonManager.Instance.currdungeonunit)

end

function MainuiTraceDungeon:Update(_data)
    if self.currId == 30001 then

        return
    end
    self.new_taskData = _data
    local oknum = 0
    local mapid = SceneManager.Instance:CurrentMapId()
    local dungeonData = DataDungeon.data_get[self.currId]
    local dungeonMapData = DataDungeon.data_dungeon_map[self.currId.."_"..mapid]

    self.Container.transform.anchoredPosition = Vector2(62, 0)
    self.Container.transform:Find("Title").anchoredPosition = Vector2(80.5, -17.5)

    if mapid == 42000 then
        self.extMsgText.gameObject:SetActive(true)
        self.extMsgText.text = TI18N("等级大于<color='#ffff00'>80</color>级，\n<color='#ffff00'>3</color>人以上组队可挑战")
        self.extMsgTextRect.sizeDelta = Vector2(self.extMsgTextRect.sizeDelta.x, self.extMsgText.preferredHeight + 5)
        self.clearanceTitleRect.anchoredPosition = Vector2(20, -49.6)
        self.clearanceTitleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "I18N_ChanllegeCopy")
        self.clearanceTarget.text = TI18N("夺宝奇兵")
        self.clearanceTargetRect.anchoredPosition = Vector2(-20.1, -51.9)
        return
    elseif dungeonMapData == nil or #dungeonMapData.unit_list == 0 then
        self.extMsgText.gameObject:SetActive(false)
        if self.new_taskData == nil or next(self.new_taskData) == nil or self.base_taskData == nil or next(self.base_taskData) == nil then
            return
        end
    else
        self.extMsgText.gameObject:SetActive(true)
    end
    for _, data in ipairs(self.new_taskData) do
        for _, base_data in ipairs(self.base_taskData) do
            if data.unit_id == base_data.unit_base_id[1] or data.base_id == base_data.unit_base_id[1] then
                if data.num == nil or data.num >= base_data.unit_num then
                    if self.currId == 20001 then
                        local item = self.Container1.transform:Find(tostring(base_data.unit_base_id[1]))
                        if item ~= nil then
                            item:Find("SuccImg").gameObject:SetActive(true)
                            item:SetAsLastSibling()
                        end
                        self:ReSizeContainer(self.Container1)
                    else
                        local item = self.Container.transform:Find(tostring(base_data.unit_base_id[1]))
                        if item ~= nil then
                            item.transform:Find("mobnameText"):GetComponent(Text).color = Color(0.42,0.53,0.6,1)
                            item.transform:Find("BossImage").gameObject:SetActive(false)
                            item.transform:Find("NOImage").gameObject:SetActive(false)
                            item.transform:Find("OKImage").gameObject:SetActive(true)
                        end
                    end
                    oknum = oknum + 1
                end
            end
        end
    end

    self.oknum = oknum
    self.allClear = false
    DungeonManager.Instance.activeType = 0 -- 普通副本

    if DungeonManager.Instance.autoExitTeam and oknum == #self.base_taskData and TeamManager.Instance:HasTeam() and dungeonData ~= nil and dungeonData.cli_type == 1 then
        TeamManager.Instance:Send11708()
        DungeonManager.Instance.autoExitTeam = false
    end
    -- BaseUtils.dump(dungeonData, "<color=#00FF00>dungeonData</color>")

    -- local position = self.Container.transform.anchoredPosition
    -- local titlePosition = self.Container.transform:Find("Title").anchoredPosition

    self.tipsBuff.gameObject:SetActive(false)
    if dungeonData ~= nil and dungeonData.type == 5 and self.base_taskData ~= nil and dungeonMapData ~= nil then
        DungeonManager.Instance.activeType = 5 -- 塔副本，夺宝奇兵
        self.tipsBuff.gameObject:SetActive(true)

        self.Container.transform.anchoredPosition = Vector2(52, -62)
        self.Container:SetActive(oknum ~= #self.base_taskData)
        -- self.clearance.gameObject:SetActive(oknum == #self.base_taskData)
        self.activeTitleText.text = string.format(TI18N("第%s/%s层"), tostring(dungeonMapData.floor), tostring(DungeonManager.Instance.tower_85_max_floor))
        self.extMsgText.gameObject:SetActive(true)
        if dungeonMapData.reward_floor > DungeonManager.Instance.tower_85_max_floor then
            self.extMsgText.text = ""
        else
            self.extMsgText.text = string.format(TI18N("通过第<color=#FFFF00>%s</color>层可获开启<color=#FFFF00>%s</color>"), tostring(dungeonMapData.reward_floor), TI18N("海心蓝贝"))
        end
        self.extMsgTextRect.sizeDelta = Vector2(self.extMsgTextRect.sizeDelta.x, self.extMsgText.preferredHeight + 5)
        if dungeonMapData.floor < 9 then
            if oknum == #self.base_taskData then
                -- self.clearanceTitle.text = TI18N("前往")
                self.clearanceTitleImage.gameObject:SetActive(true)
                self.clearanceTitleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "I18N_GoTo")
                if dungeonMapData.floor >= DungeonManager.Instance.tower_85_max_floor then
                    self.allClear = true
                    self.clearanceTarget.text = TI18N("暂未开启")
                    self.clearanceTargetRect.anchoredPosition = Vector2(-47.2, -60.9)
                else
                    self.clearanceTarget.text = string.format(TI18N("第%s层"), tostring(dungeonMapData.floor + 1))
                    self.clearanceTargetRect.anchoredPosition = Vector2(-47.2, -51.9)
                end
                -- self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 110)
                self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 110 + self.tipsBuff.sizeDelta.y)
                self.clearanceTitleRect.anchoredPosition = Vector2(48.28, -49.6)
            else
                -- self.clearanceTitle.text = ""
                self.clearanceTitleImage.gameObject:SetActive(true)
                self.clearanceTitleRect.anchoredPosition = Vector2(20, -49.6)
                self.clearanceTitleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "I18N_Condition")
                self.clearanceTarget.text = ""
                self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 160 + self.tipsBuff.sizeDelta.y + 5)
            end
        else
            if oknum == #self.base_taskData then
                -- self.clearanceTitle.text = ""
                self.allClear = true
                self.clearanceTitleImage.gameObject:SetActive(false)
                self.clearanceTarget.text = TI18N("夺宝奇兵全通！")
                self.clearanceTitleRect.anchoredPosition = Vector2(-63.5, -50)
                self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 150 + self.tipsBuff.sizeDelta.y + 5)
            else
                -- self.clearanceTitle.text = TI18N("前往")
                self.clearanceTitleImage.gameObject:SetActive(true)
                self.clearanceTitleRect.anchoredPosition = Vector2(20, -49.6)
                self.clearanceTitleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "I18N_Condition")
                self.clearanceTarget.text = ""
                local unit_list = dungeonMapData.unit_list
                DungeonManager.Instance.printIndex = nil
                DungeonManager.Instance.killNum = nil
                DungeonManager.Instance:Require12120({{base_id = unit_list[#unit_list].unit_base_id[1]}})
                self.propertyPanel:SetActive(true)
                self.extMsgText.gameObject:SetActive(false)
                self.propertyRect.anchoredPosition = Vector2(109, self.tipsBuff.sizeDelta.y + 3)
                self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 35 * #self.base_taskData + 10 - self.Container.transform.anchoredPosition.y + self.propertyPanel.transform.sizeDelta.y + self.tipsBuff.sizeDelta.y + 5)
            end
        end

        self:ReloadTipsbuff(dungeonMapData.floor)
    else
        self.extMsgText.gameObject:SetActive(false)
    end

    if self.base_taskData ~= nil and oknum == #self.base_taskData then
        if self.currId > 20000 and self.currId < 30000 then
            if DungeonManager.Instance:GetCurrTowerfloor() == 3 then
                self:OnTowerEnd()
            else
                self:OnTowerNext()
            end
        end
    else
        -- self.transform.transform:Find("bossImage").gameObject:SetActive(true)
        -- self.transform.transform:Find("TowerEnd").gameObject:SetActive(false)
        -- self.transform.transform:Find("TowerNext").gameObject:SetActive(false)
        -- self.Container.gameObject:SetActive(true)
    end
end

function MainuiTraceDungeon:AddTask(_task)
    -- BaseUtils.dump(_task,"初始化按钮")
    self.base_taskData = _task
    local task_list = _task
    local lasttask_item = self.Container.transform:Find("Title")
    self:ClearCon()
    local currtask_item = nil
    local currContainer = 1
    if self.currId == 20001 then
        currtask_item = self.task_item1
        currContainer = self.Container1
        self.transform:Find("CountainerMask").gameObject:SetActive(true)
        self.transform:GetComponent(TransitionButton).enabled = false
    else
        currContainer = self.Container
        currtask_item = self.task_item
        self.transform:Find("CountainerMask").gameObject:SetActive(false)
        self.transform:GetComponent(TransitionButton).enabled = true
    end
    for i, task in ipairs(task_list) do
        local item = GameObject.Instantiate(currtask_item.gameObject)
        item.gameObject.name = task.unit_base_id[1]
        if self.currId > 20000 and self.currId < 30000 then
            item.gameObject.transform:GetComponent(Button).onClick:AddListener(function() self:TargetPath(task.unit_base_id[1]) end)
        else
            item.gameObject.transform:GetComponent(Button).enabled = false
            item.gameObject.transform:GetComponent(TransitionButton).enabled = false
        end
        local transform = item.transform
        transform:SetParent(currContainer.transform)
        transform.localScale = Vector3.one
        -- transform.localPosition = Vector3(lasttask_item.localPosition.x, lasttask_item.localPosition.y - lasttask_item.sizeDelta.y, lasttask_item.localPosition.z)
        transform:Find("mobnameText"):GetComponent(Text).text = task.unit_name
        lasttask_item = transform
        item.gameObject:SetActive(true)
    end
    local toggleHeight = 0
    if DataDungeon.data_get[self.currId] ~= nil and DataDungeon.data_get[self.currId].cli_type == 1 then
        toggleHeight = 30
        local item = GameObject.Instantiate(self.toggle)
        item.gameObject.name = "toggle"
        local transform = item.transform
        transform:SetParent(currContainer.transform)
        transform.localScale = Vector3.one
        item.gameObject.transform:GetComponent(Toggle).isOn = DungeonManager.Instance.autoExitTeam
        item.gameObject.transform:GetComponent(Toggle).onValueChanged:AddListener(function(on) self:onToggleChange(on) end)
        item.gameObject:SetActive(true)
    end
    currContainer.transform.sizeDelta = Vector2(currContainer.transform.sizeDelta.x, 35 * (#task_list + 1.5) + toggleHeight)
    self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, currContainer.transform.sizeDelta.y)

    if self.currId ~= 20001 then
        self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, currContainer.transform.sizeDelta.y)
        -- self.transform.transform:Find("bossImage").gameObject:SetActive(true)
        self.transform.transform:Find("bossImage/Text").gameObject:SetActive(true)
        if DataDungeon.data_get[self.currId].type == 3 then
            self.transform.transform:Find("bossImage/Text"):GetComponent(Text).text = TI18N("挑战")
            self.transform.transform:Find("bossImage/Text"):GetComponent(Text).color = Color(1, 0, 0)
        elseif DataDungeon.data_get[self.currId].type == 5 then     -- 夺宝奇兵
            self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, currContainer.transform.sizeDelta.y + 55)
        else
            self.transform.transform:Find("bossImage/Text"):GetComponent(Text).text = TI18N("普通")
            self.transform.transform:Find("bossImage/Text"):GetComponent(Text).color = Color(1, 0.5, 0)
        end
        -- self.transform.transform:Find("TowerEnd").gameObject:SetActive(false)
        -- self.transform.transform:Find("TowerNext").gameObject:SetActive(false)
    else
        self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 245)
    end
    self:ReSizeContainer(currContainer)
    currContainer.gameObject:SetActive(true)
end

function MainuiTraceDungeon:OnTowerNext()
    self.transform:Find("bossImage").gameObject:SetActive(false)
    self.Container.gameObject:SetActive(false)
    -- self.transform.transform:Find("TowerEnd").gameObject:SetActive(false)
    -- self.transform.transform:Find("TowerNext").gameObject:SetActive(true)
    if self.Container1.transform:Find("TowerNext") ~= nil then
        return
    end
    local item = GameObject.Instantiate(self.task_item1.gameObject)
    item.gameObject.name = "TowerNext"
    local transform = item.transform
    transform:SetParent(self.Container1.transform)
    transform.localScale = Vector3.one
    transform:GetChild(0).gameObject:SetActive(false)
    transform:GetChild(1).gameObject:SetActive(false)
    transform:GetChild(2).gameObject:SetActive(false)
    transform:GetChild(3).gameObject:SetActive(false)
    transform:GetChild(4).gameObject:SetActive(false)
    transform:GetChild(6).gameObject:SetActive(true)
    transform:GetComponent(Button).onClick:AddListener(function() self:TargetPath(towernpc[DungeonManager.Instance:GetCurrTowerfloor()]) end)
    transform:SetAsFirstSibling()
    item.gameObject:SetActive(true)
    self:ReSizeContainer(self.Container1)
    self.Container1.transform.sizeDelta = Vector2(self.Container1.transform.sizeDelta.x, 314)
    self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 245)
end

function MainuiTraceDungeon:OnTowerEnd()
    self.transform:Find("bossImage").gameObject:SetActive(false)
    self.Container.gameObject:SetActive(false)
    -- self.transform.transform:Find("TowerEnd").gameObject:SetActive(true)
    -- self.transform.transform:Find("TowerNext").gameObject:SetActive(false)
    if self.Container1.transform:Find("TowerEnd") ~= nil then
        return
    end
    local item = GameObject.Instantiate(self.task_item1.gameObject)
    item.gameObject.name = "TowerEnd"
    local transform = item.transform
    transform:SetParent(self.Container1.transform)
    transform.localScale = Vector3.one
    transform:GetChild(0).gameObject:SetActive(false)
    transform:GetChild(1).gameObject:SetActive(false)
    transform:GetChild(2).gameObject:SetActive(false)
    transform:GetChild(3).gameObject:SetActive(false)
    transform:GetChild(4).gameObject:SetActive(false)
    transform:GetChild(5).gameObject:SetActive(true)
    transform:GetComponent(Button).onClick:AddListener(function() self:TargetPath(towernpc[DungeonManager.Instance:GetCurrTowerfloor()]) end)
    transform:SetAsFirstSibling()
    item.gameObject:SetActive(true)
    self.Container1.transform.sizeDelta = Vector2(self.Container1.transform.sizeDelta.x, 314)
    self:ReSizeContainer(self.Container1)
    self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, 245)
end

function MainuiTraceDungeon:ClearCon()
    for i = 1, self.Container.transform.childCount do
        if self.Container.transform:GetChild(i - 1).gameObject.name ~= "Title" and self.Container.transform:GetChild(i - 1).gameObject.name ~= "endText" then
            self.Container.transform:GetChild(i - 1).gameObject:SetActive(false)
            GameObject.Destroy(self.Container.transform:GetChild(i - 1).gameObject)
        end
    end
    for i = 1, self.Container1.transform.childCount do
        if self.Container1.transform:GetChild(i - 1).gameObject.name ~= "Title" and self.Container1.transform:GetChild(i - 1).gameObject.name ~= "endText" then
            self.Container1.transform:GetChild(i - 1).gameObject:SetActive(false)
            GameObject.Destroy(self.Container1.transform:GetChild(i - 1).gameObject)
        end
    end
end

function MainuiTraceDungeon:AutoPath()
    local mapid = SceneManager.Instance:CurrentMapId()
    if mapid == 10001 then
        return
    end
    local dungeonData = DataDungeon.data_get[self.currId]
    local dungeonMapData = DataDungeon.data_dungeon_map[self.currId.."_"..mapid]

    if mapid == 42000 then
        QuestManager.Instance.model:FindNpc("10051_1")
        return
    elseif self.currId == 20001 then
        return
    end
    local uuid = nil
    local battleid = 1
    local lev = 0
    local x = nil
    local y = nil
    local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    -- BaseUtils.dump(units)
    for k,v in pairs(units) do
        -- if v.type==2 or v.type==3 or v.type==101 or (v.type==105 and mod_team.has_team()) then
        if v.unittype==2 or v.unittype==3 or v.unittype==101 then
            if v.guideLev >= lev then
                uuid = v.uniqueid
                lev = v.guideLev
                x = v.x
                y = v.y
            end
        end
    end
    if x ~= nil then
        self.retry = 0
        -- SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(x, y)
        -- SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(uuid)
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(SceneManager.Instance:CurrentMapId(), uuid)
    else
        if self.retry < 5 then
            LuaTimer.Add(300, function()
                self.retry = self.retry + 1
                self:AutoPath()
            end)
        end
    end
   -- mod_scene_manager.walkto_npc_nopath(uuid)
end

function MainuiTraceDungeon:TargetPath(baseid)
    if self.currId ~= 20001 then
        return
    end
    local uuid = nil
    local battleid = 1
    local lev = 0
    local x = nil
    local y = nil
    local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for k,v in pairs(units) do
        if v.baseid == baseid then
            uuid = v.uniqueid
            lev = v.guideLev
            x = v.x
            y = v.y
        end
    end
    if x ~= nil then
        SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(uuid)
    end
end

function MainuiTraceDungeon:ReSizeContainer(Container)
    local Containertrans = Container.transform
    local count = Containertrans.childCount
    -- print(count)
    local lastitem = nil
    for i = 0, count-1 do
        local child = Containertrans:GetChild(i)
        local posi
        if child.gameObject.activeSelf then
            if lastitem == nil then
                posi = Vector3(child.sizeDelta.x/2, 0 - child.sizeDelta.y/2, 0)
            else
                posi = Vector3(child.sizeDelta.x/2, lastitem.localPosition.y - lastitem.sizeDelta.y/2 - child.sizeDelta.y/2, 0)
            end
            child.localPosition = posi
            lastitem = child
        end
    end
end

function MainuiTraceDungeon:InitLayout()
    local dungeonData = DataDungeon.data_get[self.currId]
    local mapid = SceneManager.Instance:CurrentMapId()

    -- BaseUtils.dump(dungeonData, "<color=#FF0000>dungeonData</color>")

    self.clearance.gameObject:SetActive(false)
    self.containerTitleObj:SetActive(true)
    self.propertyPanel:SetActive(false)
    if mapid == 42000 then          -- 夺宝奇兵准备区
        self.mainbg.enabled = true
        self.bossImage:SetActive(false)
        self.Container:SetActive(false)
        self.Container1:SetActive(false)
        self.exitbtn.gameObject:SetActive(false)
        self.btnArea.gameObject:SetActive(true)
        self.clearance.gameObject:SetActive(true)
        self.extMsgText.gameObject:SetActive(true)
    elseif dungeonData ~= nil and dungeonData.type == 5 then    -- 夺宝奇兵
        self.mainbg.enabled = true
        self.bossImage:SetActive(false)
        self.Container:SetActive(true)
        self.Container1:SetActive(false)
        self.containerTitleObj:SetActive(false)
        self.exitbtn.gameObject:SetActive(true)
        self.clearance.gameObject:SetActive(true)
        self.btnArea.gameObject:SetActive(false)
    elseif self.currId == 20001 then
        self.mainbg.enabled = false
        self.bossImage:SetActive(false)
        self.Container:SetActive(false)
        self.Container1:SetActive(true)
        -- self.TowerEnd:SetActive(false)
        -- self.TowerNext:SetActive(false)
        self.exitbtn.gameObject:SetActive(false)
        self.btnArea.gameObject:SetActive(false)
    else
        self.mainbg.enabled = true
        self.bossImage:SetActive(true)
        self.Container:SetActive(true)
        self.Container1:SetActive(false)
        -- self.TowerEnd:SetActive(false)
        -- self.TowerNext:SetActive(false)
        self.exitbtn.gameObject:SetActive(true)
        self.btnArea.gameObject:SetActive(false)
    end
end

function MainuiTraceDungeon:ShowShippingDungeon(extdata)
    if self.currId ~= 30001 then
        return
    end
    self.ship_box = 0
    if extdata ~= nil then
        for k,v in pairs(extdata) do
            if v.key == 1 then
                if v.val_1 == 1 then
                    if v.val_2 > BaseUtils.BASE_TIME then
                        self.ship_status = 1
                        self.ship_endtime = v.val_2 - BaseUtils.BASE_TIME
                    end
                elseif v.val_1 == 2 then
                    if v.val_2 > BaseUtils.BASE_TIME then
                        self.ship_status = 2
                        self.ship_endtime = v.val_2 - BaseUtils.BASE_TIME
                    end
                end
            elseif v.key == 2 then
                self.ship_score = v.val_1
            elseif v.key == 3 then
                self.ship_box = self.ship_box + v.val_2
            end
        end
    elseif DungeonManager.Instance.currextdata ~= nil then
        extdata = DungeonManager.Instance.currextdata
        for k,v in pairs(extdata) do
            if v.key == 1 then
                if v.val_1 == 1 then
                    if v.val_2 > BaseUtils.BASE_TIME then
                        self.ship_status = 1
                    end
                    self.ship_1endtime = v.val_2 - BaseUtils.BASE_TIME
                elseif v.val_1 == 2 then
                    if v.val_2 > BaseUtils.BASE_TIME and self.ship_1endtime <= 0 then
                        self.ship_status = 2
                    end
                    self.ship_2endtime = v.val_2 - BaseUtils.BASE_TIME
                end
            elseif v.key == 2 then
                self.ship_score = v.val_1
                self.shipboxnum.text = string.format(TI18N("已获得雕像：<color='#ffff00'>%s</color>"), self.ship_score)
            elseif v.key == 3 then
                self.ship_box = self.ship_box + v.val_2
            end
        end
    end

    local begincon = self.shipContainer.transform:Find("begin")
    local startcon = self.shipContainer.transform:Find("start")
    local endcon = self.shipContainer.transform:Find("end")
    if self.ship_status == 1 and self.ship_1endtime > 0 then
        begincon.gameObject:SetActive(true)
        startcon.gameObject:SetActive(false)
        endcon.gameObject:SetActive(false)

    elseif self.ship_status == 2 and self.ship_2endtime > 0 then
        begincon.gameObject:SetActive(false)
        startcon.gameObject:SetActive(true)
        endcon.gameObject:SetActive(false)
    else
        begincon.gameObject:SetActive(false)
        startcon.gameObject:SetActive(false)
        endcon.gameObject:SetActive(true)
    end
end

function MainuiTraceDungeon:SelfTick()
    local ttime = Time.time
    local gapetime = ttime - self.currTime
    self.currTime = ttime
    if self.ship_1endtime <= 0 and self.ship_2endtime <= 0 and self.ship_status ~= 3 then
        return
    end
    self.ship_1endtime = self.ship_1endtime - gapetime
    self.ship_2endtime = self.ship_2endtime - gapetime
    -- if self.ship_status == 1 then
    local T1 = math.max(0, self.ship_1endtime-2)
    local T2 = math.max(0, self.ship_2endtime)
        self.shipbegintime.text = tostring(math.ceil(T1))
    -- elseif self.ship_status == 2 then
        self.shipstarttime.text = string.format(TI18N("秘境关闭中：<color='#ffff00'>%s</color>"), math.ceil(T2))
    -- end
    if self.ship_1endtime-2 > 0 then
        self.ship_status = 1
    elseif self.ship_2endtime > 0 then
        self.ship_status = 2
    else
        self.ship_status = 3
    end
    self.shipContainer.transform:Find("begin").gameObject:SetActive(self.ship_status == 1)
    self.shipContainer.transform:Find("start").gameObject:SetActive(self.ship_status == 2)
    self.shipContainer.transform:Find("end").gameObject:SetActive(self.ship_status == 3)
end

function MainuiTraceDungeon:OnShippingExit()
    if self.ship_status ~= 3 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("提前退出将按照当前记录结算")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.greenCancel = true
        data.blueSure = true
        data.sureCallback = function()
            DungeonManager.Instance:ExitDungeon()
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        DungeonManager.Instance:ExitDungeon()
    end
end
-- self.ship_endtime = 0
--     self.ship_status = 1
--     self.ship_box = 0
--     self.ship_score = 0


function MainuiTraceDungeon:OnUpdateProperty(list)
    local base_id = nil
    local num = nil
    BaseUtils.dump(list, "list")
    -- for i,v in pairs(list) do
    --     base_id = i
    --     num = v
    --     break
    -- end
    local mapid = SceneManager.Instance:CurrentMapId()
    local dungeonMapData = DataDungeon.data_dungeon_map[self.currId.."_"..mapid]
    local unit_list = dungeonMapData.unit_list
    local id = unit_list[#unit_list].unit_base_id[1]
    num = list[id]
    self.killTimeText.text = ""
    self.attrValueText.text = ""
    if num == nil then
        DungeonManager.Instance.printIndex = 0
        DungeonManager.Instance.killNum = 0
    else
        local tab = {}
        for k,v in pairs(DataDungeon.data_count_attr) do
            if id == v.id then
                table.insert(tab, v)
            end
        end
        table.sort(tab, function(a,b) return a.min < b.min end)

        local data_index = 0
        for i,v in ipairs(tab) do
            if num < v.min then
                data_index = i - 1
                break
            end
        end

        DungeonManager.Instance.printIndex = data_index
        DungeonManager.Instance.killNum = num
        local gra = data_index - 1
        if gra < 0 then gra = 0 end
        self.killTimeText.text = tostring(num) .. "\n" .. tostring(gra)

        local s = ""
        if tab[data_index] ~= nil then
            s = ""
            local datalist = {}
            local kvList = {}
            BaseUtils.dump(tab[data_index].attr)
            for i,v in ipairs(tab[data_index].attr) do
                if v.point_name == 55 then
                    kvList[54] = v.val
                else
                    kvList[v.point_name] = v.val
                end
            end
            BaseUtils.dump(kvList)
            for k,v in pairs(kvList) do
                table.insert(datalist, {name = k, val = v})
            end
            BaseUtils.dump(datalist)
            for i,v in ipairs(datalist) do
                if v.name == 54 then
                    s = s .. TI18N("攻击") .. ":+" .. (v.val / 10 - 100) .. "% "
                else
                    s = s .. KvData.attr_name_show[v.name] .. ":+" .. (v.val / 10 - 100) .. "% "
                end
                if i == 2 then
                    s = s .. "\n"
                end
            end
        else
            local datalist = {1, 2, 3, 4}
            for i,v in ipairs(datalist) do
                s = s .. KvData.attr_name_show[v] .. ":+0  "
                if i == 2 then
                    s = s .. "\n"
                end
            end
        end
        self.attrValueText.text = s
    end
    -- self.attrValueText.fontSize = 16
end

function MainuiTraceDungeon:ReloadTipsbuff(floor)
    local tab = DungeonManager.Instance.extraInfoDic[2] or {}
    local max_lev = (tab[#tab] or {}).val_2 or 0
    local clearerBuff = DungeonManager.Instance.model.clearerBuff

    self.tipsIconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.bufficon, clearerBuff.icon)
    self.tipsNameText.text = clearerBuff.name
    if max_lev - 3 < floor then
        self.tipsStatusText.text = TI18N("<color='#ff0000'>未获得</color>")
        self.tipsIconImage.color = Color(0.5, 0.5, 0.5)
    else
        self.tipsStatusText.text = TI18N("已获得")
        self.tipsIconImage.color = Color(1, 1, 1)
    end

    self.tipsBuff.anchoredPosition = Vector2(0, 32)
    self.extMsgText.transform.anchoredPosition = Vector2(0, 62)
    self.tipsBuffButton.onClick:RemoveAllListeners()
    self.tipsBuffButton.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.dungeonclearbuff, max_lev - 3 >= floor) end)
end

function MainuiTraceDungeon:onToggleChange(on)
    DungeonManager.Instance.autoExitTeam = on
end