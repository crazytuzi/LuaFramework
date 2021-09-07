-- ----------------------------------------------------------
-- UI  招募奖励面板
-- ----------------------------------------------------------
LuckMoney2 = LuckMoney2 or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function LuckMoney2:__init(model, parent)
	self.model = SpringFestivalManager.Instance.model
    self.parent = parent
    self.name = "LuckMoney2"
    self.resList = {
        {file = AssetConfig.luckmoney2, type = AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.numPrePage = 6
    self.maxPageNum = #DataLuckyMoney.data_round
    self.pageObjList = {}
    self.pageNum = #DataLuckyMoney.data_round
    self.hasInitPage = {}
    self.itemObjList = {}

    self.currentPage = 1
    ------------------------------------------------
    self._update = function()
        self:update()
    end

    self._showEffect = function()
        self:ShowEffect()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function LuckMoney2:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.luckmoney2))
    self.gameObject.name = "LuckMoney2"
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    self.transform = self.gameObject.transform

    -----------------------------------------
    local transform = self.transform

    self.buyContainer = transform:Find("Panel/Container")
    self.scrollRect = transform:Find("Panel"):GetComponent(ScrollRect)
    self.buyPanel = transform:Find("Panel/BuyPanel")                      -- 翻页模板
    self.itemTemplate = self.buyPanel:Find("ItemObject").gameObject         -- 物品模板
    self.itemTemplate:SetActive(false)
    self.buyPanel.gameObject:SetActive(false)

    if self.boxXLayout == nil then
        local setting = {
            axis = BoxLayoutAxis.X
            ,cspacing = 0
        }
        self.boxXLayout = LuaBoxLayout.New(self.buyContainer, setting)
    end

    self.tabbedPanel = TabbedPanel.New(self.scrollRect.gameObject, self.maxPageNum, 520)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)
    self.tabbedPanel.scrollbar.onValueChanged:AddListener(function(value) self:OnValueChanged(value) end)

    for i=1,self.maxPageNum do
        local tab = {}
        tab.obj = GameObject.Instantiate(self.buyPanel.gameObject)
        tab.obj.name = tostring(i)
        tab.transform = tab.obj.transform
        self.boxXLayout:AddCell(tab.obj)
        tab.transform.localScale = Vector3.one

        local obj = tab.transform:Find("ItemObject").gameObject
        obj:SetActive(false)
        for j=1,self.numPrePage do
            local tab1 = {}
            tab1.obj = GameObject.Instantiate(obj)
            tab1.transform = tab1.obj.transform
            tab1.transform:SetParent(tab.transform)
            tab1.transform.localScale = Vector3.one
            tab1.obj.name = tostring((i - 1) * self.numPrePage + j)
            tab1.obj:SetActive(false)

            tab1.titleText = tab1.transform:Find("Title/Text"):GetComponent(Text)
            tab1.OpenButton = tab1.transform:Find("OpenButton"):GetComponent(Button)
            tab1.OpenButton.onClick:AddListener(function ()
                self:OnOpenButton(tonumber(tab1.obj.name))
            end)
            tab1.hasOpenText = tab1.transform:Find("HasOpenText"):GetComponent(Text)
            tab1.moneyObject = tab1.transform:Find("Money").gameObject
            tab1.moneyText = tab1.moneyObject.transform:Find("Text"):GetComponent(Text)
            tab1.moneyIcon = tab1.moneyObject.transform:Find("AssetIcon")
            tab1.okButtonText = tab1.transform:Find("OkButton/Text"):GetComponent(Text)
            tab1.okButton = tab1.transform:Find("OkButton"):GetComponent(Button)
            tab1.okButton.onClick:AddListener(function ()
                self:OnOkButton(tonumber(tab1.obj.name))
            end)
            tab1.hasGetObject = tab1.transform:Find("HasGet").gameObject
            tab1.dayObject = tab1.transform:Find("Day").gameObject
            tab1.dayText1 = tab1.transform:Find("Day/Text"):GetComponent(Text)
            tab1.dayText2 = tab1.transform:Find("Day/DayText"):GetComponent(Text)
            tab1.LabelObject = tab1.transform:Find("Label").gameObject
            tab1.okButton2 = tab1.transform:Find("OkButton2"):GetComponent(Button)
            tab1.okButton2.onClick:AddListener(function ()
                self:OnOkButton2(tonumber(tab1.obj.name))
            end)

            tab1.transform.anchoredPosition = Vector3(17 + 173 * ((j - 1) % 3), -10 - math.floor((j - 1) / 3) * 190, 0)

            self.itemObjList[(i - 1) * self.numPrePage + j] = tab1

            local fun = function(effectView)
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(tab1.OpenButton.transform)
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.localPosition = Vector3(0, 0, -400)
                effectObject.transform.localRotation = Quaternion.identity
        
                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectObject:SetActive(false)

                tab1.OpenButtonEffect = effectView
            end
            tab1.OpenButtonEffect = BaseEffectView.New({effectId = 20271, time = nil, callback = fun})
        end
        self.pageObjList[i] = tab
    end

    -- 按钮功能绑定
    self.btnNextPage = transform:Find("NextPageBtn"):GetComponent(Button)
    -- self.btnNextPage.transform.localScale = Vector3(1.5, 1.5, 1)
    self.btnNextPage.onClick:AddListener(function ()
        if self.enableNextPage == true then
            if self.currentPage < self.pageNum then
                self.currentPage = self.currentPage + 1
            end

            self.tabbedPanel:TurnPage(self.currentPage)
            self.btnPrePage.enabled = false
            self.btnNextPage.enabled = false
        end
    end)
    self.btnPrePage = transform:Find("PrePageBtn"):GetComponent(Button)
    -- self.btnPrePage.transform.localScale = Vector3(-1.5, 1.5, 1)
    self.btnPrePage.onClick:AddListener(function ()
        if self.enablePrePage == true then
            if self.currentPage > 0 then
                self.currentPage = self.currentPage - 1
            end

            self.tabbedPanel:TurnPage(self.currentPage)
            self.btnPrePage.enabled = false
            self.btnNextPage.enabled = false
        end
    end)

    self.descIcon = transform:FindChild("DescIcon").gameObject
    self.descText = MsgItemExt.New(transform:FindChild("DescText"):GetComponent(Text), 520, 20, 30)
    self.descText2 = MsgItemExt.New(transform:FindChild("DescText2"):GetComponent(Text), 520, 20, 30)
    
    -----------------------------------------

    -----------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function LuckMoney2:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function LuckMoney2:OnShow()
    self:UpdateDataPanel(1)
    if #DataLuckyMoney.data_round > 1 then
        self:UpdateDataPanel(2)
    end
    self:UpdatePageButton()
