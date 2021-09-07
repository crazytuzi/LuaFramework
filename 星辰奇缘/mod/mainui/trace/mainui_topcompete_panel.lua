-- --------------------------
--幻境追踪面板
-- --------------------------
-- MainuiTopCompetePanel = MainuiFairyLandPanel or BaseClass()

MainuiTopCompetePanel = MainuiTopCompetePanel or BaseClass(BaseTracePanel)

function MainuiTopCompetePanel:__init(main)
    self.main = main
    self.isInit = true
    self.do_request = false
    self.mid_timer_id = 0

    self.on_item_update = function()
        local key_num = BackpackManager.Instance:GetItemCount(29005)
        -- self.box_TxtKevVal.text = string.format("%sX%s", TI18N("巅峰之钥"), key_num)
        -- self.TxtKevVal.text = string.format("%sX%s", TI18N("巅峰之钥"), key_num)

        if key_num == 0 then
            self.box_TxtDesc.text = TI18N("钥匙已用完可退出活动")
        else
            self.box_TxtDesc.text = TI18N("请赶快使用钥匙开启宝箱吧")
        end
    end

    self.on_role_event_change = function()
        if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.TopCompete then
            self.do_request = false
        end
    end

    self.teamUpdate = function()
        if TeamManager.Instance:HasTeam() then
            local leave_num = 0
            local total_num = 0
            for k, v in pairs(TeamManager.Instance.memberTab) do
                total_num = total_num + 1
                if v.status == RoleEumn.TeamStatus.Away then
                    leave_num = leave_num + 1
                end
            end
            if total_num - leave_num >= 3 then
                self.MidTxtDesc.text = TI18N("系统正在匹配对手")
            else
                self.MidTxtDesc.text = string.format("<color='#ffff00'>%s</color>", TI18N("三人以上组队才能加入匹配"))
            end
        else
            self.MidTxtDesc.text = string.format("<color='#ffff00'>%s</color>", TI18N("三人以上组队才能加入匹配"))
        end
    end

    self.resList = {
        {file = AssetConfig.topcomplete_content, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTopCompetePanel:__delete()
    self.OnHideEvent:Fire()
    self.do_request = false
    self:stop_mid_timer()
end

function MainuiTopCompetePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.on_role_event_change)
    EventMgr.Instance:RemoveListener(event_name.team_update, self.teamUpdate)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.teamUpdate)
end

function MainuiTopCompetePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.topcomplete_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)
    self.rect = self.gameObject:GetComponent(RectTransform)

    ---------------------活动进行中ing
    self.openCon = self.transform:Find("OpenCon")
    self.TopItem = self.openCon:Find("TopItem")
    self.TimeTxtVal = self.TopItem:Find("TimeTxtVal"):GetComponent(Text)
    -- self.TimeRateVal = self.TopItem:Find("TimeRateVal"):GetComponent(Text)
    self.TimeLifeTxtVal = self.TopItem:Find("TimeLifeTxtVal"):GetComponent(Text)
    self.TimeTakePartVal = self.TopItem:Find("TimeTakePartVal"):GetComponent(Text)
    self.MidTxtDesc = self.TopItem:Find("MidTxtDesc"):GetComponent(Text)
    self.ImgKeyCon = self.TopItem:Find("ImgKeyCon")
    -- self.TxtKevVal = self.ImgKeyCon:Find("TxtKevVal"):GetComponent(Text)
    self.BtnCon = self.openCon:Find("BtnCon")
    self.BtnRecruit = self.BtnCon:Find("BtnRecruit"):GetComponent(Button)
    self.BtnQuick = self.BtnCon:Find("BtnQuick"):GetComponent(Button)
    self.BtnQuick.gameObject:SetActive(true)
    self.BtnAddTeam = self.BtnCon:Find("BtnAddTeam"):GetComponent(Button)
    self.BtnAddTeam_txt = self.BtnAddTeam.transform:Find("Text"):GetComponent(Text)

    ---------------------活动等待中
    self.unopenCon = self.transform:Find("UnOpenCon")
    self.unopen_TopItem = self.unopenCon:Find("TopItem")
    self.unopen_TimeTxtVal = self.unopen_TopItem:Find("TimeTxtVal"):GetComponent(Text)
    self.unopen_ImgExpCon = self.unopen_TopItem:Find("ImgExpCon")
    self.unopen_TxtExpVal = self.unopen_ImgExpCon:Find("TxtExpVal"):GetComponent(Text)
    self.unoepn_BtnCon = self.unopenCon:Find("BtnCon")
    self.unoepn_BtnQuick = self.unoepn_BtnCon:Find("BtnQuick"):GetComponent(Button)
    self.unoepn_BtnRecruit = self.unoepn_BtnCon:Find("BtnRecruit"):GetComponent(Button)
    self.unoepn_BtnAddTeam = self.unoepn_BtnCon:Find("BtnAddTeam"):GetComponent(Button)
    self.unoepn_BtnAddTeam_txt = self.unoepn_BtnAddTeam.transform:Find("Text"):GetComponent(Text)

    ---------------------开宝箱ing
    self.boxCon = self.transform:Find("BoxCon")
    self.box_TopItem = self.boxCon:Find("TopItem")
    self.box_TxtTime = self.box_TopItem:Find("TxtTime"):GetComponent(Text)
    self.box_ImgKeyCon = self.box_TopItem:Find("ImgKeyCon")
    -- self.box_TxtKevVal = self.box_ImgKeyCon:Find("TxtKevVal"):GetComponent(Text)
    self.box_BtnCon = self.boxCon:Find("BtnCon")
    self.box_BtnQuick = self.box_BtnCon:Find("BtnQuick"):GetComponent(Button)
    self.box_TxtDesc = self.box_TopItem:Find("TxtDesc"):GetComponent(Text)

    self.BtnRecruit.onClick:AddListener(function()
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[6] = 64
        TeamManager.Instance.LevelOption = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team,{1})
    end)

    self.BtnAddTeam.onClick:AddListener(function()
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[6] = 64
        TeamManager.Instance.LevelOption = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team,{1})
    end)

    self.unoepn_BtnRecruit.onClick:AddListener(function()
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[6] = 64
        TeamManager.Instance.LevelOption = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team,{1})
    end)

    self.unoepn_BtnAddTeam.onClick:AddListener(function()
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[6] = 64
        TeamManager.Instance.LevelOption = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team,{1})
    end)

    self.BtnQuick.onClick:AddListener(function()
        --请求退出战区
        self:on_quick()
    end)

    self.unoepn_BtnQuick.onClick:AddListener(function()
        --请求退出战区
        self:on_quick()
    end)

    self.box_BtnQuick.onClick:AddListener(function()
        --请求退出战区
        self:on_quick()
    end)

    self.ImgKeyCon:GetComponent(Button).onClick:AddListener(function()
        local tips = {}

        table.insert(tips, TI18N("巅峰对决结束后，将根据成绩给予<color='#ffff00'>巅峰之钥</color>，可在场地中开启："))
        table.insert(tips, TI18N("<color='ffff00'>黄金宝箱</color> 获得<color='#ffff00'>翅膀</color>等珍品道具"))
        table.insert(tips, TI18N("<color='ffff00'>水晶宝箱</color> 获得<color='#ffff00'>装备提升</color>道具"))
        table.insert(tips, TI18N("<color='ffff00'>黑曜宝箱</color> 获得<color='#ffff00'>宠物提升</color>道具"))
        table.insert(tips, TI18N("<color='ffff00'>白银宝箱</color> 获得各类<color='#ffff00'>资产</color>"))
        TipsManager.Instance:ShowText({gameObject = self.ImgKeyCon.gameObject, itemData = tips})

    end)

    self.box_ImgKeyCon:GetComponent(Button).onClick:AddListener(function()
        local tips = {}

        table.insert(tips, TI18N("巅峰对决结束后，将根据成绩给予<color='#ffff00'>巅峰之钥</color>，可在场地中开启："))
        table.insert(tips, TI18N("<color='ffff00'>黄金宝箱</color> 获得<color='#ffff00'>翅膀</color>等珍品道具"))
        table.insert(tips, TI18N("<color='ffff00'>水晶宝箱</color> 获得<color='#ffff00'>装备提升</color>道具"))
        table.insert(tips, TI18N("<color='ffff00'>黑曜宝箱</color> 获得<color='#ffff00'>宠物提升</color>道具"))
        table.insert(tips, TI18N("<color='ffff00'>白银宝箱</color> 获得各类<color='#ffff00'>资产</color>"))
        TipsManager.Instance:ShowText({gameObject = self.box_ImgKeyCon.gameObject, itemData = tips})

    end)

    self.isInit = true
    self.on_item_update()

    self.teamUpdate()
end

function MainuiTopCompetePanel:on_quick()
    if TopCompeteManager.Instance.model.top_compete_status_data ~= nil and TopCompeteManager.Instance.model.top_compete_status_data.status == 3 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("退出巅峰对决之后无法再次进入，确定是否退出")
        data.sureLabel = TI18N("退出")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            TopCompeteManager.Instance:request15102()
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
    end
    TopCompeteManager.Instance:request15102()
end

function MainuiTopCompetePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTopCompetePanel:OnShow()
    -- print("---------------------------------------show 巅峰对决追中面板了")
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.on_role_event_change)

    EventMgr.Instance:AddListener(event_name.team_update, self.teamUpdate)
    EventMgr.Instance:AddListener(event_name.team_leave, self.teamUpdate)

    if self.do_request == false then
        TopCompeteManager.Instance:request15103()
        self.do_request = true
    end

    if TopCompeteManager.Instance.model.top_compete_status_data ~= nil then
        if TopCompeteManager.Instance.model.top_compete_status_data.status == 3 then
            TopCompeteManager.Instance:show_team_tips(true)
        end
    end
