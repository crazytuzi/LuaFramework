CampaignWindow = CampaignWindow or BaseClass(BaseWindow)

function CampaignWindow:__init(model,args)
    self.model = model
    self.name = "CampaignWindow"
    self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.campaign_uniwin

    self.resList = {
        {file = AssetConfig.halloweenwindow, type = AssetType.Main}
        ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
        ,{file = AssetConfig.campaign_icon, type = AssetType.Dep}
        ,{file = AssetConfig.dropicon, type = AssetType.Dep}

        ,{file = AssetConfig.anniversaryWin, type = AssetType.Main}
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
    }

    self.panelList = {}
    self.panelIdList = {}

    self._UpdagteRedPoint = function() self:UpdagteRedPoint() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.openCampaignIndex = nil
    self.openCampaignSubIndex = nil

    self.ArgsId = args[1]
end

function CampaignWindow:InitPanel()
    if self:CheckIsAnniversary() then 
        self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.anniversaryWin))
    else
        self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenwindow))
    end

    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.titleImg = t:Find("Main/Title/Image"):GetComponent(Image)
    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/BaseItem").gameObject
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:ChangeTab(index,nil,self.rightContainer) end)
    self.tree.canRepeat = false
    --self.IsCheck = true
end

function CampaignWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CampaignWindow:__delete()
    self.OnHideEvent:Fire()

    if self.panelIdList ~= nil then
        for _,v in pairs(self.panelIdList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelIdList = nil
    end
    if self.titleImg ~= nil then
        self.titleImg.sprite = nil
    end
    if self.tree ~= nil then
        self.tree:DeleteMe()
        self.tree = nil
    end
    self:AssetClearAll()

    -- 周年庆期间ios的特殊处理
    if BaseUtils.IsIPhonePlayer() then
        -- 清理资源
        LuaTimer.Add(2000, function() AssetPoolManager.Instance:DoUnloadUnusedAssets() end)
    end
end

function CampaignWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.camp_red_change,self._UpdagteRedPoint)
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.openId = self.openArgs[1]
        self.campaignIconType = tonumber(DataCampaign.data_list[self.openId].iconid)
        self:InitTreeInfo()
        self.tree:SetData(self.treeInfo)
    end

    self:UpdagteRedPoint()


    local pos = self.campaignIdToPos[self.openId] or {1, 1}
    self.tree:ClickMain(pos[1], pos[2])

    EventMgr.Instance:AddListener(event_name.campaign_change, self._UpdagteRedPoint)

    self:UpdateCampaignTitleImg()
end

