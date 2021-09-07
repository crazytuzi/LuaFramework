-- 累充奖励
-- @author huangyaoc
-- @date 20160517

TotalReturn = TotalReturn or BaseClass(BasePanel)

function TotalReturn:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "TotalReturn"

    self.campaignData = nil     -- 对应的活动数据

    self.rechargeFormat = TI18N("充值<color=#ECC858>%s</color>钻以上可领取")
    self.rechargeDesc = TI18N("活动累充")
    self.rechargeBtnDesc = TI18N("立即充值")
    self.receiveBtnDesc = TI18N("领取奖励")
    self.dateFormat = TI18N("%s月%s日%s:%s")
    self.giftNameList = {TI18N("<color=#ff36d7>%s"), TI18N("<color=#f58140>%s")}
    self.boxName = TI18N("礼盒</color>")
    self.giftString = TI18N("使用获得以下所有道具：")

    self.iconId = {29318, 29317}

    self.giftPreview = nil
    self.updateUIListener = function() self:InitUI() end

    self.resList = {
        {file = AssetConfig.total_return_panel, type = AssetType.Main}
        , {file = AssetConfig.may_textures, type = AssetType.Dep}
        , {file = AssetConfig.witch_girl, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function TotalReturn:__delete()
    self.OnHideEvent:Fire()
    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end
    if self.receiveEffect ~= nil then
        self.receiveEffect:DeleteMe()
        self.receiveEffect = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v.showLoader ~= nil then
                v.showLoader:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function TotalReturn:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.total_return_panel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    local girlArea = t:Find("GirlArea")
    local giftArea = t:Find("GiftArea")
    local titleArea = t:Find("TitleArea")
    local totalArea = t:Find("TotalArea")

    self.jumpToRechargeBtn = girlArea:Find("GotoCharge"):GetComponent(Button)
    self.rechargeBtn = girlArea:Find("Receive"):GetComponent(Button)
    self.activityDateText = titleArea:Find("Date"):GetComponent(Text)
    self.totalText = totalArea:Find("Text"):GetComponent(Text)

    girlArea:Find("GotoCharge/Text"):GetComponent(Text).text = self.rechargeBtnDesc
    girlArea:Find("Receive/Text"):GetComponent(Text).text = self.receiveBtnDesc
    totalArea:Find("Desc"):GetComponent(Text).text = self.rechargeDesc
    girlArea:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.witch_girl, "Witch")

    self.itemList = {nil, nil}
    for i=1,#self.campaignData.sub do
        local tab = {}
        local campaignData = DataCampaign.data_list[self.campaignData.sub[i].id]
        giftArea:Find(string.format("Show/Item%s/Name", tostring(i))):GetComponent(Text).text = string.format(self.giftNameList[i], campaignData.reward_content).."</color>"
        giftArea:Find(string.format("Desc/Item%s/Name", tostring(i))):GetComponent(Text).text = string.format(self.giftNameList[i], campaignData.reward_content)..self.boxName
        giftArea:Find("Show/Item"..i):GetComponent(Button).enabled = false
        giftArea:Find("Show/Item"..i.."/Bg"):GetComponent(Button).enabled = false
        giftArea:Find("Desc/Item"..i):GetComponent(Button).onClick:AddListener(function() self:OnShowItems(i) end)
        giftArea:Find("Desc/Item"..i):GetComponent(TransitionButton).scaleSetting = true

        tab.levelChargeText = giftArea:Find(string.format("Desc/Item%s/Desc", tostring(i))):GetComponent(Text)
        tab.itemImage = giftArea:Find(string.format("Desc/Item%s/Bg/Icon", tostring(i))):GetComponent(Image)
        tab.showLoader = SingleIconLoader.New(giftArea:Find(string.format("Show/Item%s/Bg/Icon", tostring(i))).gameObject)
        tab.maskTrans = giftArea:Find(string.format("Desc/Item%s/Bg/Mask", tostring(i)))
        self.itemList[i] = tab
    end

    -- giftArea:Find("Show/Item1/Name"):GetComponent(Text).text = self.giftNameList[1].."</color>"
    -- giftArea:Find("Show/Item2/Name"):GetComponent(Text).text = self.giftNameList[2].."</color>"
    -- giftArea:Find("Desc/Item1/Name"):GetComponent(Text).text = self.giftNameList[1]..self.boxName
    -- giftArea:Find("Desc/Item2/Name"):GetComponent(Text).text = self.giftNameList[2]..self.boxName

    -- self.levelChargeText1 = giftArea:Find("Desc/Item1/Desc"):GetComponent(Text)
    -- self.levelChargeText2 = giftArea:Find("Desc/Item2/Desc"):GetComponent(Text)
    -- self.itemImage1 = giftArea:Find("Desc/Item1/Bg/Icon"):GetComponent(Image)
    -- self.itemImage2 = giftArea:Find("Desc/Item2/Bg/Icon"):GetComponent(Image)

    self.itemList[1].levelChargeText.text = string.format(self.rechargeFormat, "1200")
    self.itemList[2].levelChargeText.text = string.format(self.rechargeFormat, "0")

    titleArea:GetComponent(RectTransform).sizeDelta = Vector2(300, 96)
    titleArea:GetComponent(Image).preserveAspect = false

    self.jumpToRechargeBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)
    self.rechargeBtn.onClick:AddListener(function() self:OnReceive() end)
end

