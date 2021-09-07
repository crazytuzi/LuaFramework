-- @author zgs
-- @date 2016年9月26日

NationalDaySuccessWindow = NationalDaySuccessWindow or BaseClass(BasePanel)

function NationalDaySuccessWindow:__init(model)
    self.model = model
    self.name = "NationalDaySuccessWindow"
    self.mgr = NationalDayManager.Instance

    self.resList = {
        {file = AssetConfig.masquerade_preview_window, type = AssetType.Main},
        {file  =  AssetConfig.totembg, type  =  AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.timeIdForAutoClose = 0
end

function NationalDaySuccessWindow:__delete()
    -- self.OnHideEvent:Fire()
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.timeIdForAutoClose ~= nil then
        LuaTimer.Delete(self.timeIdForAutoClose)
    end
    self:AssetClearAll()
end

function NationalDaySuccessWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.masquerade_preview_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t
    local panelBtn = t:Find("Panel"):GetComponent(Button)
    GameObject.Destroy(panelBtn)

    -- bigbg处理
    -- hosr
    t:Find("Main/Preview/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")

    self.previewContainer = t:Find("Main/Preview")
    self.descText = t:Find("Main/Desc"):GetComponent(Text)
    self.descText.alignment = TextAnchor.UpperCenter
    self.attrText = t:Find("Main/Attr"):GetComponent(Text)
    self.attrText.transform.anchorMax = Vector2(0,1)
    self.attrText.transform.anchorMin = Vector2(0,1)
    self.attrText.transform.pivot = Vector2(0,1)
    self.confirmBtn = t:Find("Main/Confirm"):GetComponent(Button)
    self.confirmText = t:Find("Main/Confirm/Text"):GetComponent(Text)

    self.confirmBtn.onClick:AddListener(function() self:OnConfirm() end)

    self.gameObject.transform.localPosition = Vector3(0, 0, -1200)
end

function NationalDaySuccessWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NationalDaySuccessWindow:OnOpen()
    -- self.mgr.onUpdateTime:AddListener(self.timeListener)

    local model = self.model

    -- local id = self.openArgs
    local id = nil

    self.targetTime = BaseUtils.BASE_TIME + 5

    self.descExt = MsgItemExt.New(self.attrText, 256, 17, 20)
    self.descExt:SetData(TI18N("<color='#ffff00'>酒麦大叔</color>很赞赏你，特邀你再次参加<color='#00ff00'>特殊护送</color>，奖励更丰厚哦{face_1,56}"))

    self.attrText.transform.anchorMax = Vector2(0.5,1)
    self.attrText.transform.anchorMin = Vector2(0.5,1)
    self.attrText.transform.pivot = Vector2(0.5,1)
    self.attrText.transform.anchoredPosition = Vector2(0,-250)

    self.descText.text = string.format(TI18N("蛋糕欢乐送"))

    local petData = DataUnit.data_unit[74134] --跟据ID，取模型数据

    local data = {type = PreViewType.Pet, skinId = petData.skin, modelId = petData.res, animationId = petData.animation_id, scale = petData.scale / 100, effects = petData.effects}
    -- local data = {type = PreViewType.Pet, skinId = transformData.skin, modelId = transformData.res, animationId = transformData.animation_id, scale = 1, effects = {}}

    local callback = function(composite)
        self:SetRawImage(composite)
    end

    if self.previewComposite == nil then
        local setting = {
            name = "MasqueradePreview"
            ,orthographicSize = 0.6
            ,width = 256
            ,height = 256
            ,offsetY = -0.37
        }
        self.previewComposite = PreviewComposite.New(callback, setting, data)
    else
        self.previewComposite:Reload(data, callback)
    end

     if self.timeIdForAutoClose ~= nil then
        LuaTimer.Delete(self.timeIdForAutoClose)
    end
    -- self.timeIdForAutoClose = LuaTimer.Add(3000,function ()
    --     self.model:ClosePreviewWindow()
    -- end)
end

function NationalDaySuccessWindow:OnHide()
    -- self:DeleteMe()
end

function NationalDaySuccessWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.previewContainer.gameObject:SetActive(true)
end

function NationalDaySuccessWindow:OnConfirm()
    -- if self.openArgs ~= 1 and self.openArgs ~= 6 then
    --     self.mgr:send16509()
    -- end
    local key = BaseUtils.get_unique_npcid(65, 1)
    SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, key, nil, nil, true)
    self.model:ClosePreviewWindow()
end
