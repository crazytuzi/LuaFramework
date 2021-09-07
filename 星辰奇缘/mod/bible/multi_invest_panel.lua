-- @author 黄耀聪
-- @date 2016年6月3日

MultiInvestPanel = MultiInvestPanel or BaseClass(BasePanel)

function MultiInvestPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MultiInvestPanel"
    self.mgr = BibleManager.Instance

    self.resList = {
        {file = AssetConfig.multi_invest_panel, type = AssetType.Main},
        {file = AssetConfig.invest_textures, type = AssetType.Dep},
        {file = AssetConfig.shop_textures, type = AssetType.Dep},
    }

    self.descString = TI18N("获得伊芙的钻石袋，每天登录可以领取<color=#00FF00>钻石和金币</color>奖励，每种钻石袋只能购买一次")

    self.planList = {}
    self.investList = {}

    self.updateListener = function()
        self:UpdateData()
        if self.currentData ~= nil then
            self:UpdateDetail()
        else
            self:OpenPlanView()
        end
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MultiInvestPanel:__delete()
    self.OnHideEvent:Fire()

    if self.planList ~= nil then
        for k,v in pairs(self.planList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.planList = nil
    end
    if self.investList ~= nil then
        for k,v in pairs(self.investList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.investList = nil
    end
    if self.planLayout ~= nil then
        self.planLayout:DeleteMe()
        self.planLayout = nil
    end
    if self.investLayout ~= nil then
        self.investLayout:DeleteMe()
        self.investLayout = nil
    end
    if self.rewardList ~= nil then
        for _,v in pairs(self.rewardList) do
            if v.icon ~= nil then
                v.icon.sprite = nil
            end
        end
    end
    self:AssetClearAll()
end

function MultiInvestPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.multi_invest_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local planView = t:Find("PlanView")
    self.planViewObj = planView.gameObject
    self.planRect = planView:Find("ScrollLayer"):GetComponent(RectTransform)
    self.planContainer = planView:Find("ScrollLayer/Container")
    self.planCloner = planView:Find("ScrollLayer/Cloner").gameObject

    local detail = t:Find("Detail")
    self.detailObj = detail.gameObject
    self.detailPlanObj = detail:Find("IncomePreview").gameObject
    self.incomePreviewObj = detail:Find("IncomePreview").gameObject
    self.investContainer = detail:Find("ScrollLayer/Container")
    self.scrollLayerRect = detail:Find("ScrollLayer"):GetComponent(RectTransform)
    self.investContainerRect = self.investContainer:GetComponent(RectTransform)
    self.investCloner = detail:Find("ScrollLayer/Cloner").gameObject

    local desc = t:Find("Desc")
    self.descText = desc:Find("Text"):GetComponent(Text)
    self.descText1 = desc:Find("Text1"):GetComponent(Text)
    self.backBtn = desc:Find("Button"):GetComponent(Button)

    self.backBtn.onClick:AddListener(function() self:OpenPlanView() end)

    self.descText1.text = self.descString
    self.descText.text = ""

    local detailPlanRect = self.detailPlanObj.transform:Find("Bg/Income"):GetComponent(RectTransform)
    detailPlanRect.anchorMax = Vector2(0.5, 1)
    detailPlanRect.anchorMin = Vector2(0.5, 1)
end

function MultiInvestPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MultiInvestPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateInvest:AddListener(self.updateListener)

    self:UpdateData()
    self:OpenPlanView()
end

function MultiInvestPanel:OnHide()
    self:RemoveListeners()
end

function MultiInvestPanel:RemoveListeners()
    self.mgr.onUpdateInvest:RemoveListener(self.updateListener)
end

function MultiInvestPanel:OpenPlanView()
    if self.planInited ~= true then
        self:InitPlanView()
    end
    self.planViewObj:SetActive(true)
    self.detailObj:SetActive(false)
    self.backBtn.gameObject:SetActive(false)
    self.currentData = nil

    for i,v in ipairs(self.datalist) do
        self.planList[i]:SetData(v, i)
        self.planList[i].callback = function() self.currentData = v self:UpdateDetail(true) end
    end
    for i=#self.datalist + 1,#self.planList do
        self.planList[i]:SetActive(false)
    end

    self.planRect.sizeDelta = self.planLayout.panelRect.sizeDelta
end

function MultiInvestPanel:UpdateData()
    local model = self.model

    local list = {}
    local list2 = {}

    local receiveNum = {{[90002] = 0, [90003] = 0} ,{[90002] = 0, [90003] = 0}}

    for _,v in pairs(DataInvestment.data_get) do
        if model.invest_type == v.id then
            list[v.day] = DataInvestment.data_get[v.day.."_"..v.id]
            list[v.day].type = 1
            for _,reward in ipairs(list[v.day].reward) do
                receiveNum[1][reward[1]] = receiveNum[1][reward[1]] + reward[2]
            end
        end
        if list[v.day] ~= nil then
            if model.invest_data[v.day] == nil then
                list[v.day].state = 0     -- 未达成
            elseif model.invest_data[v.day].rewarded == 0 then
                list[v.day].state = 1     -- 可领取
            else
                list[v.day].state = 2     -- 已领取
            end
        end
    end

    for _,v in pairs(DataInvestment.data_get2) do
        list2[v.day] = DataInvestment.data_get2[v.day]
        list2[v.day].type = 2
        for _,reward in ipairs(list2[v.day].reward) do
            receiveNum[2][reward[1]] = receiveNum[2][reward[1]] + reward[2]
        end
        if model.invest_data2[v.day] == nil then
            list2[v.day].state = 0     -- 未达成
        elseif model.invest_data2[v.day].rewarded == 0 then
            list2[v.day].state = 1     -- 可领取
        else
            list2[v.day].state = 2     -- 已领取
        end
    end

    local income = {"", ""}
    for i=1,2 do
        local isFirst = true
        for k,v in pairs(receiveNum[i]) do
            if v > 0 then
                if not isFirst then
                    income[i] = income[i] .."+".. string.format("%s{assets_2, %s}", tostring(v), tostring(k))
                else
                    income[i] = income[i] .. string.format("%s{assets_2, %s}", tostring(v), tostring(k))
                end
                isFirst = false
            end
        end
    end

    self.datalist = {
        {name = TI18N("高级钻石袋"), money = 88, gold = receiveNum[1][90002], income = income[1], datalist = list},
        {name = TI18N("豪华钻石袋"), money = 188, gold = receiveNum[2][90002], income = income[2], datalist = list2},
    }
end

function MultiInvestPanel:InitPlanView()
    local model = self.model
    if self.planLayout == nil then
        self.planLayout = LuaBoxLayout.New(self.planContainer, {axis = BoxLayoutAxis.X, border = 20})
    end

    self.planCloner:SetActive(false)
    self.planLayout:ReSet()
    for i,v in ipairs(self.datalist) do
        if self.planList[i] == nil then
            local obj = GameObject.Instantiate(self.planCloner)
            obj.name = tostring(i)
            self.planLayout:AddCell(obj)
            self.planList[i] = MultiInvestPlanItem.New(self.model, obj)
        end
        self.planList[i]:SetData(v, i)
        self.planList[i].callback = function() self.currentData = v self:UpdateDetail(true) end
    end

    for i=#self.datalist + 1,#self.planList do
        self.planList[i]:SetActive(false)
    end

    self.planRect.sizeDelta = self.planLayout.panelRect.sizeDelta

    self.planInited = true
end

function MultiInvestPanel:UpdateDetail(doLocate)
    local data = self.currentData
    local model = self.model
    self.backBtn.gameObject:SetActive(true)
    self.planViewObj:SetActive(false)
    self.detailObj:SetActive(true)

    if self.planList[0] == nil then
        self.planList[0] = MultiInvestPlanItem.New(self.model, self.detailPlanObj)
    end
    self.planList[0]:SetData(data, 0, true)

    if self.investLayout == nil then
        self.investLayout = LuaBoxLayout.New(self.investContainer, {axis = BoxLayoutAxis.Y, border = 5})
    end

    model.moneyToPlan = model.moneyToPlan or {}
    local datalist = data.datalist
    datalist = datalist or {}
    self.investCloner:SetActive(false)
    for i,v in ipairs(datalist) do
        if self.investList[i] == nil then
            local obj = GameObject.Instantiate(self.investCloner)
            obj.name = tostring(i)
            self.investLayout:AddCell(obj)
            self.investList[i] = MultiInvestItem.New(self.model, obj)
        end
        self.investList[i]:SetData(v, i)
    end

    for i=#datalist + 1,#self.investList do
        self.investList[i]:SetActive(false)
    end

    local firstReceivable = 1
    for i=1,#datalist do
        if datalist[i].state == 1 then
            firstReceivable = i
            break
        end
    end

    if doLocate == true then
        local y = 0 - self.investList[firstReceivable].rect.anchoredPosition.y
        if self.investContainerRect.sizeDelta.y - y < self.scrollLayerRect.sizeDelta.y then
            y = self.investContainerRect.sizeDelta.y - self.scrollLayerRect.sizeDelta.y
        end

        self.investContainerRect.anchoredPosition = Vector2(0, y)
    end
end

MultiInvestPlanItem = MultiInvestPlanItem or BaseClass()

function MultiInvestPlanItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    local t = gameObject.transform
    self.transform = t

    self.descString = TI18N("连续7天每天登录\n总共可领取<color='#13fc60'>%s</color>钻石")
    self.goBuyString = TI18N("查看详情")
    self.goReceiveString = TI18N("前往领取")
    self.hasRechargeString = TI18N("已购买")
    self.rechargeString = TI18N("充值￥%s购买")

    local bg = t:Find("Bg")
    if bg:Find("Title/Text") ~= nil then
        self.titleText = bg:Find("Title/Text"):GetComponent(Text)
    end
    self.iconImage = bg:Find("Diamond/Image"):GetComponent(Image)
    self.incomeText = bg:Find("Income"):GetComponent(Text)
    self.moneyText = bg:Find("Diamond/Money/Icon/Text"):GetComponent(Text)
    self.goBuyBtn = bg:Find("Button"):GetComponent(Button)
    self.goBtnText = bg:Find("Button/Text"):GetComponent(Text)
    self.descText = bg:Find("Desc/Text"):GetComponent(Text)
    self.incomeRect = self.incomeText.gameObject:GetComponent(RectTransform)

    self.goBuyBtn.onClick:AddListener(function() self:OnClick() end)
    self.incomeText.alignment = 0
end

function MultiInvestPlanItem:__delete()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.incomeExtText ~= nil then
        self.incomeExtText:DeleteMe()
        self.incomeExtText = nil
    end
end

function MultiInvestPlanItem:OnClick()
    if self.ext == true then
        if SdkManager.Instance:RunSdk() then
            -- SdkManager.Instance:ShowChargeView(string.format("StardustRomance3K%s0", tostring(self.data.money)), self.data.money, self.data.money * 10)
            SdkManager.Instance:ShowChargeView(ShopManager.Instance.model:GetSpecialChargeData(tonumber(self.data.money)*10), self.data.money, self.data.money * 10)
        end
    else
        if self.callback ~= nil then
            self.callback()
        end
    end
end

function MultiInvestPlanItem:SetData(data, index, ext)
    if self.titleText ~= nil then
        self.titleText.text = data.name
    end
    if self.incomeExtText == nil then
        self.incomeExtText = MsgItemExt.New(self.incomeText, 173, 16, 20)
    end
    self.ext = ext
    self.data = data
    self.incomeExtText:SetData(data.income, true)
    self.moneyText.text = tostring(data.money)
    self.descText.text = string.format(self.descString, tostring(data.gold))

    local status = 0    -- 2 可领取；0 未购买；1 已购买
    for i,v in ipairs(data.datalist) do
        if v.state == 1 then
            status = 2
            break
        elseif v.state == 2 then
            status = 3
        end
    end
    if status == 3 then
        status = 1
    end

    if ext then
        if status == 0 then
            self.goBtnText.text = string.format(self.rechargeString, tostring(data.money))
            self.goBtnText.enabled = true
        else
            self.goBtnText.text = self.hasRechargeString
            self.goBuyBtn.enabled = false
        end
        local w = self.incomeRect.sizeDelta.x
        self.incomeRect.anchoredPosition = Vector2(- w / 2 + 9, -11.5)
    else

        if self.effect ~= nil then
            self.effect:DeleteMe()
            self.effect = nil
        end

        if status == 0 then
            self.goBtnText.text = self.goBuyString
        elseif status == 1 then
            self.goBtnText.text = self.goReceiveString
        elseif status == 2 then
            self.goBtnText.text = self.goReceiveString
            self.effect = BibleRewardPanel.ShowEffect(20053, self.goBuyBtn.gameObject.transform, Vector3(1.6,0.65,1), Vector3(-50.1, -16.4, -400))
        end
        local w = self.incomeRect.sizeDelta.x
        self.incomeRect.anchoredPosition = Vector2(- w / 2 + 9, -20.5)
    end
    self.gameObject:SetActive(true)
end

function MultiInvestPlanItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

MultiInvestItem = MultiInvestItem or BaseClass()

function MultiInvestItem:__init(model, gameObject)
    self.gameObject = gameObject
    self.model = model
    local t = gameObject.transform
    self.transform = t

    self.loginString = TI18N("累计登录<color='#13fc60'>%s天</color>可领取")
    self.btnString = {TI18N("领 取"), TI18N("未达成")}

    self.titleText = t:Find("Title"):GetComponent(Text)
    local bg = t:Find("Bg")
    self.hasGetObj = bg:Find("HasGet").gameObject
    self.receiveBtn = bg:Find("Button"):GetComponent(Button)
    self.receiveImage = bg:Find("Button"):GetComponent(Image)
    self.receiveText = bg:Find("Button/Text"):GetComponent(Text)
    self.receiveTransition = bg:Find("Button"):GetComponent(TransitionButton)
    if self.receiveBtn == nil then
        self.receiveBtn = bg:Find("Button").gameObject:AddComponent(Button)
    end
    self.receiveBtn.onClick:AddListener(function() self:OnClick() end)
    self.rect = gameObject:GetComponent(RectTransform)

    self.rewardList = {}
    for i=1,2 do
        local tab = {obj = nil, image = nil, amount = nil, rect = nil}
        local trans = bg:Find("Reward"..i)
        tab.obj = trans.gameObject
        tab.icon = trans:Find("Icon"):GetComponent(Image)
        tab.amount = trans:Find("TextBg/Text"):GetComponent(Text)
        tab.rect = tab.obj:GetComponent(RectTransform)
        self.rewardList[i] = tab
    end
end

function MultiInvestItem:SetData(data, index)
    self.titleText.text = string.format(self.loginString, tostring(index))
    self.gameObject:SetActive(true)
    self.data = data

    if data.state == 0 then
        self.receiveBtn.enabled = false
        self.receiveText.text = self.btnString[2]
        self.receiveImage.enabled = false
        self.receiveTransition.enabled = false
        self.hasGetObj:SetActive(false)
    elseif data.state == 1 then
        self.receiveBtn.enabled = true
        self.receiveTransition.enabled = true
        self.receiveImage.enabled = true
        self.receiveText.text = self.btnString[1]
        self.hasGetObj:SetActive(false)
    elseif data.state == 2 then
        self.receiveBtn.enabled = false
        self.receiveImage.enabled = false
        self.receiveTransition.enabled = false
        self.hasGetObj:SetActive(true)
        self.receiveText.text = ""
    end

    for i,v in ipairs(self.rewardList) do
        if data.reward[i] == nil then
            v.obj:SetActive(false)
        else
            v.obj:SetActive(true)
            v.icon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.reward[i][1])
            v.amount.text = tostring(data.reward[i][2])
        end
    end
end

function MultiInvestItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function MultiInvestItem:OnClick()
    if self.data ~= nil then
        if self.data.type == 1 then
            BibleManager.Instance:send15301(self.data.day)
        elseif self.data.type == 2 then
            BibleManager.Instance:send15303(self.data.day)
        end
    end
end

