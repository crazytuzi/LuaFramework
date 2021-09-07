ChildBirthFlowerPanel = ChildBirthFlowerPanel or BaseClass(BasePanel)

function ChildBirthFlowerPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ChildBirthFlowerPanel"
    self.mgr = OpenBetaManager.Instance

    self.btnString = TI18N("%s{assets_2, %s}购买")
    self.resList = {
        {file = AssetConfig.child_flower_panel, type = AssetType.Main},
        --{file = AssetConfig.child_flower_bg, type = AssetType.Main},
        {file = AssetConfig.sevencolor_bg, type = AssetType.Main},
        {file = AssetConfig.childbirth_textures, type = AssetType.Dep},
        {file = AssetConfig.worldlevgiftitem3, type = AssetType.Dep},
    }
    self.timeFormatString1 = TI18N("活动剩余时间：<color='%s'>%s天%s小时%s分</color>")
    self.timeFormatString2 = TI18N("活动剩余时间：<color='%s'>%s小时%s分</color>")
    self.timeFormatString3 = TI18N("活动剩余时间：<color='%s'>%s分</color>")
    self.timeFormatString4 = TI18N("活动剩余时间：<color='%s'>%s秒</color>")
    self.timeFormatString5 = TI18N("活动已结束")

    self.flowerColor = {
        "Yellow",
        "Red",
        "Green",
        "Pink",
        "Blue",
        "Purple",
        "Cyan",
    }


    self.perNum = 9

    self.slotList = {}
    self.effectList = {}
    self.flowerList = {}

    self.onTimeListener = function() self:OnTimeListener() end
    self.flowerListener = function(count) self:LightUpFlowers(count) end
    self.campaignListener = function() self:CheckState() end
    self.showEffectListener = function() self:ShowEffect(true) end
    self.count = 0

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ChildBirthFlowerPanel:__delete()
    self.OnHideEvent:Fire()
    if self.itemImageiconloader ~= nil then
        self.itemImageiconloader:DeleteMe()
        self.itemImageiconloader = nil
    end
    if self.qualityBgImage ~= nil then
        self.qualityBgImage.sprite = nil
        self.qualityBgImage = nil
    end
    if self.itemImage ~= nil then
        self.itemImage.sprite = nil
        self.itemImage = nil
    end
    if self.rechargeTextExt ~= nil then
        self.rechargeTextExt:DeleteMe()
        self.rechargeTextExt = nil
    end
    if self.slotList ~= nil then
        for _,v in pairs(self.slotList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slotList = nil
    end
    if self.effectList ~= nil then
        for _,v in pairs(self.effectList) do
            v:DeleteMe()
        end
        self.effectList = nil
    end
    if self.btnEffect ~= nil then
        self.btnEffect:DeleteMe()
        self.btnEffect = nil
    end
    if self.arrowEffect ~= nil then
        self.arrowEffect:DeleteMe()
        self.arrowEffect = nil

    end
    if self.gridLayout ~= nil then
        self.gridLayout:DeleteMe()
        self.gridLayout = nil
    end
    if self.model.giftPanel ~= nil then
        self.model.giftPanel:DeleteMe()
        self.model.giftPanel = nil
    end
    self:AssetClearAll()
end
function ChildBirthFlowerPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.child_flower_panel))
    self.gameObject.name = self.name

    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    local t = self.transform:Find("Bg").transform


    UIUtils.AddBigbg(t:Find("BackGroundBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.sevencolor_bg)))




    self.scrollRect = t:Find("RectScroll"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function() self:OnGridChange() end)

    self.container = self.scrollRect.transform:Find("Container")
    self.gridLayout = LuaGridLayout.New(self.container, {cellSizeX = 60, cellSizeY = 60, cspacing = 2, borderleft = 20, bordertop = 12, rspacing = 12, cspacing = 10, column = 4})




    self.rechargeBtn = self.transform:Find("Bg/Button"):GetComponent(CustomButton)

    self.rechargeBtnRect = self.rechargeBtn.gameObject:GetComponent(RectTransform)
    self.rechargeTextExt = MsgItemExt.New(t:Find("Button/Text"):GetComponent(Text), 140, 20, 22.45)
    self.receiveImage = self.rechargeBtn.gameObject:GetComponent(Image)

    self.noticeText = t:Find("Notice/Text"):GetComponent(Text)
    self.noticeText.text = TI18N("每购买<color='#00ff00'>9</color>个新春礼炮<color='#00ff00'>可点亮</color>一个七彩灯笼,全部点亮可领<color='#00ff00'>珍稀大礼</color>")

    self.itemBtn = t:Find("EffectItem"):GetComponent(Button)
    self.itemImage = t:Find("EffectItem/Icon"):GetComponent(Image)
    self.qualityBgImage = t:Find("EffectItem/QualityBg"):GetComponent(Image)
    self.effectBg = t:Find("EffectItem/Effect")
    self.effectBg.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.worldlevgiftitem3,"worldlevitemlight3")

    self.campaignData_cli = DataCampaign.data_list[self.campId]
    self.campaignData_cli_ext = DataCampaign.data_list[self.campId + 1]

    local itemData = ItemData.New()
    itemData:SetBase(DataItem.data_get[tonumber(CampaignManager.ItemFilter(self.campaignData_cli.reward)[1][1])])
    if self.itemImageiconloader == nil then
        self.itemImageiconloader = SingleIconLoader.New(self.itemImage.gameObject)
    end
    self.itemImageiconloader:SetSprite(SingleIconType.Item, itemData.icon)
    local quality = itemData.quality
    quality = quality or 0
    quality = quality + 1
    if quality < 4 then
        self.qualityBgImage.gameObject:SetActive(false)
    else
        self.qualityBgImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Item%s", quality))
        self.qualityBgImage.gameObject:SetActive(true)
    end
    self.itemBtn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.itemBtn.gameObject, itemData = itemData, extra = {inbag = false, nobutton = true}}) end)

    --itemSlot
    local itemlist = CampaignManager.ItemFilter(self.campaignData_cli.rewardgift)
    for i,v in ipairs(itemlist) do
        self.slotList[i] = ItemSlot.New()
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[v[1]])
        self.slotList[i]:SetAll(itemData, {inbag = false, nobutton = true})
        self.slotList[i]:SetNum(v[2])

        self.slotList[i].transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"ItemDefaultRed")

        if v[3] == 1 then
            if self.effectList[i] == nil then
                self.effectList[i] = BibleRewardPanel.ShowEffect(20223, self.slotList[i].transform, Vector3.one, Vector3(30, -30, -400))
            end
        else
            if self.effectList[i] ~= nil then
                self.effectList[i]:DeleteMe()
                self.effectList[i] = nil
            end
        end
        self.gridLayout:AddCell(self.slotList[i].gameObject)
    end

    local flower = t:Find("Flowers")
    for k,v in pairs(self.flowerColor) do
        local tab = {}
        tab.transform = flower:Find(v)
        tab.gameObject = tab.transform.gameObject
        tab.image = tab.gameObject:GetComponent(Image)
        tab.grayImage = tab.transform:Find("Gray"):GetComponent(Image)
        BaseUtils.SetGrey(tab.grayImage, true)
        tab.index = k
        tab.value = 1
        self.flowerList[k] = tab
        local j = k
        local btn = tab.gameObject:GetComponent(Button)
        if btn == nil then
            btn = tab.gameObject:AddComponent(Button)
        end
        btn.onClick:AddListener(function() self:OnGift(true) self:ShowEffect(false) end)
        btn = tab.grayImage.gameObject:GetComponent(Button)
        if btn == nil then
            btn = tab.grayImage.gameObject:AddComponent(Button)
        end
        tab.grayImage.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnGift(true) self:ShowEffect(false) end)
    end

    self.giftBtn = t:Find("Gift"):GetComponent(Button)
    self.giftBtn.transform.anchoredPosition = Vector2(115, 97)
    self.giftBtn.onClick:AddListener(function() self:OnGift() self:ShowEffect(false) end)

    self.slider = t:Find("Slider"):GetComponent(Slider)
    self.slider.onValueChanged:AddListener(function(value) self:OnSlider(value) end)
    self.slider.gameObject:SetActive(false)

    self.rechargeBtn.onClick:AddListener(function() self:OnClick() end)
    self.rechargeBtn.onHold:AddListener(function() self:OnNumberpad() end)
    self.rechargeBtn.onDown:AddListener(function() self:OnDown() end)
    self.rechargeBtn.onUp:AddListener(function() self:OnUp() end)
    self.targetMomont = os.time{year = self.campaignData_cli.cli_end_time[1][1], month = self.campaignData_cli.cli_end_time[1][2], day = self.campaignData_cli.cli_end_time[1][3], hour = self.campaignData_cli.cli_end_time[1][4], min = self.campaignData_cli.cli_end_time[1][5], sec = self.campaignData_cli.cli_end_time[1][6]}

    self:OnGridChange()
