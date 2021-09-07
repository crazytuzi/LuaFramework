-- @author Administrator
-- @date 2016年5月17日
--已弃用

BuyThreePanel = BuyThreePanel or BaseClass(BasePanel)

function BuyThreePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BuyThreePanel"

    self.dateTimeFormatString = TI18N("%s年%s月%s日%s时")
    self.noticeInfoString = TI18N("限时礼包购买截止时间为<color='#00ff00'>%s</color>，只能选择一个购买，机会难得不要错过哦！")
    self.freeBtnString = TI18N("免费领取")
    self.buyBtnString = TI18N("我要购买")
    self.hasFreeBtnString = TI18N("已领取")
    self.hasBuyBtnString = TI18N("已购买")
    self.sureNoticeString = TI18N("限时礼包只能选择其中一个购买，<color='#ffff00'>仅有一次选择机会</color>，请考虑清楚哦！")
    self.checkForRewardString = TI18N("查看奖励")
    self.giftString = TI18N("使用获得以下所有道具：")

    self.lastFormatString = TI18N("原价:<color=#C7F9FF>%s</color>")
    self.nowFormatString = TI18N("现价:<color=#C7F9FF>%s</color>")

    self.freePriceString = TI18N("免费")

    self.path = "prefabs/ui/springfestival/buybuybuy.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.shop_textures, type = AssetType.Dep},
    }

    self.itemList = {nil, nil, nil}
    self.giftPreview = nil

    self.updateUIListener = function() self:InitUI() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BuyThreePanel:__delete()
    self.OnHideEvent:Fire()
    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BuyThreePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "BuyThreePanel"
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.talkText = t:Find("TalkBg/Text"):GetComponent(Text)
    self.infoBtn = t:Find("InfoBtn"):GetComponent(Button)

    for i=1,3 do
        local item = t:Find("Container/Item"..i)
        self.itemList[i] = {
            lastText = item:Find("Last/Text"):GetComponent(Text),
            nowText = item:Find("Now/Text"):GetComponent(Text),
            buyBtn = item:Find("Button"):GetComponent(Button),
            buyImage = item:Find("Button"):GetComponent(Image),
            buyText = item:Find("Button/Text"):GetComponent(Text),
            bgBtn = item:Find("Bg"):GetComponent(Button),
            data = nil,
        }

        self.itemList[i].buyBtn.onClick:AddListener(function() self:OnClick(i) end)
        self.itemList[i].bgBtn.onClick:AddListener(function() self:OnShowItem(i) end)
    end
    self.itemList[2].buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    self.itemList[3].buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")

    self.infoBtn.onClick:AddListener(function() self:ClickInfo() end)
end

function BuyThreePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BuyThreePanel:OnOpen()
    if self:InitData() ~= true then
        return
    end

    self:InitUI()

    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateUIListener)
end

function BuyThreePanel:OnHide()
    self:RemoveListeners()
end

function BuyThreePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateUIListener)
end

function BuyThreePanel:ClickInfo()
    if self.campaignData ~= nil then
        local start = self.endTime
        local str = string.format(self.dateTimeFormatString, tostring(start[1]), tostring(start[2]), tostring(start[3]), tostring(start[4]))
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {string.format(self.noticeInfoString, str)}})
    end
end

function BuyThreePanel:InitUI()
    for i=1,3 do
        local item = self.itemList[i]
        local protoData = CampaignManager.Instance.campaignTab[self.showData[i]]
        local campaignData = DataCampaign.data_list[protoData.id]
        item.data = protoData

        item.lastText.text = string.format(self.lastFormatString, campaignData.camp_cond_client)

        if protoData.status == CampaignEumn.Status.Accepted then
            BaseUtils.SetGrey(item.buyImage, true)
            if #campaignData.loss_items == 0 then
                item.buyText.text = self.hasFreeBtnString
                item.nowText.text = string.format(self.nowFormatString, self.freePriceString)
            else
                item.buyText.text = self.hasBuyBtnString
                item.nowText.text = string.format(self.nowFormatString, tostring(campaignData.loss_items[1][2]))
            end
            item.buyBtn.enabled = false
        else
            if #campaignData.loss_items == 0 then
                item.buyText.text = self.freeBtnString
                item.nowText.text = string.format(self.nowFormatString, self.freePriceString)
            else
                item.buyText.text = self.buyBtnString
                item.nowText.text = string.format(self.nowFormatString, tostring(campaignData.loss_items[1][2]))
            end
            item.buyBtn.enabled = true
        end
    end

    self.talkText.text = self.talkString
end

function BuyThreePanel:InitData()
    if self.inited ~= true then
        if self.campaignData == nil then
            return false
        end
        self.showData = {}
        for i,v in pairs(self.campaignData.sub) do
            table.insert(self.showData, v.id)
        end
        self.endTime = DataCampaign.data_list[self.showData[1]].cli_end_time[1]
        self.talkString = DataCampaign.data_list[self.showData[1]].cond_desc
        self.inited = true
    end
    return self.inited
end

function BuyThreePanel:OnClick(index)
    local protoData = self.itemList[index].data
    local sure = function()
        if protoData ~= nil then
            CampaignManager.Instance:Send14001(protoData.id)
        end
    end
    if protoData ~= nil then
        local campaignData = DataCampaign.data_list[protoData.id]

        if #campaignData.loss_items == 0 then
            sure()
            return
        end

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = self.sureNoticeString
        data.sureLabel = self.checkForRewardString
        data.cancelLabel = self.buyBtnString
        data.sureCallback = function() self:OnShowItem(index) end
        data.showClose = 1
        data.blueSure = true
        data.greenCancel = true
        data.cancelCallback = sure
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function BuyThreePanel:OnShowItem(index)
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    local protoData = self.itemList[index].data
    if protoData ~= nil then
        local campaignData = DataCampaign.data_list[protoData.id]
        if self.giftPreview == nil then
            self.giftPreview = GiftPreview.New(self.model.bibleWin.gameObject)
        end
        local rewardList = {}
        local rewardDataList = CampaignManager.Instance.ItemFilter(campaignData.rewardgift)
        for i,v in ipairs(rewardDataList) do
            table.insert(rewardList, {v[1], v[2]})
        end
        self.giftPreview:Show({reward = rewardList, autoMain = true, text = self.giftString})
    end
end


