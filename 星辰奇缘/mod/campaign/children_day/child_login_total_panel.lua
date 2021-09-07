-- @author 黄耀聪
-- @date 2016年5月25日

LoginTotalPanel = LoginTotalPanel or BaseClass(BasePanel)

function LoginTotalPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "LoginTotalPanel"

    self.resList = {
        {file = AssetConfig.login_total_panel, type = AssetType.Main}
        , {file = AssetConfig.may_textures, type = AssetType.Dep}
    }

    self.mysteryString = TI18N("神秘奖励")
    self.timeString = TI18N("活动时间:<color=#C7F9FF>%s-%s</color>")
    self.dateFormatString = TI18N("%s年%s月%s日")
    self.descString = {TI18N("<color=#FFFF9A>当前已累积登陆</color><color=#13FC60>%s</color><color=#FFFF9A>天</color>"), TI18N("<color=#7EB9F7>活动内容:</color>%s")}
    self.receiveString = {TI18N("领取奖励"), TI18N("已领取")}
    self.messageBackString = TI18N("你当前累积登陆天数不足暂时无法领取")
    self.itemList = {nil, nil, nil}
    self.slotList = {nil, nil, nil}

    self.reloadListener = function() self:InitUI() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function LoginTotalPanel:__delete()
    self.OnHideEvent:Fire()
    if self.slotList ~= nil then
        for k,v in pairs(self.slotList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slotList = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function LoginTotalPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.login_total_panel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.bgImage = t:Find("Bg"):GetComponent(Image)
    self.bgRect = self.bgImage.gameObject:GetComponent(RectTransform)
    self.bgIconImage = t:Find("Bg/Title/Icon"):GetComponent(Image)
    self.bgTitleText = t:Find("Bg/Title/Text"):GetComponent(Text)
    self.infoImage = t:Find("Info"):GetComponent(Image)

    self.timeText = t:Find("Info/Time"):GetComponent(Text)
    self.descText = t:Find("Info/Desc"):GetComponent(Text)

    self.receiveBtn = t:Find("Bottom/Button"):GetComponent(Button)
    self.receiveImage = t:Find("Bottom/Button"):GetComponent(Image)
    self.receiveText = t:Find("Bottom/Button/Text"):GetComponent(Text)

    for i=1,3 do
        local tab = {obj = nil, trans = nil, nameText = nil, descText = nil, cont = nil, imageObj = nil, icon = nil, hasGetObj = nil}
        tab.obj = t:Find("Item"..i).gameObject
        tab.trans = tab.obj.transform
        tab.nameText = tab.trans:Find("Name"):GetComponent(Text)
        tab.descText = tab.trans:Find("TimeText"):GetComponent(Text)
        tab.cont = tab.trans:Find("Bg")
        tab.image = tab.trans:Find("Bg/Image"):GetComponent(Image)
        tab.hasGetObj = tab.trans:Find("TickImage").gameObject
        tab.imageObj = tab.image.gameObject
        self.itemList[i] = tab
        self.slotList[i] = ItemSlot.New()
        NumberpadPanel.AddUIChild(tab.cont.gameObject, self.slotList[i].gameObject)
        self.slotList[i].gameObject:SetActive(false)
    end

    self.receiveBtn.onClick:AddListener(function() self:OnClick() end)
    self.infoImage.color = Color(1, 1, 1, 0.8)
end

function LoginTotalPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function LoginTotalPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.reloadListener)

    self:InitUI()
end

function LoginTotalPanel:OnHide()
    self:RemoveListeners()
end

function LoginTotalPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.reloadListener)
end

function LoginTotalPanel:OnClick()
    if self.finishId ~= nil and self.finishId > 0 then
        CampaignManager.Instance:Send14001(self.finishId)
    else
        NoticeManager.Instance:FloatTipsByString(self.messageBackString)
    end
end

function LoginTotalPanel:InitUI()
    self.protoData = nil
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.Children] ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.Children][CampaignEumn.ChildType.Login] ~= nil then
        self.protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Children][CampaignEumn.ChildType.Login].sub
    end
    if self.protoData ~= nil then
        self.finishId = 0
        for i,v in ipairs(self.protoData) do
            local tab = self.itemList[i]
            local campaignData = DataCampaign.data_list[v.id]
            if v.status ~= CampaignEumn.Status.Accepted then
                tab.nameText.text = self.mysteryString
                tab.image = self.assetWrapper:GetSprite(AssetConfig.may_textures, "Exume")
                tab.imageObj:SetActive(true)
                if v.status == CampaignEumn.Status.Finish and self.finishId <= 0 then
                    self.finishId = v.id
                end
                tab.hasGetObj:SetActive(false)
            else
                tab.imageObj:SetActive(true)
                tab.hasGetObj:SetActive(true)
            end
            self.slotList[i].gameObject:SetActive(true)
            local itemData = ItemData.New()
            local baseData = DataItem.data_get[DataCampaign.data_list[self.protoData[i].id].reward[1][1]]
            itemData:SetBase(baseData)
            self.slotList[i]:SetAll(itemData, {inbag = false, nobutton = true})
            tab.nameText.text = baseData.name
            tab.descText.text = campaignData.cond_desc
            if i == #self.protoData and self.finishId <= 0 then
                self.finishId = -1
            end

            if self.protoData[3].value > 0 then
                self.descText.text = string.format(self.descString[1], tostring(self.protoData[3].value))
            else
                self.descText.text = string.format(self.descString[2], DataCampaign.data_list[self.protoData[3].id].content)
            end
        end
    end

    if self.openArgs ~= nil then
        local openArgs = self.openArgs
        self.bgTitleText.text = openArgs.activityName
        -- self.titleText.text = openArgs.name

        self.timeText.text = string.format(self.timeString,
            string.format(self.dateFormatString, tostring(openArgs.startTime[1]),tostring(openArgs.startTime[2]),tostring(openArgs.startTime[3])),
            string.format(self.dateFormatString, tostring(openArgs.endTime[1]),tostring(openArgs.endTime[2]),tostring(openArgs.endTime[3])))

        self.target = openArgs.target
        self.bgIconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, openArgs.icon)
        self.bgImage.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, openArgs.bg)
    end

    -- if self.finishId == -1 then
    --     self.receiveText.text = self.receiveString[2]
    --     -- self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    --     -- self.receiveBtn.enabled = false
    -- else
        self.receiveText.text = self.receiveString[1]
    --     self.receiveBtn.enabled = true
    --     self.receiveImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    -- end

    if self.finishId ~= nil and self.finishId > 0 then
        if self.effect == nil then
            self.effect = BibleRewardPanel.ShowEffect(20118, self.receiveBtn.gameObject.transform, Vector3(1.08, 0.7, 1), Vector3(-54, 19.7, -100))
        end
    else
        if self.effect ~= nil then
            self.effect:DeleteMe()
            self.effect = nil
        end
    end
end

