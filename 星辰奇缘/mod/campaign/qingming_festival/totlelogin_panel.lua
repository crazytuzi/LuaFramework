-- 清明植树面板
TotleLoginPanel = TotleLoginPanel or BaseClass(BasePanel)

function TotleLoginPanel:__init(main)
    self.main = main
    self.name = "TotleLoginPanel"

    self.resList = {
        {file = AssetConfig.totlelogin_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.type = SpringFestivalEumn.Type.TotleLogin
    self.datalist = {}
    self.listener = function()
        self:UpdateBtn()
    end
    self.slotlist = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function TotleLoginPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TotleLoginPanel:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function TotleLoginPanel:OnOpen()
    self:UpdateBtn(true)

    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.listener)
end

function TotleLoginPanel:OnHide()
    self:RemoveListeners()
end

function TotleLoginPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.listener)
end

function TotleLoginPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.totlelogin_panel))
    UIUtils.AddUIChild(self.main.rightContainer, self.gameObject)
    self.gameObject.name = "TotleLoginPanel"
    self.transform = self.gameObject.transform

    self.datalist = self.main:GetCampaignData(self.type)
    self.baseItem = self.transform:Find("MaskScroll/Container/Day1")
    self.Container = self.transform:Find("MaskScroll/Container")
    self.scrollLayerRect = self.transform:Find("MaskScroll"):GetComponent(RectTransform)
    self.containerRect = self.Container:GetComponent(RectTransform)
    self.containerRect.anchorMax = Vector2(0.5,1)
    self.containerRect.anchorMin = Vector2(0.5,1)
    self.containerRect.pivot = Vector2(0.5,1)
    self.containerRect.anchoredPosition = Vector2(0, 0)
    self:InitList()
end

function TotleLoginPanel:InitList()
    self.Container.sizeDelta = Vector2(550, 990)
    for i=8,10 do
        if i > 7 then
            item = GameObject.Instantiate(self.baseItem.gameObject)
            item.name = "Day"..tostring(i)
            item = item.transform
            item:SetParent(self.Container)
            item.anchoredPosition = Vector2(275, -(i-1)*99)
            item.localScale = Vector3(1, 1, 1)
        end
    end
    for i=1, #self.datalist do
        local item = self.transform:Find(string.format("MaskScroll/Container/Day%s", tostring(i)))

        item:Find("DayText"):GetComponent(Text).text = string.format(TI18N("第%s天"), tostring(i))
        local data = self.datalist[i]
        for ii=1,3 do
            local slotRT = item:Find(string.format("Item%s",tostring(ii)))
            if data.rewardgift[ii] ~= nil then
                local slot = ItemSlot.New()
                local info = ItemData.New()
                local base = DataItem.data_get[data.rewardgift[ii][1]]
                if base == nil then
                    Log.Error("[日程]道具id配错():[baseid:" .. tostring(baseid) .. "]")
                end
                info:SetBase(base)
                local extra = {inbag = false, nobutton = true}
                slot:SetAll(info, extra)
                slot:SetNum(data.rewardgift[ii][2])
                UIUtils.AddUIChild(slotRT.gameObject,slot.gameObject)
                table.insert(self.slotlist, slot)
                slotRT:Find("NameText"):GetComponent(Text).text = base.name
            else
                slotRT.gameObject:SetActive(false)
            end
        end
        if CampaignManager.Instance.campaignTab[data.id] ~= nil and CampaignManager.Instance.campaignTab[data.id].status ~= 0 then
            if CampaignManager.Instance.campaignTab[data.id].reward_can >0 and CampaignManager.Instance.campaignTab[data.id].status == 1 then
                item:Find("Button"):GetComponent(Button).onClick:AddListener(function()
                    CampaignManager.Instance:Send14001(data.id)
                end)
            else
                item:Find("Button").gameObject:SetActive(false)
                item:Find("FinishText").gameObject:SetActive(true)
            end
        else
            item:Find("Button").gameObject:SetActive(false)
        end
    end
end

function TotleLoginPanel:UpdateBtn(relocate)
    local canRed = false
    local firstCanGet = nil
    for i=1,#self.datalist do
        local item = self.transform:Find(string.format("MaskScroll/Container/Day%s", tostring(i)))
        local data = self.datalist[i]
        if CampaignManager.Instance.campaignTab[data.id] ~= nil and CampaignManager.Instance.campaignTab[data.id].status ~= 0 then
            if CampaignManager.Instance.campaignTab[data.id].reward_can >0 and CampaignManager.Instance.campaignTab[data.id].status == 1 then
                canRed = true
                if firstCanGet == nil then
                    firstCanGet = i
                end
                item:Find("Button"):GetComponent(Button).onClick:AddListener(function()
                    CampaignManager.Instance:Send14001(data.id)
                end)
            else
                item:Find("Button").gameObject:SetActive(false)
                item:Find("FinishText").gameObject:SetActive(true)
            end
        else
            item:Find("Button").gameObject:SetActive(false)
        end
    end
    BibleManager.Instance.redPointDic[4][1] = canRed
    BibleManager.Instance.onUpdateRedPoint:Fire()

    if relocate == true and firstCanGet ~= nil then
        local y = (firstCanGet - 1) * 99
        if self.containerRect.sizeDelta.y - y < self.scrollLayerRect.sizeDelta.y then
            y = self.containerRect.sizeDelta.y - self.scrollLayerRect.sizeDelta.y
        end

        self.containerRect.anchoredPosition = Vector2(0, y)
    end
end
