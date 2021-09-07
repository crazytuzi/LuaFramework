AnimalChessPiece = AnimalChessPiece or BaseClass()

function AnimalChessPiece:__init(board, localPos, loadCallback, follow, assetWrapper)
    self.board = board
    self.localPos = localPos
    self.follow = follow
    self.assetWrapper = assetWrapper
    self.loadCallback = loadCallback
    self.x = nil
    self.y = nil

    self.callbackList = nil
end

function AnimalChessPiece:__delete()
    self.data = nil
    self.callback = nil
    self.board = nil
    if self.faceToTweenId ~= nil then
        Tween.Instance:Cancel(self.faceToTweenId)
        self.faceToTweenId = nil
    end
    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
    end
    self.assetWrapper = nil
end

function AnimalChessPiece:SetData()
    local data = AnimalChessManager.Instance.model.chessInfoTab[self.x][self.y]
    self.data = data
    self.rotation = rotation

    if self.loader ~= nil then
        self.loader:DeleteMe()
        self.loader = nil
    end

    if data.status == AnimalChessEumn.SlotStatus.Opened then
        local petData = AnimalChessEumn.ChessType[data.grade]

        local skin = petData.skin_1
        if data.camp ~= AnimalChessManager.Instance.model.myCamp then
            skin = petData.skin_2
        end
        self.loader = NpcTposeLoader.New(skin, petData.model_id, petData.animation_id, petData.scale / 100, function(tpose, animaData, info) if self.loadCallback ~= nil then self.loadCallback(tpose) end self:TposeCallback(tpose, data.camp, info) end)
        self.follow.transform.gameObject:SetActive(true)
        if data.camp == AnimalChessManager.Instance.model.myCamp then
            self.follow.nameText1.text = string.format("<color='#3BEAFF'>%s</color>", petData.name)
        else
            self.follow.nameText1.text = petData.name
        end
        self.follow.nameText2.text = petData.name
    elseif data.status == AnimalChessEumn.SlotStatus.UnOpen then
        local boxModel = AnimalChessManager.Instance.model.boxModel
        self.loader = NpcTposeLoader.New(boxModel.skinId, boxModel.modelId, boxModel.animationId, boxModel.scale / 100, function(tpose, animaData, info) if self.loadCallback ~= nil then self.loadCallback(tpose) end self:TposeCallback(tpose, nil, info) end)
        self.follow.transform.gameObject:SetActive(true)
        self.follow.nameText1.text = ""
        self.follow.nameText2.text = ""
    else
        self.follow.transform.gameObject:SetActive(false)
    end
end

function AnimalChessPiece:TposeCallback(tpose, camp, info)
    tpose.transform.localPosition = self.localPos / 100
    if camp == nil then
        tpose.transform.localRotation = Quaternion.Euler(-20, 315, 20)
    elseif camp == AnimalChessManager.Instance.model.myCamp then
        tpose.transform.localRotation = Quaternion.Euler(20.68393, 131.9303, 340.775)
        -- info.meshNode.renderer.material.shader = PreloadManager.Instance:GetSubAsset(AssetConfig.shader_effects, "SceneUnitAlpaha")
        -- info.meshNode.renderer.material.color = Color(105/255,105/255,1,1)
    else
        tpose.transform.localRotation = Quaternion.Euler(339.3161, 311.9303, 19.91244)
        -- info.meshNode.renderer.material.shader = PreloadManager.Instance:GetSubAsset(AssetConfig.shader_effects, "SceneUnitAlpaha")
        -- info.meshNode.renderer.material.color = Color(1,57/255,57/255,1)
    end

    if self.callbackList ~= nil then
        for _,call in ipairs(self.callbackList) do
            call(tpose)
        end
        self.callbackList = nil
    end
end

function AnimalChessPiece:FaceTo(localPos, time, callback)
    time = time or 0

    if self.loader == nil then
        return
    end

    local thisPosition = self.loader.tpose.transform.localPosition
    local targetRotation = Quaternion.FromToRotation(AnimalChessManager.Instance.model.quaternion * Vector3(0, 0, -1), localPos - thisPosition) * (AnimalChessManager.Instance.model.quaternion * Quaternion.Euler(Vector3(0, 0, 0)))

    if time == 0 then
        self.loader.tpose.transform.localRotation = targetRotation
    else
        if self.faceToTweenId ~= nil then
            Tween.Instance:Cancel(self.faceToTweenId)
            self.faceToTweenId = nil
        end
        self.faceToTweenId = Tween.Instance:Rotate(self.loader.tpose.gameObject, targetRotation.eulerAngles, time,
        function()
            self.faceToTweenId = nil
            if callback ~= nil then
                callback()
            end
        end, LeanTweenType.linear).id
    end
end

function AnimalChessPiece:AfterRotate()
    self.faceToTweenId = nil
end

