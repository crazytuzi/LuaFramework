EquipStrengthDianhuaGetWindow  =  EquipStrengthDianhuaGetWindow or BaseClass(BasePanel)

function EquipStrengthDianhuaGetWindow:__init(model)
    self.name  =  "EquipStrengthDianhuaGetWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.equip_strength_dianhua_get_win, type  =  AssetType.Main},
        {file = AssetConfig.rolebg, type = AssetType.Dep},
    }

    self.width = 315
    self.height = 0

    self.minScale = 0.8
    self.maxScale = 1.05

    self.timer_id = 0

    self.txtTab = {}

    return self
end


function EquipStrengthDianhuaGetWindow:__delete()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    self:stop_rotate_win_bg()

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function EquipStrengthDianhuaGetWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_dianhua_get_win))
    self.gameObject.name  =  "EquipStrengthDianhuaGetWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, -400)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseEquipDianhuaGetsUI() end)

    self.MainCon = self.transform:Find("MainCon")

    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseEquipDianhuaGetsUI() end)

    self.MainCon:Find("ImgPreviewBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebg, "RoleBg")
    -- self.ImgPreviewBg = self.MainCon:Find("ImgPreviewBg")
    self.Preview = self.MainCon:Find("Preview").gameObject

    self.ImgTxtBg = self.MainCon:Find("ImgTxtBg")
    self.TxtName = self.ImgTxtBg:Find("TxtName"):GetComponent(Text)

    -- self.BtnConfirm = self.MainCon:Find("BtnConfirm"):GetComponent(Button)
    -- self.BtnConfirm.onClick:AddListener(function() self.model:CloseEquipDianhuaGetsUI() end)

    self:update_info()
end

function EquipStrengthDianhuaGetWindow:update_info()
    print('-====================================')
    print(self.model.new_shenqi_id)
    local base_data = DataItem.data_get[self.model.new_shenqi_id]

    -- self:star_rotate_win_bg()
    -- self.ImgPreviewBg  --转动
    -- self.Preview

    self.TxtName.text = ColorHelper.color_item_name(base_data.quality, base_data.name)

    LuaTimer.Add(200, function() self:UpdatePreview() end)
    -- self:UpdatePreview()
end


--播放背景转圈
function EquipStrengthDianhuaGetWindow:star_rotate_win_bg()
    -- self:stop_rotate_win_bg()
    -- self.timer_id = LuaTimer.Add(0, 2, function(id) self.ImgPreviewBg:RotateAround(self.ImgPreviewBg.position, self.ImgPreviewBg.forward, 0.4) end)
end

--停止播放背景转圈
function EquipStrengthDianhuaGetWindow:stop_rotate_win_bg()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end


------------------模型逻辑
function EquipStrengthDianhuaGetWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local setting = {
        name = "EquipStrengthDianhuaGetWindow"
        ,orthographicSize = 0.48
        ,width = 240
        ,height = 240
        ,offsetY = -0.1
        ,noDrag = true
    }

    local base_data = DataItem.data_get[self.model.new_shenqi_id]
    local _looks = BaseUtils.copytab(SceneManager.Instance:MyData().looks)
    local weaponData = DataLook.data_weapon[string.format("%s_12", base_data.look_id)]
    for k,v in pairs(_looks) do
        if v.looks_type == 1 then
            v.looks_val = DataItem.data_get[self.model.new_shenqi_id].look_id
            if weaponData ~= nil then
                v.looks_mode = weaponData.effect_id
            end
            break
        end
    end
    local modelData = {type = PreViewType.Weapon, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = _looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
end


function EquipStrengthDianhuaGetWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.Preview:SetActive(true)
end