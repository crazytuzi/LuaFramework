GiveMeYourHand = GiveMeYourHand or BaseClass(BasePanel)

function GiveMeYourHand:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GiveMeYourHand"

    self.titleString = TI18N("五月恋爱季")
    self.titleString2 = TI18N("执子之手，与子偕老")
    self.dateFormatString = TI18N("%s年%s月%s日")
    -- self.timeFormatString = TI18N("活动时间:<color=#C7F9FF>%s-%s</color>")
    -- self.descFormatString = TI18N("活动内容:<color=#C7F9FF>%s</color>")
    self.btnString = TI18N("我要结缘")

    self.timeFormatString = TI18N("活动时间:<color=#C7F9FF>%s-%s</color>")
    self.descExtString = TI18N("<color=#7EB9F7>活动内容:</color>")
    self.descFormatString = TI18N("%s")

    self.resList = {
        {file = AssetConfig.give_me_your_hand, type = AssetType.Main}
        , {file = AssetConfig.guidesprite, type = AssetType.Main}
        , {file = AssetConfig.midAutumn_textures, type = AssetType.Dep}
        ,{file = AssetConfig.may_textures, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GiveMeYourHand:__delete()
    self.icon = nil
    self.OnHideEvent:Fire()
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    if self.descMsgExtText ~= nil then
        self.descMsgExtText:DeleteMe()
        self.descMsgExtText = nil
    end
    self:AssetClearAll()
end

function GiveMeYourHand:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.give_me_your_hand))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.timeText = t:Find("Info/Time"):GetComponent(Text)
    self.gotoMarryBtn = t:Find("Button"):GetComponent(Button)

    self.titleText = t:Find("Bg/Title/Text"):GetComponent(Text)
    self.iconLoader = SingleIconLoader.New(t:Find("Bg/Title/Icon").gameObject)
    t:Find("Title/Text"):GetComponent(Text).text = self.titleString2
    t:Find("Button/Text"):GetComponent(Text).text = self.btnString
    t:Find("Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")

    if self.bg ~= nil then
        UIUtils.AddBigbg(t:Find("Bg/Bg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    end

    self.gotoMarryBtn.onClick:AddListener(function()
        if self.target ~= nil then
            QuestManager.Instance.model:FindNpc(self.target)
        end
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
    end)
    self.descMsgExtText = MsgItemExt.New(t:Find("Scroll/Desc"):GetComponent(Text), 400, 17, 20)
end

function GiveMeYourHand:OnInitCompleted()
    self.OnOpenEvent:Fire()
    if self.afterSprintFunc ~= nil then
        self.afterSprintFunc(self.iconLoader)
    else
    end
end

function GiveMeYourHand:OnOpen()
    self:InitUI()

    self:RemoveListeners()
end

function GiveMeYourHand:OnHide()
    self:RemoveListeners()
end

function GiveMeYourHand:RemoveListeners()
end

function GiveMeYourHand:InitUI()
    local campaignData = DataCampaign.data_list[self.campId]

    self.descMsgExtText:SetData(string.format(self.descFormatString, campaignData.cond_desc), true)

    self.timeText.text = string.format(self.timeFormatString,
        string.format(self.dateFormatString, tostring(campaignData.cli_start_time[1][1]),tostring(campaignData.cli_start_time[1][2]),tostring(campaignData.cli_start_time[1][3])),
        string.format(self.dateFormatString, tostring(campaignData.cli_end_time[1][1]),tostring(campaignData.cli_end_time[1][2]),tostring(campaignData.cli_end_time[1][3])))
    self.titleText.text = campaignData.timestr
end


