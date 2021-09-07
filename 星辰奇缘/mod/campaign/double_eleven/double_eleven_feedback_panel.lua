--2016/11/5
--xjlong
--双十一聚划算
DoubleElevenFeedbackPanel = DoubleElevenFeedbackPanel or BaseClass(BasePanel)

function DoubleElevenFeedbackPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "DoubleElevenFeedbackPanel"

    self.resList = {
        {file = AssetConfig.double_eleven_feedback_panel, type = AssetType.Main}
        ,{file = AssetConfig.newyearrebate_big_bg3, type = AssetType.Main}
        ,{file = AssetConfig.newyearrebate_big_bg2, type = AssetType.Main}
        ,{file = AssetConfig.newyearrebate_txt2, type = AssetType.Main}
        -- ,{file = AssetConfig.doubleelevenfeedbacki18n, type = AssetType.Main}
        --,{file = AssetConfig.summer_recharge_big_bg, type = AssetType.Main}
        ,{file = AssetConfig.newmoon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.springfestival_texture, type = AssetType.Dep}
    }

    --table.insert(self.resList,{file = AssetConfig.anniversary_textures, type = AssetType.Dep})

    self.timerId = 0
    self.countData = 0
    self.vec3 = Vector3(0, 0, 0.1)
    --DataCampaign.data_list[801]
    self.campaignData = { }

    self.OnOpenEvent:AddListener(function()
        self:UpdateWindow()
    end)

    self.hideListener = function() self:OnHide() end
    self.OnHideEvent:AddListener(self.hideListener)

    self.onlinerewardchange = function ()
        self:updateTime()
    end
    EventMgr.Instance:AddListener(event_name.limit_time_privilege_change, self.onlinerewardchange)

    self.isOpen = false
    self.effTimerId = nil
end

function DoubleElevenFeedbackPanel:OnHide()
    self.isOpen = false
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
end

function DoubleElevenFeedbackPanel:OnInitCompleted()
    self:UpdateWindow()
end

function DoubleElevenFeedbackPanel:__delete()
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end

    if self.effectObj ~= nil then
        self.effectObj:DeleteMe()
    end
    if self.effectTopObj ~= nil then
        self.effectTopObj:DeleteMe()
    end
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    if self.topBgImg ~= nil then
        self.topBgImg.sprite = nil
    end

    EventMgr.Instance:RemoveListener(event_name.limit_time_privilege_change, self.onlinerewardchange)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DoubleElevenFeedbackPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.double_eleven_feedback_panel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Ribbon").gameObject:SetActive(false)

    self.rechargeButton = self.transform:Find("Button_text"):GetComponent(Button)
    if next(CampaignManager.Instance.model:GetIdsByType(CampaignEumn.ShowType.DoubleElevenFeedback)) ~= nil then
        local dataId = CampaignManager.Instance.model:GetIdsByType(CampaignEumn.ShowType.DoubleElevenFeedback)[1]
        self.campaignData = DataCampaign.data_list[dataId]
    end
    self.rechargeButton.onClick:AddListener(
        function()
            if CampaignManager.Instance.campaignTab[self.campaignData.id].status == 2 then
                NoticeManager.Instance:FloatTipsByString(TI18N("你已经获得过暖心回馈，无法重复获得"))
            else
                self:OnclickRechargeButton()
            end
        end
    )
    if CampaignManager.Instance.campaignTab[self.campaignData.id].status == 2 then
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
        self.rechargeButton.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.transform:Find("Button_text").gameObject:SetActive(false)
        self.transform:Find("RechargedI18N").gameObject:SetActive(true)
    else
        self.transform:Find("Button_text").gameObject:SetActive(true)
        self.transform:Find("RechargedI18N").gameObject:SetActive(false)
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
        self.effTimerId = LuaTimer.Add(1000, 3000, function()
            self.rechargeButton.gameObject.transform.localScale = Vector3(1.2,1.1,1)
            Tween.Instance:Scale(self.rechargeButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)
    end

    -- BaseUtils.dump(self.campaignData, "dddddddddd")
    self.topBgImg = self.transform:Find("TopImage"):GetComponent(Image)
    local obj

    if self.campaignData and self.campaignData.iconid == "171" then
        obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.newyearrebate_big_bg2))
    else
        obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.newyearrebate_big_bg3))
    end
    UIUtils.AddBigbg(self.topBgImg.transform, obj)

    -- local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.doubleelevenfeedbacki18n))
    -- local obj = GameObject.Instantiate(self:GetPrefab(self.bg))
    -- UIUtils.AddBigbg(self.topBgImg.transform, obj)
    -- obj.transform:SetAsFirstSibling()
    -- self.topBgImg.gameObject:SetActive(true)


    -- local objTxt = GameObject.Instantiate(self:GetPrefab(AssetConfig.newyearrebate_txt2))
    -- UIUtils.AddBigbg(self.topBgImg.transform, objTxt)
    -- objTxt.transform.anchoredPosition = Vector2(200,0)


    local fun = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.topBgImg.transform)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(-52, -69, -400)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    self.effectTopObj = BaseEffectView.New({effectId = 20198, time = nil, callback = fun})

    self.houtTxt = self.transform:Find("TimeHour/HourText"):GetComponent(Text)
    self.minTxt = self.transform:Find("TimeMin/MinText"):GetComponent(Text)
    self.secTxt = self.transform:Find("TimeSec/SecText"):GetComponent(Text)

    self.feedBackText2 = self.transform:Find("FeedBackText2"):GetComponent(Text)
    self.feedBackText2.gameObject:SetActive(false)

    self.feedBackText = self.transform:Find("FeedBackText"):GetComponent(Text)
    self.feedBackText.transform.sizeDelta = Vector2(180, 40)
    self.timeText = self.transform:Find("TimeText"):GetComponent(Text)
    self.descText = self.transform:Find("DescText"):GetComponent(Text)
    self.descExt = MsgItemExt.New(self.descText, 338, 15)

    self.slider = self.transform:Find("Slider"):GetComponent(Slider)
    self.slider.interactable = false
    self.handleObj = self.transform:Find("Slider/Handle Slide Area/Handle")
    local funTemp = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.handleObj)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(0, 0, -400)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    self.effectObj = BaseEffectView.New({effectId = 20161, time = nil, callback = funTemp})
