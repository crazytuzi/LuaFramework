-- @author hzf
-- @date 2016年7月29日,星期五

MomentsPanel = MomentsPanel or BaseClass(BasePanel)

function MomentsPanel:__init(model, parent, main)
    self.model = model
    self.parent = parent
    self.main = main
    self.name = "MomentsPanel"

    self.resList = {
        {file = AssetConfig.moment_panel, type = AssetType.Main}
        ,{file = "prefabs/effect/20166.unity3d", type = AssetType.Main}
        ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}
    }
    self.detialOptionData = nil
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.checkTime = 0
    self.checking = false
    self.excuRefresh = nil
    self.refresh_comments = function()
        self:OnMomentsRefresh()
    end
    self.refresh_newmention = function()
        self:OnNewMentions()
    end
    self.first = true
    self.isshow = false
    self.currpanel = 1
    self.lastReqTime = 0
    self.previewID = 0
    self.isWatchnew = false
    self.isGuild = false
    self.topShow = 0
end

function MomentsPanel:__delete()
    ZoneManager.Instance.OnNewmentions:RemoveListener(self.refresh_newmention)
    ZoneManager.Instance.OnMomentsUpdate:RemoveListener(self.refresh_comments)
    self.topShow = 0
    if self.timer_set ~= nil then
        LuaTimer.Delete(self.timer_set)
        self.timer_set = nil
    end

    if self.momentList ~= nil then
        self.momentList:DeleteMe()
    end
    if self.photopreview ~= nil then
        self.photopreview:DeleteMe()
    end
    if self.selfmomentList ~= nil then
        self.selfmomentList:DeleteMe()
    end
    if self.sendpanel ~= nil then
        self.sendpanel:DeleteMe()
    end
    if self.commentpanel ~= nil then
        self.commentpanel:DeleteMe()
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MomentsPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.moment_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)


    self.bg = self.transform:Find("Bg")
    self.switchButton = self.transform:Find("switchButton"):GetComponent(Button)
    self.switchButtonTxt = self.transform:Find("switchButton/Text"):GetComponent(Text)
    self.nameText = self.transform:Find("nameText"):GetComponent(Text)
    self.statusButton = self.transform:Find("statusButton"):GetComponent(Button)
    self.redPoint = self.statusButton.transform:Find("Red").gameObject
    self.sendButtonImage = self.transform:Find("sendButton"):GetComponent(Image)
    self.sendButton = self.transform:Find("sendButton"):GetComponent(Button)
    self.backButton = self.transform:Find("backButton"):GetComponent(Button)
    self.statusButton.onClick:AddListener(function()
        self:WatchNewMoment()
    end)
    self.backButton.onClick:AddListener(function()
        if ZoneManager.Instance.openself then
            self:WatchNewMoment(true)
        else
            ZoneManager.Instance:OpenSelfZone()
        end
    end)
    if ZoneManager.Instance.openself then
        self.backButton.gameObject:SetActive(false)
        self.nameText.gameObject:SetActive(false)
    else
        self.nameText.gameObject:SetActive(true)
        self.backButton.gameObject:SetActive(true)
        self.nameText.text = string.format(TI18N("%s <color='#c7f9ff'>的动态</color>"), ZoneManager.Instance.myzoneData.name)
        self.switchButton.gameObject:SetActive(false)
        self.statusButton.gameObject:SetActive(false)
        self.sendButton.gameObject:SetActive(true)
    end
    self.MaskCon = self.transform:Find("Mask")
    self.Container = self.transform:Find("Mask/Container")
    self.SelfContainer = self.transform:Find("Mask/SelfContainer")
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

    self.detialOption = self.transform:Find("detialOption")
    self.detialOption:Find("Panel"):GetComponent(Button).onClick:AddListener(function()self.detialOption.gameObject:SetActive(false) end)
    self.likeOpt = self.detialOption:Find("LikeButton"):GetComponent(Button)
    self.likeOpt.onClick:AddListener(function() self:OnLikeOpt() end)
    self.commentsOpt = self.detialOption:Find("CommentButton"):GetComponent(Button)
    self.commentsOpt.onClick:AddListener(function() self:OnCommentsOpt({data = self.detialOptionData, type = 1, name = nil}) end)
    self.hideOpt = self.detialOption:Find("HideButton"):GetComponent(Button)
    self.hideOpt.onClick:AddListener(function() self:OnHideOpt() end)
    self.reportOpt = self.detialOption:Find("ReportButton"):GetComponent(Button)
    self.reportOpt.onClick:AddListener(function() self:OnReportOpt() end)

    self.scrollRect = self.transform:Find("Mask"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(val)
        self:OnScrollBoundary(val)
    end)
    self.momentList = MomentsListPanel.New(self.Container.gameObject, self, 1)

    local PhaseNum = 0
    for i,v in pairs(DataFriendWish.data_get_camp_theme) do
        if BaseUtils.CheckCampaignTime(v.camp_id) == true then
            PhaseNum = v.camp_id
            break
        end
    end
    self.sendpanel = MomentsSendPanel.New(self.model, self.gameObject, PhaseNum)

    --self.sendpanel = MomentsSendPanel.New(self.model, self.gameObject, 0)

    self.commentpanel = MomentsCommentPanel.New(self.model, self.gameObject)
    self.selfmomentList = MomentsSelfListPanel.New(self.SelfContainer.gameObject, self)
    -- self.selfmomentList = MomentsListPanel.New(self.Container.gameObject)
    if ZoneManager.Instance.openself then
        self.momentList:RefreshData(ZoneManager.Instance.momentsList)
        self.selfmomentList:RefreshData(ZoneManager.Instance.personmomentsData)
    else
        self.selfmomentList:RefreshData(ZoneManager.Instance.othermomentsData)
    end
    self.sendButton.onClick:AddListener(function() self:OnSendBtn() end)
    ZoneManager.Instance.OnMomentsUpdate:AddListener(self.refresh_comments)
    ZoneManager.Instance.OnNewmentions:AddListener(self.refresh_newmention)
    self.switchButton.onClick:AddListener(function()
        if self.currpanel == 1 then
            self.scrollRect.content = self.SelfContainer
            self.switchButtonTxt.text = TI18N("朋友圈")
            self.selfmomentList:Show()
            self.momentList:Hide()
            self.currpanel = 2
        else
            self.scrollRect.content = self.Container
            self.switchButtonTxt.text = TI18N("我的动态")
            self.selfmomentList:Hide()
            self.momentList:Show()
            self.currpanel = 1
        end
    end)
    if not ZoneManager.Instance.openself then
        self.scrollRect.content = self.SelfContainer
        self.selfmomentList:Show()
        self.momentList:Hide()
    end
    self:OnNewMentions()