end

function ChildBirthFlowerPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ChildBirthFlowerPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onTickTime:AddListener(self.onTimeListener)
    EventMgr.Instance:AddListener(event_name.campaign_change, self.campaignListener)
    ChildBirthManager.Instance.onFlowerCountEvent:AddListener(self.flowerListener)

    self:CheckState()
    self.timerId = LuaTimer.Add(0, 10, function() self:RotateEffect() end)
    self:ShakeTheButton()

    self.gridLayout.panel.transform.anchoredPosition = Vector2(0, 0)
end

function ChildBirthFlowerPanel:OnHide()
    if self.shakeTimer ~= nil then
        LuaTimer.Delete(self.shakeTimer)
        self.shakeTimer = nil
    end
    if self.model.giftPanel ~= nil then
        self.model.giftPanel.OnHideEvent:Remove(self.showEffectListener)
    end
    self:RemoveListeners()
end

function ChildBirthFlowerPanel:RemoveListeners()
    self.mgr.onTickTime:RemoveListener(self.onTimeListener)
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.campaignListener)
    ChildBirthManager.Instance.onFlowerCountEvent:RemoveListener(self.flowerListener)

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function ChildBirthFlowerPanel:OnTimeListener()
    local d = nil
    local h = nil
    local m = nil
    local s = nil
    if BaseUtils.BASE_TIME < self.targetMomont then
        d,h,m,s = BaseUtils.time_gap_to_timer(self.targetMomont - BaseUtils.BASE_TIME)
        if d ~= 0 then
            self.timeText.text = string.format(self.timeFormatString1, "#e8faff", tostring(d), tostring(h), tostring(m))
        elseif h ~= 0 then
            self.timeText.text = string.format(self.timeFormatString2, "#e8faff", tostring(h), tostring(m))
        elseif m ~= 0 then
            self.timeText.text = string.format(self.timeFormatString3, "#e8faff", tostring(m))
        else
            self.timeText.text = string.format(self.timeFormatString4, "#e8faff", tostring(s))
        end
    else
        self.timeText.text = self.timeFormatString5
    end
