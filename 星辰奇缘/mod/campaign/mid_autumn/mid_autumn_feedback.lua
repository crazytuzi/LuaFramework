MidAutumnFeedback = MidAutumnFeedback or BaseClass(BasePanel)

function MidAutumnFeedback:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "Feedback"
    -- self.timeText = parentObj.tabGroupTimeText[index]
    -- -- print("--------------------------------------------------------"..index)
    -- if self.timeText ~= nil then
    --     self.timeText.gameObject:SetActive(true)
    -- end
    self.resList = {
        {file = AssetConfig.bible_limit_time_privilege_panel, type = AssetType.Main}
        ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_15, type = AssetType.Dep}
        ,{file = AssetConfig.midAutumn_textures, type = AssetType.Dep}
    }

    self.timerId = 0
    self.countData = 0
    self.vec3 = Vector3(0, 0, 0.1)

    self.OnOpenEvent:AddListener(function()
        self:UpdateWindow()
    end)

    self.hideListener = function() self:OnHide() end
    self.OnHideEvent:AddListener(self.hideListener)

    self.onlinerewardchange = function ()
        self:updateTime()
    end
    EventMgr.Instance:AddListener(event_name.limit_time_privilege_change, self.onlinerewardchange)
    -- self:Init()
    self.isOpen = false
    self.rotateId = 0
    self.effTimerId = nil
end

function MidAutumnFeedback:OnHide()
    self.isOpen = false
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
        self.rotateId = 0
    end
end

function MidAutumnFeedback:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function MidAutumnFeedback:__delete()
    if self.effectObj ~= nil then
        self.effectObj:DeleteMe()
    end
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
        self.rotateId = 0
    end
    if self.bev ~= nil then
        self.bev:DeleteMe()
        self.bev = nil
    end
    self.centerBgImg.sprite = nil
    self.percentFlagImg.sprite = nil
    self.percentSecondImg.sprite = nil
    self.percentFirstImg.sprite = nil
    self.tokesImg.sprite = nil

    EventMgr.Instance:RemoveListener(event_name.limit_time_privilege_change, self.onlinerewardchange)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MidAutumnFeedback:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_limit_time_privilege_panel))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.rechargeButton = self.transform:Find("Button_text"):GetComponent(Button)
    self.rechargeButton.onClick:AddListener(function()
                if CampaignManager.Instance.campaignTab[320].status == 2 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("你已经获得过暖心回馈，无法重复获得"))
                else
                    self:OnclickRechargeButton()
                end
            end)
    -- local startPos = self.rechargeButton.gameObject.transform.localPosition
    if CampaignManager.Instance.campaignTab[320].status == 2 then
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
        self.rechargeButton.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.transform:Find("Button_text"):Find("Text"):GetComponent(Text).text = TI18N("已充值")
        -- self.rechargeButton.enabled = false
    else
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
        self.effTimerId = LuaTimer.Add(1000, 3000, function()
            self.rechargeButton.gameObject.transform.localScale = Vector3(1.2,1.1,1)
            Tween.Instance:Scale(self.rechargeButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)
    end
    -- local effTemp = Tween.Instance:Scale(self.rechargeButton.gameObject, Vector3(1,1,1), 1, function() end, LeanTweenType.easeOutElastic)
    -- effTemp:setLoopPingPong()
    -- local fun3 = function(effectView)
    --     local effectObject = effectView.gameObject

    --     effectObject.transform:SetParent(self.rechargeButton.transform)
    --     effectObject.transform.localScale = Vector3(1, 0.9, 1)
    --     effectObject.transform.localPosition = Vector3(-50, 25, -400)
    --     effectObject.transform.localRotation = Quaternion.identity

    --     Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    --     effectObject:SetActive(true)
    -- end
    -- self.bev = BaseEffectView.New({effectId = 20118, time = nil, callback = fun3})

    self.centerBgImg = self.transform:Find("CenterImage"):GetComponent(Image)
    self.centerBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.midAutumn_textures, "I18NFeedback")
    self.percentFlagImg = self.transform:Find("CenterImage/Image3"):GetComponent(Image)
    self.percentFlagImg.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_15, "%")
    self.percentSecondImg = self.transform:Find("CenterImage/Image2"):GetComponent(Image)
    self.percentFirstImg = self.transform:Find("CenterImage/Image1"):GetComponent(Image)
    self.percentSecondImg.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_15, "0")
    self.percentFirstImg.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_15, "3")
    self.centerBgImg.gameObject:SetActive(true)

    self.houtTxt = self.transform:Find("TimeHour/HourText"):GetComponent(Text)
    self.minTxt = self.transform:Find("TimeMin/MinText"):GetComponent(Text)
    self.secTxt = self.transform:Find("TimeSec/SecText"):GetComponent(Text)

    self.centerText = self.transform:Find("CTBgImage/Text"):GetComponent(Text)
    self.descText = self.transform:Find("DescText"):GetComponent(Text)
    -- self.remindTimeText = self.transform:Find("RemindTimeText"):GetComponent(Text)
    -- self.TextEXT = MsgItemExt.New(self.descText, 370, 18, 30)

    self.lightTransform = self.transform:Find("BgImage/BImage").transform
    self.tokesImg = self.transform:Find("BgImage/Tokes"):GetComponent(Image)
    self.tokesImg.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Tokes")
    self.tokesImg.gameObject:SetActive(true)
    self.tokesPercent = self.transform:Find("BgImage/Tokes/PersentValue"):GetComponent(Text)

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

    if BaseUtils.IsInTimeRange(PrivilegeManager.Instance.startMonth,PrivilegeManager.Instance.startDay,PrivilegeManager.Instance.endMonth,PrivilegeManager.Instance.endDay) == false then
        self.transform:Find("Title/Text"):GetComponent(Text).text = TI18N("限时特惠")
    else
        self.transform:Find("Title/Text"):GetComponent(Text).text = TI18N("首发狂欢限时返利")
    end
