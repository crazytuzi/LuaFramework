NpcshopWindow = NpcshopWindow or BaseClass(BaseWindow)

function NpcshopWindow:__init(model)
    self.model = model

    self.windowId = WindowConfig.WinID.npcshop

    self.effectPath = "prefabs/effect/20053.unity3d"
    self.resList = {
        {file = AssetConfig.npc_shop_window, type = AssetType.Main}
    }
    if RoleManager.Instance.RoleData.lev <= 20 then
        table.insert(self.resList, {file = self.effectPath, type = AssetType.Dep})
    end

    self.datalist = nil
    self.itemList = {}
    self.itemObjList = {}
    self.pageObjList = {}
    -- self.selectItem = 1
    self.num = 1
    self.initCount = 1
    self.pageInit = {}      -- 页面是否已经更新
    self.maxNum = 10
    self.minNum = 1

    self.needList = {}

    self.listener = function (items)
        self:GetNeedList()
        for _,v in pairs(items) do
            if self.needList[v.id] ~= nil then
                self.needInBackpack[v.id] = BackpackManager.Instance:GetItemCount(v.id)
            end
        end
        self:InitDataPanel(1)

        local size = 0
        for k,v in pairs(self.datalist) do
            if self.needList[v.base_id] ~= nil and self.needInBackpack[v.base_id] ~= nil and self.needList[v.base_id] > self.needInBackpack[v.base_id] then
                self.autoClose = true
                size = size + 1
                break
            end
        end

        if self.autoClose == true and size == 0 then
            EventMgr.Instance:RemoveListener(self.listener)
            WindowManager.Instance:CloseWindow(self)
        end

        if self.frozen ~= nil then
            self.frozen:Release()
        end
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NpcshopWindow:__delete()
    self.OnHideEvent:Fire()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.boxXLayout ~= nil then
        self.boxXLayout:DeleteMe()
        self.boxXLayout = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.frozen ~= nil then
        self.frozen:DeleteMe()
        self.frozen = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v.iconLoader ~= nil then
                v.iconLoader:DeleteMe()
            end
        end
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
    self.needList = nil
    self.needPetList = nil
end

