-- ----------------------------
-- 春节活动-- 年糕制作
-- hosr
-- ----------------------------
RiceCake = RiceCake or BaseClass(BasePanel)

function RiceCake:__init(main)
    self.main = main
    self.path = "prefabs/ui/springfestival/ricecake.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
    }
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.type = SpringFestivalEumn.Type.RiceCake
    self.currentIndex = 1
    self.enough = false

    self.toolsTab = {}

    self.itemListener = function() self:Update() end
    self.listener = function() self:Update() end

    self.clickListener = function() self:ClickButton() end

    self.buyTools = {}
end

function RiceCake:__delete()
    if self.buyButton ~= nil then
        self.buyButton:DeleteMe()
        self.buyButton = nil
    end
    if self.targetSlot ~= nil then
        self.targetSlot:DeleteMe()
    end
    for k,v in pairs(self.toolsTab) do
        v:DeleteMe()
    end
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.listener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemListener)
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function RiceCake:InitPanel()
    CampaignManager.Instance.firstRiceCake = false
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "RiceCake"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.rightTransform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.button = self.transform:Find("Button"):GetComponent(Button)
    -- self.button.onClick:AddListener(function() self:ClickButton() end)
    -- self.buttonTxt = self.button.gameObject.transform:Find("Text"):GetComponent(Text)
    -- self.buttonImg = self.button.gameObject:GetComponent(Image)
    -- self.buttonRect = self.button.gameObject:GetComponent(RectTransform)
    self.button.gameObject:SetActive(false)

    self.buyButtonObj = self.transform:Find("BuyButton")
    self.buttonRect = self.buyButtonObj:GetComponent(RectTransform)

    self.buyButton = BuyButton.New(self.buyButtonObj, TI18N("制作食盒"), WindowConfig.WinID.biblemain)
    self.buyButton.protoId = 14001
    self.buyButton:Show()

    self.jumpButton = self.transform:Find("JumpButton"):GetComponent(Button)
    self.jumpButton.onClick:AddListener(function() self:ClickJump() end)
    self.jumpTxt = self.transform:Find("JumpButton/Text"):GetComponent(Text)
    self.jumpRect = self.jumpButton.gameObject:GetComponent(RectTransform)

    self.titleTxt = self.transform:Find("Title"):GetComponent(Text)
    self.targetSlot = ItemSlot.New(self.transform:Find("TargetContainer/ItemSlot").gameObject)
    self.descTxt = self.transform:Find("Desc"):GetComponent(Text)
    self.descTxt.text = ""
    self.tipsTxt = self.transform:Find("Tips/Tips"):GetComponent(Text)
    self.tipsTxt.text = ""
    self.contentTxt = self.transform:Find("Content"):GetComponent(Text)
    self.contentTxt.text = ""

    local tools = self.transform:Find("ToolsContainer")
    self.toolsRect = tools.gameObject:GetComponent(RectTransform)
    local len = tools.childCount
    for i = 1, len do
        table.insert(self.toolsTab, ItemSlot.New(tools:GetChild(i - 1).gameObject))
    end

    self:OnShow()

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemListener)
    EventMgr.Instance:AddListener(event_name.campaign_change, self.listener)
end

function RiceCake:OnHide()
end

function RiceCake:OnShow()
    if self.openArgs ~= nil then
        self.currentIndex = self.openArgs
    end
    self.campaignData = self.main:GetCampaignData(self.type, self.currentIndex)

    self.titleTxt.text = SpringFestivalEumn.RiceCakeSubName[self.currentIndex]
    self.descTxt.text = self.campaignData.conds

    self:UpdateTarget()
    self:Update()
    self:UpdateButtons()
end

