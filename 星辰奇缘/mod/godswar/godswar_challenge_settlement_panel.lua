-- 諸神挑戰结算界面
GodsWarChallengeSettlementPanel = GodsWarChallengeSettlementPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function GodsWarChallengeSettlementPanel:__init(model)
    self.model = model
    self.name = "GodsWarChallengeSettlementPanel"
    self.resList = {
        {file = AssetConfig.godswarchallengesettlementpanel, type = AssetType.Main}
        ,{file = AssetConfig.starchallenge_textures, type = AssetType.Dep}
        ,{file = AssetConfig.zone_textures, type = AssetType.Dep}
        ,{file = AssetConfig.attr_icon,type = AssetType.Dep}
        ,{file = AssetConfig.godswarres,type = AssetType.Dep}
        ,{file = AssetConfig.levelbreakeffect1,type = AssetType.Dep}
        ,{file = AssetConfig.levelbreakeffect2,type = AssetType.Dep}
    }

    -----------------------------------------

    self.okButton = nil
    self.toggle1 = nil
    self.toggle2 = nil

    self.itemList = {}
    self.slider_tweenId = {}
    self.headLoaderList = {}
    self.light = nil
    self.rotateId = 0
    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._Update = function() self:Update() end
end

function GodsWarChallengeSettlementPanel:__delete()
    self:OnHide()
    if self.showTitleId ~= nil then
        LuaTimer.Delete(self.showTitleId)
        self.showTitleId = nil
    end

    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    self:ClearDepAsset()
end

function GodsWarChallengeSettlementPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarchallengesettlementpanel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    -- self.CloseButton = self.transform:Find("Main/CloseButton")
    -- self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel").gameObject:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.mainTransform = self.transform:Find("Main")

    self.RoleBg1 = self.mainTransform:Find("RoleBg1")
    self.RoleBg2 = self.mainTransform:Find("RoleBg2")
    self.Result = self.mainTransform:Find("Result"):GetComponent(Image)
    self.Result.gameObject:SetActive(false)
    for i=1,2 do
        self.RoleBg1:FindChild("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect1, "LevelBreakEffect1")
    end

    for i=1,4 do
        self.RoleBg2:FindChild("Image"..i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect2, "LevelBreakEffect2")
    end

    self.previewParent = self.mainTransform:FindChild("Preview")

    self.okButton = self.mainTransform:FindChild("OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:okButtonClick() end)

    self.toggle1 = self.mainTransform:FindChild("Toggle1"):GetComponent(Toggle)
    self.toggle1.onValueChanged:AddListener(function(on) self:ontoggle1change(on) end)

    self.toggle2 = self.mainTransform:FindChild("Toggle2"):GetComponent(Toggle)
    self.toggle2.onValueChanged:AddListener(function(on) self:ontoggle2change(on) end)

    --self.text = self.mainTransform:FindChild("Text"):GetComponent(Text)
    --self.arrowImage = self.mainTransform:FindChild("ArrowImage")
    --self.cupText = self.mainTransform:FindChild("CupText"):GetComponent(Text)
    --self.cupText.gameObject:SetActive(false)
    --self.cupImage = self.mainTransform:FindChild("CupImage")
    self.TimerText = self.mainTransform:FindChild("Timer/Text"):GetComponent(Text)


    self.itemList = {}
    local container = self.mainTransform:FindChild("Panel")
    for i = 1, 5 do
        -- local item = self.mainTransform:FindChild(string.format("Panel/Item%s", i))
        local item = container:GetChild(i - 1)
        item.gameObject.name = "Item" .. i
        local self_item = item:FindChild("Self")
        local self_head = self_item:FindChild("HeadImage/Image")
        local self_head_default = self_item:FindChild("HeadImage/Default")
        local self_classes = self_item:FindChild("ClassesImage")
        local self_name = self_item:FindChild("NameText"):GetComponent(Text)
        local self_type = self_item:FindChild("TypeText"):GetComponent(Text)
        local self_value = self_item:FindChild("ValueText"):GetComponent(Text)
        local self_expslider = self_item:FindChild("ExpSlider"):GetComponent(Slider)

        table.insert(self.itemList, { self_item = self_item, self_head = self_head, self_head_default = self_head_default, self_classes = self_classes, self_name = self_name, self_type = self_type, self_value = self_value, self_expslider = self_expslider})
    end

    self:OnShow()
end

function GodsWarChallengeSettlementPanel:Close()
    --self:OnHide()
    self.model:CloseSettlePanel()
end

function GodsWarChallengeSettlementPanel:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.data = self.openArgs[1]
    end

    if self.data ~= nil then
        self:Update()
    end
end

function GodsWarChallengeSettlementPanel:OnHide()
    for _,value in ipairs(self.slider_tweenId) do
        if value[1] ~= nil then
            Tween.Instance:Cancel(value[1])
        end
        if value[2] ~= nil then
            Tween.Instance:Cancel(value[2])
        end
    end

    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end

    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function GodsWarChallengeSettlementPanel:Update()
    --BaseUtils.dump(self.data,"self.data")
    self.result = self.data.result
    self.matesData = self.data.mates
    self.times = self.data.times
    self.max_dmg = 0
    self.max_heal = 0

    for _, value in ipairs(self.matesData) do
        if value.total_dmg > self.max_dmg then
            self.max_dmg = value.total_dmg
        end
        if value.total_heal > self.max_heal then
            self.max_heal = value.total_heal
        end
    end

    if self.max_dmg == 0 then
        self.max_dmg = 1
    end
    if self.max_heal == 0 then
        self.max_heal = 1
    end
    self:Update_info()
    self:Update_type()
    self:Update_Model()
end

function GodsWarChallengeSettlementPanel:Update_info()
    local roleData = RoleManager.Instance.RoleData

    for i = 1, 5 do
        local item = self.itemList[i]
        item.self_head_default.gameObject:SetActive(false)
        item.self_head.gameObject:SetActive(true)
        item.self_head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.matesData[i].classes, self.matesData[i].sex))

        item.self_classes:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, string.format("ClassesIcon_%s", self.matesData[i].classes))
        item.self_name.text = self.matesData[i].name
    end

    if self.showTitleId ~= nil then
        LuaTimer.Delete(self.showTitleId)
    end
    self.showTitleId = LuaTimer.Add(600, function() self:showTitle() end)
