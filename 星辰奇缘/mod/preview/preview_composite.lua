-- 模型预览组合件
PreviewComposite = PreviewComposite or BaseClass()

function PreviewComposite:__init(callback, setting, modelData)
    self.callback = callback
    self.setting = setting
    self.modelData = modelData

    self.name = setting.name or "Unknown"
    self.orthographicSize = setting.orthographicSize or 1.93
    self.width = setting.width or 256
    self.height= setting.height or 256
    self.offsetX = setting.offsetX or 0
    self.offsetY = setting.offsetY or 0
    self.noDrag = setting.noDrag or false
    self.noMaterial = setting.noMaterial or false

    self.tpose = nil
    self.animationData = nil
    self.headAnimationData = nil
    self.rawImage = nil
    self.cameraObj = nil
    self.render = nil
    self.animator = nil
    self.cachemotion = nil --缓存动作，等待加载完播放

    self.loader = nil

    if IS_DEBUG then
        PreviewManager.Instance:CheckRelease()
        self.previewId = PreviewManager.Instance:Insert(self)
    end

    self.nextX = PreviewManager.Instance:NextX()
    self.lastPostion = Vector3(0, 0, 0)
    self:BuildTpose(false)
end

function PreviewComposite:__delete()
    if IS_DEBUG then
        PreviewManager.Instance:Remove(self.previewId)
        self.previewId = nil
    end
    if self.render ~= nil then
        self.render:Release()
        RenderTexture.Destroy (self.render)
        self.render = nil
    end
    if self.cameraObj ~= nil then
        self.cameraObj:GetComponent(Camera).targetTexture = nil
        GameObject.DestroyImmediate(self.cameraObj)
        self.cameraObj = nil
    end
    if not BaseUtils.isnull(self.rawImage) then
        if self.rawImage:GetComponent(RawImage) ~= nil then
            self.rawImage:GetComponent(RawImage).material = nil
        end
        GameObject.DestroyImmediate(self.rawImage)
        self.rawImage = nil
    end
    if self.tpose ~= nil then
        GameObject.DestroyImmediate(self.tpose)
        self.tpose = nil
    end

    if self.tpose_2 ~= nil then
        GameObject.DestroyImmediate(self.tpose_2)
        self.tpose_2 = nil
    end

    if self.effectLoader ~= nil then
        self.effectLoader:DeleteMe()
        self.effectLoader = nil
    end
    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
    end

    self.callback = nil
    self.setting = nil
    self.modelData = nil
    self.animationData = nil
    self.rawImage = nil
    self.cameraObj = nil
    self.render = nil
    self.lastPostion = nil

end

function PreviewComposite:BuildTpose(IsReLoad)
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
            self.loader = MixRoleWingLoader.New(self.modelData.classes, self.modelData.sex, self.modelData.looks, callback, self.modelData.noWing, nil, self.modelData.noWeapon, self.modelData.showHalo)
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
        self.loader = WingTposeLoader.New(self.modelData.looks, callback, "ModelPreview")
    elseif self.modelData.type == PreViewType.Ride then
        local callback = function(newTpose, animationData,ridePoolData,nowBaseId)
            self:OnRideLoaded(newTpose, animationData,ridePoolData,IsReLoad,nowBaseId)
        end
        self.loader = RideTposeLoader.New(self.modelData.classes, self.modelData.sex, self.modelData.looks, callback)
    elseif self.modelData.type == PreViewType.Weapon then
        local callback = function (newTpose, animationData)
            self:OnWeaponLoaded(newTpose, animationData, IsReLoad)
        end
        self.loader = WeaponTposeLoader.New(self.modelData.classes, self.modelData.sex,self.modelData.looks, callback)
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

function PreviewComposite:OnNpcLoaded(newTpose, animationData, IsReLoad)
    -- if self.tpose ~= nil then
    --     -- GameObject.DestroyImmediate(self.tpose)
    --     GameObject.Destroy(self.tpose)
    -- end
    self.tpose = newTpose
    self.animationData = animationData
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    self.tpose.name = "PreviewTpose_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)
    if self.modelData.modelId == 70145 or self.modelData.modelId == 70144 or self.modelData.modelId == 70143 then
        -- 战场大炮特殊缩小
        self.tpose.transform.localPosition = Vector3(105,-0.56,0)
        self.tpose.transform.localScale = Vector3.one*0.4
    end
    -- print(IsReLoad)
    -- print("是不是？？？？")
    -- if not IsReLoad then
        self:BuildCamera()
    -- end

    if self.modelData ~= nil and self.modelData.effects ~= nil then
        local callback = function(effectObject)
            if not BaseUtils.isnull(self.tpose) then
                Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
            end
        end
        self.effectLoader = TposeEffectLoader.New(self.tpose, self.tpose, self.modelData.effects, callback)
    end

    if self.callback ~= nil then
        self.callback(self)
    end
    if self.cachemotion ~= nil then
        self:PlayAnimation(self.cachemotion)
        self.cachemotion = nil
    end
