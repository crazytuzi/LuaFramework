-- @author 黄耀聪
-- @date 2016年6月17日

MergeServerTotalLogin = MergeServerTotalLogin or BaseClass(BasePanel)

function MergeServerTotalLogin:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MergeServerTotalLogin"

    self.resList = {
        {file = AssetConfig.mergeserver_total_login, type = AssetType.Main},
        {file = AssetConfig.mergeserver_bg, type = AssetType.Dep},
    }

    self.itemList = {}
    self.timeString = TI18N("活动时间:<color='#13fc60'>%s-%s</color>")
    self.dateFormatString = TI18N("%s年%s月%s日")

    self.updateListener = function() self:UpdateCell(true) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MergeServerTotalLogin:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MergeServerTotalLogin:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mergeserver_total_login))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.titleText = t:Find("TitleArea/Title/Text"):GetComponent(Text)
    self.titleImage = t:Find("TitleArea/Title/Icon"):GetComponent(Image)
    self.timeText = t:Find("TitleArea/Time"):GetComponent(Text)
    self.descText = t:Find("TitleArea/Desc"):GetComponent(Text)

    local itemContainer = t:Find("MaskScroll/Container")
    self.containerRect = itemContainer:GetComponent(RectTransform)
    self.scrollLayerRect = t:Find("MaskScroll"):GetComponent(RectTransform)
    for i=1,7 do
        local tab = {trans = nil, obj = nil, rect = nil, items = {nil, nil, nil}, btn = nil, finishObj = nil}
        tab.trans = itemContainer:FindChild("Day"..i)
        tab.obj = tab.trans.gameObject
        tab.rect = tab.obj:GetComponent(RectTransform)
        for j=1,3 do
            local tab1 = {trans, slot = nil, data = nil, nameText = nil, rect = nil}
            tab1.trans = tab.trans:FindChild("Item"..j)
            tab1.rect = tab1.trans:GetComponent(RectTransform)
            tab1.nameText = tab1.trans:Find("NameText"):GetComponent(Text)
            tab.items[j] = tab1
        end
        tab.btn = tab.trans:Find("Button"):GetComponent(Button)
        tab.btn.onClick:AddListener(function()
            CampaignManager.Instance:Send14001(self.campaignIds[i].id)
        end)
        tab.finishObj = tab.trans:Find("FinishText").gameObject
        self.itemList[i] = tab
    end

    t:Find("TitleArea"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.mergeserver_bg, "MergeServerBg")
end

function MergeServerTotalLogin:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MergeServerTotalLogin:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListener)

    self:InitUI()
end

function MergeServerTotalLogin:OnHide()
    self:RemoveListeners()
end

function MergeServerTotalLogin:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListener)
end

function MergeServerTotalLogin:InitUI()
    local model = self.model
    self.titleImage.sprite = self.sprite

    local campaignData = DataCampaign.data_list[self.campaignIds[1].id]
    self.titleText.text = campaignData.name
    self.descText.text = TI18N("<color=#7EB9F7>活动内容:</color>")..campaignData.content

    local mergeTime = CampaignManager.Instance.merge_srv_time
    local hour = tonumber(os.date("%H",mergeTime))*3600
    hour = hour + tonumber(os.date("%M",mergeTime))*60
    hour = hour + tonumber(os.date("%S",mergeTime))
    local cli_start_time = campaignData.cli_start_time[1]
    local cli_end_time = campaignData.cli_end_time[1]
    local beginTime = mergeTime - hour + cli_start_time[2] * 86400 + cli_start_time[3]
    local endTime = mergeTime - hour + cli_end_time[2] * 86400 + cli_end_time[3]

    local startYear = tonumber(os.date("%Y", beginTime))
    local startMonth = tonumber(os.date("%m", beginTime))
    local startDay = tonumber(os.date("%d", beginTime))
    local endYear = tonumber(os.date("%Y", endTime))
    local endMonth = tonumber(os.date("%m", endTime))
    local endDay = tonumber(os.date("%d", endTime))
    self.timeText.text = string.format(self.timeString,
                        string.format(self.dateFormatString,
                            tostring(startYear),
                            tostring(startMonth),
                            tostring(startDay)),
                        string.format(self.dateFormatString,
                            tostring(endYear),
                            tostring(endMonth),
                            tostring(endDay)
                        ))

    self:UpdateCell()
end

function MergeServerTotalLogin:UpdateCell(dolocation)
    for i,v in ipairs(self.campaignIds) do
        self:SetData(self.itemList[i], v, i)
    end
    local firstReceivable = 1
    for i,v in ipairs(self.campaignIds) do
        if CampaignManager.Instance.campaignTab[v.id].status == CampaignEumn.Status.Finish then
            firstReceivable = i
            break
        end
    end

    if dolocation == true then
        local y = 0 - self.itemList[firstReceivable].rect.anchoredPosition.y
        if self.containerRect.sizeDelta.y - y < self.scrollLayerRect.sizeDelta.y then
            y = self.containerRect.sizeDelta.y - self.scrollLayerRect.sizeDelta.y
        end

        self.containerRect.anchoredPosition = Vector2(0, y)
    end
end

function MergeServerTotalLogin:SetData(tab, data, index)
    if data == nil then
        tab.obj:SetActive(false)
        return
    end
    tab.obj:SetActive(true)
    local id = data.id
    local protoData = CampaignManager.Instance.campaignTab[id]
    local campaignData = DataCampaign.data_list[id]
    local rewardList = CampaignManager.ItemFilter(campaignData.reward)
    for i=1,#tab.items do
        local reward = rewardList[i]
        if reward ~= nil then
            tab.items[i].trans.gameObject:SetActive(true)
            if tab.items[i].slot == nil then
                tab.items[i].slot = ItemSlot.New()
                NumberpadPanel.AddUIChild(tab.items[i].trans.gameObject, tab.items[i].slot.gameObject)
            end
            tab.items[i].data = tab.items[i].data or ItemData.New()
            tab.items[i].data:SetBase(DataItem.data_get[reward[1]])
            tab.items[i].slot:SetAll(tab.items[i].data, {inbag = false, nobutton = true})
            tab.items[i].slot:SetNum(reward[2])
            tab.items[i].nameText.text = DataItem.data_get[reward[1]].name

            local x = tab.items[i].rect.anchoredPosition.x
            tab.items[i].rect.anchoredPosition = Vector2(x, -2)
        else
            tab.items[i].trans.gameObject:SetActive(false)
        end
        tab.items[i].nameText.gameObject:SetActive(false)
    end

    if protoData.status == CampaignEumn.Status.Accepted then
        tab.finishObj:SetActive(true)
        tab.btn.gameObject:SetActive(false)
        tab.btn.enabled = false
    elseif protoData.status == CampaignEumn.Status.Doing then
        tab.btn.enabled = false
        tab.btn.gameObject:SetActive(false)
        tab.finishObj:SetActive(false)
    else
        tab.btn.enabled = true
        tab.btn.gameObject:SetActive(true)
        tab.finishObj:SetActive(false)
    end
end

