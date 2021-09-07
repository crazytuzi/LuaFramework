-- --------------
-- 剧情对话
-- hosr
-- --------------
DialogDramaPanel = DialogDramaPanel or BaseClass(BasePanel)

function DialogDramaPanel:__init(model)
    self.model = model

    self.effectPath = "prefabs/effect/20014.unity3d"
    self.resList = {
        {file = AssetConfig.drama_talk, type = AssetType.Main}
    }

    if RoleManager.Instance.RoleData.lev <= 20 then
        table.insert(self.resList, {file = self.effectPath, type = AssetType.Main})
    end

    self.effect = nil

    self.actionData = nil
    self.callback = nil
    self.stringTab = {}
    self.stringover = false
    self.currentStr = ""

    self.setting = {
        name = "DialogPreview"
        ,orthographicSize = 0.38
        ,width = 341
        ,height = 341
        ,offsetX = -0.04
        ,offsetY = -0.38
        ,noDrag = true
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil

    self.lastShowId = nil

    -- 点击任意地方，是否是提交任务
    self.AnywayCommitId = 0
    -- 点击任意地方做任务链任务
    self.AnywayDoChain = false
    -- 点击任意地方回调
    self.AnywayCallback = nil
    -- 需要超时关闭的
    self.TimeoutId = 0
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function DialogDramaPanel:__delete()
    if self.msg ~= nil then
        self.msg:DeleteMe()
        self.msg = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.dramaOption ~= nil then
        self.dramaOption:DeleteMe()
        self.dramaOption = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.stringTab = nil
    self.stringover = false
    self.AnywayCommitId = 0
    self.AnywayCallback = nil

    if self.TimeoutId ~= 0 then
        LuaTimer.Delete(self.TimeoutId)
        self.TimeoutId = 0
    end
end

function DialogDramaPanel:OnHide()
    if self.TimeoutId ~= 0 then
        LuaTimer.Delete(self.TimeoutId)
        self.TimeoutId = 0
    end
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function DialogDramaPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.drama_talk))
    self.gameObject.name = "DialgDramaPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(NoticeManager.Instance.model.noticeCanvas, self.gameObject)
    self.transform:SetSiblingIndex(3)
    self.gameObject.transform.localPosition = Vector3.zero
    self.gameObject:SetActive(false)

    self.nameTrans = self.transform:Find("Name").gameObject:GetComponent(RectTransform)
    self.nameTxt = self.nameTrans:Find("Text"):GetComponent(Text)
    self.standBgTrans = self.transform:Find("StandBg").gameObject:GetComponent(RectTransform)
    self.contentTrans = self.transform:Find("ContentContainer/Content").gameObject:GetComponent(RectTransform)
    self.contentContainer = self.transform:Find("ContentContainer").gameObject
    self.contentTxt = self.transform:Find("ContentContainer/Content/Content"):GetComponent(Text)
    self.contentTxtRect = self.contentTxt.gameObject:GetComponent("RectTransform")
    self.scrollRect = self.transform:Find("ContentContainer/Content"):GetComponent("ScrollRect")
    self.scrollRect.enabled = false
    self.rawImage = self.transform:Find("RawImage").gameObject
    self.rawImageTrans = self.rawImage:GetComponent(RectTransform)
    -- self.rawImage:SetActive(false)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickNext() end)
    self.optionObj = self.transform:Find("Option").gameObject
    self.optionObj:SetActive(false)

    self.nameTrans.anchoredPosition = Vector2(-130, 168)
    self.standBgTrans.anchoredPosition = Vector2(-320, 10)
    self.contentTrans.anchoredPosition = Vector2(280, -35)
    self.rawImageTrans.anchoredPosition = Vector2(-320, 220)

    self.msg = MsgItemExt.New(self.contentTxt, 501, 18, 23)

    if RoleManager.Instance.RoleData.lev < 20 then
        self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
        local effectTransform = self.effect.transform
        effectTransform:SetParent(self.contentContainer.transform)
        effectTransform.transform.localScale = Vector3.one
        effectTransform.transform.localPosition = Vector3(180, 60, -400)
        self.effect:SetActive(false)
    end

    self:ClearMainAsset()
end

