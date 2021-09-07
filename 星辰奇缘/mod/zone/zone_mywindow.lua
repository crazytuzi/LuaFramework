ZoneMyWindow = ZoneMyWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
Constellation = {
    [0]={name=TI18N("无"),character=TI18N("无"),cp=TI18N("无")},
    [1]={name=TI18N("白羊座"),character=TI18N("性格:勇敢、火热"),cp=TI18N("最佳配对：狮子座")},
    [2]={name=TI18N("金牛座"),character=TI18N("性格:浪漫、决断"),cp=TI18N("最佳配对：处女座")},
    [3]={name=TI18N("双子座"),character=TI18N("性格:开朗、机智"),cp=TI18N("最佳配对：水瓶座")},
    [4]={name=TI18N("巨蟹座"),character=TI18N("性格:温柔、友善"),cp=TI18N("最佳配对：双鱼座")},
    [5]={name=TI18N("狮子座"),character=TI18N("性格:善良、热情"),cp=TI18N("最佳配对：射手座")},
    [6]={name=TI18N("处女座"),character=TI18N("性格:细心、挑剔"),cp=TI18N("最佳配对：摩羯座")},
    [7]={name=TI18N("天秤座"),character=TI18N("性格:魅力、公正"),cp=TI18N("最佳配对：双子座")},
    [8]={name=TI18N("天蝎座"),character=TI18N("性格:理智、领导"),cp=TI18N("最佳配对：双鱼座")},
    [9]={name=TI18N("射手座"),character=TI18N("性格:乐观、敏锐"),cp=TI18N("最佳配对：白羊座")},
    [10]={name=TI18N("摩羯座"),character=TI18N("性格:聪明、宽大"),cp=TI18N("最佳配对：金牛座")},
    [11]={name=TI18N("水瓶座"),character=TI18N("性格:博爱、宽容"),cp=TI18N("最佳配对：天秤座")},
    [12]={name=TI18N("双鱼座"),character=TI18N("性格:唯美、善良"),cp=TI18N("最佳配对：天蝎座")},
}
BloodSetting = {
    [0] = TI18N("无"),
    [1] = TI18N("A型"),
    [2] = TI18N("B型"),
    [3] = TI18N("O型"),
    [4] = TI18N("AB型"),
}
function ZoneMyWindow:__init(model)
    self.model = model
    self.name = "ZoneMyWindow"
    self.windowId = WindowConfig.WinID.zone_mywin
    self.currpage = nil
    self.zoneMgr = self.model.zoneMgr
    self.tex2dList = {}
    self.resList = {
        {file = AssetConfig.zone_window, type = AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = AssetConfig.zone_textures, type = AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep}
        ,{file = AssetConfig.badge_icon, type = AssetType.Dep}
        ,{file = AssetConfig.photo_frame, type = AssetType.Dep}
        ,{file = AssetConfig.bigbadge, type = AssetType.Dep}
    }
    -- self.TabSelectPosX = {
    --     [1] = -65,
    --     [2] = 15,
    --     [3] = 94,
    --     [4] = 174,
    -- }

    self.TabSelectPosX = {
        [1] = -15,
        [2] = 65,
        [3] = 144,
        [4] = 224,
    }
    self.TabName = {
        [1] = TI18N("我的空间"),
        [2] = TI18N("好 友"),
        [3] = TI18N("最 热"),
        [4] = TI18N("发 现"),
    }

    self.giftsetpanel = GiftSetPanel.New(self)
    self.friendzonePanel = nil
    self.hotzonePanel = nil

    self.currStyle = 0
    self.currBadge = {}
    self.currFrame = 0
    self.currBigBadge = 0
    self.OnOpenEvent:Add(function() self:OnOpen() end)

    self.styleupdate = function(id)
        self:OnStyleUpdate(id)
    end
    self.frameupdate = function(id)
        self:OnFrameUpdate(id)
    end

    self.badgeupdate = function(list)
        self:OnBadgeUpdate(list)
    end

    self.bigbadgeupdate = function(id)
        self:OnBigBadgeUpdate(id)
    end

    self.specialBadgeUpdate = function()
        self:KingDataRefresh()
    end

    self.openLockPanelUpdate = function()
        self:OpenLockPanel()
    end
    self.photoList = {}
    self.assetWrapperLoaded = false


end

function ZoneMyWindow:__delete()
    if self.tex2dList ~= nil then
        for i,v in ipairs(self.tex2dList) do
            GameObject.Destroy(v)
        end
        self.tex2dList = nil
    end
    EventMgr.Instance:RemoveListener(event_name.zone_theme_update, self.styleupdate)
    EventMgr.Instance:RemoveListener(event_name.zone_frame_update, self.frameupdate)
    EventMgr.Instance:RemoveListener(event_name.zone_badge_update, self.badgeupdate)
    EventMgr.Instance:RemoveListener(event_name.zone_bigbadge_update, self.bigbadgeupdate)
    WorldChampionManager.Instance.onUpdateTimes:RemoveListener(self.specialBadgeUpdate)
    -- ZoneManager.Instance.updataMyZone:RemoveListener(self.onSetInfo)


    if self.tween ~= nil then
        LuaTimer.Delete(self.tween)
        self.tween = nil
    end
    self.giftsetpanel:DeleteMe()
    if self.chatExtPanel ~= nil then
        self.chatExtPanel:DeleteMe()
        self.chatExtPanel = nil
    end
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
        self.tabgroup = nil
    end
    if self.TrendsLayout ~= nil then
        self.TrendsLayout:DeleteMe()
        self.TrendsLayout = nil
    end
    if self.VisitLayout ~= nil then
        self.VisitLayout:DeleteMe()
        self.VisitLayout = nil
    end
    if self.GiftLayout ~= nil then
        self.GiftLayout:DeleteMe()
        self.GiftLayout = nil
    end
    if self.ZoneLooksPanelObj ~= nil then
        self.ZoneLooksPanelObj:DeleteMe()
        self.ZoneLooksPanelObj = nil
    end
    if self.StylePanelObj ~= nil then
        self.StylePanelObj:DeleteMe()
        self.StylePanelObj = nil
    end
    if self.friendzonePanel ~= nil then
        self.friendzonePanel:DeleteMe()
        self.friendzonePanel = nil
    end
    if self.hotzonePanel ~= nil then
        self.hotzonePanel:DeleteMe()
        self.hotzonePanel = nil
    end
    if self.citySetPanel ~= nil then
        self.citySetPanel:DeleteMe()
        self.citySetPanel = nil
    end
    if self.messagepanel ~= nil then
        self.messagepanel:DeleteMe()
        self.messagepanel = nil
    end

    if self.headpanel ~= nil then
        self.headpanel:DeleteMe()
        self.headpanel = nil
    end
    if self.momentspanel ~= nil then
        self.momentspanel:DeleteMe()
    end
    if self.citymomentspanel ~= nil then
        self.citymomentspanel:DeleteMe()
    end

    if self.dailytopicpanel ~= nil then
        self.dailytopicpanel:DeleteMe()
    end

    if self.assetWrapperLoaded then
        self:AssetClearAll()
    end
    self.bigBadge = nil
end

