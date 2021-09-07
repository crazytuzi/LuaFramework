WarriorDescWindow = WarriorDescWindow or BaseClass(BaseWindow)

function WarriorDescWindow:__init(model)
    self.model = model
    self.name = "WarriorDescWindow"
    self.windowId = WindowConfig.WinID.warrior_desc_window

    self.resList = {
        {file = AssetConfig.warrior_desc_window, type = AssetType.Main},
        {file = AssetConfig.warrior_textures, type = AssetType.Dep},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
    }

    self.actualCounter = 0
    self.targetCounter = -1
    self.rotateCounter = 0
    self.slowSpeed = 1
    self.endIndex = 1

    self.shouhuList = {}
    self.forceList = {}

    self.reloadListener = function() self:Reload() end
    self.guardSelectListener = function(index) self:GuardSelectListener(index) end
    self.formationSelectListener = function(index) self:FormationSelectListener(index) end
    self.confirmModeListener = function(mode) self:DoEnd(mode) end

    self.surviveString = TI18N("1.随机划分至<color=#13fc60>2个阵营</color>，每<color=#13fc60>30</color>秒匹配战斗，拥有<color=#13fc60>4</color>次复活机会\n2.战斗从第<color=#13fc60>2</color>回合开始，双方战斗单位将<color=#13fc60>自动损失</color>一定生命值\n3.最终获胜的阵营将开启<color=#13fc60>战场宝箱</color>")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WarriorDescWindow:__delete()
    self.OnHideEvent:Fire()
    if self.tweenTimerId ~= nil then
        LuaTimer.Delete(self.tweenTimerId)
        self.tweenTimerId = nil
    end
    if self.hidenMoveTweenId ~= nil then
        Tween.Instance:Cancel(self.hidenMoveTweenId)
        self.hidenMoveTweenId = nil
    end
    if self.hidenScaleTweenId ~= nil then
        Tween.Instance:Cancel(self.hidenScaleTweenId)
        self.hidenScaleTweenId = nil
    end
    if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
        self.rotateId = nil
    end
    if self.lightList ~= nil then
        for _,v in pairs(self.lightList) do
            if v ~= nil then
                v.image.sprite = nil
            end
        end
        self.lightList = nil
    end
    if self.rollingEffectTimerId ~= nil then
        LuaTimer.Delete(self.rollingEffectTimerId)
        self.rollingEffectTimerId = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.desc1Ext ~= nil then
        self.desc1Ext:DeleteMe()
        self.desc1Ext = nil
    end
    if self.desc2Ext ~= nil then
        self.desc2Ext:DeleteMe()
        self.desc2Ext = nil
    end
    if self.tweenIdY ~= nil then
        Tween.Instance:Cancel(self.tweenIdY)
        self.tweenIdY = nil
    end
    if self.tweenIdX ~= nil then
        Tween.Instance:Cancel(self.tweenIdX)
        self.tweenIdX = nil
    end
    if self.formationSelect ~= nil then
        self.formationSelect:DeleteMe()
        self.formationSelect = nil
    end
    if self.guardSelect ~= nil then
        self.guardSelect:DeleteMe()
        self.guardSelect = nil
    end
    if self.rollingEffect ~= nil then
        self.rollingEffect:DeleteMe()
        self.rollingEffect = nil
    end
    if self.confirmEffect ~= nil then
        self.confirmEffect:DeleteMe()
        self.confirmEffect = nil
    end
    if self.forceList ~= nil then
        for _,v in pairs(self.forceList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.forceList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WarriorDescWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.warrior_desc_window))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local main = t:Find("Main")
    local combatForce = main:Find("CombatForce")

    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.descArea = main:Find("DescArea").gameObject
    self.desc1Ext = MsgItemExt.New(main:Find("DescArea/Desc1"):GetComponent(Text), 309.7, 16, 18.7)
    self.desc2Ext = MsgItemExt.New(main:Find("DescArea/Desc2"):GetComponent(Text), 309.7, 16, 18.7)

    self.bg = main:Find("Bg").gameObject
    self.bg1 = main:Find("Bg1").gameObject
    self.bg2 = main:Find("Bg2").gameObject

    self.formationBtn = combatForce:Find("Formation/Format"):GetComponent(Button)
    self.formationText = combatForce:Find("Formation/Format/Text"):GetComponent(Text)
    self.formationDescText = combatForce:Find("Formation/Desc"):GetComponent(Text)
    self.formationTitle = combatForce:Find("Formation/Title"):GetComponent(Text)
    self.questionBtn = self.descArea.transform:Find("Question"):GetComponent(Button)
    self.questionBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("排名奖励")
    self.formationTitle.text = TI18N("当前阵法")

    self.cloner = combatForce:Find("Cloner").gameObject
    self.container = combatForce:Find("Container")
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 5, border = 20})
    self.combatForce = combatForce

    self.lightList = {}
    local mask = main:Find("Mask")
    for i=1,4 do
        local tab = {}
        tab.transform = mask:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.image = tab.transform:Find("Image"):GetComponent(Image)
        tab.transition = tab.gameObject:GetComponent(TransitionButton)
        tab.btn = tab.gameObject:GetComponent(Button)
        tab.light = tab.transform:Find("Light")
        self.lightList[i] = tab
        tab.btn.onClick:AddListener(function() self:ShowMode() end)
    end
    self.maskTrans = mask

    self.modeArea = main:Find("Mode").gameObject

    self.formationSelectArea = main:Find("FormatChangeGuard").gameObject
    self.guardSelectArea = main:Find("TeamChangeGuard").gameObject

    self.formationSelect = ArenaFormationSelect.New(self.model, self.formationSelectArea, self.assetWrapper, self.formationSelectListener)
    self.guardSelect = WarriorGuardSelect.New(self.model, self.guardSelectArea, self.assetWrapper, self.guardSelectListener)

    self.closeBtn.onClick:AddListener(function() self:HideTween() end)
    self.formationBtn.onClick:AddListener(function() self:OnClickFormation() end)

    for i=1,6 do
        self.forceList[i] = WarriorHeadItem.New(GameObject.Instantiate(self.cloner), self.assetWrapper)
        self.layout:AddCell(self.forceList[i].gameObject)
        self.forceList[i]:Default()
    end
    self.cloner:SetActive(false)

    self.descArea.transform:Find("Title2/Text"):GetComponent(Text).text = TI18N("战场模式")
    self.battleTitle = self.descArea.transform:Find("Title1/Text"):GetComponent(Text)

    self.modeTitleText = self.modeArea.transform:Find("Title"):GetComponent(Text)

    self.modeArea.transform:Find("Left").transform.anchoredPosition = Vector2(-180, -2)
    self.modeArea.transform:Find("Right").transform.anchoredPosition = Vector2(180, -2)

    -- 测试代码
    -- local obj = GameObject.Instantiate(self.closeBtn.gameObject)
    -- -- obj.transform:SetParent(main:Find("Mode"))
    -- -- obj.transform.anchoredPosition = Vector2(0, 0)
    -- -- obj.transform.localScale = Vector3(1, 1, 1)
    -- -- obj:GetComponent(Button).onClick:RemoveAllListeners()
    -- -- obj:GetComponent(Button).onClick:AddListener(function() self:DoEnd(math.random(1,3)) end)

    self.formationSelect:Hiden()
    self.guardSelect:Hiden()

    self.questionBtn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.questionBtn.gameObject, itemData = DataItem.data_get[21160], extra = {nobutton = true}}) end)
    self.questionBtn.transform.anchoredPosition = Vector2(-437.87,-130.3)
