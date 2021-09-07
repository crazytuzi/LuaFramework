TherionItem = TherionItem or BaseClass()

function TherionItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject

    local t = gameObject.transform
    self.nameText = t:Find("TextBg/Text"):GetComponent(Text)
    self.effectRect = t:Find("Effect"):GetComponent(RectTransform)
    self.tagImage = t:Find("Tag"):GetComponent(Image)
    self.tagText = t:Find("Tag/Text"):GetComponent(Text)
    self.previewContainer = t:Find("Model")
    self.ltDescr = nil
    self.preview = nil
end

function TherionItem:SetData(data, index)
    if data == nil then
        self:SetActive(false)
    end

    local pdata = {type = PreViewType.Pet, skinId = data.skin_id_0, modelId = data.model_id, animationId = data.animation_id, scale = data.scale / 100, effects = data.effects_0}

    local setting = {
        name = "TherionView"
        ,orthographicSize = 0.7
        ,width = 100
        ,height = 202
        ,offsetY = -0.5
        , noDrag = true
        ,noMaterial = true
    }

    local fun = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.previewContainer)
        rawImage.transform.localPosition = Vector3(0, 30, 0)
        rawImage.transform.localScale = Vector3(1.2, 1.2, 1.2)
        --rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    if self.preview == nil then
        self.preview = PreviewComposite.New(fun, setting, pdata)
    else
        self.preview:Reload(pdata, fun)
    end

    self.tagImage.gameObject:SetActive(true)
    if data.genre == 2 then
        self.tagText.text = TI18N("神兽")
        self.tagImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel3")
    elseif data.genre == 4 then
        self.tagText.text = TI18N("珍兽")
        self.tagImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel4")
    else
        self.tagImage.gameObject:SetActive(false)
    end

    self.nameText.text = data.name

    self:SetActive(true)
end

function TherionItem:__delete()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
    if self.preview ~= nil then
        self.preview:DeleteMe()
        self.preview = nil
    end
end

function TherionItem:SetActive(bool)
    self.gameObject:SetActive(bool)
    if bool == true then
        self:GoRotation()
    else
        if self.timeId ~= nil then
            LuaTimer.Delete(self.timeId)
        end
    end
end

function TherionItem:GoRotation()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
    end
    self.timeId = LuaTimer.Add(0, 10, function()
        self.effectRect:Rotate(Vector3(0, 0, 1))
    end)
end
