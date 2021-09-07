WorldChampionBadgeLookWindow = WorldChampionBadgeLookWindow or BaseClass(BaseWindow)

function WorldChampionBadgeLookWindow:__init(model)
    self.model = model
    self.Mgr = self.model.mgr
    self.name = "WorldChampionBadgeLookWindow"
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.worldchampionbadgelookwindow , type = AssetType.Main},
        {file = AssetConfig.no1inworldbadge_textures, type = AssetType.Dep},
        --{file = AssetConfig.may_textures, type = AssetType.Dep},
        {file = AssetConfig.badge_icon, type = AssetType.Dep},
        --{file = AssetConfig.fashionres, type = AssetType.Dep},
        --{file = AssetConfig.childbirth_textures, type = AssetType.Dep},
        --{file = AssetConfig.face_res, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
        --{file = AssetConfig.face_textures, type = AssetType.Dep},
    }


    self.OnOpenEvent:Add(function() self:OnOpen() end)
end

function WorldChampionBadgeLookWindow:__delete()
    self.OnHideEvent:Fire()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function WorldChampionBadgeLookWindow:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionbadgelookwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    local t = self.transform:Find("Main")

    self.CloseButton = t:Find("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseBadgeLookWindow() end)


    self.list = {}
    for i=1,9 do
        self.list[i] = {}
        local go = t:Find("Left/BadgeList"):GetChild(i-1)
        self.list[i].image = go:Find("Image").gameObject:GetComponent("Image")
        self.list[i].select = go:Find("select").gameObject
        self.list[i].unavailable = go:Find("unavailable").gameObject
        go.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickBadge(i) end)
    end
    self.combinationCount = t:Find("Left/Image/Title/Count"):GetComponent(Text)

    local l = t:Find("Left/Image/Combination")

    self.CombinationList = {}

    for i=1,8 do
        self.CombinationList[i] = l:GetChild(i-1):GetComponent(Text)
    end
    for i=6,8 do
        self.CombinationList[i].gameObject:SetActive(false)
    end

    local r = t:Find("Right")
    r:Find("BgImg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.badgeImg = r:Find("BadgeImg").gameObject:GetComponent(Image)
    self.badgeBtn = r:Find("BadgeImg").gameObject:GetComponent(Button)
    self.desc = r:Find("Des/Text").gameObject:GetComponent(Text)
    self.attr1Txt = r:Find("Attr1").gameObject:GetComponent(Text)
    self.attr1Icon = r:Find("Attr1/Icon").gameObject:GetComponent(Image)
    self.attr2Txt = r:Find("Attr2").gameObject:GetComponent(Text)
    self.attr2Icon = r:Find("Attr2/Icon").gameObject:GetComponent(Image)
    self.badgeTitle = r:Find("Title/Text").gameObject:GetComponent(Text)

    local list = r:Find("Image/Combination")
    self.attrList = {}

    for i=1,7 do
        self.attrList[i] = list:GetChild(i-1):GetComponent(Text)
    end


    self:OnOpen()
end

function WorldChampionBadgeLookWindow:OnOpen()


    self.badgelist = {}
    self.setlist = {}

    local temp1 = StringHelper.Split(self.openArgs[1], "|")
    local temp2 = StringHelper.Split(self.openArgs[2], "|")
    self.classes = tonumber(self.openArgs[3])


    for k,v in pairs(temp1) do
        if v ~= "" then
            table.insert(self.badgelist,tonumber(v))
        end
    end

    for k,v in pairs(temp2) do
        if v ~= "" then
            table.insert(self.setlist,tonumber(v))
        end
    end

    for i=1,9 do
        self:SetBadge(i)
    end
    self:InitSelect()
    self:SetCombination()
end

function WorldChampionBadgeLookWindow:SetCombination()
    self.combinationCount.text = string.format("(<color='#df3435'>%s</color>/5)", #self.setlist)
    for i=1,5 do
        if table.containValue(self.setlist, i) then
            self.CombinationList[i].text = string.format("<color='#00F802'>%s</color>", DataTournament.data_get_badge_group[i].name)
        else
            self.CombinationList[i].text = TI18N("<color='#627C90'>未知组合</color>")
        end
    end
    local attr = {}
    for i=1,7 do
        attr[i] = 0
    end

    for k,v in pairs(self.badgelist) do
        local id = v
        for k,v in pairs(DataTournament.data_get_badge_attr) do
            if v.id == id then
                if v.classes == self.classes then
                    attr[v.attr[1].attr_name] = attr[v.attr[1].attr_name] + v.attr[1].val
                    attr[v.attr[2].attr_name] = attr[v.attr[2].attr_name] + v.attr[2].val
                end
            end
        end
    end

    for i=1,7 do
        self.attrList[i].text = "+"..attr[i]
    end
end



function WorldChampionBadgeLookWindow:SetBadge(index)

    if table.containValue(self.badgelist, index + 232) then
        local source_id = DataAchieveShop.data_list[index + 232].source_id
        self.list[index].image.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(source_id)].source_id))
        self.list[index].unavailable:SetActive(false)
    else
        self.list[index].image.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "unknowBadge")
        self.list[index].unavailable:SetActive(true)
    end
end


function WorldChampionBadgeLookWindow:OnClickBadge(index)

    if self.list == nil then
        return
    end
    for i=1,9 do
        self.list[i].select:SetActive(false)
    end
    self.list[index].select:SetActive(true)

    if table.containValue(self.badgelist, index + 232) then
        local data = DataAchieveShop.data_list[index + 232]
        self.badgeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(data.source_id)].source_id))
        self.desc.text = data.desc
        local info = DataTournament.data_get_badge_info[index + 232]
        self.badgeTitle.text = info.name

        self.badgeBtn.onClick:RemoveAllListeners()
        self.badgeBtn.onClick:AddListener(function ()
           NoticeManager.Instance:FloatTipsByString(TI18N("金灿灿的王者徽章，人人都渴望获得的荣誉证明{face_1,25}"))
        end)

        self.attr1Icon.gameObject:SetActive(true)
        self.attr2Icon.gameObject:SetActive(true)

        local attr = nil
        for k,v in pairs(DataTournament.data_get_badge_attr) do
            if v.id == index+232 then
                if v.classes == self.classes then
                    attr = v.attr
                end
            end
        end

        self.attr1Txt.text = string.format("%s+%s", KvData.attr_name[attr[1].attr_name],attr[1].val)
        self.attr2Txt.text = string.format("%s+%s", KvData.attr_name[attr[2].attr_name],attr[2].val)

        self.attr1Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..attr[1].attr_name)
        self.attr2Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..attr[2].attr_name)

    else
        self.badgeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "unknowBadge")
        self.desc.text = TI18N("不为人知的神秘徽章，仿佛正轻声诉说着它的传奇故事。")
        self.badgeTitle.text = "? ? ? ? ?"
        self.attr1Icon.gameObject:SetActive(false)
        self.attr2Icon.gameObject:SetActive(false)
        self.attr1Txt.text = TI18N("未知属性")
        self.attr2Txt.text = TI18N("未知属性")

        self.badgeBtn.onClick:RemoveAllListeners()
        self.badgeBtn.onClick:AddListener(function ()
           NoticeManager.Instance:FloatTipsByString(TI18N("这个徽章还没有解锁哦"))
        end)
    end
end

function WorldChampionBadgeLookWindow:InitSelect()

    for i=1,9 do
        if table.containValue(self.badgelist, i + 232) then
            self:OnClickBadge(i)
            return
        end
    end
    self:OnClickBadge(1)
end