end

function WarriorDescWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WarriorDescWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.guard_position_change, self.reloadListener)
    EventMgr.Instance:AddListener(event_name.battlepet_update, self.reloadListener)
    EventMgr.Instance:AddListener(event_name.formation_update, self.reloadListener)
    WarriorManager.Instance.modeConfirmEvent:AddListener(self.confirmModeListener)
    WarriorManager.Instance.updateFormationEvent:AddListener(self.reloadListener)

    if self.model.mode == 0 then
        self.speed = 7
        self:SpeedUp()
        self:BeginRoll()
    else
        self:Reload()
        self:ReloadMode()
        self.descArea:SetActive(true)
        self.combatForce.gameObject:SetActive(true)
        self.modeArea.gameObject:SetActive(false)
        self:ReloadDesc()
    end

    self.transform:Find("Panel"):GetComponent(Button).onClick:RemoveAllListeners()
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:HideTween() end)

    WarriorManager.Instance:CheckBattlePet()
end

function WarriorDescWindow:OnHide()
    self:RemoveListeners()

    if self.targetSpeedUpId ~= nil then
        LuaTimer.Delete(self.targetSpeedUpId)
        self.targetSpeedUpId = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.warriorPanel ~= nil and MainUIManager.Instance.mainuitracepanel.warriorPanel.isInit == true then
        MainUIManager.Instance.mainuitracepanel.warriorPanel.showRed:SetActive(WarriorManager.Instance:CheckRed())
    end
