-- @author 黄耀聪
-- @date 2016年9月9日

LanternMainUIPanel = LanternMainUIPanel or BaseClass(BasePanel)

function LanternMainUIPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "LanternMainUIPanel"
    self.mgr = MidAutumnFestivalManager.Instance

    self.resList = {
        {file = AssetConfig.midAutumn_mainui_question, type = AssetType.Main},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
    }

    self.timeFormat1 = TI18N("%s秒")
    self.timeFormat2 = TI18N("%s分%s秒")
    self.timeFormat3 = TI18N("%s小时%s分")
    self.timeFormat4 = TI18N("%s天%s小时")
    self.timeString = TI18N("剩余出现时间:<color='#01c0ff'>%s</color>")
    --self.extString = TI18N("中秋彩灯即将刷新  场内人数:%s")

    self.tickListener = function() self:OnTick() end
    self.infoListener = function() self:OnInfo() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function LanternMainUIPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function LanternMainUIPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_mainui_question))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.time = t:Find("Title/Time")
    self.timeText = t:Find("Title/Time/Text"):GetComponent(Text)
    self.extText = t:Find("Title/Ext"):GetComponent(Text)
    self.roleNumText = t:Find("Title/RoleNum"):GetComponent(Text)
    self.lanternNumText = t:Find("Title/LantermNum"):GetComponent(Text)
end

function LanternMainUIPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function LanternMainUIPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.tickEvent:AddListener(self.tickListener)
    self.mgr.infoEvent:AddListener(self.infoListener)


    if RoleManager.Instance.RoleData.event == RoleEumn.Event.SkyLantern then
        self:OnTick()
        self:OnInfo()
        self.gameObject:SetActive(true)
    else
        self.gameObject:SetActive(false)
    end
end

function LanternMainUIPanel:OnHide()
    self:RemoveListeners()
end

function LanternMainUIPanel:RemoveListeners()
    self.mgr.tickEvent:RemoveListener(self.tickListener)
    self.mgr.infoEvent:RemoveListener(self.infoListener)
end

function LanternMainUIPanel:OnTick()
    local model = self.model
    local status = model.lantern_state or 0
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.SkyLantern then
        if model.lantern_target_time ~= nil then
            local leftTime = self.model.lantern_target_time - BaseUtils.BASE_TIME
            local d = nil
            local h = nil
            local m = nil
            local s = nil
            d,h,m,s = BaseUtils.time_gap_to_timer(leftTime)
            if d > 0 then
                self.timeText.text = string.format(model.mainuiText[status].time, string.format(self.timeFormat4, tostring(d), tostring(h)))
            elseif h > 0 then
                self.timeText.text = string.format(model.mainuiText[status].time, string.format(self.timeFormat3, tostring(h), tostring(m)))
            elseif m > 0 then
                self.timeText.text = string.format(model.mainuiText[status].time,
                    string.format(self.timeFormat2, tostring(m), tostring(s))
                    )
            elseif s > 0 then
                self.timeText.text = string.format(model.mainuiText[status].time, string.format(self.timeFormat1, tostring(s)))
            else
                self.timeText.text = string.format(model.mainuiText[status].time, string.format(self.timeFormat1, tostring(0)))
            end
        end
        local allWidth = self.time.sizeDelta.x + self.timeText.transform.anchoredPosition.x + math.ceil(self.timeText.preferredWidth + 2)
        local y = self.time.anchoredPosition.y

        self.time.anchoredPosition = Vector2(self.time.sizeDelta.x / 2 - allWidth / 2, y)
    end
end

function LanternMainUIPanel:OnInfo()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.SkyLantern then
        local model = self.model
        local status = model.lantern_state or 0
        -- self.extText.text = string.format(self.extString, tostring(model.lantern_left_role), tostring(model.lantern_wave))
        local tab = model.mainuiText[status]
        if tab.lantern == nil then
            self.lanternNumText.gameObject:SetActive(false)
            self.roleNumText.gameObject:SetActive(false)
            self.extText.gameObject:SetActive(true)
            self.extText.text = string.format(tab.ext, tostring(model.lantern_left_role or 0))
        else
            self.lanternNumText.gameObject:SetActive(true)
            self.roleNumText.gameObject:SetActive(true)
            self.extText.gameObject:SetActive(false)
            self.roleNumText.text = string.format(tab.ext, tostring(model.lantern_left_role or 0))
            self.lanternNumText.text = string.format(tab.lantern, tostring(model.lantern_left_lanterns or 0))
        end
    end
end

