-- @author 黄耀聪
-- @date 2016年9月10日

EnjoyMoonPanel = EnjoyMoonPanel or BaseClass(BasePanel)

function EnjoyMoonPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "EnjoyMoonPanel"

    self.timeString = TI18N("活动时间:<color=#C7F9FF>%s-%s</color>")
    self.dateFormatString = TI18N("%s年%s月%s日")
    self.descString = TI18N("%s")

    self.resList = {
        {file = AssetConfig.midAutumn_enjoymoon, type = AssetType.Main},
        {file = AssetConfig.bigatlas_midAutumnBg1, type = AssetType.Main},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
        {file = AssetConfig.guidesprite, type = AssetType.Main},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EnjoyMoonPanel:__delete()
    self.OnHideEvent:Fire()
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EnjoyMoonPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_enjoymoon))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("Info/Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")
    self.bgImage = t:Find("Bg")
    self.bgRect = self.bgImage.gameObject:GetComponent(RectTransform)

    -- self.timeText = t:Find("Info/Time"):GetComponent(Text)
    self.descText = t:Find("Info/Desc"):GetComponent(Text)
    self.descExt = MsgItemExt.New(self.descText, 439, 16, 19)

    self.timeCountDown = {
        t:Find("Bottom/I18N/Time/Hours/Text"):GetComponent(Text),
        t:Find("Bottom/I18N/Time/Minutes/Text"):GetComponent(Text),
        t:Find("Bottom/I18N/Time/Seconds/Text"):GetComponent(Text),
    }

    self.bottom = t:Find("Bottom").gameObject
    self.button = t:Find("Button"):GetComponent(Button)
    self.status = t:Find("I18N_Text").gameObject

    self.button.onClick:AddListener(function() self:OnClick() end)
end

function EnjoyMoonPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EnjoyMoonPanel:OnOpen()
    self:RemoveListeners()
    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTime() end)

    if self.openArgs ~= nil then
        self:InitUI(self.openArgs)
    end

    self:OnTime()
end

function EnjoyMoonPanel:OnHide()
    self:RemoveListeners()
end

function EnjoyMoonPanel:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function EnjoyMoonPanel:InitUI(openArgs)
    self.descExt:SetData(string.format(self.descString, openArgs.desc))

    -- self.timeText.text = string.format(self.timeString,
    --     string.format(self.dateFormatString, tostring(openArgs.startTime[1]),tostring(openArgs.startTime[2]),tostring(openArgs.startTime[3])),
    --     string.format(self.dateFormatString, tostring(openArgs.endTime[1]),tostring(openArgs.endTime[2]),tostring(openArgs.endTime[3])))

    self.target = openArgs.target

    UIUtils.AddBigbg(self.bgImage, GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_midAutumnBg1)))
end

function EnjoyMoonPanel:OnTime()
    local d = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local h = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    local m = tonumber(os.date("%M", BaseUtils.BASE_TIME))
    local s = tonumber(os.date("%S", BaseUtils.BASE_TIME))

    local camp_end_date = DataCampaign.data_list[self.campaignData.sub[1].id].cli_end_time[3]

    local beginTime = 19 * 3600
    local endTime = 19 * 3600 + 1200
    local current = h * 3600 + m * 60 + s

    if current < beginTime then
        self.bottom:SetActive(true)
        self.button.gameObject:SetActive(false)
        self.status:SetActive(false)
        _,h,m,s = BaseUtils.time_gap_to_timer(beginTime - current)
        if h < 10 then
            self.timeCountDown[1].text = string.format("0%s", tostring(h))
        else
            self.timeCountDown[1].text = string.format("%s", tostring(h))
        end
        if m < 10 then
            self.timeCountDown[2].text = string.format("0%s", tostring(m))
        else
            self.timeCountDown[2].text = string.format("%s", tostring(m))
        end
        if s < 10 then
            self.timeCountDown[3].text = string.format("0%s", tostring(s))
        else
            self.timeCountDown[3].text = string.format("%s", tostring(s))
        end
    elseif current <= endTime then
        self.bottom:SetActive(false)
        self.button.gameObject:SetActive(true)
        self.status:SetActive(false)
    else
        if d ~= camp_end_date then
            beginTime = (24 + 19) * 3600
            endTime = (24 + 19) * 3600 + 1200
            _,h,m,s = BaseUtils.time_gap_to_timer(beginTime - current)
            if h < 10 then
                self.timeCountDown[1].text = string.format("0%s", tostring(h))
            else
                self.timeCountDown[1].text = string.format("%s", tostring(h))
            end
            if m < 10 then
                self.timeCountDown[2].text = string.format("0%s", tostring(m))
            else
                self.timeCountDown[2].text = string.format("%s", tostring(m))
            end
            if s < 10 then
                self.timeCountDown[3].text = string.format("0%s", tostring(s))
            else
                self.timeCountDown[3].text = string.format("%s", tostring(s))
            end
        else
            self.bottom:SetActive(false)
        end
        self.button.gameObject:SetActive(false)
        self.status:SetActive(true)
    end
end

function EnjoyMoonPanel:OnClick()
    MidAutumnFestivalManager.Instance:send14060()
end