function ZoneMyWindow:InitPanel()
    self.assetWrapperLoaded = true
    self.myzoneData = self.zoneMgr.myzoneData
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.zone_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.MainCon = self.transform:Find("MainCon")
    self.TabSelectButton = self.transform:Find("MainCon/TabSelectButton")
    self.Tabbg = self.MainCon:Find("Tabbg")
    self.TabButtonGroup = self.MainCon:Find("TabButtonGroup")
    self.PanelTabButtonGroup = self.MainCon:Find("PanelTabButtonGroup")
    self.looksBtn = self.transform:Find("LooksButton")
    self.topbtn = {self.TabSelectButton.gameObject, self.Tabbg.gameObject, self.TabButtonGroup.gameObject}
    self.SubPanelCon = self.MainCon:Find("SubPanelCon")
    self.CommonTitle = self.SubPanelCon:Find("CommonTitle")
    self.CommonMyGiftText = self.CommonTitle:Find("MyGiftText"):GetComponent(Text)
    self.CommonLikeText = self.CommonTitle:Find("LikeText"):GetComponent(Text)
    self.CommonRecGiftText = self.CommonTitle:Find("RecGiftText"):GetComponent(Text)
    self.AddGiftButton = self.CommonTitle:Find("AddGiftButton"):GetComponent(Button)
    self.LikeButton = self.CommonTitle:Find("LikeButton"):GetComponent(Button)
    self.HasGiftButton = self.CommonTitle:Find("HasGiftButton"):GetComponent(Button)
    self.HasGiftIcon = self.CommonTitle:Find("GetGift/Icon"):GetComponent(Image)
    if self.iconloader1 == nil then
        self.iconloader1 = SingleIconLoader.New(self.HasGiftIcon.gameObject)
    end
    self.iconloader1:SetSprite(SingleIconType.Item, 20031)
    self.Sub1Con = self.transform:Find("MainCon/Sub1Con")
    self.Sub2Con = self.transform:Find("MainCon/Sub2Con")
    self.Sub3Con = self.transform:Find("MainCon/Sub3Con")

    self.InfoCon = self.transform:Find("MainCon/Info")


    self.TitleText = self.transform:Find("MainCon/Title/Text"):GetComponent(Text)
    self.NameText = self.transform:Find("MainCon/Info/NameText"):GetComponent(Text)
    self.ClassIcon = self.transform:Find("MainCon/Info/ClassIcon"):GetComponent(Image)
    self.LevText = self.transform:Find("MainCon/Info/LevText"):GetComponent(Text)
    self.CityText = self.transform:Find("MainCon/Info/CityText"):GetComponent(Text)
    self.ChenghaoText = self.transform:Find("MainCon/Info/ChenghaoText"):GetComponent(Text)
    self.GuildText = self.transform:Find("MainCon/Info/GuildText"):GetComponent(Text)
    self.StarText = self.transform:Find("MainCon/Info/StarText"):GetComponent(Text)
    self.CuppleText = self.transform:Find("MainCon/Info/CuppleText"):GetComponent(Text)
    self.LastNameText = self.transform:Find("MainCon/Info/LastNameText"):GetComponent(Text)
    self.transform:Find("MainCon/Info/LastNameButton").anchoredPosition = Vector2(-162, 24)
    self.transform:Find("MainCon/Info/LastNameButton").gameObject:SetActive(true)


    self.photoCon = self.transform:Find("MainCon/Info/Headbg/HeadMask/Con")
    self.SigInputField = self.transform:Find("MainCon/Info/SigInputField")
    self.SigInputField:GetComponent(InputField).lineType = InputField.LineType.MultiLineSubmit
    self.SigInputField:GetComponent(InputField).characterLimit = 40
    self:SetInputField(self.SigInputField)
    -- self:SetInputField(self.trendInputField)
    self.SigInputField:GetComponent(InputField).onEndEdit:AddListener(function()
        self:OnEndEditSig()
    end)
    self.SigInputField:GetComponent(InputField).enabled = self.zoneMgr.openself
    self.SigInputField:Find("Placeholder"):GetComponent(Text).enabled = self.zoneMgr.openself
    self.transform:Find("MainCon/Info/Headbg/Default").gameObject:SetActive(false)
    self.headImage = self.transform:Find("MainCon/Info/Headbg/Head"):GetComponent(Image)
    self.headImage.gameObject:SetActive(false)

    self.headButton = self.transform:Find("MainCon/Info/Headbg"):GetComponent(Button)
    self.headButton.onClick:AddListener(function() self:onCameraButtonClick() end)

    self.cameraButton = self.transform:Find("MainCon/Info/Headbg/CameraButton").gameObject

    self.auditeTips = self.transform:Find("MainCon/Info/Headbg/AuditeTips").gameObject
    self.auditeTips_text = self.transform:Find("MainCon/Info/Headbg/AuditeTips/Text"):GetComponent(Text)

    self.tipsCon = self.transform:Find("TipsCon").gameObject

    self.upLoadButton = self.tipsCon.transform:Find("Tips/UpLoadButton"):GetComponent(Button)
    self.upLoadButton.onClick:AddListener(function() self:OpenPhotoGallery() end)

    self.tsakePhotosButton = self.tipsCon.transform:Find("Tips/TakePhotosButton"):GetComponent(Button)
    self.tsakePhotosButton.onClick:AddListener(function() self:TakePhoto() end)

    self.delectButton = self.tipsCon.transform:Find("Tips/DelectButton"):GetComponent(Button)
    self.delectButton.onClick:AddListener(function() self:DelectPhoto() end)

    self.defaultButton = self.tipsCon.transform:Find("Tips/SetButton"):GetComponent(Button)
    self.defaultButton.onClick:AddListener(function() self:SetAsDefault() end)

    self.tipsCon.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:HideCameraTips() end)

    self:InitTab()
    self:InitInfo()
    self:SetInfo()
    -- self:InitSubCon()
    -- self:ChangeSubCon(1)
    self.messagepanel = ZoneMessagePanel.New(self.model, self)
    self.zoneMgr:Require11829(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
    self.zoneMgr:Require11840(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)

    if self.zoneMgr.openself then
        self.zoneMgr:Require11838()
        self.zoneMgr:Require11839()
    end
    self:InitWebcam()
    self.ZoneInfoSetPanel = self.transform:Find("MainCon/ZoneInfoSetPanel")
    self.XingzuoScroll = self.transform:Find("MainCon/ZoneInfoSetPanel/XingzuoScroll")
    self.ZoneInfoSetPanel:GetComponent(Button).onClick:AddListener(function()
        self.ZoneInfoSetPanel.gameObject:SetActive(false)
    end)
    for i = 1,12 do
        local item = self.XingzuoScroll:Find(string.format("Mask/XingzuoList/%s", tostring(i)))
        item:GetComponent(Button).onClick:AddListener(function()
            self.selectxingzuo = i
            -- print(string.gsub("12 11", "(%w+)%s*(%w+)", "%1"))
            self.zoneMgr:Require11833(TI18N("1992年12月12日"), self.selectxingzuo or self.myzoneData.constellation, self.myzoneData.abo, self.myzoneData.signature, self.myzoneData.region, self.myzoneData.sex)
            self.ZoneInfoSetPanel.gameObject:SetActive(false)
            end)
    end

    -- self.inputfield.onValueChange:AddListener(function (val) self:OnMsgChange(val) end)
    self.currStyle = self.zoneMgr:GetResId(self.myzoneData.theme)
    self.StylePanel = self.transform:Find("ZoneStylePanel")
    self.StylePanelObj = ZoneStylePanel.New(self, self.currStyle)
    self.ZoneLooksPanelObj = ZoneLooksPanel.New(self)
    if self.model.firstlooks then
        self.looksBtn:Find("Red").gameObject:SetActive(true)
        self.model.firstlooks = false
    else
        self.looksBtn:Find("Red").gameObject:SetActive(false)
    end
    self.looksBtn.gameObject:SetActive(self.zoneMgr.openself)
    self.looksBtn:GetComponent(Button).onClick:AddListener(function()
        self.looksBtn:Find("Red").gameObject:SetActive(false)
        if self.ZoneLooksPanelObj ~= nil then
            self.ZoneLooksPanelObj:Show()
        end
    end)
    self.badgeCon = self.transform:Find("MainCon/Info/Headbg/badge")
    for i=1,3 do
        self.badgeCon:Find(tostring(i)).transform:Find("Number").gameObject:SetActive(false)
        self.badgeCon:Find(tostring(i)):GetComponent(Button).onClick:AddListener(function()
            self:OnClickBadge(i)
        end)
    end
    self.photoFrame = self.transform:Find("MainCon/Info/Headbg/bg"):GetComponent(Image)
    self.bigBadge = self.transform:Find("MainCon/Info/Headbg/BigBadge"):GetComponent(Image)
    self.bigBadge.gameObject:GetComponent(Button).onClick:AddListener(function()
            self:OnClickBigBadge()
        end)

    self.currBadge = self.myzoneData.badges
    --BaseUtils.dump(self.currBadge,"收到的设开服角色的框架发送积分据了解")
    table.sort(self.currBadge, function(a,b) return a.badge_id<b.badge_id end)
    self.currFrame = self.zoneMgr:GetResId(self.myzoneData.photo_frame)
    for i,v in ipairs(self.currBadge) do

        self:SetBadge(i, v.badge_id)
    end
    local frameresid = self.zoneMgr:GetResId(self.currFrame)
    self:SetFrame(self.currFrame)

    self.currBigBadge = self.zoneMgr:GetResId(self.myzoneData.show_honor)
    self:SetBigBadge(self.currBigBadge)

    EventMgr.Instance:AddListener(event_name.zone_theme_update, self.styleupdate)
    EventMgr.Instance:AddListener(event_name.zone_frame_update, self.frameupdate)
    EventMgr.Instance:AddListener(event_name.zone_badge_update, self.badgeupdate)
    EventMgr.Instance:AddListener(event_name.zone_bigbadge_update, self.bigbadgeupdate)
    WorldChampionManager.Instance.onUpdateTimes:AddListener(self.specialBadgeUpdate)


    self.headpanel = ZoneHeadPanel.New(self.tipsCon.transform, self)
    -- self.myzoneData.photo ={}
    self.headpanel:OnInitCompleted()

    self.momentspanel = MomentsPanel.New(self.model, self.SubPanelCon, self)
    self.citySetPanel = ZoneCitySetPanel.New(self.model, self)
    self.citymomentspanel = MomentsCityPanel.New(self.model, self.SubPanelCon)
    self.dailytopicpanel = DailyTopicPanel.New(self.model, self.SubPanelCon)
    -- LuaTimer.Add(1000, function()
    --     self:SwitchPanelTab(2)
    -- end)
    self.paneltabgroup = TabGroup.New(self.PanelTabButtonGroup.gameObject, function (tab) self:SwitchPanelTab(tab) end, {notAutoSelect = true})
    if not self.zoneMgr.openself then
        local btn1 = self.PanelTabButtonGroup:GetChild(0)
        local btn2 = self.PanelTabButtonGroup:GetChild(1)
        btn1:Find("Normal/I18NText"):GetComponent(Text).text = TI18N("留言板")
        btn1:Find("Select/I18NText"):GetComponent(Text).text = TI18N("留言板")
        btn2:Find("Normal/I18NText"):GetComponent(Text).text = TI18N("朋友圈")
        btn2:Find("Select/I18NText"):GetComponent(Text).text = TI18N("朋友圈")
    else
        self.PanelTabButtonGroup:GetChild(2).gameObject:SetActive(true)
        self.PanelTabButtonGroup:GetChild(3).gameObject:SetActive(true)
        ZoneManager.Instance:Require11856(0)
        ZoneManager.Instance:Require11873(0)
    end

    self.lockPanelBtn = self.transform:Find("LockPanel"):GetComponent(Button)
    self.lockPanelBtn.gameObject:SetActive(false)
    self.lockPanelBtn.onClick:AddListener(function() self:hidelockpetpanel() end)

    self.lockCancelBtn = self.transform:Find("LockPanel/Main/CancelButton"):GetComponent(Button)
    self.lockCancelBtn.onClick:AddListener(function() self:hidelockpetpanel() end)

    self.lockOkBtn = self.transform:Find("LockPanel/Main/OkButton"):GetComponent(Button)
    self.lockOkBtn.onClick:AddListener(function() self:LockZone() end)


    self.lockKeyText = self.transform:Find("LockPanel/Main/Key_Text"):GetComponent(Text)

    self.transform:Find("LockPanel/Main/I18N_Text"):GetComponent(Text).text = "请输入验证码后发送留言"
    -- self.zoneMgr:Require11820()
end

function ZoneMyWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ZoneMyWindow:OnOpen()
    --BaseUtils.dump(self.openArgs,"self.openArgs")
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.paneltabgroup:ChangeTab(self.openArgs[1])
    else
        self.paneltabgroup:ChangeTab(1)
    end
end

function ZoneMyWindow:hidelockpetpanel()
    -- if self.messagepanel ~= nil then
    --         self.messagepanel.trendInputField:Find("Placeholder"):GetComponent(Text).text = self.inputMsg
    -- end
    self.lockPanelBtn.gameObject:SetActive(false)
end

function ZoneMyWindow:Close()
    self.model:CloseMyMain()
end

function ZoneMyWindow:InitTab()
    if self.zoneMgr.openself then
        local go = self.transform:Find("MainCon/TabButtonGroup").gameObject
        self.tabgroup = TabGroup.New(go, function(tab) self:OnTabChange(tab) end)
        self.transform:Find("MainCon/Info/StarButton"):GetComponent(Button).onClick:AddListener(function() self.ZoneInfoSetPanel.gameObject:SetActive(true) end)
        self.transform:Find("MainCon/Info/CityButton"):GetComponent(Button).onClick:AddListener(function() self:OpenCitySet() end)
        self.transform:Find("MainCon/Info/LastNameButton"):GetComponent(Button).onClick:AddListener(function() self:ShowNameUsed() end)
        -- self.transform:Find("MainCon/Sub1Con/sub1/AddGiftButton"):GetComponent(Button).onClick:AddListener(function() self.giftsetpanel:Show() end)
    else
        self.transform:Find("MainCon/Info/StarButton").gameObject:SetActive(false)
        self.transform:Find("MainCon/Info/CityButton").gameObject:SetActive(false)
        self.transform:Find("MainCon/Info/LastNameButton"):GetComponent(Button).onClick:AddListener(function() self:ShowNameUsed() end)
        self.transform:Find("MainCon/Tabbg").gameObject:SetActive(false)
        self.transform:Find("MainCon/TabButtonGroup").gameObject:SetActive(false)
        self.transform:Find("MainCon/TabSelectButton").gameObject:SetActive(false)
    end

    self.LikeButton.onClick:AddListener(function() self:ChangeSubCon(2) end)
    self.HasGiftButton.onClick:AddListener(function() self:ChangeSubCon(3) end)
    self.AddGiftButton.onClick:AddListener(function() self.giftsetpanel:Show() end)
    self.Sub1Con:Find("sub2/BackButton"):GetComponent(Button).onClick:AddListener(function() self:ShowMoment() end)
    self.Sub1Con:Find("sub3/BackButton"):GetComponent(Button).onClick:AddListener(function() self:ShowMoment() end)
end

function ZoneMyWindow:ChangeSubCon(index)

    for i = 1, 3 do
        self.Sub1Con.gameObject:SetActive(true)
        self.Sub1Con:Find(string.format("sub%s", tostring(i))).gameObject:SetActive(i == index)
        if index == 2 or index == 3 then
            self.CommonTitle.gameObject:SetActive(false)
            self.momentspanel:Hiden()
        end
    end
    if index == 1 then
        self:UpdataTrends()
    elseif index == 2 then
        self:UpdataVisits()
    elseif index == 3 then
        self:UpdataGiftInfo()
    end
end

function ZoneMyWindow:ShowMoment()
    self.Sub1Con.gameObject:SetActive(false)
    self.CommonTitle.gameObject:SetActive(true)
    if self.zoneMgr.openself then
        if self.openArgs == nil then
            self.openArgs = {nil,nil, nil, 1}
        else
            self.openArgs = {self.openArgs[1],self.openArgs[2], self.openArgs[3], 1}
        end
        if self.RightTab == 2 then
            self.messagepanel:Show()
        else
            self.momentspanel:Show(self.openArgs)
        end
    else
        if self.openArgs == nil then
            self.openArgs = {nil,nil, nil, 2}
        else
            self.openArgs = {self.openArgs[1],self.openArgs[2], self.openArgs[3], 2}
        end
        if self.RightTab == 1 then
            self.messagepanel:Show()
            self.Sub1Con.gameObject:SetActive(true)
            self.CommonTitle.gameObject:SetActive(false)
            self.momentspanel:Hiden()
        else
            self.momentspanel:Show(self.openArgs)
        end
    end
    
    -- self.momentspanel:Show(self.openArgs)
    -- self.messagepanel:Show()
    --self:SetPoAndSize(2)
end

function ZoneMyWindow:InitInfo()
    self.CommonMyGiftText.text = tostring(self.myzoneData.prize_num)
    self.CommonLikeText.text = tostring(self.myzoneData.liked)
    self.CommonRecGiftText.text = tostring(self.myzoneData.present_num)
end


function ZoneMyWindow:InitSub2Con()
    self.friendzonePanel = ZoneFriendList.New(self.transform:Find("MainCon/Sub2Con"), self)
end

function ZoneMyWindow:InitSub3Con()
    self.hotzonePanel = ZoneHotList.New(self.transform:Find("MainCon/Sub3Con"), self)
    -- body
end

function ZoneMyWindow:SetInfo()
    -- print("更新信息=============================================")
    self.myzoneData = self.zoneMgr.myzoneData
    self.TitleText.text = self.myzoneData.name
    self.NameText.text = self.myzoneData.name
    self.ClassIcon.sprite = self:GetClassIcon(self.myzoneData.classes)
    if self.zoneMgr.openself then
        self.LevText.text = tostring(RoleManager.Instance.RoleData.lev)
        self.cameraButton.gameObject:SetActive(true)
    else
        self.LevText.text = tostring(self.myzoneData.lev)
        self.cameraButton.gameObject:SetActive(false)
    end

    self.GuildText.text = self.myzoneData.guild ~= "" and self.myzoneData.guild or TI18N("无")
    self.StarText.text = Constellation[self.myzoneData.constellation].name
    self.CuppleText.text = self.myzoneData.lover_name ~= "" and self.myzoneData.lover_name or TI18N("无")
    self.LastNameText.text = self.myzoneData.name_used ~= "" and self.myzoneData.name_used or TI18N("无")
    if self.myzoneData.privacy == 1 then
        self.CityText.text = TI18N("未设置")
    else
        self.CityText.text = self.myzoneData.city ~= "" and string.format("%s%s", self.myzoneData.region, self.myzoneData.city) or TI18N("未设置")
    end
    -- self.MyGiftText.text = tostring(self.myzoneData.prize_num)
    -- self.LikeText.text = tostring(self.myzoneData.liked)
    self.SigInputField:GetComponent(InputField).text = self.myzoneData.signature
    -- self.RecGiftText.text = tostring(self.myzoneData.present_num)
    self:SetHonor()
    self:loadPhoto()
    self:InitInfo()
    if self.messagepanel ~= nil then
        self.messagepanel:InitInfo()
    end
end

function ZoneMyWindow:SetInputField(inputfield)
    local ipf = inputfield:GetComponent(InputField)
    local textcom = inputfield:Find("Text"):GetComponent(Text)
    local placeholder = inputfield:Find("Placeholder"):GetComponent(Text)
    ipf.textComponent = textcom
    ipf.placeholder = placeholder
end


function ZoneMyWindow:GetClassIcon(classes)
    local sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(classes))
    return sprite
