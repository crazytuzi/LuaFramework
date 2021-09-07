BibleGrowguildPanel = BibleGrowguildPanel or BaseClass(BasePanel)

function BibleGrowguildPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.resList = {
        {file = AssetConfig.bible_grow_panel, type = AssetType.Main}
        , {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
        , {file = AssetConfig.teacher_textures, type = AssetType.Dep}
    }

    self.tabGroupObjList = {}
    self.tabGroupNormalText = {}
    self.tabGroupSelectText = {}
    self.taskList = {}

    self.listener = function(data)
        local hasGuild = false
        for k,v in pairs(data) do
            if DataQuest.data_get[v].sec_type == QuestEumn.TaskType.guide then
                hasGuild = true
                break
            end
        end
        if self.currentIndex ~= nil and hasGuild == true then
            self.model:AnalyQuestList()
            self:ReloadTaskList(self.currentIndex, 1)
        end

        self.mgr.onUpdateRedPoint:Fire()
    end

    self.roleLevelChangeListener = function()
        if self.currentIndex ~= nil then
            self.model:AnalyQuestList()
            self:ReloadTaskList(self.currentIndex)
        end
    end

    self.redPointListener = function() self:CheckRedPoint() end
    self.totalListener = function(a) self:TotalBtnReply(a) end
    self.updateStatusList = function() self:UpdateMyStatusList() end

    self.OnOpenEvent:AddListener(function()
        self:OnOpen()
    end)
    self.OnHideEvent:AddListener(function()
        self:OnHide()
    end)

    self.model:AnalyQuestList()

    -- 状态列表
    self.questStatusList = {}
    -- 是否已经接受过了额外奖励
    self.IsAccetTotalList = {}
    self.totalItemSlotList = {}
    -- 当前等级的任务是否完全完成
    self.IsCompleteTotal = false

    self.totalQuest =0
    self.CompletedQuest = 0

    self.isInit = false
    self.extra = {inbag = false, nobutton = true}
end

function BibleGrowguildPanel:InitPanel()
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_grow_panel))
    self.gameObject.name = "GrowguidePanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    -- self.transform = model.bibleWin.transform:Find("Main/GrowguidePanel")
    self.transform = self.gameObject.transform

    self.container = self.transform:Find("Bg/Scroll/Container")
    self.containerRect = self.container:GetComponent(RectTransform)
    self.layout = LuaBoxLayout.New(self.container.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 5})
    self.taskTemplate = self.container:Find("Task").gameObject
    self.templateSize = self.taskTemplate:GetComponent(RectTransform).sizeDelta
    self.taskTemplate.transform:Find("HasGet"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.teacher_textures, "I18NComplete")
    self.taskTemplate:SetActive(false)
    self.taskObjList = {}
    self.scrollHeight = self.transform:Find("Bg"):GetComponent(RectTransform).sizeDelta.y

    self.tabGroupObj = self.transform:FindChild("MaskLayer/TabButtonGroup")
    self.tabCloner = self.transform:Find("MaskLayer/Clone").gameObject
    self.tabCloner:SetActive(false)

    --获取额外奖励需要的组件
    self.totalTaskTemplate = self.transform:Find("Bg/TotalTask")
    self.totalHasGet = self.totalTaskTemplate:Find("HasGet")
    self.totalHasGet:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.teacher_textures,"I18NComplete")
    self.totalActive = self.totalTaskTemplate:Find("Active")
    self.totalActiveEffect = BibleRewardPanel.ShowEffect(20053,self.totalActive.transform,Vector3(1.6, 0.8, 1),Vector3(-52, -19, -400))
    self.totalActiveRedPoint = self.totalTaskTemplate:Find("Active/RedPoint")
    self.totalNotCompleted = self.totalTaskTemplate:Find("NotCompleted")
    self.iconContainer = self.totalTaskTemplate:Find("IconContainer")
    self.iconContainerRect = self.iconContainer:GetComponent(RectTransform)
    self.iconTaskTemplateObj = self.totalTaskTemplate:Find("IconContainer/Icon").gameObject
    self.iconTaskTemplateObj.gameObject:SetActive(false)
    self.totalSlider = self.totalTaskTemplate:Find("ExpSlider"):GetComponent(Slider)
    self.totalText = self.totalTaskTemplate:Find("ExpValue"):GetComponent(Text)
    self.totalBtn = self.totalTaskTemplate:Find("Active"):GetComponent(Button)
    self.totalBtn.onClick:AddListener(function() self:TotalBtnRequire() end)
    self.totalIconLayout = LuaBoxLayout.New(self.iconContainer.gameObject, {axis = BoxLayoutAxis.X, cspacing = 5})
    -- self.totalTemplateSize = self.totalTaskTemplate:GetComponent(RectTransform).sizeDelta


    local rect = self.tabCloner:GetComponent(RectTransform)
    rect.pivot = Vector2(0,1)
    rect.anchoredPosition = Vector2(0, 0)

    self.tabGroupSetting = {
        notAutoSelect = true,
        openLevel = {0, 0},
        perWidth = 158,
        perHeight = 60,
        isVertical = true,
        spacing = 0
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, self.tabGroupSetting)
    self.IsAccetTotalList = BibleManager.Instance:GetTotalStatusData()
    if self.IsAccetTotalList == nil then
        self.IsAccetTotalList = {}
    end
    self:ReloadTabGroup()

    self.OnOpenEvent:Fire()
