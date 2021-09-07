-- 角色加翅膀
MixRoleWingLoader = MixRoleWingLoader or BaseClass()

function MixRoleWingLoader:__init(classes, sex, looks, callback, noWing, layer, noWeapon, showHalo, effectSetting)

    self.classes = classes
    self.sex = sex
    self.looks = looks
    self.callback = callback
    self.noWing = noWing  -- 不需要翅膀
    self.noWeapon = noWeapon  -- 不需要武器
    self.showHalo = showHalo
    self.effectSetting = effectSetting or {}

    self.layer = layer
    if self.layer == nil then self.layer = "ModelPreview" end

    self.roleTpose = nil
    self.roleAnimationData = nil
    self.headTpose = nil
    self.headAnimationData = nil
    self.weaponTpose = nil
    self.weaponTpose2 = nil
    self.weaponLoader = nil
    self.wingTpose = nil
    self.wingAnimationData = nil
    self.wingLoader = nil
    self.beltTpose = nil
    self.beltLoader = nil
    self.headSurbaseTpose = nil
    self.headSurbaseLoader = nil
    self.otherLoaderCount = 0
    self.roleLoader = RoleTposeLoader.New(self.classes, self.sex, self.looks, function(animationData, tpose, headAnimationData, headTpose)
        self:OnRoleTposeLoaded(animationData, tpose, headAnimationData, headTpose) end)
end

function MixRoleWingLoader:__delete()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
    if self.roleLoader ~= nil then
        self.roleLoader:DeleteMe()
        self.roleLoader = nil
    end
    if self.wingLoader ~= nil then
        self.wingLoader:DeleteMe()
        self.wingLoader = nil
    end
    if self.weaponLoader ~= nil then
        self.weaponLoader:DeleteMe()
        self.weaponLoader = nil
    end
    if self.beltLoader ~= nil then
        self.beltLoader:DeleteMe()
        self.beltLoader = nil
    end
    if self.headSurbaseLoader ~= nil then
        self.headSurbaseLoader:DeleteMe()
        self.headSurbaseLoader = nil
    end

    self.roleTpose = nil
    self.roleAnimationData = nil
    self.headTpose = nil
    self.headAnimationData = nil
    self.weaponTpose = nil
    self.weaponTpose2 = nil
    self.weaponLoader = nil
    self.wingTpose = nil
    self.wingAnimationData = nil
    self.wingLoader = nil
    self.beltTpose = nil
    self.beltLoader = nil
    self.headSurbaseTpose = nil
    self.headSurbaseLoader = nil
    self.callback = nil
end

function MixRoleWingLoader:OnRoleTposeLoaded(animationData, tpose, headAnimationData, headTpose)
    self.roleTpose = tpose
    self.roleAnimationData = animationData
    self.headTpose = headTpose
    self.headAnimationData = headAnimationData
    self.animationData = animationData

    if not self.noWeapon then
        self.weaponLoader = WeaponTposeLoader.New(self.classes, self.sex, self.looks, function(tpose, tpose2) self:OnWeaponTposeLoaded(tpose, tpose2) end, self.effectSetting.weaponEffect)
    else
        self:LoadOthers()
    end

    -- if self.callback ~= nil then
    --         self.callback(self.roleTpose, self.animationData, self.headTpose, self.headAnimationData)
    --     end

end

function MixRoleWingLoader:OnWeaponTposeLoaded(tpose, tpose2)
    if BaseUtils.is_null(self.roleTpose) then
        if tpose ~= nil then GameObject.Destroy(tpose) end
        if tpose2 ~= nil then GameObject.Destroy(tpose2) end
        return
    end

    self.weaponTpose = tpose
    self.weaponTpose2 = tpose2

    if self.weaponTpose ~= nil then
        Utils.ChangeLayersRecursively(self.weaponTpose.transform, self.layer)
    end

    if self.weaponTpose2 ~= nil then
        Utils.ChangeLayersRecursively(self.weaponTpose2.transform, self.layer)
    end

    local point = nil
    if self.classes == SceneConstData.classes_ranger or self.classes == SceneConstData.classes_devine then
        point = BaseUtils.GetChildPath(self.roleTpose.transform, "Bip_L_Weapon")
    else
        point = BaseUtils.GetChildPath(self.roleTpose.transform, "Bip_R_Weapon")
    end

    local t = self.weaponTpose:GetComponent(Transform)
    self.weaponTpose.name = "Mesh_Weapon"
    t:SetParent(self.roleTpose.transform:Find(point))
    t.localPosition = Vector3.zero
    t.localRotation = Quaternion.identity
    t.localScale = Vector3.one

    if self.weaponTpose2 ~= nil then
        local point = BaseUtils.GetChildPath(self.roleTpose.transform, "Bip_L_Weapon")
        local t2 = self.weaponTpose2:GetComponent(Transform)
        self.weaponTpose2.name = "Mesh_Weapon"
        t2:SetParent(self.roleTpose.transform:Find(point))
        t2.localPosition = Vector3.zero
        t2.localRotation = Quaternion.identity
        t2.localScale = Vector3.one

    end

    self:LoadOthers()
end

