-- ------------------------------
-- 剧情任务面板
-- hosr
-- ------------------------------
QuestDramaWindow = QuestDramaWindow or BaseClass(BaseWindow)

function QuestDramaWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.taskdrama
    self.effectPath = "prefabs/effect/20055.unity3d"
    self.effect = nil

    self.resList = {
        {file = AssetConfig.questdramawindow, type = AssetType.Main},
        {file = "textures/ui/dramatask.unity3d", type = AssetType.Dep},
    }

    if RoleManager.Instance.RoleData.lev < 26 then
        table.insert(self.resList, {file = self.effectPath, type = AssetType.Dep})
    end

    self.itemTab = {}
    self.currentTab = nil
    self.pieceData = nil
    self.chapterData = nil
    self.doingQuest = nil
    self.itemCellTab = {}
    self.previewList = {}
    self.isLimit = 0
end

function QuestDramaWindow:__delete()
    for i,v in ipairs(self.itemCellTab) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.itemCellTab = nil

    for i,v in ipairs(self.previewList) do
        v:DeleteMe()
        v = nil
    end
    self.previewList = nil

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function QuestDramaWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.questdramawindow))
    self.gameObject.name = "QuestDramaWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.titleTxt = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.bossAward = self.transform:Find("Main/BossAward").gameObject
    self.awardContainer = self.bossAward.transform:Find("Container").gameObject

    self.buttonObj = self.transform:Find("Main/Button").gameObject
    self.buttonImg = self.buttonObj:GetComponent(Image)
    self.button = self.buttonObj:GetComponent(Button)
    self.buttonTxt = self.buttonObj.transform:Find("Text"):GetComponent(Text)
    self.button.onClick:AddListener(function() self:ClickButton() end)

    self.nothing = self.transform:Find("Main/Nothing").gameObject
    self.nothing:SetActive(false)

    self.descScroll = self.transform:Find("Main/DescScroll").gameObject
    self.descScrollRect = self.descScroll:GetComponent(RectTransform)

    self.descTxt = self.descScrollRect.transform:Find("Desc"):GetComponent(Text)
    self.descTxt.verticalOverflow = VerticalWrapMode.Overflow
    self.descRect = self.descTxt.gameObject:GetComponent(RectTransform)
    self.descTxt.text = ""

    self.rightButtonObj = self.transform:Find("Main/RightButton").gameObject
    self.rightButton = self.rightButtonObj:GetComponent(Button)
    self.rightButton.onClick:AddListener(function() self:ClickRight() end)
    self.rightButtonImg = self.rightButtonObj.transform:Find("Img"):GetComponent(Image)
    self.leftButtonObj = self.transform:Find("Main/LeftButton").gameObject
    self.leftButton = self.leftButtonObj:GetComponent(Button)
    self.leftButton.onClick:AddListener(function() self:ClickLeft() end)
    self.leftButtonImg = self.leftButtonObj.transform:Find("Img"):GetComponent(Image)

    self.container = self.transform:Find("Main/Conatiner")
    for i = 1, 5 do
        local item = {}
        item.limitLev = 0
        local transform = self.container:GetChild(i - 1)
        item.transform = transform
        item.gameObject = transform.gameObject
        item.lock = transform:Find("Lock").gameObject
        item.lockTxt = transform:Find("Lock/Text"):GetComponent(Text)
        item.titleName = transform:Find("TitleName"):GetComponent(Text)
        item.orderTxt = transform:Find("Order/Text"):GetComponent(Text)
        item.preview = transform:Find("Preview").gameObject
        item.finishIcon = transform:Find("FinishIcon").gameObject
        item.awardIcon = transform:Find("AwardIcon").gameObject
        item.select = transform:Find("Select").gameObject
        item.index = i
        item.button = item.gameObject:GetComponent(Button)
        local index = i
        item.button.onClick:AddListener(function() self:ClickOneItem(index) end)
        table.insert(self.itemTab, item)

        item.select:SetActive(false)
        item.lock:SetActive(false)
        item.finishIcon:SetActive(false)
        item.awardIcon:SetActive(false)
        item.preview:SetActive(false)
        item.titleName.text = ""
        item.orderTxt.text = ""
    end

    if RoleManager.Instance.RoleData.lev < 26 then
        self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
        self.effect.name = "Effect"
        self.effect.transform:SetParent(self.buttonObj.transform)
        Utils.ChangeLayersRecursively(self.effect.transform, "UI")
        self.effect.transform.localScale = Vector3(0.45, 0.6, 0.5)
        self.effect.transform.localPosition = Vector3(-115, -24, -500)
        self.effect:SetActive(false)
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self:OnShow()
end

