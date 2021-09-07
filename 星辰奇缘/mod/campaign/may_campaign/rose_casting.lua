-- 玫瑰传情
-- @author huangyaoc
-- @date 20160517

RoseCasting = RoseCasting or BaseClass(BasePanel)

function RoseCasting:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "RoseCasting"

    self.titleString = TI18N("五月恋爱季")
    self.dateFormatString = TI18N("%s年%s月%s日")
    self.timeFormatString = TI18N("活动时间:<color=#C7F9FF>%s-%s</color>")
    self.descFormatString = TI18N("{string_2, #7EB9F7, 活动内容:}%s")
    self.btnString = {TI18N("免费领取"), TI18N("购 买")}
    self.originString = TI18N("原价:<color=#C7F9FF>%s</color>")
    self.currString = TI18N("现价:<color=#C7F9FF>%s</color>")
    self.warningString = TI18N("你今天购买次数已达到上限")
    self.currPrice = 299

    self.resList = {
        {file = AssetConfig.rose_casting, type = AssetType.Main}
        , {file = AssetConfig.may_textures, type = AssetType.Dep}
    }

    self.itemList = {}

    self.updateListener = function() self:InitUI() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RoseCasting:__delete()
    self.OnHideEvent:Fire()
    self.icon = nil
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.itemSlot:DeleteMe()
                v.descExt:DeleteMe()
                v.itemData:DeleteMe()
                v.originLoader:DeleteMe()
                v.currloader:DeleteMe()
                v.btnImage.sprite = nil
            end
        end
        self.itemList = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    if self.descExtText ~= nil then
        self.descExtText:DeleteMe()
        self.descExtText = nil
    end
    self:AssetClearAll()
end

function RoseCasting:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rose_casting))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.toBuyRoseBtn = t:Find("Item/Button"):GetComponent(Button)
    self.timeText = t:Find("Info/Time"):GetComponent(Text)
    self.descText = t:Find("Info/Desc"):GetComponent(Text)
    self.scroll = t:Find("Scroll"):GetComponent(ScrollRect)
    self.titleText = t:Find("Bg/Title/Text"):GetComponent(Text)
    self.layout = LuaBoxLayout.New(t:Find("Scroll/Container"), {axis = BoxLayoutAxis.X, cspacing = 0})
    if self.bg ~= nil then
        UIUtils.AddBigbg(t:Find("Bg/Bg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    end

    self.descExtText = MsgItemExt.New(self.descText, 520, 17, 20)
    self.cloner = t:Find("Item").gameObject
    self.toBuyRoseBtn.onClick:AddListener(function() self:OnBuy() end)

    if self.icon ~= nil then
        t:Find("Bg/Title/Icon"):GetComponent(Image).sprite = self.icon
        t:Find("Bg/Title/Icon").gameObject:SetActive(true)
    else
        t:Find("Bg/Title/Icon").gameObject:SetActive(false)
    end
end

function RoseCasting:OnBuy(id)
    local protoData = CampaignManager.Instance.campaignTab[id]
    if protoData ~= nil then
        if protoData.reward_max > 0 and protoData.reward_can == 0 then
            NoticeManager.Instance:FloatTipsByString(self.warningString)
        else
            if #DataCampaign.data_list[id].loss_items > 0 then
                local confirmData = NoticeConfirmData.New()
                confirmData.content = string.format(TI18N("是否消耗<color='#00ff00'>%s</color>{assets_2, %s}购买？"), tostring(DataCampaign.data_list[id].loss_items[1][2]), tostring(DataCampaign.data_list[id].loss_items[1][1]))
                confirmData.sureCallback = function() CampaignManager.Instance:Send14001(id) end
                NoticeManager.Instance:ConfirmTips(confirmData)
            else
                CampaignManager.Instance:Send14001(id)
            end
        end
    end
end

function RoseCasting:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RoseCasting:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListener)

    self:InitUI()
end

function RoseCasting:OnHide()
    self:RemoveListeners()
end

function RoseCasting:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListener)
end

