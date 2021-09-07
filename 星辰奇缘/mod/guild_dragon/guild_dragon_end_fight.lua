-- @author 黄耀聪
-- @date 2017年11月14日, 星期二

GuildDragonEndFight = GuildDragonEndFight or BaseClass(BaseWindow)

function GuildDragonEndFight:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GuildDragonEndFight"
    self.windowId = WindowConfig.WinID.guilddragon_endfight

    self.resList = {
        {file = AssetConfig.guilddragon_endfight, type = AssetType.Main}
        , {file = AssetConfig.guilddragon_textures, type = AssetType.Dep}
        , {file = AssetConfig.challenge_title, type = AssetType.Main}
        , {file = AssetConfig.levelbreakeffect2, type = AssetType.Dep}
        , {file = AssetConfig.guildleaguebig, type = AssetType.Dep}
    }

    self.slotList = {}
    self.numList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildDragonEndFight:__delete()
    self.OnHideEvent:Fire()
    if self.slotList ~= nil then
        for _,slot in pairs(self.slotList) do
            slot:DeleteMe()
        end
        self.slotList = nil
    end
    if self.pointExt ~= nil then
        self.pointExt:DeleteMe()
        self.pointExt = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.numList ~= nil then
        for _,img in pairs(self.numList) do
            img.sprite = nil
        end
    end
    self:AssetClearAll()
end

function GuildDragonEndFight:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_endfight))
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
    self.circle = circle

    local info = main:Find("Info")
    self.info = info
    self.turnNumText = info:GetChild(0):Find("Value"):GetComponent(Text)
    self.scoreText = info:GetChild(1):Find("Value"):GetComponent(Text)
    self.pointExt = MsgItemExt.New(info:GetChild(2):Find("Value"):GetComponent(Text), 200, 19, 22)
    self.restText = info:GetChild(3):Find("Value"):GetComponent(Text)

    -- self.multiLayout = LuaBoxLayout.New(info:Find("Multi"), {BoxLayoutAxis.X, cspacing = 0})
    self.multiContainer = info:Find("Multi")

    self.mark = info:Find("Multi/Mark")
    self.numImage = info:Find("Multi/Num"):GetComponent(Image)
    self.itemsObj = info:Find("Items").gameObject
    self.layout = LuaBoxLayout.New(info:Find("Items/Container"), {axis = BoxLayoutAxis.X, cspacing = 10})

    self.phaseText = info:Find("Phase"):GetComponent(Text)

    self.confirmBtn = info:Find("Confirm"):GetComponent(Button)
    self.againBtn = info:Find("Again"):GetComponent(Button)
    self.previewContainer = main:Find("Preview")

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.confirmBtn.onClick:AddListener(function() self:OnConfirm() end)
    self.againBtn.onClick:AddListener(function() self:OnAgain() end)
end

function GuildDragonEndFight:OnConfirm()
    self:OnClose()
end

function GuildDragonEndFight:OnAgain()
    -- self:OnClose()
    -- GuildDragonManager.Instance:GotoJumpArea()
    if self.model.myData.loot_time > BaseUtils.BASE_TIME then
        NoticeManager.Instance:FloatTipsByString(TI18N("您刚刚已经掠夺过了，给别人一条生路吧！"))
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddragon_rod)
    end
end

function GuildDragonEndFight:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDragonEndFight:OnOpen()
    self:RemoveListeners()

    self.data = self.openArgs
    self:Update()
    self:ReloadPreview()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 30, function() self:RotateCircle() end)
    end
end

function GuildDragonEndFight:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function GuildDragonEndFight:RemoveListeners()
end

function GuildDragonEndFight:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function GuildDragonEndFight:Update()
    self.turnNumText.text = self.data.round
    self.scoreText.text = self.data.damage
    self.pointExt:SetData(string.format("%s{assets_2,90054}", self.data.point))
    -- self.numImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guilddragon_textures, string.format("Yellow%s", self.data.scale or 1))
    self:LayoutNum((self.data.scale or 10) / 10)

    self.restText.text = string.format("%s%%", math.ceil(GuildDragonManager.Instance:GetRest(BaseUtils.BASE_TIME)) / 10)

    if GuildDragonManager.Instance.state == GuildDragonEnum.State.Ready then
        self.phaseText.text = string.format(TI18N("第%s阶段"), BaseUtils.NumToChn(1))
    elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.First then
        self.phaseText.text = string.format(TI18N("第%s阶段"), BaseUtils.NumToChn(1))
    elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.Second then
        self.phaseText.text = string.format(TI18N("第%s阶段"), BaseUtils.NumToChn(2))
    else
        self.phaseText.text = string.format(TI18N("第%s阶段"), BaseUtils.NumToChn(3))
    end

    self:ReloadList()
end

function GuildDragonEndFight:ReloadList()
    local list = self.data.person_items or {}
    for i,dat in ipairs(list) do
        local slot = self.slotList[i]
        if slot == nil then
            slot = ItemSlot.New()
            self.slotList[i] = slot
        end
        self.layout:AddCell(slot.gameObject)
        slot:SetAll(DataItem.data_get[dat.base_id], {inbag = false, nobutton = true})
        slot:SetNum(dat.num)
    end
    if next(list) ~= nil then
        self.itemsObj:SetActive(true)
        self.info.sizeDelta = Vector2(535, 300)
    else
        self.itemsObj:SetActive(false)
        self.info.sizeDelta = Vector2(535, 235)
    end
end

function GuildDragonEndFight:ReloadPreview()
    self.previewCallback = self.previewCallback or function(composite) self:PreviewCallback(composite) end
    local roledata = RoleManager.Instance.RoleData
    local modelData = {type = PreViewType.Role, classes = roledata.classes, sex = roledata.sex, looks = SceneManager.Instance:MyData().looks}
    if self.previewComp == nil then
        local setting = setting or {
            name = "GuildDragonEndFight"
            ,orthographicSize = 0.5
            ,width = 330
            ,height = 340
            ,offsetY = -0.4
            ,noDrag = true
        }
        self.previewComp = PreviewComposite.New(self.previewCallback, setting, modelData)
    else
        self.previewComp:Reload(modelData, self.previewCallback)
    end
end

function GuildDragonEndFight:PreviewCallback(composite)
    composite.rawImage.transform:SetParent(self.previewContainer)
    composite.rawImage.transform.localScale = Vector3.one
    composite.rawImage.transform.localPosition = Vector3.zero
end

function GuildDragonEndFight:RotateCircle()
    self.circle:Rotate(Vector3(0, 0, 0.3))
end

function GuildDragonEndFight:LayoutNum(num)
    print(tostring(num))
    local list = StringHelper.ConvertStringTable(tostring(num))
    local name = nil
    local width = self.mark.sizeDelta.x
    for i,v in ipairs(list) do
        if v == "." then
            name = "YellowPoint"
        else
            name = "Yellow" .. v
        end
        local obj = GameObject.Instantiate(self.numImage.gameObject)
        obj.gameObject:SetActive(true)
        obj.transform:SetParent(self.multiContainer)
        obj.transform.localScale = Vector3.one
        obj.transform.anchoredPosition3D = Vector3(width, 0, 0)
        local sprite = self.assetWrapper:GetSprite(AssetConfig.guilddragon_textures, name)
        self.numList[i] = obj:GetComponent(Image)
        self.numList[i].sprite = sprite
        self.numList[i]:SetNativeSize()
        width = width + sprite.textureRect.size.x
        sprite = nil
    end
    self.numImage.gameObject:SetActive(false)
end
