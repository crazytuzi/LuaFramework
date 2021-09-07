-- ----------------------------------------------------------
-- UI - 坐骑装备窗口
-- @ljh 2016.5.25
-- ----------------------------------------------------------
RideEquipView = RideEquipView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function RideEquipView:__init(model)
    self.model = model
    self.name = "RideEquipView"
    self.windowId = WindowConfig.WinID.rideequip
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.rideequip, type = AssetType.Main}
        -- , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        , {file = AssetConfig.eqmwashbg, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------
    self.previewComposite = nil

    self.preview = nil


    self.buttonscript_main = nil
    self.buttonscript_sub = nil

    self.itemSolt_main = nil
    self.itemSolt_sub = nil

    self.equip_data = nil

    self.toggle = nil
	------------------------------------------------
    self.itemChangeListener = function()
        self:update()
    end

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RideEquipView:__delete()
    if self.itemSolt_main ~= nil then
        self.itemSolt_main:DeleteMe()
        self.itemSolt_main = nil
    end

    if self.itemSolt_sub ~= nil then
        self.itemSolt_sub:DeleteMe()
        self.itemSolt_sub = nil
    end

    self:OnHide()

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.buttonscript_main ~= nil then
        self.buttonscript_main:DeleteMe()
        self.buttonscript_main = nil
    end

    if self.buttonscript_sub ~= nil then
        self.buttonscript_sub:DeleteMe()
        self.buttonscript_sub = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function RideEquipView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rideequip))
    self.gameObject.name = "RideEquipView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainPanel = self.transform:FindChild("Main").gameObject
    self.subPanel = self.transform:FindChild("Sub").gameObject

    self.mainPanel.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.subPanel.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.eqmwashbg, "EqmWashBg")

    local btn = self.mainPanel.transform:FindChild("CloseButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnClickClose() end)

    btn = self.subPanel.transform:FindChild("CloseButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnClickClose() end)

    self.buttonscript_main = BuyButton.New(self.mainPanel.transform:FindChild("BuyButton"), TI18N("穿 戴"), false)
    local myColor = Color(144/255,96/255.20/255,1)

    self.buttonscript_main.key = "RideWear"
    self.buttonscript_main.protoId = 17017
    self.buttonscript_main:Show()


    self.buttonscript_sub = BuyButton.New(self.subPanel.transform:FindChild("BuyButton"), TI18N("穿 戴"), false)
    self.buttonscript_sub.key = "RideWear2"
    self.buttonscript_sub.protoId = 17017
    self.buttonscript_sub:Show()
    self.buttonscript_sub:Set_btn_img("DefaultButton3")

    -- self.toggle = self.mainPanel.transform:FindChild("Toggle"):GetComponent(Toggle)
    -- self.toggle.onValueChanged:AddListener(function(on) self:ontogglechange(on) end)

    self.itemSolt_main = ItemSlot.New()
    UIUtils.AddUIChild(self.mainPanel.transform:FindChild("Item/Icon").gameObject, self.itemSolt_main.gameObject)

    self.itemSolt_sub = ItemSlot.New()
    UIUtils.AddUIChild(self.subPanel.transform:FindChild("Item/Icon").gameObject, self.itemSolt_sub.gameObject)

    self.preview = self.mainPanel.transform:FindChild("Preview")
    self.preview1 = self.subPanel.transform:FindChild("Panel1/Preview")
    self.preview2 = self.subPanel.transform:FindChild("Panel2/Preview")
    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function RideEquipView:InitPanel_main()
    local setting = {
        name = "RideView"
        ,orthographicSize = 0.85
        ,width = 328
        ,height = 341
        ,offsetY = -0.45
    }

    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)
end

function RideEquipView:InitPanel_sub()

end

function RideEquipView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function RideEquipView:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 1 then
        if self.model.cur_ridedata == nil then return end
        self.equipIndex = self.openArgs[1]
        self.equip_baseid = self.openArgs[2]

        if self.equipIndex == 1 then
            self.panel_index = 1
            self:InitPanel_main()
            self.mainPanel:SetActive(true)
            self.subPanel:SetActive(false)

        else
            self.panel_index = 2
            self:InitPanel_sub()
            self.mainPanel:SetActive(false)
            self.subPanel:SetActive(true)
        end
    end

    self.equip_data = self.model:get_ride_equip_data(self.model.cur_ridedata.mount_base_id, self.panel_index)

	self:update()

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemChangeListener)
end

function RideEquipView:OnHide()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemChangeListener)
end

function RideEquipView:update()
    if self.panel_index == 1 then
        self:update_model_main()
        self:update_item_main()
    elseif self.panel_index == 2 then
        self:update_item_sub()
    end
end

