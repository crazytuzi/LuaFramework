-- @author xjlong
-- @date 2016年8月17日
-- @坐骑展示界面

EncyclopediaRide = EncyclopediaRide or BaseClass(BasePanel)


function EncyclopediaRide:__init(parent)
    self.Mgr = EncyclopediaManager.Instance
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaRide"

    self.resList = {
        {file = AssetConfig.ride_peida, type = AssetType.Main},
        {file = AssetConfig.ride_texture, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = AssetConfig.ridebg, type = AssetType.Dep},
        {file = AssetConfig.headride, type = AssetType.Dep},
    }

    self.ridedata = nil
    self.ridelist = {}
    self.selectItem = nil

    self.gameObject = nil
    self.transform = nil
    self.ItemListCon = nil
    self.ItemListItem = nil
    self.Layout = nil

    self.modelPanel = nil
    self.attrPanel = nil
    self.infoPanel = nil
    self.preview = nil
    self.previewComp = nil
    self.attrImage1 = nil
    self.attrImage2 = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaRide:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    self:AssetClearAll()
end

function EncyclopediaRide:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ride_peida))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.ItemListCon = self.transform:Find("ItemList/Mask/Scroll")
    self.ItemListItem = self.transform:Find("ItemList/Mask/Scroll"):GetChild(0).gameObject
    self.ItemListItem:SetActive(false)

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = -4.8
        ,Top = 0
    }
    self.Layout = LuaBoxLayout.New(self.ItemListCon, setting)

    self.modelPanel = self.transform:FindChild("Right/ModelPanel").gameObject
    self.attrPanel = self.transform:FindChild("Right/AttrPanel").gameObject
    self.infoPanel = self.transform:FindChild("Right/InfoPanel").gameObject

    local rideBg = self.modelPanel.transform:Find("Bg"):GetComponent(Image)
    rideBg.sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg, "RideBg")
    rideBg.enabled = true
    self.preview = self.modelPanel.transform:Find("Preview").gameObject
    self.attrImage1 = self.attrPanel.transform:Find("Image1").gameObject
    self.attrImage2 = self.attrPanel.transform:Find("Image2").gameObject

    self.ridelist = RideManager.Instance.model:get_all_ride_show_list()
    for i,v in ipairs(self.ridelist) do
        local RideItem = GameObject.Instantiate(self.ItemListItem)
        self.Layout:AddCell(RideItem.gameObject)
        RideItem.gameObject:SetActive(true)

        local headId = tostring(v.base.head_id)
        local headImage = RideItem.transform:FindChild("RideHead"):GetComponent(Image)
        headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.headride, headId)
        headImage.rectTransform.sizeDelta = Vector2(54, 54)

        RideItem.transform:Find("RideName"):GetComponent(Text).text = string.format("<color='%s'>%s</color>", v.color, v.base.name)
        RideItem.transform:Find("Select").gameObject:SetActive(false)

        RideItem.transform:GetComponent(Button).onClick:RemoveAllListeners()
        RideItem.transform:GetComponent(Button).onClick:AddListener(function()
            self:RefreshRideInfo(v, RideItem)
        end)
        if i == 1 then
            self:RefreshRideInfo(v, RideItem)
        end
    end
end

function EncyclopediaRide:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaRide:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaRide:OnHide()
    self:RemoveListeners()
end

function EncyclopediaRide:RemoveListeners()
end

function EncyclopediaRide:RefreshRideInfo(data, item)
    if self.ridedata == data then return end
    
    if self.selectItem ~= nil then
        self.selectItem.transform:Find("Select").gameObject:SetActive(false)
        self.selectItem.transform:Find("RideName"):GetComponent(Text).text = string.format("<color='%s'>%s</color>", self.ridedata.color, self.ridedata.base.name)
    end

    item.transform:Find("Select").gameObject:SetActive(true)
    item.transform:Find("RideName"):GetComponent(Text).text = string.format("<color='#ffff9a'>%s</color>", data.base.name)
    
    self.ridedata = data
    self.selectItem = item

    self:update_model()
    self:update_attrPanel()
end

function EncyclopediaRide:update_model()
    if self.ridedata == nil then return end

    local transform = self.modelPanel.transform
    local rideData = self.ridedata

    -- local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = 1, effects = {}}
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = rideData.base.base_id })
    local data = RideManager.Instance.model:MakeRideLook(rideData)

    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local setting = {
        name = "RideView"
        ,orthographicSize = 1
        ,width = 328
        ,height = 341
        ,offsetY = -0.4
        ,noDrag = true
        ,noMaterial = true
    }

    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, data, "RideModelPreview")
    else
        self.previewComp:Reload(data, callback)
    end
end

function EncyclopediaRide:update_attrPanel()
    if self.ridedata == nil then return end

    local gameObject = self.attrPanel
    local attr_list = BaseUtils.copytab(self.ridedata.collect_attr)

    if self.ridedata.normal == true then
        self.attrImage1:SetActive(true)
        self.attrImage2:SetActive(false)
        attr_list = BaseUtils.copytab(self.ridedata.attr)
    else
        self.attrImage1:SetActive(false)
        self.attrImage2:SetActive(true)
    end

    local speed_attr = self.ridedata.base.speed_attr[1]
    table.insert(attr_list, { attr_name = speed_attr.attr_name, val1 = speed_attr.val1 })
    local attrCount = #attr_list

    for i=1, attrCount do
        local item = gameObject.transform:FindChild(string.format("AttrObject%s", i)).gameObject
        item:SetActive(true)

        if attr_list[i].attr_name == 12 then
            item.transform:FindChild("NameText"):GetComponent(Text).text = TI18N("移动速度:")
            item.transform:FindChild("ValueText"):GetComponent(Text).text = string.format("+%s", attr_list[i].val1)
            item.transform:FindChild("ValueText").sizeDelta = Vector2(101, 27)
            item.transform:FindChild("ValueText").anchoredPosition = Vector2(90, 0)
        else
            item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].attr_name))
            item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(attr_list[i].val1)
        end

        item.transform:FindChild("Icon"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].attr_name])))
    end

    if attrCount < 4 then
        for i=attrCount+1, 4 do
            gameObject.transform:FindChild(string.format("AttrObject%s", i)).gameObject:SetActive(false)
        end
    end

    self.infoPanel.transform:FindChild("Text"):GetComponent(Text).text = self.ridedata.access
end

function EncyclopediaRide:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)

    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(-6, SceneConstData.UnitFaceTo.LeftForward, -8))
end