end

function GodsWarChallengeSettlementPanel:Update_type()
    for i = 1, 5 do
        local item = self.itemList[i]

        if self.slider_tweenId[i] ~= nil then
            if self.slider_tweenId[i][1] ~= nil then
                Tween.Instance:Cancel(self.slider_tweenId[i][1])
            end
            if self.slider_tweenId[i][2] ~= nil then
                Tween.Instance:Cancel(self.slider_tweenId[i][2])
            end
        end

        self.slider_tweenId[i] = {}
        if self.toggle1.isOn then
            local self_data = self.matesData[i]
            item.self_type.text = TI18N("伤害量")
            item.self_value.text = ""
            item.self_expslider.value = 0

            local fun1 = function(value) item.self_expslider.value = value * 0.9 end
            local slider_value = self_data.total_dmg / self.max_dmg
            if slider_value < 0.01 then
                slider_value = 0.01
            end
            self.slider_tweenId[i][1] = Tween.Instance:ValueChange(item.self_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun1).id
        else
            local self_data = self.matesData[i]
            item.self_type.text = TI18N("治疗量")
            item.self_value.text = ""
            item.self_expslider.value = 0

            local fun1 = function(value) item.self_expslider.value = value * 0.9 end
            local slider_value = self_data.total_heal / self.max_heal
            if slider_value < 0.01 then
                slider_value = 0.01
            end
            self.slider_tweenId[i][1] = Tween.Instance:ValueChange(item.self_expslider.value, slider_value, 0.6, nil, LeanTweenType.linear, fun1).id
        end
    end

    self.TimerText.text = BaseUtils.formate_time_gap(self.times, ":", 0, BaseUtils.time_formate.MIN)
end

function GodsWarChallengeSettlementPanel:okButtonClick()
    --self:Close()
    self.model:CloseSettlePanel()
end

function GodsWarChallengeSettlementPanel:ontoggle1change(on)
    if on then
        self.toggle1.isOn = true
        self.toggle2.isOn = false
    else
        self.toggle1.isOn = false
        self.toggle2.isOn = true
    end
    self:Update_type()
end

function GodsWarChallengeSettlementPanel:ontoggle2change(on)
    if on then
        self.toggle1.isOn = false
        self.toggle2.isOn = true
    else
        self.toggle1.isOn = true
        self.toggle2.isOn = false
    end
    self:Update_type()
end

function GodsWarChallengeSettlementPanel:showTitle()
    if self.result == 1 then
        self.Result.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarres, "GodswarChallengeVictory")
    elseif self.result == 0 then
        self.Result.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarres, "GodswarChallengeDefeat")
    end
    self.Result.gameObject:SetActive(true)
    self.Result.transform.localScale = Vector3.one * 3
    Tween.Instance:Scale(self.Result.gameObject, Vector3.one, 1, function() end, LeanTweenType.easeOutElastic)
end

function GodsWarChallengeSettlementPanel:Update_Model()
    local roledata = RoleManager.Instance.RoleData
    local modelData = {type = PreViewType.Role, classes = roledata.classes, sex = roledata.sex, looks = SceneManager.Instance:MyData().looks}

    if self.previewComp == nil then
        local setting = {
            name = "previewComp"
            ,layer = "UI"
            ,parent = self.previewParent.transform
            ,localRot = Vector3(0, 0, 0)
            ,localPos = Vector3(0, -102, -220)
            ,localScale = Vector3(280,280,280)
            ,usemask = false
            ,sortingOrder = 21
        }
        self.previewComp = PreviewmodelComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
end