end

function ChildBirthFlowerPanel:OnClick()
    local protoData = CampaignManager.Instance.campaignTab[self.campaignData_cli.id]
    if protoData ~= nil then
        if protoData.status == CampaignEumn.Status.Finish or protoData.status == CampaignEumn.Status.Doing then
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.content = string.format(TI18N("确定花费<color='#00ff00'>%s</color>{assets_2,%s}购买<color=#ffff00>%s</color>吗？\n<color='#00ff00'>（长按购买可以批量购买）</color>"), tostring(self.campaignData_cli.loss_items[1][2]), tostring(self.campaignData_cli.loss_items[1][1]), DataItem.data_get[tonumber(self.campaignData_cli.reward[1][1])].name)
            confirmData.sureLabel = TI18N("确 定")
            confirmData.cancelLabel = TI18N("取 消")
            confirmData.sureCallback = function() ChildBirthManager.Instance:send17823(1) end
            NoticeManager.Instance:ConfirmTips(confirmData)
            return
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("你已经购买过此礼包了哦~"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动已结束~"))
    end
end

function ChildBirthFlowerPanel:CheckState()
    self:LightUpFlowers()

    local protoData = CampaignManager.Instance.campaignTab[self.campaignData_cli.id]
    if protoData ~= nil then
        if protoData.status == CampaignEumn.Status.Finish or protoData.status == CampaignEumn.Status.Doing then
            self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.rechargeTextExt.contentTxt.color = ColorHelper.DefaultButton3
            self.rechargeTextExt:SetData(string.format(self.btnString, tostring(self.campaignData_cli.loss_items[1][2]), tostring(self.campaignData_cli.loss_items[1][1])))
        else
            self.rechargeTextExt.contentTxt.color = ColorHelper.DefaultButton4
            self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.rechargeTextExt:SetData(TI18N("已领取"))
        end
    else
        self.rechargeTextExt.contentTxt.color = ColorHelper.DefaultButton4
        self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.rechargeTextExt:SetData(TI18N("已结束"))
    end

    local size = self.rechargeTextExt.contentRect.sizeDelta
    local sizeBtn = self.rechargeBtnRect.sizeDelta
    self.rechargeTextExt.contentRect.anchoredPosition = Vector2(sizeBtn.x / 2 - size.x / 2, size.y / 2 - sizeBtn.y / 2)
end

function ChildBirthFlowerPanel:OnNumberpad()
    local price = self.campaignData_cli.loss_items[1][2]
    local all = 0
    for k,v in pairs(KvData.assets) do
        if v == self.campaignData_cli.loss_items[1][1] then
            all = RoleManager.Instance.RoleData[k]
            break
        end
    end
    local numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.rechargeBtn.gameObject,
        min_result = 1,
        max_by_asset = math.floor(all / price),
        max_result = 50,
        textObject = nil,
        show_num = false,
        returnKeep = true,
        funcReturn = function(num) ChildBirthManager.Instance:send17823(num) end,
        callback = nil,
        show_num = true,
        returnText = TI18N("购买"),
    }
    NumberpadManager.Instance:set_data(numberpadSetting)