end

function ZoneMyWindow:GetHead(classes, sex)
    local name = tostring(classes) .. "_" .. tostring(sex)
    local sprite = self.assetWrapper:GetSprite(AssetConfig.heads, name)
    return sprite
end


function ZoneMyWindow:UpdataTrends()
    if self.messagepanel ~= nil then
        self.messagepanel:UpdataTrends()
    end
end


function ZoneMyWindow:UpdataVisits()
    if self.messagepanel ~= nil then
        self.messagepanel:UpdataVisits()
    end
end

function ZoneMyWindow:UpdataGiftInfo()
    if self.messagepanel ~= nil then
        self.messagepanel:UpdataGiftInfo()
    end
end




function ZoneMyWindow:UpdataGetGift()
    if self.messagepanel ~= nil then
        self.messagepanel:UpdataGetGift()
    end
end

function ZoneMyWindow:UpdateOtherBtn()
    if self.messagepanel ~= nil then
        self.messagepanel:UpdateOtherBtn()
    end
end


function ZoneMyWindow:OnEndEditSig()
    if self.SigInputField:GetComponent(InputField).text ~= self.myzoneData.signature then
        -- FriendManager.Instance:Require11803(self.SigInputField:GetComponent(InputField).text)
        self.zoneMgr:Require11833(TI18N("1992年12月12日"), self.myzoneData.constellation, self.myzoneData.abo, self.SigInputField:GetComponent(InputField).text, self.myzoneData.region, self.myzoneData.sex)
        print("修改了")
    else
        print("没修改")
    end
