-- @author 黄耀聪
-- @date 2016年5月17日

RewardIOU = RewardIOU or BaseClass(BasePanel)

function RewardIOU:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "RewardIOU"

    self.iWantToBuyString = {TI18N("免费领取"), TI18N("我要购买"), TI18N("%s{assets_2, %s}购买")}
    self.checkForRewardString = TI18N("查看奖励")
    self.sureNoticeString = TI18N("您确定消耗{assets_1, %s, %s}要购买吗？")
    self.hasBuyString = {TI18N("已领取"),TI18N("已购买")}
    self.canBuyString = {TI18N("数量:<color=#248813>2</color>"),TI18N("今日限购:<color=#248813>%s/%s</color>")}
    self.giftString = TI18N("使用获得以下所有道具：")
    self.timeFormatString = TI18N("活动时间:<color='#C7F9FF'>%s-%s</color>")
    self.dateFormatString = TI18N("%s年%s月%s日")
    self.descFormatString = TI18N("{string_2, #7EB9F7, 活动内容:}%s")
    self.titleString = TI18N("五月恋爱季")

    self.resList = {
        {file = AssetConfig.buybuy520, type = AssetType.Main}
        , {file = AssetConfig.may_textures, type = AssetType.Dep}
    }

    self.itemList = {}

    self.updateUIListener = function() self:InitUI() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RewardIOU:__delete()
    self.OnHideEvent:Fire()
    self.icon = nil
    if self.model.giftPreview ~= nil then
        self.model.giftPreview:DeleteMe()
        self.model.giftPreview = nil
    end
    if self.itemList ~= nil then
        for k,v in pairs(self.itemList) do
            if v ~= nil then
                if v.btnExt ~= nil then
                    v.btnExt:DeleteMe()
                end
                v.itemImageLoader:DeleteMe()
                v.receiveImage.sprite = nil
            end
        end
        self.btnTextExt = nil
    end
    if self.descExtText ~= nil then
        self.descExtText:DeleteMe()
        self.descExtText = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RewardIOU:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.buybuy520))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.titleText = t:Find("Bg/Title/Text"):GetComponent(Text)
    self.descText = t:Find("Bg/Info/Desc"):GetComponent(Text)
    self.timeText = t:Find("Bg/Info/Time"):GetComponent(Text)

    UIUtils.AddBigbg(t:Find("Bg/Bg"), GameObject.Instantiate(self:GetPrefab(self.bg)))

    for i=1,2 do
        local item = t:Find("Item"..i)
        self.itemList[i] = {
            bgBtn = item:Find("Bg"):GetComponent(Button),
            receiveBtn = item:Find("Button"):GetComponent(Button),
            receiveText = item:Find("Button/Text"):GetComponent(Text),
            receiveImage = item:Find("Button"):GetComponent(Image),
            nameText = item:Find("Name"):GetComponent(Text),
            timesText = item:Find("Times"):GetComponent(Text),
            itemImageLoader = SingleIconLoader.New(item:Find("Bg/Icon").gameObject)
        }
        self.itemList[i].btnExt = MsgItemExt.New(self.itemList[i].receiveText, 150, 20, 23)
        self.itemList[i].timesText.gameObject:SetActive(false)
        self.itemList[i].nameText.gameObject:SetActive(false)
        self.itemList[i].receiveBtn.onClick:AddListener(function() self:OnClick(i) end)
        self.itemList[i].bgBtn.onClick:AddListener(function() self:ClickBgItem(i) end)
        local rect = self.itemList[i].receiveText.gameObject:GetComponent(RectTransform)
        -- rect.anchorMax = Vector2(0,1)
        -- rect.anchorMin = Vector2(0,1)
        rect.anchorMax = Vector2(0.5,0.5)
        rect.anchorMin = Vector2(0.5,0.5)
        rect.sizeDelta = Vector2(150, 48)
        -- rect.pivot = Vector2(0, 1)
    end

    if self.icon ~= nil then
        t:Find("Bg/Title/Icon"):GetComponent(Image).sprite = self.icon
        t:Find("Bg/Title/Icon").gameObject:SetActive(true)
    else
        t:Find("Bg/Title/Icon").gameObject:SetActive(false)
    end
end

function RewardIOU:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RewardIOU:OnOpen()
    if self:InitData() ~= true then
        return
    end

    self:InitUI()

    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateUIListener)
end

function RewardIOU:OnHide()
    self:RemoveListeners()
end

function RewardIOU:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateUIListener)
end

function RewardIOU:OnClick(index)
    local campaignData = self.itemList[index].data
    local sure = function()
        if campaignData ~= nil then
            CampaignManager.Instance:Send14001(campaignData.id)
        end
    end
    local campaignData_cli = DataCampaign.data_list[campaignData.id]
    if #(campaignData_cli.loss_items) == 0 then
        sure()
        return
    end

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(self.sureNoticeString, tostring(campaignData_cli.loss_items[1][1]), tostring(campaignData_cli.loss_items[1][2]))
    data.sureLabel = self.checkForRewardString
    data.cancelLabel = self.iWantToBuyString[2]
    data.sureCallback = function() self:ClickBgItem(index) end
    data.showClose = 1
    data.blueSure = true
    data.greenCancel = true
    data.cancelCallback = sure

    if self.model.isFirstConfrimRewardIOU == nil or self.model.isFirstConfrimRewardIOU == 0 then
        NoticeManager.Instance:ConfirmTips(data)
        self.model.isFirstConfrimRewardIOU = 1
    else
        sure()
    end
end