function CampaignWindow:UpdateCampaignTitleImg()
    if self:CheckIsAnniversary() then  return end   --周年庆对标题不作处理

    local dataCampIco = DataCampaign.data_camp_ico[tonumber(self.campaignIconType)] 
    if dataCampIco ~= nil then 
        if dataCampIco.title_name ~= "" then 
            self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign, dataCampIco.title_name)
            self.titleImg:SetNativeSize()
            return
        end
    end

    if tonumber(self.campaignIconType) == 48 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"MeshTitleI18N")
    elseif tonumber(self.campaignIconType) == 49 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"KaiXueTitle")
    elseif tonumber(self.campaignIconType) == 50 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"QiXiTitleI18N")
        self.titleImg:SetNativeSize()
    elseif tonumber(self.campaignIconType) == 51 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"I18NAutumGold")
        self.titleImg:SetNativeSize()
    elseif tonumber(self.campaignIconType) == 53 then
        if self.model.isSpecialTitle == true then
            self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"MidAutumnTitleI18N")
        elseif self.model.isSpecialTitle == false then
            self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"NationalDayTitleI18N")
        end
        self.titleImg:SetNativeSize()
    elseif tonumber(self.campaignIconType) == 54 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"CampaignAutumnI18N")
    elseif tonumber(self.campaignIconType) == 55 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HalloweenTitleI18N")
    elseif tonumber(self.campaignIconType) == 56 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"DoubleElevenI18N")
    elseif tonumber(self.campaignIconType) == 57 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"WarmWinterI18N")
    elseif tonumber(self.campaignIconType) == 58 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"petPartyI18N")
    elseif tonumber(self.campaignIconType) == 60 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"I18NQdkh")    --庆典狂欢
    elseif tonumber(self.campaignIconType) == 61 then
        self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"I18NWinterDoing")   --冬日巨献
    elseif tonumber(self.campaignIconType) == 62 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"ChristmasTitleTI18N")  --圣诞狂欢
    elseif tonumber(self.campaignIconType) == 63 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"NewYearTitleTI18N")  --元旦狂欢
    elseif tonumber(self.campaignIconType) == 65 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappyCeremonyI18N")  --欢乐盛典
    elseif tonumber(self.campaignIconType) == 66 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"JanuaryTitleI18N")  --元月献礼
    elseif tonumber(self.campaignIconType) == 67 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"RechargeCouponTitleI18N")  --充值礼券
    elseif tonumber(self.campaignIconType) == 68 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LabaTitleTI18N")  --浓情腊八
    elseif tonumber(self.campaignIconType) == 70 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappyNewyearTI18N")
    elseif tonumber(self.campaignIconType) == 71 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"NewyearHappyTI18N")
    elseif tonumber(self.campaignIconType) == 73 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LanaryFestivalI18N")
    elseif tonumber(self.campaignIconType) == 74 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"ArborTitleI18N")
    elseif tonumber(self.campaignIconType) == 75 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappySpringI18N")    --乐享初春
    elseif tonumber(self.campaignIconType) == 76 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"WarmthSpringI18N")    --暖暖春分
    elseif tonumber(self.campaignIconType) == 77 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"EntertainmentI18N")    --欢快娱人
    elseif tonumber(self.campaignIconType) == 78 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"AprilHappyI18N")    --四月狂欢
    elseif tonumber(self.campaignIconType) == 79 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"Nuan2SpringDayI18N")    --暖暖春日
    elseif tonumber(self.campaignIconType) == 80 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"CourtesyTitleTI18N")    --好礼来袭
    elseif tonumber(self.campaignIconType) == 81 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LaborGloryTitleTI18N")    --劳动光荣
    elseif tonumber(self.campaignIconType) == 82 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"ColorfulSummerTI18N")    --缤纷夏日
    elseif tonumber(self.campaignIconType) == 84 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"OceanPartyTI18N")    --缤纷夏日
    elseif tonumber(self.campaignIconType) == 85 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"SixOneDayTitleI18N")    --六一快乐
    elseif tonumber(self.campaignIconType) == 86 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"CourtesyTitleTI18N")    --好礼来袭
    elseif tonumber(self.campaignIconType) == 87 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"DragonboatTI18N")    --端午
    elseif tonumber(self.campaignIconType) == 88 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"CourtesyTitleTI18N")    --好礼来袭
    elseif tonumber(self.campaignIconType) == 89 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"CoolsummerTitleI18N")    --端午
    elseif tonumber(self.campaignIconType) == 90 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"CoolsummerTI18N")    --清凉消暑
    elseif tonumber(self.campaignIconType) == 91 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"SummerGiftTI18N")    --盛夏献礼
    elseif tonumber(self.campaignIconType) == 92 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"SummerHappyI18N")    --盛夏献礼
    elseif tonumber(self.campaignIconType) == 93 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"SummerGiftTI18N")    --暑假狂欢
    elseif tonumber(self.campaignIconType) == 94 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"GragrantHolidayTI18N")    --美好假日
    elseif tonumber(self.campaignIconType) == 95 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LightAutumnGiftTI18N")    --初秋献礼
    elseif tonumber(self.campaignIconType) == 96 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"ValentineDayTI18N")    --七夕
    elseif tonumber(self.campaignIconType) == 97 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LXHLTI18N")    --乐享好礼
    elseif tonumber(self.campaignIconType) == 98 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappyParentDay")    --欢乐开学季
    elseif tonumber(self.campaignIconType) == 99 or tonumber(self.campaignIconType) == 100 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"CourtesyTitleTI18N")    --好礼来袭
    elseif tonumber(self.campaignIconType) == 101 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"WarmMidAutumnTI18nN")    --温情中秋
    elseif tonumber(self.campaignIconType) == 102 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"NationalDayTI18N")    --国庆庆典
    elseif tonumber(self.campaignIconType) == 103 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"CourtesyTitleTI18N")    --好礼来袭
    elseif tonumber(self.campaignIconType) == 104 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"BumperHolidayTI18N")    --丰收佳日
    elseif tonumber(self.campaignIconType) == 105 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HalloweenHappyDayI18N")    --万圣狂欢
    elseif tonumber(self.campaignIconType) == 106 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LXKHTitleI18N") --乐享狂欢
    elseif tonumber(self.campaignIconType) == 108 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"CourtesyTitleTI18N")    --好礼来袭
    elseif tonumber(self.campaignIconType) == 110 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"NuanNuanWinterTi18n")    --凛冬将至
    elseif tonumber(self.campaignIconType) == 112 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"WinterHappyDayTI18N")    --冬季狂歡
    elseif tonumber(self.campaignIconType) == 113 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"winterGivingGiftTI18N")   --冬日献礼
    elseif tonumber(self.campaignIconType) == 114 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"GodComingTitleI18N")  --圣诞狂欢
    elseif tonumber(self.campaignIconType) == 115 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"ChristmasTitleTI18N")  --圣诞狂欢
    elseif tonumber(self.campaignIconType) == 116 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"NewYearTitleTI18N")  --元旦狂欢
    elseif tonumber(self.campaignIconType) == 117 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"winterGoodGiftTI18N")  --冬日好礼
    elseif tonumber(self.campaignIconType) == 119 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LabaTitleTI18N")  --浓情腊八
    elseif tonumber(self.campaignIconType) == 120 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"NewYearGivingGiftTI18N")  --元月献礼
    elseif tonumber(self.campaignIconType) == 121 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappyNewYearTI18N")  --喜迎新年
    elseif tonumber(self.campaignIconType) == 122 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"NewSpringTI18N")  --新春狂欢
    elseif tonumber(self.campaignIconType) == 123 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"DoublePeopleTI18N")  --浪漫情人节
    elseif tonumber(self.campaignIconType) == 124 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"GluePudDayTI18N")  --元宵佳节
    elseif tonumber(self.campaignIconType) == 125 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappyCeremonyI18N")  --欢乐盛典
    elseif tonumber(self.campaignIconType) == 126 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappyCeremonyI18N")  --欢乐盛典
    elseif tonumber(self.campaignIconType) == 127 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"TreeTI18N")  --植树迎春
    elseif tonumber(self.campaignIconType) == 128 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappySpringI18N")  --乐享初春
    elseif tonumber(self.campaignIconType) == 129 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HundredFlowersI18N")  --百花盛宴
    elseif tonumber(self.campaignIconType) == 131 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"AprilHappyI18N")  --暖暖春日
    elseif tonumber(self.campaignIconType) == 132 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"Nuan2SpringDayI18N")  --四月狂欢
    elseif tonumber(self.campaignIconType) == 133 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"MechAttackI18N")  --机甲来袭
    elseif tonumber(self.campaignIconType) == 134 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LXKHTitleI18N")  --乐享狂欢
    elseif tonumber(self.campaignIconType) == 135 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LaborGloryTitleTI18N")  --劳动光荣
    elseif tonumber(self.campaignIconType) == 136 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappySummerTI18N")  --欢乐初夏
    elseif tonumber(self.campaignIconType) == 137 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"FullshopI18N")  --满减商城
    elseif tonumber(self.campaignIconType) == 138 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"LXHLTI18N")  --乐享好礼
    elseif tonumber(self.campaignIconType) == 139 then
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"MayHappyI18N")  --五月天狂欢
    else
        self.titleImg.sprite  = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"I18NQdkh")    --默认
    end


    self.titleImg:SetNativeSize()
