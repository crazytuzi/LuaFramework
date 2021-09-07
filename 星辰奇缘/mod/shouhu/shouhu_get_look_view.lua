-- -------------------
-- 获得新守护外观
-- 2016/11/19
-- zzl
-- -------------------
ShouhuGetLookView = ShouhuGetLookView or BaseClass(BasePanel)

function ShouhuGetLookView:__init(model)
    -- self.texture = AssetConfig.getpet_textures

    self.resList = {
        {file = AssetConfig.shouhu_get_look_view, type = AssetType.Main},
        {file = AssetConfig.shouhu_texture, type = AssetType.Dep},
        {file  =  AssetConfig.totembg, type  =  AssetType.Dep},
    }

    self.model = model
    self.listener = function(texture, modleList) self:OnTposeLoad(texture, modleList) end
    self.callback = nil
    self.timerId = 0
    self.rotateId = 0

    self.setting = {
        name = "ShouhuGetLookViewPreview"
        ,orthographicSize = 0.75
        ,width = 682
        ,height = 600
        ,offsetY = -0.4
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil
    self.hasInit = false
end

function ShouhuGetLookView:__delete()
    self.hasInit = false
    if self.skillSlot ~= nil then
        self.skillSlot:DeleteMe()
        self.skillSlot = nil
    end

    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function ShouhuGetLookView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_get_look_view))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, -800)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseGetWakeUpLookWindow() end)
    local Panel1 = self.transform:FindChild("Panel1"):GetComponent(Button)
    Panel1.onClick:AddListener(function()
        self:Destroy()
    end)

    self.title = self.transform:Find("Main/Title").gameObject
    self.nextTitle = self.transform:Find("Main/NextTitle").gameObject
    self.halo = self.transform:Find("Main/Halo").gameObject
    self.rawImg = self.transform:Find("Main/RawImage").gameObject
    self.rawImg:SetActive(false)

    self.transform:Find("Main/Halo"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")
    self.halo:SetActive(true)

    self.WakeUpIcon1 = self.transform:Find("Main/WakeUpIcon1").gameObject
    self.WakeUpIcon2 = self.transform:Find("Main/WakeUpIcon2").gameObject
    self.WakeUpIcon3 = self.transform:Find("Main/WakeUpIcon3").gameObject
    self.WakeUpIconBg1Rect = self.transform:Find("Main/WakeUpIcon1"):GetComponent(RectTransform)
    self.WakeUpIconBg2Rect = self.transform:Find("Main/WakeUpIcon2"):GetComponent(RectTransform)
    self.WakeUpIconBg3Rect = self.transform:Find("Main/WakeUpIcon3"):GetComponent(RectTransform)
    self.WakeUpIcon1Rect = self.transform:Find("Main/WakeUpIcon1/Image"):GetComponent(RectTransform)
    self.WakeUpIcon2Rect = self.transform:Find("Main/WakeUpIcon2/Image"):GetComponent(RectTransform)
    self.WakeUpIcon3Rect = self.transform:Find("Main/WakeUpIcon3/Image"):GetComponent(RectTransform)
    self.SkillCon = self.transform:Find("Main/SkillCon").gameObject
    self.SlotCon = self.transform:Find("Main/SkillCon/SlotCon")
    self.TxtSkillName = self.transform:Find("Main/SkillCon/TxtSkillName"):GetComponent(Text)
    self.TxtSkillDesc = self.transform:Find("Main/SkillCon/TxtSkillDesc"):GetComponent(Text)
    self.name = self.transform:Find("Main/Name"):GetComponent(Text)
    self.name.text = ""

    self.lookData = self.openArgs.data
    self.isNext = self.openArgs.isNext
    self.callback = self.openArgs.callback

    self.WakeUpIcon1:SetActive(false)
    self.WakeUpIcon2:SetActive(false)
    self.WakeUpIcon3:SetActive(false)
    if self.lookData.quality == 2 then
        self.WakeUpIcon1:SetActive(true)
    elseif self.lookData.quality == 3 then
        self.WakeUpIcon2:SetActive(true)
    elseif self.lookData.quality == 4 then
        self.WakeUpIcon3:SetActive(true)
    end

    self.hasInit = true

    if self.isNext ~= true then
        Tween.Instance:ValueChange(180, 50, 0.3, nil, LeanTweenType.linear, function(v)
                                if  self.hasInit == false then
                                    return
                                end
                                self.WakeUpIconBg1Rect.sizeDelta = Vector2(v, v)
                                self.WakeUpIconBg2Rect.sizeDelta = Vector2(v, v)
                                self.WakeUpIconBg3Rect.sizeDelta = Vector2(v, v)
                            end)
        Tween.Instance:ValueChange(180, 40, 0.3, nil, LeanTweenType.linear, function(v)
                                if  self.hasInit == false then
                                    return
                                end
                                self.WakeUpIcon1Rect.sizeDelta = Vector2(v, v)
                                self.WakeUpIcon2Rect.sizeDelta = Vector2(v, v)
                                self.WakeUpIcon3Rect.sizeDelta = Vector2(v, v)
                            end)
    else
        self.WakeUpIconBg1Rect.sizeDelta = Vector2(50, 50)
        self.WakeUpIconBg2Rect.sizeDelta = Vector2(50, 50)
        self.WakeUpIconBg3Rect.sizeDelta = Vector2(50, 50)
        self.WakeUpIcon1Rect.sizeDelta = Vector2(40, 40)
        self.WakeUpIcon2Rect.sizeDelta = Vector2(40, 40)
        self.WakeUpIcon3Rect.sizeDelta = Vector2(40, 40)
    end

    local baseData = DataShouhu.data_guard_base_cfg[self.lookData.base_id]
    self.name.text = ColorHelper.color_item_name(baseData.quality , baseData.name)
    self.transform:Find("Main/ImgClasses"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. baseData.classes)

    -- local tempQuality = self.lookData.quality == self.model.wakeUpMaxQuality and self.model.wakeUpMaxQuality - 1 or self.lookData.quality
    local skillList = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.lookData.base_id, self.model.wakeUpMaxQuality)].qualitySkills
    local skillId = 0
    for k, v in pairs(skillList) do
        if v[2] == self.lookData.quality then
            skillId = v[1]
            break
        end
    end
    if skillId > 0 then
        self.SkillCon:SetActive(true)
        local skillData = DataSkill.data_skill_guard[string.format("%s_1", skillId)]
        self.skillSlot = SkillSlot.New()
        UIUtils.AddUIChild(self.SlotCon, self.skillSlot.gameObject)
        self.skillSlot:SetAll(Skilltype.shouhuskill, {id = skillData.id, icon = skillData.icon, quality = self.lookData.quality})
        self.skillSlot.gameObject:SetActive(true)
        self.TxtSkillName.text = string.format(TI18N("新技能：%s"), skillData.name)
        self.TxtSkillDesc.text = skillData.desc
    else
        self.SkillCon:SetActive(false)
    end
    self:ShowHaloLight()
    self:ShowPreview()

    if self.isNext == true then
        self.nextTitle:SetActive(true)
        self.title:SetActive(false)
    else
        self.nextTitle:SetActive(false)
        self.title:SetActive(true)
    end

    -- self.timerId = LuaTimer.Add(3000, function() self:Destroy() end) d
