-- ----------------------------------------------------------
-- UI - 坐骑查看窗口
-- @ljh 2016.8.23
-- ----------------------------------------------------------
RideShowView = RideShowView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function RideShowView:__init(model)
    self.model = model
    self.name = "RideShowView"
    self.windowId = WindowConfig.WinID.rideshowwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.rideshowwindow, type = AssetType.Main}
        , {file = AssetConfig.ride_texture, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
        , {file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.headride, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------
    self.previewComposite = nil

    self.preview = nil

    self.equipList = {}
    self.equipIconList = {}
    self.skillItemList = {}

    self.tipsPanel = nil
    self.tipsMainPanel = nil
    self.tipsSubPanel = nil

    self.headlist = {}

	------------------------------------------------
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RideShowView:__delete()
    for k,v in pairs(self.equipIconList) do
        v:DeleteMe()
        v = nil
    end

    self:OnHide()

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    for i,v in ipairs(self.skillItemList) do
		v:DeleteMe()
	end

	if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function RideShowView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rideshowwindow))
    self.gameObject.name = "RideShowView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainPanel = self.transform:FindChild("Main").gameObject
    self.tipsPanel = self.transform:FindChild("TipsPanel").gameObject
    self.tipsMainPanel = self.tipsPanel.transform:FindChild("Main").gameObject
    self.tipsSubPanel = self.tipsPanel.transform:FindChild("Sub").gameObject

    self.mainPanel.transform:Find("BigBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.mainPanel.transform:Find("BigBg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")

    local btn = self.mainPanel.transform:FindChild("CloseButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnClickClose() end)

    btn = self.transform:FindChild("Panel"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnClickClose() end)

    btn = self.mainPanel.transform:FindChild("ModelPanel/Button"):GetComponent(Button)
    btn.onClick:AddListener(function() self:ShowTips() end)

    btn = self.tipsPanel:GetComponent(Button)
    btn.onClick:AddListener(function() self:CloseTips() end)

    self.preview = self.mainPanel.transform:FindChild("ModelPanel/Preview")

    local stonePanel = self.mainPanel.transform:FindChild("EquipPanel/panel").gameObject
    for i=1, 2 do
        local slot = ItemSlot.New()
        table.insert(self.equipIconList, slot)
        slot.gameObject.name = "item_slot"
        local stone = stonePanel.transform:FindChild("gem"..i).gameObject
        stone.name = tostring(i)
        UIUtils.AddUIChild(stone, slot.gameObject)
        table.insert(self.equipList, stone)
        -- stone:GetComponent(Button).onClick:AddListener(function() self:onequipclick(stone) end)
        -- slot.gameObject:GetComponent(Button).onClick:AddListener(function() self:onequipclick(stone) end)
    end

    self.skillContainer = self.mainPanel.transform:FindChild("SkillPanel/Mask/Container")
    self.skillContainerRect = self.skillContainer:GetComponent(RectTransform)
    local len = self.skillContainer.childCount
    for i = 1, len do
    	local index = i
   		local item = RideSkillItem.New(self.skillContainer:GetChild(i - 1).gameObject, self, true, false, index)
        item.noNotice = true
   		table.insert(self.skillItemList, item)
    end
    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function RideShowView:OnClickClose()
    RideManager.Instance.model:CloseRideShowWindow()
end

function RideShowView:OnShow()
    self:CloseTips()
	self:update()
end

function RideShowView:OnHide()

end

function RideShowView:update()
   self:update_model()
   self:update_info()
   self:update_attr()
   self:update_equip()
   self:update_skill()
   self:update_tipsMain()
end

function RideShowView:update_model()
    local rideData = self.model.show_ridedata

    local ride_look = rideData.base.base_id
    local ride_jewelry1 = 0
    local ride_jewelry2 = 0
    if rideData.transformation_id == 0 then
        for _,value in ipairs(rideData.decorate_list) do
            if value.decorate_index == 1 and value.is_hide == 0 then
                ride_jewelry1 = value.decorate_base_id
            elseif value.decorate_index == 2 and value.is_hide == 0 then
                ride_jewelry2 = value.decorate_base_id
            end
        end
    else
        ride_look = rideData.transformation_id
    end

    if rideData.dye_id ~= 0 then
        ride_look = rideData.dye_id
    end

    local _scale = DataMount.data_ride_data[ride_look].scale / 100 
    local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = _scale, effects = {}}
	table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = ride_look })
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry1, looks_val = ride_jewelry1 })
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry2, looks_val = ride_jewelry2 })
    
    local setting = {
        name = "RideShowView"
        ,orthographicSize = 0.8
        ,width = 328
        ,height = 341
        ,offsetY = -0.4
    }

    local fun = function(composite)
        if BaseUtils.is_null(self.gameObject) or BaseUtils.is_null(self.preview) then
            return
        end
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.LeftForward, 0))

        -- if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
        -- self.timeId_PlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayIdleAction() end)
    end

    self.previewComposite = PreviewComposite.New(fun, setting, data)
    self.previewComposite:BuildCamera(true)
