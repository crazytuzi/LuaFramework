BeltTposeLoader = BeltTposeLoader or BaseClass()

function BeltTposeLoader:__init(looks, callback)
    self.looks = looks
    self.callback = callback

    self.tpose = nil

    self.modelPath = ""
    self.effectPath = nil

    self.belData = nil

    for k, v in pairs(looks) do
        if v.looks_type == SceneConstData.lookstype_belt then -- 腰饰
            -- self.modelPath = string.format(SceneConstData.looksdefiner_beltpath, v.looks_val)
            local belData = DataFashion.data_base[v.looks_val]
            if belData == nil then 
                print(string.format("<color='#00ff00'>fashion_data 这个时装id数据没有啊 %s</color>", v.looks_val))
            else
                self.modelPath = string.format(SceneConstData.looksdefiner_beltpath, belData.model_id)
                
                self.belData = belData

                if v.looks_mode ~= 0 then
                    local effectData = DataEffect.data_effect[v.looks_mode]
                    if effectData == nil then
                        print(string.format("<color='#00ff00'>effect_data 这个特效id数据没有啊 %s</color>", v.looks_mode))
                    else
                        self.effectPath = string.format(AssetConfig.effect, effectData.res_id)
                        self.effectData = effectData
                    end
                end
            end
        end
    end

    if self.modelPath == "" then
        return 
    end

    self.loadCompleted = function()
        self:BuildTpose()
    end

    local resources = {}

    -- self.tpose = CombatManager.Instance.objPool:PopUnit(self.modelPath)
    self.tpose = GoPoolManager.Instance:Borrow(self.modelPath, GoPoolType.Surbase)
    if self.tpose == nil then
        table.insert(resources, {file = self.modelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
    end
    
    if self.effectPath ~= nil then
        -- self.effect = CombatManager.Instance.objPool:PopUnit(self.effectPath)
        self.effect = GoPoolManager.Instance:Borrow(self.effectPath, GoPoolType.Effect)
        if self.effect == nil then
            table.insert(resources, {file = self.effectPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
        end
    end

    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources, self.loadCompleted)
end

function BeltTposeLoader:__delete()
    if not BaseUtils.is_null(self.tpose) then
        -- GameObject.Destroy(self.tpose)
        GoPoolManager.Instance:Return(self.tpose, self.modelPath, GoPoolType.Surbase)
    end
    self.tpose = nil
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if not BaseUtils.is_null(self.effect) then
        GoPoolManager.Instance:Return(self.effect, self.effectPath, GoPoolType.Effect)
        -- GameObject.Destroy(self.effect)
    end

    self.tpose = nil
    self.effect = nil
    self.callback = nil
end

function BeltTposeLoader:BuildTpose()
    if self.assetWrapper == nil then return end
    
    if self.tpose == nil then
        self.tpose = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.modelPath))
        self.tpose.transform:FindChild("surbase_tpose").gameObject.name = "Mesh_Belt"
    end

    self:BuildEffect()

    local meshNode = self.tpose.transform:FindChild("Mesh_Belt")
    BaseUtils.ChangeShaderForOldVersion(meshNode.renderer.material)

    self.callback(self.tpose, self.belData, { modelPath = self.modelPath, effect = self.effect, effectPath = self.effectPath })

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function BeltTposeLoader:BuildEffect()
    if self.effectPath ~= nil then
        if self.effect == nil then
            self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
        end
        self.effect.transform:SetParent(self.tpose.transform)
        self.effect.transform.localPosition = Vector3(0, 0, 0)
        self.effect.transform.localScale = Vector3(1, 1, 1)
        self.effect.transform.localRotation = Quaternion.identity
    end
end
