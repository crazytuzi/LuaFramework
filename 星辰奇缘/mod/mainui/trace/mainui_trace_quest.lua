-- -------------------------
-- 任务追踪
-- hosr
-- -------------------------
MainuiTraceQuest = MainuiTraceQuest or BaseClass(BaseTracePanel)

function MainuiTraceQuest:__init(main)
    self.main = main
    self.isInit = false

    self.itemTab = {}
    -- 缓存对象
    self.tempTab = {}

    self.listener = function(list) self:Update(list) end

    self.mainObj = nil

    self.effectPath = "prefabs/effect/20055.unity3d"
    self.effect = nil
    self.effectPathArrow = "prefabs/effect/20009.unity3d"
    self.effectArrow = nil
    self.effectPathBoard = "prefabs/effect/20107.unity3d"
    self.effectBoard = nil

    self.customTab = {}
    self.customId = 0

    self.isInitQuest = false

    self.isEffectShow = false

    self.resList = {
        {file = AssetConfig.task_content, type = AssetType.Main},
        {file = self.effectPathBoard, type = AssetType.Main},
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceQuest:__delete()
    self.OnHideEvent:Fire()
    self.isEffectShow = false
end

function MainuiTraceQuest:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.quest_update, self.listener)
end

function MainuiTraceQuest:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.task_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(-25, -46, 0)

    self.rect = self.gameObject:GetComponent(RectTransform)
    self.baseItem = self.transform:Find("TaskItem").gameObject
    self.container = self.transform:Find("Content").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)
    self.baseItem:SetActive(false)

    self:LoadEffectArrow()
    self:LoadQuest()

    EventMgr.Instance:AddListener(event_name.quest_update, self.listener)

    self.isInit = true
    EventMgr.Instance:Fire(event_name.trace_quest_loaded)
    AgendaManager.Instance:UpdateTrace()
end

function MainuiTraceQuest:LoadEffectArrow()
    --创建加载wrapper
    self.assetWrapperArrow = AssetBatchWrapper.New()

    local func = function()
        if self.assetWrapperArrow == nil then return end
        self.effectArrow = GameObject.Instantiate(self.assetWrapperArrow:GetMainAsset(self.effectPathArrow))
        self.effectArrow.name = "ArrowEffect"
        self.effectArrow.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
        self.effectArrow.transform.localScale = Vector3.one * 0.8
        Utils.ChangeLayersRecursively(self.effectArrow.transform, "UI")
        self.effectArrow:SetActive(false)

        if self.assetWrapperArrow ~= nil then
            self.assetWrapperArrow:DeleteMe()
            self.assetWrapperArrow = nil
        end
    end

    local resList = {
        {file = self.effectPathArrow, type = AssetType.Main},
    }
    self.assetWrapperArrow:LoadAssetBundle(resList, func)
end

function MainuiTraceQuest:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceQuest:OnShow()
    if not self.isInitQuest then
        self:LoadQuest()
    end
end

function MainuiTraceQuest:OnHide()
end

function MainuiTraceQuest:LoadQuest()
    for id,questData in pairs(QuestManager.Instance:GetAll()) do
        if questData.sec_type ~= QuestEumn.TaskType.summer and questData.sec_type ~= QuestEumn.TaskType.sign_draw 
            and questData.sec_type ~= QuestEumn.TaskType.april_treasure
            and questData.sec_type ~= QuestEumn.TaskType.integral_exchange 
            and questData.sec_type ~= QuestEumn.TaskType.war_order then
            local tab = self:CreateItem()
            tab:SetData(questData)
            -- self:SetData(tab, questData)
            self.itemTab[questData.id] = tab
        end
    end
    self:Layout()
    self:PlayEffect(true)
    self.isInitQuest = true
    self.isEffectShow = false
end