--         self.showEffect = true
--         self.openIndex = 2
-- self:ShowEffect()
    self:update(true)

    SpringFestivalManager.Instance:Send18700()
    SpringFestivalManager.Instance.OnUpdateLuckMoney:Add(self._update)
    SpringFestivalManager.Instance.OnUpdateLuckMoneyOpen:Add(self._showEffect)
end

function LuckMoney2:OnHide()
    if self.updateTimerId ~= nil then
        LuaTimer.Delete(self.updateTimerId)
        self.updateTimerId = nil
    end
    SpringFestivalManager.Instance.OnUpdateLuckMoney:Remove(self._update)
    SpringFestivalManager.Instance.OnUpdateLuckMoneyOpen:Remove(self._showEffect)
end

function LuckMoney2:update(toPageMark)  
    local toPage = 0
    local data_lucky_money = nil
    local todayHasOpen = false
    for i, value in ipairs(self.model.lucky_money_data) do
        if toPage == 0 and ((value.status == 1 and value.index - self.model.day <= 0) or (value.status == 2 and value.round_id * 5 + 1 - self.model.day <= 0 )) then
            toPage = value.round_id
        end
        if DataLuckyMoney.data_lucky_money[value.id].index == self.model.day then
            data_lucky_money = DataLuckyMoney.data_lucky_money[value.id]
            if value.status == 2 then
                todayHasOpen = true
            end
        end
    end

    if toPageMark then
        if toPage > 0 then
            self.tabbedPanel:TurnPage(toPage)
        elseif self.model.round_id_now > 0 then
            self.tabbedPanel:TurnPage(self.model.round_id_now)
        end
    end
    
    for i=1,#DataLuckyMoney.data_round do
        self:UpdateDataPanel(i)
    end

    if data_lucky_money ~= nil and todayHasOpen then
        self.descIcon:SetActive(true)
        self.descText:SetData(string.format(TI18N("今日消耗{assets_2,%s}的<color='#00ff00'>%s%%</color>会帮你存入当天红包"), data_lucky_money.assets_type, data_lucky_money.ratio))
        self.descText2:SetData(string.format(TI18N("红包上限为{assets_1,%s,%s}"), data_lucky_money.assets_type, data_lucky_money.limit))
    else
        self.descIcon:SetActive(false)
        self.descText:SetData("")
        self.descText2:SetData("")
    end
