ShopRechargePanel = ShopRechargePanel or BaseClass(BasePanel)

function ShopRechargePanel:__init(model, parent, main, sub)
    self.model = model
    self.parent = parent
    self.main = main
    self.sub = sub
    self.mgr = ShopManager.Instance

    model.chargeList = model:GetChargeList()

    if BaseUtils.IsVerify then
        AssetConfig.shop_recharge_panel = "prefabs/ui/shop/rechargepanel_verify.unity3d"
    end

    self.resList = {
        {file = AssetConfig.shop_recharge_panel, type = AssetType.Main}
        , {file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.setting = {
        column = 4
        ,cspacing = 10
        ,rspacing = 6
        ,bordertop = 5
        ,cellSizeX = 172
        ,cellSizeY = 176
    }
    self.rechargeList = {}

    self.chargeNoticeText = TI18N("充值不到账请联系客服中心：<color=#00FF00>%s</color>")

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:InitUI() end
    self.indulgeListener = function() self:RefreshIndulge() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

    if BaseUtils.IsVerify then
        table.insert(self.resList, {file = AssetConfig.bible_textures, type = AssetType.Dep})
    end
end

function ShopRechargePanel:__delete()
    self.OnHideEvent:Fire()

    if self.rechargeList ~= nil then
        for _,v in pairs(self.rechargeList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.rechargeList = nil
    end
    if self.rechargeLayout ~= nil then
        self.rechargeLayout:DeleteMe()
        self.rechargeLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ShopRechargePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_recharge_panel))
    self.gameObject.name = "ShopRechargePanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform
    local model = self.model

    self.rechargeCloner = t:Find("Panel/RechargeItem").gameObject
    self.monthlyCloner = t:Find("Panel/MonthlyItem").gameObject
    self.rechargePanel = t:Find("Panel/Container")
    self.noticeText = t:Find("Notice"):GetComponent(Text)
    self.noticeRect = t:Find("Notice"):GetComponent(RectTransform)
    self.noticeObj = self.noticeText.gameObject

    self.explainObj = t:Find("Explain").gameObject

    if BaseUtils.IsVerify then
        local verifySetting = BaseUtils.GetVerifySetting()
        local gridLayoutGroup = self.rechargePanel:GetComponent(GridLayoutGroup)
        if verifySetting.rechargeType == 1 then
            gridLayoutGroup.cellSize = Vector2(170, 180)
        elseif verifySetting.rechargeType == 2 then
            gridLayoutGroup.cellSize = Vector2(230, 180)
        elseif verifySetting.rechargeType == 3 then
            gridLayoutGroup.cellSize = Vector2(350, 180)
        end
        self.monthlyCloner:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, "DHItemBg"..verifySetting.rechargeItemBg)
        self.rechargeCloner:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, "DHItemBg"..verifySetting.rechargeItemBg)
    end

    self.rechargeLayout = LuaGridLayout.New(self.rechargePanel, self.setting)
    self.explainObj:SetActive(false)
    local obj = nil
    local monthGold = 0
    for _,v in pairs(DataMonthCard.data_get_reward) do
        monthGold = v.gold
        break
    end

    if BaseUtils.IsVerify and BaseUtils.IsIosVest() then 
        for i = #model.chargeList , 1 , -1 do
            if model.chargeList[i].gold == monthGold then
                table.remove( model.chargeList, i)
            end
        end
    end

    for i,v in ipairs(model.chargeList) do
        if self.rechargeList[i] == nil then
            -- if v.gold == monthGold and PrivilegeManager.Instance.canReceiveMonthly then
            if v.gold == monthGold then
                obj = GameObject.Instantiate(self.monthlyCloner)
                self.rechargeList[i] = ShopMonthlyItem.New(self.model, obj, self.assetWrapper, function(data) self:ShowChargeView(data) end)
            else
                -- local num = DataRecharge.data_turn_score[i].tokes

                obj = GameObject.Instantiate(self.rechargeCloner)
                self.rechargeList[i] = ShopRechargeItem.New(self.model, obj, self.assetWrapper, function(data) self:ShowChargeView(data) end)
                -- self.rechargeList[i]:SetLabelNum(num)
            end
            self.rechargeLayout:AddCell(obj)
            obj.name = tostring(i)
        end
        -- self.rechargeList[i]:SetData(v,i)
        self.rechargeList[i]:SetActive(false)
    end
    self.rechargeCloner:SetActive(false)
    self.monthlyCloner:SetActive(false)

    self.OnOpenEvent:Fire()
end

function ShopRechargePanel:OnOpen()
    self.rebateData = ShopManager.Instance.dataList
    ShopManager.Instance:send14019()
    self:RemoveListeners()
    self:AddListeners()


    self.mgr.redPoint[self.main][self.sub] = false
    self.mgr.onUpdateRedPoint:Fire()

    self:RefreshIndulge()
    self.noticeRect.sizeDelta = Vector2(math.ceil(self.noticeText.preferredWidth), math.ceil(self.noticeText.preferredHeight))
    local platformChanleId = ctx.PlatformChanleId
    -- self.noticeObj:SetActive(platformChanleId == 0
    --                          or platformChanleId == 33
    --                          or platformChanleId == 74)
    -- self:InitUI()
end

function ShopRechargePanel:OnHide()
    self:RemoveListeners()
end

function ShopRechargePanel:AddListeners()
    CampaignManager.Instance.onUpdateRecharge:AddListener(self.updateListener)
    EventMgr.Instance:AddListener(event_name.indulge_change, self.indulgeListener)
end

function ShopRechargePanel:RemoveListeners()
    CampaignManager.Instance.onUpdateRecharge:RemoveListener(self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.indulge_change, self.indulgeListener)
end

function ShopRechargePanel:InitUI()
    local lenth = 1
    for i,v in ipairs(self.model.chargeList) do
        if CampaignManager.Instance.campaignData[lenth] ~= nil and i >1 then
            self.rechargeList[i]:SetData(v,i,CampaignManager.Instance.campaignData[lenth].reward_can,self.rebateData[lenth])
            lenth = lenth + 1
        else
            self.rechargeList[i]:SetData(v,i,0,self.rebateData[lenth])
        end

    end
    --BaseUtils.dump(self.model.rechargeLog, "rechargeLog")
    if BaseUtils.IsVerify then
        BaseUtils.VestChangeWindowBg(self.gameObject)
    end
end

function ShopRechargePanel:ShowChargeView(data)
    --BaseUtils.dump(data, "充值数据")
    --print(self:GetProductId(data.rmb))


    if SdkManager.Instance:RunSdk() then
        SdkManager.Instance:ShowChargeView(data.tag, data.rmb, data.gold, data.extraString)
    else
        if RoleManager.Instance:CanIRecharge(data.rmb) then
            NoticeManager.Instance:FloatTipsByString("进入充值")
        end
    end
end



function ShopRechargePanel:GetProductId(amount)
    local platformId = ctx.PlatformChanleId
    local defaultProductId = "None"
    if DataRecharge.data_androidwithid[platformId] ~= nil then
        for k,v in pairs(DataRecharge.data_androidwithid[platformId].id2item) do
            if v[2] == amount then
                defaultProductId = tostring(v[1])
                break
            end
        end
    end
    return defaultProductId
end

function ShopRechargePanel:RefreshIndulge()
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