end

function BibleGrowguildPanel:ReloadTabGroup()
    local openLevel = {}
    -- BaseUtils.dump(self.model.guideQuestListForShow, "====================")
    for i,v in ipairs(self.model.guideQuestListForShow) do
        if self.tabGroupObjList[i] == nil then
            self.tabGroupObjList[i] = GameObject.Instantiate(self.tabCloner)
            self.tabGroupNormalText[i] = self.tabGroupObjList[i].transform:Find("Normal/Text"):GetComponent(Text)
            self.tabGroupSelectText[i] = self.tabGroupObjList[i].transform:Find("Select/Text"):GetComponent(Text)
            self.tabGroupObjList[i].name = tostring(i)

            -- 初始化任务状态列表
            if self.questStatusList[i] == nil then
                 self.questStatusList[i] = {}
            end
        end
        local obj = self.tabGroupObjList[i]
        local msg = ""
        if v.key == 1 then
            msg = TI18N("1级~9级")
            openLevel[i] = 1
        else
            msg = string.format(TI18N("%s级~%s级"), tostring((v.key - 1) * 10), tostring(v.key * 10 - 1))
            openLevel[i] = (v.key - 1) * 10
        end
        obj:GetComponent(Button).onClick:RemoveAllListeners()
        obj.transform:SetParent(self.tabGroupObj.transform)
        self.tabGroupNormalText[i].text = msg
        self.tabGroupSelectText[i].text = msg
        obj.transform.localScale = Vector3.one
        local rect = obj:GetComponent(RectTransform)
        rect.pivot = Vector2(0,0.5)
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
    end
    self.tabGroupSetting.openLevel = openLevel
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, self.tabGroupSetting)
    -- self.tabGroup:Init()
end

function BibleGrowguildPanel:ChangeTab(index)
     self.CompletedQuest = 0
     if self.totalItemSlotList ~= nil then
        for i,v in ipairs(self.totalItemSlotList) do
            self.totalItemSlotList[i].gameObject:SetActive(false)
        end
    end

    self.isInit = false
    BibleManager.Instance.redPointDic[2][self.model.guideQuestListForShow[index].key] = false
    self.mgr.onUpdateRedPoint:Fire()
    self.currentIndex = index
    self:ReloadTaskList(index, 2)
    self:HideForCompleteTotal()
    self:SetCompleteTotalFirst()
    self.isInit = true