end

function LuckMoney2:OnDragEnd(currentPage, direction)
    if currentPage + 1 < self.pageNum then
        self.pageObjList[currentPage + 2].obj:SetActive(false)
    end
    if currentPage > 2 then
        self.pageObjList[currentPage - 2].obj:SetActive(false)
    end
    if currentPage < self.pageNum then
        self.pageObjList[currentPage + 1].obj:SetActive(true)
    end
    if currentPage > 1 then
        self.pageObjList[currentPage - 1].obj:SetActive(true)
    end

    if currentPage <= self.pageNum and currentPage > 0 then
        self.pageObjList[currentPage].obj:SetActive(true)
    else
        return
    end

    if currentPage > self.pageNum then
        currentPage = self.pageNum
    end
    if currentPage < 1 then
        currentPage = 1
    end
    self.currentPage = currentPage

    for i=1,#DataLuckyMoney.data_round do
        self:UpdateDataPanel(i)
    end
    self:UpdatePageButton()
    self.btnPrePage.enabled = true
    self.btnNextPage.enabled = true
end

function LuckMoney2:OnValueChanged(value)
    if self.hasShowOpenButtonEffect then
        for i, value in pairs(self.itemObjList) do
            if value.OpenButtonEffect then
                value.OpenButtonEffect:SetActive(false)
            end
        end
    end
    self.hasShowOpenButtonEffect = false

    if self.updateTimerId ~= nil then
        LuaTimer.Delete(self.updateTimerId)
        self.updateTimerId = nil
    end

    local fun = function()
        if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor
                or Application.platform == RuntimePlatform.OSXEditor or Application.platform == RuntimePlatform.OSXPlayer then
            if not Input.anyKey then
                LuaTimer.Delete(self.updateTimerId)
                self.updateTimerId = nil
                self:UpdateDataPanel(self.currentPage)
            end
        else
            if Input.touchCount == 0 then
                LuaTimer.Delete(self.updateTimerId)
                self.updateTimerId = nil
                self:UpdateDataPanel(self.currentPage)
            end
        end
    end
    self.updateTimerId = LuaTimer.Add(0, 1000, fun)
end

function LuckMoney2:UpdatePageButton()
    local currentPage = self.currentPage
    local pageNum = self.pageNum

    local nextEnable = self.btnNextPage.gameObject.transform:Find("Enable").gameObject
    local nextDisable = self.btnNextPage.gameObject.transform:Find("Disable").gameObject

    local preEnable = self.btnPrePage.gameObject.transform:Find("Enable").gameObject
    local preDisable = self.btnPrePage.gameObject.transform:Find("Disable").gameObject

    if currentPage < pageNum then
        self.enableNextPage = true
        nextEnable:SetActive(true)
        nextDisable:SetActive(false)
    else
        self.enableNextPage = false
        nextEnable:SetActive(false)
        nextDisable:SetActive(true)
    end

    if currentPage > 1 then
        self.enablePrePage = true
        preDisable:SetActive(false)
        preEnable:SetActive(true)
    else
        self.enablePrePage = false
        preDisable:SetActive(true)
        preEnable:SetActive(false)
    end
end

