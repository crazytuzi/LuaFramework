-- @Author: lwj
-- @Date:   2019-01-15 17:32:59
-- @Last Modified time: 2019-01-15 17:33:02

DailyLimitItem = DailyLimitItem or class("DailyLimitItem", BaseCloneItem)
local DailyLimitItem = DailyLimitItem

function DailyLimitItem:ctor(parent_node, layer)
    DailyLimitItem.super.Load(self)

end

function DailyLimitItem:dctor()
    if self.click_event_id then
        self.model:RemoveListener(self.click_event_id)
    end
    self.click_event_id = nil
    if self.update_count_event_id then
        self.model:RemoveListener(self.update_count_event_id)
        self.update_count_event_id = nil
    end

    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
    self.schedule = nil
end

function DailyLimitItem:LoadCallBack()
    self.model = DailyModel.GetInstance()
    self.nodes = {
        "sel_img",
        "bg",
        "normal/RightContent/timeArea/areaTime", "normal/RightContent/btn_go", "normal/times",
        "normal/RightContent/timeArea",
        "normal",
        "running", "icon",
        "outDate",
        "normal/RightContent",
        "normal/touch",
        "lock",
        "lock/limit",
    }
    self:GetChildren(self.nodes)
    SetVisible(self.running, true)

    self.icon = GetImage(self.icon)
    self.times = GetText(self.times)
    self.areaTime = GetText(self.areaTime)
    self.limit = GetText(self.limit)

    self:AddEvent()
    SetVisible(self.running, false)
end

function DailyLimitItem:AddEvent()
    local function call_back(id)
        self:Select(id)
    end
    self.click_event_id = self.model:AddListener(DailyEvent.LimitItemClick, call_back)

    local function call_back()
        self.model:Brocast(DailyEvent.LimitItemClick, self.data.conData.id)
        lua_panelMgr:GetPanelOrCreate(ActivityTips):Open(self.data.conData.id, self.touch)
    end
    AddClickEvent(self.touch.gameObject, call_back)

    local function call_back()
        if self.data.conData.link_type == 1 then
            --任务
            if self.data.conData.link then
                local link_id = tonumber(String2Table(self.data.conData.link)[1])
                if link_id == 930000 then
                    if RoleInfoModel.GetInstance():GetMainRoleData().guild == "0" then
                        Notify.ShowText("Please join the guild first")
                        return
                    end
                end
                TaskModel.GetInstance():DoTask(link_id)
            end
        elseif self.data.conData.link_type == 2 then
            if self.hookData then
                SceneManager:GetInstance():AttackCreepByTypeId(self.hookData.creep)
            end
        elseif self.data.conData.link_type == 3 then
            --界面跳转
            if self.data.conData.link ~= "" then
                local pTab = String2Table(self.data.conData.link)
                OpenLink(unpack(pTab[1]))
            end
        elseif self.data.conData.link_type == 4 then
            --挂机
            if self.hookData then
                SceneManager:GetInstance():AttackCreepByTypeId(self.hookData.creep)
            end
        elseif self.data.conData.link_type == 5 then
            --npc
            if self.data.conData.link then
                SceneManager:GetInstance():FindNpc(String2Table(self.data.conData.link)[1])
            end
        end
        self.model:Brocast(DailyEvent.CloseDailyActPanel)
    end
    AddClickEvent(self.btn_go.gameObject, call_back)

    self.update_count_event_id = self.model:AddListener(DailyEvent.UpdateActRemainCount, handler(self, self.UpdateRemainCount))
end

function DailyLimitItem:SetData(data, stencil_id, stencil_type)
    self.stencil_id = stencil_id
    self.stencil_type = stencil_type
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function DailyLimitItem:UpdateCountShow()

end

