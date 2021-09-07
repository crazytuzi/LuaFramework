TposeEffectLoader = TposeEffectLoader or BaseClass()

function TposeEffectLoader:__init(gameObject, tpose, effects, callback)
	self.gameObject = gameObject
	self.tpose = tpose
	self.effects = effects
	self.callback = callback

	self.effectdict = {}
	for i=1,#effects do
        self:CreateEffect(effects[i].effect_id)
    end
end

function TposeEffectLoader:CreateEffect(effectId)
    if self.tpose == nil then
        return
    end

    local effectData = DataEffect.data_effect[effectId]
    if effectData == nil then
        Log.Error(string.format("effect_data 这个特效id数据没有啊 %s", effectId))
        return
    end

    local callback = function(effect)
        if not BaseUtils.is_null(self.gameObject) and not BaseUtils.is_null(self.tpose) then
            self:BindEffect(effectData, self.tpose, effect.gameObject)

            if self.callback then self.callback(effect.gameObject) end
        else
            GameObject.DestroyImmediate(effect.gameObject)
            effect.gameObject = nil
        end
    end
    local effect = BaseEffectView.New({ effectId = effectData.res_id, callback = callback })
    local key = tostring(effectData.id)
    if self.effectdict[key] == nil then
        self.effectdict[key] = {effect = effect, effectId = effectData.id}
    end
end

function TposeEffectLoader:BindEffect(effectData, tpose, effect)
    if effectData.mounter == EffectDataMounter.Custom then
        local mounter = BaseUtils.GetChildPath(tpose.transform, effectData.mounter_str)
        if mounter ~= "" then
            local m = tpose.transform:Find(mounter)
            if m ~= nil then
                effect.transform:SetParent(m)
                self:EffectSetting(effect)
            end
        end
    elseif effectData.mounter == EffectDataMounter.Origin then
        effect.transform:SetParent(tpose.transform)
        self:EffectSetting(effect)
    elseif effectData.mounter == EffectDataMounter.TopOrigin then
        effect.transform:SetParent(self.gameObject.transform)
        self:EffectSetting(effect)
        effect.transform.localPosition = Vector3(0, 0.75, 0)
    elseif effectData.mounter == EffectDataMounter.Weapon then
        local lmounter = BaseUtils.GetChildPath(tpose.transform, "Bip_L_Weapon")
        local rmounter = BaseUtils.GetChildPath(tpose.transform, "Bip_R_Weapon")
        if lmounter ~= "" or rmounter ~= "" then
            local clone = false
            if lmounter ~= "" then
                local lm = tpose.transform:Find(lmounter)
                if lm ~= nil then
                    effect.transform:SetParent(lm)
                    self:EffectSetting(effect)
                    clone = true
                end
            end
            if rmounter ~= "" then
                local rm = tpose.transform:Find(rmounter)
                if rm ~= nil then
                    -- if clone  then
                    --     local reffect = nil
                    --     if #effectlist > 1 then
                    --         reffect = effectlist[2]
                    --     else
                    --         reffect = GameObject.Instantiate(effect)
                    --         table.insert(effectlist, reffect)
                    --     end
                    --     reffect.transform:SetParent(rm)
                    --     self:EffectSetting(reffect)
                    -- else
                        effect.transform:SetParent(rm)
                        self:EffectSetting(effect)
                    -- end
                end
            end
        else
            effect.transform:SetParent(tpose.transform)
            self:EffectSetting(effect)
        end
    else
        local mounterPath = nil
        if effectData.mounter == EffectDataMounter.Wing then
            mounterPath = BaseUtils.GetChildPath(tpose.transform, "bp_wing")
        elseif effectData.mounter == EffectDataMounter.WingL1 then
            -- 看以后需求改
            mounterPath = BaseUtils.GetChildPath(tpose.transform, "bp_wing")
        else
            mounterPath = BaseUtils.GetChildPath(tpose.transform, "bp_wing")
        end
        if mounterPath ~= nil then
            local mounter = tpose.transform:Find(mounterPath)
            if mounter ~= nil then
                effect.transform:SetParent(mounter)
                self:EffectSetting(effect)
            end
        end
    end
end

function TposeEffectLoader:EffectSetting(effect)
    effect.transform.localScale = Vector3(1, 1, 1)
    effect.transform.localPosition = Vector3(0, 0, 0)
    effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effect.transform, "Model")
    effect:SetActive(true)
end

function TposeEffectLoader:__delete()
    if self.effectdict ~= nil then
        for k,v in pairs(self.effectdict) do
            if v ~= nil then
                v.effect:DeleteMe()
            end
        end
        self.effectdict = nil
    end
end
