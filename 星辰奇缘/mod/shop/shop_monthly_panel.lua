ShopMonthlyPanel = ShopMonthlyPanel or BaseClass(BasePanel)

function ShopMonthlyPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ShopMonthlyPanel"

    self.resList = {
        {file = AssetConfig.shop_monthly_panel, type = AssetType.Main},
        {file = AssetConfig.bigatlas_shop_monthly_bg, type = AssetType.Dep},
    }

    self.refreshListener = function() self:Refresh() end

    local chargeList = model:GetChargeList()
    local monthGold = 0
    for _,v in pairs(DataMonthCard.data_get_reward) do
        monthGold = v.gold
        break
    end

    self.monthData = nil
    for _,v in pairs(chargeList) do
        if monthGold == v.gold then
            self.monthData = v
            break
        end
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ShopMonthlyPanel:__delete()
end

function ShopMonthlyPanel:OnOpen()
    EventMgr.Instance:RemoveListener(event_name.monthly_gift_change, self.refreshListener)
    EventMgr.Instance:AddListener(event_name.monthly_gift_change, self.refreshListener)
    self:Refresh()
end

function ShopMonthlyPanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.monthly_gift_change, self.refreshListener)
end

function ShopMonthlyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ShopMonthlyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_monthly_panel))
    self.gameObject.name = self.name
    local transform = self.gameObject.transform
    self.transform = transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.btnBuy = transform:Find("BuyButton"):GetComponent(Button)
    self.btnBuy.onClick:AddListener(function() self:OnBuy() end)
    self.textBuy = transform:Find("BuyButton/Text"):GetComponent(Text)
    self.msgExtGotReward = MsgItemExt.New(self.textBuy, 1000)
    self.textGotReward = transform:Find("TextGotReward"):GetComponent(Text)
    self.textGotReward.text = TI18N("已领取")

    self.goTime = transform:Find("Time").gameObject
    self.textTime = transform:Find("Time/Text"):GetComponent(Text)
    self.btnTips = transform:Find("GantanBg"):GetComponent(Button)
    self.btnTips.onClick:AddListener(function() self:OnShowTips() end)
    self.textTips = transform:Find("GantanBg/TextTips"):GetComponent(Text)

    self.moreBtn = transform:Find("NewTips/MoreButton"):GetComponent(Button)
    self.moreBtn.onClick:AddListener(function() self:OpenSubPanel() end)
    self.moreBtn.transform.anchoredPosition = Vector2(-105.5,-35)

    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_shop_monthly_bg))
    UIUtils.AddBigbg(transform:Find("Bg"), bigbg)

    if BaseUtils.IsVerify then
        transform:Find("Bg").gameObject:SetActive(false)
        local bgText = transform:Find("BgText")
        bgText.gameObject:SetActive(true)
        bgText:GetComponent(Text).text = BaseUtils.GetVerifySetting().monthlyText
    end
end

function ShopMonthlyPanel:Refresh()
    self:RefreshTime()
    self:RefreshButton()
end

function ShopMonthlyPanel:RefreshButton()
    if PrivilegeManager.Instance.monthlyExcessDays > 0 then
        if PrivilegeManager.Instance.canReceiveMonthly == true then
            self.btnBuy.gameObject:SetActive(true)
            self.msgExtGotReward:SetData(TI18N("领取5000{assets_2,90003}"))
            self.textBuy.transform.anchoredPosition3D = Vector2(8, -11.5)
            self.textGotReward.gameObject:SetActive(false)
        else

            self.msgExtGotReward:SetData(TI18N("续 费"))
            self.textBuy.transform.anchoredPosition3D = Vector2(38, -11.5)
            self.btnBuy.gameObject:SetActive(true)
            self.textGotReward.gameObject:SetActive(false)
        end
    else
        self.msgExtGotReward:SetData(TI18N("购 买"))
        self.textBuy.transform.anchoredPosition3D = Vector2(38, -11.5)
        self.btnBuy.gameObject:SetActive(true)
        self.textGotReward.gameObject:SetActive(false)
    end
end

function ShopMonthlyPanel:RefreshTime()
    if PrivilegeManager.Instance.monthlyExcessDays > 0 then
        self.textTime.text = string.format(TI18N("月卡剩余：<color='#248813'>%s天</color>"), tostring(PrivilegeManager.Instance.monthlyExcessDays))
    else
        self.textTime.text = TI18N("尚未购买")
    end
end

function ShopMonthlyPanel:OnBuy()
    if PrivilegeManager.Instance.monthlyExcessDays > 0 then
        if PrivilegeManager.Instance.canReceiveMonthly == true then
            PrivilegeManager.Instance:send9931()
        else
            if SdkManager.Instance:RunSdk() and self.monthData ~= nil then
                SdkManager.Instance:ShowChargeView(self.monthData.tag, self.monthData.rmb, self.monthData.gold, self.monthData.extraString)
            end
        end
    else
        if SdkManager.Instance:RunSdk() and self.monthData ~= nil then
            SdkManager.Instance:ShowChargeView(self.monthData.tag, self.monthData.rmb, self.monthData.gold, self.monthData.extraString)
        end
    end
end

function ShopMonthlyPanel:OnShowTips()
    self.tipContent = self.tipContent or {
        TI18N("每天可获得<color='#ffff00'>10点</color>额外饱食度"),
        TI18N("银币市场刷新时间<color='#ffff00'>缩短30秒</color>"),
        TI18N("魔法炼化生产道具<color='#ffff00'>减少10分钟</color>"),
        TI18N("家园每天打扫清洁度<color='#ffff00'>额外增加5点</color>"),
        TI18N("每日赠送好友道具<color='#ffff00'>上限+1</color>"),
        TI18N("活力值<color='#ffff00'>上限+200</color>"),
    }

     TipsManager.Instance:ShowText({gameObject = self.btnTips.gameObject, itemData = self.tipContent})
end

function ShopMonthlyPanel:OpenSubPanel()
    if self.subpanel == nil then
        self.subpanel = OpenServerMonthSubPanel.New(self.model,self.model.shopWin.gameObject)
    end
    self.subpanel:Show()
end