function AnimalChessPiece:Play(anim)
    if self.loader == nil or self.loader.tpose == nil then
        self.callbackList = self.callbackList or {}
        self.data = AnimalChessManager.Instance.model.chessInfoTab[self.x][self.y]
        table.insert(self.callbackList, function(tpose)
            tpose:GetComponent(Animator):Play(anim .. DataAnimation.npc_dataData[AnimalChessEumn.ChessType[self.data.grade].animation_id][AnimalChessEumn.Motion[anim]])
        end)
        return
    end

    local lastData = nil
    if AnimalChessManager.Instance.model.chessLastTab == nil then
    else
        lastData = AnimalChessManager.Instance.model.chessLastTab[self.x][self.y]
    end

        lastData = AnimalChessManager.Instance.model.chessInfoTab[self.x][self.y]
    if lastData.grade ~= nil and lastData.grade > 0 then
        local motion = anim .. DataAnimation.npc_dataData[AnimalChessEumn.ChessType[lastData.grade].animation_id][AnimalChessEumn.Motion[anim]]
        self.loader.tpose:GetComponent(Animator):Play(motion)
    else
        print("怎么不走了？？？————————————————————" .. anim)
    end
end

function AnimalChessPiece:Select(bool)
    if self.board.selectEffect ~= nil then
        self.board.selectEffect:DeleteMe()
        self.board.selectEffect = nil
    end
    if self.loader == nil then
        return
    end

    if bool then
        local callback = function(effectObject)
            if not BaseUtils.isnull(effectObject) then
                Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
            end
        end
        self.board.selectEffect = TposeEffectLoader.New(self.loader.tpose.gameObject, self.loader.tpose, {{effect_id = 300021}}, callback)
        self:Play("Idle")
    end
end

function AnimalChessPiece:SetGreen(i)
    if self.board.effectTab[i] ~= nil then
        self.board.effectTab[i]:DeleteMe()
        self.board.effectTab[i] = nil
    end
    local fun = function(effectView)
        if self.loadCallback ~= nil then
            self.loadCallback(effectView)
        end
        local effectObject = effectView.gameObject
        effectObject.name = "Effect"
        effectObject.transform.localScale = Vector3(0.007, 0.007, 0.007)
        effectObject.transform.localPosition = self.localPos / 100

        -- local q = Quaternion.FromToRotation(Vector3(0, 0, -1), AnimalChessManager.Instance.model.normalVector3.normalized)
        -- effectObject.transform.localRotation = Quaternion.FromToRotation(q * Vector3(0, -1, 0), AnimalChessManager.Instance.model.xNormalVector3) * q

        effectObject.transform.localRotation = Quaternion.Euler(59.30299,355.9821,222.5451)

        Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
    end
    self.board.effectTab[i] = BaseEffectView.New({effectId = 20404, time = time, callback = fun})
end

function AnimalChessPiece:OpenBox()
    if self.board.selectEffect ~= nil then
        self.board.selectEffect:DeleteMe()
        self.board.selectEffect = nil
    end

    local key = nil
    if self.data.camp == AnimalChessManager.Instance.model.myCamp then
        key = "openEffect1"
    else
        key = "openEffect2"
    end

    if self.board[key] == nil then
        local fun = function(effectView)
            if self.loadCallback ~= nil then
                self.loadCallback(effectView)
            end
            local effectObject = effectView.gameObject
            effectObject.name = "Effect"
            effectObject.transform.localScale = Vector3(0.007, 0.007, 0.007)
            effectObject.transform.localPosition = self.localPos / 100

            -- local qq = Quaternion.Euler(313.2233, 180, 180)

            -- local q = Quaternion.FromToRotation(Vector3(0, 0, -1), AnimalChessManager.Instance.model.normalVector3.normalized)
            -- effectObject.transform.localRotation = Quaternion.Inverse(q)

            -- effectObject.transform.localRotation = Quaternion.Euler(59.30299,355.9821,222.5451)

            Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
        end
        if self.data.camp == AnimalChessManager.Instance.model.myCamp then
            self.board[key] = BaseEffectView.New({effectId = 20364, time = time, callback = fun})
        else
            self.board[key] = BaseEffectView.New({effectId = 20365, time = time, callback = fun})
        end
    else
        self.board[key]:SetActive(false)
        self.board[key].gameObject.transform.localPosition = self.localPos / 100
        self.board[key]:SetActive(true)
    end
end

function AnimalChessPiece:SetRed(i)
    if self.board.effectTab[i] ~= nil then
        self.board.effectTab[i]:DeleteMe()
        self.board.effectTab[i] = nil
    end
    local fun = function(effectView)
        if self.loadCallback ~= nil then
            self.loadCallback(effectView)
        end
        local effectObject = effectView.gameObject
        effectObject.name = "Effect"
        effectObject.transform.localScale = Vector3(0.007, 0.007, 0.007)
        effectObject.transform.localPosition = self.localPos / 100

        -- local q = Quaternion.FromToRotation(Vector3(0, 0, -1), AnimalChessManager.Instance.model.normalVector3.normalized)
        -- effectObject.transform.localRotation = Quaternion.FromToRotation(q * Vector3(0, -1, 0), AnimalChessManager.Instance.model.xNormalVector3) * q

        effectObject.transform.localRotation = Quaternion.Euler(59.30299,355.9821,222.5451)

        Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
    end
    self.board.effectTab[i] = BaseEffectView.New({effectId = 20403, time = time, callback = fun})
end

