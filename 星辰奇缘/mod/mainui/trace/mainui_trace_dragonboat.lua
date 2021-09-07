-- @author 黄耀聪
-- @date 2016年5月31日

MainuiTraceDragonboat = MainuiTraceDragonboat or BaseClass(BaseTracePanel)

function MainuiTraceDragonboat:__init(main)
    self.main = main

    self.resList = {
        {file = AssetConfig.dragonboat_content, type = AssetType.Main}
        ,{file = AssetConfig.teamquest, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.tabObj = nil
    self.isInit = false
    self.mgr = DragonBoatManager.Instance

    self.totalDescString = TI18N("当前活动成绩:")
    self.timeDescString = TI18N("累计耗时")
    self.progressDescString = TI18N("目前进度")
    -- self.targetDescString = TI18N("下一目标:")
    self.exitString = TI18N("退出")
    self.exitSpacingString = TI18N("退 出")
    self.cancelString = TI18N("取 消")
    self.exitNoticeString = TI18N("<color='#ffff00'>活动进行中</color>退出活动，将<color='#00ff00'>无法</color>再次参与<color='#ffff00'>本场活动</color>，需要等待下场活动才能参与。是否退出活动？")
    self.exitNoticeString2 = TI18N("<color='#ffff00'>报名期间</color>退出活动，可随时再次报名。是否退出活动？")
    self.titleString = DragonBoatManager.Instance.title_name

    self.noticeString = {
        string.format(TI18N("1.%s需≥<color=#00FF00>3人</color>组队参加"), self.titleString),
        TI18N("2.完成全程时间<color=#00FF00>越短</color>排名<color=#00FF00>越高</color>"),
        TI18N("3.每场活动持续<color='#00ff00'>20分钟</color>，排名<color='#00ff00'>前3</color>的队伍可获得丰厚奖励"),
		TI18N("4.在15分钟、10分钟之前抵达，均可<color='#ffff00'>额外获得</color>一份奖励哟"),
        TI18N("5.活动途中退出活动，则无法再次参与"),
    }

    -- self.timePosition = {Vector2(-57.9,-55.7), Vector2(,-55.7), Vector2(,-55.7)}

    self.updateStatus = function() self:InitUI() end
    self.timeUpdate = function() self:UpdateTime() end
    self.update = function() self:UpdateProgress() end

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceDragonboat:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragonboat_content)) -- self.main.dragonBoatContent
    local t = self.gameObject.transform
    self.transform = t
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    local panel = t:Find("Panel")

    self.titleText = panel:Find("Title/Text"):GetComponent(Text)

    local content = panel:Find("Content")
    self.totalDescText = content:Find("TotalDesc"):GetComponent(Text)
    self.totalNoticeBtn = content:Find("TotalDesc/Notice"):GetComponent(Button)
    self.timeDescText = content:Find("TimeDesc"):GetComponent(Text)
    self.timeDescRect = self.timeDescText.gameObject:GetComponent(RectTransform)
    self.timeText = content:Find("TimeDesc/Time"):GetComponent(Text)
    self.timeRect = self.timeText.gameObject:GetComponent(RectTransform)
    self.progressNormalRect = content:Find("Progress/Normal"):GetComponent(RectTransform)
    self.progressSelectRect = content:Find("Progress/Select"):GetComponent(RectTransform)
    self.dragonBoatRect = content:Find("Progress/DragonBoat"):GetComponent(RectTransform)
    self.dragonBoatImg = content:Find("Progress/DragonBoat"):GetComponent(Image)
    -- self.dragonBoatImg.sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "dragonboat2")
    self.dragonBoatImg.sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "dragonboat")
    -- self.targetDescText = content:Find("TargetDesc"):GetComponent(Text)
    self.targetText = content:Find("TargetDesc/TargetText"):GetComponent(Text)
    self.progressSelectRect.anchoredPosition = Vector2(-0.8, 1.23)

    self.exitBtn = panel:Find("BtnArea/Box/Button"):GetComponent(Button)

    self.totalDescText.text = self.totalDescString
    self.timeDescText.text = self.timeDescString
    -- self.targetDescText.text = self.targetDescString

    self.totalNoticeBtn.onClick:AddListener(function() self:OnNotice() end)
    panel:Find("BtnArea/Box/Button/Text"):GetComponent(Text).text = self.exitString
    panel:Find("Title/Text"):GetComponent(Text).text = self.titleString

    self.btn = content:GetComponent(Button)

    self.exitBtn.onClick:AddListener(function() self:OnExit() end)
    self.btn.onClick:AddListener(function() self:OnGoNext() end)

    self.panel = panel

    panel = t:Find("Panel2")
    panel:Find("Title/Text"):GetComponent(Text).text = DragonBoatManager.Instance.title_name
    panel:Find("Container/DescText"):GetComponent(Text).text = TI18N("1、活动开始时间一到，即刻开始<color='#ffff00'>计时</color>\n2、<color='#ffff00'>越快抵达</color>终点的队伍，获得的奖励<color='#ffff00'>越丰厚</color>\n3、中途<color='#ffff00'>退出队伍/活动</color>，则<color='#00ff00'>无法</color>再次参与<color='#ffff00'>本场活动</color>")
    self.txtClockVal = panel:Find("Container/taskItemClock/TxtClockVal"):GetComponent(Text)
    local btn = panel:Find("Container/BtnLeft"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnExit() end)
    btn = panel:Find("Container/BtnTeam"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnTeam() end)

    self.panel2 = panel

    self.isInit = true
end

