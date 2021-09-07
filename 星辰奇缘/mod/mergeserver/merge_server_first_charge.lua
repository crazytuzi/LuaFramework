-- @author 黄耀聪
-- @date 2016年6月17日

MergeServerFirstCharge = MergeServerFirstCharge or BaseClass(BasePanel)

function MergeServerFirstCharge:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MergeServerFirstCharge"

    self.resList = {
        {file = AssetConfig.mergeserver_first_charge, type = Main},
        {file = AssetConfig.witch_girl, type = Dep},
    }
    self.timeString = TI18N("活动时间:<color='#13fc60'>%s-%s</color>")
    self.dateFormatString = TI18N("%s年%s月%s日")

    self.btnString = {
        [0] = TI18N("立即充值"),
        [1] = TI18N("领 取"),
        [2] = TI18N("已领取")
    }

    self.updateListener = function() self:InitUI() end

    self.itemList = {}
    self.effectList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MergeServerFirstCharge:__delete()
    self.OnHideEvent:Fire()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.effectList ~= nil then
        for _,v in pairs(self.effectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
    end

    if self.witchImage ~= nil then 
        self.witchImage.sprite = nil
    end
    
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MergeServerFirstCharge:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mergeserver_first_charge))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.titleText = t:Find("TitleArea/Title/Text"):GetComponent(Text)
    self.titleImage = t:Find("TitleArea/Title/Icon"):GetComponent(Image)
    self.timeText = t:Find("TitleArea/Time"):GetComponent(Text)
    self.descText = t:Find("TitleArea/Desc"):GetComponent(Text)

    self.btn = t:Find("RewardArea/Button"):GetComponent(Button)
    self.btnImage = self.btn.gameObject:GetComponent(Image)
    self.btnText = t:Find("RewardArea/Button/Text"):GetComponent(Text)

    local itemContainer = t:Find("ItemArea")
    for i=1,5 do
        local tab = {trans = nil, nameText = nil, slot = nil, data = nil, rect = nil}
        tab.trans = itemContainer:GetChild(i - 1)
        tab.rect = tab.trans:GetComponent(RectTransform)
        tab.nameText = tab.trans:Find("Name"):GetComponent(Text)
        self.itemList[i] = tab
    end

    self.witchImage = itemContainer:Find("Girl"):GetComponent(Image)
    self.witchImage.sprite = self.assetWrapper:GetSprite(AssetConfig.witch_girl, "Witch")
end

function MergeServerFirstCharge:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MergeServerFirstCharge:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListener)

    self:InitUI()
end

function MergeServerFirstCharge:OnHide()
    self:RemoveListeners()
end

function MergeServerFirstCharge:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListener)
end

function MergeServerFirstCharge:InitUI()
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

    local rewardList = CampaignManager.ItemFilter(campaignData.reward)
    for i,v in ipairs(self.itemList) do
        if rewardList[i] ~= nil then
            v.trans.gameObject:SetActive(true)
            v.data = v.data or ItemData.New()
            v.data:SetBase(DataItem.data_get[rewardList[i][1]])
            if v.slot == nil then
                v.slot = ItemSlot.New()
                v.slot.gameObject.transform:SetParent(v.trans)
                v.slot.gameObject.transform.localScale = Vector3.one
                v.slot.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2.zero
            end
            v.slot:SetAll(v.data, {inbag = false, nobutton = true})
            v.slot:SetNum(rewardList[i][2])
            v.nameText.text = DataItem.data_get[rewardList[i][1]].name

            if rewardList[i][1] == 29100 then
                if self.effectList[i] == nil then
                    self.effectList[i] = BibleRewardPanel.ShowEffect(20118, v.slot.gameObject.transform, Vector3(0.6, 1.1,1), Vector3(-31,30,-400))
                end
            elseif rewardList[i][1] == 29153 then
                if self.effectList[i] == nil then
                    self.effectList[i] = BibleRewardPanel.ShowEffect(20118, v.slot.gameObject.transform, Vector3(0.6, 1.1,1), Vector3(-31,30,-400))
                end
            end
        else
            v.trans.gameObject:SetActive(false)
        end
    end

    local protoData = CampaignManager.Instance.campaignTab[self.campaignIds[1].id]
    self.btnText.text = self.btnString[protoData.status]
    self.btn.onClick:RemoveAllListeners()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    if protoData.status == CampaignEumn.Status.Accepted then
        if self.effectList[0] ~= nil then
            self.effectList[0]:DeleteMe()
            self.effectList[0] = nil
        end
        self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    elseif protoData.status == CampaignEumn.Status.Finish then
        self.effect = BibleRewardPanel.ShowEffect(20118, self.btn.transform, Vector3(1.15,0.8,1), Vector3(-58,20,-400))
        self.btn.onClick:AddListener(function() CampaignManager.Instance:Send14001(protoData.id) end)
        self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    elseif protoData.status == CampaignEumn.Status.Doing then
        if self.effectList[0] == nil then
            self.effectList[0] = BibleRewardPanel.ShowEffect(20118, self.transform:Find("RewardArea/Button"), Vector3(1.15, 0.8,1), Vector3(-57.7,22.8,-400))
        end
        self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.btn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)
    else
        print("<color=#FF0000>What is the activity's status actually ...</color>")
    end
end



