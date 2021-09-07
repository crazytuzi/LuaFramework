-- 模型预览组合件(没有renderTexture)
PreviewmodelComposite = PreviewmodelComposite or BaseClass()

function PreviewmodelComposite:__init(callback, setting, modelData,effectSetting)
    self.callback = callback
    self.setting = setting
    self.effectSetting = effectSetting or {}
    self.modelData = modelData
    self.type = modelData.type

    self.name = setting.name or "Unknown"
    self.fadeTime = 0.1 -- 过渡动作过渡时间
    self.sortingOrder = setting.sortingOrder ~= nil and setting.sortingOrder or nil
    self.parent = setting.parent
    self.usemask = setting.usemask
    self.localPos = setting.localPos or Vector3(0, 0, -500)
    self.localRot = setting.localRot or Vector3(0, 180, 0)
    self.localScale = setting.localScale
    self.noDrag = setting.noDrag or false
    self.layer = setting.layer or "ModelPreview"

    self.tpose = nil
    self.animationData = nil
    self.headAnimationData = nil
    self.rawImage = nil
    self.cameraObj = nil
    self.render = nil
    self.animator = nil
    self.cachemotion = nil --缓存动作，等待加载完播放

    self.count = 1

    self.isshow = false

    self.loader = nil


    self.lastPostion = Vector3(0, 0, 0)

    -- 不需要拖动
    if self.setting ~= nil and not self.setting.noDrag and self.parent ~= nil then
        if self.parent.gameObject:GetComponent(UIDragBehaviour) == nil then
            local dragBehaviour = self.parent.gameObject:AddComponent(UIDragBehaviour)
            dragBehaviour.onBeginDrag = function(data)
                self.lastPostion = data.position
            end
            dragBehaviour.onDrag = function(data)
                self:OnTposeDrag(data)
            end
        end
    end

    self:BuildTpose(false)
end

function PreviewmodelComposite:__delete()
    if self.textId ~= nil then
        TimerManager.Delete(self.textId)
    end

    if not BaseUtils.isnull(self.tpose) then
        GameObject.DestroyImmediate(self.tpose)
        self.tpose = nil
    end

    if not BaseUtils.isnull(self.tpose2) then
        GameObject.DestroyImmediate(self.tpose_2)
        self.tpose_2 = nil
    end

    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
    end

    if self.effectLoader ~= nil then
        self.effectLoader:DeleteMe()
        self.effectLoader = nil
    end

    self.callback = nil
    self.setting = nil
    self.effectSetting = nil
    self.modelData = nil
    self.animationData = nil
    self.rawImage = nil
    self.cameraObj = nil
    self.render = nil
    self.lastPostion = nil
end

function PreviewmodelComposite:OpenDrag(bool)
    if bool then
    else
    end
end

function PreviewmodelComposite:BuildTpose(IsReLoad)
    if not BaseUtils.isnull(self.tpose) then
        GameObject.DestroyImmediate(self.tpose)
        self.tpose = nil
    end

    if not BaseUtils.isnull(self.tpose2) then
        GameObject.DestroyImmediate(self.tpose_2)
        self.tpose_2 = nil
    end
    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
    end
    self.tpose = nil
    self.animator = nil
    if self.modelData.type == PreViewType.Npc then
        local callback = function(newTpose, animationData)
            self:OnNpcLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = NpcTposeLoader.New(self.modelData.skinId, self.modelData.modelId, self.modelData.animationId, self.modelData.scale, callback)
    elseif self.modelData.type == PreViewType.Shouhu then
        local callback = function(newTpose, animationData)
            self:OnNpcLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = NpcTposeLoader.New(self.modelData.skinId, self.modelData.modelId, self.modelData.animationId, self.modelData.scale, callback)
    elseif self.modelData.type == PreViewType.Role then
        local transform_data = nil
        if self.modelData.isTransform then -- 是否显示变身效果
            for k,v in pairs(self.modelData.looks) do
                if v.looks_type == SceneConstData.looktype_transform then -- 变身
                    -- print("SceneConstData.looktype_transform")
                    transform_data = DataTransform.data_transform[v.looks_val]
                    if transform_data == nil then
                        print(string.format("不存在的变身id %s", v.looks_val))
                        return
                    end
                end
            end
        end

        if transform_data ~= nil then -- 有变身效果
            local callback = function(newTpose, animationData)
                self:OnNpcLoaded(newTpose, animationData, IsReLoad)
            end
            self.loader = NpcTposeLoader.New(transform_data.skin, transform_data.res, transform_data.animation_id, 1, callback)
        else -- 无变身效果
            local callback = function(newTpose, animationData)
                self:OnRoleLoaded(newTpose, animationData, IsReLoad)
            end
            self.loader = MixRoleWingLoader.New(self.modelData.classes, self.modelData.sex, self.modelData.looks, callback, self.modelData.noWing, "UI", self.modelData.noWeapon, self.modelData.showHalo, self.effectSetting)
        end
    elseif self.modelData.type == PreViewType.Pet then
        local callback = function(newTpose, animationData, headTpose, headAnimationData)
            self.headAnimationData = headAnimationData
            self:OnNpcLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = NpcTposeLoader.New(self.modelData.skinId, self.modelData.modelId, self.modelData.animationId, self.modelData.scale, callback)
    elseif self.modelData.type == PreViewType.Wings then
        local callback = function (newTpose, animationData)
            self:OnWingsLoaded(newTpose, animationData, IsReLoad)
        end 
        self.loader = WingTposeLoader.New(self.modelData.looks, callback, "ModelPreview",self.effectSetting.wingEffect)
    elseif self.modelData.type == PreViewType.Ride then
        local callback = function(newTpose, animationData)
            self:OnRideLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = RideTposeLoader.New(self.modelData.classes, self.modelData.sex, self.modelData.looks, callback)
    elseif self.modelData.type == PreViewType.Weapon then
        local callback = function (newTpose, animationData)
            self:OnWeaponLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = WeaponTposeLoader.New(self.modelData.classes, self.modelData.sex,self.modelData.looks, callback, self.effectSetting.weaponEffect)
    elseif self.modelData.type == PreViewType.Home then
        local callback = function(newTpose, animationData)
            self:OnHomeLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = HomeTposeLoader.New(self.modelData.skinId, self.modelData.modelId, self.modelData.animationId, self.modelData.scale, callback)
    elseif self.modelData.type == PreViewType.HeadSurbase then
        local callback = function(newTpose, animationData)
            self:OnHeadSurbaseLoaded(newTpose, headSurbaseData, modelData)
        end
        self.loader = HeadSurbaseTposeLoader.New(self.modelData.looks, callback)
    end