function LuckMoney2:UpdateDataPanel(index)
    if index < 1 or index > self.maxPageNum then
        return
    end

    local itemlist = {}
    for _,value in ipairs(self.model.lucky_money_data) do
        table.insert(itemlist, value)
    end
    -- local itemlist = {1,2,3,4,5,6,7,8,9,10,11,12}

    local page = self.pageObjList[index]
    page.obj:SetActive(true)

    if itemlist[(index - 1) * self.numPrePage + 1] ~= nil then
        for i=1,self.numPrePage do
            self:SetItem(itemlist[(index - 1) * self.numPrePage + i], self.itemObjList[(index - 1) * self.numPrePage + i], i)
        end
    end
end

function LuckMoney2:SetItem(data, tab, i)
    if data == nil then
        tab.obj:SetActive(false)
        return
    end

    tab.obj:SetActive(true)
    tab.obj.name = tostring(data.id)

    local luckyMoneyData = DataLuckyMoney.data_lucky_money[data.id]
    if luckyMoneyData.index - self.model.day == 0 then
        tab.LabelObject:SetActive(true)
    else
        tab.LabelObject:SetActive(false)
    end

    if data.status == 0 or data.status == 1 then
        if luckyMoneyData.index - self.model.day > 0 then
            tab.titleText.text = luckyMoneyData.describe
            tab.OpenButton.gameObject:SetActive(true)
            tab.hasOpenText.gameObject:SetActive(false)
            tab.moneyObject:SetActive(false)
            tab.okButton.gameObject:SetActive(false)
            tab.hasGetObject:SetActive(false)
            tab.dayObject:SetActive(true)
            tab.dayText1.text = TI18N("天后可开")
            tab.dayText2.text = tostring(luckyMoneyData.index - self.model.day)
            tab.OpenButtonEffect:SetActive(false)
            tab.okButton2.gameObject:SetActive(false)
        else
            tab.titleText.text = luckyMoneyData.describe
            tab.OpenButton.gameObject:SetActive(true)
            tab.hasOpenText.gameObject:SetActive(false)
            tab.moneyObject:SetActive(false)
            tab.okButton.gameObject:SetActive(false)
            tab.hasGetObject:SetActive(false)
            tab.dayObject:SetActive(false)
            if self.currentPage == data.round_id then
                tab.OpenButtonEffect:SetActive(true)
                self.hasShowOpenButtonEffect = true
            else
                tab.OpenButtonEffect:SetActive(false)
            end
            tab.okButton2.gameObject:SetActive(false)
        end
    elseif data.status == 2 then
        if data.round_id * 5 + 1 - self.model.day > 0 then
            tab.titleText.text = luckyMoneyData.describe
            tab.OpenButton.gameObject:SetActive(false)
            tab.hasOpenText.gameObject:SetActive(true)
            tab.moneyObject:SetActive(true)
            local num = data.init_value + math.ceil(data.assets_value * luckyMoneyData.ratio / 100)
            if num > luckyMoneyData.limit then
                num = luckyMoneyData.limit
            end
            tab.moneyText.text = tostring(num)
            tab.moneyIcon:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.assets_type)
            tab.okButton.gameObject:SetActive(false)
            tab.hasGetObject:SetActive(false)
            tab.dayObject:SetActive(true)
            tab.dayText1.text = TI18N("天后可领")
            tab.dayText2.text = tostring(data.round_id * 5 + 1 - self.model.day)
            tab.okButton2.gameObject:SetActive(true)
        else
            tab.titleText.text = luckyMoneyData.describe
            tab.OpenButton.gameObject:SetActive(false)
            tab.hasOpenText.gameObject:SetActive(true)
            tab.moneyObject:SetActive(true)
            local num = data.init_value + math.ceil(data.assets_value * luckyMoneyData.ratio / 100)
            if num > luckyMoneyData.limit then
                num = luckyMoneyData.limit
            end
            tab.moneyText.text = tostring(num)
            tab.moneyIcon:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.assets_type)
            tab.okButtonText.text = "可领取"
            tab.okButton.gameObject:SetActive(true)
            tab.hasGetObject:SetActive(false)
            tab.dayObject:SetActive(false)
            tab.okButton2.gameObject:SetActive(false)
        end
    elseif data.status == 3 then
        tab.titleText.text = luckyMoneyData.describe
        tab.OpenButton.gameObject:SetActive(false)
        tab.hasOpenText.gameObject:SetActive(true)
        tab.moneyObject:SetActive(true)
        local num = data.init_value + math.ceil(data.assets_value * luckyMoneyData.ratio / 100)
        if num > luckyMoneyData.limit then
            num = luckyMoneyData.limit
        end
        tab.moneyText.text = tostring(num)
        tab.moneyIcon:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.assets_type)
        tab.okButton.gameObject:SetActive(false)
        tab.hasGetObject:SetActive(true)
        tab.dayObject:SetActive(false)
        tab.okButton2.gameObject:SetActive(false)
    end
