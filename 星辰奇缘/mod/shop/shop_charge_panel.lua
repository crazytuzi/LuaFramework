ShopChargePanel = ShopChargePanel or BaseClass(BasePanel)

function ShopChargePanel:__init(model, parent, main)
    self.model = model
    self.parent = parent
    self.main = main
    self.mgr = ShopManager.Instance

    self.resList = {
        {file = AssetConfig.shop_charge_panel, type = AssetType.Main}
        ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.subPanelList = {}
    self.tabIconList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateAssetListener = function() self:OnUpdateAsset() end
    self.checkRedListener = function() self:CheckRedPoint() end
    self.privilegeListener = function() self:CheckTabOpen() self.tabGroup:Layout() end
    self.updateProgressListener = function(data) self:UpdateProgress(data) end

    self.progreStatus = true

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

end

function ShopChargePanel:__delete()
    self.OnHideEvent:Fire()

    if self.effectProgress ~= nil then
        self.effectProgress:DeleteMe()
        self.effectProgress = nil
    end

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    if self.tabIconList ~= nil then
        for _,icon in pairs(self.tabIconList) do
            icon.sprite = nil
        end
        self.tabIconList = nil
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.subPanelList ~= nil then
        for k,v in pairs(self.subPanelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.subPanelList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ShopChargePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_charge_panel))
    self.gameObject.name = "ChargePanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform
    local model = self.model

    self.tabCloner = t:Find("Button").gameObject
    self.tabContainer = t:Find("TopTabButtonGroup")
    self.mainPanel = t:Find("Panel")
    self.ownGoldText = t:Find("OwnGold/Gold"):GetComponent(Text)
    self.morePay = t:Find("MorePay").gameObject
    self.morePay:GetComponent(Button).onClick:AddListener(function() self:MorePay() end)
    self.explainBtn = t:Find("Explain"):GetComponent(Button)

    self.rechargeBtn = t:Find("RechargeButton"):GetComponent(Button)
    self.rechargeBtn.onClick:AddListener(function()  WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain,{1,23}) end)

    self.rechargeText = t:Find("RechargeButton/Text"):GetComponent(Text)
    self.rechargeText.text = TI18N("充值好礼")

    self.progressObj = t:Find("Progress").gameObject
    self.noticeImage = t:Find("Progress/NoticeImage"):GetComponent(Image)
    self.imgProgBarRect = t:Find("Progress/ImgProg/ImgProgBar"):GetComponent(RectTransform)
    self.txtProgBar = t:Find("Progress/ImgProg/TxtProgBar"):GetComponent(Text)

    self.noticeBtn = t:Find("Progress/NoticeBtn"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function()
            local tipsText = {TI18N("1.充值进度满后，可获得一次三倍充值返利机会\n2.使用每次机会可额外获得充值钻石数据<color='#ffff00'>2倍</color>的红钻\n3.<color='#7FFF00'>若与节日返利活动共存时，则优先触发节日活动奖励</color>")}
            TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = tipsText})
        end)

    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        if SdkManager.Instance:CheckMorePay() then
            self.morePay:SetActive(true)
        else
            self.morePay:SetActive(false)
        end
    else
        self.morePay:SetActive(false)
    end

    self.setting = {
        noCheckRepeat = true,
        notAutoSelect = true,
        perWidth = 122,
        perHeight = 38,
        isVertical = false
    }
    if BaseUtils.IsVerify and BaseUtils.IsIosVest() then  
        self.setting.openLevel = { 0, 0, 999}
    end
    
    self.tabList = {}
    for k,v in pairs(model.dataTypeList[self.main].subList) do
        if v.lev ~= nil then
            table.insert(self.tabList, {name = v.name, index = k, order = v.order, lev = v.lev, icon = v.icon, textures = v.textures})
        else
            table.insert(self.tabList, {name = v.name, index = k, order = v.order, lev = 0, icon = v.icon, textures = v.textures})
        end
    end
    table.sort(self.tabList, function(a,b) return a.order < b.order end)
    local obj = nil
    local rect = nil
    for i,v in ipairs(self.tabList) do
        obj = GameObject.Instantiate(self.tabCloner)
        obj.name = tostring(i)
        obj.transform:SetParent(self.tabContainer)
        obj.transform.localScale = Vector3.one
        obj.transform.localPosition = Vector3.zero
        rect = obj:GetComponent(RectTransform)
        rect.anchoredPosition = Vector2((i - 1) * self.setting.perWidth, 0)
        if v.icon == nil then
            obj.transform:Find("CenterText"):GetComponent(Text).text = v.name
            obj.transform:Find("CenterText").gameObject:SetActive(true)
            obj.transform:Find("Text").gameObject:SetActive(false)
            obj.transform:Find("Icon").gameObject:SetActive(false)
        else
            obj.transform:Find("Text"):GetComponent(Text).text = v.name
            self.tabIconList[i] = obj.transform:Find("Icon"):GetComponent(Image)
            if v.textures ~= nil then
                self.tabIconList[i].sprite = self.assetWrapper:GetSprite(v.textures, v.icon)
            else
                self.tabIconList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, v.icon)
            end
            obj.transform:Find("CenterText").gameObject:SetActive(false)
            obj.transform:Find("Text").gameObject:SetActive(true)
            obj.transform:Find("Icon").gameObject:SetActive(true)
        end
    end
    self.tabCloner:SetActive(false)

    self.tabGroup = TabGroup.New(self.tabContainer, function(index) self:ChangeTab(index) end, self.setting)

    self.explainBtn.gameObject:SetActive(Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.WindowsPlayer)
    self.explainBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.recharge_explain) end)
