ArenaGuardPanel = ArenaGuardPanel or BaseClass(BasePanel)

function ArenaGuardPanel:__init(parent, model)
    self.model = model
    self.parent = parent
    self.mgr = ArenaManager.Instance

    self.resList = {
        {file = AssetConfig.arena_guild_tips, type = AssetType.Main}
        , {file = AssetConfig.arena_textures, type = AssetType.Dep}
        , {file = AssetConfig.guard_head, type = AssetType.Dep}
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.reloadListener = function(index) self:ReloadTeam(index) end

    self.guardList = {}
    self.image = {}

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ArenaGuardPanel:__delete()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    for _,v in pairs(self.image) do
        if v ~= nil then
            v.sprite = nil
        end
        self.image = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ArenaGuardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.arena_guild_tips))
    self.gameObject.name = "ArenaGuardPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    local main = self.transform:Find("Main")

    self.panelBgBtn = self.transform:Find("Panel"):GetComponent(Button)
    self.challengeBtn = main:Find("Button"):GetComponent(Button)
    self.teamContainer = main:Find("Team/Container")
    self.teamCloner = main:Find("Team/Icon").gameObject
    local rect = self.teamCloner:GetComponent(RectTransform)
    self.clonerX = rect.sizeDelta.x
    self.clonerY = rect.sizeDelta.y
    self.teamRect = main:Find("Team"):GetComponent(RectTransform)
    self.teamContainerRect = self.teamContainer:GetComponent(RectTransform)

    self.teamCloner:SetActive(false)

    self.panelBgBtn.onClick:RemoveAllListeners()
    self.panelBgBtn.onClick:AddListener(function() self:OnClose() end)

    self.OnOpenEvent:Fire()
end

function ArenaGuardPanel:OnClose()
    self.model:CloseGuardTips()
end

function ArenaGuardPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateFellowGuard:AddListener(self.reloadListener)
    self.challengeBtn.onClick:RemoveAllListeners()
    self.challengeBtn.onClick:AddListener(function() self:OnClose() self.mgr:send12201({order = self.openArgs}) end)

    self:ReloadTeam(self.openArgs)
end

function ArenaGuardPanel:RemoveListeners()
    self.mgr.onUpdateFellowGuard:RemoveListener(self.reloadListener)
end

function ArenaGuardPanel:OnHide()
    self:RemoveListeners()
end

function ArenaGuardPanel:ReloadTeam(index)
    local model = self.model
    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.teamContainer, {axis = BoxLayoutAxis.X, cspacing = 0})
    end
    if self.guardList[1] == nil then
        self.guardList[1] = GameObject.Instantiate(self.teamCloner)
        self.guardList[1].name = "1"
        self.layout:AddCell(self.guardList[1])
    end
    self.image[1] = self.guardList[1].transform:Find("Image"):GetComponent(Image)

    local fellow = nil
    if model.fellows ~= nil then
        for _,v in pairs(model.fellows) do
            if v.order == index then
                fellow = v
                break
            end
        end
    end

    if fellow ~= nil then
        if fellow.classes <= 0 then
            self.image[1].sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "Unknow")
            self.image[1].gameObject:SetActive(true)
            self.teamContainerRect.sizeDelta = Vector2(self.clonerX, self.clonerY)
            self.teamRect.sizeDelta = Vector2(self.clonerX, self.clonerY)
        else
            self.image[1].sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, BaseUtils.Key(fellow.classes, fellow.sex))
        end

        local guards = model.fellowGuards[index]
        if guards == nil then
            ArenaManager.Instance:send12209(index)
            guards = {}
        end
        local guardIds = {}
        for k,v in pairs(guards) do
            if v ~= nil and v.guard_id > 0 then
                table.insert(guardIds, v.guard_id)
            end
        end

        self.image[1].gameObject:SetActive(true)

        for i,v in ipairs(guardIds) do
            if self.guardList[i + 1] == nil then
                self.guardList[i + 1] = GameObject.Instantiate(self.teamCloner)
                self.guardList[i + 1].name = tostring(i + 1)
                self.layout:AddCell(self.guardList[i + 1])
            end
            self.guardList[i + 1]:SetActive(true)
            self.image[i + 1] = self.guardList[i + 1].transform:Find("Image"):GetComponent(Image)
            self.image[i + 1].sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(v))
            self.image[i + 1].gameObject:SetActive(true)
        end
        for i=#guardIds + 2, #self.guardList do
            self.guardList[i]:SetActive(false)
        end
        self.teamContainerRect.sizeDelta = Vector2((#guardIds + 1) * self.clonerX, self.clonerY)
        self.teamRect.sizeDelta = self.teamContainerRect.sizeDelta
    end
end