end


function ZoneMyWindow:InitWebcam()
    if ZoneManager.Instance.webcam == nil then
        ZoneManager.Instance:InitWebcam()
    end
end

function ZoneMyWindow:loadPhoto()
    -- self.headImage.sprite = self:GetHead(self.myzoneData.classes, self.myzoneData.sex)
    self.photoCon:Find("Head1"):GetComponent(Image).sprite = self:GetHead(self.myzoneData.classes, self.myzoneData.sex)
    if self:GetLocalPhoto(self.myzoneData.photo) then
        return
    end
        LuaTimer.Add(50,
            function()
                local zoneManager = ZoneManager.Instance
                if self.zoneMgr.openself then
                        zoneManager:RequirePhotoQueue(zoneManager.roleinfo.id, zoneManager.roleinfo.platform, zoneManager.roleinfo.zone_id, function(photo) self:toPhoto(photo, self.headImage) end, 1)
                else
                        zoneManager:RequirePhotoQueue(zoneManager.targetInfo.id, zoneManager.targetInfo.platform, zoneManager.targetInfo.zone_id, function(photo) self:toPhoto(photo, self.headImage) end, 1)
                end
            end
        )
    -- end
end


function ZoneMyWindow:onCameraButtonClick()
    local versionOk = true

    if Application.platform == RuntimePlatform.IPhonePlayer then
        if CSVersion.Version == "1.1.1" then
            versionOk = false
        end
    end

    if not versionOk then
    	local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("当前版本不支持上传照片，请到<color='#ffff00'>Appstore</color>更新游戏后即可上传啦！")
        data.sureLabel = TI18N("前往")
        data.sureCallback = function()
            local url = "https://itunes.apple.com/us/app/xing-chen-qi-yuan-zhong-qi/id1062524230?l=zh&ls=1&mt=8"
            Application.OpenURL(url)
        end
        data.cancelLabel = TI18N("取消")
        NoticeManager.Instance:ConfirmTips(data)
    else
        if ZoneManager.Instance.webcam == nil then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Sure
            data.content = TI18N("上传照片需使用最新的客户端，可前往<color='#ffff00'>官网或应用宝</color>进行下载，详询官方QQ群：<color='#ffff00'>484362455</color>")
            data.sureLabel = TI18N("确定")
            NoticeManager.Instance:ConfirmTips(data)
        else
            self:ShowCameraTips()
        end
    end