function QuestDramaWindow:OnShow()
    self.currentPart = QuestManager.Instance.part
    self:Update(true)
end

function QuestDramaWindow:OnHide()
end

function QuestDramaWindow:Close(doCheck)
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.taskdrama, doCheck)
end

function QuestDramaWindow:ClickButton()
    if self.isLimit > 0 then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("打开日程")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain) end
        confirmData.content = string.format(TI18N("达到%s级才可领取哦，可前往日程面板，\n通过日程中各玩法提升等级{face_1,3}"), self.isLimit)
        NoticeManager.Instance:ConfirmTips(confirmData)
        return
    end
    if self.currentTab.index < QuestManager.Instance.chapter then
        -- 已通关
    elseif self.currentTab.index > QuestManager.Instance.chapter then
        -- 为激活
        NoticeManager.Instance:FloatTipsByString(TI18N("你还没通关前一章呢{face_1,32}"))
    elseif self.currentTab.index == QuestManager.Instance.chapter then
        -- 进行中
        QuestManager.Instance.model:DoMain()
        self:Close(false)
    end
end

function QuestDramaWindow:ClickLeft()
    if DataQuestPrac.data_piece[self.currentPart - 1] == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("最前面了"))
    else
        self.currentPart = self.currentPart - 1
        self:Update()
        self:UpdatePageButton()
    end
end

function QuestDramaWindow:ClickRight()
    if DataQuestPrac.data_piece[self.currentPart + 1] == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("敬请期待后续剧情!"))
    else
        self.currentPart = self.currentPart + 1
        self:Update()
        self:UpdatePageButton()
    end
end

function QuestDramaWindow:UpdatePageButton()
    if self.currentPart == #DataQuestPrac.data_piece then
        self.rightButtonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Arrow13")
        self.rightButtonImg.gameObject.transform.localScale = Vector3(-1, 1, 1)
    else
        self.rightButtonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Arrow7")
        self.rightButtonImg.gameObject.transform.localScale = Vector3(1, 1, 1)
    end

    if self.currentPart == 1 then
        self.leftButtonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Arrow13")
        self.leftButtonImg.gameObject.transform.localScale = Vector3(1, 1, 1)
    else
        self.leftButtonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Arrow7")
        self.leftButtonImg.gameObject.transform.localScale = Vector3(-1, 1, 1)
    end
end

function QuestDramaWindow:Update(isFirst)
    self:UpdateInfo()
    self:UpdateItems()
    if isFirst then
        self:UpdatePageButton()
        self:ClickOneItem(QuestManager.Instance.chapter)
    else
        self:ClickOneItem(1)
    end
end

