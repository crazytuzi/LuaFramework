-- @author 黄耀聪
-- @date 2017年7月10日, 星期一

IngotCrashShow = IngotCrashShow or BaseClass(BaseWindow)

function IngotCrashShow:__init(model)
    self.model = model
    self.name = "IngotCrashShow"
    self.windowId = WindowConfig.WinID.ingot_crash_show

    self.cacheMode = CacheMode.Visible
    
    self.resList = {
        {file = AssetConfig.ingotcrash_show, type = AssetType.Main}
        ,{file = AssetConfig.dailyicon, type = AssetType.Dep}
    }

    self.agendaId = 2056
    self.titleString = TI18N("<color='#00ff00'>钻石联赛</color>开始啦{face_1,36}")
    self.ruleString = TI18N([[1.<color='#ffff00'>资格赛</color><color='#00ff00'>20:05</color>开启，按积分排名32强晋级淘汰赛
2.<color='#ffff00'>淘汰赛</color><color='#00ff00'>20:16</color>开启，每获胜1次即可晋级下一轮
3.联赛冠军将获得无上荣耀以及累计<color='#ffff00'>1500钻石</color>奖励
4.从16进8比赛开始，所有玩家可下注赢取钻石奖励]])

    self.updateListener = function() self:Reload() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashShow:__delete()
    self.OnHideEvent:Fire()
    if self.titleExt ~= nil then
        self.titleExt:DeleteMe()
        self.titleExt = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.rulesExt ~= nil then
        self.rulesExt:DeleteMe()
        self.rulesExt = nil
    end
    if self.rewardImageLoader ~= nil then
        self.rewardImageLoader:DeleteMe()
        self.rewardImageLoader = nil
    end
    if self.dailyImage ~= nil then
        self.dailyImage.sprite = nil
    end
    self:AssetClearAll()
end

function IngotCrashShow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_show))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.mainRect = main
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.dailyImage = main:Find("DailyIcon/Image"):GetComponent(Image)
    self.titleExt = MsgItemExt.New(main:Find("Title"):GetComponent(Text), 300, 19, 22)
    self.rulesExt = MsgItemExt.New(main:Find("Rules/Text"):GetComponent(Text), 430, 18, 20.85)
    self.timeText = main:Find("Time"):GetComponent(Text)
    self.rewardBtn = main:Find("Reward"):GetComponent(Button)
    self.button = main:Find("Button"):GetComponent(Button)
    self.buttonImage = self.button.gameObject:GetComponent(Image)
    self.buttonText = main:Find("Button/Text"):GetComponent(Text)
    self.rewardImageLoader = SingleIconLoader.New(main:Find("Reward/Image").gameObject)

    self.rewardImageLoader:SetSprite(SingleIconType.Item, 90026)

    self.button.onClick:AddListener(function() self:OnClick() end)
    self.rewardBtn.onClick:AddListener(function() self:OnReward() end)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
end

function IngotCrashShow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashShow:OnOpen()
    self:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:AddListener(self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.updateListener)

    self:Reload()
end

function IngotCrashShow:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function IngotCrashShow:RemoveListeners()
    IngotCrashManager.Instance.onUpdateInfo:RemoveListener(self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.updateListener)
end

function IngotCrashShow:Reload()
    self.titleExt:SetData(self.titleString)
    self.rulesExt:SetData(self.ruleString)

    local agendaData = DataAgenda.data_list[self.agendaId]
    self.dailyImage.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, agendaData.icon)

    local size = self.titleExt.contentTrans.sizeDelta
    self.titleExt.contentTrans.anchoredPosition = Vector2(120, -66 + size.y / 2)

    size = self.rulesExt.contentTrans.sizeDelta
    self.mainRect.sizeDelta = Vector2(size.x + 80, size.y + 280)

    self:UpdateButton()

    if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Close or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Predict  or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Ready or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.GlobalPreview then
        if self.timerId == nil then
            self.timerId = LuaTimer.Add(0, 20, function() self:OnTime() end)
        end
    else
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
        self.timeText.text = TI18N("报名时间已过，可进行观战")
    end