function MainuiTraceQuest:CreateItem(noInit)
    if BaseUtils.isnull(self.baseItem) then
        return
    end
    local item = nil
    local tab = nil
    if #self.tempTab > 1 then
        tab = self.tempTab[1]
        table.remove(self.tempTab, 1)
        tab:Reset()
    else
        item = GameObject.Instantiate(self.baseItem)
        tab = TraceQuestItem.New(item, self)
    end

    tab.clickCall = function(id) self:ClickOne(id) end
    tab.downCall = function(id) self:DownOne(id) end
    tab.upCall = function(id) self:UpOne(id) end
    tab.holdCall = function(id) self:HoldOne(id) end

    if noInit then
        -- 不是初始化，添加新增标志用于排序
        tab.isNew = true
    else
        tab.isNew = false
    end

    return tab
end

function MainuiTraceQuest:Update(list)
    self:HideEffectBefore()
    for _,id in ipairs(list) do
        local questData = QuestManager.Instance:GetQuest(id)
        local tab = self.itemTab[id]
        if tab == nil then
            -- 增加新任务
            if questData ~= nil and questData.sec_type ~= QuestEumn.TaskType.summer 
                and questData.sec_type ~= QuestEumn.TaskType.sign_draw 
                and questData.sec_type ~= QuestEumn.TaskType.april_treasure 
                and questData.sec_type ~= QuestEumn.TaskType.integral_exchange 
                and questData.sec_type ~= QuestEumn.TaskType.war_order then
                    tab = self:CreateItem(true)
                    tab:SetData(questData)
                    self.itemTab[questData.id] = tab
            end
        else
            tab:Hide()
            if questData == nil then
                -- 删除任务
                tab.gameObject:SetActive(false)
                if tab.data.sec_type == QuestEumn.TaskType.treasuremap then
                    self.treasuremapItem = nil
                end
                tab.data = nil
                table.insert(self.tempTab, tab)
                self.itemTab[id] = nil
            else
                -- 更新任务
                if tab.finish ~= questData.finish then
                    -- 前后状态不一样才算新的需要排序
                    tab.isNew = true
                end
                tab:SetData(questData)
            end
        end
    end
    self:Layout()
    self:PlayEffect()
end

function MainuiTraceQuest:Sort(isCoustom)
    local list = {}
    local guideList = {}
    local hasOffer = false
    local hasMain = false
    local hasship = false
    local hascycle = false
    local branchList = {}

    local lev = RoleManager.Instance.RoleData.lev
    local tempList = {}
    for k,v in pairs(self.itemTab) do
        local type = v.data.sec_type
        if v.data.type == QuestEumn.TaskTypeSer.main then
            type = QuestEumn.TaskType.main
        end
        if v.data.sec_type == QuestEumn.TaskType.branch then
            table.insert(branchList, {key = k, type = type})
        elseif v.data.sec_type == QuestEumn.TaskType.guide then
            table.insert(guideList, {key = k, type = type})
        elseif v.data.sec_type ~= QuestEumn.TaskType.camp_inquire then
            table.insert(tempList, {key = k, type = type})
        end
    end
    table.sort(tempList, function(a,b) return a.type < b.type end)

    for i,v in ipairs(branchList) do
        table.insert(tempList, v)
    end

    for i,v in ipairs(guideList) do
        table.insert(tempList, v)
    end

    branchList = nil

    guideList = {}
    for i,v in ipairs(tempList) do
        local tab = self.itemTab[v.key]
        local questData = tab.data
        local isNew = tab.isNew
        if questData.sec_type == QuestEumn.TaskType.main and (lev < 16 or (lev >= 20 and lev <= 26)) then
            table.insert(list, 1, tab)
        elseif questData.sec_type == QuestEumn.TaskType.cycle then
            hascycle = true
            if lev >= 16 and lev <= 19 then
                -- 16~19引导职业任务，一直在上面
                table.insert(list, 1, tab)
            else
                table.insert(list, tab)
            end
        elseif questData.sec_type == QuestEumn.TaskType.offer then
            -- 悬赏任务排第一
            hasOffer = true
            table.insert(list, 1, tab)
        elseif questData.sec_type == QuestEumn.TaskType.guide then
            table.insert(guideList, tab)
        elseif questData.sec_type == QuestEumn.TaskType.plant then
            table.insert(list, 1, tab)
        elseif questData.sec_type == QuestEumn.TaskType.shipping then
            table.insert(list, 1, tab)
            hasship = true
        elseif isNew and lev > 20 then
            -- 其他出指引任务外，当前更新的在最上，如果有悬赏任务，就在第二
            if hasOffer or hasship then
                table.insert(list, 2, tab)
            else
                table.insert(list, 1, tab)
            end
        else
            table.insert(list, tab)
        end
        tab.isNew = false
    end

    table.sort(guideList,
               function(a,b)
                    if a.data.finish == a.data.finish then
                        return a.data.id < b.data.id
                    else
                        return a.data.finish > b.data.finish
                    end
               end)
    for i,v in ipairs(guideList) do
        table.insert(list, v)
    end
    guideList = nil

    for k,v in pairs(self.customTab) do
        if v.customData.type == CustomTraceEunm.Type.Activity or v.customData.type == CustomTraceEunm.Type.MainQuest or v.customData.type == CustomTraceEunm.Type.MonthlyCard then
            table.insert(list, 1, v)
        elseif v.customData.type ~= CustomTraceEunm.Type.ActivityShort then
            if hasOffer or hasship or hascycle then
                if isCoustom then
                    table.insert(list, 2, v)
                else
                    table.insert(list, 3, v)
                end
            else
                if isCoustom then
                    table.insert(list, 1, v)
                else
                    table.insert(list, 2, v)
                end
            end
        end
    end

    for k,v in pairs(self.customTab) do
        if v.customData.type == CustomTraceEunm.Type.ActivityShort then
            table.insert(list, 1, v)
        end
    end

    return list