function RewardIOU:ClickBgItem(index)
    local data = self.itemList[index].data
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    if data ~= nil then
        local campaignData = DataCampaign.data_list[data.id]
        local itemBaseId = 0
        local rewardDataList = campaignData.reward
        for i,v in ipairs(rewardDataList) do
            if #v == 2 then
                itemBaseId = tonumber(v[1])
                break
            elseif #v == 3 then
                itemBaseId = tonumber(v[1])
                break
            elseif (tonumber(v[1]) == 0 or tonumber(classes) == tonumber(v[1]))
                and (tonumber(v[2]) == 2 or tonumber(sex) == tonumber(v[2])) then
                itemBaseId = tonumber(v[3])
                break
            end
        end
        local baseData = DataItem.data_get[itemBaseId]

        if baseData ~= nil then
            TipsManager.Instance:ShowItem({gameObject = self.itemList[index].bgBtn.gameObject, itemData = baseData, extra = {nobutton = true, inbag = false}})
        end
        -- if self.model.giftPreview == nil then
        --     self.model.giftPreview = GiftPreview.New(self.model.bibleWin.gameObject)
        -- end
        -- self.model.giftPreview:Show({reward = campaignData.reward, autoMain = true, text = self.giftString})
    end
end

function RewardIOU:InitData()
    if self.inited ~= true then
        if self.campaignData == nil then
            return false
        end
        self.showData = self.campaignData.sub
        self.inited = true
    end
    return self.inited
end

function RewardIOU:InitUI()
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    for i=1,2 do
        local data = self.showData[i]
        local campaignData = DataCampaign.data_list[data.id]
        self.itemList[i].data = data
        if #campaignData.loss_items == 0 then
            self.itemList[i].timesText.gameObject:SetActive(true)
            btnString = self.iWantToBuyString[1]
            self.itemList[i].timesText.text = self.canBuyString[1]
        else
            self.itemList[i].timesText.gameObject:SetActive(true)
            self.itemList[i].timesText.text = string.format(self.canBuyString[2], tostring(data.reward_can), tostring(data.reward_max))
            btnString = string.format(self.iWantToBuyString[3], campaignData.loss_items[1][2], campaignData.loss_items[1][1])
        end
        self.itemList[i].btnExt:SetData(btnString)
        if data.status == CampaignEumn.Status.Accepted then
            if #campaignData.loss_items == 0 then
                self.itemList[i].timesText.gameObject:SetActive(true)
                self.itemList[i].btnExt:SetData(self.hasBuyString[1])
                self.itemList[i].timesText.text = self.canBuyString[1]
            else
                self.itemList[i].timesText.gameObject:SetActive(true)
                self.itemList[i].timesText.text = string.format(self.canBuyString[2], tostring(data.reward_can), tostring(data.reward_max))
                self.itemList[i].btnExt:SetData(self.hasBuyString[2])
            end
            self.itemList[i].receiveBtn.enabled = false
            -- BaseUtils.SetGrey(self.itemList[i].receiveImage, true)
            self.itemList[i].receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.itemList[i].receiveText.color = ColorHelper.DefaultButton4
        else
            local btnString = nil
            local diamondRect = self.itemList[i].receiveText.gameObject.transform:Find("Image")
            if diamondRect ~= nil then
                diamondRect = diamondRect:GetComponent(RectTransform)
                if campaignData.loss_items[1][2] > 999 then
                    diamondRect.anchoredPosition = Vector2(52, 3)
                elseif campaignData.loss_items[1][2] > 99 then
                    diamondRect.anchoredPosition = Vector2(41, 3)
                end
                diamondRect = nil
            end
            self.itemList[i].receiveBtn.enabled = true
            if #campaignData.loss_items == 0 then
                self.itemList[i].receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                self.itemList[i].receiveText.color = ColorHelper.DefaultButton2
            else
                self.itemList[i].receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                self.itemList[i].receiveText.color = ColorHelper.DefaultButton1
            end
        end
        local itemBaseId = 0
        local rewardDataList = campaignData.reward
        for _,v in ipairs(rewardDataList) do
            if #v == 2 then
                itemBaseId = tonumber(v[1])
                break
            elseif #v == 3 then
                itemBaseId = tonumber(v[1])
                break
            elseif (tonumber(classes) == tonumber(v[1]) or tonumber(v[1]) == 0)
                and (tonumber(sex) == tonumber(v[2]) or tonumber(v[2]) == 2) then
                itemBaseId = tonumber(v[3])
                break
            end
        end
        local baseData = DataItem.data_get[itemBaseId]

        if baseData ~= nil then
            self.itemList[i].itemImageLoader:SetSprite(SingleIconType.Item, baseData.icon)
            self.itemList[i].nameText.text = baseData.name
            self.itemList[i].nameText.gameObject:SetActive(true)
        end

        local size = self.itemList[i].btnExt.contentTrans.sizeDelta
        self.itemList[i].btnExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, size.y/2)
    end

    local data = self.showData[1]
    local campaignData = DataCampaign.data_list[data.id]

    if self.descExtText ~= nil then self.descExtText:DeleteMe() end
    self.descExtText = MsgItemExt.New(self.descText, 520, 17, 20)
    self.descExtText:SetData(string.format(self.descFormatString, campaignData.content))

    self.timeText.text = string.format(self.timeFormatString,
        string.format(self.dateFormatString, tostring(campaignData.cli_start_time[1][1]),tostring(campaignData.cli_start_time[1][2]),tostring(campaignData.cli_start_time[1][3])),
        string.format(self.dateFormatString, tostring(campaignData.cli_end_time[1][1]),tostring(campaignData.cli_end_time[1][2]),tostring(campaignData.cli_end_time[1][3])))

    self.titleText.text = campaignData.timestr
end



