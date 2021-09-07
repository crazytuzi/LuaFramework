RidePropPreviewWindow  =  RidePropPreviewWindow or BaseClass(BasePanel)

function RidePropPreviewWindow:__init(model)
    self.name  =  "RidePropPreviewWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.rideproppreviewwin, type  =  AssetType.Main}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.previewComposite = nil

    return self
end


function RidePropPreviewWindow:__delete()

    self.is_open  =  false

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function RidePropPreviewWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.rideproppreviewwin))
    self.gameObject.name  =  "RidePropPreviewWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseRidePropPreviewUI() end)


    self.MainCon = self.transform:FindChild("MainCon")
    self.TopCon = self.MainCon:FindChild("TopCon")
    self.LeftCon = self.TopCon:FindChild("LeftCon")
    self.Preview = self.LeftCon:FindChild("Preview")


    self.RightCon = self.TopCon:FindChild("RightCon")
    self.TxtScore = self.RightCon:FindChild("TxtScore"):GetComponent(Text)
    self.TxtGrowth = self.RightCon:FindChild("TxtGrowth"):GetComponent(Text)
    self.TxtLev = self.RightCon:FindChild("TxtLev"):GetComponent(Text)


    self.MidCon = self.MainCon:FindChild("MidCon")
    self.item_list = {}
    for i=1,4 do
        local item = {}
        item.gameObject = self.MidCon:FindChild(string.format("Item%s", i)).gameObject
        item.ImgIcon = item.gameObject.transform:FindChild("ImgIcon"):GetComponent(Image)
        item.TxtDesc = item.gameObject.transform:FindChild("TxtDesc"):GetComponent(Text)
        table.insert(self.item_list, item)
    end

    self.BottomCon = self.MainCon:FindChild("BottomCon")
    self.MaskCon = self.BottomCon:FindChild("MaskCon")
    self.ScrollCon = self.MaskCon:FindChild("ScrollCon")
    self.Container = self.ScrollCon:FindChild("Container")
    self.skill_item_list = {}
    for i=1, 8 do
        local item = {}
        item.gameObject = self.Container:FindChild(string.format("SkillItem%s", i)).gameObject
        table.insert(self.skill_item_list, item)
    end

    local setting = {
        name = "RidePropPreviewView"
        ,orthographicSize = 1
        ,width = 245.18 --188.6
        ,height = 273.52 --210.4
        ,offsetY = -0.4
    }

    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)

    self:update_info()
end

function RidePropPreviewWindow:update_info()

    ---根据类型设置显示
    local newH = 0
    if self.model.prop_preview_type == 1 then
        --不显示技能
        self.BottomCon.gameObject:SetActive(false)
        newH = 258
    else
        --显示技能
        self.BottomCon.gameObject:SetActive(true)
        newH = 393
    end
    self.MainCon:GetComponent(RectTransform).sizeDelta = Vector2(370, newH)


    --填充内容
    local rideData = self.model:get_ride_data_by_id(self.model.prop_preview_ride_id)

    self.TxtScore.text = string.format("%s：<color='#23F0F7'>%s</color>", TI18N("评分"), rideData.lev)
    self.TxtGrowth.text = string.format("%s：<color='#13EE5E'>%s</color>", TI18N("成长"), rideData.growth)
    self.TxtLev.text = string.format("%s：<color='#C7F9FF'>%s</color>", TI18N("等级"), rideData.lev)

    for i=1,#self.item_list do
        local item = self.item_list[i]
        item.gameObject:SetActive(false)
    end

    local index = 1
    for i=1,#rideData.base.attr do
        local attr_data = rideData.base.attr[i]
        local item = self.item_list[i]
        local attr_val = self.model:count_ride_attr_val(rideData.base.attr_ratio, attr_data.val1, rideData.growth)
        item.TxtDesc.text = string.format("%s：<color='#C7F9FF'>%s</color>", KvData.attr_name[attr_data.attr_name], attr_val)
        item.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon , string.format("AttrIcon%s", attr_data.attr_name))
        item.gameObject:SetActive(true)
        index = index + 1
    end

    --设置移动速度
    if index <= #self.item_list then
        local item = self.item_list[index]
        local cfg_data = DataMount.data_ride_reset[rideData.speed_lev]
        local attr_val = 1
        item.TxtDesc.text = string.format("%s：<color='#C7F9FF'>%s</color>", TI18N("移动速度"), attr_val)
        item.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon , string.format("AttrIcon%s", 3))
        item.gameObject:SetActive(true)
    end

    --更新技能
    for i=1,#self.skill_item_list do

    end


    --更新模型
    local ride_jewelry1 = 0
    local ride_jewelry2 = 0
    for _,value in ipairs(rideData.decorate_list) do
        if value.decorate_index == 1 then
            ride_jewelry1 = value.decorate_base_id
        elseif value.decorate_index == 2 then
            ride_jewelry2 = value.decorate_base_id
        end
    end

    local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = 1, effects = {}}
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = rideData.base.looks_id })
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry1, looks_val = ride_jewelry1 })
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry2, looks_val = ride_jewelry2 })
    self:load_preview(self.Preview, data)
end

function RidePropPreviewWindow:load_preview(model_preview, data)
    if not BaseUtils.sametab(data, self.model_data) then
        self.model_data = data

        self.model_preview = model_preview
        self.previewComposite:Reload(self.model_data, function(composite) self:preview_loaded(composite) end)
    else
        self.model_preview = model_preview
        local rawImage = self.previewComposite.rawImage
        rawImage.transform:SetParent(self.model_preview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
    end
end

function RidePropPreviewWindow:preview_loaded(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.model_preview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
end