end

function WarriorDescWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.guard_position_change, self.reloadListener)
    EventMgr.Instance:RemoveListener(event_name.battlepet_update, self.reloadListener)
    EventMgr.Instance:RemoveListener(event_name.formation_update, self.reloadListener)
    WarriorManager.Instance.updateFormationEvent:RemoveListener(self.reloadListener)
    WarriorManager.Instance.modeConfirmEvent:RemoveListener(self.confirmModeListener)
end

function WarriorDescWindow:Reload()
    local formationId = FormationManager.Instance.formationId
    local formationLev = FormationManager.Instance.formationLev
    local formationData = DataFormation.data_list[formationId.."_"..formationLev]

    self.formationText.text = string.format("%s Lv.%s", formationData.name, formationLev)

    -- BaseUtils.dump(formationData, "formationData")
    -- self.model.mode = 4
    if self.model.mode == 4 then
        formationData = DataFormation.data_list["89_1"]
    end

    local datalist = {}
    local roleData = RoleManager.Instance.RoleData
    datalist[1] = {
        type = 1,
        classes = roleData.classes,
        sex = roleData.sex,
        effect = formationData.attr_1,
    }

    self.shouhuProtoList = {}

    for i,v in ipairs(FormationManager.Instance.guardList) do
        if v.number > 0 then
            self.shouhuProtoList[v.number] = v
        end
    end

    -- 萌宠
    if self.model.mode == 4 then
        datalist[2] = {type = 2, effect = formationData.pet_attr, base_id = (PetManager.Instance.model.battle_petdata or {}).base_id}
        if self.model.pos_list[3] ~= nil and self.model.pos_list[3].id ~= nil and self.model.pos_list[3].id > 0 then
            datalist[3] = {type = 2, effect = formationData.pet_attr, base_id = (PetManager.Instance:GetPetById((self.model.pos_list[3] or {}).id) or {}).base_id}
        else
            datalist[3] = {type = 2, effect = formationData.pet_attr}
        end
        if self.model.pos_list[4] ~= nil and self.model.pos_list[4].id ~= nil and self.model.pos_list[4].id > 0 then
            datalist[4] = {type = 2, effect = formationData.pet_attr, base_id = (PetManager.Instance:GetPetById(self.model.pos_list[4].id) or {}).base_id}
        else
            datalist[4] = {type = 2, effect = formationData.pet_attr}
        end

        -- datalist[5] = {type = 3, base_id = (self.model.pos_list[5] or {}).id, effect = formationData.attr_2}
        -- datalist[6] = {type = 3, base_id = (self.model.pos_list[6] or {}).id, effect = formationData.attr_3}
        datalist[5] = {type = 3, base_id = nil, effect = formationData.attr_2}
        datalist[6] = {type = 3, base_id = nil, effect = formationData.attr_3}

        local j = 5
        for i=1,5 do
            if self.shouhuProtoList[i] ~= nil and self.shouhuProtoList[i].guard_id ~= nil and self.shouhuProtoList[i].guard_id > 0 and datalist[j] ~= nil then
                datalist[j].base_id = self.shouhuProtoList[i].guard_id
                j = j + 1
            end
        end

        self.formationDescText.text = TI18N("同类宠物只能\n同时上场1只")
        self.formationDescText.gameObject:SetActive(true)
        self.formationText.gameObject:SetActive(false)
        self.formationBtn.gameObject:SetActive(false)
        self.formationTitle.gameObject:SetActive(false)
    else
        -- 其他
        datalist[2] = {type = 2, base_id = (PetManager.Instance.model.battle_petdata or {}).base_id, effect = formationData.pet_attr}
        for i=3,6 do
            datalist[i] = {type = 3, base_id = (self.shouhuProtoList[i - 1] or {}).guard_id, effect = formationData["attr_" .. (i - 1)], pos = (self.shouhuProtoList[i - 1] or {}).number or 0}
        end
        self.formationDescText.gameObject:SetActive(false)
        self.formationText.gameObject:SetActive(true)
        self.formationBtn.gameObject:SetActive(true)
        self.formationTitle.gameObject:SetActive(true)
    end

    BaseUtils.dump(datalist, "datalist")

    for i,v in ipairs(self.forceList) do
        v:SetData(datalist[i])
        v.btn.onClick:RemoveAllListeners()
        local j = i
        if self.model.mode == 4 then
            if i == 2 then
                v:SetExt(TI18N("主战宠"))
            elseif i == 3 or i == 4 then
                v:SetExt(TI18N("辅战宠"))
            elseif i == 5 or i == 6 then
                v:SetExt(TI18N("守护"))
            end
        else
            BaseUtils.dump(datalist[i].effect, tostring(i))
        end
        if datalist[i].type == 2 then
            v.btn.onClick:AddListener(function() self:ClickPet(j - 1) end)
        elseif datalist[i].type == 3 then
            v.btn.onClick:AddListener(function() self:OnClickGuard(j - 1) end)
        end
    end