end

function CampaignWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.camp_red_change,self._UpdagteRedPoint)
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self._UpdagteRedPoint)
end

function CampaignWindow:OnHide()
    self:RemoveListeners()
    --self.IsCheck = false
    if self.panelList[self.openCampaignIndex]~= nil and self.panelList[self.openCampaignIndex][self.openCampaignSubIndex] ~= nil then
        self.panelList[self.openCampaignIndex][self.openCampaignSubIndex]:Hiden()
    end
end

function CampaignWindow:ChangeTab(index,subIndex,parent)
    if self.lastIndex ~= nil and self.lastGroupIndex ~= nil and self.panelList[self.lastIndex] ~= nil and self.panelList[self.lastIndex][self.lastGroupIndex] and not BaseUtils.isnull(self.panelList[self.lastIndex][self.lastGroupIndex].gameObject) and self.panelList[self.lastIndex][self.lastGroupIndex].gameObject.activeSelf then
        if self.openCampaignIndex ~= nil and self.openCampaignIndex == index then
            return
        end
    end

    local model = self.model
    if self.lastIndex ~= nil and self.lastGroupIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil and self.panelList[self.lastIndex][self.lastGroupIndex] then
            self.panelList[self.lastIndex][self.lastGroupIndex]:Hiden()       --让上一个窗口隐藏
        end
    end

    subIndex = subIndex or 1
    if self.panelList[index] == nil then self.panelList[index] = {} end
    local panel = self.panelList[index][subIndex]
    local treeInfoId = self.treeInfo[index].datalist[subIndex]
    local panelId = self.panelIdList[treeInfoId.id]

    local campaignData = DataCampaign.data_list[treeInfoId.id]
    local type = campaignData.cond_type
    local iconType = campaignData.iconid
    self.openCampaignIndex = index
    self.openCampaignSubIndex = subIndex
    -- print(string.format("treeInfoId.id %s", treeInfoId.id))
    -- print(string.format("type %s", type))

    self.openId = nil
    if type == CampaignEumn.ShowType.Lantern
        or type == CampaignEumn.ShowType.DoubleElevenFeedback
        or type == CampaignEumn.ShowType.RideShow
        then
        self.openId = campaignData.id
    end

    if panelId == nil then
        if type == CampaignEumn.ShowType.Lantern then
            panelId = NewYearReward.New(self.model,parent)
            panelId.iconIndex = self.campaignIconType          --53
            panelId.mainIndex = campaignData.index             
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.ShowType.BuyPackage then
            panelId = HalloweenMoonPanel.New(self.model,parent)
            panelId.iconIndex = self.campaignIconType
            panelId.mainIndex = campaignData.index
            panelId.campId = campaignData.id
            panelId.bg = AssetConfig.goodcourtesytitle
            table.insert(panelId.resList, {file = panelId.bg, AssetType.Main})
        elseif type == CampaignEumn.ShowType.NewFashion then
            panelId = MeshFashionNew.New(self.model,parent)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.ShowType.DoubleElevenFeedback then
            panelId = DoubleElevenFeedbackPanel.New(self.model, parent)
            panelId.campId = campaignData.id
            -- panelId.bg = AssetConfig.newyearrebate_big_bg
            -- table.insert(panelId.resList, {file = panelId.bg, AssetType.Main})
        elseif type == CampaignEumn.ShowType.OpenServerFlop then
            panelId = OpenServerFlop.New(self.model, parent)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.ShowType.TreasureHunting then
            panelId = TreasureHunting.New(self.model, parent)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.ShowType.SeekChildren  then
            panelId = SeekChildrenPanel.New(SummerManager.Instance.model,parent)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.ShowType.DoubleElevenGroup then
            panelId = DoubleElevenGroupBuyPanel.New(DoubleElevenManager.Instance.model,parent,self.gameObject)
            panelId.bg = AssetConfig.groupbuybgti18n
            panelId.campId = campaignData.id
            table.insert(panelId.resList, {file = panelId.bg, AssetType.Main})
        elseif type == CampaignEumn.ShowType.Hand  then
            panelId =  GiveMeYourHand.New(self.model,parent)
            panelId.target = "44_1"
            panelId.bg = AssetConfig.valentine_bg
            panelId.campId = campaignData.id
            table.insert(panelId.resList, {file = panelId.bg, AssetType.Main})
            panelId.afterSprintFunc = function(loader) loader:SetOtherSprite(self.assetWrapper:GetSprite(self.model.campShowSpriteFuncTab[type].package, self.model.campShowSpriteFuncTab[type].name)) end
        elseif type == CampaignEumn.ShowType.IntiMacy  then
            panelId = IntiMacyPanel.New(parent, self.model)
            panelId.campId = campaignData.id
            WorldLevManager.Instance.CurRankType = CampaignEumn.CampaignRankType.Intimacy
        elseif type == CampaignEumn.ShowType.QiXi then
            panelId = LoveActivePanel.New(self.model,parent)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.ShowType.BigPicture then
            panelId = PictureDesc.New(self.model, parent)
            panelId.campId = treeInfoId.id
            panelId.bg = AssetConfig.picture_desc1
            table.insert(panelId.resList, {file = panelId.bg, AssetType.Main})
        elseif type == CampaignEumn.ShowType.Secondary then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_secondarywin,{tonumber(iconType),treeInfoId.id})
        elseif type == CampaignEumn.ShowType.Turntable then
            panelId = TurntabelRechargePanel.New(self.model, parent)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.ShowType.SkyLantern then
            panelId = MidAutumnDesc.New(self.model,parent)
            --panelId.bg = AssetConfig.midAutumnBg
            --table.insert(panelId.resList, {file = panelId.bg, AssetType.Main})
            panelId.bg1 = AssetConfig.LunarlanternTopBg
            panelId.bg2 = AssetConfig.LunarlanternTopTitleI18N
            panelId.campId = campaignData.id
            panelId.type = CampaignEumn.ShowType.SkyLantern
            panelId.campaignData = DataCampaign.data_list[campaignData.id]
            table.insert(panelId.resList, {file = panelId.bg1, AssetType.Main})
            table.insert(panelId.resList, {file = panelId.bg2, AssetType.Main})
            panelId.target = "46_1"
        elseif type == CampaignEumn.ShowType.PoetryChallenge then
            panelId = MidAutumnDesc.New(self.model,parent)
            panelId.bg1 = AssetConfig.poetryChallenge
            panelId.bg2 = AssetConfig.poetryChallengeText
            panelId.campId = campaignData.id
            panelId.type = CampaignEumn.ShowType.PoetryChallenge
            panelId.campaignData = DataCampaign.data_list[campaignData.id]
            table.insert(panelId.resList, {file = panelId.bg1, AssetType.Main})
            table.insert(panelId.resList, {file = panelId.bg2, AssetType.Main})
            panelId.target = "46_1"
        elseif type == CampaignEumn.ShowType.RebateReward then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rebatereward_window,{treeInfoId.id})
        elseif type == CampaignEumn.ShowType.SecondaryTop then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_secondarytopwin,{tonumber(iconType),treeInfoId.id})
        elseif type == CampaignEumn.ShowType.RechargePackage then
            panelId = HalloweenSugerPanel.New(self.model, parent)
            panelId.campId = campaignData.id
            --panelId.bg = AssetConfig.rechargePackage
            --table.insert(panelId.resList, {file = panelId.bg, AssetType.Main})
        elseif type == CampaignEumn.ShowType.Exchange_Window then
            local datalist = {}
            local lev = RoleManager.Instance.RoleData.lev
            local strList = StringHelper.Split(campaignData.camp_cond_client, ",")
            local exchange_first = tonumber(strList[1]) or 2
            local exchange_second = tonumber(strList[2]) or 28
            for i,v in pairs(ShopManager.Instance.model.datalist[exchange_first][exchange_second]) do
                table.insert(datalist, v)
            end
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = campaignData.reward_title, extString = campaignData.content})
        elseif type == CampaignEumn.ShowType.FlowerAccept then
            panelId = NationalSecondFlowerAcceptPanel.New(self.model,parent)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.AutumnBargain then
            panelId = CampaignAutumnPanel.New(self.model,parent)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.LoginReward then
            panelId = SevenLoginPanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
            panelId.bg = AssetConfig.dragonboatlogin_big_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.Boat then
            panelId = DragonBoatPanel.New(self.model, self.rightContainer)
            panelId.campId = campaignData.id
            --panelId.bg = AssetConfig.fastskiingtitle
            panelId.bg = AssetConfig.dragonpixtitle
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.Zongzi then
            panelId = RiceDumplingPanel.New(self.model,self.rightContainer)
            panelId.campDataGroup = {type = tonumber(iconType), index = tonumber(campaignData.index)}
            panelId.campId = treeInfoId.id
            panelId.bg = AssetConfig.halloween_i18n_bg4
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.Consume then
            panelId = DragonBoatConsmRtnPanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.dragonboat_topbg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campaignGroup = CampaignManager.Instance.campaignTree[tonumber(iconType)][tonumber(campaignData.index)]
        elseif type == CampaignEumn.ShowType.KillEvil then
            panelId = HalloweenKillEvilPanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
            panelId.bg = AssetConfig.halloween_i18n_bg2
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.DiscountHalloween then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.discountshopwindow2, {treeInfoId.id})
            return
        elseif type == CampaignEumn.ShowType.TalkBubble then
            panelId = CampaignDesc.New(self.model, self.rightContainer)
            panelId.campId = treeInfoId.id
            panelId.bg = AssetConfig.halloween_i18n_bg2
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})

        elseif type == CampaignEumn.ShowType.LoveWish then
            panelId = LoveConnection.New(self.model, self.rightContainer)
            --panelId.campData = DataCampaign.data_list[treeInfoId.id]
            panelId.campId = treeInfoId.id
            panelId.bg = AssetConfig.whitevalentine_bg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.AnnualExchange then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.cakeexchangwindow)
        elseif type == CampaignEumn.ShowType.SaveSingleDog then
            panelId = SingleDogPanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.SpriteEgg then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.magicegg_window, {treeInfoId.id})
        -- elseif type == CampaignEumn.ShowType.CampaignInquiry then
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_inquiry_window)
        elseif type == CampaignEumn.ShowType.SalesPromotion then
            panelId = SalesPromotionPanel.New(self.rightContainer)
            panelId.campId = treeInfoId.id
            panelId.bg = AssetConfig.LunarypreferenceTopBgI18N
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.SummerDoing then
            panelId = SummerQuest.New(self.model,self.rightContainer)
            panelId.bg = AssetConfig.summer_quest_big_bg
            panelId.campId = treeInfoId.id
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.CuteSnowMan then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.christmas_snowman, {treeInfoId.id})
        elseif type == CampaignEumn.ShowType.SnowFight then
            panelId = ChristmasDescPanel.New(model, self.rightContainer)
            panelId.campId = campaignData.id
            panelId.bg = AssetConfig.christmassnowfightti18n
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.RideShow then
            panelId = ChristmasRidePanel.New(self.model,self.rightContainer)
            panelId.bg = AssetConfig.christmasridebgi19n
            panelId.campId = treeInfoId.id
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.FashionSelection then

            if FashionSelectionManager.Instance:IsFashionVoteEnd() == false then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fashion_selection_window,{campId = treeInfoId.id})
            elseif FashionSelectionManager.Instance:IsFashionVoteEnd() == true then
                FashionSelectionManager.Instance:send20414()
            end

        elseif type == CampaignEumn.ShowType.FastSkiing then
            --panelId.target = "80_1"
            panelId = PathFindingPanel.New(self.model,self.rightContainer)
            panelId.bg = AssetConfig.christmasridebgi19n
            panelId.campId = treeInfoId.id
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.RechargeCoupon then
            panelId = RechargePointsPanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.LimitTimeStore then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.discountshopwindow,{campId = treeInfoId.id})
        elseif type == CampaignEumn.ShowType.FashionDiscount then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fashion_discount_window,{campId = treeInfoId.id})
        elseif type == CampaignEumn.ShowType.DragonKingSendsBless then
            panelId = BigSummerPubPanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.NewYearTurnable then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.new_year_turnable_window,{campId = treeInfoId.id, titleImg = self.titleImg.sprite})
        elseif type == CampaignEumn.ShowType.NewYearGoods then
            panelId = HalloweenMoonPanel.New(self.model,self.rightContainer)    -- 压岁钱
            panelId.bg = AssetConfig.newyeargoodstitle
            panelId.campId = treeInfoId.id
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.LuckyMoney then
            panelId = LuckMoney2.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.MulticoloredMountainsAndRivers then
            panelId = NewLabourTypePanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.newlahourbg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campData = campaignData
            panelId.targetNpc = "86_1"
            panelId.btnName = TI18N("前去参与")
        elseif type == CampaignEumn.ShowType.LanternMultiRecharge then
           panelId = ContinueChargePanel.New(NewMoonManager.Instance.model, self.rightContainer)
            panelId.campBaseData = campaignData
        elseif type == CampaignEumn.ShowType.RushTop then
            panelId = RushTopDesc.New(self.model,parent)
            panelId.bg1 = AssetConfig.RushtopTopBg
            panelId.bg2 = AssetConfig.RushtopTopTitleI18N
            panelId.campId = campaignData.id
            panelId.type = CampaignEumn.ShowType.RushTop
            panelId.campaignData = DataCampaign.data_list[campaignData.id]
            table.insert(panelId.resList, {file = panelId.bg1, AssetType.Main})
            table.insert(panelId.resList, {file = panelId.bg2, AssetType.Main})
            panelId.target = "46_1"
        elseif type == CampaignEumn.ShowType.SweetCake then
            panelId = PathFindingPanel.New(self.model, self.rightContainer)
            panelId.campId = campaignData.id
        elseif type == CampaignEumn.ShowType.SignDraw then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.signdrawwindow,{campId = treeInfoId.id,  titleImg = self.titleImg.sprite})
        elseif type == CampaignEumn.ShowType.SummerCold then
            panelId = SummerLossChildPanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.AprilTreasure then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.AprilTreasure_win,{campId = treeInfoId.id})
        elseif type == CampaignEumn.ShowType.PurifyHome then
            panelId = NewLabourTypePanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.newlahourbg
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campData = campaignData
            panelId.targetNpc = "32024_1"
            panelId.btnName = TI18N("前去参与")
        elseif type == CampaignEumn.ShowType.PassBless then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.passblesswindow,{campId = treeInfoId.id})
        elseif type == CampaignEumn.ShowType.Anniversary then
            panelId = AnniversaryTyPanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.FullSubtraction then               --满减商城
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fullsubtractionshop,{campId = treeInfoId.id})
        elseif type == CampaignEumn.ShowType.FruitPlant then
            panelId = SummerFruitPlantPanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.NewRebate then
            panelId = NewRebatePanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
            panelId.dataList = ShopManager.Instance:GetDataList(type)
        elseif type == CampaignEumn.ShowType.ConSumeRank  then
            panelId = CampaignRankPanel.New(self.rightContainer, CampaignEumn.CampaignRankType.ConSume, treeInfoId.id, self, true)
            table.insert(panelId.resList, {file = AssetConfig.bg_campaignrankbg_consume, type = AssetType.Main})
        elseif type == CampaignEumn.ShowType.IntegralExchange then 
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.integralexchangewindow,{campId = treeInfoId.id})
        elseif type == CampaignEumn.ShowType.NewRechargeGift then 
            panelId = NewRechargePanel.New(self.model,self.rightContainer)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.DirectPackage then 
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.directpackagewindow,{campId = treeInfoId.id})
        elseif type == CampaignEumn.ShowType.LuckyTree then 
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.luckytreewindow,{campId = treeInfoId.id})
        elseif type == CampaignEumn.ShowType.IntoGold then
            panelId = NewLabourTypePanel.New(self.model, self.rightContainer)
            panelId.bg = AssetConfig.newlahourbg1
            table.insert(panelId.resList, {file = panelId.bg, type = AssetType.Main})
            panelId.campData = campaignData
            panelId.targetNpc = "32024_1"
            panelId.btnName = TI18N("前去参与")
        elseif type == CampaignEumn.ShowType.WarOrder then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warorderwindow, {index = 1, campId = treeInfoId.id})            
        elseif type == CampaignEumn.ShowType.CustomGift then 
            panelId = CustomGiftPanel.New(self.model, self.rightContainer)
            panelId.campId = treeInfoId.id
        elseif type == CampaignEumn.ShowType.PrayTreasure then 
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.praytreasurewindow, {campId = treeInfoId.id})
        elseif type == CampaignEumn.ShowType.Other  then
        end
        self.panelIdList[treeInfoId.id] = panelId
    end
    --- if panel == nil then
        -- panel = panelId
        -- panel.protoData = CampaignManager.Instance.campaignTree[self.campaignIconType][campaignData.index]
        self.panelList[index][subIndex] = panelId
        -- panel.icon = self.assetWrapper:GetSprite(self.treeInfo[index].package, self.treeInfo[index].iconName)
    -- end

    self.lastIndex = index
    self.lastGroupIndex = subIndex

    if panelId ~= nil then
        panelId:Show()
    end
