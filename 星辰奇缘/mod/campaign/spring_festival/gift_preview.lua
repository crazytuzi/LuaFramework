-- ---------------------------
-- 礼包预览
-- hosr
-- ---------------------------
GiftPreview = GiftPreview or BaseClass(BasePanel)

function GiftPreview:__init(parent, DataList, gettitle, showClose)
    self.parent = parent
    self.path = "prefabs/ui/springfestival/giftpreviewpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }
    self.data_list = DataList
    self.gettitle = gettitle
    self.showClose = showClose
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.titleWidth = 400

    self.hideCallback = nil         -- 隐藏回调

    self.slotTab = {}
    self.count = 0
    self.price = 0
    self.page = 1
end

function GiftPreview:__delete()
    if self.titleTxt ~= nil then
        self.titleTxt:DeleteMe()
        self.titleTxt = nil
    end
    for k,v in pairs(self.slotTab) do
        if v.slot ~= nil then
            v.slot:DeleteMe()
        end
    end
    if self.slotTab1 ~= nil then
        for k,v in pairs(self.slotTab1) do
            if v.slot ~= nil then
                v.slot:DeleteMe()
            end
        end
    end
    if self.titleTxt1 ~= nil then
        self.titleTxt1:DeleteMe()
        self.titleTxt1 = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function GiftPreview:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "GiftPreview"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.mainRect = self.transform:Find("Main"):GetComponent(RectTransform)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.baseSlot = self.transform:Find("Main/Item").gameObject
    self.baseSlot:SetActive(false)
    self.itemRect = self.baseSlot:GetComponent(RectTransform)
    self.titleObj = self.transform:Find("Main/Title").gameObject
    self.titleTxt = MsgItemExt.New(self.titleObj:GetComponent(Text), self.titleWidth or 400, 20, 23)
    self.titleRect = self.titleObj:GetComponent(RectTransform)
    self.container = self.transform:Find("Main/Container").gameObject
    self.containerTransform = self.container.transform
    self.containerRect = self.container:GetComponent(RectTransform)
    self.LButton = self.transform:Find("Main/LButton"):GetComponent(Button)
    self.RButton = self.transform:Find("Main/RButton"):GetComponent(Button)
    self.CloseButton = self.transform:Find("Main/Close"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self:Hiden() end)
    self.LButton.onClick:AddListener(function()
        self:TurnPage(self.page - 1)
    end)
    self.RButton.onClick:AddListener(function()
        self:TurnPage(self.page + 1)
    end)
    if self.data_list == nil then
        self.LButton.gameObject:SetActive(false)
        self.RButton.gameObject:SetActive(false)
    end
    self:OnShow()
end

function GiftPreview:OnShow()
    if self.openArgs ~= nil then
        self.width = self.openArgs.width or 160
        self.height = self.openArgs.height or 120

        self.itemRect.sizeDelta = Vector2(self.width, self.height)
        self.text = self.openArgs.text              -- 不传入价格就显示此文字
        self.price = self.openArgs.price            -- 等于nil表示不显示价格
        self.autoMain = self.openArgs.autoMain      -- 等于true表示对mainPanel进行自适应排布，否则按700×400固定大小
        self.column = self.openArgs.column or 4

        if self.openArgs.multi then                 -- 上下分层
            self.multi = true

            if self.titleObj1 == nil then
                self.titleObj1 = GameObject.Instantiate(self.titleObj)
                self.titleObj1.transform:SetParent(self.titleObj.transform.parent)
                self.titleObj1.transform.localScale = Vector3.one
                self.titleRect1 = self.titleObj1:GetComponent(RectTransform)
                self.titleTxt1 = MsgItemExt.New(self.titleObj1:GetComponent(Text), 400, 20, 23)
            end

            if self.container1 == nil then
                self.container1 = GameObject.Instantiate(self.container)
                self.container1.transform:SetParent(self.container.transform.parent)
                self.container1.transform.localScale = Vector3.one
                self.containerTransform1 = self.container1.transform
                self.containerRect1 = self.container1:GetComponent(RectTransform)
            end

            self.text1 = self.openArgs.text1
            self.itemTab = self.openArgs.reward
            self.itemTab1 = self.openArgs.reward1
            self:UpdateContent()
        else
            if self.openArgs.pageindex ~= nil then -- 传入pageindex 则走翻页流程
                self:TurnPage(self.openArgs.pageindex)
            else
                self.itemTab = self.openArgs.reward
                self:UpdateContent()
            end
        end
    end
end

function GiftPreview:OnHide()
    if self.hideCallback ~= nil then
        self.hideCallback()
        self.hideCallback = nil
    end
end