function MainuiTraceDragonboat:OnInitCompleted()
    -- 非依赖资源，UI创建完就可以卸载
    --self:ClearMainAsset()

    self.OnOpenEvent:Fire()
end

function MainuiTraceDragonboat:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.totalNoticeBtn.gameObject, itemData = self.noticeString})
end

function MainuiTraceDragonboat:__delete()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function MainuiTraceDragonboat:OnShow()
    self:RemoveListeners()
    self.mgr.onUpdateStatus:AddListener(self.updateStatus)
    self.mgr.onUpdateTrace:AddListener(self.update)

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 200, self.timeUpdate)

    self:InitUI()
end

function MainuiTraceDragonboat:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function MainuiTraceDragonboat:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function MainuiTraceDragonboat:RemoveListeners()
    self.mgr.onUpdateStatus:RemoveListener(self.update)
    self.mgr.onUpdateTrace:RemoveListener(self.update)
end

function MainuiTraceDragonboat:InitUI()
    if self.mgr.status == 2 then
        self.panel.gameObject:SetActive(true)
        self.panel2.gameObject:SetActive(false)

        self:UpdateTime()
        self:UpdateProgress()
    else
        self.panel.gameObject:SetActive(false)
        self.panel2.gameObject:SetActive(true)

        self:UpdateTime()
    end
end

function MainuiTraceDragonboat:UpdateTime()
    -- print("UpdateTime")
    -- print(self.mgr.status)
    -- print(self.mgr.time_out)
    -- print(BaseUtils.BASE_TIME)
    if self.mgr.status == 1 and self.mgr.time_out > 0 then
        local time = math.floor(self.mgr.time_out - BaseUtils.BASE_TIME)
        self.txtClockVal.text = tostring(os.date("%M:%S", time))

        -- if time > 0 and time < 7 and self.mgr.model.dragonBoatStartWindow == nil then
        --     self.mgr.model:OpenStartWindow()
        -- end

        -- if time == 0 and TeamManager.Instance:IsSelfCaptin() then
        --     local list = TeamManager.Instance:GetMemberOrderList()
        --     local num = 0
        --     for key, value in ipairs(list) do
        --         if value.status == RoleEumn.TeamStatus.Follow then
        --             num = num + 1
        --         end
        --     end
        --     if num < 2 then
        --         DragonBoatManager.Instance:send19903()
        --     end
        -- end
    end

    if self.mgr.status == 2 then
        if self.mgr.start_time > 0 then
            local diff = BaseUtils.BASE_TIME - self.mgr.start_time
            if diff < 3600 then
        	    if diff <= 600 then
                    self.timeText.text = tostring(os.date("%M:%S", diff))..TI18N("<color=#FFFF00>/10分钟</color>")
        	    elseif diff <= 900 then
                    self.timeText.text = tostring(os.date("%M:%S", diff))..TI18N("<color=#FFFF00>/15分钟</color>")
        	    else
                    self.timeText.text = tostring(os.date("%M:%S", diff))
        	    end
            else
                local h = math.floor(diff / 3600)
                if h < 10 then
                    self.timeText.text = string.format("0%s:%s", tostring(h), os.date("%M:%S", diff))
                else
                    self.timeText.text = string.format("%s:%s", tostring(h), os.date("%M:%S", diff))
                end
            end
        else
            self.timeText.text = "00:00"
        end
    end

    local w = self.timeDescText.preferredWidth + self.timeText.preferredWidth + self.timeRect.anchoredPosition.x
    self.timeDescRect.anchoredPosition = Vector2(-w/2 + 12, -55.7)

    -- if self.mgr.done == DataDragonBoat.data_list_length then
    --     if self.timerId ~= nil then
    --         LuaTimer.Delete(self.timerId)
    --         self.timerId = nil
    --     end
    -- end
end

function MainuiTraceDragonboat:UpdateProgress()
    -- self.progressText.text = (self.mgr.done + 1).."/"..(DataDragonBoat.data_list_length + 1)
    -- self.progressSlider.value = (self.mgr.done + 1) / (DataDragonBoat.data_list_length + 1)
    local w = self.progressNormalRect.sizeDelta.x
    local h = self.progressNormalRect.sizeDelta.y

    self.progressSelectRect.sizeDelta = Vector2(w * self.mgr.done / DataDragonBoat.data_list_length, h)
    self.dragonBoatRect.anchoredPosition = Vector2((w - 16) * self.mgr.done / DataDragonBoat.data_list_length, 0)

    if self.mgr.done == DataDragonBoat.data_list_length then
    else
        local monsterData = DataDragonBoat.data_list[self.mgr.done + 1]
        self.targetText.text = DataMap.data_list[monsterData.map_id].name.."\n"..monsterData.name
    end
end

function MainuiTraceDragonboat:OnGoNext()
    print(string.format("划龙舟，当前点%s", self.mgr.done))
    self.mgr:GoNext()
end

function MainuiTraceDragonboat:OnExit()
    --print("滑雪活动做完啦。。。。。啦啦啦")
    local exit = function() DragonBoatManager.Instance:send19903() end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    if self.mgr.status == 2 then
        data.content = self.exitNoticeString
    else
        data.content = self.exitNoticeString2
    end
    data.sureLabel = self.exitSpacingString
    data.cancelLabel = self.cancelString
    data.cancelSecond = -1
    data.sureCallback = exit
    data.blueSure = true
    data.greenCancel = true
    NoticeManager.Instance:ConfirmTips(data)
end

function MainuiTraceDragonboat:OnTeam()
    TeamManager.Instance.TypeOptions = {}
    TeamManager.Instance.TypeOptions[6] = 113
    TeamManager.Instance.LevelOption = 1
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
end
