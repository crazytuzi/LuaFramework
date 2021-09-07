OpenServerRankPanel = OpenServerRankPanel or BaseClass(BasePanel)

function OpenServerRankPanel:__init(model, parent, subList)
    self.model = model
    self.parent = parent
    self.subList = subList

    local openTime = CampaignManager.Instance.open_srv_time
    local base_time = BaseUtils.BASE_TIME
    local hour = tonumber(os.date("%H",openTime))*3600
    hour = hour + tonumber(os.date("%M",openTime))*60
    hour = hour + tonumber(os.date("%S",openTime))

    -- self.TimeSwitch = 1461059784
    self.openTime = CampaignManager.Instance.open_srv_time

    local basedata = DataCampaign.data_list[self.subList[2].id]

    local cli_end_time = basedata.cli_end_time[1]
    self.endTime = openTime - hour + cli_end_time[2] * 86400 + cli_end_time[3]

    self.timeFormat1 = TI18N("%s天%s小时")
    self.timeFormat2 = TI18N("%s小时%s分钟")
    self.timeFormat3 = TI18N("%s分钟%s秒")
    self.timeFormat4 = TI18N("%s秒")
    self.timeFormat5 = TI18N("活动已结束")

    self.mgr = OpenServerManager.Instance

    self.resList = {
        {file = AssetConfig.open_server_rank, type = AssetType.Main},
        {file = AssetConfig.openserver_rank_i18n, type = AssetType.Main},
    }

    self.rankList = {}
    self.isInit = false

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateLuckyListener = function() self.isInit = false self:ReloadLucky() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function OpenServerRankPanel:__delete()
    self.OnHideEvent:Fire()
    if self.rankList ~= nil then
        for k,v in pairs(self.rankList) do
            if v ~= nil then
                v:DeleteMe()
                self.rankList[k] = nil
                v = nil
            end
        end
        self.rankList = nil
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

function OpenServerRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_rank))
    self.gameObject.name = "OpenServerRankPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.timeText = t:Find("CheckArea/Info/TitleI18N/Text"):GetComponent(Text)
    self.myRankText = t:Find("CheckArea/Info/MyInfoI18N/Text"):GetComponent(Text)
    self.cloner = t:Find("MaskArea/ScrollLayer/Cloner").gameObject
    self.container = t:Find("MaskArea/ScrollLayer/Container")
    self.jumpToRankBtn = t:Find("CheckArea/Button"):GetComponent(Button)

    self.jumpToRankBtn.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank)
    end)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})

    self.timeText.text = self.activityTimeText

    UIUtils.AddBigbg(t:Find("CheckArea/Image"), GameObject.Instantiate(self:GetPrefab(AssetConfig.openserver_rank_i18n)))

    t:Find("MaskArea/ScrollLayer"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged() end)

    self.cloner:SetActive(false)

    self.OnOpenEvent:Fire()
end

function OpenServerRankPanel:OnOpen()
    local openTime = CampaignManager.Instance.open_srv_time
    local base_time = BaseUtils.BASE_TIME
    local hour = tonumber(os.date("%H",openTime))*3600 + tonumber(os.date("%M",openTime))*60 + tonumber(os.date("%S",openTime))

    local subList = {}
    for i,v in pairs(self.subList) do
        table.insert(subList, DataCampaign.data_list[v.id])
    end
    self.theSubList = subList

    self:ReloadLucky()

    self:RemoveListeners()
    self.mgr.onUpdateLucky:AddListener(self.updateLuckyListener)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 1000, function() self:OnTime() end)
    end
end

function OpenServerRankPanel:RemoveListeners()
    self.mgr.onUpdateLucky:RemoveListener(self.updateLuckyListener)
end

function OpenServerRankPanel:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function OpenServerRankPanel:ReloadLucky()
    if self.isInit == false then
        local obj = nil
        self.layout:ReSet()
        for i,v in ipairs(self.theSubList) do
            if self.rankList[i] == nil then
                obj = GameObject.Instantiate(self.cloner)
                obj.name = tostring(i)
                self.rankList[i] = RankRewardItem.New(self.model, obj)
            end
            self.layout:AddCell(self.rankList[i].gameObject)
            self.rankList[i]:SetData(v,i)
        end

        self:OnValueChanged()

        for i=#self.theSubList + 1, #self.rankList do
            self.rankList[i]:SetActive(false)
        end
    end
end

function OpenServerRankPanel:OnTime()
    local dis = self.endTime - BaseUtils.BASE_TIME
    local d = nil
    local h = nil
    local m = nil
    local s = nil
    d,h,m,s = BaseUtils.time_gap_to_timer(dis)

    if dis < 0 then
        self.timeText.text = self.timeFormat5
    else
        if d > 0 then
            self.timeText.text = string.format(self.timeFormat1, tostring(d), tostring(h))
        elseif h > 0 then
            self.timeText.text = string.format(self.timeFormat2, tostring(h), tostring(m))
        elseif m > 0 then
            self.timeText.text = string.format(self.timeFormat3, tostring(m), tostring(s))
        else
            self.timeText.text = string.format(self.timeFormat4, tostring(m))
        end
    end
end

function OpenServerRankPanel:OnValueChanged()
    for i=1, #self.rankList do
        local item = self.rankList[i]
        item:OnValueChanged()
    end
end