function DailyLimitItem:UpdateView()
    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_daily", self.data.conData.pic, true, nil, false)
    if self.data.isLock then
        SetVisible(self.lock, true)
        SetVisible(self.normal, false)
        self.limit.text = string.format(ConfigLanguage.Daily.DailyShowLimit, tostring(String2Table(self.data.conData.reqs)[1][2]))
    else
        SetVisible(self.lock, false)
        SetVisible(self.normal, true)

        local len = 0

        self.areaTime.text,len = self:GetTimeStr()

        if len == 3 then
            --处理3个时间段
            SetSizeDelta(self.timeArea,114.5,53.3)

            SetAnchoredPosition(self.areaTime.transform,57,-27.2)
            SetSizeDelta(self.areaTime.transform,114,61.8)
        end

        local is_show_eft = false
        if self.data.timeData.state == 1 then
            --进行中
            self:SetOpenShow()
            self.targetTime = TimeManager.GetInstance():GetStampByHMS(unpack(self.data.timeData.endStamp[self.data.timeData.startStamp.running_index]))
            is_show_eft = true
        elseif self.data.timeData.state == 2 then
            --未到开放时间
            self:SetInDateShow()
            self.targetTime = TimeManager.GetInstance():GetStampByHMS(unpack(self.data.timeData.startStamp[self.data.timeData.endStamp.target_index]))
        else
            --已过期
            self:SetOutDateShow()
            self.targetTime = TimeManager.GetInstance():GetTomorZeroTime()
        end

        if self.schedule then
            GlobalSchedule:Stop(self.schedule)
            self.schedule = nil
        end
        self.schedule = GlobalSchedule.StartFun(handler(self, self.CheckChange), 1, -1)
        local times = self.data.conData.count
        --local actV = self.data.conData.activation * times
        if self.data.taskInfo then

        else
            self.times.text = ConfigLanguage.Daily.ActiveItemTimesHead .. times .. "/" .. times
        end
        self:DestroyEft()
        if is_show_eft then
            self.running_eft = UIEffect(self.bg.transform, 10124, false)
            self.running_eft:SetConfig({ useStencil = true, stencilId = self.stencil_id, stencilType = self.stencil_type })
            self.running_eft:SetOrderIndex(421)
        end
    end
end

function DailyLimitItem:DestroyEft()
    if self.running_eft then
        self.running_eft:destroy()
        self.running_eft = nil
    end
end

function DailyLimitItem:CheckChange()
    if os.time() >= self.targetTime then
        if not self.model.isUpdatting then
            self.model:Brocast(DailyEvent.UpdatePanel)
            self.model.isUpdatting = true
        end
    end
end

function DailyLimitItem:Select(id)
    SetVisible(self.sel_img, self.data.conData.id == id)
end

function DailyLimitItem:GetTimeStr()
    local str = ""
    local len = #self.data.timeData.startStamp
    local startTbl = self.data.timeData.startStamp
    local endTbl = self.data.timeData.endStamp
    for i = 1, len do
        local enter_str = ""
        if i ~= len then
            enter_str = "\n"
        end
        if self.data.timeData.state == 1 then
            local color_str = "31A420"
            if startTbl.running_index == i then
                color_str = "D46433"
            end
            str = str .. string.format("<color=#%s>%02d:%02d-%02d:%02d</color>", color_str, startTbl[i][1], startTbl[i][2], endTbl[i][1], endTbl[i][2]) .. enter_str
        else
            str = str .. string.format("%02d:%02d-%02d:%02d", startTbl[i][1], startTbl[i][2], endTbl[i][1], endTbl[i][2]) .. enter_str
        end
    end
    return str,len
end

function DailyLimitItem:SetOpenShow()
    SetVisible(self.bg, true)
    SetVisible(self.running, true)
    SetVisible(self.outDate, false)
    SetVisible(self.btn_go, true)
    ShaderManager.GetInstance():SetImageNormal(self.icon)
    SetVisible(self.RightContent, true)
    SetColor(self.areaTime, 212, 100, 51, 255)
    SetColor(self.times, 169, 110, 69, 255)
end

function DailyLimitItem:SetInDateShow()
    SetVisible(self.bg, true)
    SetVisible(self.running, false)
    SetVisible(self.outDate, false)
    SetVisible(self.btn_go, false)
    ShaderManager.GetInstance():SetImageNormal(self.icon)
    SetVisible(self.RightContent, true)
    SetColor(self.areaTime, 212, 100, 51, 255)
    SetColor(self.times, 169, 110, 69, 255)
end

function DailyLimitItem:SetOutDateShow()
    SetVisible(self.outDate, true)
    SetVisible(self.bg, false)
    SetVisible(self.running, false)
    SetVisible(self.btn_go, false)
    ShaderManager.GetInstance():SetImageGray(self.icon, self.stencil_id, self.stencil_type)
    SetVisible(self.RightContent, false)
    SetColor(self.times, 119, 119, 119, 255)
end

function DailyLimitItem:UpdateRemainCount(group, ser_data)
    if self.data.conData.group == group then
        local rest = self.data.conData.count - ser_data.progress
        local color_str = ""
        if ser_data.progress == self.data.conData.count then
            color_str = "<color=#FF0000>"
        else
            color_str = "<color=#A96E45>"
        end
        self.times.text = ConfigLanguage.Daily.ActiveItemTimesHead .. color_str .. rest .. "/" .. self.data.conData.count .. "</color>"
    end
end