end

function MomentsPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MomentsPanel:OnOpen()
    self.first = true
    self.isshow = true
    self.isGuild = false
    if self.openArgs ~= nil then
        if self.openArgs[2] ~= nil then
            if self.openArgs[2] == 2 then
                self:WatchNewMoment()
            end
        end
        if self.openArgs[3] ~= nil then
            if self.openArgs[3] == 1 then
                self:SendShowEffect()
                self.isGuild = true
            end
        end
        if self.openArgs[4] ~= nil then
            if self.openArgs[4] == 1 then
                self.topShow = 1
            elseif self.openArgs[4] == 2 then
                self.topShow = 2
            end
        end
        self.openArgs = nil
    end
    if BaseUtils.CheckCampaignTime(1061) then
        self.sendButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton12")
    else
        self.sendButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    end

    local rect = self.transform:Find("Mask"):GetComponent(RectTransform)
    if self.topShow == 1 then
        self.main.CommonTitle.anchoredPosition = Vector2(0, -29)
        self.bg.anchoredPosition = Vector2(1, -3)
        self.bg.sizeDelta = Vector2(521,326)
        rect.offsetMin = Vector2(7,57)
        rect.offsetMax = Vector2(-7,-61)
    elseif self.topShow == 2 then
        self.main.CommonTitle.anchoredPosition = Vector2(0, 6)
        self.bg.anchoredPosition = Vector2(1, 12)
        self.bg.sizeDelta = Vector2(521,356)
        rect.offsetMin = Vector2(7,57)
        rect.offsetMax = Vector2(-7,-31)
    end
end

function MomentsPanel:OnHide()
    self.isshow = false
end

function MomentsPanel:OnSendBtn()

    if RoleManager.Instance.RoleData.lev < 25 then
        NoticeManager.Instance:FloatTipsByString(TI18N("25级后才能发表状态喔，努力升级吧{face_1,9}"))
        return
    end
    if self.SendBtnEffect ~= nil then
        self.SendBtnEffect:SetActive(false)
    end
    self.sendpanel:Show(self.isGuild)
end

function MomentsPanel:ShowDetailOption(data, position)
    self.detialOptionData = data
    -- if self:IsSelfData() then
        self.hideOpt.gameObject:SetActive(false)
        self.reportOpt.gameObject:SetActive(false)
    -- else
    --     self.reportOpt.gameObject:SetActive(true)
    --     self.hideOpt.gameObject:SetActive(true)

    -- end
    if self:IsLiked() then
        self.likeOpt.transform:Find("I18NText"):GetComponent(Text).text = TI18N("取消")
    else
        self.likeOpt.transform:Find("I18NText"):GetComponent(Text).text = TI18N("点赞")
    end
    self.detialOption.position = position
    self.detialOption.gameObject:SetActive(true)
