ShopRechargeReturnItem = ShopRechargeReturnItem or BaseClass()

function ShopRechargeReturnItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    local t = gameObject.transform

    self.rect = gameObject:GetComponent(RectTransform)
    self.btn = t:Find("Button"):GetComponent(Button)
    self.goldText = t:Find("Left/Gold"):GetComponent(Text)
    self.curText = t:Find("Slider/ProgressTxt"):GetComponent(Text)
    self.hadGetObj = t:Find("Text").gameObject
    self.container = t:Find("ScrollRect/ImageContainer")
    self.containerTr = self.container:GetComponent(RectTransform)

    self.scrollRectTr = t:Find("ScrollRect"):GetComponent(RectTransform)

    self.imagesList = {
        self.container:Find("Image1"):GetComponent(Image)
        , self.container:Find("Image2"):GetComponent(Image)
        , self.container:Find("Image3"):GetComponent(Image)
        , self.container:Find("Image4"):GetComponent(Image)
        , self.container:Find("Image5"):GetComponent(Image)
        , self.container:Find("Image6"):GetComponent(Image)
        , self.container:Find("Image7"):GetComponent(Image)
    }
    self.slider = t:Find("Slider"):GetComponent(Slider)
    self.slotList = {}
    self.slotData = {}
end

function ShopRechargeReturnItem:__delete()
    if self.slotList ~= nil then
        for k,v in pairs(self.slotList) do
            if v ~= nil then
                v:DeleteMe()
                self.slotList[k] = nil
                v = nil
            end
        end
        self.slotList = nil
    end
    if self.slotData ~= nil then
        for k,v in pairs(self.slotData) do
            if v ~= nil then
                v:DeleteMe()
                self.slotData[k] = nil
                v = nil
            end
        end
        self.slotData = nil
    end
    if self.specialSlot ~= nil then
        self.specialSlot:DeleteMe()
        self.specialSlot = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
end

function ShopRechargeReturnItem:SetData(data, index, isFirst)
    self.goldText.text = tostring(data.min)

    local newData = {}
    for i,v in ipairs(data.item) do
        if v[4] == RoleManager.Instance.RoleData.classes or v[4] == 0 then
            table.insert(newData,v)
        end
    end

    for i=1,7 do
        local img = self.imagesList[i]
        local rewardTemp = newData[i]
        local newData = {}

        if rewardTemp ~= nil then
            img.gameObject:SetActive(true)

            if self.slotList[i] == nil then
                self.slotList[i] = ItemSlot.New()
                self.slotData[i] = ItemData.New()
            end
            local cell = DataItem.data_get[rewardTemp[1]]
            self.slotData[i]:SetBase(cell)
            self.slotList[i]:SetAll(self.slotData[i], {inbag = false, nobutton = true})
            NumberpadPanel.AddUIChild(img.gameObject, self.slotList[i].gameObject)
            self.slotList[i]:SetNum(rewardTemp[3])
            self.slotList[i].gameObject:SetActive(true)
        else
            img.gameObject:SetActive(false)
        end
    end

    local length = 0
    if data.title ~= "" then
        length = #newData + 1
    else
        length = #newData
    end

    self.containerTr.sizeDelta = Vector2(length * 74,64)
    if length > 5 then
        length = 5
    end
    self.scrollRectTr.sizeDelta = Vector2(length * 74,64)


    if DataPrivilege.data_section[data.lev].title == "" then
        if self.specialSlot ~= nil then
            self.specialSlot:DeleteMe()
            self.specialSlot = nil
        end
        self.imagesList[#newData + 1].gameObject:SetActive(false)
    else
        if self.slotList[#newData + 1] ~= nil then
            self.slotList[#newData + 1].gameObject:SetActive(false)
        end
        self.imagesList[#newData + 1].gameObject:SetActive(true)
        if self.specialSlot == nil then
            self.specialSlot = ItemSlot.New()
        end
        NumberpadPanel.AddUIChild(self.imagesList[#newData + 1].gameObject, self.specialSlot.gameObject)
        self.specialSlot:SetItemSprite(self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Privilege"))
        self.specialSlot.itemImgRect.sizeDelta = Vector2(56, 56)

        local itemData = {}
        for i,v in ipairs(DataPrivilege.data_section[data.lev].attrs) do
            table.insert(itemData, string.format(v.val, tostring(DataPrivilege.data_exp[RoleManager.Instance.RoleData.lev].exp)))
        end
        self.specialSlot.button.onClick:RemoveAllListeners()
        self.specialSlot.button.onClick:AddListener(function() self:ShowTips({gameObject = self.specialSlot, itemData = itemData}) end)
    end

    local privilegeMgr = PrivilegeManager.Instance
    local state = privilegeMgr:GetPrivilegeState(data.lev)

    if data.state == 1 then          -- 未完成
        self.btn.gameObject:SetActive(false)
        self.hadGetObj:SetActive(false)
        self.slider.gameObject:SetActive(true)
        self.curText.text = string.format("%d/%d", tostring(privilegeMgr.charge), tostring(data.min))
        -- if data.activeNum <= receivable then
        --     self.curText.text = string.format("%d/%d", tostring(privilegeMgr.charge), tostring(data.min))
        -- else
        --     self.goldText.text = "???"
        --     self.curText.text = string.format("%d/???", tostring(privilegeMgr.charge))
        -- end
        self.slider.value = privilegeMgr.charge / data.min
    elseif data.state == 2 then      -- 可领取
        self.btn.gameObject:SetActive(true)
        self.hadGetObj:SetActive(false)
        self.slider.gameObject:SetActive(false)
        if self.effect ~= nil then
            self.effect:DeleteMe()
        end
        if isFirst == true then
            self.effect = BibleRewardPanel.ShowEffect(20118, self.btn.transform, Vector3(1, 1, 1), Vector3(-50, 28, -400))
        end
        self.btn.onClick:RemoveAllListeners()
        self.btn.onClick:AddListener(function() self:OnReceive(data.lev) end)
    elseif data.state == 3 then      -- 已领取
        self.btn.gameObject:SetActive(false)
        self.hadGetObj:SetActive(true)
        self.slider.gameObject:SetActive(false)
    end

    self:SetActive(true)
end

function ShopRechargeReturnItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function ShopRechargeReturnItem:OnReceive(index)
    PrivilegeManager.Instance:send9926(index)
end

function ShopRechargeReturnItem:ShowTips(itemdata)
    TipsManager.Instance:ShowText(itemdata)
end