function GiftPreview:UpdateContent()
    if self.price ~= nil then
        self.titleTxt:SetData(string.format(TI18N("本礼包价值{assets_1,90002,%s}"), tostring(self.price)))
    elseif self.text ~= nil then
        self.titleTxt:SetData(self.text)
    else
        self.titleTxt:SetData("")
    end
    self.CloseButton.gameObject:SetActive(self.showClose == true)

    self.count = #self.itemTab
    for i,item in ipairs(self.itemTab) do
        local baseId = item[1]
        local num = item[2]
        local itemData = BaseUtils.copytab(DataItem.data_get[baseId])
        if itemData ~= nil then
            local slotItem = self.slotTab[i]
            if slotItem == nil then
                slotItem = {}
                local obj = GameObject.Instantiate(self.baseSlot)
                slotItem.gameObject = obj
                slotItem.transform = obj.transform
                slotItem.rect = obj:GetComponent(RectTransform)
                slotItem.slot = ItemSlot.New(obj.transform:Find("ItemSlot").gameObject)
                slotItem.label = obj.transform:Find("Text"):GetComponent(Text)
                slotItem.rare = obj.transform:Find("ItemSlot/Rare").gameObject
                obj.transform:SetParent(self.containerTransform)
                obj.transform.localScale = Vector3.one
                table.insert(self.slotTab, slotItem)
            end
            -- itemData.quantity = num
            local format = ItemData.New()
            format:SetBase(itemData)
            slotItem.slot:SetAll(format, {nobutton = true, inbag = false})
            slotItem.slot:SetNum(num)
            slotItem.slot.numBgRect.sizeDelta = Vector2(slotItem.slot.numBgRect.sizeDelta.x + 4, 23)
            slotItem.label.text = ColorHelper.color_item_name(format.quality, BaseUtils.string_cut_utf8(format.name, 5, 4))
            slotItem.rare:SetActive(item[3] == 1)
        end
    end

    if self.multi then
        if self.text1 ~= nil then
            self.titleTxt1:SetData(self.text1)
        else
            self.titleTxt1:SetData("")
        end

        self.count1 = #self.itemTab1
        self.slotTab1 = {}
        for i,item in ipairs(self.itemTab1) do
            local baseId = item[1]
            local num = item[2]
            local itemData = BaseUtils.copytab(DataItem.data_get[baseId])
            if itemData ~= nil then
                local slotItem = self.slotTab1[i]
                if slotItem == nil then
                    slotItem = {}
                    local obj = GameObject.Instantiate(self.baseSlot)
                    slotItem.gameObject = obj
                    slotItem.transform = obj.transform
                    slotItem.rect = obj:GetComponent(RectTransform)
                    slotItem.slot = ItemSlot.New(obj.transform:Find("ItemSlot").gameObject)
                    slotItem.label = obj.transform:Find("Text"):GetComponent(Text)
                    obj.transform:SetParent(self.containerTransform1)
                    obj.transform.localScale = Vector3.one
                    table.insert(self.slotTab1, slotItem)
                end
                -- itemData.quantity = num
                local format = ItemData.New()
                format:SetBase(itemData)
                slotItem.slot:SetAll(format, {nobutton = true, inbag = false})
                slotItem.slot:SetNum(num)
                slotItem.label.text = ColorHelper.color_item_name(format.quality, BaseUtils.string_cut_utf8(format.name, 5, 4))
            end
        end
    end

    self:Layout()
end

function GiftPreview:Layout()
    local offsetY = -35
    self.titleRect.anchoredPosition = Vector2(-self.titleTxt.contentRect.sizeDelta.x / 2, offsetY)
    for i,slot in ipairs(self.slotTab) do
        if i > self.count then
            slot.gameObject:SetActive(false)
        else
            slot.gameObject:SetActive(true)
            local x = self.width * ((i - 1) % self.column)
            local line = math.floor((i - 1) / self.column)
            local y = - self.height * line
            slot.rect.anchoredPosition = Vector2(x, y)
        end
    end

    local cc = math.min(self.count, self.column)
    local width = self.width * cc
    local height = self.height * math.ceil(self.count / self.column)
    offsetY = offsetY - self.titleRect.sizeDelta.y - 20
    self.containerRect.sizeDelta = Vector2(width, height)

    if self.multi then
        offsetY = offsetY - self.containerRect.sizeDelta.y - 20
        self.titleRect1.anchoredPosition = Vector2(-self.titleTxt1.contentRect.sizeDelta.x / 2, offsetY)
        for i,slot in ipairs(self.slotTab1) do
            if i > self.count1 then
                slot.gameObject:SetActive(false)
            else
                slot.gameObject:SetActive(true)
                local x = self.width * ((i - 1) % self.column)
                local line = math.floor((i - 1) / self.column)
                local y = - self.height * line
                slot.rect.anchoredPosition = Vector2(x, y)
            end
        end

        cc = math.max(cc, math.min(self.count1, self.column))
        width = self.width * cc
        local heightTemp = self.height * math.ceil(self.count1 / self.column)
        height = height + heightTemp + 30

        offsetY = offsetY - self.titleRect1.sizeDelta.y - 20
        self.containerRect1.sizeDelta = Vector2(width, heightTemp)
        self.containerRect1.anchoredPosition = Vector2(20, offsetY)
    end

    local allWidth = 700
    local allHeight = 400

    if self.autoMain == true then
        allWidth = math.max(width + 40, 400)
        allHeight = math.max(height + 120, 230)
    end
    self.mainRect.sizeDelta = Vector2(allWidth, allHeight)
    self.mainRect.anchoredPosition = Vector2.zero

    self.containerRect.anchoredPosition = Vector2(self.mainRect.sizeDelta.x / 2 - width / 2 , offsetY)
end

function GiftPreview:TurnPage(index)
    if self.data_list ~= nil and next(self.data_list) ~= nil and index <= #self.data_list then
        if self.gettitle ~= nil then
            self.text = self.gettitle(index)
        end
        self.page = index
        self.itemTab = self.data_list[index]
        self.LButton.gameObject:SetActive(index ~= 1)
        self.RButton.gameObject:SetActive(index ~= #self.data_list)
        self:UpdateContent()
    end
end
