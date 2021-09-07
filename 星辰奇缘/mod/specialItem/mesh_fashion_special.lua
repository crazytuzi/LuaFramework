-- @author 黄耀聪
-- @date 2017年8月8日, 星期二

MeshFashionSpecial = MeshFashionSpecial or BaseClass(BaseWindow)

function MeshFashionSpecial:__init(model)
    self.model = model
    self.name = "MeshFashionSpecial"
    self.windowId = WindowConfig.WinID.mesh_fashion_special

    self.resList = {
        {file = AssetConfig.mesh_fashion_special, type = AssetType.Main}
        , {file = AssetConfig.mesh_fashion_buybg, type = AssetType.Main}
        , {file = AssetConfig.specialitem_texture, type = AssetType.Dep}
    }

    self.digitList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MeshFashionSpecial:__delete()
    self.OnHideEvent:Fire()
    if self.confirmData ~= nil then
        self.confirmData:DeleteMe()
        self.confirmData = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.assetLoader ~= nil then
        self.assetLoader:DeleteMe()
        self.assetLoader = nil
    end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    self:AssetClearAll()
end

function MeshFashionSpecial:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mesh_fashion_special))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")

    self.layout = LuaBoxLayout.New(main:Find("Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})
    self.assetLoader = SingleIconLoader.New(main:Find("Container/Assets").gameObject)
    self.digitCloner = main:Find("Container/Digit").gameObject

    self.slot = ItemSlot.New()
    NumberpadPanel.AddUIChild(main:Find("Icon"), self.slot.gameObject)

    self.nameText = main:Find("Name"):GetComponent(Text)

    main:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:OnBuy() end)
    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.mesh_fashion_buybg)))
    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
end

function MeshFashionSpecial:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MeshFashionSpecial:OnOpen()
    self:RemoveListeners()

    self.itemData = self.openArgs
    self:Reload()
end

function MeshFashionSpecial:OnHide()
    self:RemoveListeners()
end

function MeshFashionSpecial:RemoveListeners()
end

function MeshFashionSpecial:ReloadDigits(num)
    local digitNumList = {}
    while num > 0 do
        table.insert(digitNumList, 1, num % 10)
        num = math.floor(num / 10)
    end
    if #digitNumList == 0 then
        digitNumList[1] = 0
    end

    self.layout:ReSet()
    for i,num in ipairs(digitNumList) do
        local tab = self.digitList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.digitCloner)
            tab.transform = tab.gameObject.transform
            tab.image = tab.gameObject:GetComponent(Image)
            self.digitList[i] = tab
        end
        local sprite = self.assetWrapper:GetSprite(AssetConfig.specialitem_texture, string.format("number%s", num))
        local size = sprite.textureRect.size
        tab.image.sprite = sprite
        tab.transform.sizeDelta = size * 0.8
        self.layout:AddCell(tab.gameObject)
    end
    for i=#digitNumList+1,#self.digitList do
        self.digitList[i].gameObject:SetActive(false)
    end
    self.digitCloner:SetActive(false)
end

function MeshFashionSpecial:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function MeshFashionSpecial:Reload()
    local base_id = self.itemData.base_id
    local data = {}
    for i,v in ipairs(DataMonthGift.data_specialitem) do
        if v.gift_id == base_id
            and (v.classes == 0 or v.classes == RoleManager.Instance.RoleData.classes)
            and (v.sex == 2 or v.sex == RoleManager.Instance.RoleData.sex)
            then
            table.insert(data, v)
            break
        end
    end

    if #data == 0 then
        self:OnClose()
        return
    end

    local itemData = DataItem.data_get[data[1].item_id]
    self.slot:SetAll(itemData, {inbag = false, nobutton = true})
    self.slot:SetNum(data[1].num)
    self.nameText.text = itemData.name

    self.price = data[1].price[1]

    self.assetLoader:SetSprite(SingleIconType.Item, DataItem.data_get[data[1].price[1][1]].icon)
    self:ReloadDigits(data[1].price[1][2])
end

function MeshFashionSpecial:OnBuy()
    self.confirmData = self.confirmData or NoticeConfirmData.New()
    self.confirmData.content = string.format(TI18N("是否花费{assets_2, %s}<color='#00ff00'>%s</color>购买<color='#ffff00'>%s</color>？"), self.price[1], self.price[2], DataItem.data_get[self.itemData.base_id].name)
    self.confirmData.sureCallback = function() BackpackManager.Instance:Send10315(self.itemData.id, 1) self:OnClose() end
    NoticeManager.Instance:ConfirmTips(self.confirmData)
end

