-- ------------------
-- 表情
-- hosr
-- ------------------
FaceItem = FaceItem or BaseClass()

function FaceItem:__init(parent)
    self.parent = parent
    self.faceId = nil
    self.path = ""
    self.gameObject = nil
    self.width = 30
    self.height = 30

    self.animator = nil
    self.timeId = nil
    self.result = function() self:ShowResult() end
    self.resultVal = 1
    self.noRoll = false
    self.isSceneFace = false
    self.size = nil
    self.doAnimation = true
    self.grey = false
    self.spriteGameObject = nil

    self.anotherAssetWrapper = nil
    self.mask = false
    self.repeatLoad = false
end

function FaceItem:Load()
    self.isLoading = true
    self:Destroy()
    self.assetWrapper = AssetBatchWrapper.New()
    if self.isBig then
        self.assetWrapper:LoadAssetBundle({{file = self.path, type = AssetType.Dep},{file = AssetConfig.face_textures, type = AssetType.Dep}}, function() self:LoadEnd() end)
    else
        self.assetWrapper:LoadAssetBundle({{file = self.path, type = AssetType.Main},{file = AssetConfig.face_textures, type = AssetType.Dep}}, function() self:LoadEnd() end)
    end
end

function FaceItem:LoadEnd()
    self.isLoading = false
    if self.assetWrapper == nil then
        return
    end

    if self.isBig then
        self.gameObject = GameObject()
        self.gameObject:AddComponent(RectTransform)
        self.gameObject:AddComponent(Image).sprite = self.assetWrapper:GetSprite(self.path, tostring(self.faceId))
    else
        local o = self.assetWrapper:GetMainAsset(self.path)
        if BaseUtils.isnull(o) then
            if self.assetWrapper.resList[self.path] == nil then
                local ta = {}
                for k,v in pairs(self.assetWrapper.resList) do
                    if v ~= nil then
                        table.insert(ta,k)
                    end
                end
                Log.Error("AssetWrapper找不到这个预设" .. self.path .. "\n" .. table.concat(ta, "\n"))
            end
        end
        self.gameObject = GameObject.Instantiate(o)
        self.animator = self.gameObject:GetComponent(Animator)
        self.animator.enabled = self.doAnimation
    end
    self.gameObject.name = string.format("face_%s", self.faceId)

    self.rect = self.gameObject:GetComponent(RectTransform)
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent)
    if self.isSceneFace then
        self.transform.localScale = Vector3.one*1.4
    else
        self.transform.localScale = Vector3.one
    end
    self.transform.localPosition = Vector3.zero
    self.rect.anchorMin = Vector2(0, 1)
    self.rect.anchorMax = Vector2(0, 1)
    self.rect.pivot = Vector2(0, 1)
    if self.isSceneFace then
        self.rect.anchoredPosition = Vector2(self.pos.x, self.pos.y + 3)
    else
        self.rect.anchoredPosition = Vector2(self.pos.x, self.pos.y + 5)
    end

    if self.isBig then
        self.width = 80
        self.height = 80
    elseif self.faceId == 7 or self.faceId == 16 or self.faceId == 34 or self.faceId == 41 or self.faceId == 114 or self.faceId == 123 or self.faceId == 124 or self.faceId == 125 or self.faceId == 126 or self.faceId == 128 or self.faceId == 135 then
        self.width = 60
    else
        self.width = 30
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if self.size == nil then
        self.rect.sizeDelta = Vector2(self.width, self.height)
    else
        self.rect.sizeDelta = self.size
    end
    self.gameObject:SetActive(true)
    if self.mySpecial == true then
        self:SetGreySprite()
    else
        self:SetGrey(self.grey)
    end

    if self.mySize ~= nil then
        self.transform.sizeDelta = self.mySize
    end

    if self.noRoll then
        self:ShowResult()
    end

    if self.callback ~= nil then
        self.callback()
        self.callback = nil
    end
end

function FaceItem:__delete()
    self.animator = nil
    if self.gameObject ~= nil then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if self.anotherAssetWrapper ~= nil then
        self.anotherAssetWrapper:DeleteMe()
        self.anotherAssetWrapper = nil
    end
end

function FaceItem:Show(faceId, pos, isSceneFace,size)
    if self.repeatLoad == true then
        self.callback = nil
    end
    if self.isLoading then
        self.callback = function() self:Show(faceId, pos, isSceneFace,size) end
        self.repeatLoad = true
        return
    end

    self.mySize = size
    self.isSprite = isSprite or false
    self.isSceneFace = isSceneFace
    self.faceId = tonumber(faceId)
    self.pos = pos
    self.isBig = false
    if faceId == 1000 or faceId == 1001 then
        --特殊表情
        self.path = string.format("prefabs/ui/specialface/face_%s.unity3d", self.faceId)
    else
        if DataChatFace.data_new_face[self.faceId] ~= nil and DataChatFace.data_new_face[self.faceId].type == FaceEumn.FaceType.Big then
            self.isBig = true
            self.path = FaceEumn.GetBigPath(self.faceId)
        else
            -- self.faceId = math.min(self.faceId, 64)
            self.path = string.format("prefabs/ui/face/face_%s.unity3d", self.faceId)
        end
    end
    self:Load()
