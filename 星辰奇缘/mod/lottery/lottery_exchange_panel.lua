-- 2016/8/29
-- zzl
-- 一元夺宝兑换panel
LotteryExchangePanel = LotteryExchangePanel or BaseClass(BasePanel)

function LotteryExchangePanel:__init(parent)
    self.model = parent.model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.lottery_exchange, type = AssetType.Main}
    }

    self.itemList = {}
    self.panelList = {}
    self.toggleList = {}
    self.gridLayoutList = {}
    self.hasInitPage = {}
    self.perPageItemNum = 8 --每一页有多少个item

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

    self.updatePanelListener = function()
        if self.hasInit == false then
            return
        end
        self:OnUpdatePanel()
    end

    self.resetItemListener = function()
        if self.hasInit == false then
            return
        end
        self:ResetItemData()
    end

    self.assetListener = function()
        if self.hasInit == false then
            return
        end
        local temp =  tonumber(self.TxtNum.text)
        local total = self.selectedItem.data.price*temp
        if total > RoleManager.Instance.RoleData.lottery_luck then
            if BaseUtils.is_null(self.TxtValue1) == false then
                self.TxtValue1.text = string.format("<color='#df3435'>%s</color>", total)
            end
        else
            if BaseUtils.is_null(self.TxtValue1) == false then
                self.TxtValue1.text = string.format("<color='#2fc823'>%s</color>", total)
            end
        end
        if BaseUtils.is_null(self.TxtValue2) == false then
            self.TxtValue2.text = tostring(RoleManager.Instance.RoleData.lottery_luck)
        end
        self:ResetItemData()
    end
    self.hasInit = false
end

function LotteryExchangePanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
    ShopManager.Instance.onUpdateBuyPanel:RemoveListener(self.updatePanelListener)
    ShopManager.Instance.onUpdateBuyPanel:RemoveListener(self.resetItemListener)

    self.numberpadSetting.textObject = nil
    self.numberpadSetting = nil
    self.hasInit = false
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gridLayoutList ~= nil then
        for k,v in pairs(self.gridLayoutList) do
            if v ~= nil then
                v:DeleteMe()
                self.gridLayoutList[k] = nil
                v = nil
            end
        end
    end
    if self.itemList ~= nil then
        for k,v in pairs(self.itemList) do
            if v ~= nil then
                self.itemList[k]:Release()
                self.itemList[k]:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.toggleLayout ~= nil then
        self.toggleLayout:DeleteMe()
        self.toggleLayout = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function LotteryExchangePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.lottery_exchange))
    self.gameObject.name = "SelectPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.main.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, -10, 0)

    --左边
    self.Left = self.transform:Find("Left")
    self.LeftImgIcon = self.Left:Find("ImgIcon"):GetComponent(Image)
    self.goodsPanel = self.Left:Find("GoodsPanel")
    self.itemPanelCloner = self.goodsPanel:Find("ItemPage").gameObject
    self.itemCloner = self.goodsPanel:Find("ItemPage/Item").gameObject
    self.panelContainer = self.goodsPanel:Find("Panel/Container")
    self.panelScrollRect = self.goodsPanel:Find("Panel"):GetComponent(ScrollRect)
    self.panelRect = self.goodsPanel:Find("Panel"):GetComponent(RectTransform)
    self.pageRect = self.itemPanelCloner:GetComponent(RectTransform)
    self.toggleContainer = self.Left:Find("ToggleGroup")
    self.toggleCloner = self.toggleContainer:Find("Toggle").gameObject
    self.itemCloner:SetActive(false)
    self.toggleCloner:SetActive(false)
    self.itemPanelCloner:SetActive(false)

    --右边
    self.Right = self.transform:Find("Right")
    self.TxtTitle=self.Right.transform:FindChild("TopCon"):FindChild("ImgTitle"):FindChild("TxtTitle"):GetComponent(Text)
    self.TxtLimit = self.Right.transform:FindChild("TopCon"):FindChild("TxtLimit"):GetComponent(Text)
    self.TxtDesc_go=self.Right.transform:FindChild("TopCon"):FindChild("TxtDesc"):GetComponent(Text)
    self.TxtDesc = MsgItemExt.New(self.TxtDesc_go, 220, 18, 23)
    self.BtnMinus=self.Right.transform:FindChild("BottomCon"):FindChild("ItemCon0"):FindChild("BtnMinus"):GetComponent(Button)

    self.countBtn = self.Right.transform:FindChild("BottomCon"):FindChild("ItemCon0"):Find("CountBtn"):GetComponent(Button)
    self.TxtNum = self.Right.transform:FindChild("BottomCon"):FindChild("ItemCon0"):Find("TxtNum"):GetComponent(Text)

    self.BtnPlus=self.Right.transform:FindChild("BottomCon"):FindChild("ItemCon0"):FindChild("BtnPlus"):GetComponent(Button)
    self.TxtValue1=self.Right.transform:FindChild("BottomCon"):FindChild("ItemCon1"):FindChild("TxtValue"):GetComponent(Text)
    self.ImgIcon1=self.Right.transform:FindChild("BottomCon"):FindChild("ItemCon1"):FindChild("ImgIcon"):GetComponent(Image)
    self.TxtValue2=self.Right.transform:FindChild("BottomCon"):FindChild("ItemCon2"):FindChild("TxtValue"):GetComponent(Text)
    self.ImgIcon2=self.Right.transform:FindChild("BottomCon"):FindChild("ItemCon2"):FindChild("ImgIcon"):GetComponent(Image)
    self.BtnExchange=self.Right.transform:FindChild("BottomCon"):FindChild("BtnExchange"):GetComponent(Button)


    self.LeftImgIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90022")
    self.updatePrice = function()
        local selectNum = NumberpadManager.Instance:GetResult()
        local total = self.selectedItem.data.price*selectNum
        if total > RoleManager.Instance.RoleData.lottery_luck then
            self.TxtValue1.text = string.format("<color='#df3435'>%s</color>", total)
        else
            self.TxtValue1.text = string.format("<color='#2fc823'>%s</color>", total)
        end
    end
    self.max_result = 100
    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.countBtn.gameObject,
        min_result = 1,
        max_by_asset = self.max_result,
        max_result = self.max_result,
        textObject = self.TxtNum,
        show_num = false,
        funcReturn = function() NoticeManager.Instance:FloatTipsByString(TI18N("请确认购买")) end,
        callback = self.updatePrice
    }
    self.countBtn.onClick:AddListener(function() self:OnNumberpad() end)

    self.BtnMinus.onClick:AddListener(function() self:OnClickBtn(1) end)
    self.BtnPlus.onClick:AddListener(function() self:OnClickBtn(2) end)
    self.BtnExchange.onClick:AddListener(function() self:OnClickBtn(3) end)
    self.hasInit = true