end

function MomentsPanel:IsSelfData()
    if RoleManager.Instance.RoleData.id == self.detialOptionData.role_id and RoleManager.Instance.RoleData.platform == self.detialOptionData.platform and RoleManager.Instance.RoleData.zone_id == self.detialOptionData.zone_id then
        return true
    else
        return false
    end
end

function MomentsPanel:IsLiked()
    for i,v in ipairs(self.detialOptionData.likes) do
        if RoleManager.Instance.RoleData.id == v.liker_id and RoleManager.Instance.RoleData.platform == v.liker_platform and RoleManager.Instance.RoleData.zone_id == v.liker_zone_id
            or RoleManager.Instance.RoleData.id == v.role_id and RoleManager.Instance.RoleData.platform == v.platform and RoleManager.Instance.RoleData.zone_id == v.zone_id  then
            return true
        end
    end
    return false
end

function MomentsPanel:OnLikeOpt()
    if self:IsLiked() then
        ZoneManager.Instance:Require11861(self.detialOptionData.m_id, self.detialOptionData.m_platform, self.detialOptionData.m_zone_id)
    else
        ZoneManager.Instance:Require11860(self.detialOptionData.m_id, self.detialOptionData.m_platform, self.detialOptionData.m_zone_id)
    end
    self.detialOption.gameObject:SetActive(false)
end

function MomentsPanel:OnCommentsOpt(itemdata)
    -- BaseUtils.dump(itemdata, "数据？？")
    local role = RoleManager.Instance.RoleData
    if itemdata.commentdata ~= nil and itemdata.commentdata.name == role.name then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否<color='#ffff00'>删除</color><color='#ffff00'>本条评论</color>？")
        data.sureLabel = TI18N("删除")
        data.cancelLabel = TI18N("取消")
        data.blueSure = true
        data.greenCancel = true
        data.sureCallback = function()ZoneManager.Instance:Require11863(itemdata.data.m_id, itemdata.data.m_platform, itemdata.data.m_zone_id, itemdata.commentdata.id) end
        NoticeManager.Instance:ConfirmTips(data)
        return
    end
    if role.lev < 20 then
        NoticeManager.Instance:FloatTipsByString(TI18N("20级后才能评论和回复喔，努力升级吧{face_1,9}"))
        return
    end
    self.commentpanel:Show(itemdata)
    self.detialOption.gameObject:SetActive(false)
end

function MomentsPanel:OnHideOpt()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("是否<color='#ffff00'>屏蔽</color>%s的<color='#ffff00'>本条状态</color>？"), self.detialOptionData.name)
    data.sureLabel = TI18N("全部")
    data.cancelLabel = TI18N("确认屏蔽")
    data.blueSure = true
    data.greenCancel = true
    data.cancelCallback = function()ZoneManager.Instance:Require11859(self.detialOptionData.m_id, self.detialOptionData.m_platform, self.detialOptionData.m_zone_id) end
    data.sureCallback = function()ZoneManager.Instance:Require11870(self.detialOptionData.role_id, self.detialOptionData.platform, self.detialOptionData.zone_id) end
    NoticeManager.Instance:ConfirmTips(data)
    self.detialOption.gameObject:SetActive(false)
end


function MomentsPanel:OnReportOpt()
    self.detialOption.gameObject:SetActive(false)
end

function MomentsPanel:OnScrollBoundary(value)
    if self.isWatchnew then
        return
    end
    local Top = (value.y-1)*(self.scrollRect.content.sizeDelta.y - 382.83) + 50
    local Bot = Top - 382.83 - 50
    self.momentList:OnScroll(Top, Bot)
    self.selfmomentList:OnScroll(Top, Bot)
    local space = 0
    if value.y > 1 then
        space = (value.y-1)*math.max(382.83, self.scrollRect.content.sizeDelta.y - 382.83)
    elseif value.y < 0 then
        space = value.y*math.max(382.83, self.scrollRect.content.sizeDelta.y - 382.83) * -1
    end
    -- print(space)
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
                            self.excuRefresh = 0
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
                            self.excuRefresh = 1
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
            if self.currpanel == 1 and ZoneManager.Instance.openself then
                -- print("请求自己？？")
                ZoneManager.Instance:Require11856(self.excuRefresh)
            elseif ZoneManager.Instance.openself then
                -- NoticeManager.Instance:FloatTipsByString("请求了自己的个人"..tostring(self.excuRefresh))
                ZoneManager.Instance:Require11857(ZoneManager.Instance.roleinfo.id, ZoneManager.Instance.roleinfo.platform, ZoneManager.Instance.roleinfo.zone_id, self.excuRefresh)
            else
                -- NoticeManager.Instance:FloatTipsByString("请求了别人的个人"..tostring(self.excuRefresh))
                ZoneManager.Instance:Require11857(ZoneManager.Instance.targetInfo.id, ZoneManager.Instance.targetInfo.platform, ZoneManager.Instance.targetInfo.zone_id, self.excuRefresh)
            end
            self.excuRefresh = nil
        end
        self.checking = false
        self.TopLoading:SetActive(false)
        self.BotLoading:SetActive(false)
    end
