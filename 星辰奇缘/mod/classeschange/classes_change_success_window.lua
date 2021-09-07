-- 职业转换成功
-- ljh 2016.10.10
ClassesChangeSuccessWindow = ClassesChangeSuccessWindow or BaseClass(BaseDramaPanel)

function ClassesChangeSuccessWindow:__init()
    self.effectPath = "prefabs/effect/20014.unity3d"
    self.texture = AssetConfig.getpet_textures

    self.resList = {
        {file = AssetConfig.classeschangesuccesswindow, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main}
        ,{file = self.texture, type = AssetType.Dep}
        , {file = "prefabs/effect/15100.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/15101.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/15102.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/13100.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/13101.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/12100.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/12101.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/11100.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/11101.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/11102.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/11103.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/14100.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/14101.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/14100.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/17100.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/17101.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/18100.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/18101.unity3d", type = AssetType.Main}
        , {file = "prefabs/effect/18102.unity3d", type = AssetType.Main}
        , {file = AssetConfig.getpetbtn, type = AssetType.Dep}
        ,{file = AssetConfig.getpethalo1, type = AssetType.Dep}
        ,{file = AssetConfig.getpetlight1, type = AssetType.Dep}
    }

    self.actionover = true
    self.meshId = 0
    self.previewLoaded = false
    self.previewShowed = false
    self.listener = function(texture, modleList) self:OnTposeLoad(texture, modleList) end
    self.click = function() self:Destroy() end
    self.clickClose = function() self:Close() end
    self.playaction = function() self:PlayAction() end

    self.step = 0

    self.callback = nil

    self.timeId = 0
    self.timeId2 = 0
    self.rotateId = 0

    self.previewComp = nil
    self.current_classes = nil
    self.current_sex = nil

    self.weaponSetting = { 10005, 10102, 10203, 10304, 10405, 10506, 10701 }
    self.maleDressSetting = { 51001, 51003, 51005, 51007, 51009, 51011, 51013}
    self.femaleDressSetting = { 51002, 51004, 51006, 51008, 51010, 51012 ,51014}

    self.maleShowTimes = {2.5, 2.4, 2.533, 3.533, 3.167, 3.167} 
    self.femaleShowTimes = {3.367,3.167,2.533, 3.533, 3.167, 3.167} 
    self.maleSound = {204, 208, 212, 210, 206, 206, 206}
    self.femaleSound = {205, 209, 212, 210, 206, 206, 206}
    self.maleTalkSound = {300, 310, 320, 330, 340, 350, 360}
    self.femaleTalkSound = {301, 311, 321, 331, 341, 351,361}
end

function ClassesChangeSuccessWindow:__delete()
	if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    if self.effect ~= nil then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function ClassesChangeSuccessWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.classeschangesuccesswindow))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, -177, -400)
    self.effect:SetActive(false)

    self.title = self.transform:Find("Main/Title").gameObject
    self.halo = self.transform:Find("Main/Halo").gameObject
    self.light = self.transform:Find("Main/Light").gameObject
    self.button = self.transform:Find("Main/Button").gameObject
    self.preview = self.transform:Find("Main/Preview").gameObject
    self.button:SetActive(false)
    self.halo:SetActive(false)
    self.light:SetActive(false)
    self.title:SetActive(false)

    self.halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")
    self.button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")
    self.button:GetComponent(Button).onClick:AddListener(self.click)
end

function ClassesChangeSuccessWindow:OnInitCompleted()
    self:SetData()
end

function ClassesChangeSuccessWindow:SetData()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.current_classes = self.openArgs[1]
        self.current_sex = RoleManager.Instance.RoleData.sex
    end
    self:Next()
end

function ClassesChangeSuccessWindow:Next()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.step = self.step + 1
    if self.step == 1 then
        self:ShowTitle()
    elseif self.step == 2 then
        self:ShowHaloLight()
        self:ShowModel()
    elseif self.step == 3 then
        self:ShowButton()
    end
end