end

function LotteryExchangePanel:ReloadItemPanel()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end

    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.panelContainer, {axis = BoxLayoutAxis.X, cspacing = 4})
        self.toggleLayout = LuaBoxLayout.New(self.toggleContainer, {axis = BoxLayoutAxis.X})
    else
        self.layout:ReSet()
        self.toggleLayout:ReSet()
    end


    local dataList = self.model:GetExchangeList()
    self.pageNum = math.ceil(#dataList/self.perPageItemNum) --self.model.pageNum[self.main][self.sub]
    if self.pageNum == nil then self.pageNum = 0 end
    for i=1,self.pageNum do
        if self.panelList[i] == nil then
            self.panelList[i] = GameObject.Instantiate(self.itemPanelCloner)
            self.panelList[i].name = tostring(i)
            self.toggleList[i] = GameObject.Instantiate(self.toggleCloner)
            self.toggleList[i].name = tostring(i)
            self.toggleList[i] = self.toggleList[i]:GetComponent(Toggle)
            self.toggleList[i].interactable = false
        end
        self.layout:AddCell(self.panelList[i])
        self.toggleLayout:AddCell(self.toggleList[i].gameObject)
        self.toggleList[i].isOn = false
    end
    for i=self.pageNum + 1, #self.panelList do
        self.panelList[i]:SetActive(false)
        self.toggleList[i].gameObject:SetActive(false)
    end
    if self.tabbedPanel == nil then
        self.tabbedPanel = TabbedPanel.New(self.panelScrollRect.gameObject, self.pageNum, self.pageRect.sizeDelta.x)
    else
        self.tabbedPanel:SetPageCount(self.pageNum)
    end
    if self.toggleList[1] ~= nil then
        self.toggleList[1].isOn = true
    end
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)
end

function LotteryExchangePanel:InitDataPanel(index)
    local model = self.model
    if self.gridLayoutList[index] ~= nil then
        self.gridLayoutList[index]:DeleteMe()
    end
    self.datalist = self.model:GetExchangeList() --self.model.datalist[self.main][self.sub]
    if self.datalist == nil then self.datalist = {} end
    self.gridLayoutList[index] = LuaGridLayout.New(self.panelList[index], {column = 2, cellSizeX = 239, cellSizeY = 87, cspacing = 4})
    local obj = nil
    for i=1,self.perPageItemNum do
        if self.itemList[(index - 1) * self.perPageItemNum + i] == nil then
            obj = GameObject.Instantiate(self.itemCloner)
            obj.name = tostring((index - 1) * self.perPageItemNum + i)
            self.itemList[(index - 1) * self.perPageItemNum + i] = LotteryExchangeItem.New(self, obj, index)
            self.gridLayoutList[index]:AddCell(obj)
        end
        if self.datalist[(index - 1) * self.perPageItemNum + i] ~= nil then
            local tempData = self.datalist[(index - 1) * self.perPageItemNum + i]
            self.itemList[(index - 1) * self.perPageItemNum + i]:SetData(tempData, (index - 1) * self.perPageItemNum + i)
        else
            self.itemList[(index - 1) * self.perPageItemNum + i].gameObject:SetActive(false)
        end
    end

    self.panelList[index].gameObject:SetActive(true)
end