end

function MomentsPanel:OnMomentsRefresh()
    --刷新数据
    if self.momentList~= nil then
        self.scrollRect.inertia = false
        self.momentList:RefreshData(ZoneManager.Instance.momentsList, self.isshow)
        self.scrollRect.inertia = true
    end
    if self.selfmomentList ~= nil then
        if ZoneManager.Instance.openself then
            self.selfmomentList:RefreshData(ZoneManager.Instance.personmomentsData)
        else
            self.selfmomentList:RefreshData(ZoneManager.Instance.othermomentsData)
        end
    end
    self.TopLoading:SetActive(false)
    self.BotLoading:SetActive(false)
end

function MomentsPanel:OpenPhotoPreview(data)
    if self.photopreview == nil then
        self.photopreview = MomentsPhotoPreviewPanel.New(self.model, self)
    end
    self.photopreview:Show(data)
end

function MomentsPanel:WatchNewMoment(hide)
    if self.isWatchnew then
        self.momentList:RefreshData(ZoneManager.Instance.momentsList)
        self.isWatchnew = false
        self.nameText.gameObject:SetActive(false)
        self.switchButton.gameObject:SetActive(true)
        self.backButton.gameObject:SetActive(false)
        self.statusButton.gameObject:SetActive(true)
    end
    if next(ZoneManager.Instance.newmomentList) ~= nil then
        self.nameText.gameObject:SetActive(true)
        self.switchButton.gameObject:SetActive(false)
        self.statusButton.gameObject:SetActive(false)
        self.backButton.gameObject:SetActive(true)
        self.isWatchnew = true
        self.redPoint:SetActive(false)
        local temp = {}
        for k,v in pairs(ZoneManager.Instance.newmomentList) do
            table.insert( temp, v)
        end
        ZoneManager.Instance:ClearTempMoment()
        self.momentList:RefreshData(temp)
    elseif hide == nil then
        self.statusButton.gameObject:SetActive(true)
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有新消息"))
    end
end

function MomentsPanel:OnNewMentions()
    if next(ZoneManager.Instance.newmomentList) ~= nil then
        self.redPoint:SetActive(true)
    else
        self.redPoint:SetActive(false)
    end
end

function MomentsPanel:SendShowEffect()
    if self.SendBtnEffect == nil then
       local fun = function(effectView)
           local effectObject = effectView.gameObject
           effectObject.transform:SetParent(self.sendButton.gameObject.transform)
           effectObject.transform.localScale = Vector3(0.5, 0.65, 1)
           effectObject.transform.localPosition = Vector3(0, 1.7, -400)
           effectObject.transform.localRotation = Quaternion.identity
           Utils.ChangeLayersRecursively(effectObject.transform, "UI")
       end
       self.SendBtnEffect = BaseEffectView.New({effectId = 20107, time = nil, callback = fun})
    else
       self.SendBtnEffect:SetActive(true)
    end
end

--index  1为自己  2为别人
function MomentsPanel:SetPoAndSize(index)
    if self.transform == nil then
        if self.timer_set ~= nil then
            LuaTimer.Delete(self.timer_set)
            self.timer_set = nil
        end
        self.timer_set = LuaTimer.Add(50,function() self:SetPoAndSize(index) end)
        return
    end
    -- if self.MaskCon == nil then
    --     if self.timer_set ~= nil then
    --         LuaTimer.Delete(self.timer_set)
    --         self.timer_set = nil
    --     end
    --     self.timer_set = LuaTimer.Add(50,function() self:SetTimer(index) end)
    --     return
    -- end
    local rect = self.transform:Find("Mask"):GetComponent(RectTransform)
    if index == 1 then
        self.main.CommonTitle.anchoredPosition = Vector2(0, -29)
        self.bg.anchoredPosition = Vector2(1, -3)
        self.bg.sizeDelta = Vector2(521,326)
        rect.offsetMin = Vector2(7,57)
        rect.offsetMax = Vector2(-7,-61)
    elseif index == 2 then
        self.main.CommonTitle.anchoredPosition = Vector2(0, 6)
        self.bg.anchoredPosition = Vector2(1, 12)
        self.bg.sizeDelta = Vector2(521,356)
        rect.offsetMin = Vector2(7,57)
        rect.offsetMax = Vector2(-7,-31)
    end
end

