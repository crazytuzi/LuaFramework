BibleLimitTimePrivilegePanel = BibleLimitTimePrivilegePanel or BaseClass(BasePanel)

function BibleLimitTimePrivilegePanel:__init(model, parent, parentObj, index)
    self.model = model
    self.parent = parent
    self.parentObj = parentObj
    self.index = index
    -- self.timeText = parentObj.tabGroupTimeText[index]
    -- -- print("--------------------------------------------------------"..index)
    -- if self.timeText ~= nil then
    --     self.timeText.gameObject:SetActive(true)
    -- end
    self.resList = {
        {file = AssetConfig.bible_limit_time_privilege_panel, type = AssetType.Main}
        ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
        ,{file = AssetConfig.limittimeprivilege_bg, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_15, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
    }

    self.timerId = 0
    self.countData = 0
    self.vec3 = Vector3(0, 0, 0.1)

    self.OnOpenEvent:AddListener(function()
        if self.openArgs ~= self.model.lastSelect then
            self:Hiden()
            return
        end
        self:UpdateWindow()
    end)

    self.hideListener = function() self:OnHide() end
    self.OnHideEvent:AddListener(self.hideListener)

    self.onlinerewardchange = function ()
        self:updateTime()
    end
    -- self:Init()
    self.isOpen = false
    self.rotateId = 0
    self.effTimerId = nil
end

function BibleLimitTimePrivilegePanel:OnHide()
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

function BibleLimitTimePrivilegePanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    EventMgr.Instance:AddListener(event_name.limit_time_privilege_change, self.onlinerewardchange)
    self:UpdateWindow()
end

function BibleLimitTimePrivilegePanel:__delete()
    self.parentObj = nil
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
    if self.centerBgImg ~= nil then
        self.centerBgImg.sprite = nil
    end
    self.percentFlagImg.sprite = nil
    self.percentSecondImg.sprite = nil
    self.percentFirstImg.sprite = nil
    self.tokesImg.sprite = nil

    EventMgr.Instance:RemoveListener(event_name.limit_time_privilege_change, self.onlinerewardchange)
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    self.gameObject = nil
    self.model = nil
end

function BibleLimitTimePrivilegePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_limit_time_privilege_panel))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.rechargeButton = self.transform:Find("Button_text"):GetComponent(Button)
    self.rechargeButton.onClick:AddListener(function()
                self:OnclickRechargeButton()
            end)
    -- local startPos = self.rechargeButton.gameObject.transform.localPosition

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    self.effTimerId = LuaTimer.Add(1000, 3000, function()
        self.rechargeButton.gameObject.transform.localScale = Vector3(1.2,1.1,1)
        Tween.Instance:Scale(self.rechargeButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
     end)
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
    self.centerBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.limittimeprivilege_bg, "LimitTimePrivilegeBgI18N")
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

    self.transform:Find("BgImage/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")

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
    if self.parentObj.index ~= self.index then
        self:Hiden()
    end
end

function BibleLimitTimePrivilegePanel:Rotate()
    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
        self.rotateId = 0
    end
    self.rotateId = LuaTimer.Add(0, 5, function() self:Loop() end)
end

function BibleLimitTimePrivilegePanel:Loop()
    self.lightTransform:Rotate(self.vec3)
end

function BibleLimitTimePrivilegePanel:OnclickRechargeButton()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
end

function BibleLimitTimePrivilegePanel:UpdateWindow()
    local dataIfo = PrivilegeManager.Instance.limitTimePrivilegeInfo
    if dataIfo == nil then
        return
    end
    self.isOpen = true
    BibleManager.Instance.redPointDic[1][9] = false
    self.model.bibleWin:CheckRedPoint()

    -- PrivilegeManager.Instance:send9927() -- 请求限时特惠
    self:updateTime()
    self.centerText.text = string.format(TI18N("充值额外获得<color='#ffdc5f'>%d%%</color>"), dataIfo.return_val/10)
    -- local msgContent = string.format("恭喜您获选享受<color='#f58140'>限时首笔充值超值优惠</color>，现在充值<color='#01c0ff'>任意数额</color>{assets_2, 90002}均可获赠充值数额的<color='#ffdc5f'>%d%%</color>{assets_2, 90002}\n<color='#ffff00'>（此优惠可与商城额外赠送钻石叠加）</color>",dataIfo.return_val/10)
    -- self.TextEXT:SetData(msgContent)
    self.tokesPercent.text = string.format("%d%%",dataIfo.return_val/10)
    local firstVal = dataIfo.return_val / 100
    local secondVal = dataIfo.return_val % 10 /10
    self.percentSecondImg.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_15, tostring(secondVal))
    self.percentFirstImg.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_15, tostring(firstVal))
    -- self:Rotate()
end

function BibleLimitTimePrivilegePanel:updateTime()
    -- body
    local dataIfo = PrivilegeManager.Instance.limitTimePrivilegeInfo
    if dataIfo == nil then
        return
    end
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    self.timeTemp = Time.time -- 当前时间
    self.timeT = Time.time --上次的时间
    self.countData = dataIfo.max_time - (dataIfo.keep_time + (BaseUtils.BASE_TIME - math.max(dataIfo.login_time,dataIfo.start_time))) - 1800
    self.timerId = LuaTimer.Add(0, 1000, function()
        if self.countData > 0 then
            self.timeTemp = Time.time
            self.countData = self.countData - (self.timeTemp - self.timeT)
            self.timeT = Time.time
            self.slider.value = self.countData / 12000
            -- local timeStr = ""
            local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(self.countData))
            self.houtTxt.text = string.format("0%d",hour)
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

