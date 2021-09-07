-- @author 黄耀聪
-- @date 2017年6月12日, 星期一

QuestKingProgress = QuestKingProgress or BaseClass(BaseWindow)

function QuestKingProgress:__init(model)
    self.model = model
    self.name = "QuestKingProgress"

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.quest_king_progress
    -- self.holdTime = 100

    self.resList = {
        {file = AssetConfig.quest_king_progress, type = AssetType.Main},
        {file = AssetConfig.quest_king_bg, type = AssetType.Main},
        {file = AssetConfig.quest_king_textures, type = AssetType.Dep},
    }

    self.levelList = {}
    self.timeString = TI18N("%s月%s日")
    self.waitListener = function() self:WaitForProto() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function QuestKingProgress:__delete()
    self.OnHideEvent:Fire()
    if self.levelList ~= nil then
        for _,level in pairs(self.levelList) do
            level:DeleteMe()
        end
        self.levelList = nil
    end
    self:AssetClearAll()
end

function QuestKingProgress:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.quest_king_progress))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")

    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.quest_king_bg)))

    self.timeText = main:Find("Time"):GetComponent(Text)
    self.noticeBtn = main:Find("Notice"):GetComponent(Button)

    local levelContainer = main:Find("LevelContainer")
    for i=1,levelContainer.childCount do
        self.levelList[levelContainer.childCount - i + 1] = QuestKingProgressLevel.New(self.model, levelContainer:GetChild(i - 1).gameObject)
    end

    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
end

function QuestKingProgress:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function QuestKingProgress:OnOpen()
    self:RemoveListeners()
    QuestKingManager.Instance.updateEvent:AddListener(self.waitListener)

    self:Reload()
end

function QuestKingProgress:OnHide()
    self:RemoveListeners()
end

function QuestKingProgress:RemoveListeners()
    QuestKingManager.Instance.updateEvent:RemoveListener(self.waitListener)
end

function QuestKingProgress:WaitForProto()
    if self.model.selectEnvelop ~= nil then
        local quest_id = nil
        for _,v in ipairs(self.model.currentList) do
            if v.envelop == self.model.selectEnvelop then
                quest_id = v.quest_id
                break
            end
        end
        if quest_id ~= nil then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.quest_king_scroll_mark, {self.model.selectEnvelop})
        end
        self.model.selectEnvelop = nil
    else
        if self.stage ~= nil and self.model.stage ~= self.stage then
            self:Unlock()
        end
        self:Reload()
    end
end

function QuestKingProgress:Reload()
    for i,v in ipairs(self.levelList) do
        v:SetData(i)
    end
    self.stage = self.model.stage

    if self.model.campId == nil or DataCampaign.data_list[self.model.campId] == nil then
        self.timeText.text = ""
    else
        local start_time = DataCampaign.data_list[self.model.campId].cli_start_time[1]
        local end_time = DataCampaign.data_list[self.model.campId].cli_end_time[1]

        self.timeText.text = string.format(TI18N("活动时间:<color='#ffff00'>%s-%s</color>"),
                string.format(self.timeString, tostring(start_time[2]), tostring(start_time[3])),
                string.format(self.timeString, tostring(end_time[2]), tostring(end_time[3]))
            )
    end
end

function QuestKingProgress:Unlock()
    if self.levelList[self.model.stage] ~= nil then
        self.levelList[self.model.stage]:Unlock()
    end
    -- LuaTimer.Add(500, function() self:Reload() end)
end

function QuestKingProgress:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {
            TI18N("1.同时仅能接受一个<color='#13fc60'>暖心祈福</color>任务，需完成或放弃当前任务才能接受下一个"),
            TI18N("2.完成当前阶段的任务要求后，即可<color='#13fc60'>解锁</color>下一阶段"),
            TI18N("3.当可完成任务数<color='#13fc60'>不足以</color>完成当前阶段要求时，将无法解锁至下阶段，请<color='#ffff00'>谨慎放弃任务！</color>"),
        }})
end