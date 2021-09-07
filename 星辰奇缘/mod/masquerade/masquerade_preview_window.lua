-- @author 黄耀聪
-- @date 2016年7月2日

MasqueradePreviewWindow = MasqueradePreviewWindow or BaseClass(BaseWindow)

function MasqueradePreviewWindow:__init(model)
    self.model = model
    self.name = "MasqueradePreviewWindow"
    self.mgr = MasqueradeManager.Instance

    self.windowId = WindowConfig.WinID.masquerade_preview_window

    self.resList = {
        {file = AssetConfig.masquerade_preview_window, type = AssetType.Main},
        {file  =  AssetConfig.totembg, type  =  AssetType.Dep}
    }

    self.confirmString = TI18N("进入下层(%s)")

    self.timeListener = function() self:OnTime() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MasqueradePreviewWindow:__delete()
    self.OnHideEvent:Fire()
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MasqueradePreviewWindow:InitPanel()
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
    self.attrText = t:Find("Main/Attr"):GetComponent(Text)
    self.confirmBtn = t:Find("Main/Confirm"):GetComponent(Button)
    self.confirmText = t:Find("Main/Confirm/Text"):GetComponent(Text)

    self.confirmBtn.onClick:AddListener(function() self:OnConfirm() end)
end

function MasqueradePreviewWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MasqueradePreviewWindow:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateTime:AddListener(self.timeListener)

    local model = self.model

    -- local id = self.openArgs
    local id = nil
    local transform_id = nil

    self.targetTime = BaseUtils.BASE_TIME + 5

    if self.openArgs < 6 then
        self.attrText.text = DataBuff.data_list[DataElf.data_floor[self.openArgs].buff_id].desc
        self.descText.text = DataElf.data_floor[self.openArgs].msg
        transform_id = DataElf.data_floor[self.openArgs].transform_id
    else
        self.attrText.text = DataBuff.data_list[DataElf.data_floor[model.max_floor].grade_buff_id].desc
        self.descText.text = DataElf.data_floor[model.max_floor].grade_msg
        transform_id = DataElf.data_floor[model.max_floor].grade_transform_id
    end

    local transformData = DataTransform.data_transform[transform_id]

    if transformData ~= nil then
        -- BaseUtils.dump(transformData, "变身数据")
        local data = {type = PreViewType.Pet, skinId = transformData.skin, modelId = transformData.res, animationId = transformData.animation_id, scale = 1, effects = {}}

        local callback = function(composite)
            self:SetRawImage(composite)
        end

        if self.previewComposite == nil then
            local setting = {
                name = "MasqueradePreview"
                ,orthographicSize = 0.6
                ,width = 256
                ,height = 256
                ,offsetY = -0.3
            }
            self.previewComposite = PreviewComposite.New(callback, setting, data)
        else
            self.previewComposite:Reload(data, callback)
        end
    end


    self:OnTime()
end

function MasqueradePreviewWindow:OnHide()
    self:RemoveListeners()
end

function MasqueradePreviewWindow:RemoveListeners()
    self.mgr.onUpdateTime:RemoveListener(self.timeListener)
end

function MasqueradePreviewWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.previewContainer.gameObject:SetActive(true)
end

function MasqueradePreviewWindow:OnConfirm()
    if self.openArgs ~= 1 and self.openArgs ~= 6 then
        self.mgr:send16509()
    end
    self.model:ClosePreviewWindow()
end

function MasqueradePreviewWindow:OnTime()
    if self.openArgs ~= 1 and self.openArgs ~= 6 then
        local diff = self.targetTime - BaseUtils.BASE_TIME
        if diff > 0 then
            self.confirmText.text = string.format(self.confirmString, tostring(diff))
        else
            self.confirmText.text = TI18N("确 定")
        end
        if diff == 0 then
            if self.openArgs ~= 1 and self.openArgs ~= 6 then
                self.mgr:send16509()
            end
        end
    else
        self.confirmText.text = TI18N("确 定")
    end
end