function TotalReturn:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TotalReturn:OnOpen()
    if self:InitData() ~= true then
        return
    end

    self:InitUI()

    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateUIListener)
end

function TotalReturn:OnHide()
    self:RemoveListeners()
end

function TotalReturn:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateUIListener)
end

function TotalReturn:InitData()
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    if self.inited ~= true then
        if self.campaignData == nil then
            return false
        end
        self.showData = {}
        for i,v in ipairs(self.campaignData.sub) do
            local campaignData_cli = DataCampaign.data_list[v.id]
            local tab = {id = nil, target = nil, startTime = nil, endTime = nil, reward = nil, status = nil, value = nil}
            tab.id = v.id
            tab.target = v.target_val
            tab.value = v.value
            tab.endTime = tonumber(os.time{year = campaignData_cli.cli_end_time[1][1], month = campaignData_cli.cli_end_time[1][2], day = campaignData_cli.cli_end_time[1][3], hour = campaignData_cli.cli_end_time[1][4], min = campaignData_cli.cli_end_time[1][5], sec = campaignData_cli.cli_end_time[1][6]})
            tab.startTime = tonumber(os.time{year = campaignData_cli.cli_start_time[1][1], month = campaignData_cli.cli_start_time[1][2], day = campaignData_cli.cli_start_time[1][3], hour = campaignData_cli.cli_start_time[1][4], min = campaignData_cli.cli_start_time[1][5], sec = campaignData_cli.cli_start_time[1][6]})

            local rewardList = CampaignManager.ItemFilter(campaignData_cli.reward)
            tab.reward = rewardList
            tab.status = v.status
            self.showData[i] = tab
        end

        self.startTime = self.showData[1].startTime
        self.endTime = self.showData[1].endTime
        for i,v in ipairs(self.showData) do
            if self.startTime < v.startTime then self.startTime = v.startTime end
            if self.endTime > v.endTime then self.endTime = v.endTime end
        end
        self.inited = true
    end
    return self.inited
end

function TotalReturn:InitUI()
    local m1 = tostring(tonumber(os.date("%m", self.startTime)))
    local d1 = tostring(os.date("%d", self.startTime))
    local H1 = tostring(os.date("%H", self.startTime))
    local M1 = tostring(os.date("%M", self.startTime))
    local m2 = tostring(tonumber(os.date("%m", self.endTime)))
    local d2 = tostring(os.date("%d", self.endTime))
    local H2 = tostring(os.date("%H", self.endTime))
    local M2 = tostring(os.date("%M", self.endTime))
    self.activityDateText.text = string.format(self.dateFormat, m1, d1, H1, M1).."-"..string.format(self.dateFormat, m2, d2, H2, M2)

    local canReceive = 0
    if self.receiveEffect ~= nil then self.receiveEffect:DeleteMe() self.receiveEffect = nil end
    for i,v in ipairs(self.campaignData.sub) do
        if v.status == CampaignEumn.Status.Finish then
            canReceive = 1
            if self.receiveEffect == nil then
                self.receiveEffect = BibleRewardPanel.ShowEffect(20118, self.rechargeBtn.gameObject.transform, Vector3(1.17, 0.73, 0), Vector3(-58, 40, -100))
            else
                self.receiveEffect:SetActive(true)
            end
            break
        end
        canReceive = 2
    end
    self.rechargeBtn.gameObject:SetActive(canReceive == 1)
    self.jumpToRechargeBtn.gameObject:SetActive(canReceive ~= 1)

    for i,v in ipairs(self.campaignData.sub) do
        local campaignData = DataCampaign.data_list[v.id]
        self.itemList[i].levelChargeText.text = string.format(self.rechargeFormat, tostring(v.target_val))
        self.itemList[i].showLoader:SetSprite(SingleIconType.Item, DataItem.data_get[tonumber(campaignData.reward_title) or 90000].icon)
        -- BaseUtils.SetGrey(self.itemList[i].itemImage, v.status == CampaignEumn.Status.Accepted)
        if self.itemList[i].maskTrans ~= nil then
            self.itemList[i].maskTrans.gameObject:SetActive(v.status == CampaignEumn.Status.Accepted)
        end
    end
    self.totalText.text = tostring(self.campaignData.sub[1].value)
end

function TotalReturn:OnReceive()
    for i,v in ipairs(self.campaignData.sub) do
        if v.status == CampaignEumn.Status.Finish then
            CampaignManager.Instance:Send14001(v.id)
            break
        end
    end
end

function TotalReturn:OnShowItems(index)
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    if self.campaignData ~= nil then
        local campaignData_cli = DataCampaign.data_list[self.showData[index].id]
        if self.giftPreview == nil then
            self.giftPreview = GiftPreview.New(self.model.mainWin.gameObject)
        end
        local rewardList = {}
        local rewardDataList = CampaignManager.ItemFilter(campaignData_cli.rewardgift)
        for i,v in ipairs(rewardDataList) do
            if #v == 2 then
                table.insert(rewardList, {v[1], v[2]})
            elseif (tonumber(v[1]) == 0 or tonumber(classes) == tonumber(v[1]))
                and (tonumber(v[2]) == 2 or tonumber(sex) == tonumber(v[2])) then
                table.insert(rewardList, {v[3], v[4]})
            end
        end
        self.giftPreview:Show({reward = rewardList, autoMain = true, text = self.giftString})
    end
end
