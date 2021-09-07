BibleInvestPanel = BibleInvestPanel or BaseClass(BasePanel)

function BibleInvestPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.rechargeAmount = 88
    self.receiveNum = 2880
    self.rechargeAmount_sg = 1099

    self.resList = {
        {file = AssetConfig.bible_invest_panel, type = AssetType.Main}
    }

    self.investItemList = {}
    self.investTypeTime = {TI18N("三倍"),TI18N("两倍")}
    self.title = TI18N("神秘的钻石袋是伊芙从未来世界带给你最好的祝福")
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        self.desc1 = TI18N(string.format("<color=#ffff00>充值$%s</color>可获得<color=#23f0f7>伊芙的钻石袋</color>", tostring(self.rechargeAmount_sg / 100)))
    else
        self.desc1 = TI18N(string.format("<color=#ffff00>充值￥%s</color>可获得<color=#23f0f7>伊芙的钻石袋</color>", tostring(self.rechargeAmount)))
    end
    self.desc = TI18N("达到登录天数要求可领取总共<color=#00FF00>%s</color>返还{assets_2, 90002}<color=#ffff00>%s</color>")

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:ReloadList() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function BibleInvestPanel:__delete()
    self.OnHideEvent:Fire()

    if self.msgItemExt ~= nil then
        self.msgItemExt:DeleteMe()
        self.msgItemExt = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BibleInvestPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_invest_panel))
    self.gameObject.name = "InvestPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.titleText = self.transform:Find("Title/Text"):GetComponent(Text)
    self.titleRect = self.transform:Find("Title/Text"):GetComponent(RectTransform)
    self.leftRect = self.transform:Find("Title/Text/Left"):GetComponent(RectTransform)
    self.rightRect = self.transform:Find("Title/Text/Right"):GetComponent(RectTransform)
    local height = self.titleRect.sizeDelta.y

    self.scrollLayerRect = self.transform:Find("MaskLayer/ScrollLayer"):GetComponent(RectTransform)
    self.container = self.transform:Find("MaskLayer/ScrollLayer/Container")
    self.containerRect = self.container:GetComponent(RectTransform)
    local bgWidth = self.containerRect.sizeDelta.x
    self.cloner = self.container:Find("Cloner").gameObject
    self.descText = self.transform:Find("Desc/Text"):GetComponent(Text)
    self.descText1 = self.transform:Find("Desc/Text1"):GetComponent(Text)
    self.descObj = self.transform:Find("Desc").gameObject
    self.rechargeBtn = self.transform:Find("Desc/Button"):GetComponent(Button)
    self.rechargeDescText = self.transform:Find("Desc/Button/Text"):GetComponent(Text)

    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        self.rechargeDescText.text = string.format(TI18N("充值$%s"), tostring(self.rechargeAmount_sg / 100))
    else
        self.rechargeDescText.text = string.format(TI18N("充值￥%s"), tostring(self.rechargeAmount))
    end
    -- self.rechargeDescAmount = self.transform:Find("Desc/Button/Text/Amount"):GetComponent(Text)
    -- self.rechargeDescDesc = self.transform:Find("Desc/Button/Text/Amount"):GetComponent(Text)

    self.hadBuyObj = self.transform:Find("Desc/HadBuy").gameObject

    self.rechargeBtn.onClick:RemoveAllListeners()
    self.rechargeBtn.onClick:AddListener(function() self:OnRecharge() end)
    self.msgItemExt = MsgItemExt.New(self.descText, 473, 15, 20)
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        self.msgItemExt:SetData(string.format(self.desc, tostring(self.investTypeTime[self.model.invest_type]), "1680"), true)
    else
        self.msgItemExt:SetData(string.format(self.desc, tostring(self.investTypeTime[self.model.invest_type]), tostring(self.receiveNum)), true)
    end
    self.titleText.text = self.title
    self.titleRect.sizeDelta = Vector2(self.titleText.preferredWidth + 5, height)
    self.descText1.text = self.desc1

    height = self.leftRect.sizeDelta.y
    local width = (bgWidth - self.titleRect.sizeDelta.x) / 2
    if width > 100 then
        width = 100
    end
    self.leftRect.sizeDelta = Vector2(width, height)
    self.rightRect.sizeDelta = Vector2(width, height)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.cloner:SetActive(false)

    self.OnOpenEvent:Fire()