end

function FaceItem:Destroy()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
    if self.gameObject ~= nil then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
        self.animator = nil
    end
end

function FaceItem:ShowRandom(val)
    self.resultVal = math.max(val, 1)
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
    self.timeId = LuaTimer.Add(2000, self.result)
end

function FaceItem:JustShowResult(val)
    self.noRoll = true
    self.resultVal = math.max(val, 1)
    self:ShowResult()
end

function FaceItem:ShowResult()
    if BaseUtils.is_null(self.gameObject) then
        return
    end

    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end

    if self.animator ~= nil then
        self.animator.enabled = false
    end
    local p = ""
    if self.faceId == 1000 then
        p = string.format("%s_%s", self.faceId, self.resultVal)
    elseif self.faceId == 1001 then
        p = string.format("%s_%s", self.faceId, MsgEumn.Roll[self.resultVal])
    end
    self.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.face_special_res, p)
end

function FaceItem:Animate(move)
    self.doAnimation = (move == true)
    if self.animator ~= nil then
        self.animator.enabled = (move == true)
    end
end

function FaceItem:SetGrey(grey)
    self.mySpecial = false
    self.grey = grey
    if BaseUtils.is_null(self.gameObject) then
        return
    end
    -- self.lastSprite = self.gameObject:GetComponent(Image).sprite

    if grey then
        self.gameObject:GetComponent(Image).color = Color.grey
    else
        self.gameObject:GetComponent(Image).color = Color.white
    end
end

function FaceItem:SetSprite(grey,v1,v2)
    self.mySpecial = true
    self.grey = grey
    self.anotherAssetWrapper = AssetBatchWrapper.New()
    self.anotherAssetWrapper:LoadAssetBundle({{file = AssetConfig.face_textures, type = AssetType.Dep}}, function() self:LoadAnOtherEnd() end)
end

function FaceItem:LoadAnOtherEnd()
    if self.spriteGameObject == nil then
        if self.grey then
            self.spriteGameObject = GameObject()
            self.spriteGameObject:AddComponent(RectTransform)
            local sprite = nil
            if self.isBig then
                sprite = self.anotherAssetWrapper:GetSprite(AssetConfig.face_textures,"BigFace")
                if sprite == nil then
                    sprite = PreloadManager.Instance:GetSprite(AssetConfig.face_textures,"BigFace")
                end
            else
                if DataChatFace.data_new_face[self.faceId].isdistance ~= 2 then
                    sprite = self.anotherAssetWrapper:GetSprite(AssetConfig.face_textures,"SmallFace")
                    if sprite == nil then
                        sprite = PreloadManager.Instance:GetSprite(AssetConfig.face_textures,"SmallFace")
                    end
                elseif DataChatFace.data_new_face[self.faceId].isdistance == 2 then
                    sprite = self.anotherAssetWrapper:GetSprite(AssetConfig.face_textures,"SmallFace2")
                    if sprite == nil then
                        sprite = PreloadManager.Instance:GetSprite(AssetConfig.face_textures,"SmallFace2")
                    end
                end
            end

            self.spriteGameObject:AddComponent(Image).sprite = sprite
            self.spriteGameObject.transform:SetParent(self.parent)
            self.spriteRect = self.spriteGameObject.transform:GetComponent(RectTransform)
            self.spriteTransform = self.spriteGameObject.transform

            if self.isSceneFace then
                self.spriteTransform.localScale = Vector3.one*1.4
            else
                self.spriteTransform.localScale = Vector3.one
            end
            self.spriteTransform.localPosition = Vector3.zero
            self.spriteRect.anchorMin = Vector2(0, 1)
            self.spriteRect.anchorMax = Vector2(0, 1)
            self.spriteRect.pivot = Vector2(0, 1)
            if self.isSceneFace then
                self.spriteRect.anchoredPosition = Vector2(self.pos.x, self.pos.y + 3)
            else
                self.spriteRect.anchoredPosition = Vector2(self.pos.x, self.pos.y + 5)
            end


            if self.isBig then
                self.spriteRect.sizeDelta = Vector2(80, 80)
            else
                if self.mySize == nil then
                    self.spriteRect.sizeDelta = Vector2(30, 30)
                else
                    self.spriteRect.sizeDelta = self.mySize
                end
            end
        end
    end



    self:SetGreySprite()
end


function FaceItem:SetGreySprite()
    if not BaseUtils.isnull(self.spriteGameObject) then
        self.spriteGameObject:SetActive(self.grey)
        -- if self.gameObject ~= nil then
        --     self.spriteGameObject.transform.anchoredPosition = self.gameObject.transform.anchoredPosition
        -- end
    end
    if not BaseUtils.isnull(self.gameObject) then
        self.gameObject:SetActive(not self.grey)
    end
    self.mask = self.grey
end