-- @author 黄耀聪
-- @date 2017年11月13日, 星期一

GuildDragonSettle = GuildDragonSettle or BaseClass(BaseWindow)

function GuildDragonSettle:__init(model)
    self.model = model
    self.name = "GuildDragonSettle"
    self.windowId = WindowConfig.WinID.guilddragon_settle

    self.resList = {
        {file = AssetConfig.guilddragon_settle, type = AssetType.Main}
        , {file = AssetConfig.guilddragon_textures, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
        , {file = AssetConfig.rolebgstand, type = AssetType.Dep}
    }

    self.panelList = {}
    self.updateListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildDragonSettle:__delete()
    self.OnHideEvent:Fire()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.panelList ~= nil then
        for _,panel in pairs(self.panelList) do
            panel:DeleteMe()
        end
        self.panelList = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    local show = self.transform:Find("Main/Show")
    show:Find("RoleBg"):GetComponent(Image).sprite = nil
    show:Find("RoleStandBg"):GetComponent(Image).sprite = nil

    GuildDragonManager.Instance:Clean()

    self:AssetClearAll()
end

function GuildDragonSettle:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_settle))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.tabGroup = TabGroup.New(main:Find("TabContainer").gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = false, perWidth = 90, perHeight = 33, isVertical = false, spacing = 5})

    self.panelContainer = main:Find("Panel")

    local show = main:Find("Show")
    self.previewContainer = show:Find("Preview")
    self.nameText = show:Find("Name/Text"):GetComponent(Text)
    self.honorText = show:Find("Honor/Text"):GetComponent(Text)
    self.descExt = MsgItemExt.New(show:Find("Desc/Text"):GetComponent(Text), 266, 19, 22)
    show:Find("RoleBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    show:Find("RoleBg"):GetComponent(Image).color = Color(1, 1, 1)
    show:Find("RoleStandBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")
    show:Find("RoleStandBg"):GetComponent(Image).color = Color(1, 1, 1)

end

function GuildDragonSettle:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDragonSettle:OnOpen()
    self:RemoveListeners()
    GuildDragonManager.Instance.updateRankEvent:AddListener(self.updateListener)

    self:Update()
    self.tabGroup:ChangeTab(1)
end

function GuildDragonSettle:OnHide()
    self:RemoveListeners()
    for _,panel in pairs(self.panelList) do
        if panel ~= nil then
            panel:Hiden()
        end
    end
end

function GuildDragonSettle:RemoveListeners()
    GuildDragonManager.Instance.updateRankEvent:RemoveListener(self.updateListener)
end

function GuildDragonSettle:ChangeTab(index)
    if self.panelList[self.lastIndex] ~= nil then
        self.panelList[self.lastIndex]:Hiden()
    end
    if index == 1 or index == 2 then
        if self.panelList[index] == nil then
            self.panelList[index] = GuildDragonRank.New(self.model, self.transform:Find("Main/Panel").gameObject)
        end
        self.panelList[index]:Show(index)
    elseif index == 3 then
        if self.panelList[3] == nil then
            self.panelList[3] = GuildDragonSpoils.New(self.model, self.transform:Find("Main/Panel"))
        end
        self.panelList[3]:Show()
    end
    self.lastIndex = index
end

function GuildDragonSettle:ReloadPreview(id, platform, zone_id, classes, sex)
    local looks = self.model.looks[BaseUtils.Key(id, platform, zone_id)] or {}
    self.previewCallback = self.previewCallback or function(composite) self:PreviewCallback(composite) end
    local modelData = {type = PreViewType.Role, classes = classes, sex = sex, looks = looks}
    if self.previewComp == nil then
        local setting = setting or {
            name = "GuildDragonSettle"
            ,orthographicSize = 0.6
            ,width = 341
            ,height = 300
            ,offsetY = -0.1
            ,noDrag = true
        }
        self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
    else
        self.wingComposite:Reload(modelData, self.previewCallback)
    end
end


function GuildDragonSettle:Update()
    self:ReloadInfo((self.model.rank_list[GuildDragonEnum.Rank.Personal] or {})[1])
end

function GuildDragonSettle:ReloadInfo(firstPlaceData)
    local roleData = RoleManager.Instance.RoleData
    firstPlaceData = firstPlaceData or {target_name = roleData.name, id = roleData.id, platform = roleData.platform, zone_id = roleData.zone_id, sex = roleData.sex, classes = roleData.classes}
    self.nameText.text = firstPlaceData.target_name
    self:ReloadPreview(firstPlaceData)
end

function GuildDragonSettle:ReloadPreview(data)
    if self.previewCallback == nil then
        self.previewCallback = function(composite) self:PreviewCallback(composite) end
    end

    local info = self.model:GetLooks(data.id, data.platform, data.zone_id)

    local modelData = nil
    if info == nil then
        modelData = {type = PreViewType.Role, classes = data.classes, sex = data.sex, looks = {}}
    else
        modelData = {type = PreViewType.Role, classes = data.classes, sex = data.sex, looks = info.looks}
    end

    self.honorText.text = DataHonor.data_get_honor_list[11129].name
    self.descExt:SetData(DataHonor.data_get_honor_list[11129].cond_desc)
    local size = self.descExt.contentTrans.sizeDelta
    self.descExt.contentTrans.anchoredPosition3D = Vector3(-size.x / 2, size.y / 2, 0)
    -- if info == nil or info.honor_id == nil or info.honor_id == 0 then
    -- else
    --     self.honorText.text = DataHonor.data_get_honor_list[info.honor_id].name
    --     self.descExt:SetData(DataHonor.data_get_honor_list[info.honor_id].cond_desc)
    -- end
    if self.previewComp == nil then
        local setting = setting or {
            name = "GuildDragonSettle"
            ,orthographicSize = 0.6
            ,width = 330
            ,height = 340
            ,offsetY = -0.4
            ,noDrag = false
        }
        self.previewComp = PreviewComposite.New(self.previewCallback, setting, modelData)
    else
        self.previewComp:Reload(modelData, self.previewCallback)
    end
end

function GuildDragonSettle:PreviewCallback(composite)
    composite.rawImage.transform:SetParent(self.previewContainer)
    composite.rawImage.transform.localScale = Vector3.one
    composite.rawImage.transform.localPosition = Vector3.zero
end