end

function MainuiTraceQuest:Layout(isCoustom)
    local height = 0
    local list = self:Sort(isCoustom)
    for i,tab in ipairs(list) do
        local gameObject = tab.gameObject
        local noShow = tab.noShow
        if not noShow then
            local questData = tab.data
            local rect = tab.rect
            rect.anchoredPosition = Vector2(0, -height)
            rect.sizeDelta = Vector2(222, tab.height)
            height = height + tab.height
            gameObject:SetActive(true)
        else
            gameObject:SetActive(false)
        end
    end
    self.containerRect.sizeDelta = Vector2(230, height)
    if RoleManager.Instance.RoleData.lev >21 then
        self.rect.sizeDelta = Vector2(232, math.min(height + 10, 230))
        self.rect.anchoredPosition = Vector2(0, -46)
        self.containerRect.anchoredPosition = Vector2(0, -46)
    else
        self.rect.sizeDelta = Vector2(284, math.min(height + 10, 230))
        self.rect.anchoredPosition = Vector2(-25, -46)
        self.containerRect.anchoredPosition = Vector2(25, 0)
    end
end

-- 点击某一个
function MainuiTraceQuest:ClickOne(id)
    local tab = self.itemTab[id]
    QuestManager.Instance:DoQuest(tab.data)
    self:HideEffect(tab.data)
    SoundManager.Instance:Play(214)

    AutoFarmManager.Instance:StopAncientDemons()
end

function MainuiTraceQuest:DownOne(id)
end

function MainuiTraceQuest:UpOne(id)
    if self.effectArrow ~= nil then
        self.effectArrow:SetActive(false)
    end
end

function MainuiTraceQuest:HoldOne(id)
    if self.effectArrow ~= nil then
        self.effectArrow:SetActive(false)
    end
end

