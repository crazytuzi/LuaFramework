GloryRewardWindow = GloryRewardWindow or BaseClass(BaseWindow)

function GloryRewardWindow:__init(model)
    self.model = model
    self.name = "GloryRewardWindow"
    self.windowId = WindowConfig.WinID.glory_reward
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.glory_reward_window, type = AssetType.Main}
        , {file = AssetConfig.rolebgstand, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
        , {file = AssetConfig.glory_textures, type = AssetType.Dep}
    }

    self.rewardList = {}
    self.weeklyList = {}

    self.updateListener = function() self:UpdateRank() end
    self.gloryListener = function() self:UpdateGlory() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GloryRewardWindow:__delete()
    self.OnHideEvent:Fire()
    if self.rewardList ~= nil then
        for _,v in pairs(self.rewardList) do
            if v ~= nil then
                v.slot:DeleteMe()
            end
        end
    end
    if self.weeklyList ~= nil then
        for _,v in pairs(self.weeklyList) do
            if v ~= nil then
                v.slot:DeleteMe()
            end
        end
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.rewardLayout ~= nil then
        self.rewardLayout:DeleteMe()
        self.rewardLayout = nil
    end
    if self.weeklyLayout ~= nil then
        self.weeklyLayout:DeleteMe()
        self.weeklyLayout = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.rewardEffect ~= nil then
        self.rewardEffect:DeleteMe()
        self.rewardEffect = nil
    end
    if self.rankPanel ~= nil then
        self.rankPanel:DeleteMe()
        self.rankPanel = nil
    end
    self.model = nil
    self:AssetClearAll()
end

function GloryRewardWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glory_reward_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform

    local main = t:Find("Main")
    self.closeBtn = main:Find("Close"):GetComponent(Button)

    local left = main:Find("Left")
    local right = main:Find("Right")

    self.nameText = left:Find("Name"):GetComponent(Text)
    self.classesImage = left:Find("Class"):GetComponent(Image)
    self.roleContainer = left:Find("Role")
    self.currentLevelText = left:Find("TextBg/Current"):GetComponent(Text)
    self.maxLevelText = left:Find("TextBg/Max"):GetComponent(Text)
    self.nextText = left:Find("Text"):GetComponent(Text)

    self.weeklyLayout = LuaBoxLayout.New(right:Find("WeeklyReward/Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 5})
    self.rankText = right:Find("Rank/Title/Num"):GetComponent(Text)
    self.overText = right:Find("Rank/Over"):GetComponent(Text)
    self.descExt = MsgItemExt.New(right:Find("Rank/Text"):GetComponent(Text), 200, 16, 18.53)
    self.rewardLayout = LuaBoxLayout.New(right:Find("Rank/Reward"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})
    self.jumpBtn = right:Find("Jump"):GetComponent(Button)
    self.rewardBtn = right:Find("Reward"):GetComponent(Button)
    self.rewardBtnImg = right:Find("Reward"):GetComponent(Image)
    self.rewardBtnText = right:Find("Reward/Text"):GetComponent(Text)
    self.checkFriendBtn = right:Find("Rank/Check"):GetComponent(Button)
    self.notifyText = right:Find("Rank/Reward/NotifyText"):GetComponent(Text)
    self.imageI18N = right:Find("Rank/ImageI18N"):GetComponent(Image)

    left:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")
    left:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.jumpBtn.onClick:AddListener(function() self:OnRankGlobal() end)
    self.rewardBtn.onClick:AddListener(function() self:OnReward() end)
    self.checkFriendBtn.onClick:AddListener(function() self:OnRankFriends() end)

    -- 预处配置数据
    table.sort(DataGlory.data_rank, function(a,b) return a.min < b.min end)
end

function GloryRewardWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryRewardWindow:OnOpen()
    self:RemoveListeners()
    RankManager.Instance.OnUpdateList:AddListener(self.updateListener)
    GloryManager.Instance.onUpdateInfo:AddListener(self.gloryListener)

    self.dailyMode = nil
    self.normalMode = nil
    local newId = self.model.currentData.new_id or 0;
    if newId == DataGlory.data_level_length then
        self.dailyMode = DataGlory.data_level[newId].day_exp_mod
        self.normalMode = DataGlory.data_level[newId].normal_exp_mod
    else
        self.dailyMode = DataGlory.data_level[newId + 1].day_exp_mod
        self.normalMode = DataGlory.data_level[newId + 1].normal_exp_mod
    end

    RankManager.Instance:send12500({type = 56, sub_type = 1, page = 1, num = 100})
    RankManager.Instance:send12500({type = 56, sub_type = 2, page = 1, num = 100})
    RankManager.Instance:send12501({type = 56})

    self:UpdateMyRank()
    self:UpdateFriends()
    self:UpdateGlory()
    self:UpdateInfo()
    self:UpdateWeekReward()
end

function GloryRewardWindow:OnHide()
    self:RemoveListeners()

    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
    if self.rankPanel ~= nil then
        self.rankPanel:Hiden()
    end
end

function GloryRewardWindow:RemoveListeners()
    RankManager.Instance.OnUpdateList:RemoveListener(self.updateListener)
    GloryManager.Instance.onUpdateInfo:RemoveListener(self.gloryListener)
end

function GloryRewardWindow:UpdateMyRank()
    local datalist = RankManager.Instance.model:GetDataList(56,1)
    local myData = RankManager.Instance.model:GetMyData(56)
    self.overText.text = string.format(TI18N("（超越了<color='#ffff00'>%s%%</color>的玩家）"), self:GetPercent(myData.rank, (datalist[1] or {}).val1))
    if myData.rank == nil or myData.rank == 0 then
        self.rankText.text = TI18N("未上榜")
    else
        self.rankText.text = myData.rank
    end

    if myData.rank == nil or myData.rank == 0 or myData.rank > DataGlory.data_rank[DataGlory.data_rank_length].max then
        self:UpdateRankReward(DataGlory.data_rank[DataGlory.data_rank_length].reward)
        self.notifyText.text = string.format(TI18N("前<color='#ffff00'>%s名</color>可获"), DataGlory.data_rank[DataGlory.data_rank_length].max)
        self.rewardLayout:AddCell(self.notifyText.gameObject)
        self.imageI18N.sprite = self.assetWrapper:GetSprite(AssetConfig.glory_textures, "NextI18N")
    else
        for i=DataGlory.data_rank_length,1,-1 do
            local data = DataGlory.data_rank[i]
            if myData.rank >= data.min then
                self:UpdateRankReward(data.reward)
                break
            end
        end
        self.imageI18N.sprite = self.assetWrapper:GetSprite(AssetConfig.glory_textures, "CanRewardI18N")
        self.notifyText.gameObject:SetActive(false)
    end
    self.imageI18N:SetNativeSize()
end

function GloryRewardWindow:UpdateGlory()
    self.currentLevelText.text = string.format(TI18N("当前层数:<color='#ffff9a'>第%s层</color>"), self.model.currentData.new_id)
    self.maxLevelText.text = string.format(TI18N("历史最高:<color='#ffff9a'>第%s层</color>"), self.model.currentData.max_id)
    local next_id = self.model.currentData.max_id - 5
    if next_id < 0 then next_id = 0 end
    self.nextText.text = string.format(TI18N("下周将会重置到<color='#ffff9a'>第%s层</color>"), next_id)

    if self.model.currentData.last_week_flag == 1 then
        self.rewardBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.rewardBtnText.color = ColorHelper.DefaultButton3
        if self.rewardEffect == nil then
            self.rewardEffect = BibleRewardPanel.ShowEffect(20118, self.rewardBtn.transform, Vector3(1.15, 0.78, 1), Vector3(-58, 22, -400))
        else
            self.rewardEffect:SetActive(true)
        end
    else
        self.rewardBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.rewardBtnText.color = ColorHelper.DefaultButton4
        if self.rewardEffect ~= nil then
            self.rewardEffect:SetActive(false)
        end
    end
end

function GloryRewardWindow:UpdateInfo()
    self.nameText.text = RoleManager.Instance.RoleData.name
    self.classesImage.sprite = PreloadManager.Instance:GetClassesSprite(RoleManager.Instance.RoleData.classes)

    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "GloryRewardPreview"
        ,orthographicSize = 0.65
        ,width = 341
        ,height = 341
        ,offsetY = -0.38
    }
    local llooks = {}
    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        llooks = mySceneData.looks
    end
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = llooks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function GloryRewardWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.roleContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.roleContainer.gameObject:SetActive(true)
end

function GloryRewardWindow:GetPercent(rank, top)
    if rank == nil or rank == 0 then
        return 100 - ((top or 100) - self.model.currentData.new_id)
    elseif rank <= 10 then
        return 99
    elseif rank <= 30 then
        return 98
    elseif rank <= 50 then
        return 97
    elseif rank <= 60 then
        return 96
    elseif rank <= 70 then
        return 95
    elseif rank <= 80 then
        return 94
    elseif rank <= 90 then
        return 93
    elseif rank <= 100 then
        return 92
    else
        return 91
    end
end

function GloryRewardWindow:UpdateRank(updateType)
    self:UpdateFriends()
    self:UpdateMyRank()
end

function GloryRewardWindow:UpdateFriends()
    local datalist = RankManager.Instance.model:GetDataList(56,2)
    local friendList = {}
    local roleData = RoleManager.Instance.RoleData

    BaseUtils.dump(datalist, "56_2")

    local findMe = false
    for i,v in ipairs(datalist) do
        if (not findMe) and roleData.id == v.role_id and roleData.platform == v.platform and v.zone_id == roleData.zone_id then
            findMe = true
        elseif findMe == true and #friendList < 3 then
            table.insert(friendList, v.name)
        end
    end

    if #friendList == 0 then
        self.descExt:SetData(TI18N("暂未超越任何好友，继续加油噢"))
    elseif #friendList == 1 then
        self.descExt:SetData(string.format(TI18N("当前已超越<color='#ffff00'>%s</color>"), friendList[1]))
    else
        self.descExt:SetData(string.format(TI18N("当前已超越<color='#ffff00'>%s</color>等好友"), table.concat(friendList, TI18N("、"))))
    end
end

function GloryRewardWindow:OnReward()
    if self.model.currentData.last_week_flag == 1 then
        GloryManager.Instance:send14425()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("本周奖励可在下<color='#ffff00'>周一五点</color>后领取哟{face_1, 22}"))
    end