end

function BibleGrowguildPanel:OnHide()
    self:RemoveListener()

    if self.totalItemSlotList ~= nil then
        for i,v in ipairs(self.totalItemSlotList) do
            self.totalItemSlotList[i].gameObject:SetActive(false)
        end
    end
end

function BibleGrowguildPanel:__delete()
    self.OnHideEvent:Fire()
    if self.totalActiveEffect ~= nil then
       self.totalActiveEffect:DeleteMe()
    end

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.totalIconLayout ~= nil then
        self.totalIconLayout:DeleteMe()
    end

    if self.totalItemSlotList ~= nil then
        for i,v in ipairs(self.totalItemSlotList) do
            v:DeleteMe()
        end
    end
    if self.taskList ~= nil then
        for _,task in pairs(self.taskList) do
            if task.rewardList ~= nil then
                for _,reward in pairs(task.rewardList) do
                    reward.imageLoader:DeleteMe()
                end
            end
        end
        self.taskList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

-- index 等级段
-- doLocate 1:进行定位，如果找不到定位点，则不动
--          2:进行定位，如果找不到定位点，则定位到0
function BibleGrowguildPanel:ReloadTaskList(index, doLocate)
    self.CompletedQuest = 0
    self.firstReceivablePos = -1
    local quests = self.model.guideQuestListForShow[index].value
    local questList = {}
    local world_lev = RoleManager.Instance.world_lev
    for i,v in ipairs(quests) do
        if v.id == 41012 then
            if world_lev >= 45 then
                table.insert(questList, v)
            end
        else
            table.insert(questList, v)
        end
        -- table.insert(questList, v)
    end
     -- if self.isInit == false then
     --    self.isInit = true
     --    self.layout:AddCell(self.totalTaskTemplate.gameObject)
     -- end

    self.totalQuest = #questList
    for i,v in ipairs(questList) do
        if self.taskObjList[i] == nil then
            self.taskObjList[i] = GameObject.Instantiate(self.taskTemplate)
            self.taskObjList[i].name = tostring(i)
            self.layout:AddCell(self.taskObjList[i])
        end
        local obj = self.taskObjList[i]
        local tab = self.taskList[i]
        if tab == nil then
            tab = {}
            tab.obj = obj
            tab.transform = obj.transform
            self.taskList[i] = tab
        end
        self:SetItem(DataQuest.data_get[v.id], i)
        obj:SetActive(true)
    end
    for i=#questList + 1, #self.taskObjList do
        self.taskObjList[i]:SetActive(false)
    end

    self.containerRect.sizeDelta = Vector2(self.templateSize.x, self.templateSize.y * #questList)
    -- self.layout:OnScroll(self.containerRect.sizeDelta, Vector2.zero)

    if doLocate == 1 then
        if self.firstReceivablePos >= 0 then
            if self.containerRect.sizeDelta.y < self.scrollHeight then
                self.firstReceivablePos = 0
            elseif self.containerRect.sizeDelta.y - self.firstReceivablePos < self.scrollHeight then
                self.firstReceivablePos = self.containerRect.sizeDelta.y - self.scrollHeight
            end
            self.containerRect.anchoredPosition = Vector2(0, self.firstReceivablePos)
        end
    elseif doLocate == 2 then
        if self.firstReceivablePos >= 0 then
            if self.containerRect.sizeDelta.y < self.scrollHeight then
                self.firstReceivablePos = 0
            elseif self.containerRect.sizeDelta.y - self.firstReceivablePos < self.scrollHeight then
                self.firstReceivablePos = self.containerRect.sizeDelta.y - self.scrollHeight
            end
        else
            self.firstReceivablePos = 0
        end
        self.containerRect.anchoredPosition = Vector2(0, self.firstReceivablePos)
    end
end

function BibleGrowguildPanel:SetItem(data, i)
    local obj = self.taskList[i].obj
    local t = obj.transform
    local nameText = t:Find("Name"):GetComponent(Text)
    local iconImage = t:Find("Icon/Image"):GetComponent(Image)

    nameText.text = data.name
    iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(data.iconId))

    -- BaseUtils.dump(data.rewards_commit, "奖励列表 "..data.name)
    self:AddRewardToItem(data.rewards_commit, i)
    self:UpdateItem(data, obj)

    local btn = t:Find("Active"):GetComponent(Button)
    local quest = BaseUtils.copytab(QuestManager.Instance.questTab[data.id])

    -- 加入任务状态列表
    if quest ~= nil then
      if self.questStatusList[self.currentIndex][data.id] == nil then
        self.questStatusList[self.currentIndex][data.id] = {}
      end
      self.questStatusList[self.currentIndex][data.id].quest = quest
    end

    local lev = data.lev
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function()
        if quest ~= nil then
            self:DoQuest(quest)
        else
            if data.find_break_lev > 0 then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("需<color='#00ff00'>突破后</color>达到<color='#00ff00'>%s级</color>才行哦"), tostring(data.lev)))
            else
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("达到<color='#00ff00'>%s级</color>才行哦"), tostring(data.lev)))
            end
        end
    end)