function NpcshopWindow:InitPanel()
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.npc_shop_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = "NpcshopWindow"

    local t = self.gameObject.transform
    local main = t:Find("Main")
    self.titleText = main:Find("Title/Text"):GetComponent(Text)
    if self.openArgs[1] == 1 then
        self.datalist = model.medicineData
        self.titleText.text = TI18N("药品商店")
    elseif self.openArgs[1] == 3 then
        self.datalist = model.contestmedicineData
        self.titleText.text = TI18N("擂台药店")
    else
        self.datalist = model.eqmData
        self.titleText.text = TI18N("装备商店")
    end
    model.openArgs = self.openArgs
    self.datalist = model:GetDataList()

    self.pageNum = math.ceil(#self.datalist / 8)

    local panel = main:Find("ItemPanel")
    self.container = panel:Find("GridPanel/Container")
    self.pageTemplate = self.container:Find("ItemPage").gameObject
    self.pageTemplate:SetActive(false)

    local rect = self.container:GetComponent(RectTransform)
    -- self.pageNum = 5
    local w = self.pageTemplate:GetComponent(RectTransform).sizeDelta.x
    rect.sizeDelta = Vector2(w * self.pageNum, rect.sizeDelta.y)
    rect.anchoredPosition = Vector2(0, 0)

    self.baseToggle = panel:Find("ToggleGroup/Toggle").gameObject
    self.ToggleCon = panel:Find("ToggleGroup")
    self.ToggleList = {}
    self.ToggleList[1] = self.baseToggle.transform:GetComponent(Toggle)

    self.tabbedPanel = TabbedPanel.New(panel:Find("GridPanel").gameObject, self.pageNum, w)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)

    for i=1,self.pageNum do
        self.pageInit[i] = false
    end

    for i=2, self.pageNum do
        local go = GameObject.Instantiate(self.baseToggle)
        go.transform:SetParent(self.ToggleCon)
        go.transform.localScale = Vector3.one
        local com = go.transform:GetComponent(Toggle)
        com.isOn = false
        self.ToggleList[i] = com
    end

    if self.boxXLayout == nil then
        local setting = {
            axis = BoxLayoutAxis.X
            ,spacing = 10
        }
        self.boxXLayout = LuaBoxLayout.New(self.container, setting)
    end

    for i=1,self.pageNum do
        self.pageObjList[i] = GameObject.Instantiate(self.pageTemplate)
        self.pageObjList[i].name = tostring(i)
        self.boxXLayout:AddCell(self.pageObjList[i])
        self.pageObjList[i].transform.localScale = Vector3.one
    end

    -- 信息面板
    local infoPanel = main:Find("InfoPanel")

    -- 选中物品的信息
    local itemInfoPanel = infoPanel:Find("ItemInfo")
    self.itemInfoArea = itemInfoPanel.gameObject
    self.nameText = infoPanel:Find("NameBg/Name"):GetComponent(Text)
    self.descText = itemInfoPanel:Find("DescText"):GetComponent(Text)

    -- 购买数目
    local numObj = infoPanel:Find("NumObject")
    self.numText = numObj:Find("NumBg/Value"):GetComponent(Text)
    local numpadBtn = self.numText.transform.parent:GetComponent(Button)
    local plusBtn = numObj:Find("PlusButton"):GetComponent(CustomButton)
    local minusBtn = numObj:Find("MinusButton"):GetComponent(CustomButton)

    self.updatePrice = function(result)
        if self.selectUniprice ~= nil and result ~= nil then
            self.priceText.text = tostring(result * self.selectUniprice)
            local myAssets = tonumber(self.ownText.text)
            if myAssets <= result * self.selectUniprice and self.priceText ~= nil then
                self.priceText.text = ColorHelper.Fill(ColorHelper.color[6], self.priceText.text)
            end
        end
    end

    -- 弹出数字键盘
    numpadBtn.onClick:AddListener(function ()
        local info = {parent_obj = self.gameObject, gameObject = numpadBtn.gameObject, max_result = self.maxNum, min_result = self.minNum, max_by_asset = 10 , textObject = self.numText, show_num = false, funcReturn = function() self:ClickBuyButton() end, callback = function(num) self.num = num self.updatePrice(num) end}
        NumberpadManager.Instance:set_data(info)
        NumberpadManager.Instance:OpenWindow()
    end)
    plusBtn.onClick:AddListener(function () self:PlusMinusClick(1) end)
    plusBtn.onHold:AddListener(function () self.plusTimerId = LuaTimer.Add(0, 100, function() self:PlusMinusClick(1) end) end)
    plusBtn.onUp:AddListener(function () if self.plusTimerId ~= nil then LuaTimer.Delete(self.plusTimerId) end end)

    minusBtn.onClick:AddListener(function () self:PlusMinusClick(2) end)
    minusBtn.onHold:AddListener(function () self.minusTimerId = LuaTimer.Add(0, 100, function() self:PlusMinusClick(2) end) end)
    minusBtn.onUp:AddListener(function () if self.minusTimerId ~= nil then LuaTimer.Delete(self.minusTimerId) end end)

    -- 价格
    local priceObj = infoPanel:Find("PriceObject")
    self.priceText = priceObj:Find("PriceBg/Value"):GetComponent(Text)
    self.priceCurrencyImage = priceObj:Find("Currency"):GetComponent(Image)

    -- 个人资产
    local ownObj = infoPanel:Find("OwnObject")
    self.ownText = ownObj:Find("OwnBg/Value"):GetComponent(Text)
    self.ownCurrencyImage = ownObj:Find("Currency"):GetComponent(Image)
    self.ownText.text = tostring(RoleManager.Instance.RoleData.coin)

    self.buybutton = infoPanel:Find("BuyButton"):GetComponent(Button)
    self.frozen = FrozenButton.New(self.buybutton.gameObject, {})
    self.buybutton.onClick:AddListener(function() self:ClickBuyButton() end)

    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function ()
        WindowManager.Instance:CloseWindow(self, false)
    end)

    self.autoClose = false
    self:GetNeedList()

    self:InitDataPanel(1)
    if self.pageNum > 1 then
        self:InitDataPanel(2)
    end

    local baseid = nil
    for i=1,#self.datalist do
        if self.needList[self.datalist[i].base_id] ~= nil then
            baseid = self.datalist[i].base_id
            break
        end
    end

    if baseid == nil then
        self:SelectItem(1)
    else
        self:SelectItem(self:BaseidToIndex(baseid))
    end
    -- self:UpdateInfoPanel(self.datalist[1])

    t:Find("Main/InfoPanel/NoticeText").gameObject:SetActive(false)
