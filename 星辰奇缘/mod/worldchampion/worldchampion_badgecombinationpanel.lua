WorldChampionBadgeCombinationPanel = WorldChampionBadgeCombinationPanel or BaseClass(BasePanel)

function WorldChampionBadgeCombinationPanel:__init(parent,model)
    self.Mgr = WorldChampionManager.Instance
    self.parent = parent
    self.model = model
    self.resList = {
        {file = AssetConfig.worldchampionbadgecombinationpanel, type = AssetType.Main},
        {file = AssetConfig.no1inworldbadge_textures, type = AssetType.Dep},
        --{file = AssetConfig.base_textures, type = AssetType.Dep},
        {file = AssetConfig.badge_icon, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
    }

    self.refreshLeft = function()
        for i=1,5 do
            self:SetLeft(i)
        end
        self:InitSelect()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function WorldChampionBadgeCombinationPanel:OnShow()
    self.Mgr.onGetBadgeData:AddListener(self.refreshLeft)
    self.Mgr:Require16435()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end

end

function WorldChampionBadgeCombinationPanel:OnInitCompleted()

end

function WorldChampionBadgeCombinationPanel:OnHide()
    self.Mgr.onGetBadgeData:RemoveListener(self.refreshLeft)
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function WorldChampionBadgeCombinationPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionBadgeCombinationPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionbadgecombinationpanel))
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t
    self:OnShow()
    self.list = {}
    for i=1,5 do
        self.list[i] = {}
        local go = t:Find("Left/CombinationList"):GetChild(i-1)
        self.list[i].text = go:Find("NameText").gameObject:GetComponent("Text")
        self.list[i].select = go:Find("Select").gameObject
        self.list[i].image = go:Find("Image"):GetComponent(Image)
        go.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickLeft(i) end)
    end
    local r = t:Find("Right")
    r:Find("Badge1/Image1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    r:Find("Badge2/Image1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.title = r:Find("Title/Text"):GetComponent(Text)
    self.badgeBtn1 = r:Find("Badge1"):GetComponent(Button)
    self.badgeImg1 = r:Find("Badge1/BadgeImg"):GetComponent(Image)
    self.badgeName1 = r:Find("Badge1/BadgeName"):GetComponent(Text)
    self.badgeName1.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-78)
    self.badgeBtn2 = r:Find("Badge2"):GetComponent(Button)
    self.badgeImg2 = r:Find("Badge2/BadgeImg"):GetComponent(Image)
    self.badgeName2 = r:Find("Badge2/BadgeName"):GetComponent(Text)
    self.badgeName2.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(0,-78)
    self.desc = r:Find("Text"):GetComponent(Text)
    self.attr1Txt = r:Find("Attr1"):GetComponent(Text)
    self.attr1Icon = r:Find("Attr1/Icon"):GetComponent(Image)
    self.attr2Txt = r:Find("Attr2"):GetComponent(Text)
    self.attr2Icon = r:Find("Attr2/Icon"):GetComponent(Image)
    self.unknow = r:Find("UnknowAttr").gameObject
    self.unknow:GetComponent(RectTransform).sizeDelta = Vector2(360,30)
    self.unknow:GetComponent(RectTransform).anchoredPosition = Vector2(0, -65)
    self.unknow:GetComponent(Text).text = TI18N("解锁王者徽章组合，可获得额外属性加成")
    self.unlockOne = r:Find("Image/Text2").gameObject
    self.unlockTwo = r:Find("Image/Image").gameObject
    self.unlockTwo.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(200,-35)
    self.unlockTwo.gameObject:GetComponent(RectTransform).localRotation = Quaternion.Euler(0, 0, 350)
end

function WorldChampionBadgeCombinationPanel:SetLeft(index)
    if table.containValue(self.model.unlockCombination, index) then
        self.list[index].text.text = DataTournament.data_get_badge_group[index].name
        self.list[index].image.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "have")
    else
        self.list[index].text.text = "? ? ? ? ?"
        self.list[index].image.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "donothave")
    end
end