function RoseCasting:InitUI()
    local campaignData = DataCampaign.data_list[self.campaignData.sub[1].id]

    self.titleText.text = campaignData.timestr
    self.descExtText:SetData(string.format(self.descFormatString, campaignData.cond_desc), true)

    self.timeText.text = string.format(self.timeFormatString,
        string.format(self.dateFormatString, tostring(campaignData.cli_start_time[1][1]),tostring(campaignData.cli_start_time[1][2]),tostring(campaignData.cli_start_time[1][3])),
        string.format(self.dateFormatString, tostring(campaignData.cli_end_time[1][1]),tostring(campaignData.cli_end_time[1][2]),tostring(campaignData.cli_end_time[1][3])))

    self.cloner:SetActive(false)
    self.layout:ReSet()

    for i,protoData in ipairs(self.campaignData.sub) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.cloner)
            tab.transform = tab.gameObject.transform
            tab.itemSlot = ItemSlot.New()
            NumberpadPanel.AddUIChild(tab.transform:Find("Bg/Icon"), tab.itemSlot.gameObject)
            tab.itemData = ItemData.New()
            tab.descExt = MsgItemExt.New(tab.transform:Find("Times"):GetComponent(Text), 140, 15, 17.36)
            tab.originText = tab.transform:Find("Bg/OriginPrice"):GetComponent(Text)
            tab.currText = tab.transform:Find("Bg/CurrPrice"):GetComponent(Text)
            tab.originLoader = SingleIconLoader.New(tab.transform:Find("Bg/OriginPrice/Diamond").gameObject)
            tab.currLoader = SingleIconLoader.New(tab.transform:Find("Bg/CurrPrice/Diamond").gameObject)
            tab.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function() if tab.id ~= nil then self:OnBuy(tab.id) end end)
            tab.btnText = tab.transform:Find("Button/Text"):GetComponent(Text)
            tab.btnImage = tab.transform:Find("Button"):GetComponent(Image)
            self.itemList[i] = tab
        end
        self.layout:AddCell(tab.gameObject)

        tab.id = protoData.id
        local cfgData = DataCampaign.data_list[tab.id]
        if #cfgData.loss_items > 0 then
            tab.currText.text = string.format(self.currString, tostring(cfgData.loss_items[1][2]))
            tab.originText.text = string.format(self.originString, tostring(cfgData.camp_cond_client))
            tab.currText.gameObject:SetActive(true)
            tab.originText.gameObject:SetActive(true)
            if GlobalEumn.CostTypeIconName[cfgData.loss_items[1][1]] == nil then
                tab.currLoader:SetSprite(SingleIconType.Item, DataItem.data_get[cfgData.loss_items[1][1]].icon)
                tab.originLoader:SetSprite(DataItem.data_get[cfgData.loss_items[1][1]].icon)
            else
                tab.currLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[cfgData.loss_items[1][1]]))
                tab.originLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[cfgData.loss_items[1][1]]))
            end
            tab.descExt.contentTrans.gameObject:SetActive(false)
            tab.btnText.text = self.btnString[2]
            tab.btnText.color = ColorHelper.DefaultButton1
            tab.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        else
            tab.btnText.text = self.btnString[1]
            tab.currText.gameObject:SetActive(false)
            tab.originText.gameObject:SetActive(false)
            tab.descExt.contentTrans.gameObject:SetActive(true)
            tab.descExt:SetData(cfgData.reward_content)
            tab.btnText.color = ColorHelper.DefaultButton2
            tab.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            local size = tab.descExt.contentTrans.sizeDelta
            tab.descExt.contentTrans.anchoredPosition = Vector2(-size.x/2, -20+size.y/2)
        end
        if tab.itemData.base_id ~= cfgData.reward[1][1] then
            tab.itemData:SetBase(DataItem.data_get[cfgData.reward[1][1]])
            tab.itemSlot:SetAll(tab.itemData, {inbag = false, nobutton = true})
        end

        tab.itemSlot:SetNum(protoData.reward_max)
        if protoData.reward_can > 0 then
            tab.itemSlot:SetGrey(false)
            tab.itemSlot:SetNum(protoData.reward_can)
        else
            tab.itemSlot:SetGrey(true)
            tab.itemSlot.numTxt.text = TI18N("售罄")
            tab.btnText.color = ColorHelper.DefaultButton4
            if #cfgData.loss_items > 0 then
                tab.btnText.text = TI18N("售 罄")
            else
                tab.btnText.text = TI18N("已领取")
            end
            tab.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        end
    end
    for i=#self.campaignData.sub + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end

    if #self.campaignData.sub > 3 then
        self.scroll.movementType = 1
    else
        self.scroll.movementType = 2
    end
end


