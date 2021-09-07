--武道大会荣誉分享
--2017/02/13
--zzl

 WorldChampionShareWindow  =  WorldChampionShareWindow or BaseClass(BaseWindow)

function WorldChampionShareWindow:__init(model)
    self.name  =  "WorldChampionShareWindow"
    self.model  =  model
    -- 缓存
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.worldchampionshare
    self.resList  =  {
        {file  =  AssetConfig.worldchampionno1share, type  =  AssetType.Main}
        , {file = AssetConfig.no1inworld_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.onupdateTimes = function() self:UpdateTimes() end
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.rightItemList = nil
    return self
end

function WorldChampionShareWindow:OnShow()
    WorldChampionManager.Instance.onUpdateTimes:RemoveListener(self.onupdateTimes)
    WorldChampionManager.Instance.onUpdateTimes:AddListener(self.onupdateTimes)
    if self.openArgs ~= nil then
        WorldChampionManager.Instance:Require16427(tonumber(self.openArgs[2]), self.openArgs[3], tonumber(self.openArgs[4]))
        self.model.shareData.rid = tonumber(self.openArgs[2])
        self.model.shareData.platform = self.openArgs[3]
        self.model.shareData.zone_id = tonumber(self.openArgs[4])
    else
        WorldChampionManager.Instance:Require16427(self.model.shareData.rid, self.model.shareData.platform, self.model.shareData.zone_id)
        -- self.model.shareData.rid = RoleManager.Instance.RoleData.id
        -- self.model.shareData.platform = RoleManager.Instance.RoleData.platform
        -- self.model.shareData.zone_id = RoleManager.Instance.RoleData.zone_id
    end
end

function WorldChampionShareWindow:OnHide()
    WorldChampionManager.Instance.onUpdateTimes:RemoveListener(self.onupdateTimes)
end

function WorldChampionShareWindow:__delete()
    WorldChampionManager.Instance.onUpdateTimes:RemoveListener(self.onupdateTimes)
    self.is_open  =  false

    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function WorldChampionShareWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionno1share))
    self.gameObject:SetActive(false)
    self.gameObject.name = "WorldChampionShareWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.Main = self.gameObject.transform:Find("Main")

    local closeBtn = self.gameObject.transform:Find("Main/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseShareWindow()
    end)

    self.TopCon = self.Main:Find("TopCon")
    self.LeftCon = self.TopCon:Find("LeftCon")
    self.LeftTitleTxt = self.LeftCon:Find("ImgTitle/Text"):GetComponent(Text)
    self.LeftIcon = self.LeftCon:Find("LevIconCon/ImgLevIconBg/ImgIcon"):GetComponent(Image)
    self.LeftLevNameTxt = self.LeftCon:Find("ImgLevName/Text"):GetComponent(Text)

    self.rightItemList = {}
    for i = 1, 8 do
        local go =self.TopCon:Find(string.format("RightCon/Item%s", i))
        table.insert(self.rightItemList, go)
    end

    self.rightItemList[4]:Find("TxtGood"):GetComponent(RectTransform).sizeDelta = Vector2(202, 30)
    self.rightItemList[5]:Find("TxtName"):GetComponent(RectTransform).sizeDelta = Vector2(202, 30)
    self.rightItemList[4]:Find("TxtGood"):GetComponent(RectTransform).anchoredPosition = Vector2(26, 0)
    self.rightItemList[5]:Find("TxtName"):GetComponent(RectTransform).anchoredPosition = Vector2(26, 0)

    self.BottomCon = self.Main:Find("BottomCon")
    self.BtnCount = self.BottomCon:Find("BtnCount"):GetComponent(Button)
    self.BtnNearWar = self.BottomCon:Find("BtnNearWar"):GetComponent(Button)

    self.ShareCon = self.BottomCon:Find("ShareCon").gameObject
    self.SharePanel = self.BottomCon:Find("ShareCon/ImgPanel"):GetComponent(Button)
    self.ShareChat = self.BottomCon:Find("ShareCon/BtnChat"):GetComponent(Button)
    self.ShareFriend = self.BottomCon:Find("ShareCon/BtnFriend"):GetComponent(Button)

    self.BtnShare = self.BottomCon:Find("BtnShare"):GetComponent(Button)
    self.BtnShare.onClick:AddListener(function()
        print("=====================dddddddddddddddddddddddddddddd")
    end)
    self.BtnCount.onClick:AddListener(function()
        self.model:OpenFightHonorWindow(1)
    end)
    self.BtnNearWar.onClick:AddListener(function()
        self.model:OpenFightHonorWindow(2)
    end)
    self.model.shareData = {}
    if self.openArgs ~= nil then
        WorldChampionManager.Instance:Require16427(tonumber(self.openArgs[2]), self.openArgs[3], tonumber(self.openArgs[4]))
        self.model.shareData.rid = tonumber(self.openArgs[2])
        self.model.shareData.platform = self.openArgs[3]
        self.model.shareData.zone_id = tonumber(self.openArgs[4])
    else
        WorldChampionManager.Instance:Require16427(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
        self.model.shareData.rid = RoleManager.Instance.RoleData.id
        self.model.shareData.platform = RoleManager.Instance.RoleData.platform
        self.model.shareData.zone_id = RoleManager.Instance.RoleData.zone_id
    end

    self.showShare = false
    self.BtnShare.onClick:AddListener(function()
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
        WorldChampionManager.Instance.model:OnShareFightScore()
    end)

    local setting = {title = TI18N("武道战绩分享"), type = 2}
    self.quickpanel = ZoneQuickShareStr.New(setting)
    self.ShareFriend.onClick:AddListener(function()
        self.showShare = not self.showShare
        self.ShareCon.gameObject:SetActive(self.showShare)
        self.quickpanel:Show()
    end)
     WorldChampionManager.Instance.onUpdateTimes:RemoveListener(self.onupdateTimes)
    WorldChampionManager.Instance.onUpdateTimes:AddListener(self.onupdateTimes)
end

function WorldChampionShareWindow:UpdateInfo(socketData)
    if self.model.shareData.rid == RoleManager.Instance.RoleData.id and self.model.shareData.platform == RoleManager.Instance.RoleData.platform and self.model.shareData.zone_id == RoleManager.Instance.RoleData.zone_id then
        self.BtnShare.gameObject:SetActive(true)
    else
        self.BtnShare.gameObject:SetActive(false)
    end

    local cfgData = DataTournament.data_list[socketData.rank_lev]
    self.LeftTitleTxt.text = string.format(TI18N("第%s赛季"), BaseUtils.NumToChn(WorldChampionManager.Instance.season_id))
    self.LeftLevNameTxt.text = cfgData.name
    self.rightItemList[1]:Find("TxtName"):GetComponent(Text).text = socketData.name
    self.rightItemList[1]:Find("ImgClasses"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_"..socketData.classes)
    self.rightItemList[2]:Find("TxtGood"):GetComponent(Text).text = string.format(TI18N("点赞：%s"), tostring(socketData.liked))
    self.rightItemList[3]:Find("TxtName"):GetComponent(Text).text = string.format(TI18N("头衔：<color='#AD3BD2'>%s</color>"), DataTournament.data_list[socketData.rank_lev].name)
    local str = ""
    if socketData.combat_count == 0 then
        str = string.format("%s%s", 0, "%")
    else
        str = string.format("%s%s", math.ceil((socketData.win_count/socketData.combat_count)*100), "%")
    end
    self.rightItemList[4]:Find("TxtGood"):GetComponent(Text).text = string.format(TI18N("赛季胜率：<color='#22921B'>%s</color>（%s/%s)"), str, socketData.win_count, socketData.combat_count)
    self.rightItemList[5]:Find("TxtName"):GetComponent(Text).text = string.format(TI18N("历史胜场：%s（%s连胜)"), socketData.best_win_count, socketData.best_win_sustained)
    self.rightItemList[6]:Find("TxtGood"):GetComponent(Text).text = string.format(TI18N("历史最佳：<color='#BE6F44'>%s</color>"), DataTournament.data_list[socketData.best_rank_lev].name)


    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.LeftIcon.gameObject)
    end
    self.headLoader:SetSprite(SingleIconType.Pet, cfgData.icon)
    -- self.LeftIcon.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(cfgData.icon), cfgData.icon)
    self.LeftIcon.gameObject:SetActive(true)
    if #socketData.best_partner == 0 then
        self.rightItemList[7].gameObject:SetActive(false)
        self.rightItemList[8].gameObject.transform.anchoredPosition = Vector2(0.5,-82.9)
    else
        self.rightItemList[7].gameObject:SetActive(true)
        self.rightItemList[7]:Find("TxtName"):GetComponent(Text).text = string.format(TI18N("最佳拍档：%s"), socketData.best_partner[1].partner_name)
        self.rightItemList[8].gameObject.transform.anchoredPosition = Vector2(0.5,-116.3)
    end
    --WorldChampionManager.Instance:Require16430(RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)
    --self:UpdateTimes()
    self.rightItemList[8].gameObject:SetActive(false)
end

function WorldChampionShareWindow:UpdateTimes()



    if WorldChampionManager.Instance.times > 0 then
        self.rightItemList[8].gameObject:SetActive(true)
        local bradgeText = self.rightItemList[8].gameObject.transform:Find("TxtName"):GetComponent(Text)
        bradgeText.text = string.format("王者赛季,共<color='#ffff00'>%s</color>个",WorldChampionManager.Instance.times)
    else
        self.rightItemList[8].gameObject:SetActive(false)
    end
    self.rightItemList[8].gameObject:SetActive(false)
end