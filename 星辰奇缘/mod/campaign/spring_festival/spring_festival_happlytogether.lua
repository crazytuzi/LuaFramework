-- ----------------------------
-- 春节活动-- 全民过春节
-- hosr
-- ----------------------------
HappyTogether = HappyTogether or BaseClass(BasePanel)

function HappyTogether:__init(main)
    self.main = main
    self.path = "prefabs/ui/springfestival/happytogether.unity3d"
    self.effectPath = "prefabs/effect/20110.unity3d"

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = self.effectPath, type = AssetType.Dep},
    }
    self.type = SpringFestivalEumn.Type.HappyTogether
    self.index = 1

    self.slotList = {}
    self.valList = {}
    self.effectList = {}

    self.OnHideEvent:Add(function() self:OnHide() end)
    self.OnOpenEvent:Add(function() self:OnShow() end)

    -- 当前进度值
    self.currentValue = 0
    self.maxValue = 1

    self.maxWidth = 500
    self.widthList = {85, 200, 325, 450}

    self.listener = function() self:UpdateProgress() end
end

function HappyTogether:__delete()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.listener)
    for k,v in pairs(self.slotList) do
        v:DeleteMe()
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.currentValue = 0
end

function HappyTogether:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "HappyTogether"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.rightTransform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.timeTxt = self.transform:Find("Time"):GetComponent(Text)
    self.contextTxt = self.transform:Find("Content"):GetComponent(Text)
    self.txt1 = self.transform:Find("TimeTxt"):GetComponent(Text)
    self.txt2 = self.transform:Find("ContentTxt"):GetComponent(Text)

    self.timeTxt.text = ""
    self.contextTxt.text = ""
    self.txt1.text = TI18N("活动时间:")
    self.txt2.text = TI18N("活动内容:")

    self.bar = self.transform:Find("BarBg/Bar").gameObject
    self.barRect = self.bar:GetComponent(RectTransform)
    self.barTxt = self.bar.transform:Find("Image/Text"):GetComponent(Text)
    self.barTxt.text = ""

    local slot1 = ItemSlot.New(self.transform:Find("Slot1/ItemSlot").gameObject)
    local slot2 = ItemSlot.New(self.transform:Find("Slot2/ItemSlot").gameObject)
    local slot3 = ItemSlot.New(self.transform:Find("Slot3/ItemSlot").gameObject)
    local slot4 = ItemSlot.New(self.transform:Find("Slot4/ItemSlot").gameObject)
    self.slotList = {slot1, slot2, slot3, slot4}

    local val1 = self.transform:Find("BarBg/Val1/Text"):GetComponent(Text)
    local val2 = self.transform:Find("BarBg/Val2/Text"):GetComponent(Text)
    local val3 = self.transform:Find("BarBg/Val3/Text"):GetComponent(Text)
    local val4 = self.transform:Find("BarBg/Val4/Text"):GetComponent(Text)
    self.valList = {val1, val2, val3, val4}

    local effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    Utils.ChangeLayersRecursively(effect.transform, "UI")
    effect.transform:SetParent(slot1.transform)
    effect.transform.localScale = Vector3.one
    effect.transform.localPosition = Vector3(0, 0, -100)
    effect:SetActive(false)
    table.insert(self.effectList, effect)

    effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    Utils.ChangeLayersRecursively(effect.transform, "UI")
    effect.transform:SetParent(slot2.transform)
    effect.transform.localScale = Vector3.one
    effect.transform.localPosition = Vector3(0, 0, -100)
    effect:SetActive(false)
    table.insert(self.effectList, effect)

    effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    Utils.ChangeLayersRecursively(effect.transform, "UI")
    effect.transform:SetParent(slot3.transform)
    effect.transform.localScale = Vector3.one
    effect.transform.localPosition = Vector3(0, 0, -100)
    effect:SetActive(false)
    table.insert(self.effectList, effect)

    effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    Utils.ChangeLayersRecursively(effect.transform, "UI")
    effect.transform:SetParent(slot4.transform)
    effect.transform.localScale = Vector3.one
    effect.transform.localPosition = Vector3(0, 0, -100)
    effect:SetActive(false)
    table.insert(self.effectList, effect)

    self:OnShow(true)

    EventMgr.Instance:AddListener(event_name.campaign_change, self.listener)