function QuestDramaWindow:UpdateItems()
    local section = QuestManager.Instance.section
    if self.currentPart > QuestManager.Instance.part then
        section = 1
    end
    section = math.max(section, 1)
    for i,item in ipairs(self.itemTab) do
        local data = DataQuestPrac.data_chapter[string.format("%s_%s", self.currentPart, i)]
        if data ~= nil then
            item.gameObject:SetActive(true)

            item.orderTxt.text = tostring(i)
            item.titleName.text = data.name
            item.limitLev = 0
            item.finishIcon:SetActive(false)

            item.awardIcon:SetActive(#data.treasure > 0)
            if self.currentPart > QuestManager.Instance.part then
                item.finishIcon:SetActive(false)
            elseif self.currentPart < QuestManager.Instance.part then
                item.finishIcon:SetActive(true)
                item.awardIcon:SetActive(false)
            else
                if i < QuestManager.Instance.chapter then
                    item.finishIcon:SetActive(true)
                    item.awardIcon:SetActive(false)
                elseif i > QuestManager.Instance.chapter then
                    item.finishIcon:SetActive(false)
                end
            end

            local npcData = DataUnit.data_unit[data.unit_model]
            if npcData ~= nil then
                if npcData.classes == nil or npcData.sex == nil or npcData.classes == 0 then
                    local modelData = {type = PreViewType.Npc, skinId = npcData.skin, modelId = npcData.res, animationId = npcData.animation_id, scale = 1}
                    self:SetPriview(i, modelData)
                else
                    local modelData = {type = PreViewType.Role, classes = npcData.classes, sex = npcData.sex, looks = npcData.looks}
                    self:SetPriview(i, modelData)
                end
            end

            local taskData = DataQuestPrac.data_task[string.format("%s_%s_%s", self.currentPart, i, section)]
            if taskData ~= nil then
                local questId = taskData.quest_id
                local questData = DataQuest.data_get[questId]
                local role = RoleManager.Instance.RoleData
                local open = false

                if role.lev_break_times == 0 then
                    if role.lev >= questData.lev then
                        open = true
                    else
                        open = false
                    end
                elseif role.lev_break_times > questData.lev_break_min_times then
                    open = true
                elseif role.lev_break_times == questData.lev_break_min_times then
                    if role.lev >= questData.lev then
                        open = true
                    else
                        open = false
                    end
                elseif role.lev_break_times < questData.lev_break_min_times then
                    open = false
                end

                if open then
                    item.lock:SetActive(false)
                else
                    item.lock:SetActive(true)
                    item.lockTxt.text = string.format(TI18N("%s级开启"), questData.lev)
                    item.limitLev = questData.lev
                end
            else
                item.lock:SetActive(false)
            end
        else
            item.gameObject:SetActive(false)
        end
    end
end

function QuestDramaWindow:UpdateBottom(limitLev)
    self.isLimit = 0
    if self.chapterData == nil then
        return
    end
    if self.currentPart > QuestManager.Instance.part then
        self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.buttonTxt.text = TI18N("未开启")
        self.buttonTxt.color = ColorHelper.DefaultButton1
    elseif self.currentPart < QuestManager.Instance.part then
        self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.buttonTxt.text = TI18N("已通关")
        self.buttonTxt.color = ColorHelper.DefaultButton1
    else
        if self.currentTab.index < QuestManager.Instance.chapter then
            -- 已通关
            self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.buttonTxt.text = TI18N("已通关")
            self.buttonTxt.color = ColorHelper.DefaultButton1
        elseif self.currentTab.index > QuestManager.Instance.chapter then
            -- 为激活
            self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.buttonTxt.text = TI18N("未开启")
            self.buttonTxt.color = ColorHelper.DefaultButton1
        elseif self.currentTab.index == QuestManager.Instance.chapter then
            -- 进行中
            if RoleManager.Instance.RoleData.lev >= limitLev then
                self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self.buttonTxt.color = ColorHelper.DefaultButton3
                if QuestManager.Instance:GetQuestMain() ~= nil then
                    self.buttonTxt.text = TI18N("前往任务")
                else
                    self.buttonTxt.text = TI18N("接取任务")
                    if self.effect ~= nil and RoleManager.Instance.RoleData.lev < 26 then
                        self.effect:SetActive(true)
                    end
                end
            else
                self.isLimit = limitLev
                self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                self.buttonTxt.text = string.format(TI18N("%s级可领"), limitLev)
                self.buttonTxt.color = ColorHelper.DefaultButton1
            end
        end
    end

    self.descTxt.text = self.chapterData.desc
    self.nothing:SetActive(false)

    self.bossAward:SetActive(#self.chapterData.treasure > 0)
    if #self.chapterData.treasure > 0 then
        self:ShowAward(self.chapterData.treasure)
        self.descScrollRect.sizeDelta = Vector2(245, 110)
        self.descRect.sizeDelta = Vector2(245, 120)
        self.descRect.sizeDelta = Vector2(245, self.descTxt.preferredHeight)
        self.descRect.anchoredPosition = Vector2.zero
    else
        self.descScrollRect.sizeDelta = Vector2(500, 110)
        self.descRect.sizeDelta = Vector2(500, 110)
        self.descRect.sizeDelta = Vector2(500, self.descTxt.preferredHeight)
        self.descRect.anchoredPosition = Vector2.zero
    end
end

function QuestDramaWindow:ShowAward(items)
    for _,cell in ipairs(self.itemCellTab) do
        cell.gameObject:SetActive(false)
    end
    local QuestCount = 0
    for i,v in ipairs(items) do
        local baseid = v
        local count = 1
        local bind = 0

        local item = BackpackManager.Instance:GetItemBase(baseid)
        item.quantity = count
        item.bind = bind

        local cell = self.itemCellTab[i]
        if cell == nil then
            cell = ItemSlot.New()
            local trans = cell.gameObject.transform
            trans:SetParent(self.awardContainer.transform)
            trans.localScale = Vector3.one
            table.insert(self.itemCellTab, cell)
        end
        cell:SetAll(item, {nobutton = true})
        cell.gameObject.transform.localPosition = Vector3(32 + QuestCount * 70, -35, 0)
        cell.gameObject:SetActive(true)
        QuestCount = QuestCount + 1
    end
end

function QuestDramaWindow:UpdateInfo()
    local qData = DataQuestPrac.data_task[string.format("%s_%s_%s", self.currentPart, QuestManager.Instance.chapter, QuestManager.Instance.section)]
    self.doingQuest = nil
    if qData ~= nil then
        self.doingQuest = qData.quest_id
    end
    self.pieceData = DataQuestPrac.data_piece[self.currentPart]
    if self.pieceData ~= nil then
        self.titleTxt.text = string.format(TI18N("第%s幕 %s"), BaseUtils.NumToChn(self.pieceData.part), self.pieceData.name)
    else
        self.titleTxt.text = TI18N("剧情任务")
    end
end

function QuestDramaWindow:ClickOneItem(index)
    if self.currentTab ~= nil and self.currentTab.index ~= index then
        self:UnSelect(self.currentTab)
    end
    self.currentTab = self.itemTab[index]
    self:Select(self.currentTab)

    self.chapterData = DataQuestPrac.data_chapter[string.format("%s_%s", self.currentPart, index)]
    self:UpdateBottom(self.currentTab.limitLev)
end

function QuestDramaWindow:UnSelect(item)
    item.select:SetActive(false)
end

function QuestDramaWindow:Select(item)
    item.select:SetActive(true)
end

function QuestDramaWindow:SetPriview(_index, modelData)
    local index = _index
    local callback = function(composite)
        if self.gameObject == nil then
            return
        end
        self.previewList[index] = composite
        self:SetRawImage(index)
    end
    local setting = {
        name = "TaskPreview"..index
        ,orthographicSize = 0.5
        ,width = 130
        ,height = 200
        ,offsetY = -0.4
        ,noDrag = true
    }

    if self.previewList[index] == nil then
        PreviewComposite.New(callback, setting, modelData)
    else
        self.previewList[index]:Reload(modelData, callback)
    end
end

function QuestDramaWindow:SetRawImage(index)
    local tab = self.itemTab[index]
    local composite = self.previewList[index]
    composite.tpose.transform:Rotate(Vector3(0, -30, 0))
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(tab.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 8, 0)
    rawImage.transform.localScale = Vector3.one
    tab.preview:SetActive(true)
end