function DialogDramaPanel:SetRawImage(composite)
    local image = composite.rawImage
    image.transform:SetParent(self.rawImage.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3(20, 0, 0)
    composite.tpose.transform:Rotate(Vector3(0, 0, 0))
    self.rawImage:SetActive(true)
end

function DialogDramaPanel:ShowPreview(npcData)
    self.npcData = npcData
    self.nameTxt.text = self.npcData.name

    self.gameObject:SetActive(true)

    -- npc在左边
    if self.lastShowId ~= self.npcData.id then
        self.lastShowId = self.npcData.id
        -- self.rawImage:SetActive(false)
        if npcData.home then
            local modelData = {type = PreViewType.Home, skinId = npcData.skin, modelId = npcData.res, animationId = npcData.animation_id, scale = 0.35, }
            self:Preview(modelData)
        elseif npcData.classes == nil or npcData.sex == nil or npcData.classes == 0 then
            local modelData = {type = PreViewType.Npc, skinId = npcData.skin, modelId = npcData.res, animationId = npcData.animation_id, scale = 1}
            if self.npcData.dialog_scale ~= nil and self.npcData.dialog_scale ~= 0 then
                modelData.scale = self.npcData.dialog_scale / 100
            end
            self:Preview(modelData)
        else
            local modelData = {type = PreViewType.Role, classes = npcData.classes, sex = npcData.sex, looks = npcData.looks}
            self:Preview(modelData)
        end
    end
    if self.previewComp ~= nil then
        self.previewComp:Show()
        self.previewComp:PlayAction(FighterAction.Stand)
    end
    

    if self.TimeoutId ~= 0 then
        LuaTimer.Delete(self.TimeoutId)
        self.TimeoutId = 0
    end

    -- print(string.format("设置超时关闭 %s", self.model.TimeoutClose))
    if self.model.TimeoutClose ~= 0 then
        local a = self.model.TimeoutClose
        self.model.TimeoutClose = 0
        self.TimeoutId = LuaTimer.Add(a, function() self:OnClickNext() end)
    end
end

function DialogDramaPanel:Preview(modelData)
    if modelData ~= nil then
        local callback = function(composite)
            if modelData.modelId == 40068 or modelData.modelId == 40168 or modelData.modelId == 40268 or modelData.modelId == 40368 then
                if not BaseUtils.isnull(composite.tpose) then
                    composite.tpose.transform:Rotate(Vector3(-20, 0, 0))
                    composite.tpose.transform.localPosition = Vector3(-40, -145, -150)
                end
            end
        end
        
        if modelData.scale == nil then
            modelData.scale = 3
        else
            modelData.scale = modelData.scale * 3
        end
        if self.previewComp == nil then
            local setting = {
                name = "DialogPreview"
                ,layer = "UI"
                ,parent = self.rawImage.transform
                ,localRot = Vector3(0, 0, 0)
                ,localPos = Vector3(0, -175, -150)
                ,usemask = false
                ,sortingOrder = 21
            }
            self.previewComp = PreviewmodelComposite.New(callback, setting, modelData)
        else
            self.previewComp:Reload(modelData, callback)
        end
        self.previewComp:Show()
    end
end

function DialogDramaPanel:OnClickNext()
    SoundManager.Instance:Play(214)
    if self.AnywayCommitId ~= 0 then
        QuestManager.Instance:Send10206(self.AnywayCommitId)
        self.AnywayCommitId = 0
    elseif self.AnywayDoChain then
        QuestManager.Instance.model:DoChain()
        self.AnywayDoChain = false
    elseif self.AnywayCallback ~= nil then
        self.AnywayCallback()
        self.AnywayCallback = nil
    end
    if self.TimeoutId ~= 0 then
        LuaTimer.Delete(self.TimeoutId)
        self.TimeoutId = 0
    end
    self.TimeoutClose = 0
    -- self:Hiden()
    self.model:Hide()
    if self.dramaOption ~= nil then
        self.dramaOption:Hiden()
    end
end

function DialogDramaPanel:ShowOption(options)
    if self.optionObj == nil then
        return
    end

    self.AnywayDoChain = false
    self.AnywayCommitId = 0
    if self.dramaOption == nil then
        self.dramaOption = DialogTalkOption.New(self)
        self.dramaOption:InitPanel(self.optionObj)
    end
    return self.dramaOption:Show(options)
end

function DialogDramaPanel:ChangeText(str)
    if self.msg == nil or self.contentTxtRect == nil then
        return
    end

    if self.msg ~= nil then
        self.msg:SetData(QuestEumn.FilterContent(str))

        if self.msg.selfHeight > 120 then
            self.scrollRect.enabled = true
        else
            self.scrollRect.enabled = false
        end
        self.contentTxtRect.anchoredPosition = Vector2(self.contentTxtRect.anchoredPosition.x, 0)
    end
end

function DialogDramaPanel:ShowFinger(bool)
    if not BaseUtils.isnull(self.effect) then
        self.effect:SetActive(bool)
    end
end