function MixRoleWingLoader:LoadOthers()
    local loadWing = false
    local loadBelt = false
    local loadHeadSurbase = false
    local loadHalo = false
    self.initAll = false
    self.haloEffectPath = nil
    for k, v in pairs(self.looks) do
        if v.looks_type == SceneConstData.looktype_wing then -- 翅膀
            loadWing = true
        elseif v.looks_type == SceneConstData.lookstype_belt then -- 腰饰
            loadBelt = true
        elseif v.looks_type == SceneConstData.lookstype_headsurbase then -- 头饰
            loadHeadSurbase = true
        elseif v.looks_type == SceneConstData.lookstype_halo then -- 光环
            local base = DataEffect.data_effect[v.looks_val]
            if base ~= nil then
                loadHalo = true
                self.haloEffectPath = string.format(AssetConfig.effect, base.res_id)
            end
        end
    end

    self.otherLoaderCount = 0
    if loadWing and not self.noWing then
        self.otherLoaderCount = self.otherLoaderCount + 1
        self.wingLoader = WingTposeLoader.New(self.looks, function(tpose, animationData) self:OnWingTposeLoaded(tpose, animationData) self.otherLoaderCount = self.otherLoaderCount - 1 self:CheckCompelete() end, self.layer, self.effectSetting.wingEffect)
    end

    if loadBelt and not self.noBelt then
        self.otherLoaderCount = self.otherLoaderCount + 1
        self.beltLoader = BeltTposeLoader.New(self.looks, function(tpose) self:OnBeltTposeLoaded(tpose) self.otherLoaderCount = self.otherLoaderCount - 1 self:CheckCompelete() end,  self.layer)
    end

    if loadHeadSurbase and not self.noHeadSurbase then
        self.otherLoaderCount = self.otherLoaderCount + 1
        self.headSurbaseLoader = HeadSurbaseTposeLoader.New(self.looks, function(tpose) self:OnHeadSurbaseTposeLoaded(tpose) self.otherLoaderCount = self.otherLoaderCount - 1 self:CheckCompelete() end, self.layer)
    end


    if loadHalo and self.showHalo then
        self:LoadHalo()
    end
    self.initAll = true
    self:CheckCompelete()
end

function MixRoleWingLoader:CheckCompelete()

    if self.otherLoaderCount <= 0 and self.initAll == true then
        if self.callback ~= nil then
            if not BaseUtils.is_null(self.roleTpose) then
                self.callback(self.roleTpose, self.animationData, self.headTpose, self.headAnimationData)
            end
        end
    end
end

function MixRoleWingLoader:OnWingTposeLoaded(tpose, animationData)
    if BaseUtils.is_null(self.roleTpose) then
        if wingTpose ~= nil then GameObject.Destroy(wingTpose) end
        return
    end

    self.wingTpose = tpose
    self.wingAnimationData = animationData

    local path = BaseUtils.GetChildPath(self.roleTpose.transform, "bp_wing")
    local bind = self.roleTpose.transform:Find(path)
    if bind ~= nil then
        local t = self.wingTpose:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        t:Rotate(Vector3(90, 270, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, self.layer)
    end
end

function MixRoleWingLoader:OnBeltTposeLoaded(tpose)
    if BaseUtils.is_null(self.roleTpose) then
        if tpose ~= nil then GameObject.Destroy(tpose) end
        return
    end

    self.beltTpose = tpose

    local path = BaseUtils.GetChildPath(self.roleTpose.transform, "bp_wing")
    local bind = self.roleTpose.transform:Find(path)
    if bind ~= nil then
        local t = self.beltTpose:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        t:Rotate(Vector3(90, 270, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, self.layer)
    end
end


function MixRoleWingLoader:OnHeadSurbaseTposeLoaded(tpose)
    if BaseUtils.is_null(self.roleTpose) then
        if tpose ~= nil then GameObject.Destroy(tpose) end
        return
    end

    self.headSurbaseTpose = tpose

    local path = BaseUtils.GetChildPath(self.roleTpose.transform, "Bip_Head")
    local bind = self.roleTpose.transform:Find(path)
    if bind ~= nil then
        local t = self.headSurbaseTpose:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        t:Rotate(Vector3(90, 0, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, self.layer)
    end
end

function MixRoleWingLoader:LoadHalo()
    if self.haloEffectPath == nil then
        return
    end

    self.haloEffect = GoPoolManager.Instance:Borrow(self.haloEffectPath, GoPoolType.Effect)
    local resources = {}
    if self.haloEffect == nil then
        self.otherLoaderCount = self.otherLoaderCount + 1
        table.insert(resources, {file = self.haloEffectPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
    end
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources, function() self:OnLoadHaloComplete()  self.otherLoaderCount = self.otherLoaderCount - 1 self:CheckCompelete() end)
end

function MixRoleWingLoader:OnLoadHaloComplete()
    if self.haloEffect == nil then
        self.haloEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.haloEffectPath))
    end

    Utils.ChangeLayersRecursively(self.haloEffect.transform, self.layer)
    self.haloEffect.transform:SetParent(self.roleTpose.transform)
    self.haloEffect.transform.localPosition = Vector3(0, 0, 0)
    self.haloEffect.transform.localRotation = Quaternion.identity

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end