end

function PreviewmodelComposite:OnNpcLoaded(newTpose, animationData, IsReLoad)
    -- if self.tpose ~= nil then
    --     -- GameObject.Destroy(self.tpose)
    --     GameObject.Destroy(self.tpose)
    -- end
    self.tpose = newTpose
    self.animationData = animationData
    if self.usemask then
        Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    else
        Utils.ChangeLayersRecursively(self.tpose.transform, self.layer)
    end
    if self.modelData ~= nil and self.modelData.scale ~= nil then
        self.tpose.transform.localScale = Vector3.one*self.modelData.scale
    elseif result.scale ~= nil then
        self.tpose.transform.localScale = Vector3.one * result.scale
    end
    self.tpose.name = "PreviewTpose_" .. self.name .. "_" .. self.count
    -- self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.localRotation = Quaternion.identity
    self.tpose.transform:Rotate(self.localRot)

    -- print(IsReLoad)
    -- print("是不是？？？？")
    -- if not IsReLoad then
        self:BindModel()
    -- end

    if self.modelData ~= nil and self.modelData.effects ~= nil then
        local callback = function(effectObject)
            if not BaseUtils.isnull(self.tpose) then
                Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
            end
        end
        self.effectLoader = TposeEffectLoader.New(self.tpose, self.tpose, self.modelData.effects, callback)
    end

    self.isshow = true
    if self.callback ~= nil then
        self.callback(self)
    end
    if self.cachemotion ~= nil then
        self:PlayAnimation(self.cachemotion)
        self.cachemotion = nil
    end
end