end

function IngotCrashShow:UpdateButton()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Close or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Predict or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.GlobalPreview then
        if IngotCrashManager.Instance.hasRegister then
            self.buttonText.text = TI18N("报名成功")
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.buttonText.color = ColorHelper.DefaultButton1
        else
            self.buttonText.text = TI18N("我要报名")
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.buttonText.color = ColorHelper.DefaultButton2
            self.effect = BibleRewardPanel.ShowEffect(20118, self.button.transform, Vector3(1, 0.75, 1), Vector3(-50, 20, -400))
        end
    elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Ready then
        if IngotCrashManager.Instance:IsActive() then
            self.buttonText.text = TI18N("正在参与")
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.buttonText.color = ColorHelper.DefaultButton1
        elseif IngotCrashManager.Instance.hasRegister then
            self.buttonText.text = TI18N("立即参与")
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.buttonText.color = ColorHelper.DefaultButton2
            self.effect = BibleRewardPanel.ShowEffect(20118, self.button.transform, Vector3(1, 0.75, 1), Vector3(-50, 20, -400))
        else
            self.buttonText.text = TI18N("我要报名")
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.buttonText.color = ColorHelper.DefaultButton2
            self.effect = BibleRewardPanel.ShowEffect(20118, self.button.transform, Vector3(1, 0.75, 1), Vector3(-50, 20, -400))
        end
    elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Qualifier or IngotCrashManager.Instance.phase== IngotCrashEumn.Phase.Kickout then
        self.buttonText.text = TI18N("观 战")
        self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.buttonText.color = ColorHelper.DefaultButton1
    elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
        self.buttonText.text = TI18N("录 像")
        self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.buttonText.color = ColorHelper.DefaultButton1
    elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Champion then
        self.buttonText.text = TI18N("录 像")
        self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.buttonText.color = ColorHelper.DefaultButton1
    end
end

function IngotCrashShow:OnClick()
    if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Close then
    elseif IngotCrashManager.Instance.phase ==IngotCrashEumn.Phase.Predict or IngotCrashManager.Instance.phase ==IngotCrashEumn.Phase.GlobalPreview then
        IngotCrashManager.Instance:Enter()
        WindowManager.Instance:CloseWindow(self, false)
    elseif IngotCrashManager.Instance.phase ==IngotCrashEumn.Phase.Ready then
        if IngotCrashManager.Instance:IsActive() then
        else
            IngotCrashManager.Instance:Enter()
            WindowManager.Instance:CloseWindow(self, false)
        end
    elseif IngotCrashManager.Instance.phase== IngotCrashEumn.Phase.Qualifier then
        self:OnWatch()
    elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Kickout then
        self:OnWatch()
    elseif IngotCrashManager.Instance.phase ==IngotCrashEumn.Phase.Guess then
    elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Champion then
        self:OnWatch()
    end
end

function IngotCrashShow:OnReward()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_reward)
end

function IngotCrashShow:OnWatch()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_watch)
end

function IngotCrashShow:OnTime()
    local dis = (IngotCrashManager.Instance.time or BaseUtils.BASE_TIME) - BaseUtils.BASE_TIME
    local min = 0
    local sec = 0
    local hour = 0

    -- if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.GlobalPreview then
    --     dis = dis + 15 * 60
    -- end
    if dis > 0 then
        hour = math.floor(dis / 3600)
        min = math.floor((dis % 3600) / 60)
        sec = dis % 60
    end
    if min < 10 then
        min = string.format("0%s", min)
    end
    if sec < 10 then
        sec = string.format("0%s", sec)
    end

    if hour > 0 then
        if hour < 10 then
            hour = string.format("0%s", hour)
        end
        self.timeText.text = string.format(TI18N("距离活动开启：%s:%s:%s"), hour, min, sec)
    else
        self.timeText.text = string.format(TI18N("距离活动开启：%s:%s"), min, sec)
    end
end