--更新右边显示
function LotteryExchangePanel:UpdateRight(item)
    if self.selectedItem ~= nil then
        self.selectedItem:SetSelect(false)
    end
    self.selectedItem = item
    self.selectedItem:SetSelect(true)

    local baseData = DataItem.data_get[self.selectedItem.data.base_id]
    self.TxtDesc:SetData(baseData.desc)
    self.TxtNum.text = "1"
    self.TxtTitle.text = ColorHelper.color_item_name(baseData.quality,baseData.name)
    self.TxtValue2.text = tostring(RoleManager.Instance.RoleData.lottery_luck)

    if self.selectedItem.data.limit_role == -1 then
        self.TxtLimit.text = ""
    else
        self.TxtLimit.text = string.format("<color='#00ff00'> %s:%s%s</color>", TI18N("每日限兑"), self.selectedItem.data.limit_role, TI18N("个"))
    end

    if self.selectedItem.data.price > RoleManager.Instance.RoleData.lottery_luck then
        self.TxtValue1.text = string.format("<color='#df3435'>%s</color>", self.selectedItem.data.price)
    else
        self.TxtValue1.text = string.format("<color='#2fc823'>%s</color>", self.selectedItem.data.price)
    end
end

function LotteryExchangePanel:RemoveListeners()
    ShopManager.Instance.onUpdateBuyPanel:RemoveListener(self.updatePanelListener)
end

function LotteryExchangePanel:OnDragEnd(currentPage, direction)
    local model = self.model
    if direction == LuaDirection.Left then
        if currentPage > 1 then
            self.toggleList[currentPage - 1].isOn = false
        end
        self.toggleList[currentPage].isOn = true
    elseif direction == LuaDirection.Right then
        if currentPage < self.pageNum then
            self.toggleList[currentPage + 1].isOn = false
        end
        self.toggleList[currentPage].isOn = true
    end
end

function LotteryExchangePanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
    self:RemoveListeners()
end

--点击监听
function LotteryExchangePanel:OnClickBtn(index)
    if index == 1 then
        --减
        local temp =  tonumber(self.TxtNum.text)
        temp = temp - 1
        if temp<1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("最少兑换一个"))
            temp = 1
        end
        local total = self.selectedItem.data.price*temp
        if total > RoleManager.Instance.RoleData.lottery_luck then
            self.TxtValue1.text = string.format("<color='#df3435'>%s</color>", total)
        else
            self.TxtValue1.text = string.format("<color='#2fc823'>%s</color>", total)
        end
        self.TxtNum.text = tostring(temp)
    elseif index == 2 then
        --加
        local temp =  tonumber(self.TxtNum.text)
        temp = temp + 1
        local leftNum = 0
        --非共享
        local hasBuyNum = ShopManager.Instance.model.hasBuyList[self.selectedItem.data.id]
        if hasBuyNum == nil then
            hasBuyNum = 0
        end
        if self.selectedItem.data.limit_role ~= -1 then --有限购
            leftNum = self.selectedItem.data.limit_role - hasBuyNum
            if leftNum < 1 then
                leftNum = 1
            end
            if temp>leftNum then
                NoticeManager.Instance:FloatTipsByString(TI18N("不能兑换更多了"))
                temp = leftNum
            end
            if temp <= 0 then
                temp = 1
            end
        end
        self.TxtNum.text = tostring(temp)
        local total = self.selectedItem.data.price*temp
        if total > RoleManager.Instance.RoleData.lottery_luck then
            self.TxtValue1.text = string.format("<color='#df3435'>%s</color>", total)
        else
            self.TxtValue1.text = string.format("<color='#2fc823'>%s</color>", total)
        end
    elseif index == 3 then
        --兑换
        local temp =  tonumber(self.TxtNum.text)
        ShopManager.Instance:send11303(self.selectedItem.data.id, temp)
    end
end

function LotteryExchangePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function LotteryExchangePanel:OnOpen()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)
    ShopManager.Instance:send11302()
    ShopManager.Instance.onUpdateBuyPanel:AddListener(self.updatePanelListener)
    ShopManager.Instance.onUpdateBuyPanel:AddListener(self.resetItemListener)
end

function LotteryExchangePanel:OnUpdatePanel()
    self:ReloadItemPanel()
    for i=1,self.pageNum do
        self:InitDataPanel(i)
    end
    if self.pageNum > 0 then
        self.tabbedPanel:TurnPage(1)
        self.toggleList[1].isOn = true
    end
    self:RemoveListeners()
end

--重设数据
function LotteryExchangePanel:ResetItemData()
    for k,v in pairs(self.itemList) do
        if v.data ~= nil then
            v:SetData(v.data)
        end
    end
end

function LotteryExchangePanel:OnNumberpad()
    local max_result = self.max_result
    if self.selectedItem.data.limit_role == -1 then
        max_result = 100
    else
        max_result = self.selectedItem.data.limit_role
    end
    self.numberpadSetting.max_result = max_result
    self.numberpadSetting.max_by_asset = max_result
    NumberpadManager.Instance:set_data(self.numberpadSetting)
end