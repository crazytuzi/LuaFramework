-- @author 黄耀聪
-- @date 2016年8月8日
-- 公测活动

OpenBetaCeremony = OpenBetaCeremony or BaseClass(BasePanel)

function OpenBetaCeremony:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "OpenBetaCeremony"
    self.mgr = OpenBetaManager.Instance

    self.resList = {
        {file = AssetConfig.open_beta_ceremony, type = AssetType.Main},
        {file = AssetConfig.bigatlas_open_beta_bg2, type = AssetType.Main},
        {file = AssetConfig.open_beta_textures, type = AssetType.Dep},
    }
    self.slotList = {}
    self.campaignData_cli = DataCampaign.data_list[309]
    self.timeFormatString1 = TI18N("活动剩余时间：<color='#00ff00'>%s天%s小时%s分%s秒</color>")
    self.timeFormatString2 = TI18N("活动剩余时间：<color='#00ff00'>%s小时%s分%s秒</color>")
    self.timeFormatString3 = TI18N("活动剩余时间：<color='#00ff00'>%s分%s秒</color>")
    self.timeFormatString4 = TI18N("活动剩余时间：<color='#00ff00'>%s秒</color>")
    self.onTimeListener = function() self:OnTimeListener() end
    self.campaignListener = function() self:CheckState() end
    self.effectList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenBetaCeremony:__delete()
    self.OnHideEvent:Fire()
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
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.effect1 ~= nil then
        self.effect1:DeleteMe()
        self.effect1 = nil
    end

    self.receiveImage.sprite = nil
    self.receiveImage = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenBetaCeremony:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_beta_ceremony))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("Bg"):GetComponent(Image).enabled = false
    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_open_beta_bg2)))

    self.container = t:Find("Bg/Scroll/Container")
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 5, border = 10})
    self.receiveBtn = t:Find("Bg/Button"):GetComponent(Button)
    self.receiveText = t:Find("Bg/Button/I18N_Text"):GetComponent(Text)
    self.receiveImage = t:Find("Bg/Button"):GetComponent(Image)
    self.receiveBtn.onClick:AddListener(function() self:OnClick() end)

    for i,v in ipairs(self.campaignData_cli.reward) do
        self.slotList[i] = ItemSlot.New()
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[v[1]])
        self.slotList[i]:SetAll(itemData, {inbag = false, nobutton = true})
        self.slotList[i]:SetNum(v[2], nil)
        self.layout:AddCell(self.slotList[i].gameObject)
        if itemData.quality >= 4 then
            self.effectList[i] = BibleRewardPanel.ShowEffect(20053, self.slotList[i].gameObject.transform, Vector3(1, 1, 1), Vector3(0, -24.1, -400))
        end
    end

    self.timeText = t:Find("Time/Clock/Text"):GetComponent(Text)

    self.targetMomont = os.time{year = self.campaignData_cli.cli_end_time[1][1], month = self.campaignData_cli.cli_end_time[1][2], day = self.campaignData_cli.cli_end_time[1][3], hour = self.campaignData_cli.cli_end_time[1][4], min = self.campaignData_cli.cli_end_time[1][5], sec = self.campaignData_cli.cli_end_time[1][6]}
end

function OpenBetaCeremony:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenBetaCeremony:OnOpen()
    self:RemoveListeners()
    self.mgr.onTickTime:AddListener(self.onTimeListener)
    EventMgr.Instance:AddListener(event_name.campaign_change, self.campaignListener)

    self:CheckState()
end

function OpenBetaCeremony:OnHide()
    self:RemoveListeners()
end

function OpenBetaCeremony:RemoveListeners()
    self.mgr.onTickTime:RemoveListener(self.onTimeListener)
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.campaignListener)
end

function OpenBetaCeremony:OnTimeListener()
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

function OpenBetaCeremony:CheckState()
    local protoData = CampaignManager.Instance.campaignTab[self.campaignData_cli.id]
    if protoData ~= nil then
        if protoData.status == CampaignEumn.Status.Doing then
            self.receiveImage.sprite = self.assetWrapper:GetSprite(AssetConfig.open_beta_textures, "I18N_OBT_GoRecharge")
            self.receiveImage.gameObject.transform.sizeDelta = Vector2(160, 60)
            -- self.receiveText.text = TI18N("前往充值")
            self.receiveText.gameObject:SetActive(false)
            self:ShowEffect1()
        elseif protoData.status == CampaignEumn.Status.Finish then
            self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.receiveImage.gameObject.transform.sizeDelta = Vector2(110, 40)
            self.receiveText.text = TI18N("领取奖励")
            self.receiveText.gameObject:SetActive(true)
            if self.effect1 ~= nil then
                self.effect1:DeleteMe()
                self.effect1 = nil
            end
        else
            self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.receiveImage.gameObject.transform.sizeDelta = Vector2(110, 40)
            self.receiveText.text = TI18N("已领取")
            self.receiveText.gameObject:SetActive(true)
            if self.effect1 ~= nil then
                self.effect1:DeleteMe()
                self.effect1 = nil
            end
        end
    else
        self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.receiveImage.gameObject.transform.sizeDelta = Vector2(110, 40)
        self.receiveText.text = TI18N("已结束")
        self.receiveText.gameObject:SetActive(true)
        if self.effect1 ~= nil then
            self.effect1:DeleteMe()
            self.effect1 = nil
        end
    end
end

function OpenBetaCeremony:OnClick()
    local protoData = CampaignManager.Instance.campaignTab[self.campaignData_cli.id]
    if protoData ~= nil then
        if protoData.status == CampaignEumn.Status.Doing then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
            return
        elseif protoData.status == CampaignEumn.Status.Finish then
            CampaignManager.Instance:Send14001(protoData.id)
            return
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("你已经领取过奖励了哦~"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动已结束~"))
    end
end

function OpenBetaCeremony:ShowEffect1()
    if self.effect1 == nil then
        self.effect1 = BibleRewardPanel.ShowEffect(20176, self.receiveBtn.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
    else
        self.effect1.gameObject:SetActive(true)
    end
end



