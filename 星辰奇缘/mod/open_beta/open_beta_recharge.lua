-- @author 黄耀聪
-- @date 2016年8月8日
-- 公测活动

OpenBetaRecharge = OpenBetaRecharge or BaseClass(BasePanel)

function OpenBetaRecharge:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "OpenBetaRecharge"
    self.mgr = OpenBetaManager.Instance

    self.btnString = TI18N("%s{assets_2, %s}购买")
    self.resList = {
        {file = AssetConfig.open_beta_recharge, type = AssetType.Main},
        {file = AssetConfig.bigatlas_open_beta_bg1, type = AssetType.Main},
    }
    self.campaignData_cli = DataCampaign.data_list[310]
    self.timeFormatString1 = TI18N("活动剩余时间：<color='#e8faff'>%s天%s小时%s分%s秒</color>")
    self.timeFormatString2 = TI18N("活动剩余时间：<color='#e8faff'>%s小时%s分%s秒</color>")
    self.timeFormatString3 = TI18N("活动剩余时间：<color='#e8faff'>%s分%s秒</color>")
    self.timeFormatString4 = TI18N("活动剩余时间：<color='#e8faff'>%s秒</color>")
    self.timeFormatString5 = TI18N("活动已结束")

    self.slotList = {}
    self.onTimeListener = function() self:OnTimeListener() end
    self.campaignListener = function() self:CheckState() end
    self.count = 0

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenBetaRecharge:__delete()
    self.OnHideEvent:Fire()
    if self.qualityBgImage ~= nil then
        self.qualityBgImage.sprite = nil
        self.qualityBgImage = nil
    end
    if self.itemLoader ~= nil then
        self.itemLoader.sprite = nil
        self.itemLoader = nil
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
    if self.gridLayout ~= nil then
        self.gridLayout:DeleteMe()
        self.gridLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenBetaRecharge:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_beta_recharge))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("Bg"):GetComponent(Image).enabled = false
    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_open_beta_bg1)))

    self.container = t:Find("Bg/Scroll/Container")
    self.gridLayout = LuaGridLayout.New(self.container, {cellSizeX = 60, cellSizeY = 60, cspacing = 2, borderleft = 20, bordertop = 12, rspacing = 12, cspacing = 10, column = 4})

    self.timeText = t:Find("Time/Clock/Text"):GetComponent(Text)
    self.rechargeBtn = t:Find("Button"):GetComponent(CustomButton)
    self.rechargeBtnRect = self.rechargeBtn.gameObject:GetComponent(RectTransform)
    self.rechargeTextExt = MsgItemExt.New(t:Find("Button/Text"):GetComponent(Text), 140, 20, 22.45)
    self.receiveImage = self.rechargeBtn.gameObject:GetComponent(Image)
    self.noticeBtn = t:Find("Notice"):GetComponent(Button)

    self.itemBtn = t:Find("Bg/Item"):GetComponent(Button)
    self.itemLoader = SingleIconLoader.New(t:Find("Bg/Item/Icon").gameObject)
    self.qualityBgImage = t:Find("Bg/Item/QualityBg"):GetComponent(Image)
    self.effectBg = t:Find("Bg/Effect")
    t:Find("Bg/Item/LimitBg").gameObject:SetActive(false)
    t:Find("Bg/Item/Limit").gameObject:SetActive(false)

    local itemData = ItemData.New()
    itemData:SetBase(DataItem.data_get[tonumber(self.campaignData_cli.camp_cond_client)])
    self.itemLoader:SetSprite(SingleIconLoader.Item, itemData.icon)
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

    for i,v in ipairs(self.campaignData_cli.rewardgift) do
        self.slotList[i] = ItemSlot.New()
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[v[1]])
        self.slotList[i]:SetAll(itemData, {inbag = false, nobutton = true})
        self.slotList[i]:SetNum(v[2], nil)
        self.gridLayout:AddCell(self.slotList[i].gameObject)
    end

    self.rechargeBtn.onClick:AddListener(function() self:OnClick() end)
    self.rechargeBtn.onHold:AddListener(function() self:OnNumberpad() end)
    self.rechargeBtn.onDown:AddListener(function() self:OnDown() end)
    self.rechargeBtn.onUp:AddListener(function() self:OnUp() end)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    self.targetMomont = os.time{year = self.campaignData_cli.cli_end_time[1][1], month = self.campaignData_cli.cli_end_time[1][2], day = self.campaignData_cli.cli_end_time[1][3], hour = self.campaignData_cli.cli_end_time[1][4], min = self.campaignData_cli.cli_end_time[1][5], sec = self.campaignData_cli.cli_end_time[1][6]}
