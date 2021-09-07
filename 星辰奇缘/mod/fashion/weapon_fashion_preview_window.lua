WeaponFashionPreviewWindow  =  WeaponFashionPreviewWindow or BaseClass(BasePanel)

function WeaponFashionPreviewWindow:__init(model)
    self.name  =  "WeaponFashionPreviewWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.weaponfashionpreviewwindow, type  =  AssetType.Main},
        {file = AssetConfig.rolebg, type = AssetType.Dep},
    }

    self.width = 315
    self.height = 0

    self.minScale = 0.8
    self.maxScale = 1.05

    self.timer_id = 0

    self.txtTab = {}

    self.classes = RoleManager.Instance.RoleData.classes

    return self
end


function WeaponFashionPreviewWindow:__delete()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.timer ~= nil then 
        LuaTimer.Delete(self.timer)
    end

    self:stop_rotate_win_bg()

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function WeaponFashionPreviewWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.weaponfashionpreviewwindow))
    self.gameObject.name  =  "WeaponFashionPreviewWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, -400)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseWeaponFashionPreviewWindow() end)

    self.MainCon = self.transform:Find("MainCon")

    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseWeaponFashionPreviewWindow() end)

    self.MainCon:Find("ImgPreviewBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebg, "RoleBg")
    -- self.ImgPreviewBg = self.MainCon:Find("ImgPreviewBg")
    self.Preview = self.MainCon:Find("Preview").gameObject

    self.TxtTitle = self.MainCon:Find("TxtTitle"):GetComponent(Text)

    self.ImgTxtBg = self.MainCon:Find("ImgTxtBg")
    self.TxtName = self.ImgTxtBg:Find("TxtName"):GetComponent(Text)

    self.NextButton = self.MainCon:Find("NextButton").gameObject
    self.NextButton:GetComponent(Button).onClick:AddListener(function() self:OnClickNextButton() end)
    self.PreButton = self.MainCon:Find("PreButton").gameObject
    self.PreButton:GetComponent(Button).onClick:AddListener(function() self:OnClickPreButton() end)
    -- self.BtnConfirm = self.MainCon:Find("BtnConfirm"):GetComponent(Button)
    -- self.BtnConfirm.onClick:AddListener(function() self.model:CloseEquipDianhuaGetsUI() end)

    self:update_info()
end

function WeaponFashionPreviewWindow:OnClickNextButton()
    -- if self.classes < 6 then
    --     self.classes = self.classes + 1
    --     self:update_info()
    -- end
    -- if self.classes == 6 then
    --     self.NextButton:SetActive(false)
    -- else
    --     self.PreButton:SetActive(true)
    -- end
    self.classes = self.classes + 1
    if self.classes > 7 then
        self.classes = self.classes - 7
    end
    self:update_info()
end

function WeaponFashionPreviewWindow:OnClickPreButton()
    -- if self.classes > 1 then
    --     self.classes = self.classes - 1
    --     self:update_info()
    -- end
    -- if self.classes == 0 then
    --     self.PreButton:SetActive(false)
    -- else
    --     self.NextButton:SetActive(true)
    -- end
    self.classes = self.classes - 1
    if self.classes < 1 then
        self.classes = self.classes + 7
    end
    self:update_info()
end

function WeaponFashionPreviewWindow:update_info()
    self.fashion_data = nil
    
    for key, value in pairs(DataFashion.data_base) do
        if value.special_mark == 4 and self.classes == value.classes then
            self.fashion_data = value
        end
    end

    -- self:star_rotate_win_bg()
    -- self.ImgPreviewBg  --转动
    -- self.Preview

    if self.fashion_data ~= nil then
        self.TxtTitle.text = string.format("%s<color='#ffff00'>(%s)</color>", self.fashion_data.name, KvData.classes_name[self.classes])
        self.TxtName.text = TI18N("竞技场每日<color='#00ff00'>前五名</color>\n可获得<color='#ffff00'>竞技王者</color>武饰")

        self.timer = LuaTimer.Add(200, function() self:UpdatePreview() end)
        -- self:UpdatePreview()
    end
end


--播放背景转圈
function WeaponFashionPreviewWindow:star_rotate_win_bg()
    -- self:stop_rotate_win_bg()
    -- self.timer_id = LuaTimer.Add(0, 2, function(id) self.ImgPreviewBg:RotateAround(self.ImgPreviewBg.position, self.ImgPreviewBg.forward, 0.4) end)
end

--停止播放背景转圈
function WeaponFashionPreviewWindow:stop_rotate_win_bg()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end


------------------模型逻辑
function WeaponFashionPreviewWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local setting = {
        name = "WeaponFashionPreviewWindow"
        ,orthographicSize = 0.48
        ,width = 240
        ,height = 240
        ,offsetY = -0.1
        ,noDrag = true
    }

    local base_data = DataItem.data_get[self.model.new_shenqi_id]
    local _looks = BaseUtils.copytab(SceneManager.Instance:MyData().looks)
    local weaponData = DataLook.data_weapon[string.format("%s_12", self.fashion_data.model_id)]
    for k,v in pairs(_looks) do
        if v.looks_type == 1 then
            v.looks_val = self.fashion_data.model_id
            if weaponData ~= nil then
                v.looks_mode = weaponData.effect_id
            end
            break
        end
    end
    local modelData = {type = PreViewType.Weapon, classes = self.classes, sex = RoleManager.Instance.RoleData.sex, looks = _looks}
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    self.previewComp = PreviewComposite.New(callback, setting, modelData)
end


function WeaponFashionPreviewWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.Preview:SetActive(true)
end