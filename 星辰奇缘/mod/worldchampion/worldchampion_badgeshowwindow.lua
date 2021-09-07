WorldChampionBadgeShowWindow = WorldChampionBadgeShowWindow or BaseClass(BaseWindow)

function WorldChampionBadgeShowWindow:__init(model)
    self.model = model
    self.Mgr = self.model.mgr
    self.name = "WorldChampionBadgeShowWindow"
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.worldchampionbadgeshowwindow , type = AssetType.Main},
        {file = AssetConfig.no1inworldbadge_textures, type = AssetType.Dep},
        {file = AssetConfig.badge_icon, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = AssetConfig.totembg, type = AssetType.Dep},
    }


    self.OnOpenEvent:Add(function() self:OnOpen() end)
end

function WorldChampionBadgeShowWindow:__delete()
    self.OnHideEvent:Fire()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function WorldChampionBadgeShowWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionbadgeshowwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    local main = self.transform:Find("Main")

    main:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")
    main:Find("Image"):GetComponent(Image).color = Color(1, 1, 1, 1)
    self.CloseButton = main:Find("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseBadgeShowWindow() end)
    self.badgeImg = main:Find("Image/badgeImg"):GetComponent(Image)
    self.title = main:Find("Title/Text"):GetComponent(Text)
    self.desc = main:Find("Des/Text"):GetComponent(Text)
    self.attrTxt1 = main:Find("Attr1"):GetComponent(Text)
    self.attrIcon1 = main:Find("Attr1/Icon"):GetComponent(Image)
    self.attrTxt2 = main:Find("Attr2"):GetComponent(Text)
    self.attrIcon2 = main:Find("Attr2/Icon"):GetComponent(Image)
    self:OnOpen()
end


function WorldChampionBadgeShowWindow:SetData()
    local data = DataAchieveShop.data_list[self.id]
    self.badgeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(data.source_id)].source_id))
    self.desc.text = data.desc
    local info = DataTournament.data_get_badge_info[self.id]
    self.title.text = info.name


    local attr = nil

    for k,v in pairs(DataTournament.data_get_badge_attr) do
        if v.id == self.id  then
            if v.classes == self.classes then
                attr = v.attr
            end
        end
    end

    self.attrTxt1.text = string.format("%s+%s", KvData.attr_name[attr[1].attr_name],attr[1].val)
    self.attrTxt2.text = string.format("%s+%s", KvData.attr_name[attr[2].attr_name],attr[2].val)

    self.attrIcon1.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..attr[1].attr_name)
    self.attrIcon2.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..attr[2].attr_name)
end

function WorldChampionBadgeShowWindow:OnOpen()
    self.id = self.openArgs.badge_id
    self.classes = self.openArgs.classes
    self:SetData()

end


