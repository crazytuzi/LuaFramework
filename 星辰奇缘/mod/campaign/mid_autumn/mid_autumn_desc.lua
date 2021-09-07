-- @author 黄耀聪
-- @date 2016年9月12日

MidAutumnDesc = MidAutumnDesc or BaseClass(BasePanel)

function MidAutumnDesc:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MidAutumnDesc"
    self.timeString = TI18N("活动时间：%s-%s")
    self.dateFormatString = TI18N("%s月%s日")

    self.resList = {
        {file = AssetConfig.midAutumn_desc, type = AssetType.Main},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
        {file = AssetConfig.guidesprite, type = AssetType.Main},
    }

    self.itemList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MidAutumnDesc:__delete()
    self.OnHideEvent:Fire()
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MidAutumnDesc:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_desc))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")
    self.timeText = t:Find("Time"):GetComponent(Text)
    t:Find("Time").gameObject:SetActive(true)
    if self.type == CampaignEumn.ShowType.SkyLantern then
        self.timeText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(182,-117)
        t:Find("Time").gameObject:SetActive(false)
    elseif self.type == CampaignEumn.ShowType.PoetryChallenge then
        self.timeText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(167,-121)
    else
        self.timeText.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(220,-119)
    end

    self.descExt = MsgItemExt.New(t:Find("Info/Desc"):GetComponent(Text), 434, 16, 19)

    -- t:Find("Info").pivot = Vector2(0.5, 1)
    t:Find("Info").anchoredPosition = Vector2(-30, -134)

    self.layout = LuaBoxLayout.New(t:Find("Reward/Scroll/Container"), {axis = BoxLayoutAxis.X, border = 5, cspacing = 10})
    t:Find("Reward/Scroll"):GetComponent(ScrollRect).enabled = true

    UIUtils.AddBigbg(t:Find("Bg1"), GameObject.Instantiate(self:GetPrefab(self.bg1)))
    -- t:Find("Bg2").gameObject:SetActive(false)
    -- t:Find("Bg2").anchoredPosition = Vector2(40, -14)
    -- UIUtils.AddBigbg(t:Find("Bg2"), GameObject.Instantiate(self:GetPrefab(self.bg2)))
end

function MidAutumnDesc:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnDesc:OnOpen()
    self:RemoveListeners()

    self:OnInfo()
    self:Reload()
end

function MidAutumnDesc:OnHide()
    self:RemoveListeners()
end

function MidAutumnDesc:RemoveListeners()
end

function MidAutumnDesc:OnInfo()
    local baseData = self.campaignData
    self.descExt:SetData(baseData.cond_desc)

    local endTime = baseData.cli_end_time[1]
    local startTime = baseData.cli_start_time[1]

    self.timeText.text = string.format(self.timeString,
        string.format(self.dateFormatString, tostring(startTime[2]),tostring(startTime[3])),
        string.format(self.dateFormatString, tostring(endTime[2]),tostring(endTime[3])))

    -- local height = self.descExt.contentRect.sizeDelta.y
    -- if height < 157 then
    --     height = 157
    -- end
    -- self.transform:Find("Info").sizeDelta = Vector2(472, height)
end


function MidAutumnDesc:Reload()
    local campData = DataCampaign.data_list[self.campId]
    self.layout:ReSet()
    -- BaseUtils.dump(campData.reward,"reward")
    if campData.reward == nil then
        return
    end

    for i,v in ipairs(campData.reward) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.itemdata = ItemData.New()
            self.itemList[i] = tab
        end
        tab.itemdata:SetBase(DataItem.data_get[v[1]])
        tab.slot:SetAll(tab.itemdata)
        tab.slot:SetNum(v[2])
        -- tab.slot:SetItemBg("ItemDefaultRed")
        self.layout:AddCell(tab.slot.gameObject)
    end

    if self.itemList == nil then
        return
    end

    for i=#campData.reward + 1,#self.itemList do
        self.itemList[i].slot.gameObject:SetActive(false)
    end
end


