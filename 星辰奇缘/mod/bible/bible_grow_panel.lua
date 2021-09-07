-- 已弃用，由BibleGrowguildPanel代替

BibleGrowPanel = BibleGrowPanel or BaseClass(BasePanel)

function BibleGrowPanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.bible_grow_panel, type = AssetType.Main}
        , {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
    }
    self.questUpdateList = {}

    self.listener = function(data)
        self.questUpdateList = {}
        for k,v in pairs(data) do
            if v ~= nil then
                local dat = DataQuest.data_get[v]
                if dat.sec_type == QuestEumn.TaskType.guide then
                    table.insert(self.questUpdateList, v)
                end
            end
        end
        self:ReloadTaskList()
    end
    -- EventMgr.Instance:AddListener(event_name.quest_update, self.listener)

    self.ltDescrList = nil   -- 移动对象列表

    self.OnOpenEvent:AddListener(function()
        self:OnOpen()
    end)
    self.OnHideEvent:AddListener(function()
        self:OnHide()
    end)
end

function BibleGrowPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.quest_update, self.listener)
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()

    for k,v in pairs(self.ltDescrList) do
        if v ~= nil then
            Tween.Instance:Cancel(v)
            self.ltDescrList[k] = nil
        end
    end
    self.ltDescrList = nil

    -- if self.ltDescr ~= nil then
    --     Tween.Instance:Cancel(self.ltDescr.id)
    --     self.ltDescr = nil
    -- end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BibleGrowPanel:InitPanel()
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_grow_panel))
    self.gameObject.name = "GrowguidePanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    -- self.transform = model.bibleWin.transform:Find("Main/GrowguidePanel")
    self.transform = self.gameObject.transform

    self.container = self.transform:Find("Bg/Scroll/Container")
    self.layout = LuaBoxLayout.New(self.container.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 5})
    self.taskTemplate = self.container:Find("Task").gameObject
    self.taskTemplate:SetActive(false)
    self.taskObjList = {}

    self.OnOpenEvent:Fire()
end

function BibleGrowPanel:ReloadTaskList()
    BibleManager.Instance.redPointDic[2][1] = false
    self.model.bibleWin:CheckRedPoint()

    local tasklist = QuestManager.Instance.questTab

    local rect = self.container.gameObject:GetComponent(RectTransform)

    local guideTaskList = {}
    for k,v in pairs(tasklist) do
        if v ~= nil and v.sec_type == QuestEumn.TaskType.guide then
            table.insert(guideTaskList, v)
        end
    end

    rect.sizeDelta = Vector2(720, 90 * #guideTaskList + 12)
    rect.anchoredPosition = Vector2(0, 0)

    if self.questUpdateList ~= nil and #self.questUpdateList > 0 then
        for k,v in pairs(self.questUpdateList) do
            if self.taskObjList[v] ~= nil then  -- 如果不是新任务
                if tasklist[v] ~= nil then
                    self:SetItem(tasklist[v], self.taskObjList[v])
                else
                    local parent = self.taskObjList[v].transform.parent
                    local task = self.taskObjList[v].transform:Find("task")
                    if task ~= nil then
                        task:SetParent(parent)
                        GameObject.DestroyImmediate(self.taskObjList[v])
                        self.taskObjList[v] = nil

                        if parent.gameObject.name == "Container" then
                            task:GetComponent(RectTransform).anchoredPosition = Vector2(0, -90)
                            local ltDescr = Tween.Instance:MoveY(task:GetComponent(RectTransform), -5, 0.5, function() end, LeanTweenType.linear)
                            table.insert(self.ltDescrList, ltDescr.id)
                        else
                            task:GetComponent(RectTransform).anchoredPosition = Vector2(0, -180)
                            local ltDescr = Tween.Instance:MoveY(task:GetComponent(RectTransform), -90, 0.5, function() end, LeanTweenType.linear)
                            table.insert(self.ltDescrList, ltDescr.id)
                        end
                    else
                        GameObject.DestroyImmediate(self.taskObjList[v])
                        self.taskObjList[v] = nil
                        if parent.gameObject.name ~= "Container" then
                            self.bottomTaskObj = parent.gameObject
                        else
                            self.bottomTaskObj = nil
                        end
                    end
                end
            else    -- 如果是新任务
                local obj = GameObject.Instantiate(self.taskTemplate)
                obj.name = "task"
                obj:SetActive(true)
                self.taskObjList[v] = obj
                self:SetItem(tasklist[v], obj)

                if self.bottomTaskObj == nil then
                    obj.transform:SetParent(self.container)
                    obj.transform.localScale = Vector3.one
                    obj:GetComponent(RectTransform).anchoredPosition = Vector2(0, -5)
                else
                    obj.transform:SetParent(self.bottomTaskObj.transform)
                    obj.transform.localScale = Vector3.one
                    obj:GetComponent(RectTransform).anchoredPosition = Vector2(0, -90)
                end
                self.bottomTaskObj = obj
            end
        end
        self.questUpdateList = nil
        return
    else
    end

    table.sort(guideTaskList, function (a, b)
        return a.finish > b.finish
    end)

    -- BaseUtils.dump(guideTaskList, "指引任务列表")

    if #guideTaskList > 0 then
        local obj = self.container:Find("task")
        if obj == nil then
            obj = GameObject.Instantiate(self.taskTemplate)
            obj.transform:SetParent(self.container)
            obj.name = "task"
            obj:GetComponent(RectTransform).anchoredPosition = Vector2(0, -5)
            obj.transform.localScale = Vector3.one
        else
            obj = obj.gameObject
            obj:GetComponent(RectTransform).anchoredPosition = Vector2(0, -5)
        end
        self.taskObjList[guideTaskList[1].id] = obj
        obj:SetActive(true)
        self:SetItem(guideTaskList[1], obj)
        self.bottomTaskObj = obj

        for i=2,#guideTaskList do
            obj = self.taskObjList[guideTaskList[i - 1].id].transform:Find("task")
            if obj == nil then
                obj = GameObject.Instantiate(self.taskTemplate)
                obj.name = "task"
                obj.transform:SetParent(self.taskObjList[guideTaskList[i - 1].id].transform)
                obj.transform.localScale = Vector3.one
                obj:GetComponent(RectTransform).anchoredPosition = Vector2(0, -90)
            else
                obj = obj.gameObject
                obj:GetComponent(RectTransform).anchoredPosition = Vector2(0, -90)
            end
            obj:SetActive(true)
            self.taskObjList[guideTaskList[i].id] = obj
            self:SetItem(guideTaskList[i], obj)

            if i == #guideTaskList then
                self.bottomTaskObj = obj
            end
        end
    else
        self.bottomTaskObj = nil
    end

end

function BibleGrowPanel:SetItem(data, obj)
    local t = obj.transform
    local nameText = t:Find("Name"):GetComponent(Text)
    local iconImage = t:Find("Icon/Image"):GetComponent(Image)

    nameText.text = data.name
    iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(data.id))

    -- BaseUtils.dump(data.rewards_commit, "奖励列表 "..data.name)
    self:AddRewardToItem(data.rewards_commit, t:Find("Reward/Text/Container"))
    self:UpdateItem(data, obj)

    local btn = t:Find("Active"):GetComponent(Button)
    local quest = BaseUtils.copytab(data)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function()
        if self.waiting ~= true then
            if quest.finish == QuestEumn.TaskStatus.Finish then
                -- 完成直接提交
                QuestManager.Instance:Send10206(quest.id)
                self.waiting = true
                LuaTimer.Add(500, function() self.waiting = false end)
            else
                self.model:CloseWindow()
                QuestManager.Instance:DoQuest(quest)
            end
        end
    end)
