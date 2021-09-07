-- --------------------------
-- 主UI段位赛
-- --------------------------
MainuiQualifyPanel = MainuiQualifyPanel or BaseClass(BaseTracePanel)

function MainuiQualifyPanel:__init(main)
    self.main = main
    self.isInit = true

    self.mainObj = nil
    self.match_timer_id = 0
    self.mid_timer_id = 0
    self.total_time = 0

    self.resList = {
        {file = AssetConfig.qualify_content, type = AssetType.Main}
        ,{file = AssetConfig.attr_icon,type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiQualifyPanel:__delete()
    self.OnHideEvent:Fire()
    self.mainObj = nil
    self:stop_mid_timer()
    self:stop_bottom_timer()
end

function MainuiQualifyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.qualify_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.rect = self.gameObject:GetComponent(RectTransform)

    self.TopItem = self.transform:Find("TopItem")
    self.TimeTxtVal = self.TopItem:Find("TimeTxtVal"):GetComponent(Text)
    self.TimeRateVal = self.TopItem:Find("TimeRateVal"):GetComponent(Text)
    self.TimeTakePartVal = self.TopItem:Find("TimeTakePartVal"):GetComponent(Text)
    self.BottomItem = self.transform:Find("BottomItem").gameObject
    self.BtnCon = self.transform:Find("BtnCon")
    self.BtnQuick = self.BtnCon:Find("BtnQuick"):GetComponent(Button)
    self.BtnMatch = self.BtnCon:Find("BtnMatch"):GetComponent(Button)
    self.Desc =  self.BottomItem.transform:Find("Desc"):GetComponent(Text)

    self.BottomItem.transform:GetComponent(Button).onClick:AddListener(function()
        QualifyManager.Instance.model:OpenQualifyMatchUI()
    end)

    self.BtnMatch.onClick:AddListener(function()
        QualifyManager.Instance.model:OpenQualifyMainUI()
    end)

    self.BtnQuick.onClick:AddListener(function()
        QualifyManager.Instance:request13513()
    end)

    self.isInit = true

    if QualifyManager.Instance.model.sign_type ~= 0 then
        --匹配中显示底部信息
        self:update_bottom_state(true)
    else
        self:update_bottom_state(false)
    end

    EventMgr.Instance:AddListener(event_name.qualify_state_update, function()
        if QualifyManager.Instance.model.sign_type ~= 0 then
            --匹配中显示底部信息
            self:update_bottom_state(true)
        else
            self:update_bottom_state(false)
        end
        -- 更新胜场
        local fenmu = QualifyManager.Instance.model:get_has_take_part()

        local fenzi = QualifyManager.Instance.model.match_state_data.win
        self.TimeRateVal.text = tostring(fenzi)

        self.TimeTakePartVal.text = string.format("%s/8", fenmu)
    end)

    EventMgr.Instance:AddListener(event_name.role_event_change, function()
        if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Match then
            self:stop_mid_timer()
        else
            self:star_mid_timer()
        end
    end)

    EventMgr.Instance:AddListener(event_name.qualify_time_update, function()
        self:star_mid_timer()
    end)
    self:star_mid_timer()

    if QualifyManager.Instance.model.match_state_data ~= nil then
         -- 更新胜场
        local fenmu = QualifyManager.Instance.model:get_has_take_part()

        local fenzi = QualifyManager.Instance.model.match_state_data.win
        self.TimeRateVal.text = tostring(fenzi)

        self.TimeTakePartVal.text = string.format("%s/8", fenmu)
    end
end

function MainuiQualifyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiQualifyPanel:OnShow()
    -- if QualifyManager.Instance.model.match_state_data ~= nil then
    --     self.TimeRateVal.text = tostring(QualifyManager.Instance.model.match_state_data.win)
    -- end
end

function MainuiQualifyPanel:OnHide()
    -- self.gameObject:SetActive(false)
end

--中部计时器
function MainuiQualifyPanel:star_mid_timer()
    if self.mid_timer_id ~= 0 then
        return
    end
    self.mid_timer_id = LuaTimer.Add(0, 1000, function()
        self:mid_timer_tick()
    end)
end

function MainuiQualifyPanel:stop_mid_timer()
    if self.mid_timer_id ~= 0 then
        LuaTimer.Delete(self.mid_timer_id)
        self.mid_timer_id = 0
    end
end

function MainuiQualifyPanel:mid_timer_tick()
    local time = QualifyManager.Instance.model.activity_time - Time.time
    if time == 0 then
        self.TimeTxtVal.text = "00:00"
        self:stop_mid_timer()
    else
        local my_minute = math.modf(time % 86400 % 3600 / 60)
        local my_second = math.modf(time % 86400 % 3600 % 60)
        my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
        my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
        self.TimeTxtVal.text = string.format("%s:%s", my_minute, my_second)
    end
end

--更新胜场
function MainuiQualifyPanel:update_win_rate()
    self.TimeRateVal.text = string.format("")
end

--更新底部显示状态
function MainuiQualifyPanel:update_bottom_state(state)
    self.BottomItem:SetActive(state)

    self.BtnCon.gameObject:SetActive(not state)
    if state then
        --如果计时器没开就开启计时器
        self:star_bottom_timer()
    else
        self:stop_bottom_timer()
    end
end

------------------------------------底部逻辑
--开启计时器
function MainuiQualifyPanel:star_bottom_timer()
    self:stop_bottom_timer()
    if self.match_timer_id ~= 0 then
        --已经在计时中
        return
    end
    self.match_timer_id = LuaTimer.Add(0, 1000, function()
        self:update_timer_tick()
    end)
end

--停止计时器
function MainuiQualifyPanel:stop_bottom_timer()
    if self.match_timer_id ~= 0 then
        LuaTimer.Delete(self.match_timer_id)
        self.match_timer_id = 0
    end
end



--外部计时器调用
function MainuiQualifyPanel:update_timer_tick()
    self.total_time = self.total_time + 1
    local mod = self.total_time%4
    if mod == 1 then
        self.Desc.text = TI18N(".")
    elseif mod == 2 then
        self.Desc.text = TI18N("..")
    elseif mod == 3 then
        self.Desc.text = TI18N("...")
    else
        self.Desc.text = TI18N("")
    end
end