end

function ZoneMyWindow:ShowCameraTips()
    -- if self.zoneMgr.openself then
        self.tipsCon:SetActive(true)
        self.headpanel:Open()
    -- end
end

function ZoneMyWindow:HideCameraTips()
    -- self.tipsCon:SetActive(false)
    self.headpanel:Close()
end

function ZoneMyWindow:TakePhoto()
    self:HideCameraTips()
    local pData = self:GetpData(self.headpanel.clickid)
    if pData ~= nil and pData.auditing == 0 and pData.uploaded + 60 * 30 > BaseUtils.BASE_TIME then
        NoticeManager.Instance:FloatTipsByString(TI18N("你上传的照片还在审核中，半小时内无法上传新的照片"))
    elseif ZoneManager.Instance.roleinfo.lev < 40 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你的等级不足40级，无法上传照片"))
    else
        LoginManager.Instance.webcam_sleep = true
        ZoneManager.Instance.webcam:TakePhoto()
    end
end

function ZoneMyWindow:OpenPhotoGallery()
    self:HideCameraTips()
    local pData = self:GetpData(self.headpanel.clickid)
    if pData ~= nil and pData.uploaded + 60 * 30 > BaseUtils.BASE_TIME then
        NoticeManager.Instance:FloatTipsByString(TI18N("你上传的照片还在审核中，半小时内无法上传新的照片"))
    elseif ZoneManager.Instance.roleinfo.lev < 40 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你的等级不足40级，无法上传照片"))
    else
        LoginManager.Instance.webcam_sleep = true
        ZoneManager.Instance.webcam:OpenPhotoGallery()
    end
end

function ZoneMyWindow:DelectPhoto()
    self:HideCameraTips()
    local pData = self:GetpData(self.headpanel.clickid)
    if pData ~= nil then
        if self.zoneMgr.openself then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("你确定要删除该照片吗？")
            data.sureLabel = TI18N("删除")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                    self:HideCameraTips()
                    local zoneManager = ZoneManager.Instance
                    zoneManager:Require11846(self.headpanel.clickid, zoneManager.roleinfo.id, zoneManager.roleinfo.platform, zoneManager.roleinfo.zone_id)
                end
            NoticeManager.Instance:ConfirmTips(data)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("你当前没有上传过照片，无法进行删除"))
    end
end

function ZoneMyWindow:SetAsDefault()
    self:HideCameraTips()
    local pData = self:GetpData(self.headpanel.clickid)
    if pData ~= nil and pData.auditing == 1 then
        if self.zoneMgr.openself then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("是否设为默认照片")
            data.sureLabel = TI18N("确定")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                    self:HideCameraTips()
                    local zoneManager = ZoneManager.Instance
                    zoneManager:Require11854(self.headpanel.clickid)
                end
            NoticeManager.Instance:ConfirmTips(data)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("照片未审核通过，无法设置"))
    end
end