function RiceCake:Update()
    self:UpdateTools()

    self.protoData = CampaignManager.Instance:GetCampaignData(self.campaignData.id)
    if self.protoData ~= nil then

        local color = "#00ff00"
        if self.protoData.reward_can == 0 then
            color = "#ff0000"
        end
        self.tipsTxt.text = string.format(TI18N("今日已制作<color='%s'>%s/%s</color> "), color, (self.protoData.reward_max - self.protoData.reward_can), self.protoData.reward_max)

        if self.protoData.status == CampaignEumn.Status.Accepted then
            self.buyButton:Layout({}, self.clickListener)
            -- self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            return
        end
    end

    if self.enough then
        -- self.buttonTxt.text = "制作年糕"
        -- self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.buyButton:Layout({}, self.clickListener)
    else
        -- self.buttonTxt.text = "材料不足"
        -- self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        if self.campaignData.auto_buy == 1 then
            self.buyButton:Layout(self.buyTools, self.clickListener)
        else
            self.buyButton:Layout({}, self.clickListener)
        end
    end

    self.buyButton:ReleaseFrozon()
end

function RiceCake:UpdateTarget()
    local item = self.campaignData.reward[1]
    if item == nil then
        self.targetSlot:SetAll(nil)
        self.contentTxt.text = ""
    else
        local itemData = BaseUtils.copytab(DataItem.data_get[item[1]])
        itemData.quantity = item[2]
        self.targetSlot:SetAll(itemData, {nobutton = true})
        self.contentTxt.text = itemData.desc
    end
end

function RiceCake:UpdateTools()
    self.enough = true
    local count = 1
    self.buyTools = {}
    for i,v in ipairs(self.campaignData.loss_items) do
        local id = v[1]
        local num = v[2]

        local itemData = BaseUtils.copytab(DataItem.data_get[id])
        itemData.need = num
        itemData.quantity = BackpackManager.Instance:GetItemCount(id)

        self.enough = self.enough and (itemData.quantity >= itemData.need)

        local slot = self.toolsTab[count]
        slot:SetAll(itemData)
        count = count + 1

        self.buyTools[id] = {need = num}
    end
    for i = 1 , #self.toolsTab do
        slot = self.toolsTab[i]
        if i >= count then
            slot.gameObject:SetActive(false)
        else
            slot.gameObject:SetActive(true)
        end
    end

    count = count - 1
    self.toolsRect.sizeDelta = Vector2(count * 64 + (count - 1) * 50, 64)
    self.toolsRect.anchoredPosition = Vector2(0, -290)
    self.main.tree:RedMain(SpringFestivalEumn.Type.RiceCake, false)

    BibleManager.Instance.redPointDic[4][5] = self.enough
    BibleManager.Instance.onUpdateRedPoint:Fire()
end

function RiceCake:UpdateButtons()
    if self.currentIndex == 1 then
        self.jumpButton.gameObject:SetActive(false)
        self.buttonRect.anchoredPosition = Vector2(0, 40)
    elseif self.currentIndex == 2 then
        self.jumpButton.gameObject:SetActive(true)
        self.jumpTxt.text = TI18N("时装预览")
        self.buttonRect.anchoredPosition = Vector2(100, 40)
        self.jumpRect.anchoredPosition = Vector2(-100, 15)
    elseif self.currentIndex == 3 then
        self.jumpButton.gameObject:SetActive(true)
        self.jumpTxt.text = TI18N("神兽预览")
        self.buttonRect.anchoredPosition = Vector2(100, 40)
        self.jumpRect.anchoredPosition = Vector2(-100, 15)
    end
end

function RiceCake:ClickButton()
    if self.protoData ~= nil and self.protoData.status == CampaignEumn.Status.Accepted then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("今天已经制作20个<color='#ffff00'>%s</color>，太累了明天再制作吧"), SpringFestivalEumn.RiceCakeSubName[self.currentIndex]))
        return
    end
    -- if not self.enough then
    --     NoticeManager.Instance:FloatTipsByString("材料不足，无法制作年糕")
    --     return
    -- end
    if self.campaignData ~= nil then
        CampaignManager.Instance:Send14001(self.campaignData.id)
    end
end

function RiceCake:ClickJump()
    if self.currentIndex == 2 then
        -- 时装
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fashion_window)
    elseif self.currentIndex == 3 then
        -- 神兽
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {3,20004})
    end
end