function MainuiTraceQuest:ShowArrowEffect(transform)
    if self.downId ~= nil then
        LuaTimer.Delete(self.downId)
        self.downId = nil
    end

    if BaseUtils.is_null(transform) then
        return
    end

    if self.effectArrow ~= nil then
        local pos = ctx.UICamera.camera:WorldToScreenPoint(transform.position)

        local scaleWidth = ctx.ScreenWidth
        local scaleHeight = ctx.ScreenHeight
        local origin = 960 / 540
        local currentScale = scaleWidth / scaleHeight
        local newx = 0
        local newy = 0
        local ch = 0
        local cw = 0
        local off_x = 0
        local off_y = 0
        if currentScale > origin then
            -- 以宽为准
            ch = 540
            cw = 960 * currentScale / origin

            newx = pos.x * cw / scaleWidth
            newy = pos.y * ch / scaleHeight
        else
            -- 以高为准
            ch = 540 * origin / currentScale
            cw = 960

            newx = pos.x * cw / scaleWidth
            newy = pos.y * ch / scaleHeight
        end
        pos = Vector3(newx + off_x - cw / 2, newy + off_y - ch / 2, 0)
        self.effectArrow.transform.localPosition = Vector3(pos.x, pos.y, -1000)
        self.effectArrow:SetActive(true)
    end
end

-- 外部调用隐藏或显示摸个
function MainuiTraceQuest:ShowOne(id, bool)
    local tab = self.itemTab[id]
    if tab ~= nil then
        tab.noShow = not bool
        self:Layout()
    end
end

function MainuiTraceQuest:LoadEffect(parent)
    --创建加载wrapper
    if self.assetWrapperBoard ~= nil then
        print("Loading")
        return
    end
    self.assetWrapperBoard = AssetBatchWrapper.New()
    local resList = {{file = self.effectPath, type = AssetType.Main}}
    if RoleManager.Instance.RoleData.lev < 17 then
        table.insert(resList, {file = self.effectPathBoard, type = AssetType.Main})
    end
    self.assetWrapperBoard:LoadAssetBundle(resList, function() self:EffectLoaded(parent) end)
end

function MainuiTraceQuest:EffectLoaded(parent)
    if self.assetWrapperBoard == nil then return end
    self.effect = GameObject.Instantiate(self.assetWrapperBoard:GetMainAsset(self.effectPath))
    self.effect.name = "QuestEffect"
    self.effect.transform:SetParent(parent)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    local rect = parent.gameObject:GetComponent(RectTransform)
    local x = 0.74
    local y = 0.8 * (rect.rect.height / 65)
    self.effect.transform.localScale = Vector3(x, y, 1)
    self.effect.transform.localPosition = Vector3(-81.3, -61.6 - rect.rect.height + 65, -400)
    self.effect:SetActive(true)

    if RoleManager.Instance.RoleData.lev < 17 then
        self.effectBoard = GameObject.Instantiate(self.assetWrapperBoard:GetMainAsset(self.effectPathBoard))
        self.effectBoard.name = "effectPathBoard"
        Utils.ChangeLayersRecursively(self.effectBoard.transform, "UI")
        self.effectBoard.transform.localScale = Vector3.one

        if RoleManager.Instance.RoleData.lev == 15 or RoleManager.Instance.RoleData.lev == 16 then
            self.effectBoard.transform:SetParent(parent)
            Utils.ChangeLayersRecursively(self.effectBoard.transform, "UI")
            self.effectBoard.transform.localScale = Vector3.one
            self.effectBoard.transform.localPosition = Vector3(0, -rect.rect.height/2, -400)
            self.effectBoard:SetActive(true)
        else
            self.effectBoard:SetActive(false)
            self.effectBoard.transform:SetParent(self.transform)
        end
    end

    self.isEffectShow = true

    if self.assetWrapperBoard ~= nil then
        self.assetWrapperBoard:DeleteMe()
        self.assetWrapperBoard = nil
    end
end

