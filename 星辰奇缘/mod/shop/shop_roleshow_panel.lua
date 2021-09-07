-- @author zyh
-- @date 2017年8月4日

ShopRoleShowPanel = ShopRoleShowPanel or BaseClass(BasePanel)

function ShopRoleShowPanel:__init(model, parent)

    self.model = model
    self.parent = parent
    self.name = "ShopRoleShowPanel"

    self.resList = {
        {file = AssetConfig.shop_roleshow_panel, type = AssetType.Main}
        ,{file = AssetConfig.fashionBg,type = AssetType.Dep}
        -- ,{file = "prefabs/effect/15100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/15101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/15102.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/13100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/13101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/12100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/12101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/11100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/11101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/11102.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/11103.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/14100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/14101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/14100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/17100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        -- , {file = "prefabs/effect/17101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)


    self.extra = {inbag = false, nobutton = true}

    self.setting = {
        name = "ShopShowRole"
        ,orthographicSize = 0.55
        ,width = 251
        ,height = 251
        ,offsetY = -0.352
        ,offsetX = -0.02
        ,noDrag = true
    }
    self.previewComp = nil

    -- self.effectList = {}

    self.initPreviewComp = false



end

function ShopRoleShowPanel:__delete()

    self.OnHideEvent:Fire()

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ShopRoleShowPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_roleshow_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent,self.gameObject)
    self.transform = t

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.previewContainer = self.transform:Find("MainCon/PreviewContainer")

    self.bigBgImage = self.transform:Find("MainCon/Bg/Image"):GetComponent(Image)
    self.bigBgImage.sprite = self.assetWrapper:GetSprite(AssetConfig.fashionBg,"I18NFashion")

    self.showText = self.transform:Find("MainCon/Image/Text"):GetComponent(Text)

    self.closeButton = self.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    self.closeButton.onClick:AddListener(function() self:Hiden() end)
    self:OnOpen()
end

function ShopRoleShowPanel:ShowMyRole(modelData)
    if self.lastLooks ~= nil then
        local isLastLooks = self:CheckLooksName(self.lastLooks,modelData.looks)
        if isLastLooks == true then
            return
        end
    end
    local callback = function(composite)
        self:SetRawImage(composite)
    end


    local roledata = RoleManager.Instance.RoleData

    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback,self.setting,modelData)
    else
        -- self.previewComp:Reload(modelData, callback)
        self.previewComp:Show()
        self.previewComp:PlayMotion(FighterAction.Stand)
    end

    self.showText.text = string.format("成就点数大于<color='#00ff00'>%s点</color>可以购买",self.openArgs[2].achievement_limit[1].min)


end


function ShopRoleShowPanel:fight_effect(effectObjectData)

    local attackPos = self.last_tpose.transform.position

    local attackTransform = self.last_tpose.transform
    local tempStr = "prefabs/effect/%s.unity3d"
    tempStr = string.format(tempStr, tostring(effectObjectData.EffectId))

    local effect = self:GetPrefab(tempStr)

    if effect == nil then
        -- mod_notify.append_scroll_win(string.format("缺少特效资源:%s",tostring(effectObjectData.EffectId)))
    end

    local effectObject = GameObject.Instantiate(effect)
    -- table.insert(self.effectList, effectObject)

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

function ShopRoleShowPanel:bind_hand(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    if classes == 1 then

    elseif classes == 4 then
        local leffect = GameObject.Instantiate(effect)
        -- table.insert(self.effectList, leffect)
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

--绑武器
function ShopRoleShowPanel:bind_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    if classes == 1 then

    elseif classes == 4 then
        local leffect = GameObject.Instantiate(effect)
        -- table.insert(self.effectList, leffect)
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

function ShopRoleShowPanel:bind_right_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end

--绑左武器
function ShopRoleShowPanel:bind_left_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end

function ShopRoleShowPanel:bind_right_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end


function ShopRoleShowPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1.5, 1.5, 1)

    self.last_tpose = composite.tpose
    self.last_ad = composite.animationData
    self.animator = self.last_tpose:GetComponent(Animator)

    if self.has_belt then
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.Backward, 0))
    end

    self.previewContainer.gameObject:SetActive(true)

    composite:PlayMotion(FighterAction.Stand)

    -- self:PlayAction()

    -- local targetList = nil
    -- if RoleManager.Instance.RoleData.sex == 0 then --女
    --     targetList = CreateRoleManager.Instance.model.femaleEffectList
    -- else
    --     targetList = CreateRoleManager.Instance.model.maleEffectList
    -- end

    -- for i=1,#targetList do
    --    local ed = targetList[i]
    --     if ed.Classes == RoleManager.Instance.RoleData.classes then
    --         self:fight_effect(ed)
    --     end
    -- end
end


function ShopRoleShowPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()
    self:ShowMyRole(self.openArgs[1])
end

function ShopRoleShowPanel:OnHide()
    self:RemoveListeners()
    if self.timer_2 ~= nil then
        LuaTimer.Delete(self.timer_2)
        self.timer_2 = nil
    end

    if self.delayTimerId ~= nil then
        LuaTimer.Delete(self.delayTimerId)
        self.delayTimerId = nil
    end

    if self.animatorId ~= nil then
        LuaTimer.Delete(self.animatorId)
        self.animatorId = nil
    end

    if self.last_ad ~= nil and self.last_ad.stand_id ~= nil then
        if BaseUtils.isnull(self.animator) then
            return
        end
        self.animator:Play(string.format("Stand%s", self.last_ad.stand_id))
    end

    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end

end

function ShopRoleShowPanel:RemoveListeners()
end

function ShopRoleShowPanel:AddListeners()
end

function ShopRoleShowPanel:CheckLooksName(looks1,looks2)
    if #looks1 ~= #looks2 then
       return false
    end

    local dic_1 = {}
    local dic_2 = {}
    for i=1,#looks1 do
        local temp = looks1[1]
        dic_1[temp.looks_type] = temp
    end

    for i=1,#looks2 do
        local temp = looks2[1]
        dic_2[temp.looks_type] = temp
    end
    for k, v in pairs(looks1) do
        local temp = looks2[k]
        if temp.looks_mode ~= v.looks_mode or temp.looks_val ~= v.looks_val then
            return false
        end
    end
    return true
end

function ShopRoleShowPanel:PlayAction()
  -- local state_id = BaseUtils.GetShowActionId(RoleManager.Instance.RoleData.classes,RoleManager.Instance.RoleData.sex)

  --   if self.animatorId == nil then
  --    self.animatorId = LuaTimer.Add(80, function()
  --        self.animator:Play(tostring(state_id))
  --        self.delayTimerId = LuaTimer.Add(100, function () self:ActionDelay() end)
  --     end)
  --   end
end

function ShopRoleShowPanel:ActionDelay()
    local delay = self.animator:GetCurrentAnimatorStateInfo(0).length
    self.timer_2 = LuaTimer.Add(delay*1000, function() self:model_tick_end_callback() end)
end

function ShopRoleShowPanel:model_tick_end_callback()
    -- if self.has_init == false then
    --     return
    -- end
    -- self.timer_2 = id
    self:stop_timer_2()

    if self.last_ad ~= nil and self.last_ad.stand_id ~= nil then
        if BaseUtils.isnull(self.animator) then
            return
        end
        self.animator:Play(string.format("Stand%s", self.last_ad.stand_id))
    end
end

function ShopRoleShowPanel:stop_timer_2()
    if self.timer_2 ~= nil then
        LuaTimer.Delete(self.timer_2)
        self.timer_2 = 0
    end
end