end

function WarriorDescWindow:OnClickGuard(index)
    self.currentSHList = BaseUtils.copytab(ShouhuManager.Instance.model.my_sh_list)
    for i,v in ipairs(self.currentSHList) do
        if v.war_id > 0 then
            v.rank_value = 3
        elseif v.guard_fight_state == ShouhuManager.Instance.model.guard_fight_state.field then
            v.rank_value = 1
        else
            v.rank_value = 2
        end
    end
    table.sort(self.currentSHList, function(a, b) return a.rank_value > b.rank_value end)

    self.formationSelect:Hiden()
    local model = self.model
    if self.guardSelect.isOpen == true then
        self.guardSelect:Hiden()
    else
        self.guardWarId = index + 1
        self.guardSelect:Show(self.currentSHList, index - 1, (self.shouhuProtoList[index] or {}).base_id, {id = FormationManager.Instance.formationId, lev = FormationManager.Instance.formationLev})
    end
end

function WarriorDescWindow:GuardSelectListener(index)
    local model = self.model
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()

    self.guardSelect:UnSelect(self.guardSelect.lastSelect)

    local tab = self.guardSelect.selectTab
    if self.guardSelect.lastSelect == nil then
        tab[index] = true
        self.guardSelect.lastSelect = index
    elseif self.guardSelect.lastSelect == index then
        tab[index] = false
        self.guardSelect.lastSelect = nil
    else
        tab[self.guardSelect.lastSelect] = false
        tab[index] = true
        self.guardSelect.lastSelect = index
    end
    self.guardSelect:Select(self.guardSelect.lastSelect)

    local selectIndex = self.guardSelect:GetSelection()

    local currentSHList = {}
    for i=1,4 do
        if self.shouhuProtoList[i + 1] ~= nil then
            currentSHList[i + 1] = self.shouhuProtoList[i + 1].guard_id
        else
            currentSHList[i + 1] = 0
        end
    end

    -- self.model.mode = 4
    if selectIndex ~= nil then
        local base_id = self.currentSHList[selectIndex].base_id         -- 选中的守护id
        local swap_base_id = 0
        if self.model.mode == 4 then
            local j = 4
            for i=1,5 do
                if currentSHList[i] ~= nil and currentSHList[i] ~= 0 then
                    if j + 1 == self.guardWarId then
                        swap_base_id = currentSHList[i]
                        break
                    end
                    j = j + 1
                end
            end
        else
            swap_base_id = currentSHList[self.guardWarId - 1] or 0
        end
        local pos_list = {--[[{pos = 1},{pos = 2},{pos = 3},{pos = 4},{pos = 5},{pos = 6}]] }
        for _,v in pairs(self.model.pos_list) do
            table.insert(pos_list, v)
        end

        -- if DataShouhu.data_guard_base_cfg[base_id] ~= nil then
        --     print("选中的"..DataShouhu.data_guard_base_cfg[base_id].alias)
        -- end
        -- if DataShouhu.data_guard_base_cfg[swap_base_id] ~= nil then
        --     print("要交换的"..DataShouhu.data_guard_base_cfg[swap_base_id].alias)
        -- end
        -- if self.model.mode == 4 then
        --     local canFind = false
        --     if base_id == swap_base_id then
        --         for _,v in ipairs(pos_list) do
        --             if v.id == base_id then
        --                 v.id = 0
        --                 canFind = true
        --                 break
        --             end
        --         end
        --     else
        --         for _,v in ipairs(pos_list) do
        --             if v.pos == 5 or v.pos == 6 then
        --                 if v.id == base_id then
        --                     v.id = 0
        --                     canFind = true
        --                 elseif v.pos == self.guardWarId then
        --                     v.id = base_id
        --                     canFind = true
        --                 end
        --             end
        --         end
        --     end
        --     -- BaseUtils.dump(pos_list, "pos_list")
        --     if canFind == false then
        --         table.insert(pos_list, {pos = self.guardWarId, id = base_id})
        --     end

        --     local pets = {}
        --     local guards = {}
        --     for _,v in pairs(pos_list) do
        --         if v.pos == 5 or v.pos == 6 then
        --             if v.id ~= nil and v.id ~= 0 then
        --                 table.insert(guards, v)
        --             end
        --         elseif v.pos == 1 then
        --         else
        --             if v.id ~= nil and v.id ~= 0 then
        --                 table.insert(pets, v)
        --             end
        --         end
        --     end
        --     WarriorManager.Instance:send14214(pets, guards)
        -- else
            if base_id == swap_base_id then
                FormationManager.Instance:Send12905(base_id, 0, 0)
            else
                FormationManager.Instance:Send12905(base_id, 1, swap_base_id)
            end
        -- end
    else
        currentSHList[self.guardWarId] = nil
        NoticeManager.Instance:FloatTipsByString(TI18N("该守护已经上阵"))
    end