function MainuiTraceQuest:PlayEffect(byClick)
    local lev = RoleManager.Instance.RoleData.lev
    if lev > 26 then
        self:HideEffectBefore()
        return
    end
    local parent = nil
    if (lev < 16 or (lev >= 20 and lev <= 26)) then --and byClick then
        -- 主线
        parent = self.mainObj
        if parent == nil then
            parent = self:GetCustom(QuestManager.Instance:GetNoticeItemId())
        end
    elseif lev >= 16 and lev < 20 then
        -- 职业
        parent = self.cycleObj
    end
    if BaseUtils.is_null(parent) then
        return
    end
    if TeamManager.Instance:MemberCount() > 1 then
        -- 队伍人数超过1个就不引导了
        self:HideEffectBefore()
        return
    end
    parent = parent.transform
    if self.effect == nil then
        self:LoadEffect(parent)
    else
        if not self.isEffectShow then
            self.effect.transform:SetParent(parent)
            local rect = parent.gameObject:GetComponent(RectTransform)
            local x = 0.74
            local y = 0.8 * (rect.rect.height / 65)
            self.effect.transform.localScale = Vector3(x, y, 1)
            self.effect.transform.localPosition = Vector3(-81.3, -61.6 - rect.rect.height + 65, -400)
            self.effect:SetActive(false)
            self.effect:SetActive(true)

            if RoleManager.Instance.RoleData.lev == 15 or RoleManager.Instance.RoleData.lev == 16 then
                if not BaseUtils.is_null(self.effectBoard) then
                    self.effectBoard.transform:SetParent(parent)
                    self.effectBoard.transform.localScale = Vector3.one
                    self.effectBoard.transform.localPosition = Vector3(0, -rect.rect.height/2, -400)
                    self.effectBoard:SetActive(false)
                    self.effectBoard:SetActive(true)
                end
            end

            self.isEffectShow = true
        end
    end
end

function MainuiTraceQuest:HideEffect(data)
    local lev = RoleManager.Instance.RoleData.lev
    local hide = false
    if lev < 16 or (lev >= 20 and lev <= 26) then
        -- 主线
        if data.type == QuestEumn.TaskTypeSer.main then
            hide = true
        end
    elseif lev >= 16 and lev < 20 then
        -- 职业
        if data.sec_type == QuestEumn.TaskType.cycle then
            hide = true
        end
    end

    if hide then
        self.isEffectShow = false
        if not BaseUtils.is_null(self.effect) then
            self.effect:SetActive(false)
            self.effect.transform:SetParent(self.transform)
        end

        if not BaseUtils.is_null(self.effectBoard) then
            self.effectBoard:SetActive(false)
            self.effectBoard.transform:SetParent(self.transform)
        end
    end
end

function MainuiTraceQuest:HideEffectBefore()
    self.isEffectShow = false
    if not BaseUtils.is_null(self.effect) then
        self.effect:SetActive(false)
        self.effect.transform:SetParent(self.transform)
    end
    if not BaseUtils.is_null(self.effectBoard) then
        self.effectBoard:SetActive(false)
        self.effectBoard.transform:SetParent(self.transform)
    end
end

-- -----------------------------------
-- 外部调用，添加自定义项目到追踪
-- 此类型项目由外部自己控制增删改
-- -----------------------------------
function MainuiTraceQuest:GetCustom(customId)
    local tab = self.customTab[customId]
    if tab ~= nil then
        return tab.gameObject
    end
    return nil
end

function MainuiTraceQuest:AddCustom(force_effect)
    self.customId = self.customId + 1

    local customData = CustomTraceData.New()
    customData.customId = self.customId

    local tab = self:CreateItem()
    tab.data = customData
    self.customTab[self.customId] = tab

    if force_effect then
        self.isEffectShow = true
        self:LoadEffect(tab.gameObject.transform)
    end

    return customData, tab
end

function MainuiTraceQuest:UpdateCustom(customData)
    local tab = self.customTab[customData.customId]

    self:SetCustomData(tab, customData)
    self:Layout()
end

function MainuiTraceQuest:DeleteCustom(customId, force_effect)
    local tab = self.customTab[customId]
    if tab ~= nil then
        tab.gameObject:SetActive(false)
        tab.data = nil
        table.insert(self.tempTab, tab)
        self.customTab[customId] = nil
        self:Layout()
    end
    if force_effect then
        if self.effect ~= nil then
            self.isEffectShow = false
            self.effect:SetActive(false)
            self.effect.transform:SetParent(self.transform)
        end
    end
end

