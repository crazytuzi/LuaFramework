BibleFestivalPanel = BibleFestivalPanel or BaseClass(BasePanel)

function BibleFestivalPanel:__init(model, parent)
    self.model = model
    self.name = BibleFestivalPanel
    self.parent = parent

    self.resList = {
        {file = AssetConfig.bible_festival_panel, type = AssetType.Main},
        {file = AssetConfig.festival_winter, type = AssetType.Main},
    }

    self.festivalItemList = {}
    self.itemList = {}

    self.comingContent = TI18N("<color='#ffff9a'>即将到来</color>")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BibleFestivalPanel:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for k,v in pairs(self.itemList) do
            v:DeleteMe()
        end
        self.itemList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BibleFestivalPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_festival_panel))
    self.gameObject.name = "BibleFestivalPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    local content = t:Find("Content")

    self.currentNameText = content:Find("CurrentFestival/Title"):GetComponent(Text)
    self.currentNameRect = self.currentNameText.gameObject:GetComponent(RectTransform)
    self.gotoButton = content:Find("CurrentFestival/Button"):GetComponent(Button)
    self.gotoButtonText = content:Find("CurrentFestival/Button/Text"):GetComponent(Text)
    self.gotoButtonImage = content:Find("CurrentFestival/Button"):GetComponent(Image)

    self.festivalItemList[1] = {}
    self.festivalItemList[1].descText = content:Find("CurrentFestival/Desc"):GetComponent(Text)
    self.festivalItemList[1].dateObj = content:Find("CurrentFestival/Date").gameObject
    self.festivalItemList[1].dateText = content:Find("CurrentFestival/Date/Text"):GetComponent(Text)

    self.comingText = content:Find("Coming/Title"):GetComponent(Text)
    self.comingRect = content:Find("Coming/Title"):GetComponent(RectTransform)

    for i=2,3 do
        self.festivalItemList[i] = {}
        local coming = content:Find("Coming/Coming"..(i-1))
        self.festivalItemList[i].gameObject = coming.gameObject
        self.festivalItemList[i].descText = coming:Find("Scroll/Desc"):GetComponent(Text)
        self.festivalItemList[i].dateObj = coming:Find("Date").gameObject
        self.festivalItemList[i].dateText = coming:Find("Date/Text"):GetComponent(Text)
    end

    for i=1,3 do
        self.itemList[i] = BibleFestivalItem.New(self.model, self.festivalItemList[i])
    end

    self.gotoButton.onClick:AddListener(function() self:OnClick() end)

    UIUtils.AddBigbg(content:Find("CurrentFestival/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.festival_winter)))
end

function BibleFestivalPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BibleFestivalPanel:OnOpen()
    local currentMonth = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local currentDay = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local ceil = math.ceil

    FestivalManager.Instance.model:CheckFestival()
    self.festivalList = FestivalManager.Instance.model.festivalList

    local index = FestivalManager.Instance.festivalToGetIndex
    local festivalList = {}
    local tempIndex = 1
    local wednesdayMark = false
    for i=1,3 do
        local festivalData = self.festivalList[(index + (tempIndex - 2)) % #self.festivalList + 1]
        while wednesdayMark and festivalData.name == "周三要加油" do
            tempIndex = tempIndex + 1
            festivalData = self.festivalList[(index + (tempIndex - 2)) % #self.festivalList + 1]
        end
        table.insert(festivalList, festivalData)
        self.itemList[i]:SetData(festivalList[i], i)
        tempIndex = tempIndex + 1
        if festivalData.name == "周三要加油" then
            wednesdayMark = true
        end
    end

    self.currentNameText.text = festivalList[1].name
    self.currentNameRect.sizeDelta = Vector2(ceil(self.currentNameText.preferredWidth + 10), ceil(self.currentNameText.preferredHeight))

    self.comingText.text = self.comingContent
    self.comingRect.sizeDelta = Vector2(ceil(self.comingText.preferredWidth + 10), ceil(self.comingText.preferredHeight))

    self.gotoButton.gameObject:SetActive(FestivalManager.Instance.isTodayFestival == true)
    if FestivalManager.Instance.isFestivalGot then
        self.gotoButtonText.text = TI18N("已领取")
        BaseUtils.SetGrey(self.gotoButtonImage, true)
        self.gotoButton.enabled = false
    else
        self.gotoButtonText.text = TI18N("前 往")
        BaseUtils.SetGrey(self.gotoButtonImage, false)
        self.gotoButton.enabled = true
    end
    self:RemoveListeners()
end

function BibleFestivalPanel:OnHide()
    self:RemoveListeners()
end

function BibleFestivalPanel:RemoveListeners()
end

function BibleFestivalPanel:OnClick()
    self.model:CloseWindow()
    QuestManager.Instance.model:FindNpc("45_1")
end

BibleFestivalItem = BibleFestivalItem or BaseClass()

function BibleFestivalItem:__init(model, itemSet)
    self.model = model
    self.itemSet = itemSet
    self.msgExtItem = MsgItemExt.New(itemSet.descText, 280, 17, 20)
    -- self.gameObject = itemSet.gameObject
    -- self.transform = self.gameObject.transform
    self.dateFormat = TI18N("%s月%s日开启")
end

function BibleFestivalItem:SetData(data, index)
    local itemSet = self.itemSet
    self.msgExtItem:SetData(data.msg, true)
    if index == 1 then
        itemSet.dateObj.gameObject:SetActive(FestivalManager.Instance.isTodayFestival ~= true)
    end
    itemSet.dateText.text = string.format(self.dateFormat, tostring(data.mount), tostring(data.day))
    -- self.msgExtItem.contentTrans.anchoredPosition = Vector2.zero
end

function BibleFestivalItem:__delete()
    if self.msgExtItem ~= nil then
        self.msgExtItem:DeleteMe()
        self.msgExtItem = nil
    end
end
