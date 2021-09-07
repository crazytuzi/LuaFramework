-- ------------------------------
-- 获取途径
-- hosr
-- ------------------------------
PreviewTips = PreviewTips or BaseClass(BasePanel)

function PreviewTips:__init(model)
    self.model = model
    self.name = "PreviewTips"
    self.path = "prefabs/ui/tips/previewtips.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
    }

    self.isShow = false
    self.height = 330
    self.previewComp = nil
    self.footEffect ={} 
    self.footTimer = {}
    ---
end

function PreviewTips:__delete()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    for i = 1, 3 do
        if self.footEffect[i] ~= nil then
            self.footEffect[i]:DeleteMe()
            self.footEffect[i] = nil
        end
        if self.footTimer[i] ~= nil then
            LuaTimer.Delete(self.footTimer[i])
        end
    end
end

function PreviewTips:Show(arge)
    self.isShow = true
    self.openArgs = arge
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
        self:UpdateInfo(self.openArgs.args, self.openArgs.height)
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function PreviewTips:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    -- if self.previewComp ~= nil then
    --     self.previewComp:Hide()
    -- end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    for i = 1, 3 do
        if self.footEffect[i] ~= nil then
            self.footEffect[i]:DeleteMe()
            self.footEffect[i] = nil
        end
        if self.footTimer[i] ~= nil then
            LuaTimer.Delete(self.footTimer[i])
        end
    end
    self.isShow = false
end

function PreviewTips:HideAllDesc()
    for i,tab in ipairs(self.buttons) do
        tab.descObj:SetActive(false)
    end
end

function PreviewTips:OnInitCompleted()
    self:UpdateInfo(self.openArgs.args, self.openArgs.height)
end

function PreviewTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "PreviewTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.model:Closetips() end)

    self.nameText = self.transform:Find("Name"):GetComponent(Text)

    self.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
end

function PreviewTips:UpdateInfo(args, itemHeight)
    self.itemHeight = itemHeight -- 依附的对象啊高度，用于计算位置
    -- self.height = count * 55
    -- self.height = self.height + 100
    -- self.height = math.max(self.itemHeight, self.height)

    self.rect.anchorMax = Vector2(0.5,0.5)
    self.rect.anchorMin = Vector2(0.5,0.5)
    self.rect.pivot = Vector2(0,0.5)
    -- self.rect.sizeDelta = Vector2(315, self.itemHeight)
    self.rect.sizeDelta = Vector2(315, self.height)
    self.rect.anchoredPosition = Vector2.zero

    -- local offsety = (self.itemHeight - self.height) / 2
    -- self.rect.anchoredPosition = Vector2(0, offsety)

    local type = args[1] or 0
    local id = args[2] or 0

    self.setting = self.setting or {
        name = "tips"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 300
        ,offsetY = -0.1
        ,noDrag = true
        ,offsetX = -0.04
    }

    if type == 1 then -- 翅膀
        local wingData = DataWing.data_base[id]
        self.nameText.text = wingData.name
        self.setting.offsetY = -0.1

        local modelData = {type = PreViewType.Wings, looks = {{looks_type = SceneConstData.looktype_wing, looks_val = wingData.wing_id}}}

        local callback = function(comp)
            comp.rawImage.transform:SetParent(self.transform)
            comp.rawImage.transform.localScale = Vector3.one
            comp.rawImage.transform.anchoredPosition = Vector2(0, 20)
        end
        if self.previewComp ~= nil then
            self.previewComp:Show()
            self.previewComp:Reload(modelData, callback)
        else
            self.previewComp = PreviewComposite.New(callback, self.setting, modelData)
        end
    elseif type == 2 then -- 其他
        local unitData = DataUnit.data_unit[id]
        self.nameText.text = unitData.name
        self.setting.offsetY = -0.5

        local modelData = {type = PreViewType.Npc, skinId = unitData.skin, animationId = unitData.animation_id, modelId = unitData.res, scale = 1.0, effects = unitData.effects}

        local callback = function(comp)
            comp.rawImage.transform:SetParent(self.transform)
            comp.rawImage.transform.localScale = Vector3.one
            comp.rawImage.transform.anchoredPosition = Vector2(0, 20)
            comp.tpose.transform.localRotation = Quaternion.Euler(Vector3(0,-40,0))
        end
        if self.previewComp ~= nil then
            self.previewComp:Show()
            self.previewComp:Reload(modelData, callback)
        else
            self.previewComp = PreviewComposite.New(callback, self.setting, modelData)

        end
    elseif type == 3 then -- 足迹
        local name = nil
        local DataAchieveShop = DataAchieveShop.data_list
        for i,v in pairs(DataAchieveShop) do
            if v.source_id == id then
                name = v.name
                break
            end
        end
        self.nameText.text = name
        for i = 1, 3 do
            if self.footEffect[i] ~= nil then
                self.footEffect[i]:DeleteMe()
                self.footEffect[i] = nil
            end
            if self.footTimer[i] ~= nil then
                LuaTimer.Delete(self.footTimer[i])
            end
            if self.footEffect[i] == nil then
                local fun = function(effectView)
                    local effectObject = effectView.gameObject
                    effectObject.name = "Effect"..i
                    effectObject.transform:SetParent(self.transform)
                    effectObject.transform.localScale = Vector3(0.4,0.4,0.4)
                    effectObject.transform.localPosition = Vector3(100 * i - 50 , 20*i-80, -400)
                    effectObject.transform.localRotation = Quaternion.Euler(340,0,0)
                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                    effectObject:SetActive(false)
                    self.footTimer[i] = LuaTimer.Add(500* i, 2000, function() 
                        effectObject:SetActive(false)
                        effectObject:SetActive(true)
                    end)
                end
                self.footEffect[i] = BaseEffectView.New({effectId = id, time = nil, callback = fun})

            end
        end
    end

    local maxHeight = math.max(self.model.itemTips.height, self.height)
    self.model.itemTips.transform.anchoredPosition = Vector2(0, maxHeight / 2 - self.model.itemTips.height / 2)
    self.transform.anchoredPosition = Vector2(0, maxHeight / 2 - self.height / 2)
end