end

function ShopChargePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ShopChargePanel:ChangeTab(index)
    local panel = nil
    local currentIndex = nil
    if self.lastIndex ~= nil then
        currentIndex = self.tabList[self.lastIndex].index
        panel = self.subPanelList[currentIndex]
    end
    if panel ~= nil then
        panel:Hiden()
    end
    currentIndex = self.tabList[index].index
    panel = self.subPanelList[currentIndex]
    if panel == nil then
        if currentIndex == 1 then
            self.subPanelList[currentIndex] = ShopRechargePanel.New(self.model, self.mainPanel, self.main, currentIndex)
        elseif currentIndex == 2 then
            self.subPanelList[currentIndex] = ShopRechargeReturnPanel.New(self.model, self.mainPanel, self.main, currentIndex)
        elseif currentIndex == 3 then
            self.subPanelList[currentIndex] = RechargeGiftPanel.New(self.model, self.mainPanel, self.main, currentIndex)
        end
        panel = self.subPanelList[currentIndex]
    end



    self.lastIndex = currentIndex
    panel:Show()
    self.model.currentSub = 1

    self:StartThreeCharge()
end

function ShopChargePanel:OnOpen()
    self:RemoveListeners()
    if self:CheckRechargeTab() == true then
        self.rechargeBtn.gameObject:SetActive(true)
    else
        self.rechargeBtn.gameObject:SetActive(false)
    end
    self.mgr:send9956()
    self:ApplyBtnAnimation()
    self:CheckTabOpen()
    self.tabGroup:Layout()
    for k,v in pairs(self.tabList) do
        if v ~= nil and v.index == self.model.currentSub then
            self.model.currentSub = k
            break
        end
    end
    if self.tabGroup.buttonTab[self.model.currentSub] == nil then
        self.model.currentSub = 1
    end
    self.tabGroup:ChangeTab(self.model.currentSub)
    self:OnUpdateAsset()

    EventMgr.Instance:AddListener(event_name.role_asset_change, self.updateAssetListener)
    self.mgr.onUpdateRedPoint:AddListener(self.checkRedListener)
    EventMgr.Instance:AddListener(event_name.privilege_lev_change, self.privilegeListener)
    self.mgr.onUpdateProgress:AddListener(self.updateProgressListener)
    self.mgr.onUpdateRedPoint:Fire()

end

function ShopChargePanel:ApplyBtnAnimation()
    if RoleManager.Instance.RoleData.turn > 0 then
       self.effTimerId = LuaTimer.Add(1000, 3000, function()
            self.rechargeBtn.gameObject.transform.localScale = Vector3(1.1,1.1,1)
            Tween.Instance:Scale(self.rechargeBtn.gameObject, Vector3(1,1,1), 1.5, function() end, LeanTweenType.easeOutElastic)
       end)
    end