-- 回调函数可能还有其它字段，用到就加上去
function PreviewmodelComposite:OnRoleLoaded(newTpose, animationData, IsReLoad)
    -- if self.tpose ~= nil then
    --     -- GameObject.Destroy(self.tpose)
    --     GameObject.Destroy(self.tpose)
    -- end
    self.tpose = newTpose
    self.animationData = animationData

    if self.usemask then
        Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    else
        Utils.ChangeLayersRecursively(self.tpose.transform, self.layer)
    end
    self.tpose.name = "PreviewTpose_" .. self.name .. "_" .. self.count
    -- self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.localRotation = Quaternion.identity
    self.tpose.transform:Rotate(self.localRot)
    if self.modelData ~= nil and self.modelData.scale ~= nil then
        self.tpose.transform.localScale = Vector3(self.modelData.scale, self.modelData.scale, self.modelData.scale)
    end
    -- if not IsReLoad then
        self:BindModel()
    -- end
    self:BindEffect()
    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewmodelComposite:OnRideLoaded(newTpose, animationData, IsReLoad)
    -- if self.tpose ~= nil then
    --     -- GameObject.Destroy(self.tpose)
    --     GameObject.Destroy(self.tpose)
    -- end
    self.tpose = newTpose
    self.animationData = animationData

    if self.usemask then
        Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    else
        Utils.ChangeLayersRecursively(self.tpose.transform, self.layer)
    end
    self.tpose.name = "PreviewTpose_" .. self.name .. "_" .. self.count
    -- self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.localRotation = Quaternion.identity
    self.tpose.transform:Rotate(self.localRot)
    if self.modelData ~= nil and self.modelData.scale ~= nil then
        self.tpose.transform.localScale = Vector3(self.modelData.scale, self.modelData.scale, self.modelData.scale)
    end
    -- if not IsReLoad then
        self:BindModel()
    -- end
    self:BindEffect()
    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewmodelComposite:OnWingsLoaded(newTpose, animationData, IsReLoad)
    -- if self.tpose ~= nil then
    --     -- GameObject.DestroyImmediate(self.tpose)
    --     GameObject.Destroy(self.tpose)
    -- end
    self.tpose = newTpose
    self.animationData = animationData

    if self.usemask then
        Utils.ChangeLayersRecursively(self.tpose.transform, "UI")
    else
        Utils.ChangeLayersRecursively(self.tpose.transform, self.layer)
    end
    self.tpose.name = "PreviewTpose_" .. self.name .. "_" .. self.count
    -- self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.localRotation = Quaternion.identity
    self.tpose.transform:Rotate(self.localRot)
    if self.modelData ~= nil and self.modelData.scale ~= nil then
        self.tpose.transform.localScale = Vector3(self.modelData.scale, self.modelData.scale, self.modelData.scale)
    end
    -- if not IsReLoad then
        self:BindModel()
    -- end
    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewmodelComposite:BindModel(doCheck)
    if (not doCheck and BaseUtils.isnull(self.tpose)) or not BaseUtils.isnull(self.cameraObj) then
        return
    end
    local renders = self.tpose.transform:GetComponentsInChildren(Renderer, true)
    local meshrenders = self.tpose.transform:GetComponentsInChildren(MeshRenderer, true)
    if self.sortingOrder ~= nil then
        for i=1, #renders do
            renders[i].sortingOrder = self.sortingOrder
        end
        for i=1, #meshrenders do
            meshrenders[i].sortingOrder = self.sortingOrder
        end
    end
    if self.usemask then
        local maskshader = PreloadManager.Instance:GetSubAsset(AssetConfig.shader_unlittexturemasker, "UnlitTextureMask")

        for i=1, #renders do
            renders[i].sortingOrder = self.sortingOrder
            if maskshader ~= nil then
                renders[i].material.shader = maskshader
            end
        end
        for i=1, #meshrenders do
            meshrenders[i].sortingOrder = self.sortingOrder
            if maskshader ~= nil then
                meshrenders[i].material.shader = maskshader
            end
        end

    end
    if self.parent ~= nil then
        self.tpose.transform:SetParent(self.parent)
        self.tpose.transform.localPosition = self.localPos
        if self.localScale ~= nil then
            self.tpose.transform.localScale = self.localScale
        end
    end
end



function PreviewmodelComposite:BindEffect(doCheck)
    if (not doCheck and BaseUtils.isnull(self.tpose)) or not BaseUtils.isnull(self.cameraObj) then
        return
    end
    local scale=  self.tpose.transform.localScale.x / 144
    local particleSystemList = self.tpose.transform:GetComponentsInChildren(ParticleSystem, true)
    for i=1, #particleSystemList do
        local particleSystem = particleSystemList[i]
        particleSystem.startSize = particleSystem.startSize * scale
    end
end

-- 界面隐藏的时候在隐藏预览内容
function PreviewmodelComposite:Hide()
    self.isshow = false
    if not BaseUtils.isnull(self.tpose) then
        self.tpose:SetActive(false)
    end
    if not BaseUtils.isnull(self.tpose_2) then
        self.tpose_2:SetActive(false)
    end
    if not BaseUtils.isnull(self.cameraObj) then
        self.cameraObj:SetActive(false)
    end
end

function PreviewmodelComposite:Show()
    self.isshow = true
    if not BaseUtils.isnull(self.tpose) then
        self.tpose:SetActive(true)
    end
    if not BaseUtils.isnull(self.tpose_2) then
        self.tpose_2:SetActive(true)
    end
    if not BaseUtils.isnull(self.cameraObj) then
        self.cameraObj:SetActive(true)
    end
end

function PreviewmodelComposite:OnTposeDrag(eventData)
    local offset = self.lastPostion.x - eventData.position.x
    -- printf(offset)
    self.lastPostion = eventData.position
    local width = 200
    if not BaseUtils.isnull(self.tpose) then
        self.tpose.transform:Rotate(Vector3.up, offset / width * 120)
    end
    if not BaseUtils.isnull(self.tpose_2) then
        self.tpose_2.transform:Rotate(Vector3.up, offset / width * 120)
    end
end