end

function GloryRewardWindow:OnRankGlobal()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, {1, 56})
end

function GloryRewardWindow:OnRankFriends()
    if self.rankPanel == nil then
        self.rankPanel = GloryFriendRank.New(self.model, self.gameObject)
    end
    self.rankPanel.closeCallback = function() self.rankPanel:Hiden() end
    self.rankPanel:Show()
end


function GloryRewardWindow:UpdateWeekReward()
    self.weeklyLayout:ReSet()
    local tab = {}
    local datalist = {}
    for i,v in ipairs((RoleManager.Instance.expModeTab[self.dailyMode] or {}).list or {}) do
        if v.num > 0 then
            tab[v.item_id] =(tab[v.item_id] or 0) + v.num
        end
    end
    local newid = self.model.currentData.new_id or 0
    if newid < DataGlory.data_level_length then
        for _,v in ipairs(GloryManager.RewardFilter(DataGlory.data_level[newid + 1].day_reward)) do
            tab[v[1]] =(tab[v[1]] or 0) + v[2]
        end
    end
    for base_id, v in pairs(tab) do
        table.insert(datalist, {item_id = base_id, num = v})
    end

    for i, v in ipairs(datalist) do
        local tab = self.weeklyList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            self.weeklyList[i] = tab
        end
        tab.slot:SetAll(DataItem.data_get[v.item_id], {inbag = false, nobutton = true})
        tab.slot:SetNum(v.num)
        self.weeklyLayout:AddCell(tab.slot.gameObject)
    end
    for i=#datalist + 1, #self.weeklyList do
        self.weeklyList[i].gameObject:SetActive(false)
    end
end

function GloryRewardWindow:UpdateRankReward(list)
    self.rewardLayout:ReSet()
    for i, v in ipairs(list) do
        local tab = self.rewardList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            self.rewardList[i] = tab
        end
        tab.slot:SetAll(DataItem.data_get[v[1]], {inbag = false, nobutton = true})
        tab.slot:SetNum(v[2])
        self.rewardLayout:AddCell(tab.slot.gameObject)
    end
    for i=#list + 1, #self.rewardList do
        self.rewardList[i].slot.gameObject:SetActive(false)
    end
end