end

function DoubleElevenFeedbackPanel:OnclickRechargeButton()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
end

function DoubleElevenFeedbackPanel:UpdateWindow()
    self.isOpen = true

    self:updateTime()
    local returnVal = tonumber(self.campaignData.camp_cond_client)
    self.feedBackText.text = string.format(TI18N("<color='#ffdc5f'>%d%%</color>"), returnVal or 0)
    local cfgData = self.campaignData

    if cfgData.cli_start_time[1][1] ~= nil then
        self.timeText.text = string.format(TI18N("%s年%s月%s日~%s月%s日"), cfgData.cli_start_time[1][1], cfgData.cli_start_time[1][2], cfgData.cli_start_time[1][3], cfgData.cli_end_time[1][2], cfgData.cli_end_time[1][3])
    else
        local start_month = os.date("%m",CampaignManager.Instance.open_srv_time + 86400 * cfgData.cli_start_time[1][2] + cfgData.cli_start_time[1][3])
        local start_day = os.date("%d",CampaignManager.Instance.open_srv_time + 86400 * cfgData.cli_start_time[1][2] + cfgData.cli_start_time[1][3])
        local end_month = os.date("%m",CampaignManager.Instance.open_srv_time + 86400 * cfgData.cli_end_time[1][2] + cfgData.cli_end_time[1][3])
        local end_day = os.date("%d",CampaignManager.Instance.open_srv_time + 86400 * cfgData.cli_end_time[1][2] + cfgData.cli_end_time[1][3])

        self.timeText.text = string.format(TI18N("%s月%s日~%s月%s日"), start_month, start_day, end_month, end_day)
    end
    --self.descText.text = cfgData.cond_desc

    -- print("=======================================")
    -- print(cfgData.cond_desc)
    self.descExt:SetData(cfgData.cond_desc)

    if CampaignManager.Instance.campaignTab[self.campaignData.id].status == 2 then
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
        self.rechargeButton.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.transform:Find("Button_text").gameObject:SetActive(false)
        self.transform:Find("RechargedI18N").gameObject:SetActive(true)
    else
        self.transform:Find("Button_text").gameObject:SetActive(true)
        self.transform:Find("RechargedI18N").gameObject:SetActive(false)
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
        self.effTimerId = LuaTimer.Add(1000, 3000, function()
            self.rechargeButton.gameObject.transform.localScale = Vector3(1.2,1.1,1)
            Tween.Instance:Scale(self.rechargeButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)
    end
end

function DoubleElevenFeedbackPanel:updateTime()
    self.startTime = self.campaignData.cli_start_time[1]
    self.endTime = self.campaignData.cli_end_time[1]
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    self.timeTemp = Time.time -- 当前时间
    self.timeT = Time.time --上次的时间
    local endTime = self.endTime
    local startTime = self.startTime
    local end_time = nil
    local start_time = nil
    if endTime[1] == nil then
        end_time = CampaignManager.Instance.open_srv_time + endTime[2] * 86400 + endTime[3]
        start_time = CampaignManager.Instance.open_srv_time + startTime[2] * 86400 + startTime[3]
    else
        end_time = os.time{year = endTime[1], month = endTime[2], day = endTime[3], hour = endTime[4], min = endTime[5], sec = endTime[6]}
        start_time = os.time{year = startTime[1], month = startTime[2], day = startTime[3], hour = startTime[4], min = startTime[5], sec = startTime[6]}
    end
    self.countData = end_time - BaseUtils.BASE_TIME
    self.timerId = LuaTimer.Add(0, 1000, function()
        if self.countData > 0 then
            self.timeTemp = Time.time
            self.countData = self.countData - (self.timeTemp - self.timeT)
            self.timeT = Time.time

            self.slider.value = self.countData / (end_time - start_time)
            local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(self.countData))
            local hour = hour + day * 24
            if hour < 10 then
                self.houtTxt.text = string.format("0%d",hour)
            else
                self.houtTxt.text = string.format("%d",hour)
            end
            if min > 9 then
                self.minTxt.text = string.format("%d",min)
            else
                self.minTxt.text = string.format("0%d",min)
            end
            if second > 9 then
                self.secTxt.text = string.format("%d",second)
            else
                self.secTxt.text = string.format("0%d",second)
            end
        else
            self.slider.value = 0
            self.houtTxt.text = string.format("00")
            self.minTxt.text = string.format("00")
            self.secTxt.text = string.format("00")
            if self.timerId ~= 0 then
                LuaTimer.Delete(self.timerId)
                self.timerId = 0
            end
        end
    end)
end