end

function ChildBirthFlowerPanel:OnDown()
    self.isUp = false
    LuaTimer.Add(150, function()
        if self.isUp then
            return
        end
        if self.arrowEffect == nil then
            self.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.rechargeBtn.gameObject.transform, Vector3(1, 1.5, 1), Vector3(0, 61, -400))
        else
            self.arrowEffect.gameObject:SetActive(false)
            self.arrowEffect.gameObject:SetActive(true)
        end
    end)
end

function ChildBirthFlowerPanel:OnUp()
    self.isUp = true
    if self.arrowEffect ~= nil then
        self.arrowEffect:SetActive(false)
    end
end

function ChildBirthFlowerPanel:RotateEffect()
    self.count = (self.count + 1) % 360
    self.effectBg.rotation = Quaternion.Euler(0, 0, self.count)
end

-- 点亮花瓣
function ChildBirthFlowerPanel:LightUpFlowers(c)
    local count = c or (self.model.flowerData or {}).count or 0
    if count < 7 * self.perNum then
        if self.btnEffect ~= nil then
            self.btnEffect:SetActive(false)
        end
    else
        if self.btnEffect == nil then
            self.btnEffect = BibleRewardPanel.ShowEffect(20118, self.giftBtn.transform, Vector3(0.9, 1.9, 1), Vector3(-45,50, -400))
        else
            self.btnEffect:SetActive(true)
        end
    end

    if count > 7 * self.perNum then
        count = 7 * self.perNum
    end
    for i,v in ipairs(self.flowerColor) do
        self:OnTmpClick(i)
        self:OnSlider((count - (i - 1) * self.perNum - 1) /(self.perNum - 1))
    end
end