end

function BibleInvestPanel:OnOpen()
    self:ReloadList(true)

    self:RemoveListener()
    self.mgr.onUpdateInvest:AddListener(self.updateListener)
end

function BibleInvestPanel:OnHide()
    self:RemoveListener()
end

function BibleInvestPanel:RemoveListener()
    self.mgr.onUpdateInvest:RemoveListener(self.updateListener)
end

function BibleInvestPanel:ReloadList(doLocate)
    local model = self.model
    local list = {}
    local obj = nil

    self.receiveNum = 0

    for _,v in pairs(DataInvestment.data_get) do
        if model.invest_type == v.id then
            list[v.day] = DataInvestment.data_get[v.day.."_"..v.id]
            if list[v.day].reward[1][1] == 90002 then
                self.receiveNum = self.receiveNum + list[v.day].reward[1][2]
            end
        end
    end

    for i=1,DataInvestment.data_get_length / 2 do
    end

    -- self.msgItemExt:SetData(string.format(self.desc, tostring(self.investTypeTime[self.model.invest_type]), tostring(self.receiveNum)), true)
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        self.msgItemExt:SetData(string.format(self.desc, tostring(self.investTypeTime[self.model.invest_type]), "1680"), true)
    else
        self.msgItemExt:SetData(string.format(self.desc, tostring(self.investTypeTime[self.model.invest_type]), tostring(self.receiveNum)), true)
    end

    self.mgr.redPointDic[1][4] = false
    self.mgr.onUpdateRedPoint:Fire()

    self.rechargeBtn.gameObject:SetActive(#model.invest_data == 0)
    self.hadBuyObj.gameObject:SetActive(#model.invest_data ~= 0)

    if self.effect == nil then
        self.effect = BibleRewardPanel.ShowEffect(20118, self.rechargeBtn.transform, Vector3(1.15,0.8,1), Vector3(-120.6,22,0))
    end

    local firstReceivable = 1

    for i,v in ipairs(list) do
        if self.investItemList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.investItemList[i] = BibleInvestItem.New(self.model, obj)
        end
        v.state = 0
        if model.invest_data[i] == nil then
            v.state = 0     -- 未达成
        elseif model.invest_data[i].rewarded == 0 then
            v.state = 1     -- 可领取
        else
            v.state = 2     -- 已领取
        end
        self.investItemList[i]:SetData(v, i)
    end


    for i=1,#list do
        if list[i].state == 1 then
            firstReceivable = i
            break
        end
    end

    for i=#list + 1, #self.investItemList do
        self.investItemList[i]:SetActive(false)
    end

    if doLocate == true then
        local y = 0 - self.investItemList[firstReceivable].rect.anchoredPosition.y
        if self.containerRect.sizeDelta.y - y < self.scrollLayerRect.sizeDelta.y then
            y = self.containerRect.sizeDelta.y - self.scrollLayerRect.sizeDelta.y
        end

        self.containerRect.anchoredPosition = Vector2(0, y)
    end
end

function BibleInvestPanel:OnRecharge()
    if SdkManager.Instance:RunSdk() and self.model.invest_data ~= nil and #self.model.invest_data == 0 then
        if BaseUtils.GetLocation() == KvData.localtion_type.sg then
            local dataItem = BaseUtils.GetProductDataForEyou(self.rechargeAmount_sg)
            if dataItem ~= nil then
                SdkManager.Instance:ShowChargeView(dataItem.tag, dataItem.rmb,dataItem.gold)
            end
        else
            -- SdkManager.Instance:ShowChargeView(string.format("StardustRomance3K%s0", tostring(self.rechargeAmount)), self.rechargeAmount, self.rechargeAmount * 10)
            SdkManager.Instance:ShowChargeView(ShopManager.Instance.model:GetSpecialChargeData(tonumber(self.rechargeAmount)*10), self.rechargeAmount, self.rechargeAmount * 10)
        end
    end
end

function BibleInvestPanel:LayoutButton()

end