end


function CampaignWindow:InitTreeInfo()
    local tempData = CampaignManager.Instance.campaignTree[self.campaignIconType]
    local baseCampaignData = DataCampaign.data_list
    self.mayData = tempData
    -- for index,v in pairs(tempData) do
    --     -- if index == CampaignEumn.MayType.Summer then
    --         table.insert(self.mayData, v)
    --     -- end
    -- end
    -- BaseUtils.dump(self.mayData, "<color=#FF0000>mayData</color>")

    if self.mayData == nil then
        Log.Error("[活动]打开活动面板参数错误，活动数据为空，self.campaignIconType = "..self.campaignIconType);
    end

    local infoTab = {}
    local c = 1
    for index,v in pairs(self.mayData) do
        if index ~= "count" and (#v.sub ~= 1 or DataCampaign.data_list[v.sub[1].id].cond_type ~= CampaignEumn.ShowType.NoShow) then
            if #v.sub > 1 then
                table.sort(v.sub,function(a,b)
                   if a.id ~= b.id then
                        return a.id < b.id
                    else
                        return false
                    end
                end)
            end

            if infoTab[c] == nil then
                infoTab[c] = {height = 60, subs = {}, type = index, datalist = {}, resize = false}
                c = c + 1
            end
            local main = infoTab[c - 1]
            main.datalist = v.sub
            main.label = baseCampaignData[v.sub[1].id].name
            -- print(main.label)
            main.sprite = nil

            local showType = DataCampaign.data_list[v.sub[1].id].cond_type
            local tab = self.model.campShowSpriteFuncTab[showType]
            if tab == nil then
                self.model.campShowSpriteFuncTab[showType] = {package = AssetConfig.dropicon,name = tostring(DataCampaign.data_list[v.sub[1].id].dropicon_id)}
                tab = self.model.campShowSpriteFuncTab[showType]
            end
            if type(tab) == "table" then
                main.sprite = self.assetWrapper:GetSprite(tab.package, tab.name)
            elseif type(tab) == "function" then
                main.spriteFunc = tab
            end
        end



    end
    self.treeInfo = infoTab

    -- BaseUtils.dump(infoTab)

    self.campaignIdToPos = {}
    for index,v in pairs(infoTab) do
        for index2,sub in pairs(v.datalist) do
            if #v.subs == 0 then
                self.campaignIdToPos[sub.id] = {index, 1}
            else
                self.campaignIdToPos[sub.id] = {index, index2}
            end
        end
    end
end

function CampaignWindow:ClickSub(data)
    self:ChangeTab(data[1], data[2])
end

function CampaignWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function CampaignWindow:UpdagteRedPoint()
    local treeData = CampaignManager.Instance.campaignTree[self.campaignIconType]
    if self.tree ~= nil and treeData ~= nil then

        -- BaseUtils.dump(treeData, "treeData")
        local id = nil
        local pos = nil
        for _,main in pairs(treeData) do
            if main ~= nil and type(main) ~= "number" then
                local red = false
                for _,v in pairs(main.sub) do
                    id = id or v.id
                    red = red or (self.model.redPointList[v.id] == true)

                    pos = self.campaignIdToPos[v.id]
                    if pos ~= nil then
                        self.tree:RedSub(pos[1], pos[2], self.model.redPointList[v.id])
                    end
                end
                if pos ~= nil then
                    self.tree:RedMain(pos[1], red)
                end
                id = nil
            end
        end
    end
end

--是否为周年庆活动
function CampaignWindow:CheckIsAnniversary()
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.openId = self.openArgs[1]
        self.campaignIconType = tonumber(DataCampaign.data_list[self.openId].iconid)
    end
    local campaignName = DataCampaign.data_camp_ico[self.campaignIconType].name
    if campaignName == "周年庆活动" then 
        return true
    end
    return false
end
