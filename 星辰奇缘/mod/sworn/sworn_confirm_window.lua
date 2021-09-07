-- @author 黄耀聪
-- @date 2016年11月4日

SwornConfirmWindow = SwornConfirmWindow or BaseClass(BaseWindow)

function SwornConfirmWindow:__init(model)
    self.model = model
    self.name = "SwornConfirmWindow"
    self.windowId = WindowConfig.WinID.sworn_confirm_window

    self.resList = {
        {file = AssetConfig.sworn_confirm_window, type = AssetType.Main},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
    }

    self.memberList = {}
    self.confirmString = TI18N("我<color='#ffff00'>%s</color>在此立誓:\n  愿以<color='#ff00ff'>%s</color>为名，与%s结为异姓兄弟姐妹，从此有福同享，有难同当！")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornConfirmWindow:__delete()
    self.OnHideEvent:Fire()
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SwornConfirmWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_confirm_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.result = main:Find("Result")
    for i=1,5 do
        local tab = {}
        tab.transform = self.result:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.headImage = tab.transform:Find("Mask/Head"):GetComponent(Image)
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        tab.honorText = tab.transform:Find("Rank/Text"):GetComponent(Text)
        tab.figure = tab.transform:Find("Figure").gameObject
        self.memberList[i] = tab
    end

    self.descExt = MsgItemExt.New(main:Find("DescBg/Text"):GetComponent(Text), 503, 16, 28)

    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    main:Find("Button"):GetComponent(Button).onClick:AddListener(function() self.model:ReadyFire() WindowManager.Instance:CloseWindow(self) end)
end

function SwornConfirmWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornConfirmWindow:OnOpen()
    self:RemoveListeners()

    self:Reload()
end

function SwornConfirmWindow:OnHide()
    self:RemoveListeners()
end

function SwornConfirmWindow:RemoveListeners()
end

function SwornConfirmWindow:Reload()
    local members = (self.model.swornData or {}).members or {}
    local stringFormat = "<color='#01c0ff'>%s</color>"
    for i=1,5 do
        local tab = self.memberList[i]
        if members[i] == nil then
            tab.headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.sworn_textures, "Unknow")
            tab.nameText.text = ""
            tab.honorText.text = ""
            tab.figure:SetActive(false)
        else
            tab.figure:SetActive(true)
            tab.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, members[i].classes .. "_" .. members[i].sex)
            tab.nameText.text = members[i].name
            tab.honorText.text = self.model.normalList[i]
        end
    end
    local tab = {}
    for i=1,#members do
        if i ~= self.model.myPos and members[i] ~= nil then
            table.insert(tab, members[i].name)
        end
    end

    local s = ""
    s = s .. string.format(stringFormat, tab[1])
    for i=2,#tab do
        s = s .. "、"..string.format(stringFormat, tab[i])
    end

    self.descExt:SetData(string.format(self.confirmString, RoleManager.Instance.RoleData.name, self.model.swornData.name .. TI18N("之") .. self.model.rankList[self.model.myPos] .. members[self.model.myPos].name_defined, s))
end