end

function BibleGrowguildPanel:DoQuest(quest)
    if self.waiting ~= true then
        if quest.finish == QuestEumn.TaskStatus.Finish then
            if quest.progress ~= nil and #quest.progress == 0 then
                -- 拜访任务提交
                self.model:CloseWindow()
                QuestManager.Instance.model:FindNpc(BaseUtils.get_unique_npcid(quest.npc_commit_id, quest.npc_commit_battle))
            else
                -- 完成直接提交
                QuestManager.Instance:Send10206(quest.id)
                self.waiting = true
                LuaTimer.Add(500, function() self.waiting = false end)
            end
        else
            self.model:CloseWindow()
            QuestManager.Instance:DoQuest(quest)
        end
    end
end

function BibleGrowguildPanel:UpdateItem(data, obj)
    local t = obj.transform
    local descText = t:Find("Desc"):GetComponent(Text)
    local btnText = t:Find("Active/Text"):GetComponent(Text)
    local btnImage = t:Find("Active"):GetComponent(Image)
    local toggle = t:Find("Toggle"):GetComponent(Toggle)
    local btn = t:Find("Active"):GetComponent(Button)
    local label = t:Find("Label").gameObject
    local hasGetObj = t:Find("HasGet").gameObject
    local redPointObj = t:Find("Active/RedPoint").gameObject

    local progressSer = data.progress_ser
    local progress = data.progress
    local progressId = 0

    descText.horizontalOverflow = 1

    if progressSer ~= nil then
        for i=1,#progressSer do
            if progressSer[i].finish == 0 then
                progressId = i
                break
            end
        end
        if progressId == 0 then
            progressId = 1
        end

        local desc = BaseUtils.match_between_symbols(progress[progressId].desc, "%[", "%]")[1]
        desc = string.gsub(desc, "<.->", "")
        -- print(desc)
        if progressSer[progressId].target_val == 0 then
            descText.text = desc
        else
            descText.text = string.format("%s(%s/%s)", desc, tostring(progressSer[progressId].value), tostring(progressSer[progressId].target_val))
        end

        if desc == nil or desc == "[]" then
            descText.text = data.trace_msg
        end
    else
        if #progress > 0 then
            local desc = BaseUtils.match_between_symbols(progress[1].desc, "%[", "%]")[1]
            desc = string.gsub(desc, "<.->", "")
            if desc == nil or desc == "[]" then
                descText.text = data.trace_msg
            else
                descText.text = desc
            end
        else    -- 拜访任务
            descText.text = data.trace_msg
        end
    end

    local quest = BaseUtils.copytab(QuestManager.Instance.questTab[data.id])
    if quest == nil then
        quest = {finish = 1, follow = 0}
    end

    btn.gameObject:SetActive(true)
    hasGetObj:SetActive(false)
    redPointObj:SetActive(false)
    if quest.progress ~= nil then
        local isVisit = #quest.progress == 0
        label:SetActive(false)
        toggle.gameObject:SetActive(true)
        btn.enabled = true
        if quest.finish == 2 then
            if isVisit then
                --拜访
                btnText.text = string.format(TI18N("<color=%s>前 往</color>"), ColorHelper.ButtonLabelColor.Blue)
                btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            else
                if self.firstReceivablePos < 0 then
                    self.firstReceivablePos = 0 - obj:GetComponent(RectTransform).anchoredPosition.y
                end
                redPointObj:SetActive(true)
                btnText.text = string.format(TI18N("<color=%s>领 取</color>"), ColorHelper.ButtonLabelColor.Orange)
                btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            end
        else
            btnText.text = string.format(TI18N("<color=%s>前 往</color>"), ColorHelper.ButtonLabelColor.Blue)
            btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        end
        local preQuest = QuestManager.Instance.questTab[data.pre_quest_client]
        if preQuest ~= nil then
            toggle.gameObject:SetActive(false)
        end
    else
        toggle.gameObject:SetActive(false)
        if data.find_break_lev > 0 then
            if RoleManager.Instance.RoleData.lev < data.lev or RoleManager.Instance.RoleData.lev_break_times < data.find_break_lev then
                btn.enabled = true
                label:SetActive(false)
                btnText.text = string.format(TI18N("<color=%s>前 往</color>"), ColorHelper.ButtonLabelColor.Blue)
                btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            else
                label:SetActive(true)
                btn.gameObject:SetActive(false)
                hasGetObj:SetActive(true)
                self.CompletedQuest = self.CompletedQuest + 1
                if self.questStatusList[self.currentIndex][data.id] ~= nil then
                    self.questStatusList[self.currentIndex][data.id] = nil
                end
                if self.isInit == true then
                  self:CheckCompleteTotal()
                  self:UpdateCompleteTotal()
                end
            end
        else
            if RoleManager.Instance.RoleData.lev < data.lev then
                btn.enabled = true
                label:SetActive(false)
                btnText.text = string.format(TI18N("<color=%s>前 往</color>"), ColorHelper.ButtonLabelColor.Blue)
                btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            else
                self.CompletedQuest = self.CompletedQuest + 1
                label:SetActive(true)
                btn.gameObject:SetActive(false)
                hasGetObj:SetActive(true)
                if self.questStatusList[self.currentIndex][data.id] ~= nil then
                    self.questStatusList[self.currentIndex][data.id] = nil
                end
                 if self.isInit == true then
                  self:CheckCompleteTotal()
                  self:UpdateCompleteTotal()
                end
            end
        end
    end

    toggle.onValueChanged:RemoveAllListeners()
    toggle.isOn = (quest.follow == 1)

    toggle.onValueChanged:AddListener(function(status) self:OnCheck(quest, status) end)