end

function WarriorDescWindow:FormationSelectListener(index)
    local model = self.model
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()

    self.formationSelect:UnSelect(self.formationSelect.lastSelect)
    local tab = self.formationSelect.selectTab
    if self.formationSelect.lastSelect ~= nil then
        tab[self.formationSelect.lastSelect] = false
    end
    tab[index] = true
    self.formationSelect.lastSelect = index
    self.formationSelect:Select(self.formationSelect.lastSelect)

    local selectIndex = self.formationSelect:GetSelection()

    FormationManager.Instance:Send12901(FormationManager.Instance.formationList[selectIndex].id)
end

function WarriorDescWindow:ClickPet(index)
    self.petWarId = index + 1
    local select_tab = nil
    if self.model.mode == 4 then
        -- 测试代码
        select_tab = {}
        if ((PetManager.Instance.model.battle_petdata or {}).id or 0) > 0 then
            select_tab[(PetManager.Instance.model.battle_petdata or {}).id] = TI18N("<color='#ffff00'>主战</color>")
        end
        if self.model.pos_list[3] ~= nil and self.model.pos_list[3].id ~= nil and self.model.pos_list[3].id > 0 then
            select_tab[self.model.pos_list[3].id] = TI18N("<color='#248813'>辅战</color>")
        end
        if self.model.pos_list[4] ~= nil and self.model.pos_list[4].id ~= nil and self.model.pos_list[4].id > 0 and self.model.pos_list[4].id < 1000 then
            select_tab[self.model.pos_list[4].id] = TI18N("<color='#248813'>辅战</color>")
        end
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, { function() end, function(data) self:SelectPetCallBack(data) end, 1, battle_pet = select_tab, is_need_master = 0})
end