function PreviewmodelComposite:Reload(modelData, callback)
    self.callback = callback
    self.modelData = modelData
    self.count = self.count + 1
    self:BuildTpose(true)
end

function PreviewmodelComposite:PlayAction(action)
    if BaseUtils.is_null(self.tpose) then
        return
    end
    if self.animator == nil then
        self.animator = self.tpose:GetComponent(Animator)
    end
    if self.animator ~= nil then
        if self.modelData.type == PreViewType.Role then
            self:RolePlayAction(action)
        else
            self:NpcPlayAction(action)
        end
    end
end


function PreviewmodelComposite:RolePlayAction(action)
    --if BaseUtils.is_null(self.animator) or self.headAnimationData == nil then return end
    if BaseUtils.is_null(self.animator) then return end
    if action == FighterAction.BattleMove then
        self.animator:Play("Move" .. self.animationData.battlemove_id)
        -- self.headAnimator:Play(self.headAnimationData.battlemove_id)
    elseif action == FighterAction.Move then
        self.animator:Play("Move" .. self.animationData.move_id)
        -- self.headAnimator:Play(self.headAnimationData.move_id)
    elseif action == FighterAction.BattleStand then
        self.animator:Play("Stand" .. self.animationData.battlestand_id)
        -- self.headAnimator:Play(self.headAnimationData.battlestand_id)
    elseif action == FighterAction.Stand then
        self.animator:Play("Stand" .. self.animationData.stand_id)
        -- self.headAnimator:Play(self.headAnimationData.stand_id)
    elseif action == FighterAction.Hit then
        self.animator:Play("Hit" .. self.animationData.hit_id)
        -- self.headAnimator:Play(self.headAnimationData.hit_id)
    elseif action == FighterAction.Dead then
        self.animator:Play("Dead" .. self.animationData.dead_id)
        -- self.headAnimator:Play(self.headAnimationData.dead_id)
    elseif action == FighterAction.MultiHit then
        self.animator:Play("Hit" .. self.animationData.hit_id)
        -- self.headAnimator:Play(self.headAnimationData.hit_id)
    elseif action == FighterAction.Upthrow then
        self.animator:Play("Upthrow" .. self.animationData.upthrow_id)
        -- self.headAnimator:Play(self.headAnimationData.upthrow_id)
    elseif action == FighterAction.Standup then
        self.animator:Play("Standup" .. self.animationData.standup_id)
        -- self.headAnimator:Play(self.headAnimationData.standup_id)
    elseif action == FighterAction.Defense then
        self.animator:Play("Defense" .. self.animationData.defense_id)
        -- self.headAnimator:Play(self.headAnimationData.defense_id)
    elseif action == FighterAction.Meditation then -- 修炼动作
        self.animator:Play("Meditation")
    else
        self.animator:Play("Idle" .. self.animationData.idle_id)
        -- self.headAnimator:Play(self.headAnimationData.idle_id)
    end
end

function PreviewmodelComposite:NpcPlayAction(action)
    if BaseUtils.is_null(self.tpose) then
        return
    end
    if self.animator == nil then
        self.animator = self.tpose:GetComponent(Animator)
    end
    if BaseUtils.is_null(self.animator) then return end
    if action == FighterAction.BattleMove then
        self.animator:Play("Move" .. self.animationData.move_id)
    elseif action == FighterAction.Move then
        self.animator:Play("Move" .. self.animationData.move_id)
    elseif action == FighterAction.BattleStand then
        self.animator:Play("Stand" .. self.animationData.stand_id)
    elseif action == FighterAction.Stand then
        self.animator:Play("Stand" .. self.animationData.stand_id)
    elseif action == FighterAction.Hit then
        self.animator:Play("Hit" .. self.animationData.hit_id)
    elseif action == FighterAction.Dead then
        self.animator:Play("Dead" .. self.animationData.dead_id)
    elseif action == FighterAction.MultiHit then
        self.animator:Play("Hit" .. self.animationData.hit_id)
    elseif action == FighterAction.Upthrow then
        self.animator:Play("Upthrow" .. self.animationData.upthrow_id)
    elseif action == FighterAction.Standup then
        self.animator:Play("Standup" .. self.animationData.standup_id)
    elseif action == FighterAction.Defense then
        self.animator:Play("Defense" .. self.animationData.defense_id)
    elseif action == FighterAction.Weak then -- 答题宠物答错动作
        self.animator:Play("Weak" .. self.animationData.weak_id)
    else
        self.animator:Play("Idle" .. self.animationData.idle_id)
    end
end

function PreviewmodelComposite:PlayAnimation(name)
    if BaseUtils.is_null(self.tpose) then
        return
    end
    if self.animator == nil then
        self.animator = self.tpose:GetComponent(Animator)
    end
    if self.animator ~= nil then
        self.animator:Play(name)
    end
end