end

function BibleGrowguildPanel:AddRewardToItem(rewardList, index)
    local container = self.taskList[index].transform:Find("Reward/Text/Container")
    local template = container:Find("RewardItem").gameObject
    local w = template.transform:Find("Image"):GetComponent(RectTransform).sizeDelta.x
    template:SetActive(false)

    local childCount = container.childCount - 1
    for i=1,childCount do
        container:Find(tostring(i)).gameObject:SetActive(false)
    end

    local l = #rewardList
    self.taskList[index].rewardList = self.taskList[index].rewardList or {}
    local list = self.taskList[index].rewardList
    for i=1,l do
        local tab = list[i]
        if tab == nil then
            tab = {}
            tab.obj = GameObject.Instantiate(template)
            NumberpadPanel.AddUIChild(container.gameObject, tab.obj)
            tab.obj.name = tostring(i)
            tab.transform = tab.obj.transform
            tab.imageLoader = SingleIconLoader.New(tab.transform:Find("Image").gameObject)
            tab.text = tab.transform:Find("Text"):GetComponent(Text)
            list[i] = tab
        end
        local data = QuestEumn.AwardItemInfo(rewardList[i])
        tab.obj:SetActive(true)
        if data ~= nil then
            tab.imageLoader:SetSprite(SingleIconType.Item, DataItem.data_get[data.baseid].icon)
            tab.text.text = "×"..data.count
        else
            tab.obj:SetActive(false)
        end
    end
    for i=l+1,#list do
        list[i].obj:SetActive(false)
    end

    local x = 0
    local y = 0
    for i=1,l do
        list[i].transform.anchoredPosition = Vector2(x, y)
        x = x + list[i].text.preferredWidth + w + 5
    end

    x = x + self.taskList[index].transform:Find("Reward/Text").sizeDelta.x
    x = x / 2
    self.taskList[index].transform:Find("Reward/Text").anchoredPosition = Vector2(-x, 0)