end

function MainuiTopCompetePanel:OnHide()
    self:RemoveListeners()
end


---------------------------------------------更新界面逻辑
function MainuiTopCompetePanel:update_status()
    if self.isInit == false then
        return
    end
    if TopCompeteManager.Instance.model.top_compete_status_data == nil then
        return
    end

    self.teamUpdate()

    local top_compete_status_data = TopCompeteManager.Instance.model.top_compete_status_data
    self.unopenCon.gameObject:SetActive(false)
    self.openCon.gameObject:SetActive(false)
    self.boxCon.gameObject:SetActive(false)
    if top_compete_status_data.status == 2 then
        self.unopenCon.gameObject:SetActive(true)
    elseif top_compete_status_data.status == 3 then
        self.openCon.gameObject:SetActive(true)
    elseif top_compete_status_data.status == 4 then
        -- self.boxCon.gameObject:SetActive(true)
        self.openCon.gameObject:SetActive(true)
        self.MidTxtDesc.text = TI18N("活动已结束，可自行退出")
    end

    self.time = TopCompeteManager.Instance.model.top_compete_status_data.time
    self:star_mid_timer()
end

function MainuiTopCompetePanel:update_info(data)
    if self.isInit == false then
        return
    end

    self.data = data

    self:update_status()

    -- self.TimeRateVal.text = string.format("%s/%s", data.win, data.times)
    self.TimeTakePartVal.text = tostring(data.score)

    self.unopen_TxtExpVal.text = tostring(data.exp)

    local die = data.die - 1
    die = die > 0 and die or 0
    self.TimeLifeTxtVal.text = string.format("%s", die)

    self.BtnAddTeam.gameObject:SetActive(false)
    self.BtnRecruit.gameObject:SetActive(false)
    self.unoepn_BtnRecruit.gameObject:SetActive(false)
    self.unoepn_BtnAddTeam.gameObject:SetActive(false)
    self.unoepn_BtnQuick.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
    self.BtnQuick.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)

    self.unoepn_BtnAddTeam_txt.text = TI18N("组 队")
    self.BtnAddTeam_txt.text = TI18N("组 队")
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        --我是队长,检查下队员是否已经满了

        self.unoepn_BtnAddTeam_txt.text = TI18N("队伍匹配")
        self.BtnAddTeam_txt.text = TI18N("队伍匹配")
        if TeamManager.Instance:MemberCount() < 5 then
            --显示成招募按钮
            self.unoepn_BtnRecruit.gameObject:SetActive(true)
            self.unoepn_BtnQuick.transform:GetComponent(RectTransform).anchoredPosition = Vector2(57, 0)
        end
    else
        if not TeamManager.Instance:HasTeam() then
            --显示成加入按钮
            self.unoepn_BtnAddTeam.gameObject:SetActive(true)
            self.unoepn_BtnQuick.transform:GetComponent(RectTransform).anchoredPosition = Vector2(57, 0)
        end
    end
end

--


---------------------------------------------计时器逻辑
--中部计时器
function MainuiTopCompetePanel:star_mid_timer()
    if self.mid_timer_id ~= 0 then
        return
    end
    self.mid_timer_id = LuaTimer.Add(0, 1000, function()
        self:mid_timer_tick()
    end)
end

function MainuiTopCompetePanel:stop_mid_timer()
    if self.mid_timer_id ~= 0 then
        LuaTimer.Delete(self.mid_timer_id)
        self.mid_timer_id = 0
    end
end

function MainuiTopCompetePanel:mid_timer_tick()
    self.time = self.time - 1
    if self.time <= 0 then
        self.TimeTxtVal.text = "00:00"
        self.unopen_TimeTxtVal.text = "00:00"
        self.box_TxtTime.text = "00:00"
        self:stop_mid_timer()
    else
        local my_hour = math.modf(self.time % 86400 / 3600)
        local my_minute = math.modf(self.time % 86400 % 3600 / 60)
        local my_second = math.modf(self.time % 86400 % 3600 % 60)
        my_minute = my_minute + my_hour*60
        my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
        my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
        if TopCompeteManager.Instance.model.top_compete_status_data.status == 2 then
            self.unopen_TimeTxtVal.text = string.format("%s:%s", my_minute, my_second)
        elseif TopCompeteManager.Instance.model.top_compete_status_data.status == 3 then
            self.TimeTxtVal.text = string.format("%s:%s", my_minute, my_second)
        elseif TopCompeteManager.Instance.model.top_compete_status_data.status == 4 then
             self.box_TxtTime.text = string.format("%s:%s", my_minute, my_second)
        end

    end
end

--更新胜场
function MainuiTopCompetePanel:update_win_rate()
    -- self.TimeRateVal.text = string.format("")
end