end

-- 回调函数可能还有其它字段，用到就加上去
function PreviewComposite:OnRoleLoaded(newTpose, animationData, IsReLoad)
    -- if self.tpose ~= nil then
    --     -- GameObject.DestroyImmediate(self.tpose)
    --     GameObject.Destroy(self.tpose)
    -- end
    self.tpose = newTpose
    self.animationData = animationData
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    self.tpose.name = "PreviewTpose_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)
    -- if not IsReLoad then
        self:BuildCamera()
    -- end
    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewComposite:OnWingsLoaded(newTpose, animationData, IsReLoad)
    -- if self.tpose ~= nil then
    --     -- GameObject.DestroyImmediate(self.tpose)
    --     GameObject.Destroy(self.tpose)
    -- end
    self.tpose = newTpose
    self.animationData = animationData
    self.tpose.name = "PreviewTpose_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)
    -- if not IsReLoad then
        self:BuildCamera()
    -- end
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewComposite:OnWeaponLoaded(newTpose1, newTpose2)
    -- if self.tpose ~= nil then
    --     GameObject.Destroy(self.tpose)
    -- end
    self.tpose = newTpose1
    self.tpose.name = "PreviewTpose1_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)

    self:BuildCamera()
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")

    if self.modelData.classes == SceneConstData.classes_gladiator or self.modelData.classes == SceneConstData.classes_sanctuary then
        if self.modelData.classes == SceneConstData.classes_gladiator then
            self.tpose.transform.position = Vector3(self.nextX + self.offsetX - 0.15, self.offsetY - 0.1, 0)
            self.tpose.transform.localRotation = Quaternion.identity
            self.tpose.transform:Rotate(Vector3(310, 90, 90))


            if newTpose2 ~= nil then
                if self.tpose_2 ~= nil then
                    GameObject.Destroy(self.tpose_2)
                end
                self.tpose_2 = newTpose2
                self.tpose_2.name = "PreviewTpose2_" .. self.name
                self.tpose_2.transform:SetParent(PreviewManager.Instance.container.transform)
                self.tpose_2.transform.position = Vector3(self.nextX + self.offsetX + 0.15, self.offsetY - 0.1, 0)

                Utils.ChangeLayersRecursively(self.tpose_2.transform, "ModelPreview")

                self.tpose_2.transform.localRotation = Quaternion.identity
                self.tpose_2.transform:Rotate(Vector3(310, -90, 90))
            end
        elseif self.modelData.classes == SceneConstData.classes_sanctuary then
            self.tpose.transform.position = Vector3(self.nextX + self.offsetX - 0.15, self.offsetY + 0.28, 0)
            self.tpose.transform.localRotation = Quaternion.identity
            self.tpose.transform:Rotate(Vector3(90, 0, 0))
            if newTpose2 ~= nil then

                self.tpose_2 = newTpose2
                self.tpose_2.name = "PreviewTpose2_" .. self.name
                self.tpose_2.transform:SetParent(PreviewManager.Instance.container.transform)
                self.tpose_2.transform.position = Vector3(self.nextX + self.offsetX + 0.15, self.offsetY, 0)

                Utils.ChangeLayersRecursively(self.tpose_2.transform, "ModelPreview")

                self.tpose_2.transform.localRotation = Quaternion.identity
                self.tpose_2.transform:Rotate(Vector3(90,90,0))
            end
        end
    elseif self.modelData.classes == SceneConstData.classes_mage then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX - 0.1, self.offsetY, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3(300, 90, 0))
    elseif self.modelData.classes == SceneConstData.classes_ranger then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY + 0.1, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3(0, 0, 90))
    elseif self.modelData.classes == SceneConstData.classes_musketeer then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX - 0.1, self.offsetY, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3(300, 90, 90))
    elseif self.modelData.classes == SceneConstData.classes_devine then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY + 0.1, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3(0, 200, 0))
    elseif self.modelData.classes == SceneConstData.classes_moon then
        self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY + 0.1, 0)
        self.tpose.transform.localRotation = Quaternion.identity
        self.tpose.transform:Rotate(Vector3.zero)

    end

    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewComposite:OnHomeLoaded(newTpose, animationData, IsReLoad)
    -- if self.tpose ~= nil then
    --     -- GameObject.DestroyImmediate(self.tpose)
    --     GameObject.Destroy(self.tpose)
    -- end
    self.tpose = newTpose
    self.animationData = animationData
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    self.tpose.name = "PreviewTpose_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY + 0.05, 0)

    self.tpose.transform.localRotation = Quaternion.identity
    self.tpose.transform:Rotate(Vector3(-30, 0, 0))
    self.tpose.transform:Rotate(Vector3(0, 65, 0))
    -- print(IsReLoad)
    -- print("是不是？？？？")
    -- if not IsReLoad then
        self:BuildCamera()
    -- end

    if self.modelData ~= nil and self.modelData.scale ~= nil then
        self.tpose.transform.localScale = Vector3(self.modelData.scale, self.modelData.scale, self.modelData.scale)
    end

    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewComposite:OnRideLoaded(newTpose, animationData,ridePoolData, IsReLoad,nowBaseId)
    -- if self.tpose ~= nil then
    --     -- GameObject.DestroyImmediate(self.tpose)
    --     GameObject.Destroy(self.tpose)
    -- end
    self.rideEffect = ridePoolData.rideEffect
    self.nowBaseId = nowBaseId
    self.tpose = newTpose
    self.animationData = animationData
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    self.tpose.name = "PreviewTpose_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)

         local myEffectLoader = false
          if self.rideEffect ~= nil and self.rideEffect.gameObject ~= nil then
                if  RideManager.Instance.model.cur_ridedata ~= nil and RideManager.Instance.model.cur_ridedata.decorate_list ~= nil then
                    for k2,v2 in pairs(RideManager.Instance.model.cur_ridedata.decorate_list) do
                        if v2.decorate_index == 1 then
                            myEffectLoader = true

                        end
                    end
                end
                -- end
            -- end
        -- end
            local mountData = DataMount.data_ride_data[self.nowBaseId]
            if mountData.notshowprevew == 0 then
                if mountData.isalwaysshow == 1 then
                    self.rideEffect.gameObject:SetActive(true)
                else
                    if myEffectLoader == true then
                        self.rideEffect.gameObject:SetActive(true)
                    else
                        self.rideEffect.gameObject:SetActive(false)
                    end
                end
            elseif mountData.notshowprevew == 1 then
                self.rideEffect.gameObject:SetActive(false)
            end

          end

    if not IsReLoad then
        self:BuildCamera()
    end

    if self.modelData ~= nil and self.modelData.scale ~= nil then
        self.tpose.transform.localScale = Vector3(self.modelData.scale, self.modelData.scale, self.modelData.scale)
    end

    if self.modelData ~= nil and self.modelData.effects ~= nil then
        local callback = function() Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview") end
        self.effectLoader = TposeEffectLoader.New(self.tpose, self.tpose, self.modelData.effects, callback)
    end

    if self.callback ~= nil then
        self.callback(self)
    end

    if self.cachemotion ~= nil then
        self:PlayAnimation(self.cachemotion)
        self.cachemotion = nil
    end


