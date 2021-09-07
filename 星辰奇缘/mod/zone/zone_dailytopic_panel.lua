-- @author #pwj
-- @date 2018年5月30日,星期三

DailyTopicPanel = DailyTopicPanel or BaseClass(BasePanel)

function DailyTopicPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "DailyTopicPanel"

    self.resList = {
        {file = AssetConfig.daily_topic_panel, type = AssetType.Main}
        ,{file = "prefabs/effect/20166.unity3d", type = AssetType.Main}
        ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.refresh_comments = function(campId)
        if campId == self.model.currCampId then
            self:OnMomentsRefresh()
        end
    end
    self.panelId = 1
    self.MainTopicList = { }
end

function DailyTopicPanel:__delete()
    self.OnHideEvent:Fire()

    if self.photopreview ~= nil then
        self.photopreview:DeleteMe()
        self.photopreview = nil
    end

    if self.momentList ~= nil then
        self.momentList:DeleteMe()
    end
    if self.MainTopicList ~= nil then
        for i,v in pairs(self.MainTopicList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.MainTopicList = nil
    end

    if self.MainTopicLayout ~= nil then
        self.MainTopicLayout:DeleteMe()
        self.MainTopicLayout = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DailyTopicPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.daily_topic_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.backButton = self.transform:Find("backButton"):GetComponent(Button)
    self.backButton.onClick:AddListener(function()
        self:OnBackBtn()
    end)
    self.backButton.gameObject:SetActive(false)

    self.MaskCon = self.transform:Find("Mask")
    self.Container = self.transform:Find("Mask/Container")
    self.MainTopicItem = self.transform:Find("Mask/Container/Item").gameObject
    self.MainTopicItem.gameObject:SetActive(false)

    self.NoMsg = self.transform:Find("Mask/Container/Nomsg")
    self.NoMsgText = self.NoMsg:Find("Text"):GetComponent(Text)
    self.NoMsgText.text = TI18N("暂未开启敬请期待")
    self.NoMsg.gameObject:SetActive(false)

    self.DetailTopicPanel = self.transform:Find("Mask/Detailtopic")
    self.TopLoading = self.transform:Find("Mask/TopLoading").gameObject
    self.BotLoading = self.transform:Find("Mask/BotLoading").gameObject
    self.TopText = self.transform:Find("Mask/TopLoading/I18NText"):GetComponent(Text)
    self.BotText = self.transform:Find("Mask/BotLoading/I18NText"):GetComponent(Text)
    local go = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20166.unity3d"))
    go.transform:SetParent(self.TopLoading.transform:Find("Image"))
    go.transform.localPosition = Vector3(0,0,-1000)
    go.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(go.transform, "UI")
    local go2 = GameObject.Instantiate(go)
    go2.transform:SetParent(self.BotLoading.transform:Find("Image"))
    go2.transform.localPosition = Vector3(0,0,-1000)
    go2.transform.localScale = Vector3.one

    self.Title2 = self.transform:Find("Title2"):GetComponent(Image)
    self.Title2Text = self.transform:Find("Title2/nameText"):GetComponent(Text)
    self.Title2.gameObject:SetActive(false)

    self.scrollRect = self.transform:Find("Mask"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(val)
        self:OnScrollBoundary(val)
    end)
    self.momentList = MomentsListPanel.New(self.DetailTopicPanel.gameObject, self, 3)

    self.MainTopicLayout = LuaBoxLayout.New(self.Container.gameObject,{axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})

    self.mainTopicData = DataFriendWish.data_get_camp_theme
    table.sort(self.mainTopicData, function(a,b) return a.camp_id > b.camp_id end)

    self.tempTopicData = {}
    local NowTime = BaseUtils.BASE_TIME
    for i,v in pairs(self.mainTopicData) do
        if CampaignManager.Instance.campaignTab[v.camp_id] ~= nil then
            table.insert(self.tempTopicData,v)
        else
            local startTime = DataCampaign.data_list[v.camp_id].cli_start_time[1]
            local endTime = DataCampaign.data_list[v.camp_id].cli_end_time[1]
            local startTimeStamp = os.time({year = startTime[1], month = startTime[2], day = startTime[3], hour = startTime[4], min = startTime[5], sec = startTime[6]})
            local endTimeStamp = os.time({year = endTime[1], month = endTime[2], day = endTime[3], hour = endTime[4], min = endTime[5], sec = endTime[6]})
            if (endTimeStamp <= NowTime and startTimeStamp <= NowTime) or (endTimeStamp > NowTime and startTimeStamp <= NowTime) then
                table.insert(self.tempTopicData,v)
            end
        end
    end
    if self.tempTopicData ~= nil and next(self.tempTopicData) ~= nil then
        for i,v in pairs(self.tempTopicData) do
            if self.MainTopicList[i] == nil then
                local Item = ZoneDailyTopicItem.New(self, GameObject.Instantiate(self.MainTopicItem), v)
                Item:update_my_self(v, #(self.tempTopicData)+1-i)
                table.insert(self.MainTopicList, Item)
            end
            self.MainTopicLayout:AddCell(self.MainTopicList[i].gameObject)
        end
    else
        self.NoMsg.gameObject:SetActive(true)
    end
end

function DailyTopicPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DailyTopicPanel:OnOpen()
    self:RemoveListeners()
    ZoneManager.Instance.OnAnniMomentsUpdate:AddListener(self.refresh_comments)
    self:InitTab()
end

function DailyTopicPanel:OnHide()
    self:RemoveListeners()
end

function DailyTopicPanel:RemoveListeners()
    ZoneManager.Instance.OnAnniMomentsUpdate:RemoveListener(self.refresh_comments)
end

--初始化面板的显示
function DailyTopicPanel:InitTab(i)
    if self.panelId == 1 then
        self.scrollRect.content = self.Container
        self.momentList:Hide()
        self.Container.gameObject:SetActive(true)

        self.Title2.gameObject:SetActive(false)
        self.backButton.gameObject:SetActive(false)
    elseif self.panelId == 2 then
        self.scrollRect.content = self.DetailTopicPanel
        self.momentList:Show()
        self.Container.gameObject:SetActive(false)
        if i ~= nil then
            local temp = #(self.tempTopicData)+1-i
            self.Title2Text.text = string.format("第%s期  #%s#  精彩回顾", i, self.tempTopicData[temp].theme)
        end
        self.Title2.gameObject:SetActive(true)
        self.backButton.gameObject:SetActive(true)
    end
end

function DailyTopicPanel:OnScrollBoundary(value)
    if self.panelId == 1 then return end
    if self.isWatchnew then
        return
    end
    local Top = (value.y-1)*(self.scrollRect.content.sizeDelta.y - 382.83) + 50
    local Bot = Top - 382.83 - 50
    self.momentList:OnScroll(Top, Bot)
    local space = 0
    if value.y > 1 then
        space = (value.y-1)*math.max(382.83, self.scrollRect.content.sizeDelta.y - 382.83)
    elseif value.y < 0 then
        space = value.y*math.max(382.83, self.scrollRect.content.sizeDelta.y - 382.83) * -1
    end
    if space > 5 and self.excuRefresh == nil then
        if value.y > 1 then
            if self.checking then
                self.TopLoading:SetActive(true)
            else
                self.checking = true
                self.checkTime = Time.time
                self.TopText.text = TI18N("保持下拉将会刷新")
                self.TopLoading:SetActive(true)
                if self.checkTimer == nil then
                    self.checkTimer = LuaTimer.Add(300, function()
                        if self.checking == true and self.TopText ~= nil then
                            self.TopText.text = TI18N("松开手指刷新")
                            self.checking = false
                            self.excuRefresh = 1
                            self.checkTimer = nil
                        end
                    end)
                end
            end
        elseif value.y < 0 then
            if self.checking then
                self.BotLoading:SetActive(true)
            else
                self.checking = true
                self.checkTime = Time.time
                self.BotText.text = TI18N("保持上拉将会刷新")
                self.BotLoading:SetActive(true)
                if self.checkTimer == nil then
                    self.checkTimer = LuaTimer.Add(300, function()
                        if self.checking == true and self.TopText ~= nil then
                            self.BotText.text = TI18N("松开手指刷新")
                            self.checking = false
                            self.excuRefresh = 2
                            self.checkTimer = nil
                        end
                    end)
                end
            end
        end
    elseif space <= 5 then
        if self.checkTimer ~= nil then
            LuaTimer.Delete(self.checkTimer)
            self.checkTimer = nil
        end
        if self.excuRefresh ~= nil then
            ZoneManager.Instance:Require11893(self.model.currCampId, self.excuRefresh)
            self.excuRefresh = nil
        end
        self.checking = false
        self.TopLoading:SetActive(false)
        self.BotLoading:SetActive(false)
    end
end

function DailyTopicPanel:OnBackBtn()
    self.panelId = 1
    self:InitTab()
end

--11893刷新数据
function DailyTopicPanel:OnMomentsRefresh()
    --刷新数据
    if self.momentList ~= nil then
        self.scrollRect.inertia = false
        self.momentList:RefreshData(ZoneManager.Instance.TopicmomentsData[self.model.currCampId], self.isshow)
        self.scrollRect.inertia = true
    end
    self.TopLoading:SetActive(false)
    self.BotLoading:SetActive(false)
end

function DailyTopicPanel:ShowDetailOption(data, position)
    self.detialOptionData = data
    -- ZoneManager.Instance:OpenOtherZone(self.detialOptionData.role_id, self.detialOptionData.platform, self.detialOptionData.zone_id, {2})
end

function DailyTopicPanel:OpenPhotoPreview(data)
    if self.photopreview == nil then
        self.photopreview = MomentsPhotoPreviewPanel.New(self.model, self)
    end
    self.photopreview:Show(data)
end