function ClassesChangeSuccessWindow:ShowTitle()
    self.title.transform.localScale = Vector3.one * 0.2
    self.title:SetActive(true)
    Tween.Instance:Scale(self.title, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function ClassesChangeSuccessWindow:ShowHaloLight()
    self.halo:SetActive(true)
    self.light:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function ClassesChangeSuccessWindow:ShowModel()
    -- self.preview:SetActive(true)
    local weapon = self.weaponSetting[self.current_classes]
    local dress = 0
    if self.current_sex == 1 then
    	dress = self.maleDressSetting[self.current_classes]
    else
    	dress = self.femaleDressSetting[self.current_classes]
    end

    local _looks = {}
    table.insert(_looks, { looks_type = SceneConstData.looktype_weapon, looks_val = weapon, looks_mode = 0 })
    table.insert(_looks, { looks_type = SceneConstData.looktype_dress, looks_val = dress, looks_mode = 0 })

    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end
    local setting = {
        name = "ClassesChangeSuccessWindow"
        ,orthographicSize = 0.45
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    local modelData = {type = PreViewType.Role, classes = self.current_classes, sex = self.current_sex, looks = _looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    end

    self.timeId = LuaTimer.Add(500, function() self:Next() end)
end

function ClassesChangeSuccessWindow:on_model_build_completed(composite)
	local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    self.last_tpose = composite.tpose
    self.last_tpose.transform.localScale = Vector3(1,1,1)
    self.last_ad = composite.animationData
    self.animator = self.last_tpose:GetComponent(Animator)
    self.animator.cullingMode = AnimatorCullingMode.AlwaysAnimate

    self:PlayModelAction()

    local targetList = nil
	if self.current_sex == 0 then --女
	    targetList = CreateRoleManager.Instance.model.femaleEffectList
	else
	    targetList = CreateRoleManager.Instance.model.maleEffectList
	end
	for i=1,#targetList do
	   local ed = targetList[i]
	    if ed.Classes == self.current_classes then
	        self:fight_effect(ed)
	    end
	end
end

function ClassesChangeSuccessWindow:ShowButton()
    self.button.transform.localScale = Vector3.one * 3
    self.button:SetActive(true)
    Tween.Instance:Scale(self.button, Vector3.one, 1, function() self:BeginCountDown() end, LeanTweenType.easeOutElastic)
end

function ClassesChangeSuccessWindow:Rotate()
    self.light.transform:Rotate(Vector3(0, 0, 0.5))
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function ClassesChangeSuccessWindow:Close()
    HomeManager.Instance.model:CloseGetHomeWindow()
end

function ClassesChangeSuccessWindow:Destroy()
    if self.countDownId ~= nil then
        LuaTimer.Delete(self.countDownId)
        self.countDownId = nil
    end
    if self.callback ~= nil then
        self.callback()
    end
end

function ClassesChangeSuccessWindow:BeginCountDown()
    self.effect:SetActive(true)
    -- self.countDownId = LuaTimer.Add(3000, function() self:Destroy() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(self.clickClose)
end

-----------------
-- 模型动作相关
-----------------
function ClassesChangeSuccessWindow:ActionDelay()
    local delay = self.animator:GetCurrentAnimatorStateInfo(0).length
    self.timeId2 = LuaTimer.Add(delay*1000, function() self:model_tick_end_callback() end)
end

function ClassesChangeSuccessWindow:stop_timer_2()
    if self.timeId2 ~= 0 and self.timeId2 ~= nil then
        LuaTimer.Delete(self.timeId2)
        self.timeId2 = 0
    end
end

-- 播放模型动作
function ClassesChangeSuccessWindow:PlayModelAction()
    self:stop_timer_2()

	self:star_timer_2()
end

function ClassesChangeSuccessWindow:star_timer_2()

    local state_id = BaseUtils.GetShowActionId(self.current_classes, self.current_sex)
    self.animator:Play(tostring(state_id))

    LuaTimer.Add(100, function () self:ActionDelay() end)

    local sound_id = 0
    local talk_id = 0
    if self.current_sex == 0 then --女
        sound_id = self.femaleSound[self.current_classes]
        talk_id = self.femaleTalkSound[self.current_classes]
    else
        sound_id = self.maleSound[self.current_classes]
        talk_id = self.maleTalkSound[self.current_classes]
    end
    SoundManager.Instance:Play(sound_id)
    SoundManager.Instance:PlayCombatHiter(talk_id)
end

--回到站立动作
function ClassesChangeSuccessWindow:model_tick_end_callback()
    if self.has_init == false then
        return
    end
    self:stop_timer_2()

    if self.last_ad ~= nil and self.last_ad.stand_id ~= nil then
        if BaseUtils.isnull(self.animator) then
            return
        end
        self.animator:Play(string.format("Stand%s", self.last_ad.stand_id))
    end
end

-- 动作特效逻辑
local effectList = {}
function ClassesChangeSuccessWindow:fight_effect(effectObjectData)
    local attackPos = self.last_tpose.transform.position

    local attackTransform = self.last_tpose.transform
    local tempStr = "prefabs/effect/%s.unity3d"
    tempStr = string.format(tempStr, tostring(effectObjectData.EffectId))

    local effect = self:GetPrefab(tempStr)

    if effect == nil then
        -- mod_notify.append_scroll_win(string.format("缺少特效资源:%s",tostring(effectObjectData.EffectId)))
    end

    local effectObject = GameObject.Instantiate(effect)
    table.insert(effectList, effectObject)

    if effectObjectData.type == 0 then
        return
    end
    if effectObjectData.EffectTargetPoint == EffectTargetPoint.Weapon then
        self:bind_weapon(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.Origin  then
        effectObject.transform:SetParent(attackTransform)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.LHand  then
        self:bind_hand(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.RHand then
        self:bind_hand(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.LWeapon then
        self:bind_left_weapon(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.RWeapon then
        self:bind_right_weapon(self.last_tpose, effectObject,effectObjectData.Classes)
    else
        effectObject.transform:SetParent(attackTransform)
    end

    effectObject.transform.localScale = Vector3(1, 1, 1)
    effectObject.transform.localPosition = Vector3(0, 0, 0)
    effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
    effectObject:SetActive(true)
end

--绑左武器
function ClassesChangeSuccessWindow:bind_left_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end

function ClassesChangeSuccessWindow:bind_right_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end

--绑武器
function ClassesChangeSuccessWindow:bind_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    if classes == 1 then

    elseif classes == 4 then
        local leffect = GameObject.Instantiate(effect)
        table.insert(effectList, leffect)
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
        leffect.transform:SetParent(attackTransform:Find(weaponPoint))
        leffect.transform.localPosition = Vector3.zero
        leffect.transform.localRotation = Quaternion.identity
        leffect.transform.localScale = Vector3(1.0,1.0,1.0)
    elseif classes == 3 then

    elseif classes == 5 then
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    else
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    end
end

--绑手
function ClassesChangeSuccessWindow:bind_hand(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    if classes == 1 then

    elseif classes == 4 then
        local leffect = GameObject.Instantiate(effect)
        table.insert(effectList, leffect)
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Hand")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Hand")
        leffect.transform:SetParent(attackTransform:Find(weaponPoint))
        leffect.transform.localPosition = Vector3.zero
        leffect.transform.localRotation = Quaternion.identity
        leffect.transform.localScale = Vector3(1.0,1.0,1.0)
    elseif classes == 3 then

    elseif classes == 5 then
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Hand")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    else
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Hand")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    end
end