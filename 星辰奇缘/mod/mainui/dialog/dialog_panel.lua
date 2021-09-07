-- ------------------------
-- npc对话框
-- hosr
-- ------------------------
DialogPanel = DialogPanel or BaseClass(BasePanel)

function DialogPanel:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.dialog, type = AssetType.Main},
        {file = AssetConfig.dialog_res, type = AssetType.Dep},
    }

    self.setting = {
        name = "DialogPreview"
        ,orthographicSize = 0.5
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil
    self.timerId = 0
    self.isOpen = false
    self.needDelete = false
end

function DialogPanel:__delete()
    self:DeletePreview()
end

function DialogPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dialog))
    self.gameObject:SetActive(false)
    self.gameObject.name = "DialogPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(MainUIManager.Instance.MainUICanvasView.gameObject.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    local rect = self.gameObject:GetComponent(RectTransform)
    rect.localPosition = Vector3.zero
    rect.anchoredPosition = Vector2.zero

    self.preview = self.transform:Find("Window/RawImage").gameObject
    self.preview:GetComponent(CanvasGroup).blocksRaycasts = false
    self.preview:SetActive(false)
    self.npcName = self.transform:Find("Window/Name/Text"):GetComponent(Text)
    self.npcName.text = ""
    self.contentTxt = self.transform:Find("Window/Content"):GetComponent(Text)
    self.contentTxt.text = ""

    -- self.showInfo = self.transform:Find("Window/Show").gameObject

    self.questInfo = DialogQuest.New(self, self.transform:Find("Window/TaskInfo").gameObject)
    self.optionInfo = DialogOption.New(self, self.transform:Find("Window/Options").gameObject)

    self.transform:Find("Window/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self:Show(self.openArgs)
end

function DialogPanel:Show(args)
    self.openArgs = args
    if self.gameObject ~= nil then
        local isOpen = self:SetData(self.openArgs[1], self.openArgs[2])
        if isOpen then
            if self.npcData ~= nil then
                local modelData = {type = PreViewType.Npc, skinId = self.npcData.skin, modelId = self.npcData.res, animationId = self.npcData.animation_id, scale = 1}
                if self.npcData.dialog_scale ~= nil and self.npcData.dialog_scale ~= 0 then
                    modelData.scale = self.npcData.dialog_scale / 100
                end
                self:LoadPreview(modelData)
            end
            self.isOpen = true
            self.gameObject:SetActive(true)
        end
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function DialogPanel:Hiden()
    if self.gameObject ~= nil then
        self.isOpen = false
        self.gameObject:SetActive(false)
        if self.needDelete then
            self:DeletePreview()
        end
    end
end

function DialogPanel:SetData(npcData, tasks)
    self.questInfo.gameObject:SetActive(false)
    self.optionInfo.gameObject:SetActive(false)

    self.npcData = npcData
    self.special = false
    self.npcName.text = npcData.name
    self.contentTxt.text = ""

    local ok = true
    if #npcData.buttons == 0 then
        if #tasks == 1 then
            ok = self.questInfo:ShowQuest(tasks[1])
        else
            ok = self.optionInfo:ShowOption(npcData, tasks)
        end
    else
        if #npcData.buttons == 1 and #tasks == 0 then
            --如果只有一个功能，没有任务，直接处理相关功能,不打开对话框
            local action = npcData.buttons[1].button_id
            local args = npcData.buttons[1].button_args
            local rule = npcData.buttons[1].button_show

            if action ~= 5 and action ~= 6 and action ~= 8 and action ~= 9 and action ~= 11 and action ~= 16 then
                self.model:ButtonAction(action, args, rule)
                return false
            -- elseif mod_convoy.convoydata ~= nil and mod_convoy.convoydata.start_time ~= 0 then
                -- ok = self.optionInfo:ShowOption(npcData, tasks)
            elseif action == 5 then
                npcData.buttons = {}
                ok = self.optionInfo:ShowOption(npcData, tasks)
            elseif action == 6 then
                ok = self.optionInfo:ShowOption(npcData, tasks)
            elseif action == 8 then
                ok = self.optionInfo:ShowOption(npcData, tasks)
            elseif action == 9 then
                ok = self.optionInfo:ShowOption(npcData, tasks)
            elseif action == 11 then
                ok = self.optionInfo:ShowOption(npcData, tasks)
             elseif action == 16 then
                ok = self.optionInfo:ShowOption(npcData, tasks)
            end
        else
            ok = self.optionInfo:ShowOption(npcData, tasks)
        end
    end

    -- if npcData.isrole then
    --     preview_id = -1
    --     ui_dialog.load_preview_role(npcData)
    -- elseif preview_id ~= npcData.id then
    --     preview_id = npcData.id
    --     ui_dialog.load_preview(npcData)
    -- end

    if self.special then
        return false
    end
    return ok
end

function DialogPanel:ShowContent(str)
    self.contentTxt.text = str
end

function DialogPanel:LoadPreview(modelData)
    self.preview:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function DialogPanel:SetRawImage(composite)
    self:BeginTimer()
    local image = composite.rawImage
    image.transform:SetParent(self.preview.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3.zero
    self.preview:SetActive(true)
end

-- 开启倒计时，完了删掉对话预览
function DialogPanel:BeginTimer()
    self.needDelete = false
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(3*60*1000, function() self.needDelete = true  self:DeletePreview() end)
end

function DialogPanel:DeletePreview()
    if self.isOpen then
        return
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
end