end

function MidAutumnFeedback:Rotate()
    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
        self.rotateId = 0
    end
    self.rotateId = LuaTimer.Add(0, 5, function() self:Loop() end)
end

function MidAutumnFeedback:Loop()
    self.lightTransform:Rotate(self.vec3)
end

function MidAutumnFeedback:OnclickRechargeButton()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
end

function MidAutumnFeedback:UpdateWindow()
    local return_val = tonumber(DataCampaign.data_list[self.campaignData.sub[1].id].camp_cond_client)
    self.isOpen = true

    -- PrivilegeManager.Instance:send9927() -- 请求限时特惠
    self:updateTime()
    self.centerText.text = string.format(TI18N("充值额外获得<color='#ffdc5f'>%d%%</color>"), return_val)
    -- local msgContent = string.format("恭喜您获选享受<color='#f58140'>限时首笔充值超值优惠</color>，现在充值<color='#01c0ff'>任意数额</color>{assets_2, 90002}均可获赠充值数额的<color='#ffdc5f'>%d%%</color>{assets_2, 90002}\n<color='#ffff00'>（此优惠可与商城额外赠送钻石叠加）</color>",dataIfo.return_val/10)
    -- self.TextEXT:SetData(msgContent)
    self.tokesPercent.text = string.format("%d%%",return_val)
    local firstVal = return_val / 10
    local secondVal = return_val % 10
    self.percentSecondImg.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_15, tostring(secondVal))
    self.percentFirstImg.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_15, tostring(firstVal))

    self.descText.text = TI18N("1、此优惠可与<color='#ffff00'>商城额外赠送钻石</color>叠加\n2、若同时触发<color='#ffff00'>限时返利</color>，则<color='#ffff00'>中秋返利</color>优先生效")
    self.descText.horizontalOverflow = 1
    self.descText.lineSpacing = 1
    self.descText.transform.anchoredPosition = Vector2(32,-386)

    -- self:Rotate()

    if CampaignManager.Instance.campaignTab[320].status == 2 then
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
        self.rechargeButton.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.transform:Find("Button_text"):Find("Text"):GetComponent(Text).text = TI18N("已充值")
        -- self.rechargeButton.enabled = false
    else
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

function MidAutumnFeedback:updateTime()
    -- body
    local dataIfo = PrivilegeManager.Instance.limitTimePrivilegeInfo
    if dataIfo == nil then
        print("MidAutumnFeedback:updateTime()--"..debug.traceback())
        return
    end
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    self.timeTemp = Time.time -- 当前时间
    self.timeT = Time.time --上次的时间
    local endTime = self.openArgs.endTime
    local startTime = self.openArgs.startTime
    local end_time = os.time{year = endTime[1], month = endTime[2], day = endTime[3], hour = endTime[4], min = endTime[5], sec = endTime[6]}
    local start_time = os.time{year = startTime[1], month = startTime[2], day = startTime[3], hour = startTime[4], min = startTime[5], sec = startTime[6]}
    -- self.countData = end_time - (dataIfo.keep_time + (BaseUtils.BASE_TIME - math.max(dataIfo.login_time,dataIfo.start_time))) - 1800
    self.countData = end_time - BaseUtils.BASE_TIME
    self.timerId = LuaTimer.Add(0, 1000, function()
        if self.countData > 0 then
            self.timeTemp = Time.time
            self.countData = self.countData - (self.timeTemp - self.timeT)
            self.timeT = Time.time

            self.slider.value = self.countData / (end_time - start_time)
            -- local timeStr = ""
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
            -- if hour > 0 then
            --     timeStr = string.format("%d小时",hour)
            --     if min > 9 then
            --         timeStr = string.format("%s%d分钟",timeStr,min)
            --     else
            --         timeStr = string.format("%s0%d分钟",timeStr,min)
            --     end
            -- else
            --     if min > 9 then
            --         timeStr = string.format("%d分钟",min)
            --     else
            --         timeStr = string.format("0%d分钟",min)
            --     end
            --     if second > 9 then
            --         timeStr = string.format("%s%d秒",timeStr,second)
            --     else
            --         timeStr = string.format("%s0%d秒",timeStr,second)
            --     end
            -- end

            -- self.remindTimeText.text = string.format("剩余时间：<color='#2fc823'>%s</color>",timeStr)
            -- self.timeText.text = string.format("%s:%s", hour, min)
            -- self.timeText.text = string.format("%s:%s", tostring(math.floor(self.countData/60)), tostring(math.floor(self.countData%60)))
        else
            -- self.countDataBefore = 0
            -- self.remindTimeText.text = "剩余时间：<color='#2fc823'>00分钟00秒</color>"
            -- self.timeText.text = string.format("%s:%s", tostring(math.floor(self.countData/60)), tostring(math.floor(self.countData%60)))
            self.slider.value = 0
            self.houtTxt.text = string.format("00")
            self.minTxt.text = string.format("00")
            self.secTxt.text = string.format("00")
            if self.timerId ~= 0 then
                LuaTimer.Delete(self.timerId)
                self.timerId = 0
            end
            if self.isOpen == true then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 1})
            end
        end
    end)
end