function WorldChampionBadgeCombinationPanel:OnClickLeft(index)
    for i=1,5 do
        self.list[i].select:SetActive(false)
    end
    self.list[index].select:SetActive(true)
    if table.containValue(self.model.unlockCombination, index) then
        local info = DataTournament.data_get_badge_group[index]
        self.title.text = info.name
        self.desc.text = info.desc
        self.unknow:SetActive(false)

        self.attr1Txt.gameObject:SetActive(true)
        self.attr2Txt.gameObject:SetActive(true)

        local role = RoleManager.Instance.RoleData
        local attr = nil
        for k,v in pairs(DataTournament.data_get_badge_attr) do
            if v.id == index then
                if v.classes == role.classes then
                    attr = v.attr
                end
            end
        end

        self.attr1Txt.text = string.format("%s+%s", KvData.attr_name[attr[1].attr_name],attr[1].val)
        self.attr2Txt.text = string.format("%s+%s", KvData.attr_name[attr[2].attr_name],attr[2].val)

        self.attr1Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..attr[1].attr_name)
        self.attr2Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..attr[2].attr_name)


        self.badgeBtn1.onClick:RemoveAllListeners()
        self.badgeBtn2.onClick:RemoveAllListeners()

        local unlockCount = 0
        if table.containValue(self.model.badgeData,info.group_list[1]) then
            local data = DataAchieveShop.data_list[info.group_list[1]]
            self.badgeImg1.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(data.source_id)].source_id))
            self.badgeImg1.color = Vector4(1,1,1,1)
            self.badgeBtn1.onClick:AddListener(function () self:onClickBadge(info.group_list[1]) end)
            self.badgeName1.gameObject:SetActive(true)
            self.badgeName1.text = data.name
            unlockCount = unlockCount + 1
        else
            self.badgeImg1.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "unknowBadge")
            self.badgeImg1.color = Vector4(91/255,103/255,120/255,1)
            self.badgeName1.gameObject:SetActive(false)
            self.badgeBtn1.onClick:AddListener(function ()
                NoticeManager.Instance:FloatTipsByString(TI18N("该徽章尚未解锁，请继续加油吧{face_1,3}"))
            end)
        end

        if table.containValue(self.model.badgeData,info.group_list[2]) then
            local data = DataAchieveShop.data_list[info.group_list[2]]
            self.badgeImg2.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(data.source_id)].source_id))
            self.badgeImg2.color = Vector4(1,1,1,1)
            self.badgeBtn2.onClick:AddListener(function () self:onClickBadge(info.group_list[2]) end)
            self.badgeName2.gameObject:SetActive(true)
            self.badgeName2.text = data.name
            unlockCount = unlockCount + 1
        else
            self.badgeImg2.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "unknowBadge")
            self.badgeImg2.color = Vector4(91/255,103/255,120/255,1)
            self.badgeName2.gameObject:SetActive(false)
            self.badgeBtn2.onClick:AddListener(function ()
                NoticeManager.Instance:FloatTipsByString(TI18N("该徽章尚未解锁，请继续加油吧{face_1,3}"))
            end)
        end

        if unlockCount == 1 then
            self.unlockOne:SetActive(true)
            self.unlockTwo:SetActive(false)
        elseif unlockCount == 2 then
            self.unlockTwo:SetActive(true)
            self.unlockOne:SetActive(false)
        end
    else
        self.title.text = "? ? ? ? ?"
        self.desc.text = TI18N("一个未知的徽章组合。解锁组合中的所有徽章，能获得令人敬畏的力量。")
        self.unknow:SetActive(true)
        self.attr1Txt.gameObject:SetActive(false)
        self.attr2Txt.gameObject:SetActive(false)
        self.unlockOne:SetActive(false)
        self.unlockTwo:SetActive(false)
        self.badgeImg1.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "unknowBadge")
        self.badgeImg2.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "unknowBadge")
        self.badgeImg1.color = Vector4(91/255,103/255,120/255,1)
        self.badgeImg2.color = Vector4(91/255,103/255,120/255,1)
        self.badgeName1.gameObject:SetActive(false)
        self.badgeName2.gameObject:SetActive(false)
        self.badgeBtn1.onClick:RemoveAllListeners()
        self.badgeBtn2.onClick:RemoveAllListeners()
        self.badgeBtn1.onClick:AddListener(function ()
            NoticeManager.Instance:FloatTipsByString(TI18N("该徽章尚未解锁，请继续加油吧{face_1,3}"))
        end)
        self.badgeBtn2.onClick:AddListener(function ()
            NoticeManager.Instance:FloatTipsByString(TI18N("该徽章尚未解锁，请继续加油吧{face_1,3}"))
        end)
    end
end



function WorldChampionBadgeCombinationPanel:InitSelect()
    for i=1,5 do
        if table.containValue(self.model.unlockCombination, i) then
            self:OnClickLeft(i)
            return
        end
    end
    self:OnClickLeft(1)
end

function WorldChampionBadgeCombinationPanel:onClickBadge(id)
    if self.model.badge_win ~= nil then
        self.model.badge_win.tabgroup:ChangeTab(2)
        self.model.badge_win.subcon[2].openSelect = id - 232
    end
end

