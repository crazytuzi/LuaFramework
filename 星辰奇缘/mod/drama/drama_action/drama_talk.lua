-- --------------
-- 剧情对话
-- hosr
-- --------------
DramaTalk = DramaTalk or BaseClass(BaseDramaPanel)

function DramaTalk:__init()
    self.effectPath = "prefabs/effect/20014.unity3d"
    self.effect = nil
    self.resList = {
        {file = AssetConfig.drama_talk, type = AssetType.Main},
    }

    if RoleManager.Instance.RoleData.lev < 20 then
        table.insert(self.resList, {file = self.effectPath, type = AssetType.Main})
    end

    self.actionData = nil
    self.callback = nil
    self.stringTab = {}
    self.stringover = false
    self.currentStr = ""

    self.setting = {
        name = "DramaPreview"
        ,orthographicSize = 0.6
        ,width = 682
        ,height = 550
        -- ,offsetX = -0.25
        ,offsetY = -0.5
        ,noDrag = true
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil

    -- self.OneByOne = DramaOneByOne.New()
    -- self.OneByOne.callback = function() self:OneByOneEnd() end

    self.isSelf = false

    self.timeId = nil
end

function DramaTalk:__delete()
    -- print("DramaTalk:__delete")
    self:EndTime()

    if self.msg ~= nil then
        self.msg:DeleteMe()
        self.msg = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.OneByOne ~= nil then
        self.OneByOne:DeleteMe()
        self.OneByOne = nil
    end
    if self.effect ~= nil then
        GameObject.DestroyImmediate(self.effect)
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.effect = nil
    self.gameObject = nil
    self.stringTab = nil
    self.stringover = false
end

function DramaTalk:Hiden()
    self:EndTime()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

function DramaTalk:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.drama_talk))
    self.gameObject:SetActive(false)
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)

    self.nameTrans = self.transform:Find("Name").gameObject:GetComponent(RectTransform)
    self.nameTxt = self.nameTrans:Find("Text"):GetComponent(Text)
    self.standBgTrans = self.transform:Find("StandBg").gameObject:GetComponent(RectTransform)
    self.contentContainer = self.transform:Find("ContentContainer").gameObject
    self.contentTrans = self.transform:Find("ContentContainer/Content").gameObject:GetComponent(RectTransform)
    self.contentTxt = self.transform:Find("ContentContainer/Content/Content"):GetComponent(Text)
    self.contentTxtRect = self.contentTxt.gameObject:GetComponent("RectTransform")
    self.scrollRect = self.transform:Find("ContentContainer/Content"):GetComponent("ScrollRect")
    self.scrollRect.enabled = false
    self.rawImage = self.transform:Find("RawImage").gameObject
    self.rawImageTrans = self.rawImage:GetComponent(RectTransform)
    self.rawImage:SetActive(false)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickNext() end)
    self.transform:Find("Option").gameObject:SetActive(false)
    self.msg = MsgItemExt.New(self.contentTxt, 501, 18, 23)

    if RoleManager.Instance.RoleData.lev < 20 then
        self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
        local effectTransform = self.effect.transform
        effectTransform:SetParent(self.contentContainer.transform)
        effectTransform.transform.localScale = Vector3.one
        effectTransform.transform.localPosition = Vector3(180, 60, -400)
        self.effect:SetActive(false)
    end

    self.assetWrapper:ClearMainAsset()
end

function DramaTalk:SetRawImage(composite)
    if self.gameObject == nil then
        return
    end
    local image = composite.rawImage
    if image == nil then
        return
    end
    image.transform:SetParent(self.rawImage.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3(0, 55, 0)

    if self.isSelf then
        composite.tpose.transform:Rotate(Vector3(0, 20, 0))
    else
        composite.tpose.transform:Rotate(Vector3(0, -20, 0))
    end
    self.rawImage:SetActive(true)
    if RoleManager.Instance.RoleData.lev < 16 then
        self.effect:SetActive(true)
    end
    self.stringover = true
end

function DramaTalk:OnInitCompleted()
    self.actionData = self.openArgs
    if self.actionData.name == "0" then
        self.nameTxt.text = RoleManager.Instance.RoleData.name
    else
        self.nameTxt.text = self.actionData.name
    end
    self.contentTxt.text = ""
    self.rawImage:SetActive(false)
    local modelData = nil
    if self.actionData.unit_base_id == 0 then
        -- 角色在右边
        self.isSelf = true
        self.nameTrans.anchoredPosition = Vector2(130, 168)
        self.standBgTrans.anchoredPosition = Vector2(320, 10)
        self.contentTrans.anchoredPosition = Vector2(70, -35)
        self.rawImageTrans.anchoredPosition = Vector2(320, 220)
        modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = SceneManager.Instance:MyData().looks}
    else
        -- npc在左边
        self.isSelf = false
        self.nameTrans.anchoredPosition = Vector2(-130, 168)
        self.standBgTrans.anchoredPosition = Vector2(-320, 10)
        self.contentTrans.anchoredPosition = Vector2(280, -35)
        self.rawImageTrans.anchoredPosition = Vector2(-320, 220)
        local npcData = DataUnit.data_unit[self.actionData.unit_base_id]
        if npcData ~= nil then
            if npcData.classes == 0 then
                modelData = {type = PreViewType.Npc, skinId = npcData.skin, modelId = npcData.res, animationId = npcData.animation_id, scale = 1}
            else
                modelData = {type = PreViewType.Role, scale = 1, classes = npcData.classes, sex = npcData.sex, looks = BaseUtils.TransformBaseLooks(npcData.looks)}
            end
        end
    end
    self:Preview(modelData)
    self.gameObject:SetActive(true)
    self.step = 0
    self.stringover = true
    self.msg:SetData(QuestEumn.FilterContent(self.actionData.msg))

    if self.msg.selfHeight > 120 then
        self.scrollRect.enabled = true
    else
        self.scrollRect.enabled = false
    end
    self.contentTxtRect.anchoredPosition = Vector2(self.contentTxtRect.anchoredPosition.x, 0)

    self:BeginTime()
end

function DramaTalk:Preview(modelData)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

-- 点击背景,1。文字没出全就出全文字，2.文字出全了就回调
function DramaTalk:OnClickNext(isAuto)
    self:EndTime()
    if self.stringover then
        if self.callback ~= nil then
            self.callback()
        end
    else
        -- self.OneByOne:End()
    end
    if not isAuto then
        SoundManager.Instance:Play(214)
    end
end

function DramaTalk:OneByOneEnd()
    self.stringover = true
end

function DramaTalk:OnJump()
end

function DramaTalk:BeginTime()
    self:EndTime()
    if RoleManager.Instance.RoleData.lev <= AutoRunManager.Instance.levLimit and AutoRunManager.Instance.isOpen then
        self.timeId = LuaTimer.Add(AutoRunManager.Instance.timeLimit, function() self:OnClickNext(true) end)
    end
end

function DramaTalk:EndTime()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
end