function ChildBirthFlowerPanel:OnShowFinalGift(itemlist, title)
    if self.model.giftPanel == nil then
        self.model.giftPanel = GiftPreview.New(self.parent.gameObject)
        self.model.giftPanel.OnHideEvent:Add(self.showEffectListener)
    end
    self.model.giftPanel.titleLineHeight = 21
    self.model.giftPanel.titleWidth = 400
    self.model.giftPanel.showClose = false
    self.model.giftPanel:Show({text = title, autoMain = true, column = 4, reward = itemlist})
end

function ChildBirthFlowerPanel:ShakeTheButton()
    if self.shakeTimer == nil then
        self.shakeTimer = LuaTimer.Add(1000, 3000, function()
            self.giftBtn.gameObject.transform.localScale = Vector3(1.2,1.1,1)
            Tween.Instance:Scale(self.giftBtn.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)
    end
end

function ChildBirthFlowerPanel:OnGift(isShow)
    local count = count or (self.model.flowerData or {}).count or 0
    if count < 7 * self.perNum or (isShow == true) then
        local myCount = count - 1
        local addNum = 1
        if myCount < 0 then
            myCount = 0
            addNum = 0
        end
        self:OnShowFinalGift(CampaignManager.ItemFilter(self.campaignData_cli_ext.rewardgift), string.format(TI18N("点亮全部七彩灯笼开启礼包后，可直接获得以下道具中的一个(本轮已购买<color='#00ff00'>%s</color>/%s个)"), tostring(myCount % (7 * self.perNum) + addNum), tostring(7 * self.perNum)))
    else
        ChildBirthManager.Instance:send17822()
    end
end


-- 以下是测试代码。。。。。。。。。。。。。。。。。。。
-- 好吧，现在不是测试代码了。。。

function ChildBirthFlowerPanel:OnTmpClick(i)
    self.selectIndex = i
    self.slider.value = self.flowerList[i].value
end

function ChildBirthFlowerPanel:OnSlider(value)

    -- 前期测试函数, 不要删

    -- local func1 = function(v)
    --     if v < 0.5 then
    --         return 9 * v / 5
    --     else
    --         return 0.8 + v / 5
    --     end
    -- end

    -- local func2 = function(v)
    --     if v < 0.5 then
    --         return 1 - v / 5
    --     else
    --         return 1.8 - 9 * v / 5
    --     end
    -- end

    if self.selectIndex ~= nil then
        local tab = self.flowerList[self.selectIndex]
        local cutter = 0.77

        -- local midColorAlpha = func1(cutter)
        -- local midGrayAlpha = func2(cutter)

        local midColorAlpha = 0.95
        local midGrayAlpha = 0.45

        if value < 0.5 then
            tab.image.color = Color(1, 1, 1, midColorAlpha * value / 0.5)
            tab.grayImage.color = Color(1, 1, 1, 1 - (1 - midGrayAlpha) * value / 0.5)
        else
            tab.image.color = Color(1, 1, 1, midColorAlpha + (1 - midColorAlpha) * (value - 0.5) / 0.5)
            tab.grayImage.color = Color(1, 1, 1, midGrayAlpha - midGrayAlpha * (value - 0.5) / 0.5)
        end

        tab.value = value
    end
end

function ChildBirthFlowerPanel:OnGridChange()
    local y = self.container.anchoredPosition.y
    local height = self.container.parent:GetComponent(RectTransform).rect.height
    for i,v in pairs(self.slotList) do
        if v.transform.sizeDelta.y - (y + v.transform.anchoredPosition.y) > height or y + v.transform.anchoredPosition.y > 0 then
            if self.effectList[i] ~= nil then
                self.effectList[i]:SetActive(false)
            end
        else
            if self.effectList[i] ~= nil then
                self.effectList[i]:SetActive(true)
            end
        end
    end
end

function ChildBirthFlowerPanel:ShowEffect(bool)
    local itemlist = CampaignManager.ItemFilter(self.campaignData_cli.rewardgift)
    for i,v in ipairs(itemlist) do
        if v[3] == 1 then
            self.effectList[i].gameObject:SetActive(bool)
        end
    end
    if bool then
        self:OnGridChange()
    end
end