end

function BibleGrowPanel:UpdateItem(data, obj)
    local t = obj.transform
    local descText = t:Find("Desc"):GetComponent(Text)
    local btnText = t:Find("Active/Text"):GetComponent(Text)
    local btnImage = t:Find("Active"):GetComponent(Image)
    local toggle = t:Find("Toggle"):GetComponent(Toggle)

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
        -- print(desc)
        if progressSer[progressId].target_val == 0 then
            descText.text = desc
        else
            descText.text = string.format("%s(%s/%s)", desc, tostring(progressSer[progressId].value), tostring(progressSer[progressId].target_val))
        end
    end

    if data.finish == 2 then
        btnText.text = string.format(TI18N("<color=%s>领取奖励</color>"), ColorHelper.ButtonLabelColor.Green)
        btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    else
        btnText.text = string.format(TI18N("<color=%s>前往任务</color>"), ColorHelper.ButtonLabelColor.Blue)
        btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    end

    toggle.onValueChanged:RemoveAllListeners()
    toggle.isOn = (data.follow == 1)

    local quest = BaseUtils.copytab(data)
    toggle.onValueChanged:AddListener(function(status) self:OnCheck(quest, status) end)
end

function BibleGrowPanel:AddRewardToItem(rewardList, container)
    local template = container:Find("RewardItem").gameObject
    local w = template.transform:Find("Image"):GetComponent(RectTransform).sizeDelta.x
    template:SetActive(false)

    local childCount = container.childCount - 1
    for i=1,childCount do
        container:Find(tostring(i)).gameObject:SetActive(false)
    end

    local l = #rewardList
    local objList = {}
    for i=1,l do
        local obj = container:Find(tostring(i))
        local data = QuestEumn.AwardItemInfo(rewardList[i])
        if obj == nil then
            obj = GameObject.Instantiate(template)
            NumberpadPanel.AddUIChild(container.gameObject, obj)
            obj.name = tostring(i)
        else
            obj = obj.gameObject
        end
        obj:SetActive(true)
        objList[i] = obj
        local t = obj.transform
        if data ~= nil then
            t:Find("Text"):GetComponent(Text).text = "×"..data.count
        else
            obj:SetActive(false)
        end
    end

    local x = 0
    local y = 0
    for i=1,l do
        local rect = objList[i]:GetComponent(RectTransform)
        rect.anchoredPosition = Vector2(x, y)
        local text = objList[i].transform:Find("Text"):GetComponent(Text)
        x = x + text.preferredWidth + w + 5
    end

    local rect = container.parent:GetComponent(RectTransform)
    x = x + rect.sizeDelta.x
    x = x / 2
    rect.anchoredPosition = Vector2(-x, 0)
end

function BibleGrowPanel:OnCheck(questData, status)
    if questData ~= nil then
        if status == true then
            QuestManager.Instance.questTab[questData.id].follow = 1
        else
            QuestManager.Instance.questTab[questData.id].follow = 0
        end
        MainUIManager.Instance:HideOrShowQuest(questData.id, status)
    end
end

function BibleGrowPanel:RemoveListener()
    EventMgr.Instance:RemoveListener(event_name.quest_update, self.listener)
end

function BibleGrowPanel:OnOpen()
    self.questUpdateList = nil
    EventMgr.Instance:RemoveListener(event_name.quest_update, self.listener)
    EventMgr.Instance:AddListener(event_name.quest_update, self.listener)
    self.ltDescrList = {}
    self:ReloadTaskList()
end

function BibleGrowPanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.quest_update, self.listener)
    for k,v in pairs(self.ltDescrList) do
        if v ~= nil then
            Tween.Instance:Cancel(v)
            self.ltDescrList[k] = nil
        end
    end
end
