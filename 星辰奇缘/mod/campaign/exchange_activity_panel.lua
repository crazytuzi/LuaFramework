-- @author 黄耀聪
-- @date 2016年5月31日

ExchangeActivityPanel = ExchangeActivityPanel or BaseClass(BasePanel)

function ExchangeActivityPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ExchangeActivityPanel"

    self.resList = {
        {file = AssetConfig.rice_cake, type = AssetType.Main}
    }

    self.boxMakeString = TI18N("")
    self.makingString = TI18N("今日已制作<color='%s'>%s/%s</color>")
    self.fullString = TI18N("今天已经制作20个<color='#ffff00'>%s</color>，太累了明天再制作吧")
    self.toolsTab = {}

    self.itemListener = function() self:Update() end
    self.listener = function()
        -- if self.buyButton ~= nil then self.buyButton:ReleaseFrozon() end
        self:Update()
    end
    self.clickListener = function() self:ClickButton() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ExchangeActivityPanel:__delete()
    self.OnHideEvent:Fire()
    if self.buyButton ~= nil then
        self.buyButton:DeleteMe()
        self.buyButton = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ExchangeActivityPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rice_cake))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.button = self.transform:Find("Button"):GetComponent(Button)
    self.button.gameObject:SetActive(false)

    self.buyButtonObj = self.transform:Find("BuyButton")
    self.buttonRect = self.buyButtonObj:GetComponent(RectTransform)

    self.buyButton = BuyButton.New(self.buyButtonObj, self.boxMakeString, WindowConfig.WinID.biblemain)
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
end

function ExchangeActivityPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ExchangeActivityPanel:OnOpen()
    local campaignData = DataCampaign.data_list[self.protoData.id]
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.listener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemListener)

    self.titleTxt.text = campaignData.reward_title
    self.descTxt.text = campaignData.conds

    self:InitUI()
end

function ExchangeActivityPanel:InitUI()
    self:UpdateTarget()
    self:Update()
    self:UpdateButtons()
end

function ExchangeActivityPanel:OnHide()
    self:RemoveListeners()
end

function ExchangeActivityPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.listener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemListener)
end

function ExchangeActivityPanel:Update()
    local campaignData = DataCampaign.data_list[self.protoData.id]
    self:UpdateTools()

    self.buyButton.content = campaignData.reward_content
    if self.buyButton.loading ~= true then
        self.buyButton:Update()
    end

    self.protoData = CampaignManager.Instance:GetCampaignData(campaignData.id)
    if self.protoData ~= nil then

        local color = "#00ff00"
        if self.protoData.reward_can == 0 then
            color = "#ff0000"
        end
        self.tipsTxt.text = string.format(self.makingString, color, (self.protoData.reward_max - self.protoData.reward_can), self.protoData.reward_max)

        if self.protoData.status == CampaignEumn.Status.Accepted then
            self.buyButton:Layout({}, self.clickListener)
            -- self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            return
        end
    end

    if self.enough then
        self.buyButton:Layout({}, self.clickListener)
    else
        if campaignData.auto_buy == 1 then
            self.buyButton:Layout(self.buyTools, self.clickListener)
        else
            self.buyButton:Layout({}, self.clickListener)
        end
    end

    self.buyButton:ReleaseFrozon()
end

function ExchangeActivityPanel:UpdateTools()
    local campaignData = DataCampaign.data_list[self.protoData.id]
    self.enough = true
    local count = 1
    self.buyTools = {}
    for i,v in ipairs(campaignData.loss_items) do
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
    -- self.main.tree:RedMain(SpringFestivalEumn.Type.RiceCake, false)

    -- BibleManager.Instance.redPointDic[4][5] = self.enough
    -- BibleManager.Instance.onUpdateRedPoint:Fire()
end

function ExchangeActivityPanel:UpdateTarget()
    local campaignData = DataCampaign.data_list[self.protoData.id]
    local item = campaignData.reward[1]
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

function ExchangeActivityPanel:UpdateButtons()
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

function ExchangeActivityPanel:ClickButton()
    -- if not self.enough then
    --     NoticeManager.Instance:FloatTipsByString("材料不足，无法制作年糕")
    --     return
    -- end
    if self.protoData ~= nil then
        local campaignData = DataCampaign.data_list[self.protoData.id]
        local item = campaignData.reward[1]
        if self.protoData.status == CampaignEumn.Status.Accepted then
            NoticeManager.Instance:FloatTipsByString(string.format(self.fullString, DataItem.data_get[item[1]].name))
            self.buyButton:ReleaseFrozon()
        else
            CampaignManager.Instance:Send14001(self.protoData.id)
        end
    end
end