end

function ShopChargePanel:OnHide()
    self.subPanelList[self.lastIndex]:Hiden()
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    self:RemoveListeners()
end

function ShopChargePanel:OnUpdateAsset()
    self.ownGoldText.text = tostring(RoleManager.Instance.RoleData.gold)
end

function ShopChargePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.updateAssetListener)
    self.mgr.onUpdateRedPoint:RemoveListener(self.checkRedListener)
    EventMgr.Instance:RemoveListener(event_name.privilege_lev_change, self.privilegeListener)
    self.mgr.onUpdateProgress:RemoveListener(self.updateProgressListener)
end

function ShopChargePanel:CheckRedPoint()
    local redDic = self.mgr.redPoint[self.main]
    for k,v in pairs(redDic) do
        self.tabGroup.buttonTab[k].red:SetActive(v == true)
    end
end

function ShopChargePanel:MorePay()
    SdkManager.Instance:OpenMorePay()
end

function ShopChargePanel:CheckTabOpen()
    local openTab = {
        [1] = true,
        [2] = true,
        [3] = self:GetPrivilegeStatus()
    }

    local unreachableLev = 255

    for i,v in pairs(openTab) do
        if v == true then
            self.tabGroup.openLevel[i] = 0
        else
            self.tabGroup.openLevel[i] = unreachableLev
        end
    end
end


function ShopChargePanel:CheckRechargeTab()
    local openTime = CampaignManager.Instance.open_srv_time

    local oy = tonumber(os.date("%Y", openTime))
    local om = tonumber(os.date("%m", openTime))
    local od = tonumber(os.date("%d", openTime))


    local beginTime = tonumber(os.time{year = oy, month = om, day = od, hour = 0, min = 00, sec = 0})
    local baseTime = BaseUtils.BASE_TIME
    local distanceTime = baseTime - beginTime
    local d = math.ceil(distanceTime / 86400)

    if d > 14 then
        return true
    end

    return false
end


function ShopChargePanel:StartThreeCharge()
    if  ShopManager.Instance.openThreeCharge then
        self.explainBtn.transform.anchoredPosition = Vector2(295,-225)
        self.transform:Find("OwnGold").anchoredPosition = Vector2(-248,-225)
    else
        self.explainBtn.transform.anchoredPosition = Vector2(313,-226)
        self.transform:Find("OwnGold").anchoredPosition = Vector2(236,195)
    end
    self.progressObj:SetActive((self.lastIndex == 1) and ShopManager.Instance.openThreeCharge and not self.progreStatus)

end


function ShopChargePanel:UpdateProgress(data)
    if self.effectProgress == nil then
        self.effectProgress = BaseUtils.ShowEffect(20468, self.imgProgBarRect.transform, Vector3(1.44, 1.16, 1), Vector3(87.2, -2.7, 0))
    end

    self.effectProgress:SetActive(false)
    self.progreStatus = false
    if data ~= nil then
        local percent = (data.val/data.upper_limit_num) > 1 and 1 or (data.val/data.upper_limit_num)
        if data.val == -1 and data.upper_limit_num == -1 then
            self.progreStatus = true
        elseif data.val == 0 then
            self.noticeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "rechargeTitle2_I18N")
            self.txtProgBar.text = TI18N("充值任意金额")
        elseif data.val >= data.upper_limit_num then
            self.noticeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "rechargeTitle1_I18N")
            self.txtProgBar.text = TI18N("1次机会")
            self.effectProgress:SetActive(true)
        else
            self.noticeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "rechargeTitle2_I18N")
            self.txtProgBar.text = string.format("%d/%d",data.val,data.upper_limit_num)
        end
        self.noticeImage:SetNativeSize()
        self.imgProgBarRect.sizeDelta = Vector2(percent * 174,19.6)
    end

    self:StartThreeCharge()
end

function ShopChargePanel:GetPrivilegeStatus()
    if BaseUtils.IsVerify and BaseUtils.IsIosVest() then  
        return (PrivilegeManager.Instance.lev or 0) >= 9
    else
        return flase
    end
end