end

function PreviewComposite:OnHeadSurbaseLoaded(newTpose, headSurbaseData, modelData)
    self.tpose = newTpose
    self.animationData = headSurbaseData
    self.tpose.name = "PreviewTpose_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)
    self:BuildCamera()
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    if self.callback ~= nil then
        self.callback(self)
    end
end

function PreviewComposite:BuildCamera(doCheck)
    if (not doCheck and BaseUtils.is_null(self.tpose)) or not BaseUtils.isnull(self.cameraObj) then
        return
    end

    self.cameraObj = GameObject("PreviewCamera_" .. self.name)
    local camera = self.cameraObj:AddComponent(Camera)
    camera.orthographicSize = self.orthographicSize
    camera.orthographic = true
    camera.backgroundColor = Color(0,0,0,0)
    camera.clearFlags = CameraClearFlags.Color;
    camera.depth = 1;
    camera.nearClipPlane = -10;
    camera.farClipPlane = 1
    camera.cullingMask = 512
    self.cameraObj.transform:SetParent(PreviewManager.Instance.container.transform)
    self.cameraObj.transform.position = Vector3(self.nextX, 0, 0.5)

    self.rawImage = GameObject("PreviewRawImage_" .. self.name)
    self.rawImage:AddComponent(RectTransform).sizeDelta = Vector2(self.width, self.height)
    local raw = self.rawImage:AddComponent(RawImage)
    -- self.render = RenderTexture.GetTemporary(self.width, self.height, 24)
    self.render = RenderTexture.GetTemporary(self.width * 1.5, self.height * 1.5, 16)
    raw.texture = self.render
    if not self.noMaterial then
        raw.material = Material(Shader.Find ("Particles/Alpha Blended Premultiply"))
    end
    camera.targetTexture = self.render

    -- 不需要拖动
    if self.setting ~= nil and not self.setting.noDrag then
        local dragBehaviour = self.rawImage:AddComponent(UIDragBehaviour)
        local onBeginDrag = function(data)
            self.lastPostion = data.position
        end
        dragBehaviour.onBeginDrag= {"+=", onBeginDrag}
        local cbOnDrag = function(data)
            self:OnTposeDrag(data)
        end
        dragBehaviour.onDrag = {"+=", cbOnDrag}
    end
