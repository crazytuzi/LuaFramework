-- @author 黄耀聪
-- @date 2016年7月13日

SevendayTarget = SevendayTarget or BaseClass(BasePanel)

function SevendayTarget:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "SevendayTarget"
    self.mgr = SevendayManager.Instance

    self.resList = {
        {file = AssetConfig.sevenday_target, type = AssetType.Main},
        {file = AssetConfig.masquerade_textures, type = AssetType.Dep},
    }

    self.itemlist = {}
    self.idToItem = {}

    self.updateTargetListener = function()
        print('-------------------进来刷新了')
        -- self:UpdateTarget()
        self:OnOpen()
    end

    self.layoutSetting = {
        axis = BoxLayoutAxis.Y,
        cspacing = 10,
        border = 5,
    }
    self.itemEffectList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SevendayTarget:__delete()
    if self.itemEffectList ~= nil then
        for _,v in pairs(self.itemEffectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemEffectList = nil
    end
    self.OnHideEvent:Fire()

    if self.idToItem ~= nil then
        for k1,v1 in pairs(self.idToItem) do
            for k2,v2 in pairs(v1.slotList) do
                v2:DeleteMe()
            end
        end
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SevendayTarget:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sevenday_target))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.container = t:Find("ScrollLayer/Container")
    self.cloner = t:Find("ScrollLayer/Cloner").gameObject
    self.scrollTrans = t:Find("ScrollLayer")
    t:Find("ScrollLayer"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged() end)

    self.layout = LuaBoxLayout.New(self.container, self.layoutSetting)
end

function SevendayTarget:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SevendayTarget:OnOpen()
    local model = self.model
    self:RemoveListeners()
    self.mgr.onUpdateTarget:AddListener(self.updateTargetListener)

    local datalist = {}
    for _,v in pairs(model.dayToIds[self.openArgs.day]) do
        if DataGoal.data_goal[v].tabId == DataGoal.data_tab[self.openArgs.day].effect[self.openArgs.tabId - 1].tabId then
            table.insert(datalist, v)
        end
    end
    -- table.sort(datalist, function(a,b)
    --         if model.targetTab[a] == nil or model.targetTab[b] == nil then
    --             if model.targetTab[a] ~= nil then
    --                 return true
    --             elseif model.targetTab[b] ~= nil then
    --                 return false
    --             else
    --                 return DataGoal.data_goal[a].sortIndex < DataGoal.data_goal[b].sortIndex
    --             end
    --         elseif model.targetTab[a].rankValue == model.targetTab[b].rankValue then
    --             return DataGoal.data_goal[a].sortIndex < DataGoal.data_goal[b].sortIndex
    --         else
    --             return model.targetTab[a].rankValue < model.targetTab[b].rankValue
    --         end
    --     end)
    model:AddItems(self.layout, self.container, self.cloner, self.itemlist, datalist, function(cloner) return self:GetObj(cloner) end, function(tab, data) self:SetData(tab, data) end)
end

function SevendayTarget:OnHide()
    self:RemoveListeners()
end

function SevendayTarget:RemoveListeners()
    self.mgr.onUpdateTarget:RemoveListener(self.updateTargetListener)
end

function SevendayTarget:GetObj(cloner)
    local tab = {}
    tab.obj = GameObject.Instantiate(cloner)
    tab.trans = tab.obj.transform
    tab.titleText = tab.trans:Find("Title"):GetComponent(Text)
    -- tab.slot = ItemSlot.New()


    tab.slotList = {}
    tab.Reward = tab.trans:Find("Reward")
    tab.SlotCon = tab.trans:Find("Reward/SlotCon")
    tab.SlotCon.gameObject:SetActive(false)
    -- NumberpadPanel.AddUIChild(tab.trans:Find("Reward"), tab.slot.gameObject)
    tab.data = ItemData.New()
    tab.descText = tab.trans:Find("Desc"):GetComponent(Text)
    tab.descText.gameObject:SetActive(false)
    tab.slider = tab.trans:Find("Slider"):GetComponent(Slider)
    tab.progressText = tab.trans:Find("Slider/Progress"):GetComponent(Text)
    tab.getBtn = tab.trans:Find("Get"):GetComponent(Button)
    tab.gotoBtn = tab.trans:Find("Goto"):GetComponent(Button)
    tab.gotoText = tab.trans:Find("Goto/I18N_Text"):GetComponent(Text)
    tab.receiveObj = tab.trans:Find("ReceivedText").gameObject
    -- tab.extraText = tab.trans:Find("Text"):GetComponent(Text)
    return tab
