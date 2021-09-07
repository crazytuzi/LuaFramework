WorldChampionBadgeCollectPanel = WorldChampionBadgeCollectPanel or BaseClass(BasePanel)

function WorldChampionBadgeCollectPanel:__init(parent,model)
    self.Mgr = WorldChampionManager.Instance
    self.parent = parent
    self.model = model
    self.resList = {
        {file = AssetConfig.worldchampionbadgecollectpanel, type = AssetType.Main},
        {file = AssetConfig.no1inworldbadge_textures, type = AssetType.Dep},
        --{file = AssetConfig.base_textures, type = AssetType.Dep},
        {file = AssetConfig.badge_icon, type = AssetType.Dep},
        --{file = AssetConfig.fashionres, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
    }

    self.refreshlist = function()
        for i=1,9 do
            self:SetBadge(i)
        end
        self:InitSelect()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function WorldChampionBadgeCollectPanel:OnShow()
    self.Mgr.onGetBadgeData:AddListener(self.refreshlist)
    self.Mgr:Require16437()
    self.Mgr:Require16435()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
end

function WorldChampionBadgeCollectPanel:OnInitCompleted()

end

function WorldChampionBadgeCollectPanel:OnHide()
    self.Mgr.onGetBadgeData:RemoveListener(self.refreshlist)
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function WorldChampionBadgeCollectPanel:__delete()
    self.OnHideEvent:Fire()
    if self.quickpanel ~= nil then
        self.quickpanel:DeleteMe()
        self.quickpanel = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionBadgeCollectPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionbadgecollectpanel))
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t
    self:OnShow()
    self.list = {}
    self.openSelect = nil
    self.curUse = 0
    for i=1,9 do
        self.list[i] = {}
        local go = t:Find("Left/BadgeList"):GetChild(i-1)
        self.list[i].image = go:Find("Image").gameObject:GetComponent("Image")
        self.list[i].select = go:Find("select").gameObject
        self.list[i].unavailable = go:Find("unavailable").gameObject
        self.list[i].notifyPoint = go:Find("NotifyPoint").gameObject
        go.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickBadge(i) end)
    end
    local r = t:Find("Right")
    r:Find("BgImg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    r:Find("BgImg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.badgeName = r:Find("BadgeName").gameObject:GetComponent(Text)
    self.badgeImg = r:Find("BadgeImg").gameObject:GetComponent(Image)
    self.badgeBtn = r:Find("BadgeImg").gameObject:GetComponent(Button)
    self.desc = r:Find("Des/Text").gameObject:GetComponent(Text)
    self.attr1Txt = r:Find("Attr1").gameObject:GetComponent(Text)
    self.attr1Icon = r:Find("Attr1/Icon").gameObject:GetComponent(Image)
    self.attr2Txt = r:Find("Attr2").gameObject:GetComponent(Text)
    self.attr2Icon = r:Find("Attr2/Icon").gameObject:GetComponent(Image)
    self.unloadBtn = r:Find("UnloadBtn").gameObject:GetComponent(Button)
    self.unloadBtn.gameObject:SetActive(false)
    self.useBtn = r:Find("UseBtn").gameObject:GetComponent(Button)
    self.useBtnImg = r:Find("UseBtn").gameObject:GetComponent(Image)
    self.useBtnTxt = r:Find("UseBtn/Text").gameObject:GetComponent(Text)

    -- self.nameText = t:Find("Right/Text"):GetComponent(Text)
    -- self.nameText.gameObject:SetActive(false)
    self.notice = r:Find("Notice"):GetComponent(Button)
    self.notice.onClick:AddListener(function ()
        local tipsText = TI18N("徽章使用后，可以在武道会匹配界面展示")
        TipsManager.Instance:ShowText({gameObject = self.notice.gameObject, itemData = {tipsText}})
    end)

    local left = t:Find("Left")
    self.showBtn = left:Find("ShowBtn"):GetComponent(Button)
    self.ShareCon = left:Find("ShareCon").gameObject
    self.SharePanel = left:Find("ShareCon/ImgPanel"):GetComponent(Button)
    self.ShareChat = left:Find("ShareCon/BtnChat"):GetComponent(Button)
    self.ShareFriend = left:Find("ShareCon/BtnFriend"):GetComponent(Button)

    self.showShare = false
    self.showBtn.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
    end)

    self.SharePanel.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
    end)

    self.ShareChat.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
        if #self.model.badgeData > 0 then
            WorldChampionManager.Instance.model:OnShareBadge()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("还未获得王者徽章，无法分享"))
        end
    end)

    local setting = {title = TI18N("王者徽章分享"), type = 4}
    self.quickpanel = ZoneQuickShareStr.New(setting)
    self.ShareFriend.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
        if #self.model.badgeData > 0 then
            self.quickpanel:Show()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("还未获得王者徽章，无法分享"))
        end
    end)
end

