-- @author 黄耀聪
-- @date 2017年11月14日, 星期二

GuildDragonEndRod = GuildDragonEndRod or BaseClass(BaseWindow)

function GuildDragonEndRod:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GuildDragonEndRod"
    self.windowId = WindowConfig.WinID.guilddragon_endrod

    self.resList = {
        {file = AssetConfig.guilddragon_endrod, type = AssetType.Main}
        , {file = AssetConfig.guilddragon_textures, type = AssetType.Dep}
        , {file = AssetConfig.challenge_title, type = AssetType.Main}
        , {file = AssetConfig.levelbreakeffect2, type = AssetType.Dep}
        , {file = AssetConfig.guildleaguebig, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildDragonEndRod:__delete()
    self.OnHideEvent:Fire()
    if self.scoreExt ~= nil then
        self.scoreExt:DeleteMe()
        self.scoreExt = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    self.transform:Find("Main"):GetComponent(Image).sprite = nil
    local circle = self.transform:Find("Main/Circle")
    for i=0,3 do
        circle:GetChild(i):GetComponent(Image).sprite = nil
    end
    self:AssetClearAll()
end

function GuildDragonEndRod:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_endrod))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local main = t:Find("Main")
    UIUtils.AddBigbg(main:Find("Title"), GameObject.Instantiate(self:GetPrefab(AssetConfig.challenge_title)))
    main:GetComponent(Image).sprite = self.assetWrapper:GetTextures(AssetConfig.guildleaguebig, "GuildLeague2")

    local circle = main:Find("Circle")
    for i=0,3 do
        circle:GetChild(i):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.levelbreakeffect2, "LevelBreakEffect2")
    end

    local battle = main:Find("Battle")
    self.nameText1 = battle:Find("Name1"):GetComponent(Text)
    self.nameText2 = battle:Find("Name2"):GetComponent(Text)
    self.win = battle:Find("Win")

    local info = main:Find("Info")
    self.turnNumText = info:GetChild(0):Find("Value"):GetComponent(Text)
    self.scoreExt = MsgItemExt.New(info:GetChild(1):Find("Value"):GetComponent(Text), 200, 19, 22)
    self.rankText = info:GetChild(2):Find("Value"):GetComponent(Text)

    self.previewContainer = main:Find("Preview")

    self.confirmBtn = main:Find("Confirm"):GetComponent(Button)
    self.againBtn = main:Find("Again"):GetComponent(Button)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.confirmBtn.onClick:AddListener(function() self:OnClose() end)
    self.againBtn.onClick:AddListener(function() self:OnAgain() end)
end

function GuildDragonEndRod:OnInitCompleted()
    self.OnOpenEvent:Fire()

    self.data = self.openArgs
    self:Update()
    self:ReloadPreview()
end

function GuildDragonEndRod:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function GuildDragonEndRod:OnOpen()
    self:RemoveListeners()
end

function GuildDragonEndRod:OnHide()
    self:RemoveListeners()
end

function GuildDragonEndRod:RemoveListeners()
end

function GuildDragonEndRod:Update()
    self.turnNumText.text = self.data.round
    self.nameText1.text = RoleManager.Instance.RoleData.name
    self.nameText2.text = self.data.target_name
    self.scoreExt:SetData(string.format("%s{assets_2,90054}", self.data.loot_point))
    self.rankText.text = self.data.rank_index

    if self.data.is_win == 1 then
        self.win.transform.anchoredPosition = Vector3(-133.7, 25)
    else
        self.win.transform.anchoredPosition = Vector3(133.7, 25)
    end
end

function GuildDragonEndRod:ReloadPreview()
    self.previewCallback = self.previewCallback or function(composite) self:PreviewCallback(composite) end
    local roledata = RoleManager.Instance.RoleData
    local modelData = {type = PreViewType.Role, classes = roledata.classes, sex = roledata.sex, looks = SceneManager.Instance:MyData().looks}
    if self.previewComp == nil then
        local setting = {
            name = "GuildDragonEndRod"
            ,orthographicSize = 0.45
            ,width = 341
            ,height = 300
            ,offsetY = -0.4
            ,noDrag = true
        }
        self.previewComp = PreviewComposite.New(self.previewCallback, setting, modelData)
    else
        self.previewComp:Reload(modelData, self.previewCallback)
    end
end

function GuildDragonEndRod:PreviewCallback(composite)
    composite.rawImage.transform:SetParent(self.previewContainer)
    composite.rawImage.transform.localScale = Vector3.one
    composite.rawImage.transform.localPosition = Vector3.one
end

function GuildDragonEndRod:OnAgain()
    WindowManager.Instance:CloseWindow(self)
    GuildDragonManager.Instance:Challenge()
end

