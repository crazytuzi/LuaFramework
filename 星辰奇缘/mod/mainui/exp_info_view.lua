-- 主界面 经验
ExpInfoView = ExpInfoView or BaseClass(BaseView)

function ExpInfoView:__init()
    self.model = model
	self.resList = {
        {file = AssetConfig.exparea, type = AssetType.Main}
    }

    self.name = "ExpInfoView"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    self.text = nil
    self.slider = nil

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self:LoadAssetBundleBatch()
end

function ExpInfoView:ShowCanvas(bool)
    if self.gameObject == nil then
        return
    end

    self.gameObject:SetActive(bool)
    -- if bool then
        -- BaseUtils.ChangeLayersRecursively(self.transform, "UI")
        -- if self.raycaster == nil then
        --     self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        -- end
        -- if self.raycaster ~= nil then
        --     self.raycaster.enabled = true
        -- end
    -- else
        -- BaseUtils.ChangeLayersRecursively(self.transform, "Water")
        -- if self.raycaster == nil then
        --     self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        -- end
        -- if self.raycaster ~= nil then
        --     self.raycaster.enabled = false
        -- end
    -- end
end

function ExpInfoView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ExpInfoView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exparea))
    self.gameObject.name = "ExpInfoView"
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

    self.text = self.transform:Find("Main/Value"):GetComponent(Text)
    self.slider = self.transform:Find("Main/Slider"):GetComponent(Slider)

    -----------------------------
    self:update()
    EventMgr.Instance:AddListener(event_name.role_exp_change, self._update)

    self:AssetClearAll()
end

function ExpInfoView:update()
    local roleData = RoleManager.Instance.RoleData
	if roleData == nil then return end

    local levup_data = DataLevup.data_levup[roleData.lev]
    local tovalue = 1
    if levup_data ~= nil then
        local max_exp = levup_data.exp
        tovalue = roleData.exp / max_exp
        if (roleData.lev == 89 or roleData.lev == 109) and tovalue >= 1 then
            self.text.text = string.format(TI18N("%.1f%% 可跃升"), math.floor(tovalue * 1000)/10)
        else
            self.text.text = string.format("%.1f%%", math.floor(tovalue * 1000)/10)
        end
    else
        self.text.text = TI18N("满级")
    end

    if tovalue > 1 then
        self.slider.value = 1
    else
        local fun = function(value) self.slider.value = value end
        if self.slider.value == 1 then self.slider.value = 0 end

        if tovalue > self.slider.value or self.slider.value == 0 then
            Tween.Instance:ValueChange(self.slider.value, tovalue, 0.5, nil, LeanTweenType.linear, fun)
        else
            Tween.Instance:ValueChange(self.slider.value, 1, 0.5, function() self:update() end, LeanTweenType.linear, fun)
        end
    end
end