function ZoneMyWindow:webcamCallBack(photoSavePath, photoSaveName)
    if self.model.tempCallback ~= nil then
        self.model.tempCallback(photoSavePath, photoSaveName)
        self.model.tempCallback = nil
    else
        NoticeManager.Instance.hideConfirmTips = false
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("上传的照片将会进行审核，请不要上传非法照片。上传后半小时内无法再进行上传。确定上传该照片吗？")
        data.sureLabel = TI18N("上传")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            NoticeManager.Instance.hideConfirmTips = false
            LuaTimer.Add(500, function() self:sendPhoto(string.format("%s%s", photoSavePath, photoSaveName)) end)
        end
        data.cancelCallback = function()
            NoticeManager.Instance.hideConfirmTips = false
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function ZoneMyWindow:sendPhoto(fileName)
    local photo = Utils.ReadBytesPath(fileName)

    Log.Debug(photo.Length)
    if photo.Length < 307200 then
        ZoneManager.Instance:Require11834(self.headpanel.clickid ,photo)
        self.model.cachePhoto = photo
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = TI18N("上传失败，你上传的照片过大，请对图片进行处理或更换小于300KB的照片重新上传")
        data.sureLabel = TI18N("确认")
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function ZoneMyWindow:toPhoto(photo)
    if BaseUtils.isnull(self.photoCon) then
        return
    end
    self.photoList = photo
    if self.headpanel ~= nil then
        self.headpanel:OnInitCompleted()
    end
    table.sort( self.photoList, function(a,b) return a.id<b.id end)
    local zoneManager = ZoneManager.Instance
    for i,v in ipairs(photo) do
        local img = self.photoCon:Find(string.format("Head%s", i)):GetComponent(Image)
        local pData = self:GetpData(v.id)
        if self.zoneMgr.openself then
            -- self.model:SaveLocalPhoto(photo, zoneManager.roleinfo.id, zoneManager.roleinfo.platform, zoneManager.roleinfo.zone_id, pData.photo_bin, pData.id)
        else
            -- self.model:SaveLocalPhoto(photo, zoneManager.targetInfo.id, zoneManager.targetInfo.platform, zoneManager.targetInfo.zone_id, pData.photo_bin, pData.id)
        end
        if BaseUtils.isnull(self.headImage) then
            return
        end
        local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)

        local result = tex2d:LoadImage(pData.photo_bin)
        if result then
            -- self.headImage.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0, 0))
            img.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
            -- self.headImage.gameObject:GetComponent(RectTransform).sizeDelta = Vector2.zero
        end
        table.insert(self.tex2dList, tex2d)
    end
    if self.tween == nil then
        self.tween = LuaTimer.Add(0,4000,function()self:ScrollPhoto()end)
    end
    if #photo > 1 then
        self.photoCon:Find(string.format("Head%s", (#photo+1))):GetComponent(Image).sprite =
        self.photoCon:Find("Head1"):GetComponent(Image).sprite
    else
        if #photo > 0 then
            self.photoCon:Find(string.format("Head%s", (#photo+1))):GetComponent(Image).sprite =
            self.photoCon:Find("Head1"):GetComponent(Image).sprite
        else
            self.photoCon:Find("Head1"):GetComponent(Image).sprite = self:GetHead(self.myzoneData.classes, self.myzoneData.sex)
        end
    end
end

--------------------------空间聊天功能-----------------------------


function ZoneMyWindow:AppendInputElement(element)
    if self.messagepanel ~= nil then
        self.messagepanel:AppendInputElement(element)
    end
end



function ZoneMyWindow:ShowNameUsed()
    RoleManager.Instance:Send10017(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id, self.transform:Find("MainCon/Info/LastNameButton").gameObject)
end


function ZoneMyWindow:SetBadge(index, id)
    -- if self.currBadge[index] == nil or self.currBadge[index].badge_id ~= id then
    --     return
    -- else
        -- self.currBadge[index] = id
    -- end
    local img = self.badgeCon:Find(tostring(index)):GetComponent(Image)
    if id ~= 0 and id ~= nil then
        -- print("索引ziyuanid" .. ZoneManager.Instance:ResIdToId(id))
        local resourcesId = DataAchieveShop.data_list[id].source_id
        if resourcesId >= 20001 and resourcesId<= 20008 then
            -- print("最终资源id" .. ZoneManager.Instance.myDataAchieveShop[ZoneManager.Instance:ResIdToId(id)].source_id)
                img.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(resourcesId))
        else
                img.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(resourcesId))
        end
        if resourcesId == 20030 then
            if self.zoneMgr.openself then
                --WorldChampionManager.Instance:Require16430(ZoneManager.Instance.roleinfo.id, ZoneManager.Instance.roleinfo.platform, ZoneManager.Instance.roleinfo.zone_id)
            else
                --WorldChampionManager.Instance:Require16430(ZoneManager.Instance.targetInfo.id, ZoneManager.Instance.targetInfo.platform, ZoneManager.Instance.targetInfo.zone_id)
            end
        end
        img.gameObject:SetActive(true)
    else
        img.gameObject:SetActive(false)
    end
    local has = false
    local has = self.badgeCon:Find("1").gameObject.activeSelf or self.badgeCon:Find("2").gameObject.activeSelf or self.badgeCon:Find("3").gameObject.activeSelf
    self.badgeCon:Find("bg").gameObject:SetActive((id ~= nil and id ~= 0) or has)
end

----------------------------------------------------
function ZoneMyWindow:KingDataRefresh()
    for k,v in pairs(self.currBadge) do
        if v.badge_id == 20030 then
            local numberImg = self.badgeCon:Find(tostring(k)).transform:Find("Number"):GetComponent(Image)
            self.badgeCon:Find(tostring(k)).transform:Find("Number").gameObject:SetActive(false)
            -- numberImg.sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon, "Number" .. WorldChampionManager.Instance.times)
        else
            self.badgeCon:Find(tostring(k)).transform:Find("Number").gameObject:SetActive(false)
        end
    end
end

function ZoneMyWindow:SetFrame(id)
    -- if self.currFrame == id then
    --     return
    -- end
    -- self.currFrame = id
    local Configdata = nil
    for i,v in ipairs(DataFriendZone.data_frame) do
        if v.id == id then
            Configdata = v
        end
    end
    if id == 0 or Configdata == nil then
        self.photoFrame.gameObject:SetActive(false)
    else
        self.photoFrame.sprite = self.assetWrapper:GetSprite(AssetConfig.photo_frame, tostring(id))
        self.photoFrame.gameObject.transform.sizeDelta = Vector2(Configdata.location[2][1]/10, Configdata.location[2][2]/10)
        self.photoFrame.gameObject.transform.anchoredPosition = Vector2(Configdata.location[1][1]/100, Configdata.location[1][2]/100)
        self.photoFrame.gameObject:SetActive(true)
    end
end

function ZoneMyWindow:SetBigBadge(id)
    if self.bigBadgeEffect ~= nil then
        self.bigBadgeEffect:DeleteMe()
        self.bigBadgeEffect = nil
    end

    if id == 0 or id == nil then
        self.bigBadge.gameObject:SetActive(false)
    else
        self.bigBadge.sprite = self.assetWrapper:GetSprite(AssetConfig.bigbadge, tostring(id))
        self.bigBadge:SetNativeSize()
        self.bigBadge.gameObject:SetActive(true)

        local data_bigbadge = nil
        for index, value in ipairs(DataFriendZone.data_bigbadge) do
            if value.id == id then
                data_bigbadge = value
                break
            end
        end
        if data_bigbadge ~= nil and data_bigbadge.effect_id ~= 0 then
            local fun = function(effectView)
                if BaseUtils.is_null(self.gameObject) then
                    GameObject.Destroy(effectView.gameObject)
                    return
                end

                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.bigBadge.transform)
                effectObject.name = "Effect"
                effectObject.transform.localScale = Vector3(tonumber(data_bigbadge.scale_x), tonumber(data_bigbadge.scale_y), tonumber(data_bigbadge.scale_z))
                effectObject.transform.localPosition = Vector3(tonumber(data_bigbadge.position_x), tonumber(data_bigbadge.position_y), tonumber(data_bigbadge.position_z))

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            self.bigBadgeEffect = BaseEffectView.New({effectId = data_bigbadge.effect_id, callback = fun})
        end
    end
end

function ZoneMyWindow:OnStyleUpdate(id)
    if self.StylePanelObj == nil or not self.zoneMgr.openself then
        EventMgr.Instance:RemoveListener(event_name.zone_theme_update, self.styleupdate)
        return
    end

    self.currStyle = self.zoneMgr:GetResId(id)
    -- print("协议更新："..tostring(self.currStyle))
    self.StylePanelObj:Reload(self.currStyle)
end


function ZoneMyWindow:OnFrameUpdate(id)
    if  not self.zoneMgr.openself then
        EventMgr.Instance:RemoveListener(event_name.zone_frame_update, self.frameupdate)
        return
    end

    self.currFrame = self.zoneMgr:GetResId(id)
    -- print("协议更新："..tostring(self.currStyle))
    self:SetFrame(self.currFrame)
end

function ZoneMyWindow:OnClickBadge(index)
    if self.currBadge[index] ~= nil and self.currBadge[index] ~= 0 then
        local data = DataAchieveShop.data_list[self.currBadge[index].badge_id]
        local itemgo = self.badgeCon:Find(tostring(index)).gameObject
        TipsManager.Instance:ShowText({gameObject = itemgo, itemData = {
            TI18N(string.format("<color='#ffff00'>%s</color>", data.name)),
            -- TI18N(string.format("<size=18><color='#ffff00'>%s</color></size>", data.name)),
            TI18N("类型：徽章"),
            TI18N(data.condition),
            }})
    end
end


function ZoneMyWindow:OnBadgeUpdate(list)
    if  not self.zoneMgr.openself then
        EventMgr.Instance:RemoveListener(event_name.zone_badge_update, self.badgeupdate)
        return
    end
    BaseUtils.dump(list, "徽章更新")
    self.currBadge = list or {}
    table.sort(self.currBadge, function(a,b) return a.badge_id<b.badge_id end)
    for i,v in ipairs(self.currBadge) do
        self:SetBadge(i, v.badge_id)
    end
end

function ZoneMyWindow:OnClickBigBadge()
    local data = nil
    for key, value in pairs(DataAchieveShop.data_list) do
        if value.source_id == self.currBigBadge then
            data = value
            break
        end
    end

    local itemgo = self.bigBadge.gameObject
    TipsManager.Instance:ShowText({gameObject = itemgo, itemData = {
        TI18N(string.format("<color='#ffff00'>%s</color>", data.name)),
        TI18N("类型：荣耀"),
        TI18N(data.condition),
        }})
end

function ZoneMyWindow:OnBigBadgeUpdate(id)
    if  not self.zoneMgr.openself then
        EventMgr.Instance:RemoveListener(event_name.zone_bigbadge_update, self.bigbadgeupdate)
        return
    end

    self.currBigBadge = self.zoneMgr:GetResId(id)
    -- print("协议更新："..tostring(self.currBigBadge))
    self:SetBigBadge(self.currBigBadge)
end

function ZoneMyWindow:SetHonor()

    local honor_name = TI18N("无")
    local honor_data = DataHonor.data_get_honor_list[self.myzoneData.honor_id]
    if  honor_data == nil then
        self.ChenghaoText.text = honor_name
        return
    end
    if honor_data.type == 3 then
        -- honor_name = string.format("%s%s%s", GuildManager.Instance.model.my_guild_data.Name, TI18N("的"), honor_data.name)
        honor_name = string.format("%s%s", self.myzoneData.guild, honor_data.name)
    elseif honor_data.type == 7 then
        honor_name = string.format("%s%s", self.myzoneData.teacher_name, honor_data.name)
    elseif honor_data.type == 6 then
        honor_name = string.format(TI18N("%s的%s"), self.myzoneData.lover_name, honor_data.name)
    elseif honor_data.type == 10 then
        honor_name = self.myzoneData.sworn_name
    else
        honor_name = honor_data.name
    end
    if DataHonor.data_get_pre_honor_list[self.myzoneData.pre_honor_id] ~= nil then
        honor_name =DataHonor.data_get_pre_honor_list[self.myzoneData.pre_honor_id].pre_name.. "·" .. honor_name
    end
    self.ChenghaoText.text = honor_name
end

function ZoneMyWindow:GetpData(index, sort)
    local pData = nil
    for k,v in pairs(self.photoList) do
        if v.id == index then
            pData = v
        end
    end
    if sort and pData == nil and index < 3 then
        pData = self:GetpData(index+1, sort)
    end
    return pData
end

function ZoneMyWindow:ScrollPhoto()
    local position = {
        [1] = 234,
        [2] = 78,
        [3] = -78,
        [4] = -234,
    }
    if #self.photoList < 2 then
        self.photoCon.anchoredPosition = Vector2(position[1], 0)
        return
    end
    if self.currPhotopage == nil then
        self.currPhotopage = 1
        self.photoCon.anchoredPosition = Vector2(position[1], 0)
        Tween.Instance:MoveLocalX(self.photoCon.gameObject, position[self.currPhotopage+1], 2, function() end, LeanTweenType.linear)
    elseif self.currPhotopage > #self.photoList then
        self.photoCon.anchoredPosition = Vector2(position[1], 0)
        self.currPhotopage = 1
        Tween.Instance:MoveLocalX(self.photoCon.gameObject, position[self.currPhotopage+1], 2, function() end, LeanTweenType.linear)
    else
        Tween.Instance:MoveLocalX(self.photoCon.gameObject, position[self.currPhotopage+1], 2, function() end, LeanTweenType.linear)
    end
    self.currPhotopage = self.currPhotopage + 1
end

function ZoneMyWindow:GetLocalPhoto(photo)
    local zoneManager = ZoneManager.Instance
    local photoList = {}
    --BaseUtils.dump(self.myzoneData.photo, "角色信息？？")
    for i,v in ipairs(self.myzoneData.photo) do
        local photo = self.model:LoadLocalPhoto(zoneManager.targetInfo.id, zoneManager.targetInfo.platform, zoneManager.targetInfo.zone_id, v.id, v.uploaded)
        -- print("目标id：  "..zoneManager.targetInfo.id)
        if BaseUtils.is_null(photo) then
            return false
        else
            -- print("渠道")
            photoList[i] = v
            photoList[i].photo_bin = photo
        end
    end
    self:toPhoto(photoList, self.headImage)
    -- print("取到了")
    return true
end

--左边切换面板
function ZoneMyWindow:SwitchPanelTab(index)
    print("切换"..index)
    self.RightTab = index
    self.looksBtn.gameObject:SetActive(self.zoneMgr.openself)
    if self.zoneMgr.openself then     --如果是打开自己空间
        for i,v in ipairs(self.topbtn) do
            v:SetActive((index == 2 or index == 1) and self.zoneMgr.openself)
        end
        if index == 2 then
            self.CommonTitle.gameObject:SetActive(false)
            self.messagepanel:Show()
            self.momentspanel:Hiden()
            self.citymomentspanel:Hiden()
            self.dailytopicpanel:Hiden()
        elseif index == 3 then
            self.InfoCon.gameObject:SetActive(true)
            self.CommonTitle.gameObject:SetActive(false)
            self.messagepanel:Hiden()                  --留言
            self.momentspanel:Hiden()                  --朋友圈
            self.citymomentspanel:Show()               --同城
            self.dailytopicpanel:Hiden()
        elseif index == 1 then
            self.InfoCon.gameObject:SetActive(true)
            self.CommonTitle.gameObject:SetActive(true)
            self.messagepanel:Hiden()
            self.citymomentspanel:Hiden()
            self.dailytopicpanel:Hiden()
            if self.openArgs == nil then
                self.openArgs = {nil,nil, nil, 1}
            else
                self.openArgs = {self.openArgs[1],self.openArgs[2], self.openArgs[3], 1}
            end
            self.momentspanel:Show(self.openArgs)
            --self:SetPoAndSize(1)
            self.tabgroup:ChangeTab(1)
            --self.openArgs = nil
        elseif index == 4 then
            self.InfoCon.gameObject:SetActive(true)
            self.CommonTitle.gameObject:SetActive(false)
            self.messagepanel:Hiden()
            self.citymomentspanel:Hiden()
            self.momentspanel:Hiden()
            self.dailytopicpanel:Show()
        end
    else
        for i,v in ipairs(self.topbtn) do
            v:SetActive(index == 1 and self.zoneMgr.openself)
        end
        if index == 1 then
            self.messagepanel:Show()
            self.Sub1Con.gameObject:SetActive(true)
            self.CommonTitle.gameObject:SetActive(false)
            self.momentspanel:Hiden()
        elseif index == 2 then
            self.InfoCon.gameObject:SetActive(true)
            self.CommonTitle.gameObject:SetActive(true)
            self.messagepanel:Hiden()
            if self.openArgs == nil then
                self.openArgs = {nil,nil, nil, 2}
            else
                self.openArgs = {self.openArgs[1],self.openArgs[2], self.openArgs[3], 2}
            end
            self.momentspanel:Show(self.openArgs)
            --self:SetPoAndSize(2)
            self.openArgs = nil
        end
    end
end

function ZoneMyWindow:SetPoAndSize(index)
    LuaTimer.Add(200, function()
        if self.momentspanel ~= nil then
            self.momentspanel:SetPoAndSize(index)
        end
    end)
end

function ZoneMyWindow:OpenCitySet()
    if self.citySetPanel ~= nil then
        self.citySetPanel:Show()
    end
end

function ZoneMyWindow:OpenLockPanel()
    self.lockPanelBtn.gameObject:SetActive(true)
    local input_field = self.transform:Find("LockPanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
    input_field.textComponent = self.transform:FindChild("LockPanel/Main/InputCon/InputField/Text"):GetComponent(Text)
    input_field.text = TI18N("请输入上方的验证码")

    -- self.lockKey = "1234"
    self.lockKey = tostring(math.random(100000, 999999))
    self.transform:FindChild("LockPanel/Main/Key_Text"):GetComponent(Text).text = self.lockKey
end

function ZoneMyWindow:LockZone()
    local input_field = self.transform:Find("LockPanel/Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
    local str = input_field.text
    if str == self.lockKey then
        self:hidelockpetpanel()
        if self.replyId == 1 then
                ZoneManager.Instance:Require11849(self.mainId, self.inputMsg, self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
                if self.messagepanel ~= nil then
                        self.messagepanel.trendInputField:Find("Placeholder"):GetComponent(Text).text = TI18N("输入内容")
                        self.messagepanel.Sub1Con:Find("sub1/InputBar/SendButton/Text"):GetComponent(Text).text = TI18N("发 送")
                        self.messagepanel.inputfield.text = ""
                end
        elseif self.replyId == 2 then
                ZoneManager.Instance:Require11823(0,self.inputMsg,self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
                if self.messagepanel ~= nil then
                        self.messagepanel.inputfield.text = ""
                end
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("验证码有误，请重新输入{face_1,3}"))
    end

end
function ZoneMyWindow:CheckWord()
    self:CutWord()
    self.pass = nil
    for k,v in pairs(DataFriendZone.data_word) do
        self.pass = string.find(self.myMsg,v.word)
        if self.pass ~= nil then
            break
        end
    end
    if self.pass ~= nil then
        self:OpenLockPanel()
    else
        if self.replyId == 1 then
                ZoneManager.Instance:Require11849(self.mainId, self.inputMsg, self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
                if self.messagepanel ~= nil then
                        self.messagepanel.trendInputField:Find("Placeholder"):GetComponent(Text).text = TI18N("输入内容")
                        self.messagepanel.Sub1Con:Find("sub1/InputBar/SendButton/Text"):GetComponent(Text).text = TI18N("发 送")
                        self.messagepanel.inputfield.text = ""
                end
        elseif self.replyId == 2 then
                ZoneManager.Instance:Require11823(0,self.inputMsg,self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
                if self.messagepanel ~= nil then
                        self.messagepanel.inputfield.text = ""
                end
        end
    end
end
function ZoneMyWindow:CutWord()
    self.myMsg = ""
    local lenInByte = #self.inputMsg
    local str = self.inputMsg

    --根据编码方式判断中文汉字
    for i=1,lenInByte do
        local curByte = string.byte(str,i)
        local byteCount = 1
        if curByte >0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            --去除中文汉字的中文字符和标识
            if curByte>=228 and curByte<=233 then
                local c1 = string.byte(str,i+1)
                local c2 = string.byte(str,i+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if curByte == 228 then a1 = 184
                    elseif curByte == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        byteCount = 3
                    else
                        byteCount = 1
                    end
                else
                    byteCount = 1
                end
            else
                byteCount = 1
            end

        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end

        local char = string.sub(str,i,i+byteCount-1)
        i = i + byteCount -1

        if byteCount ~= 1 then
            self.myMsg = self.myMsg .. char
        end
    end
end

function ZoneMyWindow:OnTabChange(index)
    if index == 4 then
        NoticeManager.Instance:FloatTipsByString(TI18N("敬请期待"))
    elseif index == 2 then
        self.InfoCon.gameObject:SetActive(false)
        self.transform:Find("MainCon/Sub1Con").gameObject:SetActive(false)
        self.transform:Find("MainCon/Sub2Con").gameObject:SetActive(true)
        self.transform:Find("MainCon/Sub3Con").gameObject:SetActive(false)
        self.momentspanel:Hiden()
        self.CommonTitle.gameObject:SetActive(false)
    elseif index == 1 then
        if self.RightTab ~= nil then
            self.InfoCon.gameObject:SetActive(true)
            self.transform:Find("MainCon/Sub2Con").gameObject:SetActive(false)
            self.transform:Find("MainCon/Sub3Con").gameObject:SetActive(false)
            if self.RightTab == 1 then
                if self.openArgs == nil then
                    self.openArgs = {nil,nil, nil, 1}
                else
                    self.openArgs = {self.openArgs[1],self.openArgs[2], self.openArgs[3], 1}
                end
                self.momentspanel:Show(self.openArgs)
                self.CommonTitle.gameObject:SetActive(true)
                self.transform:Find("MainCon/Sub1Con").gameObject:SetActive(false)
                --self.transform:Find("MainCon/SubPanelCon").gameObject:SetActive(true)
            elseif self.RightTab == 2 then
                self.transform:Find("MainCon/Sub1Con").gameObject:SetActive(true)
                --self.transform:Find("MainCon/SubPanelCon").gameObject:SetActive(false)
                self.momentspanel:Hiden()
                self.CommonTitle.gameObject:SetActive(false)
            end
        end

    elseif index == 3 then
        self.transform:Find("MainCon/Info").gameObject:SetActive(false)
        self.transform:Find("MainCon/Sub1Con").gameObject:SetActive(false)
        self.transform:Find("MainCon/Sub2Con").gameObject:SetActive(false)
        self.transform:Find("MainCon/Sub3Con").gameObject:SetActive(true)
        --self.transform:Find("MainCon/SubPanelCon").gameObject:SetActive(false)
        self.momentspanel:Hiden()
        self.CommonTitle.gameObject:SetActive(false)
    end
    local pos = Vector2(self.TabSelectPosX[index], 218)
    self.TabSelectButton:Find("Text"):GetComponent(Text).text = self.TabName[index]
    Tween.Instance:MoveX(self.TabSelectButton, self.TabSelectPosX[index], 0.6, function() end, LeanTweenType.easeOutQuint)
end