-- @author hzf
-- @date 2016年7月29日,星期五

MomentsCityPanel = MomentsCityPanel or BaseClass(BasePanel)

function MomentsCityPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MomentsCityPanel"

    self.resList = {
        {file = AssetConfig.moment_city_panel, type = AssetType.Main}
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
    self.isshow = false
    self.currpanel = 1
    self.lastReqTime = 0
    self.previewID = 0
    self.isWatchnew = false
end

function MomentsCityPanel:__delete()
    ZoneManager.Instance.OnMomentsUpdate:RemoveListener(self.refresh_comments)
    if self.photopreview ~= nil then
        self.photopreview:DeleteMe()
    end
    if self.momentList ~= nil then
        self.momentList:DeleteMe()
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

function MomentsCityPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.moment_city_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.switchButton = self.transform:Find("switchButton"):GetComponent(Button)
    self.switchButtonTxt = self.transform:Find("switchButton/Text"):GetComponent(Text)
    self.nameText = self.transform:Find("nameText"):GetComponent(Text)
    self.nameText.text = TI18N("同城动态")
    -- if ZoneManager.Instance.openself then
    --     self.nameText.gameObject:SetActive(false)
    -- else
    --     self.nameText.gameObject:SetActive(true)
    --     self.switchButton.gameObject:SetActive(false)
    -- end
    self.MaskCon = self.transform:Find("Mask")
    self.Container = self.transform:Find("Mask/Container")
    self.TopLoading = self.transform:Find("Mask/TopLoading").gameObject
    self.BotLoading = self.transform:Find("Mask/BotLoading").gameObject
    self.TopText = self.transform:Find("Mask/TopLoading/I18NText"):GetComponent(Text)
    self.BotText = self.transform:Find("Mask/BotLoading/I18NText"):GetComponent(Text)
    local go = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20166.unity3d"))
    go.transform:SetParent(self.TopLoading.transform:Find("Image"))
    go.transform.localPosition = Vector3(0,0,-110)
    go.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(go.transform, "UI")
    local go2 = GameObject.Instantiate(go)
    go2.transform:SetParent(self.BotLoading.transform:Find("Image"))
    go2.transform.localPosition = Vector3(0,0,-110)
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
    self.scrollRect.content = self.Container
    self.scrollRect.onValueChanged:AddListener(function(val)
        self:OnScrollBoundary(val)
    end)
    self.momentList = MomentsListPanel.New(self.Container.gameObject, self, 1)
    -- self.sendpanel = MomentsSendPanel.New(self.model, self.gameObject)
    self.commentpanel = MomentsCommentPanel.New(self.model, self.gameObject)

    self.momentList:RefreshData(ZoneManager.Instance.citymomentList)
    ZoneManager.Instance.OnMomentsUpdate:AddListener(self.refresh_comments)
end

function MomentsCityPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MomentsCityPanel:OnOpen()
    self.isshow = true
end

function MomentsCityPanel:OnHide()
    self.isshow = false
end

function MomentsCityPanel:ShowDetailOption(data, position)
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

function MomentsCityPanel:IsSelfData()
    if RoleManager.Instance.RoleData.id == self.detialOptionData.role_id and RoleManager.Instance.RoleData.platform == self.detialOptionData.platform and RoleManager.Instance.RoleData.zone_id == self.detialOptionData.zone_id then
        return true
    else
        return false
    end
end

function MomentsCityPanel:IsLiked()
    for i,v in ipairs(self.detialOptionData.likes) do
        if RoleManager.Instance.RoleData.id == v.liker_id and RoleManager.Instance.RoleData.platform == v.liker_platform and RoleManager.Instance.RoleData.zone_id == v.liker_zone_id
            or RoleManager.Instance.RoleData.id == v.role_id and RoleManager.Instance.RoleData.platform == v.platform and RoleManager.Instance.RoleData.zone_id == v.zone_id  then
            return true
        end
    end
    return false
end

function MomentsCityPanel:OnLikeOpt()
    if self:IsLiked() then
        ZoneManager.Instance:Require11861(self.detialOptionData.m_id, self.detialOptionData.m_platform, self.detialOptionData.m_zone_id)
    else
        ZoneManager.Instance:Require11860(self.detialOptionData.m_id, self.detialOptionData.m_platform, self.detialOptionData.m_zone_id)
    end
    self.detialOption.gameObject:SetActive(false)
end

function MomentsCityPanel:OnCommentsOpt(itemdata)
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

function MomentsCityPanel:OnHideOpt()
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

function MomentsCityPanel:OnReportOpt()
    self.detialOption.gameObject:SetActive(false)
end

function MomentsCityPanel:OnScrollBoundary(value)
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
            ZoneManager.Instance:Require11873(self.excuRefresh)
            self.excuRefresh = nil
        end
        self.checking = false
        self.TopLoading:SetActive(false)
        self.BotLoading:SetActive(false)
    end
end

function MomentsCityPanel:OnMomentsRefresh()
    if self.momentList~= nil then
        self.scrollRect.inertia = false
        self.momentList:RefreshData(ZoneManager.Instance.citymomentList, self.isshow)
        self.scrollRect.inertia = true
    end
    self.TopLoading:SetActive(false)
    self.BotLoading:SetActive(false)
end

function MomentsCityPanel:OpenPhotoPreview(data)
    if self.photopreview == nil then
        self.photopreview = MomentsPhotoPreviewPanel.New(self.model, self)
    end
    self.photopreview:Show(data)
end

-- function MomentsCityPanel:WatchNewMoment(hide)
--     if self.isWatchnew then
--         self.momentList:RefreshData(ZoneManager.Instance.citymomentList)
--         self.isWatchnew = false
--         self.nameText.gameObject:SetActive(false)
--         self.switchButton.gameObject:SetActive(true)
--         self.backButton.gameObject:SetActive(false)
--         self.statusButton.gameObject:SetActive(true)
--     end
--     if next(ZoneManager.Instance.citymomentList) ~= nil then
--         self.nameText.gameObject:SetActive(true)
--         self.switchButton.gameObject:SetActive(false)
--         self.statusButton.gameObject:SetActive(false)
--         self.backButton.gameObject:SetActive(true)
--         self.isWatchnew = true
--         self.redPoint:SetActive(false)
--         local temp = {}
--         for k,v in pairs(ZoneManager.Instance.citymomentList) do
--             table.insert( temp, v)
--         end
--         ZoneManager.Instance:ClearTempMoment()
--         self.momentList:RefreshData(temp)
--     elseif hide == nil then
--         self.statusButton.gameObject:SetActive(true)
--         NoticeManager.Instance:FloatTipsByString("当前没有新消息")
--     end
-- end