function WarriorDescWindow:SelectPetCallBack(data)
    if data ~= nil then
        if self.model.mode == 4 and self.petWarId ~= 2 then
            local curr_data = PetManager.Instance.model.battle_petdata or {}
            BaseUtils.dump(curr_data, "curr_data")
            BaseUtils.dump(data, "data")
            if curr_data.id == data.id then -- 选中了主战宠
                NoticeManager.Instance:FloatTipsByString(TI18N("该宠物已出战，不能重复选择"))
                return
            end
            if curr_data.base_id == data.base_id then -- 选中了主战宠
                NoticeManager.Instance:FloatTipsByString(TI18N("同类宠物只能上阵一只"))
                return
            end

            local pos_list = {}
            for _,v in pairs(self.model.pos_list) do
                table.insert(pos_list, v)
            end
            local canFind = false
            for i,v in ipairs(pos_list) do
                if v.pos ~= self.petWarId and (PetManager.Instance:GetPetById(v.id) or {}).base_id == (PetManager.Instance:GetPetById(data.id) or {}).base_id then
                    NoticeManager.Instance:FloatTipsByString(TI18N("同类宠物只能同时上场1只"))
                    return
                end
            end
            for i,v in ipairs(pos_list) do
                if v.pos == self.petWarId and v.id == data.id then
                    v.id = 0
                    canFind = true
                    break
                end
            end
            if not canFind then
                for i,v in ipairs(pos_list) do
                    if v.pos == self.petWarId then
                        v.id = data.id
                        canFind = true
                        break
                    end
                end
            end
            if canFind == false then
                table.insert(pos_list, {pos = self.petWarId, id = data.id})
            end

            local pets = {}
            local guards = {}
            for _,v in pairs(pos_list) do
                if v.pos == 5 or v.pos == 6 then
                    -- if v.id ~= nil and v.id ~= 0 then
                    --     table.insert(guards, v)
                    -- end
                elseif v.pos == 1 then
                elseif v.pos == 3 or v.pos == 4 then
                    if v.id ~= nil and v.id ~= 0 then
                        table.insert(pets, v)
                    end
                end
            end
            WarriorManager.Instance:send14214(pets, guards)
        else
            if self.model.mode == 4 then
                local pos_list = {}
                for _,v in pairs(self.model.pos_list) do
                    table.insert(pos_list, v)
                end
                local canFind = false
                for i,v in ipairs(pos_list) do
                    if (PetManager.Instance:GetPetById(v.id) or {}).base_id == (PetManager.Instance:GetPetById(data.id) or {}).base_id then
                        NoticeManager.Instance:FloatTipsByString(TI18N("同类宠物只能同时上场1只"))
                        return
                    end
                end
            end
            PetManager.Instance:Send10501(data.id, 1)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请先选择一只宠物"))
    end
end

function WarriorDescWindow:OnClickFormation()
    self.guardSelect:Hiden()
    if self.formationSelect.isOpen == true then
        self.formationSelect:Hiden()
    else
        self.formationSelect:Show(FormationManager.Instance.formationList, self.model.formation)
    end
end

function WarriorDescWindow:ReloadFormation()
    local formationId = FormationManager.Instance.formationId
    local formationLev = FormationManager.Instance.formationLev
    local formationData = DataFormation.data_list[formationId.."_"..formationLev]
    if formationData ~= nil then
        self.formationText.text = formationData.name.."Lv."..formationLev
    end
end

function WarriorDescWindow:DoRoll()
    if self.speedCounter ~= nil then
        self.speedCounter = self.speedCounter + 1
        if self.speedCounter % 20 == 0 then
            if self.speed > self.slowSpeed then self.speed = self.speed - self.slowSpeed end
        end
    end
    self.actualCounter = self.actualCounter + self.speed
    self.moveCounter = self.actualCounter % 940
    for i,v in ipairs(self.lightList) do
        -- local x = -470 + 235 * i - self.moveCounter
        local x = v.transform.anchoredPosition.x - self.speed
        if x < -470 then
            x = x + 940
        end
        v.transform.anchoredPosition = Vector2(x, 0)
    end

    self:SetLightScale()

    if self.targetCounter > 0 and self.actualCounter >= self.targetCounter then
        self:EndRoll()
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
    end