end

function NpcshopWindow:SetItem(data, index)
    self.itemList[index] = self.itemList[index] or {}
    local obj = self.itemObjList[index]
    local btn = obj:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function ()
        print("----------------Player Operation-----------------")
        if AutoQuestManager.Instance.model.isOpen then -- 玩家手动操作则取消自动历练 by 嘉俊 2017/9/1
            AutoQuestManager.Instance.disabledAutoQuest:Fire()
        end
        self:SelectItem(tonumber(obj.name))
    end)

    self.initCount = self.initCount + 1

    obj:SetActive(true)

    local t = obj.transform
    local nameText = t:Find("NameText"):GetComponent(Text)
    local selectObj = t:Find("Select").gameObject
    local priceText = t:Find("PriceBg/Value"):GetComponent(Text)
    local currencyImage = t:Find("CurrencyImage"):GetComponent(Image)
    local tipsObj = t:Find("TipsImage").gameObject
    if self.itemList[index].iconLoader == nil then
        self.itemList[index].iconLoader = SingleIconLoader.New(t:Find("Icon/Image").gameObject)
    end

    local basedata = DataItem.data_get[data.base_id]

    nameText.text = basedata.name
    priceText.text = tostring(data.price)
    self.itemList[index].iconLoader:SetSprite(SingleIconType.Item, basedata.icon)

    if self.needList[data.base_id] ~= nil and self.needInBackpack[data.base_id] < self.needList[data.base_id] then
        tipsObj:SetActive(true)

        if RoleManager.Instance.RoleData.lev <= 20 then
            if self.effect == nil then
                self.effect = BibleRewardPanel.ShowEffect(20053, self.gameObject.transform:Find("Main/InfoPanel/BuyButton"),Vector3(1.65,0.7,1), Vector3(-53,-15.4,-100))
            end
        end
    else
        tipsObj:SetActive(false)
    end
end

function NpcshopWindow:UpdateInfoPanel(data)
    local basedata = DataItem.data_get[data.base_id]

    self.selectUniprice = data.price

    self.nameText.text = basedata.name
    self.priceText.text = tostring(data.price)

    local ddesc = basedata.desc

    if data.step ~= nil and data.step ~= 0 then
        self.otherTxt.text = string.format(TI18N("品阶:%s"), info.step)
        local step_data = DataSkillLife.data_fight_effect[string.format("%s_%s", info.base_id, info.step)]
        if step_data ~= nil then
            ddesc = string.gsub(ddesc, "%[skill_life1%]", tostring(step_data.args[1]))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", tostring(step_data.args[2]))
        else
            ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
        end
    else
        -- self.otherTxt.text = ""
        ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
        ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
    end
    local ddesc2 = string.gsub(ddesc, "<.->", "")
    self.descText.text = ddesc2
end

function NpcshopWindow:RoleAssetsListener()
    if self.gameObject ~= nil then
        self.ownText.text = tostring(RoleManager.Instance.RoleData.coin)
    end
end

function NpcshopWindow:ClickBuyButton()
    local num = self.num or 1
    if num > 0 then
        if self.frozen ~= nil then
            self.frozen:OnClick()
        end
        NpcshopManager.Instance:send11400(self.model.openArgs[1], self.datalist[self.selectItem].base_id, num)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请输入购买数目"))
    end
end

function NpcshopWindow:OnMoveEnd(currentPage, direction)
    if direction == LuaDirection.Left then
        if currentPage < self.pageNum then
            if self.pageInit[currentPage + 1] == false then
                self:InitDataPanel(currentPage + 1)
            end
        end
    end
    for i=1, self.pageNum do
        self.ToggleList[i].isOn = currentPage == i
    end
end

function NpcshopWindow:InitDataPanel(currentPage)
    local num = 0
    local size = #self.datalist
    if currentPage == self.pageNum then
        num = (size - 1) % 8 + 1
    else
        num = 8
    end

    local t = self.pageObjList[currentPage].transform
    for i=1,8 do
        t:Find(tostring(i)).gameObject:SetActive(false)
    end

    local beginIndex = (currentPage - 1) * 8 + 1
    for i=beginIndex, beginIndex + num - 1 do
        self.itemObjList[i] = t:Find(tostring((i - 1) % 8 + 1)).gameObject
        self.itemObjList[i].name = tostring(i)
        self:SetItem(self.datalist[i], i)
    end

    self.pageInit[currentPage] = true