end

function RideShowView:update_info()
	local transform = self.mainPanel.transform
    local rideData = self.model.show_ridedata
    local gameObject = transform:FindChild("ModelPanel").gameObject

    gameObject.transform:FindChild("PointText"):GetComponent(Text).text = tostring(rideData.score * 5)
    gameObject.transform:FindChild("LevText"):GetComponent(Text).text = string.format(TI18N("等级:%s"), rideData.lev)
end

function RideShowView:update_attr()
	local transform = self.mainPanel.transform
    local rideData = self.model.show_ridedata
    local gameObject = transform:FindChild("AttrPanel").gameObject

    -- local attr_list = self.model:get_ride_all_attr_val(rideData.mount_base_id)
    local attr_list = self.model:get_all_attr_val(rideData.lev, rideData.base.classes, rideData.index, rideData.growth)
    local speed_attr = rideData.base.speed_attr[1]
    table.insert(attr_list, 1, { key = speed_attr.attr_name, value = speed_attr.val1 })
    for i=1, #attr_list do
        if i <= 5 then
            local item = gameObject.transform:FindChild(string.format("AttrObject%s", i)).gameObject
            item.gameObject:SetActive(true)

            if string.len(KvData.GetAttrName(attr_list[i].key)) > 6 then
                item.transform:FindChild("ValueText").sizeDelta = Vector2(101, 27)
                item.transform:FindChild("ValueText").anchoredPosition = Vector2(97, 0)
            else
                item.transform:FindChild("ValueText").sizeDelta = Vector2(128.2, 27)
                item.transform:FindChild("ValueText").anchoredPosition = Vector2(72.2, 0)
            end

            if attr_list[i].key == 12 then
                item.transform:FindChild("NameText"):GetComponent(Text).text = TI18N("移动速度:")
                item.transform:FindChild("ValueText"):GetComponent(Text).text = string.format("+%s", attr_list[i].value)

                item.transform:FindChild("ValueText").sizeDelta = Vector2(101, 27)
                item.transform:FindChild("ValueText").anchoredPosition = Vector2(97, 0)
            else
                item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].key))
                item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(attr_list[i].value)
            end
            item.transform:FindChild("Icon"):GetComponent(Image).sprite
                = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].key])))
        end
    end

    if #attr_list < 5 then
        for i=#attr_list+1, 5 do
            gameObject.transform:FindChild(string.format("AttrObject%s", i)).gameObject:SetActive(false)
        end
    end

    gameObject.transform:FindChild("GrowthValueText"):GetComponent(Text).text = string.format("%.2f", rideData.growth)
    gameObject.transform:FindChild("GrowthIcon"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.ride_texture, string.format("RideGrowth%s", rideData.growth))
end

function RideShowView:update_equip()
	local rideData = self.model.show_ridedata

    if rideData ~= nil then
        local stonedata = nil
        local equipIcon = nil
        for i=1,#self.equipList do
            self.equipList[i].name = tonumber(i)
            self.equipIconList[i].gameObject:SetActive(false)
        end

        for i=1,#rideData.decorate_list do
            stonedata = rideData.decorate_list[i]
            equipIcon = self.equipIconList[stonedata.decorate_index]

            local ride_jewelry = DataMount.data_ride_jewelry[stonedata.decorate_base_id]
            if ride_jewelry == nil then break end
            local itembase = BackpackManager.Instance:GetItemBase(ride_jewelry.item_id)
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            equipIcon:SetAll(itemData)

            self.equipList[stonedata.decorate_index].name = "equip"
            equipIcon.gameObject:SetActive(true)
        end
    end
