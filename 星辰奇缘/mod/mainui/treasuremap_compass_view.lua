-- 主界面 藏宝图指南针
TreasuremapCompassView = TreasuremapCompassView or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function TreasuremapCompassView:__init()
    self.model = model
	self.resList = {
        {file = AssetConfig.treasuremap_compass, type = AssetType.Main}
        , {file = AssetConfig.maxnumber_str, type = AssetType.Dep}
    }

    self.name = "TreasuremapCompassView"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    self.pointer_transform = nil
    self.treasureimage = nil
    self.distanceimage = nil
    self.directionimage1 = nil
    self.text = nil
    self.image = nil
    self.directionimage2 = nil
    self.button = nil
    self.button_effect = nil
    self.loading_button_effect = false
    self.time_txt = nil
    self.timer = nil

    self.init_effect = 0

    ------------------------------------
    self._update = function(angle, dis)
    	self:update(angle, dis)
	end

    self._update_time = function()
        self:update_time()
    end

    self._change_map = function()
        self:change_map()
    end

	self:LoadAssetBundleBatch()
end

function TreasuremapCompassView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    LuaTimer.Delete(self.timerId)
    EventMgr.Instance:RemoveListener(event_name.treasuremap_compass_update, self._update)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self._change_map)
    self:AssetClearAll()
end

function TreasuremapCompassView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.treasuremap_compass))
    self.gameObject.name = "TreasuremapCompassView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

	-----------------------------
    local transform = self.transform

	self.pointer_transform = transform:FindChild("Pointer")
    self.treasureimage = transform:FindChild("Text/TreasureImage"):GetComponent(Image)
    self.distanceimage = transform:FindChild("Text/DistanceImage"):GetComponent(Image)
    self.directionimage1 = transform:FindChild("Text/DirectionImage/Image1"):GetComponent(Image)
    self.directionimage2 = transform:FindChild("Text/DirectionImage/Image2"):GetComponent(Image)
    self.image = transform:FindChild("Text/Image").gameObject
    self.text = transform:FindChild("Text/Text"):GetComponent(Text)
    self.button = transform:FindChild("Button").gameObject
    self.button:GetComponent(Button).onClick:AddListener(function() self:button_click() end)
    self.button:SetActive(false)

    self.time_txt = transform:FindChild("Time/Text"):GetComponent(Text)

    self.timerId = LuaTimer.Add(0, 1000, self._update_time)

    local fun = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.pointer_transform)
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, -12, -1000)
        effectObject.transform.localRotation = Quaternion.identity
        -- effectObject.transform:Rotate(self.pointer_transform.rotation.eulerAngles)

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        self.init_effect = 1
        Tween.Instance:RotateZ(self.pointer_transform.gameObject, 790, 0.5, function() self:init_effect_callback() end)
    end
    BaseEffectView.New({effectId = 20090, time = nil, callback = fun})

    local fun2 = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.button.transform)
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, 0, -1000)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        if SceneManager.Instance:CurrentMapId() ~= TreasuremapManager.Instance.model.map_id then
            effectView:SetActive(false)
        end
    end
    self.button_effect = BaseEffectView.New({effectId = 20119 , time = nil, callback = fun2})

    -----------------------------
    EventMgr.Instance:AddListener(event_name.treasuremap_compass_update, self._update)
    EventMgr.Instance:AddListener(event_name.scene_load, self._change_map)

    self:ClearMainAsset()
end

function TreasuremapCompassView:init_effect_callback()
    self.init_effect = 2
end