function MainuiTraceQuest:SetCustomData(tab, customData)
    if tab == nil then
        return
    end

    tab:SetCustomData(customData)
    -- tab.noShow = false
    -- tab.customData = customData
    -- tab.name.text = string.format("<color='#ffcc66'>%s</color>", customData.title)
    -- tab.desc.text = customData.Desc
    -- tab.height = 65
    -- tab.fight.gameObject:SetActive(customData.fight == true)
    -- tab.succ.gameObject:SetActive(customData.finish == true)
    -- tab.btnScript.onClick:RemoveAllListeners()
    -- tab.btnScript.onDown:RemoveAllListeners()
    -- tab.btnScript.onUp:RemoveAllListeners()
    -- local id = customData.customId
    -- tab.btnScript.onClick:AddListener(function() self:ClickCustomOne(id) end)
    -- tab.btnScript.onDown:AddListener(function() self:DownCustomOne(id) end)
    -- tab.btnScript.onUp:AddListener(function() self:UpCustomOne(id) end)
    -- tab.btnScript.onHold:AddListener(function() self:HoldCustomOne(id) end)
    -- local descHeight = tab.desc.preferredHeight
    -- tab.desc.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(200, descHeight)
    -- local height = 5 + 25 + descHeight + 6 + 10
    -- tab.height = height
end

function MainuiTraceQuest:ClickCustomOne(id)
    local tab = self.customTab[id]
    print("点击任务追踪导致自动停止")
    AutoQuestManager.Instance.disabledAutoQuest:Fire() -- 玩家也可能会点到这些custom追踪这时候也要关闭自动历练和自动职业的开关 by 嘉俊 2017/8/31 11:46
    if tab ~= nil then
        if tab.customData.callback ~= nil then
            tab.customData.callback()
        end
    end
end

function MainuiTraceQuest:DownCustomOne(id)
    local tab = self.customTab[id]
    if tab ~= nil then
        tab.select:SetActive(true)
        tab.select_rect.sizeDelta = Vector2(224, tab.height + 2)
        if not BaseUtils.is_null(tab.gameObject) then
            self.downId = LuaTimer.Add(200, function() self:ShowArrowEffect(tab.gameObject.transform) end)
        end
    end
end

function MainuiTraceQuest:UpCustomOne(id)
    if self.downId ~= nil then
        LuaTimer.Delete(self.downId)
        self.downId = nil
    end
    local tab = self.customTab[id]
    if tab ~= nil then
        tab.select:SetActive(false)
    end
    if self.effectArrow ~= nil then
        self.effectArrow:SetActive(false)
    end
end

function MainuiTraceQuest:HoldCustomOne(id)
    local tab = self.customTab[id]
    if tab ~= nil then
        tab.select:SetActive(false)
        if self.effectArrow ~= nil then
            self.effectArrow:SetActive(false)
        end
        if tab.customData.callback ~= nil then
            tab.customData.callback()
        end
    end
end

function MainuiTraceQuest:ClearAll()
    if self.effect ~= nil then
        self.effect:SetActive(false)
        self.effect.transform:SetParent(self.transform)
    end
    for k,item in pairs(self.itemTab) do
        item:Hide()
        GameObject.DestroyImmediate(item.gameObject)
    end
    self.itemTab = {}
    self.tempTab = {}

    self.mainObj = nil

    for k,item in pairs(self.customTab) do
        item:Hide()
        GameObject.DestroyImmediate(item.gameObject)
    end
    self.customTab = {}
    self.customId = 0

    self.treasuremapItem = nil
end

function MainuiTraceQuest:CheckTreasuremapFinish()
    -- if DataAgenda.data_list[1011].engaged ~= nil then
    --     local num = 10 - DataAgenda.data_list[1011].engaged
    --     return num == 0
    -- end
    -- return false
    return false
end

function MainuiTraceQuest:HideTreasuremap()
    if self:CheckTreasuremapFinish() then
        if self.treasuremapItem ~= nil then
            self.treasuremapItem.noShow = true
            self:Layout()
        end
    end
end
