Demo2Window = Demo2Window or BaseClass(BaseWindow)

function Demo2Window:__init(model)
    self.model = model
    self.name = "Demo2Window"
    self.resList = {
        {file = AssetConfig.demo2_window, type = AssetType.Main}
        ,{file = AssetConfig.no1inworld_textures, type = AssetType.Dep}
    }

    self.subFirst = nil
    self.subSecond = nil
    self.mainObj = nil
end

function Demo2Window:__delete()
    if self.subFirst ~= nil then
        self.subFirst:DeleteMe()
        self.subFirst = nil
    end
    if self.subSecond ~= nil then
        self.subSecond:DeleteMe()
        self.subSecond = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function Demo2Window:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.demo2_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "Demo2Window"
    self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    self.gameObject.transform.localScale = Vector3.one
    self.gameObject.transform.localPosition = Vector3.zero
    BaseUtils.ChangeLayersRecursively(self.gameObject.transform, "UI")
    self.mainObj = self.gameObject.transform:Find("Main").gameObject

    local closeBtn = self.gameObject.transform:Find("Main/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    local tabGroup = self.gameObject.transform:Find("Main/TabButtonGroup").gameObject
    tabGroup.transform:GetChild(0):GetComponent(Button).onClick:AddListener(function() self:TabChange(1) end)
    tabGroup.transform:GetChild(1):GetComponent(Button).onClick:AddListener(function() self:TabChange(2) end)

    self.gameObject:SetActive(true)
    self:TabChange(1)
end

function Demo2Window:OnClickClose()
    self.model:CloseMain()
end

function Demo2Window:TabChange(index)
    if index == 1 then
        self:ShowFirst(true)
        self:ShowSecond(false)
    else
        self:ShowSecond(true)
        self:ShowFirst(false)
    end
end

function Demo2Window:ShowFirst(IsShow)
    if IsShow then
        if self.subFirst == nil then
            self.subFirst = Demo2Sub1Panel.New(self)
        end
        self.subFirst:Show()
    else
        if self.subFirst ~= nil then
            self.subFirst:Hiden()
        end
    end
end

function Demo2Window:ShowSecond(bool)
    if bool then
        if self.subSecond == nil then
            self.subSecond = Demo2Sub2Panel.New(self)
        end
        self.subSecond:Show()
    else
        if self.subSecond ~= nil then
            self.subSecond:Hiden()
        end
    end
end