end

function BibleGrowguildPanel:OnCheck(questData, status)
    local quest = QuestManager.Instance.questTab[questData.id]
    if questData ~= nil and quest ~= nil then
        if status == true then
            quest.follow = 1
        else
            quest.follow = 0
        end
        MainUIManager.Instance:HideOrShowQuest(questData.id, status)
    end
end

function BibleGrowguildPanel:RemoveListener()
    EventMgr.Instance:RemoveListener(event_name.quest_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.roleLevelChangeListener)
    self.mgr.onUpdateRedPoint:RemoveListener(self.redPointListener)
    self.mgr.onUpdateTotal:RemoveListener(self.totalListener)
    self.mgr.onUpdateStatusList:RemoveListener(self.updateStatusList)
end

function BibleGrowguildPanel:OnOpen()
    self.questUpdateList = nil
    self:RemoveListener()
    EventMgr.Instance:AddListener(event_name.quest_update, self.listener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.roleLevelChangeListener)
    self.mgr.onUpdateRedPoint:AddListener(self.redPointListener)
    self.mgr.onUpdateTotal:AddListener(self.totalListener)
    self.mgr.onUpdateStatusList:AddListener(self.updateStatusList)

    self.model:AnalyQuestList()

    self.currentIndex = 1
    local targetId = self.model.currentSub
    if targetId ~= nil then
        if DataQuest.data_get[targetId] ~= nil then
            self.currentIndex = self.model.partToShowIndex[math.ceil((DataQuest.data_get[targetId].lev + 1) / 10)]
        end
    end
    -- self:ReloadTaskList()
    if self.tabGroup ~= nil then
        if self.tabGroup.currentIndex > 0 then
            self.tabGroup:UnSelect(self.tabGroup.currentIndex)
            self.tabGroup.currentIndex = 0
        end
        self.tabGroup:ChangeTab(self.currentIndex)
    end

    -- 处理第一次的额外奖励
    self:SetCompleteTotalFirst()
end

function BibleGrowguildPanel:CheckRedPoint()

    local partToShowIndex = self.model.partToShowIndex
    for k,v in pairs(BibleManager.Instance.redPointDic[2]) do
        if v ~= nil and partToShowIndex[k] ~= nil then
            self.tabGroup.buttonTab[partToShowIndex[k]].red:SetActive(v)
        end
    end
end