end

function SevendayTarget:ShowEffect(id, transform, scale, position, time)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = scale
        effectObject.transform.localPosition = position
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        local y = self.layout.panelRect.anchoredPosition.y
        local height = self.scrollTrans.rect.height+20
        local item = effectObject.transform.parent.parent.parent
        effectObject:SetActive(not (-item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height))
    end
    return BaseEffectView.New({effectId = id, time = time, callback = fun})
end

function SevendayTarget:OnValueChanged()
    local y = self.layout.panelRect.anchoredPosition.y
    local height = self.scrollTrans.rect.height+20
    for _,v in pairs(self.itemEffectList) do
        if v ~= nil and v.gameObject ~= nil and not BaseUtils.is_null(v.gameObject) then
            local item = v.gameObject.transform.parent.parent.parent
            v.gameObject:SetActive(not (-item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height))
        end
    end
end

function SevendayTarget:CreateSlot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function SevendayTarget:SetSlotData(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, {_nobutton = true})
    else
        slot:SetAll(cell, {nobutton = _nobutton})
    end
end

function SevendayTarget:SetData(item, data)
    local id = data
    self.idToItem[id] = item

    local basedata = DataGoal.data_goal[id]
    local day = basedata.day
    local protoData = self.model.targetTab[id]
    for i = 1, #item.slotList do
        item.slotList[i].gameObject:SetActive(false)
    end
    for i = 1, #basedata.rewards_commit do
        local slot = item.slotList[i]
        if slot == nil then
            local slotCon = GameObject.Instantiate(item.SlotCon)
            slotCon.gameObject:SetActive(true)
            slotCon.transform:SetParent(item.Reward)
            slotCon.transform.localScale = Vector3.one
            slot = self:CreateSlot(slotCon)
            table.insert(item.slotList, slot)
        end
        slot.gameObject:SetActive(true)
        self:SetSlotData(slot, DataItem.data_get[basedata.rewards_commit[i][1]])
        slot:SetNum(basedata.rewards_commit[i][2])

        --检查一下是否显示特效
        local showEffect = false
        for i=1, #basedata.rewards_effect do
            if basedata.rewards_effect[i][1] == basedata.rewards_commit[i][1] then
                showEffect = true
                break
            end
        end
        if showEffect then
            if self.itemEffectList[string.format("%s_%s", id, basedata.rewards_commit[i][1])] == nil then
                self.itemEffectList[string.format("%s_%s", id, basedata.rewards_commit[i][1])] = self:ShowEffect(20223,slotCon.transform,Vector3(1, 1, 1), Vector3(0, 0, 0))
            end
            local effectObj = self.itemEffectList[string.format("%s_%s", id, basedata.rewards_commit[i][1])]
            if effectObj ~= nil and effectObj.gameObject ~= nil and not BaseUtils.is_null(effectObj.gameObject) then
                local y = self.layout.panelRect.anchoredPosition.y
                local height = self.scrollTrans.rect.height+20
                local item = effectObj.gameObject.transform.parent.parent.parent
                effectObj.gameObject:SetActive(not (-item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height))
            end
        end
    end

    item.descText.text = basedata.desc
    item.titleText.text = basedata.name
    item.progressText.text = ""
    if protoData ~= nil then
        -- BaseUtils.dump(protoData, tostring(id))
        item.slider.gameObject:SetActive(protoData.rewarded ~= 1)
        item.gotoText.text = TI18N("前往")
        if protoData.finish == 1 or protoData.rewarded == 1 then
            -- item.progressText.text = "0/0"
            item.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "0/0")
            item.slider.value = 1
            if #protoData.progress == 0 then
                -- item.progressText.text = "1/1"
                item.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "1/1")
                item.slider.value = 1
            else
                -- item.progressText.text = string.format("%s/%s", ItemSlot.FormatNum(nil, protoData.progress[1].value), ItemSlot.FormatNum(nil, protoData.progress[1].target_val))
                local tempStr = string.format("%s/%s", ItemSlot.FormatNum(nil, protoData.progress[1].value), ItemSlot.FormatNum(nil, protoData.progress[1].target_val))
                item.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, tempStr)
                item.slider.value = 1
            end
        else
            if #protoData.progress == 0 then
                if protoData.finish == 1 then
                    -- item.progressText.text = "1/1"
                    item.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "1/1")
                    item.slider.value = 1
                else
                    -- item.progressText.text = "0/1"
                    item.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "0/1")
                    item.slider.value = 0
                end
            else
                -- item.progressText.text = string.format("%s/%s", ItemSlot.FormatNum(nil, protoData.progress[1].value), ItemSlot.FormatNum(nil, protoData.progress[1].target_val))
                local tempStr = string.format("%s/%s", ItemSlot.FormatNum(nil, protoData.progress[1].value), ItemSlot.FormatNum(nil, protoData.progress[1].target_val))
                item.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, tempStr)
                item.slider.value = protoData.progress[1].value / protoData.progress[1].target_val
            end
        end
        item.getBtn.gameObject:SetActive(protoData.finish == 1 and protoData.rewarded ~= 1)
        item.gotoBtn.gameObject:SetActive(protoData.finish == 0 and protoData.rewarded ~= 1)
        item.receiveObj:SetActive(true)
    else
        item.getBtn.gameObject:SetActive(false)
        item.gotoText.text = string.format(TI18N("%s级开启"), tostring(basedata.lev))
        if #basedata.progress == 0 then
            -- item.progressText.text = "0/1"
            item.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "0/1")
            item.slider.value = 0
        else
            -- item.progressText.text = string.format("0/%s", ItemSlot.FormatNum(nil, basedata.progress[1].target_val))
            local tempStr = string.format("0/%s", ItemSlot.FormatNum(nil, basedata.progress[1].target_val))
            item.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, tempStr)
            item.slider.value = 0
        end
        -- item.gotoBtn.gameObject:SetActive(false)
        item.receiveObj:SetActive(false)
    end

    item.getBtn.onClick:RemoveAllListeners()
    item.getBtn.onClick:AddListener(function() self.mgr:send10236(day, id) end)

    item.gotoBtn.onClick:RemoveAllListeners()
    item.gotoBtn.onClick:AddListener(function() self:OnGoto(id) end)
end

function SevendayTarget:UpdateTarget()
    local model = self.model
    local idList = {}
    if model.dayToIds[self.openArgs] ~= nil then
        for _,v in pairs(model.dayToIds[self.openArgs]) do
            if model.targetTab[v] ~= nil then
                table.insert(idList, v)
            end
        end
    end

    for _,id in pairs(idList) do
        if self.idToItem[id] ~= nil then
            self:SetData(self.idToItem[id], id)
        end
    end
end

function SevendayTarget:OnGoto(id)
    local data = DataGoal.data_goal[id]
    local str = data.action
    if str == "" or RoleManager.Instance.RoleData.lev < data.lev then
        return
    end
    local strList = StringHelper.Split(str, ":")
    local type = strList[1]
    strList = StringHelper.Split(strList[2], ",")
    if type == "1" then
        local args = {}
        for i=2,#strList do
            table.insert(args, tonumber(strList[i]))
        end
        WindowManager.Instance:OpenWindowById(tonumber(strList[1]), args)
    elseif type == "2" then
        QuestManager.Instance.model:FindNpc(strList[1].."_"..strList[2])
        self.model:CloseWindow()
    end
end