end

function WarriorDescWindow:BeginRoll()
    self.combatForce.gameObject:SetActive(false)
    self.descArea.gameObject:SetActive(false)
    self.modeArea.gameObject:SetActive(true)
    self.bg1:SetActive(false)
    self.bg2:SetActive(false)
    self.bg:SetActive(true)

    for i,v in ipairs(self.lightList) do
        v.index = i
        v.image.sprite = self.assetWrapper:GetSprite(AssetConfig.warrior_textures, self.model.modeRes[v.index])
        v.transform.anchoredPosition = Vector2(-470 + 235 * i, 0)
        v.transition.enabled = false
        v.btn.enabled = false
    end

    self:SetLightScale()

    if self.rollingEffect ~= nil then
        self.rollingEffect:DeleteMe()
    end
    if self.timerId == nil then
        self.speedCounter = nil
        self.timerId = LuaTimer.Add(0, 10, function() self:DoRoll() end)
    end
end

function WarriorDescWindow:SetLightScale()
    local scale = nil
    for i,v in ipairs(self.lightList) do
        scale = 0.6 + 0.4 * math.exp(-math.abs(v.transform.anchoredPosition.x) / 100)
        v.transform.localScale = Vector3(scale, scale, 1)

        if math.abs(v.transform.anchoredPosition.x) < 100 then
            self.modeTitleText.text = string.format(TI18N("本周勇士战场模式:<color='#00ff00'>%s</color>"), self.model.titleString[i])
        end
    end
end

function WarriorDescWindow:SlowDown()
end

function WarriorDescWindow:DoEnd(index)
    self.endIndex = nil
    for i,v in ipairs(self.lightList) do
        if v.index == index then
            self.endIndex = i
        end
    end
    if self.endIndex == nil then
        return
    end
    local c = math.ceil(self.actualCounter / 940)
    self.targetCounter = (math.ceil(self.actualCounter / 940) + 2) * 940 - 470 + self.endIndex * 235

    local t = 800   -- 约5秒
    local r = t % 20
    local m = math.floor(t / 20)

    self.slowSpeed = ((r + 20 * m) * self.speed - (self.targetCounter - self.actualCounter)) / ((r + 10 * m) * (m + 1))
    -- if self.targetCounter - self.actualCounter > 470 then
    --     self.targetCounter = math.ceil(self.actualCounter / 940) * 940 - 470 + k * 235
    -- end

    if self.targetSpeedUpId ~= nil then
        LuaTimer.Delete(self.targetSpeedUpId)
        self.targetSpeedUpId = nil
    end

    self.speedCounter = 0
end

function WarriorDescWindow:SpeedUp()
    if self.targetSpeedUpId == nil then
        self.speedUpValue = 1

        if self.rollingEffectTimerId ~= nil then
            LuaTimer.Delete(self.rollingEffectTimerId)
        end
        self.rollingEffectTimerId = LuaTimer.Add(2500, function()
            self.rollingEffect = BibleRewardPanel.ShowEffect(20231, self.maskTrans, Vector3(1, 1, 1), Vector3(0, 0, -400))
        end)
        self.targetSpeedUpId = LuaTimer.Add(2000, 100, function()
            self.speedUpValue = 1.5
            if self.speed < 20 then
                self.speed = self.speed + self.speedUpValue
            else
                self.speedUpValue = 1
                LuaTimer.Delete(self.targetSpeedUpId)
                self.targetSpeedUpId = nil
            end
        end)
    end
end