function BibleGrowguildPanel:CheckCompleteTotal()
     self.IsAccetTotalList = BibleManager.Instance:GetTotalStatusData()
    -- IsAccetTotalList是一开始获得的表
    self.IsCompleteTotal = true
     -- local notCompeletedQuest = 0

     -- BaseUtils.dump(self.questStatusList[self.currentIndex], "打印数据")
     -- for k,v in pairs(self.questStatusList[self.currentIndex]) do
     --     notCompeletedQuest = notCompeletedQuest + 1
     -- end

     -- self.CompletedQuest = self.totalQuest - notCompeletedQuest

     if self.CompletedQuest < self.totalQuest then
        self.IsCompleteTotal = false
     end

     if self.IsAccetTotalList ~= nil and self.IsAccetTotalList[self.currentIndex + 1] == nil then
        -- BaseUtils.dump(self.questStatusList[self.currentIndex],"总数据")
        if self.IsCompleteTotal == true then
            self.totalHasGet.gameObject:SetActive(false)
            self.totalActive.gameObject:SetActive(true)
            self.totalActiveEffect:SetActive(true)
            self.totalNotCompleted.gameObject:SetActive(false)
            self.totalText.gameObject:SetActive(false)
            self.totalSlider.gameObject:SetActive(false)
            BibleManager.Instance.redPointDic[2][self.currentIndex + 1] = true
            -- self.totalActiveRedPoint.gameObject:SetActive(true)
        else
            self.totalHasGet.gameObject:SetActive(false)
            self.totalActive.gameObject:SetActive(false)
            self.totalActiveEffect:SetActive(false)
            self.totalNotCompleted.gameObject:SetActive(true)
            self.totalText.gameObject:SetActive(true)
            self.totalSlider.gameObject:SetActive(true)
        end
    else
            self.totalHasGet.gameObject:SetActive(true)
            self.totalActive.gameObject:SetActive(false)
            self.totalActiveRedPoint.gameObject:SetActive(false)
            self.totalActiveEffect:SetActive(false)
            self.totalNotCompleted.gameObject:SetActive(false)
             self.totalText.gameObject:SetActive(false)
            self.totalSlider.gameObject:SetActive(false)
            BibleManager.Instance.redPointDic[2][self.currentIndex + 1] = false
            self.totalActiveRedPoint.gameObject:SetActive(false)
    end

    BibleManager.Instance.onUpdateRedPoint:Fire()


end

function BibleGrowguildPanel:UpdateCompleteTotal()
    self.totalSlider.value = self.CompletedQuest / self.totalQuest
    self.totalText.text = self.CompletedQuest .. "/" .. self.totalQuest
end

function BibleGrowguildPanel:SetCompleteTotalFirst()
     local dataList = DataQuest.data_reward[self.currentIndex + 1]
     local reward = dataList.reward

     -- 处理图片排列P
     for i=1,#reward do
         local slot
         local Id = reward[i][1]
         local itemData = DataItem.data_get[Id]
         if self.totalItemSlotList[i] == nil then
              slot = ItemSlot.New()
              -- , self.extra
              slot:SetAll(itemData,self.extra)
              slot:SetNum(reward[i][3])
              slot:ShowNum(true)
              -- obj = GameObject.Instantiate(self.iconTaskTemplateObj)
              -- obj:SetActive(true)
              self.totalIconLayout:AddCell(slot.gameObject)
              self.totalItemSlotList[i] = slot
         else
            slot = self.totalItemSlotList[i]
            slot.gameObject:SetActive(true)
            slot:SetAll(itemData,self.extra)
            slot:SetNum(reward[i][3])
            slot:ShowNum(true)

         end
     end
     self:CheckCompleteTotal()
     self:UpdateCompleteTotal()
end

-- 按钮切换处理
function BibleGrowguildPanel:HideForCompleteTotal()
    if self.totalIconObjList ~= nil then
        for k,v in pairs(self.totalIconObjList) do
            v:SetActive(false)
        end
    end
end


function BibleGrowguildPanel:TotalBtnRequire()
    local data = {id = self.currentIndex + 1}
    BibleManager.Instance:send10249(data)
end

function BibleGrowguildPanel:TotalBtnReply(id)
end

function BibleGrowguildPanel:UpdateMyStatusList()
    self:CheckCompleteTotal()
end