end

-- 界面隐藏的时候在隐藏预览内容
function PreviewComposite:Hide()
    if not BaseUtils.is_null(self.tpose) then
        self.tpose:SetActive(false)
    end
    if not BaseUtils.is_null(self.tpose_2) then
        self.tpose_2:SetActive(false)
    end
    if not BaseUtils.is_null(self.cameraObj) then
        self.cameraObj:SetActive(false)
    end
    -- if self.tpose ~= nil then
    --     self.tpose:SetActive(false)
    -- end
    -- if self.cameraObj ~= nil then
    --     self.cameraObj:SetActive(false)
    -- end
end

function PreviewComposite:HideCameraOnly()
    if not BaseUtils.is_null(self.cameraObj) then
        self.cameraObj:SetActive(false)
    end
end

function PreviewComposite:Show()
    if not BaseUtils.is_null(self.tpose) then
        self.tpose:SetActive(true)
    end
    if not BaseUtils.is_null(self.tpose_2) then
        self.tpose_2:SetActive(true)
    end
    if not BaseUtils.is_null(self.cameraObj) then
        self.cameraObj:SetActive(true)
    end
    -- if self.tpose ~= nil then
    --     self.tpose:SetActive(true)
    -- end
    -- if self.cameraObj ~= nil then
    --     self.cameraObj:SetActive(true)
    -- end
end

function PreviewComposite:OnTposeDrag(eventData)
    local offset = self.lastPostion.x - eventData.position.x
    self.lastPostion = eventData.position
    if not BaseUtils.is_null(self.tpose) then
        self.tpose.transform:Rotate(Vector3.up, offset / self.width * 120)
    end
    if not BaseUtils.is_null(self.tpose_2) then
        self.tpose_2.transform:Rotate(Vector3.up, offset / self.width * 120)
    end
end

function PreviewComposite:Reload(modelData, callback)
    self.callback = callback
    self.modelData = modelData
    self:BuildTpose(true)
end

function PreviewComposite:testFun()
    -- self.headAnimator = self.loader.headTpose:GetComponent(Animator)

    -- self.headAnimator:Play(self.loader.headAnimationData.stand_id)

    -- local path = BaseUtils.GetChildPath(self.loader.roleTpose.transform, "Bip_Head")
    -- local mounter = self.loader.roleTpose.transform:Find(path)
    local headTran = self.loader.headTpose.transform
    -- headTran:SetParent(mounter)
    -- headTran.localPosition = Vector3(0, 0, 0)
    -- headTran.localScale = Vector3(1, 1, 1)
    -- headTran.localRotation = Quaternion.identity
    -- headTran:Rotate(Vector3(90, 0, 0))

    -- LuaTimer.Add(1000, function()
        headTran.localPosition = Vector3(100, 100, 0)
    -- end)

    LuaTimer.Add(100, function()
        headTran.localPosition = Vector3(0, 0, 0)
    end)
    -- self.loader.headTpose
end

function PreviewComposite:PlayMotion(action)
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


function PreviewComposite:RolePlayAction(action)
    -- if BaseUtils.is_null(self.animator) or self.headAnimationData == nil then return end
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
    else
        self.animator:Play("Idle" .. self.animationData.idle_id)
        -- self.headAnimator:Play(self.headAnimationData.idle_id)
    end
end

function PreviewComposite:NpcPlayAction(action)
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
    else
        self.animator:Play("Idle" .. self.animationData.idle_id)
    end
end

function PreviewComposite:PlayAnimation(name)
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