function TreasuremapCompassView:update(angle, dis)
    if self.transform ~= nil then
        if self.init_effect == 0 then
            -- init_effect = 1
            -- tween:DoRotation(pointer_transform.gameObject, Vector3(0, 0, 0), Vector3(0, 0, 790), 0.5, "ui_treasuremap_compass.init_effect_callback")
        elseif self.init_effect == 2 then
            -- pointer_transform.rotation = Quaternion.identity
            -- pointer_transform:Rotate(Vector3(0, 0, angle))
            local tween_time = 0.5
            if dis < 150 then
                tween_time = 0.1
            elseif dis < 800 then
                tween_time = 0.3
            elseif dis < 1500 then
                tween_time = 0.5
            end
            local tween_angle_start = self.pointer_transform.rotation.eulerAngles.z
            local tween_angle_end = angle
            if tween_angle_start > 180 then
                tween_angle_start = tween_angle_start - 360
            end
            if tween_angle_start > 90 and tween_angle_end < 0 then
                tween_angle_end = tween_angle_end + 360
            elseif tween_angle_start < -90 and tween_angle_end > 0 then
                tween_angle_start = tween_angle_start + 360
            end
            self.pointer_transform.rotation = Quaternion.identity
            self.pointer_transform:Rotate(Vector3(0, 0, tween_angle_start))
            Tween.Instance:RotateZ(self.pointer_transform.gameObject, tween_angle_end, tween_time)
        end

        if dis > 800 then
            self.distanceimage.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_henyuan")
        else
            self.distanceimage.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_henjin")
        end

        if dis < 100 then
            self:show_text(true)
        else
            self:show_text(false)
            local angle = angle + 45 / 2
            if angle < 0 then angle = angle + 360 end
            if angle < 45 then -- 北
                self.directionimage1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_bei")
                self.directionimage1.gameObject:SetActive(true)
                self.directionimage2.gameObject:SetActive(false)
            elseif angle < 90 then -- 西北
                self.directionimage1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_xi")
                self.directionimage2.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_bei")
                self.directionimage1.gameObject:SetActive(true)
                self.directionimage2.gameObject:SetActive(true)
            elseif angle < 135 then -- 西
                self.directionimage1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_xi")
                self.directionimage1.gameObject:SetActive(true)
                self.directionimage2.gameObject:SetActive(false)
            elseif angle < 180 then -- 西南
                self.directionimage1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_xi")
                self.directionimage2.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_nan")
                self.directionimage1.gameObject:SetActive(true)
                self.directionimage2.gameObject:SetActive(true)
            elseif angle < 225 then -- 南
                self.directionimage1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_nan")
                self.directionimage1.gameObject:SetActive(true)
                self.directionimage2.gameObject:SetActive(false)
            elseif angle < 270 then -- 东南
                self.directionimage1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_dong")
                self.directionimage2.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_nan")
                self.directionimage1.gameObject:SetActive(true)
                self.directionimage2.gameObject:SetActive(true)
            elseif angle < 315 then -- 东
                self.directionimage1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_dong")
                self.directionimage1.gameObject:SetActive(true)
                self.directionimage2.gameObject:SetActive(false)
            elseif angle < 360 then -- 东北
                self.directionimage1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_dong")
                self.directionimage2.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_str, "Str2_bei")
                self.directionimage1.gameObject:SetActive(true)
                self.directionimage2.gameObject:SetActive(true)
            end
        end
    end
end

function TreasuremapCompassView:button_click()
    if SceneManager.Instance:CurrentMapId() == TreasuremapManager.Instance.model.map_id then
        local func = function()
            TreasuremapManager.Instance:Send13602()
        end
        SceneManager.Instance.sceneElementsModel.collection.callback = func
        SceneManager.Instance.sceneElementsModel.collection:Show({msg = TI18N("挖宝中..."), time = 1000})
    else
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_Transport(TreasuremapManager.Instance.model.map_id, 0, 0)
    end
end

function TreasuremapCompassView:update_time()
    local time = TreasuremapManager.Instance.model.compass_end_time - BaseUtils.BASE_TIME
    if time < 0 then
        MainUIManager.Instance:CloseTreasuremapCompassView()
    elseif self.time_txt ~= nil then
        self.time_txt.text = BaseUtils.formate_time_gap(time, ":", 0, BaseUtils.time_formate.MIN)
    end
end

function TreasuremapCompassView:change_map()
    if SceneManager.Instance:CurrentMapId() == TreasuremapManager.Instance.model.map_id then
        self:show_text(false)
    else
        self:show_text(true)
    end
end

function TreasuremapCompassView:show_text(show)
    if self.treasureimage == nil then return end

    if show then
        self.treasureimage.gameObject:SetActive(false)
        self.directionimage1.gameObject:SetActive(false)
        self.directionimage2.gameObject:SetActive(false)
        self.distanceimage.gameObject:SetActive(false)
        self.image.gameObject:SetActive(false)
        self.pointer_transform.gameObject:SetActive(false)
        self.text.gameObject:SetActive(true)
        self.button:SetActive(true)

        if SceneManager.Instance:CurrentMapId() == TreasuremapManager.Instance.model.map_id then
            self.text.text = TI18N("就在此处")
            self.button.transform:FindChild("Text"):GetComponent(Text).text = TI18N("挖宝")

            if self.button_effect ~= nil then
                self.button_effect:SetActive(true)
            end
        else
            self.text.text = DataMap.data_list[TreasuremapManager.Instance.model.map_id].name
            self.button.transform:FindChild("Text"):GetComponent(Text).text = TI18N("传送")

            if self.button_effect ~= nil then
                self.button_effect:SetActive(false)
            end
        end
    else
        self.treasureimage.gameObject:SetActive(true)
        self.distanceimage.gameObject:SetActive(true)
        self.image.gameObject:SetActive(true)
        self.pointer_transform.gameObject:SetActive(true)
        self.text.gameObject:SetActive(false)
        self.button:SetActive(false)
    end
end