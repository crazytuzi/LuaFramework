

PathFindingPanel = PathFindingPanel or BaseClass(BasePanel)

function PathFindingPanel:__init(model, parent, bg)
    self.model = model
    self.parent = parent
    self.name = "PathFindingPanel"

    self.target = "32023_1"

    self.timeString = TI18N("活动时间:%s-%s")
    self.dateFormatString = TI18N("%s年%s月%s日")

    self.resList = {
        {file = AssetConfig.path_finding_panel, type = AssetType.Main}
        ,{file = AssetConfig.path_finding_bg, type = AssetType.Main}

        , {file = AssetConfig.may_textures, type = AssetType.Dep}
        , {file = AssetConfig.guidesprite, type = AssetType.Main}
        , {file = AssetConfig.backend_textures, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PathFindingPanel:__delete()
    self.OnHideEvent:Fire()

    if self.containerExt ~= nil then
        self.containerExt:DeleteMe()
        self.containerExt = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PathFindingPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.path_finding_panel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.path_finding_bg)))

    self.timeText = t:Find("Bg/TimeBg/TimeText"):GetComponent(Text)
    self.timeText.transform.anchoredPosition = Vector2(-64.5, 0)
    self.timeText.transform.sizeDelta = Vector2(329,30)

    self.timebg = t:Find("Bg/TimeBg")
    self.timebg.transform.anchoredPosition = Vector2(-1.1, 76)
    self.timebg.transform.sizeDelta = Vector2(568, 31.3)

    t:Find("Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")

    self.containerExt = MsgItemExt.New(t:Find("Scroll/Container"):GetComponent(Text), 420, 18, 21)

    self.findPathBtn = t:Find("Button"):GetComponent(Button)
    self.findPathBtn.onClick:AddListener(function() self:OnFind() end)
end

function PathFindingPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


function PathFindingPanel:OnOpen()
    self:RemoveListeners()
    self:InitUI()
end

function PathFindingPanel:InitUI(openArgs)
    local campData = DataCampaign.data_list[self.campId]

    self.containerExt:SetData(campData.cond_desc)

    local startTime = campData.cli_start_time[1]
    local endTime = campData.cli_end_time[1]

    self.timeText.text = string.format(self.timeString,
    string.format(self.dateFormatString, tostring(startTime[1]),tostring(startTime[2]),tostring(startTime[3])),
    string.format(self.dateFormatString, tostring(endTime[1]),tostring(endTime[2]),tostring(endTime[3])))

    self.transform:Find("Bg/TimeBg/TitleText"):GetComponent(Text).text = campData.timestr
    self.transform:Find("Bg/TimeBg/TitleText").gameObject:SetActive(false)
    -- self.transform:Find("Bg/TimeBg/Text").anchoredPosition = Vector2(8, 0)
end

function PathFindingPanel:OnHide()
    self:RemoveListeners()
end

function PathFindingPanel:RemoveListeners()
end

function PathFindingPanel:OnFind()
    if self.target ~= nil then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
        QuestManager.Instance.model:FindNpc(self.target)
        -- QuestManager.Instance.model:DoPlant()
    end
end

