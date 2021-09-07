WeaponTposeLoader = WeaponTposeLoader or BaseClass()

function WeaponTposeLoader:__init(classes, sex, looks, callback, isShowEffect)
	self.classes = classes
	self.sexNum = sex
    self.sex = (sex == 1 and "male" or "female")
    self.looks = looks
    self.callback = callback
    self.isShowEffect = isShowEffect

    self.animator = nil

    self.weaponPath = ""
    self.weaponEffectPath = nil
    self.effectData = nil
    self.isSecondWeapon = false

    --  print("双手武器？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？")
    --  BaseUtils.dump(looks,"外观数据")
    -- print(debug.traceback())
    self:ApplyLooks(classes,sex,looks,callback)

    if self.weaponPath == "" then
        local looksVal = BaseUtils.default_weapon(self.classes, self.sexNum)
        self.weaponPath = string.format(SceneConstData.looksdefiner_playerweaponpath, looksVal)
        if self.classes == 7 then
            for k2,v2 in pairs(DataLook.data_secondweapon) do
                if v2.looks_val == tonumber(looksVal ) then
                    self.weaponSecondPath = string.format(SceneConstData.looksdefiner_playerweaponpath,v2.other_looks_val)
                    break
                end
            end
        end
    end

    self.loadCompleted = function()
        self:BuildWeapon()
    end

    local resources = {}

    -- self.weapon = CombatManager.Instance.objPool:PopUnit(self.weaponPath)
    self.weapon = GoPoolManager.Instance:Borrow(self.weaponPath, GoPoolType.Weapon)
    if self.weapon == nil then
        table.insert(resources, {file = self.weaponPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
    end

    if self.weaponSecondPath ~= nil then
        self.isSecond = true
        self.weapon2 = GoPoolManager.Instance:Borrow(self.weaponSecondPath, GoPoolType.Weapon)
        if self.weapon2 == nil then
            table.insert(resources, {file = self.weaponSecondPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
        end
    end




    if self.weaponEffectPath ~= nil then
        -- self.weaponEffect = CombatManager.Instance.objPool:PopUnit(self.weaponEffectPath)
        self.weaponEffect = GoPoolManager.Instance:Borrow(self.weaponEffectPath, GoPoolType.Effect)

        if self.weaponEffect == nil then
            table.insert(resources, {file = self.weaponEffectPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
        end

        if self.classes == SceneConstData.classes_gladiator or self.classes == SceneConstData.classes_sanctuary then
            if self.weaponEffectPath2 == nil then
                -- self.weaponEffect2 = CombatManager.Instance.objPool:PopUnit(self.weaponEffectPath)
                self.weaponEffect2 = GoPoolManager.Instance:Borrow(self.weaponEffectPath, GoPoolType.Effect)
            else
                self.weaponEffect2 = GoPoolManager.Instance:Borrow(self.weaponEffectPath2, GoPoolType.Effect)
            end

            if self.weaponEffect2 == nil then
                if self.weaponEffectPath2 == nil then
                    table.insert(resources, {file = self.weaponEffectPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
                else
                    table.insert(resources, {file = self.weaponEffectPath2, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
                end
            end
        end
    end


    if self.weaponSecondEffectPath ~= nil then
        -- self.weaponEffect = CombatManager.Instance.objPool:PopUnit(self.weaponEffectPath)
        self.weaponSecondEffect = GoPoolManager.Instance:Borrow(self.weaponSecondEffectPath, GoPoolType.Effect)

        if self.weaponSecondEffect == nil then
            table.insert(resources, {file = self.weaponSecondEffectPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
        end
    end

    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources, self.loadCompleted)
end

function WeaponTposeLoader:ApplyLooks(classes, sex, looks, callback)
    for k, v in pairs(looks) do
        if v.looks_type == SceneConstData.looktype_weapon then -- 武器
            self.weaponPath = string.format(SceneConstData.looksdefiner_playerweaponpath, v.looks_val)
            if v.looks_mode ~= 0 then
                for k2,v2 in pairs(DataLook.data_secondweapon) do
                    if v.looks_mode == tonumber(v2.effectId) and v.looks_val == tonumber(v2.looks_val) then
                        self.otherModelId = v2.other_looks_effectId
                        self.weaponSecondPath = string.format(SceneConstData.looksdefiner_playerweaponpath,v2.other_looks_val)
                        break
                    end
                end

            else
                for k2,v2 in pairs(DataLook.data_secondweapon) do
                    if v2.looks_val == tonumber(v.looks_val) then
                        self.weaponSecondPath = string.format(SceneConstData.looksdefiner_playerweaponpath,v2.other_looks_val)
                        break
                    end
                end


            end
            -- print(string.format("<color='#00ff00'>这个武器的模型 %s</color>", v.looks_val))
            -- print(string.format("<color='#00ff00'>这个武器的特效 %s</color>", v.looks_mode))
            if v.looks_mode ~= 0 then
                local shenqi_effect = DataLook.data_weapon_effect[v.looks_mode]
                if shenqi_effect ~= nil then
                    local effectData = DataEffect.data_effect[shenqi_effect.effect_id1]
                    if effectData == nil then
                        print(string.format("<color='#00ff00'>effect_data 这个神器特效id数据没有啊 %s</color>", tostring(shenqi_effect.effect_id1)))
                    else
                        self.weaponEffectPath = string.format(AssetConfig.effect, effectData.res_id)
                        self.effectData = effectData
                    end

                    -- if shenqi_effect.effect_id2 ~= 0 then
                    --     local effectData = DataEffect.data_effect[shenqi_effect.effect_id2]
                    --     if effectData == nil then
                    --         print(string.format("<color='#00ff00'>effect_data 这个第二武器神器特效id数据没有啊 %s</color>", tostring(shenqi_effect.effect_id2)))
                    --     else
                    --         self.weaponEffectPath2 = string.format(AssetConfig.effect, effectData.res_id)
                    --         self.effectData2 = effectData
                    --     end
                    -- end
                else
                    local effectData = DataEffect.data_effect[v.looks_mode]
                    if effectData == nil then
                        print(string.format("<color='#00ff00'>effect_data 这个特效id数据没有啊 %s</color>", tostring(v.looks_mode)))
                    else
                        self.weaponEffectPath = string.format(AssetConfig.effect, effectData.res_id)
                        self.effectData = effectData
                    end
                end


                if self.otherModelId ~= nil then
                    local shenqi_effect2 = DataLook.data_weapon_effect[self.otherModelId]
                    if shenqi_effect2 ~= nil then
                         local effectData = DataEffect.data_effect[shenqi_effect2.effect_id1]
                         if effectData == nil then
                            print(string.format("<color='#00ff00'>effect_data 这个第二武器神器特效id数据没有啊 %s</color>", tostring(shenqi_effect2.effect_id1)))
                         else
                            self.weaponEffectPath2 = string.format(AssetConfig.effect, effectData.res_id)
                            self.effectData2 = effectData
                        end
                    else
                        local effectData = DataEffect.data_effect[self.otherModelId]
                        if effectData == nil then
                            print(string.format("<color='#00ff00'>effect_data 这个第二武器特效id数据没有啊 %s</color>", tostring(self.otherModelId)))
                        else
                            self.weaponEffectPath2 = string.format(AssetConfig.effect, effectData.res_id)
                            self.effectData = effectData
                        end
                    end
                end
            end
        end
    end
end

function WeaponTposeLoader:__delete()
    if not BaseUtils.is_null(self.weapon) then
        -- GameObject.Destroy(self.weapon)
        GoPoolManager.Instance:Return(self.weapon, self.weaponPath, GoPoolType.Weapon)
        self.weapon = nil
    end

    if not BaseUtils.is_null(self.weapon2) then
        GoPoolManager.Instance:Return(self.weapon2,self.weaponSecondPath, GoPoolType.Weapon)
        self.weapon2 = nil
    end

    if self.assetWrapper ~= nil then
    	self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if not BaseUtils.is_null(self.weaponEffect) then
        GoPoolManager.Instance:Return(self.weaponEffect, self.weaponEffectPath, GoPoolType.Effect)
        -- GameObject.Destroy(self.weaponEffect)
    end

    if not BaseUtils.is_null(self.weaponEffect2) then
        if self.weaponEffectPath2 == nil then
            GoPoolManager.Instance:Return(self.weaponEffect2, self.weaponEffectPath, GoPoolType.Effect)
        else
            GoPoolManager.Instance:Return(self.weaponEffect2, self.weaponEffectPath2, GoPoolType.Effect)
        end
    end

    self.weapon = nil
    self.weapon2 = nil
    self.weaponEffect = nil
    self.weaponEffect2 = nil
    self.animator = nil
    self.weaponEffectPath = nil
    self.effectData = nil
    self.weaponEffectPath2 = nil
    self.effectData2 = nil
    self.callback = nil
end

function WeaponTposeLoader:BuildWeapon()
    -- if self.classes == 7 then
    --     print(self.weaponSecondPath .. "加载后")
    -- end
    if self.assetWrapper == nil then return end

    if self.weapon == nil then
    	self.weapon = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.weaponPath))
    end

    if self.classes == SceneConstData.classes_gladiator or self.classes == SceneConstData.classes_sanctuary then
        if self.weapon2 == nil then
            if self.weaponSecondPath == nil then
    	       self.weapon2 = GameObject.Instantiate(self.weapon)
            elseif self.weaponSecondPath ~= nil then
                self.weapon2 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.weaponSecondPath))
            end
        end

	end

    self:BuildWeaponEffect()

    local meshNode = self.weapon.transform
    BaseUtils.ChangeShaderForOldVersion(meshNode.renderer.material)
    local isOtherWeapon = false
    if self.weaponSecondPath ~= nil then
        isOtherWeapon = false
    end
    self.callback(self.weapon, self.weapon2, { weaponPath = self.weaponPath, weaponPath2 = self.weaponSecondPath,weaponEffect = self.weaponEffect, weaponEffect2 = self.weaponEffect2, weaponEffectPath = self.weaponEffectPath, weaponEffectPath2 = self.weaponEffectPath2 },isOtherWeapon)

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function WeaponTposeLoader:BuildWeaponEffect()
    if self.isShowEffect == nil then
        self.isShowEffect = true
    end
    if self.weaponEffectPath ~= nil and self.isShowEffect then
        if self.weaponEffect == nil then
            self.weaponEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.weaponEffectPath))
        end
        self.weaponEffect.transform:SetParent(self.weapon.transform)
        self.weaponEffect.transform.localPosition = Vector3(0, 0, 0)
        self.weaponEffect.transform.localRotation = Quaternion.identity

        if self.classes == SceneConstData.classes_gladiator  or self.classes == SceneConstData.classes_sanctuary then
            if self.weaponEffect2 == nil then
                if self.weaponEffectPath2 == nil then
                    self.weaponEffect2 = GameObject.Instantiate(self.weaponEffect)
                else
                    self.weaponEffect2 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.weaponEffectPath2))
                end
            end
            self.weaponEffect2.transform:SetParent(self.weapon2.transform)
            self.weaponEffect2.transform.localPosition = Vector3(0, 0, 0)
            self.weaponEffect2.transform.localRotation = Quaternion.identity
        end
    end
end