end

function OpenBetaRecharge:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenBetaRecharge:OnOpen()
    self:RemoveListeners()
    self.mgr.onTickTime:AddListener(self.onTimeListener)
    EventMgr.Instance:AddListener(event_name.campaign_change, self.campaignListener)

    self:CheckState()
    self.timerId = LuaTimer.Add(0, 10, function() self:RotateEffect() end)
end

function OpenBetaRecharge:OnHide()
    self:RemoveListeners()
end

function OpenBetaRecharge:RemoveListeners()
    self.mgr.onTickTime:RemoveListener(self.onTimeListener)
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.campaignListener)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function OpenBetaRecharge:OnTimeListener()
    local d = nil
    local h = nil
    local m = nil
    local s = nil
    if BaseUtils.BASE_TIME < self.targetMomont then
        d,h,m,s = BaseUtils.time_gap_to_timer(self.targetMomont - BaseUtils.BASE_TIME)
        if d ~= 0 then
            self.timeText.text = string.format(self.timeFormatString1, tostring(d), tostring(h), tostring(m), tostring(s))
        elseif h ~= 0 then
            self.timeText.text = string.format(self.timeFormatString2, tostring(h), tostring(m), tostring(s))
        elseif m ~= 0 then
            self.timeText.text = string.format(self.timeFormatString3, tostring(m), tostring(s))
        else
            self.timeText.text = string.format(self.timeFormatString4, tostring(s))
        end
    else
        self.timeText.text = self.timeFormatString5
    end
end

function OpenBetaRecharge:OnClick()
    local protoData = CampaignManager.Instance.campaignTab[self.campaignData_cli.id]
    if protoData ~= nil then
        if protoData.status == CampaignEumn.Status.Finish then
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.content = string.format(TI18N("确定花费<color='#00ff00'>%s</color>{assets_2,%s}购买<color=#ffff00>%s</color>吗？\n<color='#00ff00'>（长按购买可以批量购买）</color>"), tostring(self.campaignData_cli.loss_items[1][2]), tostring(self.campaignData_cli.loss_items[1][1]), DataItem.data_get[tonumber(self.campaignData_cli.camp_cond_client)].name)
            confirmData.sureLabel = TI18N("确 定")
            confirmData.cancelLabel = TI18N("取 消")
            confirmData.sureCallback = function() ShopManager.Instance:send11303(20, 1) end
            NoticeManager.Instance:ConfirmTips(confirmData)
            return
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("你已经购买过此礼包了哦~"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动已结束~"))
    end
end

function OpenBetaRecharge:CheckState()
    local protoData = CampaignManager.Instance.campaignTab[self.campaignData_cli.id]
    if protoData ~= nil then
        if protoData.status == CampaignEumn.Status.Finish then
            self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.rechargeTextExt:SetData(string.format(self.btnString, tostring(self.campaignData_cli.loss_items[1][2]), tostring(self.campaignData_cli.loss_items[1][1])))
        else
            self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.rechargeTextExt:SetData(TI18N("已领取"))
        end
    else
        self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.rechargeTextExt:SetData(TI18N("已结束"))
    end

    local size = self.rechargeTextExt.contentRect.sizeDelta
    local sizeBtn = self.rechargeBtnRect.sizeDelta
    self.rechargeTextExt.contentRect.anchoredPosition = Vector2(sizeBtn.x / 2 - size.x / 2, size.y / 2 - sizeBtn.y / 2)
end

function OpenBetaRecharge:OnNumberpad()
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
        funcReturn = function(num) ShopManager.Instance:send11303(20, num) end,
        callback = nil,
        show_num = true,
        returnText = TI18N("购买"),
    }
    NumberpadManager.Instance:set_data(numberpadSetting)
end

function OpenBetaRecharge:OnDown()
    self.isUp = false
    LuaTimer.Add(150, function()
        if self.isUp then
            return
        end
        if self.arrowEffect == nil then
            self.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.rechargeBtn.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 61, -400))
        else
            self.arrowEffect.gameObject:SetActive(false)
            self.arrowEffect.gameObject:SetActive(true)
        end
    end)
end

function OpenBetaRecharge:OnUp()
    self.isUp = true
    if self.arrowEffect ~= nil then
        self.arrowEffect.gameObject:SetActive(false)
    end
end

function OpenBetaRecharge:OnNotice()
    local tipsText = {
        TI18N("<color='#ffff00'>长按</color>可批量购买"),
    }
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = tipsText})
end

function OpenBetaRecharge:RotateEffect()
    self.count = (self.count + 1) % 360
    self.effectBg.rotation = Quaternion.Euler(0, 0, self.count)
end