function WorldChampionBadgeCollectPanel:SetBadge(index)
    if table.containValue(self.model.badgeData, index + 232) then
        local source_id = DataAchieveShop.data_list[index + 232].source_id
        self.list[index].image.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(source_id)].source_id))
        self.list[index].unavailable:SetActive(false)
    else
        self.list[index].image.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "unknowBadge")
        self.list[index].unavailable:SetActive(true)
    end
end

function WorldChampionBadgeCollectPanel:OnClickBadge(index)

    if self.list == nil then
        return
    end
    for i=1,9 do
        self.list[i].select:SetActive(false)
    end
    self.list[index].select:SetActive(true)

    if self.curUse == index then
        self.useBtnTxt.text = TI18N("使用中")
    else
        self.useBtnTxt.text = TI18N("使用")
    end


    if table.containValue(self.model.badgeData, index + 232) then
        local data = DataAchieveShop.data_list[index + 232]
        self.badgeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(data.source_id)].source_id))
        self.desc.text = data.desc

        self.badgeName.gameObject:SetActive(true)
        self.badgeName.text = data.name

        local role = RoleManager.Instance.RoleData
        local attr = nil
        for k,v in pairs(DataTournament.data_get_badge_attr) do
            if v.id == index+232 then
                if v.classes == role.classes then
                    attr = v.attr
                end
            end
        end

        self.attr1Icon.gameObject:SetActive(true)
        self.attr2Icon.gameObject:SetActive(true)
        self.attr1Txt.text = string.format("%s+%s", KvData.attr_name[attr[1].attr_name],attr[1].val)
        self.attr2Txt.text = string.format("%s+%s", KvData.attr_name[attr[2].attr_name],attr[2].val)
        self.attr1Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..attr[1].attr_name)
        self.attr2Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..attr[2].attr_name)

        self.useBtn.onClick:RemoveAllListeners()
        self.unloadBtn.onClick:RemoveAllListeners()

        if self.curUse ~= index then

            self.useBtnTxt.text = TI18N("使用")
            self.useBtnTxt.color = ColorHelper.DefaultButton2
            self.useBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")

        elseif self.curUse ~= 0 then
            self.useBtnTxt.text = TI18N("卸下")
            self.useBtnTxt.color = ColorHelper.DefaultButton3
            self.useBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")

        end

        self.useBtn.onClick:AddListener(function ()
            if self.curUse ~= index then
                self.curUse = index
                self.Mgr:Require16434(index + 232)
                self.useBtnTxt.text = TI18N("卸下")
                self.useBtnTxt.color = ColorHelper.DefaultButton3
                self.useBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            elseif self.curUse ~= 0 then
                self.curUse = 0
                self.Mgr:Require16434(0)
                self.useBtnTxt.text = TI18N("使用")
                self.useBtnTxt.color = ColorHelper.DefaultButton2
                self.useBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            end
        end)


        self.unloadBtn.onClick:AddListener(function()
            if self.curUse ~= 0 then
                self.curUse = 0
                self.Mgr:Require16434(0)
                self.useBtnTxt.text = TI18N("使用")
            end
        end)
        self.badgeBtn.onClick:RemoveAllListeners()
        self.badgeBtn.onClick:AddListener(function ()
           NoticeManager.Instance:FloatTipsByString(TI18N("金灿灿的王者徽章，人人都渴望获得的荣誉证明{face_1,25}"))
        end)

    else
        self.badgeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "unknowBadge")
        self.desc.text = TI18N("不为人知的神秘徽章，仿佛正轻声诉说着它的传奇故事。")
        self.badgeName.gameObject:SetActive(false)
        self.attr1Icon.gameObject:SetActive(false)
        self.attr2Icon.gameObject:SetActive(false)
        self.attr1Txt.text = TI18N("未知属性")
        self.attr2Txt.text = TI18N("未知属性")
        self.useBtn.onClick:RemoveAllListeners()
        self.unloadBtn.onClick:RemoveAllListeners()

        self.badgeBtn.onClick:RemoveAllListeners()
        self.badgeBtn.onClick:AddListener(function ()
           NoticeManager.Instance:FloatTipsByString(TI18N("该徽章尚未解锁，请继续加油吧{face_1,3}"))
        end)

        self.useBtn.onClick:AddListener(function ()
            NoticeManager.Instance:FloatTipsByString(TI18N("该徽章需要解锁后才能使用，快去解锁吧{face_1,18}"))
        end)

        self.useBtnTxt.color = ColorHelper.DefaultButton4
        self.useBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.useBtnTxt.text = TI18N("使用")
    end
end

function WorldChampionBadgeCollectPanel:InitSelect()
    self.curUse = self.model.curUse - 232
    if self.openSelect ~= nil then
        self:OnClickBadge(self.openSelect)
        self.openSelect = nil
        return
    end
    for i=1,9 do
        if table.containValue(self.model.badgeData, i + 232) then
            self:OnClickBadge(i)
            return
        end
    end
    self:OnClickBadge(1)
end