end

function LuckMoney2:OnOpenButton(index)
    local data = self.model.lucky_money_data[index]
    if data == nil then
        return
    end
    local luckyMoneyData = DataLuckyMoney.data_lucky_money[data.id]

    if luckyMoneyData.index > self.model.day then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s天后才可开启红包，敬请期待{face_1, 3}"), luckyMoneyData.index - self.model.day))
    else
        self.showEffect = true
        self.openIndex = index
        -- SpringFestivalManager.Instance:Send18701(index)

        LuaTimer.Add(1500, function() SpringFestivalManager.Instance:Send18701(index) end)
        self:ShowEffect()
        self.showEffect = false
        -- LuaTimer.Add(2500, function() 
        --     -- NoticeManager.Instance:FloatTipsByString(string.format(TI18N("{assets_1,%s,%s}已存入红包中\n%s天后才可领取哦"), luckyMoneyData.assets_type, luckyMoneyData.assets_value, luckyMoneyData.round_id * 6 + 1 - self.model.day))
        --     local data = NoticeConfirmData.New()
        --     data.type = ConfirmData.Style.Sure
        --     data.content = string.format(TI18N("获得{assets_1,%s,%s}，赠送的{assets_1,%s,%s}已存入红包，今日消耗{assets_2,%s}的<color='#00ff00'>%s%%</color>也会存入红包，<color='#00ff00'>%s天</color>后就可领取哦啦{face_1,25}"), luckyMoneyData.reward[1][1], luckyMoneyData.reward[1][3],  luckyMoneyData.assets_type, luckyMoneyData.assets_value, luckyMoneyData.assets_type, luckyMoneyData.ratio, luckyMoneyData.round_id * 6 + 1 - self.model.day)
        --     data.sureLabel = TI18N("确认")
        --     NoticeManager.Instance:ConfirmTips(data)
        -- end)
    end
end

function LuckMoney2:OnOkButton(index)
    local list = self.model.lucky_money_data
    if list[index] == nil then
        return
    end

    self.showEffect = false
    SpringFestivalManager.Instance:Send18701(list[index].id)
end

function LuckMoney2:OnOkButton2(index)
    local data = self.model.lucky_money_data[index]
    if data == nil then
        return
    end
    local luckyMoneyData = DataLuckyMoney.data_lucky_money[data.id]

    local num = data.init_value + math.ceil(data.assets_value * luckyMoneyData.ratio / 100)
    if num > luckyMoneyData.limit then
        num = luckyMoneyData.limit
    end
    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已存入{assets_1,%s,%s}，%s天后才可领取哦"), data.assets_type, num, data.round_id * 5 + 1 - self.model.day))
end

function LuckMoney2:ShowEffect()
    if self.showEffect then
        local itemObj = self.itemObjList[self.openIndex]
        local position = itemObj.OpenButton.transform.position

        local fun = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.transform)
            effectObject.transform.localScale = Vector3(1, 1, 1)
            effectObject.transform.position = position
            effectObject.transform.localRotation = Quaternion.identity
    
            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        BaseEffectView.New({effectId = 20268, time = 1500, callback = fun})

        local effectId = 20269
        if DataLuckyMoney.data_lucky_money[self.openIndex].assets_type == 90000 then
            effectId = 20270
        end
        LuaTimer.Add(1500, function()
            local fun = function(effectView)
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(self.transform)
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.position = position
                effectObject.transform.localRotation = Quaternion.identity
        
                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectObject:SetActive(true)
            end
            BaseEffectView.New({effectId = effectId, time = 2000, callback = fun})
        end)
    end
end