end

function HappyTogether:OnShow(isInit)
    self.dataList = self.main:GetCampaignData(self.type)
    self.campaignData = self.dataList[1]

    if isInit then
        self:ShowTime()
        self.contextTxt.text = self.campaignData.cond_desc
        self:ShowAward()
    end

    self:UpdateProgress()
end

function HappyTogether:ShowTime()
    local start = self.campaignData.cli_start_time[1]
    local over = self.campaignData.cli_end_time[1]
    local str = string.format(TI18N("%s年%s月%s日-%s年%s月%s日"), start[1], start[2], start[3], over[1], over[2], over[3])
    self.timeTxt.text = str
end

function HappyTogether:OnHide()
    for i,v in ipairs(self.effectList) do
        v:SetActive(false)
    end
end

function HappyTogether:ShowAward()
    for i,v in ipairs(self.dataList) do
        local index = i
        self.valList[i].text = v.camp_cond_client
        local itemId = v.reward[1][1]
        local num = v.reward[1][2]

        local itemData = BaseUtils.copytab(DataItem.data_get[itemId])
        itemData.quantity = num
        if itemData ~= nil then
            local slot = self.slotList[i]
            slot:SetAll(itemData, {nobutton = true})
            slot:SetSelectSelfCallback(function() self:ClickOne(index) end)
        end
    end
end

function HappyTogether:UpdateProgress()
    self.currentValue = 0
    self.maxValue = 0
    local currentWidth = 0
    local currentMaxWidth = 0
    local lastValue = 0
    table.sort(self.dataList, function(a,b) return tonumber(a.camp_cond_client) < tonumber(b.camp_cond_client) end)

    for i,campaignData in ipairs(self.dataList) do
        local protoData = CampaignManager.Instance:GetCampaignData(campaignData.id)

        -- if i == 1 then
        --     protoData.status = CampaignEumn.Status.Accepted
        --     protoData.value = 0
        -- elseif i == 2 then
        --     protoData.status = CampaignEumn.Status.Finish
        --     protoData.value = 0
        -- elseif i == 3 then
        --     protoData.status = CampaignEumn.Status.Accepted
        --     protoData.value = 56
        -- elseif i == 4 then
        --     protoData.status = CampaignEumn.Status.Doing
        --     protoData.value = 119
        -- end

        campaignData.protoData = protoData
        if protoData ~= nil then
            if protoData.status == CampaignEumn.Status.Doing then
                -- 未完成
                if self.maxValue == 0 then
                    self.currentValue = protoData.value
                    self.maxValue = protoData.target_val
                    currentWidth = self.widthList[i - 1] or 0
                    currentMaxWidth = self.widthList[i]
                end
                self.effectList[i]:SetActive(false)
                self.slotList[i]:SetGrey(false)
            elseif protoData.status == CampaignEumn.Status.Finish then
                -- 完成未领取
                lastValue = math.max(lastValue , protoData.target_val)
                self.effectList[i]:SetActive(true)
                self.slotList[i]:SetGrey(false)
            elseif protoData.status == CampaignEumn.Status.Accepted then
                -- 已领取
                lastValue = math.max(lastValue , protoData.target_val)
                self.effectList[i]:SetActive(false)
                self.slotList[i]:SetGrey(true)
            end
        end
    end

    -- print(self.currentValue)
    -- print(self.maxValue)
    -- print(currentWidth)
    -- print(currentMaxWidth)
    -- print(lastValue)

    if self.maxValue == 0 then
        self.currentValue = 120
    end
    self.currentValue = math.min(self.currentValue, 120)
    self.barTxt.text = tostring(self.currentValue)

    local width = 0
    if self.currentValue == 120 then
        width = self.maxWidth
    else
        width = (currentMaxWidth - currentWidth) * ((self.currentValue - lastValue) / (self.maxValue - lastValue)) + currentWidth
    end

    self.barRect.sizeDelta = Vector2(width, 16)
end

function HappyTogether:ClickOne(index)
    local campaignData = self.dataList[index]
    if campaignData.protoData ~= nil and campaignData.protoData.status == CampaignEumn.Status.Finish then
        CampaignManager.Instance:Send14001(campaignData.id)
    end
end