function RideEquipView:update_model_main()
    local rideData = self.model.cur_ridedata


    local ride_id = rideData.base.base_id
    print(ride_id)
    for k,v in pairs(DataMount.data_ride_jewelry) do
        if v.mount_base_id == rideData.base.base_id and v.type == 1 then
            ride_id = v.appearance
            break
        end
    end
    local ride_jewelry1 = 0
    local ride_jewelry2 = 0
    for _,value in ipairs(rideData.decorate_list) do
        if value.decorate_index == 1 then
            ride_jewelry1 = value.decorate_base_id
        elseif value.decorate_index == 2 then
            ride_jewelry2 = value.decorate_base_id
        end
    end

    -- if self.toggle.isOn then
        -- local equip_data = self.equip_data
        -- if equip_data == nil then return end
        -- if self.equipIndex == 1 then
        --     ride_jewelry1 = equip_data.base_id
        -- elseif self.equipIndex == 2 then
        --     ride_jewelry2 = equip_data.base_id
        -- end
    -- end

    local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = 1, effects = {}}
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = ride_id })
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry1, looks_val = self.equip_data.item_id })
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry2, looks_val = ride_jewelry2 })

    -- local data = self.model:MakeRideLook(rideData)

    self.previewComposite:Reload(data, function(composite) self:preview_loaded_main(composite) end)
end

function RideEquipView:preview_loaded_main(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
end

function RideEquipView:update_item_main()
    local equip_data = self.equip_data
    if equip_data == nil then return end
    -- self.buttonscript_main:Layout({[equip_data.item_id] = {need = 1}}, function() self:send_suit_up_main() end, function (baseidToBuyInfo) self:callbackAfter12406_main(baseidToBuyInfo) end)
    self.buttonscript_main:Layout({[equip_data.item_id] = {need = 1}}, function() self:send_suit_up_main() end)

    local itembase = BackpackManager.Instance:GetItemBase(equip_data.item_id)
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    self.itemSolt_main:SetAll(itemData)

    self.mainPanel.transform:FindChild("Item/NameText"):GetComponent(Text).text = itemData.name

    self.mainPanel.transform:FindChild("Text"):GetComponent(Text).text = string.format(TI18N("装备后每日回复<color='#00ff00'>%s精力</color>"), equip_data.day_spirit)
end

function RideEquipView:callbackAfter12406_main(baseidToBuyInfo)
    local coins = RoleManager.Instance.RoleData.coins
    local gold_bind = RoleManager.Instance.RoleData.gold_bind

    local t = self.mainPanel.transform:FindChild("Item/Num")
    local numText = t:GetComponent(Text)

    if self.imgLoader == nil then
        local go = t:Find("Currency").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, baseidToBuyInfo[1].assets)

    if baseidToBuyInfo[1].allprice < 0 then
        numText.text = "<color=#FF0000>"..tostring(0 - baseidToBuyInfo[1].allprice).."</color>"
    else
        numText.text = tostring(v.allprice)
    end
end

function RideEquipView:suit_up_main()
    local rideData = self.model.cur_ridedata
    local equip_data = self.equip_data
    if rideData == nil then return end
    if equip_data == nil then return end
    local list = BackpackManager.Instance:GetItemByBaseid(equip_data.item_id)
    if list ~= nil and #list > 0 then
        self:send_suit_up_main()
    else
        self.buttonscript_main:ShowNotice(true)
    end
end

function RideEquipView:send_suit_up_main()
print("send_suit_up_main")
    local rideData = self.model.cur_ridedata
    local equip_data = self.equip_data
    if rideData == nil then return end
    if equip_data == nil then return end
    -- local list = BackpackManager.Instance:GetItemByBaseid(equip_data.item_id)
    -- if list ~= nil and #list > 0 then
    --     print(list[1].id)
    --     RideManager.Instance:Send16403(rideData.index, list[1].id)
    -- end
    RideManager.Instance:Send17017(rideData.index, 1)
    self:OnClickClose()
end

function RideEquipView:ontogglechange(on)
    self:update_model_main()
end

function RideEquipView:update_item_sub()
    local equip_data = self.equip_data
    if equip_data == nil then return end
    -- self.buttonscript_sub:Layout({[equip_data.item_id] = {need = 1}}, function() self:send_suit_up_sub() end, function (baseidToBuyInfo) self:callbackAfter12406_sub(baseidToBuyInfo) end)
    self.buttonscript_sub:Layout({[equip_data.item_id] = {need = 1}}, function() self:send_suit_up_sub() end)

    local itembase = BackpackManager.Instance:GetItemBase(equip_data.item_id)
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    self.itemSolt_sub:SetAll(itemData)

    self.subPanel.transform:FindChild("Item/NameText"):GetComponent(Text).text = itemData.name

    self.subPanel.transform:FindChild("Text"):GetComponent(Text).text = string.format(TI18N("装备后每日回复<color='#00ff00'>%s精力</color>"), equip_data.day_spirit)

    local attr = equip_data.attr[1]
    if attr.attr_name == 12 then
        self.subPanel.transform:FindChild("SpeedText"):GetComponent(Text).text = string.format(TI18N("<color='#00ff00'>移动速度：+%s</color>"), attr.val1)
    end
end

function RideEquipView:send_suit_up_sub()
    print("send_suit_up_sub")
    local rideData = self.model.cur_ridedata
    local equip_data = self.equip_data
    if rideData == nil then return end
    if equip_data == nil then return end
    -- local list = BackpackManager.Instance:GetItemByBaseid(equip_data.item_id)
    -- if list ~= nil and #list > 0 then
    --     print(list[1].id)
    --     RideManager.Instance:Send17003(rideData.index, list[1].id)
    -- end
    RideManager.Instance:Send17017(rideData.index, 2)
    self:OnClickClose()
end

function RideEquipView:callbackAfter12406_sub()

end