-- @author 黄耀聪
-- @date 2016年6月21日

RechargeGiftPanel = RechargeGiftPanel or BaseClass(BasePanel)

function RechargeGiftPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "RechargeGiftPanel"

    self.resList = {
        {file = AssetConfig.shop_recharge_panel, type = AssetType.Main}
        , {file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.setting = {
        column = 4
        ,cspacing = 10
        ,rspacing = 6
        ,cellSizeX = 172
        ,cellSizeY = 176
    }
    self.chargeNoticeText = TI18N("充值不到账请联系客服中心：<color=#00FF00>%s</color>")
    self.explainString = TI18N("1.购买{assets_2, 90002}礼物可自己使用或赠送给朋友\n2.购买{assets_2, 90002}礼物不享受限时优惠奖励和首充奖励及其他充值类活动")
    self.giftList = {}

    self.indulgeListener = function() self:RefreshIndulge() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RechargeGiftPanel:__delete()
    self.OnHideEvent:Fire()
    if self.giftList ~= nil then
        for i,v in ipairs(self.giftList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.giftList = nil
    end
    if self.msgExt ~= nil then
        self.msgExt:DeleteMe()
        self.msgExt = nil
    end
    if self.giftLayout ~= nil then
        self.giftLayout:DeleteMe()
        self.giftLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RechargeGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_recharge_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("Panel"):GetComponent(ScrollRect).movementType = 2
    self.rechargeCloner = t:Find("Panel/RechargeItem").gameObject
    self.rechargePanel = t:Find("Panel/Container")

    self.noticeText = t:Find("Notice"):GetComponent(Text)
    self.noticeRect = t:Find("Notice"):GetComponent(RectTransform)
    self.noticeObj = self.noticeText.gameObject

    t:Find("Explain").gameObject:SetActive(true)
    self.explainRect = t:Find("Explain"):GetComponent(RectTransform)
    self.explainTextRect = t:Find("Explain/Text"):GetComponent(RectTransform)
    self.explainText = t:Find("Explain/Text"):GetComponent(Text)

    self.msgExt = MsgItemExt.New(self.explainText, 486, 16, 23)
    self.msgExt:SetData(self.explainString)
    self.explainTextRect.anchoredPosition = Vector2((self.explainRect.sizeDelta.x - self.explainTextRect.sizeDelta.x) / 2, (self.explainTextRect.sizeDelta.y - self.explainRect.sizeDelta.y) / 2)

    self.giftLayout = LuaGridLayout.New(self.rechargePanel, self.setting)
    local obj = nil
    local datalist = {}
    for _,v in pairs(DataRecharge.data_gift) do
        table.insert(datalist, v)
    end
    table.sort(datalist, function(a,b) return a.money < b.money end)
    for i,v in ipairs(datalist) do
        if self.giftList[i] == nil then
            obj = GameObject.Instantiate(self.rechargeCloner)
            self.giftLayout:AddCell(obj)
            obj.name = tostring(i)
            self.giftList[i] = RechargeGiftItem.New(self.model, obj, self.assetWrapper, function(data) self:ShowChargeView(data) end)
        end
        self.giftList[i]:update_my_self(v,i)
    end
    self.rechargeCloner:SetActive(false)
    t:Find("Panel/MonthlyItem").gameObject:SetActive(false)
end

function RechargeGiftPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RechargeGiftPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.indulge_change, self.indulgeListener)

    self:RefreshIndulge()
    self.noticeRect.sizeDelta = Vector2(math.ceil(self.noticeText.preferredWidth), math.ceil(self.noticeText.preferredHeight))

    -- local platformChanleId = ctx.PlatformChanleId
    -- self.noticeObj:SetActive(platformChanleId == 0
    --                          or platformChanleId == 33
    --                          or platformChanleId == 74)
end

function RechargeGiftPanel:OnHide()
    self:RemoveListeners()
end

function RechargeGiftPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.indulge_change, self.indulgeListener)
end

function RechargeGiftPanel:ShowChargeView(data)
    --BaseUtils.dump(data, "充值数据")
    if SdkManager.Instance:RunSdk() then
        SdkManager.Instance:ShowChargeView(data.tag, data.rmb, data.gold, "1")
    end
end

function RechargeGiftPanel:RefreshIndulge()
    local indulgeData = ((RoleManager.Instance.indulgeData or {})[RoleManager.Instance.RoleData.platform] or {})[ctx.PlatformChanleId] or {}
    -- local indulgeData = (RoleManager.Instance.indulgeData or {})[ctx.PlatformChanleId] or {}

    if indulgeData.is_show_phone == 1 then
        self.noticeObj:SetActive(true)
        self.noticeText.text = string.format(self.chargeNoticeText, indulgeData.show_info)
        self.noticeRect.sizeDelta = Vector2(math.ceil(self.noticeText.preferredWidth), math.ceil(self.noticeText.preferredHeight))
    else
        self.noticeObj:SetActive(false)
    end
end
