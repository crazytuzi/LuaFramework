-- @author jia
-- @date 2017年4月19日

NewLabourTypePanel = NewLabourTypePanel or BaseClass(BasePanel)

function NewLabourTypePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "NewLabourTypePanel"

    self.resList = {
        {file = AssetConfig.newlabourtypepanel, type = AssetType.Main},
        {file = AssetConfig.valentine_textures, type = AssetType.Dep},
        {file = AssetConfig.guidesprite, type = AssetType.Dep},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
        {file = AssetConfig.newlabertitle, type = AssetType.Dep},
        {file = AssetConfig.newlabertitle1, type = AssetType.Dep},
    }

    self.itemList = {}
    self.timeString = TI18N("活动时间:<color='#ffff00'>%s-%s</color>")
    self.dateString = TI18N("%s月%s日")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NewLabourTypePanel:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.itemList) do
        if v.slot ~= nil then
            v.slot:DeleteMe()
        end
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    self:AssetClearAll()
end

function NewLabourTypePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newlabourtypepanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.timeText = t:Find("Time"):GetComponent(Text)

    self.timeText.transform.localPosition = Vector2(-6,101.5)

    self.descExt = MsgItemExt.New(t:Find("TalkBg/Scroll/Text"):GetComponent(Text), 427, 16, 18.51)
    self.rewardLayout = LuaBoxLayout.New(t:Find("RewardArea/Scroll/Container"), {axis = BoxLayoutAxis.X, cspacing = 10, border = 5})
    self.button = t:Find("RewardArea/Button"):GetComponent(Button)

    self.button.gameObject:SetActive(false)
    t:Find("RewardArea/Scroll").sizeDelta = Vector2(340,81)
    t:Find("RewardArea/Scroll/Container").sizeDelta = Vector2(340,81)



    t:Find("RewardArea/Button/Text"):GetComponent(Text).text = self.btnName
    if self.hideBtn then
        self.button.gameObject:SetActive(false)
    end
    if self.bg ~= nil then
        UIUtils.AddBigbg(t:Find("BigBg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    end

    t:Find("BgTitle").anchoredPosition = Vector2(43,167)
    if self.campData.cond_type == CampaignEumn.ShowType.IntoGold then 
        t:Find("BgTitle"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newlabertitle1, "fivecolorMountainRivers1I18N")
    else
        t:Find("BgTitle"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newlabertitle, "fivecolorMountainRiversI18N")
    end
    t:Find("BgTitle"):GetComponent(Image):SetNativeSize()

    t:Find("Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")

    local start_time = self.campData.cli_start_time[1]
    local end_time = self.campData.cli_end_time[1]

    self.timeText.text = string.format(self.timeString,
            string.format(self.dateString, tostring(start_time[2]), tostring(start_time[3])),
            string.format(self.dateString, tostring(end_time[2]), tostring(end_time[3]))
        )

    self.descExt:SetData(self.campData.cond_desc)
    self.button.onClick:AddListener(
        function()
            if self.targetNpc ~= nil then
                QuestManager.Instance.model:FindNpc(self.targetNpc)
            end
            --self.model:CloseWindow()
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
        end)
end

function NewLabourTypePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NewLabourTypePanel:OnOpen()
    self:RemoveListeners()

    self:ReloadReward(CampaignManager.Instance.ItemFilter(self.campData.reward))
end

function NewLabourTypePanel:OnHide()
    self:RemoveListeners()
end

function NewLabourTypePanel:RemoveListeners()
end

function NewLabourTypePanel:ReloadReward(rewardList)
    self.rewardLayout:ReSet()
    for i,v in ipairs(rewardList) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.data = ItemData.New()
            self.itemList[i] = tab
        end
        self.rewardLayout:AddCell(tab.slot.gameObject)
        if v[1] ~= tab.data.base_id then
            tab.data:SetBase(DataItem.data_get[v[1]])
            tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
        end
        tab.slot:SetNum(v[2])
    end
    for i=#rewardList + 1,#self.itemList do
        self.itemList[i].slot.gameObject:SetActive(false)
    end
end
