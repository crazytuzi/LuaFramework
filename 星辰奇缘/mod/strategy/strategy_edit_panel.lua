-- @author 黄耀聪
-- @date 2016年7月7日

StrategyEditPanel = StrategyEditPanel or BaseClass(BasePanel)

function StrategyEditPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "StrategyEditPanel"
    self.mgr = StrategyManager.Instance

    self.resList = {
        {file = AssetConfig.strategy_edit_panel, type = AssetType.Main},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function StrategyEditPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function StrategyEditPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strategy_edit_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.titleInputField = t:Find("TitleEdit/InputField"):GetComponent(InputField)
    self.contentInputField = t:Find("ContentEdit/InputField"):GetComponent(InputField)

    self.saveBtn = t:Find("Save"):GetComponent(Button)
    self.uploadBtn = t:Find("Upload"):GetComponent(Button)
    self.collectBtn = t:Find("Collect"):GetComponent(Button)
    self.deleteBtn = t:Find("Delete"):GetComponent(Button)
    self.backBtn = t:Find("Back"):GetComponent(Button)

    self.saveBtn.onClick:AddListener(function() self:SaveToDraft() end)
    self.uploadBtn.onClick:AddListener(function() self:UploadDraft() end)
    self.collectBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {2, 0}) end)
    self.deleteBtn.onClick:AddListener(function() self:OnDelete() end)
    self.backBtn.onClick:AddListener(function() self:OnBack() end)
end

function StrategyEditPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StrategyEditPanel:OnOpen()
    local model = self.model
    self:RemoveListeners()
    self.extra = self.extra or {}
    self.type = self.extra.type
    self.model.currentDraftId = self.extra.id
    self.model.currentTitleId = self.extra.title_id

    model._tmp = model._tmp or {}

    if self.extra.name ~= nil then self.titleInputField.text = self.extra.name
    else self.titleInputField.text = model._tmp.title or ""
    end
    if self.extra.content ~= nil then self.contentInputField.text = self.extra.content
    else self.contentInputField.text = model._tmp.content or ""
    end

    self.timerId = LuaTimer.Add(10 * 1000, 30 * 1000, function()
        model._tmp = model._tmp or {}
        model._tmp.title = self.titleInputField.text
        model._tmp.content = self.contentInputField.text
    end)
end

function StrategyEditPanel:OnHide()
    self:RemoveListeners()
end

function StrategyEditPanel:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function StrategyEditPanel:SaveToDraft()
    local model = self.model
    if self.titleInputField.text == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("填写标题后才能保存喔{face_1,9}"))
        return
    end
    if model.currentDraftId == nil then
        model.currentDraftId = BaseUtils.BASE_TIME
    end
    if model.draftTab[model.currentDraftId] == nil then
        model.draftTab[model.currentDraftId] = {name = self.titleInputField.text, content = self.contentInputField.text, lastEditTime = BaseUtils.BASE_TIME}
    else
        model.draftTab[model.currentDraftId].name = self.titleInputField.text
        model.draftTab[model.currentDraftId].content = self.contentInputField.text
        model.draftTab[model.currentDraftId].lastEditTime = BaseUtils.BASE_TIME
    end
    model:SaveDraft()
    NoticeManager.Instance:FloatTipsByString(TI18N("保存成功{face_1,38}"))
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {2, 0})
end

function StrategyEditPanel:UploadDraft()
    local model = self.model
    if self.titleInputField.text == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("填写标题后才能上传喔{face_1,9}"))
        return
    end
    if model.currentDraftId == nil then
        model.currentDraftId = BaseUtils.BASE_TIME
    end
    if model.draftTab[model.currentDraftId] == nil then
        model.draftTab[model.currentDraftId] = {name = self.titleInputField.text, content = self.contentInputField.text, lastEditTime = BaseUtils.BASE_TIME}
    else
        model.draftTab[model.currentDraftId].name = self.titleInputField.text
        model.draftTab[model.currentDraftId].content = self.contentInputField.text
        model.draftTab[model.currentDraftId].lastEditTime = BaseUtils.BASE_TIME
    end
    if self.type then
        if model.currentTitleId == nil then
            self.mgr:send16602(self.type, self.titleInputField.text, self.contentInputField.text, model.currentDraftId)
        else
            self.mgr:send16608(model.currentTitleId, self.type, self.titleInputField.text, self.contentInputField.text, model.currentDraftId)
        end
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {2, 0})
    else
        model:OpenTypePanel({name = self.titleInputField.text, content = self.contentInputField.text, local_id = model.currentDraftId, title_id = model.currentTitleId})
    end
end

function StrategyEditPanel:OnDelete()
    local model = self.model
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if model.currentDraftId ~= nil then
        model.draftTab[model.currentDraftId] = nil
        model:SaveDraft()
        NoticeManager.Instance:FloatTipsByString(TI18N("删除成功"))
    end
    model._tmp = model._tmp or {}
    model._tmp.title = self.titleInputField.text
    model._tmp.content = self.contentInputField.text
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {2, 0})
end

function StrategyEditPanel:OnBack()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {2, 0})
end