function WarriorDescWindow:EndRoll()
    for i,v in ipairs(self.lightList) do
        v.gameObject:SetActive(i == self.endIndex)
        v.transform.localScale = Vector3.one

        if i == self.endIndex then
            v.transform.anchoredPosition = Vector2(0, 0)
        end
    end
    if self.tweenIdX ~= nil then
        Tween.Instance:Cancel(self.tweenIdX)
    end
    if self.tweenIdY ~= nil then
        Tween.Instance:Cancel(self.tweenIdY)
    end
    if self.rollingEffect ~= nil then
        self.rollingEffect:DeleteMe()
        self.rollingEffect = nil
    end
    if self.confirmEffect ~= nil then
        self.confirmEffect:DeleteMe()
    end
    self.confirmEffect = BibleRewardPanel.ShowEffect(20232, self.maskTrans, Vector3(1, 1, 1), Vector3(0, 0, -400))
    if self.tweenTimerId ~= nil then
        LuaTimer.Delete(self.tweenTimerId)
    end
    self.tweenTimerId = LuaTimer.Add(1000, function()
        self.tweenIdX = Tween.Instance:MoveLocalX(self.lightList[self.endIndex].gameObject, -173, 0.6, function()
                self.descArea:SetActive(true)
                self.combatForce.gameObject:SetActive(true)
                self.modeArea.gameObject:SetActive(false)
                self:Reload()
                self:ReloadDesc()
            end, LeanTweenType.easeOutQuad).id
        self.tweenIdY = Tween.Instance:MoveLocalY(self.maskTrans.gameObject, 28, 0.6, function() end, LeanTweenType.easeOutQuad).id
    end)
end

function WarriorDescWindow:ReloadMode()
    for i,v in ipairs(self.lightList) do
        v.gameObject:SetActive(i == self.endIndex)
    end
    if self.modeMark == nil then
        self.modeMark = self.lightList[self.endIndex]
        self.modeMark.transition.enabled = true
        self.modeMark.btn.enabled = true
    end
    self.modeMark.transform.anchoredPosition = Vector2(-173, 28)
    self.maskTrans.transform.anchoredPosition = Vector2(0, 40)
    self.modeMark.transform.localScale = Vector3.one
    self.modeMark.image.sprite = self.assetWrapper:GetSprite(AssetConfig.warrior_textures, self.model.modeRes[self.model.mode])
end

function WarriorDescWindow:ReloadDesc()
    self.desc1Ext:SetData(self.model.modeString[self.model.mode] or "")
    self.desc2Ext:SetData(string.format(self.model.battleString, self.model.titleString[self.model.mode] or ""))
    self.battleTitle.text = self.model.titleString[self.model.mode] or ""
    self.bg1:SetActive(true)
    self.bg2:SetActive(true)
    self.bg:SetActive(false)

    if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
    end
    self.rotateId = LuaTimer.Add(0, 10, function() self:RotateLight() end)
end

function WarriorDescWindow:ShowMode()
    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("本次勇士战场采用：<color='#00ff00'>%s</color>{face_1,18}"), self.model.titleString[self.model.mode]))
end

function WarriorDescWindow:HideTween()
    WindowManager.Instance:ShowUI(true)
    if self.hidenMoveTweenId ~= nil then
        Tween.Instance:Cancel(self.hidenMoveTweenId)
        self.hidenMoveTweenId = nil
    end
    if self.hidenScaleTweenId ~= nil then
        Tween.Instance:Cancel(self.hidenScaleTweenId)
        self.hidenScaleTweenId = nil
    end

    self.hidenMoveTweenId = Tween.Instance:MoveLocalX(self.gameObject, 400, 0.2, function() self.hidenMoveTweenId = nil self:AfterHide() end).id
    self.hidenScaleTweenId = Tween.Instance:Scale(self.gameObject, Vector3(0.25, 0.25, 1), 0.2, function() self.hidenScaleTweenId = nil self:AfterHide() end).id
end

function WarriorDescWindow:AfterHide()
    if self.hidenMoveTweenId == nil and self.hidenScaleTweenId == nil then
        WindowManager.Instance:CloseWindow(self)
    end
end

function WarriorDescWindow:RotateLight()
    self.rotateCounter = (self.rotateCounter + 0.5) % 360

    if self.lightList[self.endIndex] ~= nil then
        self.lightList[self.endIndex].light.rotation = Quaternion.Euler(0, 0, self.rotateCounter)
    end
end