end

function RideShowView:update_skill()
	local rideData = self.model.show_ridedata
	local list = rideData.skill_list
	table.sort(list, function(a,b) return a.skill_index < b.skill_index end)

    local skill_num = 5

    for i = 1, #list do
        local v = list[i]
        self.skillItemList[i]:SetData(v)
    end

    if #list < skill_num then
        for i = #list+1, skill_num do
            self.skillItemList[i]:SetData(nil)
        end
    end

    if skill_num < #self.skillItemList then
        for i = skill_num+1, #self.skillItemList do
            self.skillItemList[i].gameObject:SetActive(false)
        end
    end

    self.skillContainerRect.sizeDelta = Vector2(90 * skill_num, 100)
end

function RideShowView:ShowTips()
    self.tipsPanel:SetActive(true)
    self.tipsSubPanel:SetActive(false)
end

function RideShowView:CloseTips()
    self.tipsPanel:SetActive(false)
    self.tipsSubPanel:SetActive(false)
end

function RideShowView:update_tipsMain()
    local rideData = self.model.show_ridedata
    -- local list = rideData.appearance_list
    local list = self.model:get_all_ride_transformation_list()

    local gameObject = self.tipsMainPanel.gameObject

    local container = gameObject.transform:FindChild("Mask/Container").gameObject
    local headItem = gameObject.transform:FindChild("Mask/Container/HeadItem").gameObject
    headItem:SetActive(false)
    for i,value in ipairs(list) do
        if value.id ~= self.model.show_ridedata.mount_base_id then
            local item = GameObject.Instantiate(headItem)
            item:SetActive(true)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            table.insert(self.headlist, item)

            local data = DataMount.data_ride_data[value.id]
            item.name = tostring(data.base_id)

            item.transform:FindChild("head"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.headride, data.head_id)
            local btn = item:AddComponent(Button)
            btn.onClick:AddListener(function() self:onheaditemclick(item) end)

            local hasAppearance = false
            for _, appearance in ipairs(rideData.appearance_list) do
                if appearance.appearance_id == value.id then
                    hasAppearance = true
                    break
                end
            end

            if not hasAppearance then
                item.transform:FindChild("head"):GetComponent(Image).color = Color(0.2, 0.2, 0.2)
            end
        end
    end
end

function RideShowView:onheaditemclick(item)
    self.select_ridedata = DataMount.data_ride_data[tonumber(item.name)]

    local head
    for i = 1, #self.headlist do
        head = self.headlist[i]
        head.transform:FindChild("Select").gameObject:SetActive(false)
    end
    item.transform:FindChild("Select").gameObject:SetActive(true)

    self.tipsSubPanel:SetActive(true)
    self:update_tipsSub()
end

function RideShowView:update_tipsSub()
    if self.select_ridedata == nil then
        return
    end

    local gameObject = self.tipsSubPanel.gameObject
    gameObject.transform:FindChild("HeadImage/head"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.headride, self.select_ridedata.head_id)
    gameObject.transform:FindChild("NameText"):GetComponent(Text).text = self.select_ridedata.name

    local ride_transformation = DataMount.data_ride_transformation[self.select_ridedata.base_id]
    if ride_transformation ~= nil then
        local attr_list = DataMount.data_ride_transformation[self.select_ridedata.base_id].collect_attr
        for i=1, #attr_list do
            local item = gameObject.transform:FindChild(string.format("AttrObject%s", i)).gameObject
            item.gameObject:SetActive(true)

            item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].attr_name))
            item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(attr_list[i].val1)
            item.transform:FindChild("Icon"):GetComponent(Image).sprite
                = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].attr_name])))

            if i % 2 == 0 then
                item.transform:FindChild("Image").gameObject:SetActive(false)
            else
                item.transform:FindChild("Image").gameObject:SetActive(true)
            end
        end

        if #attr_list < 5 then
            for i=#attr_list+1, 5 do
                gameObject.transform:FindChild(string.format("AttrObject%s", i)).gameObject:SetActive(false)
            end
        end

        gameObject.transform:FindChild("SpeedText"):GetComponent(Text).text = string.format(TI18N("移动速度：%s"), self.select_ridedata.speed_attr[1].val1)
    else

    end
end