-- @author 黄耀聪
-- @date 2016年11月1日

SwornGetoutWindow = SwornGetoutWindow or BaseClass(BaseWindow)

function SwornGetoutWindow:__init(model)
    self.model = model
    self.name = "SwornGetoutWindow"
    self.windowId = WindowConfig.WinID.sworn_getout

    self.resList = {
        {file = AssetConfig.sworn_getout, type = AssetType.Main},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
    }

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornGetoutWindow:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.model.selectGetout = nil
    self:AssetClearAll()
end

function SwornGetoutWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_getout))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    local main = t:Find("Main")
    self.container = main:Find("Scroll/Container")
    self.cloner = main:Find("Scroll/Cloner").gameObject
    self.sureBtn = main:Find("Sure"):GetComponent(Button)
    self.cancelBtn = main:Find("Cancel"):GetComponent(Button)

    self.sureBtn.onClick:AddListener(function() self:OnClick() end)
    self.cancelBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, border = 10, cspacing = 10})
    for i=1,10 do
        local obj = GameObject.Instantiate(self.cloner)
        self.itemList[i] = SwornGetoutItem.New(self.model, obj)
        layout:AddCell(obj)
    end
    layout:DeleteMe()
    self.cloner:SetActive(false)
end

function SwornGetoutWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornGetoutWindow:OnOpen()
    self:RemoveListeners()
    self.model.selectGetouInfo = nil

    self:Reload()
end

function SwornGetoutWindow:Reload()
    local members = (self.model.swornData or {}).members or {}
    local data = {}
    local roleData = RoleManager.Instance.RoleData
    for _,v in ipairs(members) do
        if v.m_id ~= roleData.id or v.m_platform ~= roleData.platform or v.m_zone_id ~= roleData.zone_id then
            table.insert(data, v)
        end
    end
    for i,v in ipairs(data) do
        self.itemList[i]:update_my_self(v)
    end
    for i=#data + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
    self.cloner:SetActive(false)
    self.container.sizeDelta = Vector2(313, #data * 90)
end

function SwornGetoutWindow:OnHide()
    self:RemoveListeners()
end

function SwornGetoutWindow:RemoveListeners()
end

function SwornGetoutWindow:OnClick()
    if self.model.selectGetouInfo == nil then
        return
    end

    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_reason)
end

SwornGetoutItem = SwornGetoutItem or BaseClass()

function SwornGetoutItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    local t = gameObject.transform
    self.transform = t

    self.headImage = t:Find("Head/Image"):GetComponent(Image)
    self.classIconImage = t:Find("Icon"):GetComponent(Image)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.honorText = t:Find("Honor"):GetComponent(Text)
    self.select = t:Find("Select").gameObject

    gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
end

function SwornGetoutItem:update_my_self(data)
    self.data = data
    self.gameObject:SetActive(true)
    self.nameText.text = data.name
    self.honorText.text = string.format(TI18N("<color='#00ff00'>%s</color>之<color='#ffff00'>%s%s</color>"), self.model.swornData.name, self.model.rankList[data.pos], data.name_defined)
    self.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes .. "_" .. data.sex)
    self.classIconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. data.classes)

    self.select:SetActive(self.model.selectGetouInfo ~= nil and (self.model.selectGetouInfo.id == data.m_id and self.model.selectGetouInfo.platform == data.m_platform and self.model.selectGetouInfo.zone_id == self.data.m_zone_id))
end

function SwornGetoutItem:OnClick()
    if self.model.selectGetout ~= nil then
        self.model.selectGetout:SetActive(false)
    end
    self.model.selectGetouInfo = {id = self.data.m_id, platform = self.data.m_platform, zone_id = self.data.m_zone_id}
    self.select:SetActive(true)
    self.model.selectGetout = self.select
end

function SwornGetoutItem:__delete()
    self.headImage.sprite = nil
    self.classIconImage.sprite = nil
end