end

function ShouhuGetLookView:ShowHaloLight()
    self.halo:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function ShouhuGetLookView:Rotate()
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function ShouhuGetLookView:ShowPreview()
    self.name.text = self.openArgs.name
    local data = {type = PreViewType.Shouhu, skinId = self.lookData.skin, modelId = self.lookData.model, animationId = self.lookData.animation, scale = 0.7}
    self:LoadPreview(data)
end

function ShouhuGetLookView:PlayRun()
    if self.animator ~= nil then
        self.animator:Play(string.format("Move%s", DataAnimation.data_npc_data[self.lookData.animation].move_id))
    end
end

function ShouhuGetLookView:PlayStand()
    if self.animator ~= nil then
        self.animator:Play(string.format("Stand%s", DataAnimation.data_npc_data[self.lookData.animation].stand_id))
    end
end

function ShouhuGetLookView:LoadPreview(modelData)
    self.rawImg:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function ShouhuGetLookView:SetRawImage(composite)
    SoundManager.Instance:Play(230)
    self.previewComp = composite
    local image = composite.rawImage
    image.transform:SetParent(self.rawImg.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3.zero
    self.rawImg:SetActive(true)
    self.animator = composite.tpose:GetComponent(Animator)
    if self.isNext then
        self.previewComp.tpose.transform.localRotation = Quaternion.Euler(0, 0, 0)
        self:PlayStand()
    else
        self.previewComp.tpose.transform.localRotation = Quaternion.Euler(0, -45, 0)
        self:PlayRun()
    end
end

function ShouhuGetLookView:Destroy()
    if self.callback ~= nil then
        self.callback()
    end
    self.model:CloseGetWakeUpLookWindow()
end