end

function NpcshopWindow:SelectItem(index)
    local selectObj = nil
    if self.selectItem ~= nil then
        selectObj = self.itemObjList[self.selectItem].transform:Find("Select").gameObject
        selectObj:SetActive(false)
    end

    if index ~= self.selectItem then
        self.num = 1
        self.numText.text = tostring(self.num)
        self.selectItem = index
        local data = self.datalist[index]
        self.maxNum = math.floor(RoleManager.Instance.RoleData.coin / data.price)
        self.maxNum = 10
        selectObj = self.itemObjList[self.selectItem].transform:Find("Select").gameObject

        self:UpdateInfoPanel(data)
    else
        self:PlusMinusClick(1)
    end
    selectObj:SetActive(true)
end

function NpcshopWindow:PlusMinusClick(flag)
    self.num = self.num or 1
    if flag == 1 then
        if self.num < self.maxNum then
            self.num = self.num + 1
        end
    else
        if self.num > self.minNum then
            self.num = self.num - 1
        end
    end
    self.numText.text = tostring(self.num)
    self.updatePrice(self.num)
end

function NpcshopWindow:GetNeedList()
    local needList = QuestManager.Instance:GetItemTarget()
    self.needList = {}
    if needList ~= nil then
        for _,v in pairs(needList) do
            if v.type ~= 2 then
                if self.needList[v.id] == nil then
                    self.needList[v.id] = v.num
                else
                    self.needList[v.id] = self.needList[v.id] + v.num
                end
            else
            end
        end
    end

    needList = ShippingManager.Instance.shipping_need

    if needList ~= nil then
        for _,v in pairs(needList) do
            if v.type ~= 2 then
                if self.needList[v.id] == nil then
                    self.needList[v.id] = v.num
                else
                    self.needList[v.id] = self.needList[v.id] + v.num
                end
            else
            end
        end
    end

    self.needInBackpack = {}
    for k,_ in pairs(self.needList) do
        self.needInBackpack[k] = BackpackManager.Instance:GetItemCount(k)
    end

    -- BaseUtils.dump(self.needList, "需求列表")
    -- BaseUtils.dump(self.needInBackpack, "需求在背包中的数量")

    for k,v in pairs(self.datalist) do
        if self.needList[v.base_id] ~= nil and self.needInBackpack[v.base_id] ~= nil and self.needList[v.base_id] > self.needInBackpack[v.base_id] then
            self.autoClose = true
            break
        end
    end

end

function NpcshopWindow:BaseidToIndex(base_id)
    local datalist = self.datalist
    if datalist ~= nil then
        for k,v in pairs(datalist) do
            if v.base_id == base_id then
                return k
            end
        end
    end
    return 1
end

function NpcshopWindow:OnOpen()
    if gm_cmd.auto2 then
        LuaTimer.Add(300, function()
            self:ClickBuyButton()
        end)
    end


    -- inserted by 嘉俊 自动历练，自动职业任务
    if AutoQuestManager.Instance.model.isOpen then
        if BackpackManager.Instance:GetCurrentGirdNum() <= 0  then -- 对背包是否已满进行检测，若满则停止自动历练/职业任务
            NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，无法购买"))
            print("背包已满导致自动停止")
            AutoQuestManager.Instance.disabledAutoQuest:Fire()
            return
        end
        AutoQuestManager.Instance.model.timerForNpcShopWindow =  LuaTimer.Add(300, function()
            self:ClickBuyButton()
        end)

    end
    -- end by 嘉俊
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.listener)
end

function NpcshopWindow:OnHide()
    -- inserted by 嘉俊 摘除自动购买NPC商店物品的定时器
    if AutoQuestManager.Instance.model.timerForNpcShopWindow ~= nil then
        LuaTimer.Delete(AutoQuestManager.Instance.model.timerForNpcShopWindow)
        AutoQuestManager.Instance.model.timerForNpcShopWindow = nil
    end
    self:RemoveListeners()
    NumberpadManager.Instance:Close()
end

function NpcshopWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.listener)
end

function NpcshopWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end
