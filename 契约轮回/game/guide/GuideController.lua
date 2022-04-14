require('game.guide.RequireGuide')
GuideController = GuideController or class("GuideController", BaseController)
local GuideController = GuideController

function GuideController:ctor()
    GuideController.Instance = self
    self.model = GuideModel:GetInstance()
    self:AddEvents()
    --self:RegisterAllProtocal()
end

function GuideController:dctor()
end

function GuideController:GetInstance()
    if not GuideController.Instance then
        GuideController.new()
    end
    return GuideController.Instance
end

function GuideController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = ""
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function GuideController:AddEvents()
    local function call_back()
        --self:ShowGuide()
    end
    GlobalEvent:AddListener(GuideEvent.PanelOpen, call_back)

    local function call_back(cls_name)
        for i = 1, #self.model.items do
            local item = self.model.items[i]
            if item.data.panel == cls_name then
                item:destroy()
                self.model.items[i] = nil
            end
        end
        if self.model.advertise_name == cls_name then
            TaskModel:GetInstance():ResumeTask(true)
            self.model.advertise_name = ""
        end
    end
    GlobalEvent:AddListener(EventName.ClosePanel, call_back)

    local function call_back()
        self:ClearCurGuide()
    end
    GlobalEvent:AddListener(TaskEvent.FinishMainTask, call_back)

    local function call_back()
        local level = RoleInfoModel:GetInstance():GetRoleValue("level")
        for k, v in pairs(Config.db_advertise) do
            if v.level == 0 or v.level == level then
                if v.task_id == 0 or
                        (v.task_id > 0 and TaskModel:GetInstance():GetTask(v.task_id)
                                and TaskModel:GetInstance():GetTask(v.task_id).state == enum.TASK_STATE.TASK_STATE_ACCEPT) then
                    local close_time = v.time or 0
                    local params = String2Table(v.panel)
                    if close_time > 0 then
                        table.insert(params, close_time)
                    end
                    MainIconOpenLink(unpack(params))
                    self.model.advertise_name = v.panel_name
                    TaskModel:GetInstance():PauseTask()
                end
            end
        end
    end
    GlobalEvent:AddListener(TaskEvent.GlobalAddTask, call_back)
    RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", call_back)

    local function call_back()
        self:AddStrongGuide()
    end
    GlobalEvent:AddListener(GuideEvent.ShowStrong, call_back)
end

-- overwrite
function GuideController:GameStart()
    local function call_back()
        GlobalSchedule:Start(handler(self, self.CheckGuide), 0.2)
    end
    GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.VLow)
end


----请求基本信息
--function LoginController:RequestLoginVerify()
-- local pb = self:GetPbObject("m_login_verify_tos")
-- self:WriteMsg(proto.LOGIN_VERIFY,pb)
--end

----服务的返回信息
--function GuideController:HandleLoginVerify(  )
-- local data = self:ReadMsg("m_login_verify_toc")
--end

--检查指引
function GuideController:CheckGuide()
    if OpenTipModel:GetInstance().isOpenning then
        return
    end
    if self.model.cur_guide then
        self:ShowGuide()
        return
    end
    local task_list = TaskModel:GetInstance().task_list
    self.model.step_index = 1
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    for task_id, _ in pairs(task_list) do
        if Config.db_guide[task_id] and not self.model.guides[task_id] then
            local guide_level = Config.db_guide[task_id].level
            if guide_level == 0 or (guide_level > 0 and level <= guide_level) then
                self.model.cur_guide = Config.db_guide[task_id]
            end
        end
    end
    if Config.db_guide[level] and not self.model.guides[level] then
        self.model.cur_guide = Config.db_guide[level]
    end
    self:ShowGuide()
end

function GuideController:ShowGuide()
    if #self.model.items > 0 then
        return
    end
    --[[	if self.model.has_guide then
            return
        end--]]
    if not self.model.cur_guide then
        return
    end
    local step_id = String2Table(self.model.cur_guide.guide_step)[self.model.step_index]
    local guide_step = Config.db_guide_step[step_id]
    if not guide_step then
        return
    end
    if self.model.cur_guide.expand_menu == 1 and self.model.step_index == 1 then
        local MainPanel = lua_panelMgr:GetPanel(MainUIView)
        if MainPanel and MainPanel.main_bottom_right then
            MainPanel.main_bottom_right:SwitchToIcons(true)
        end
    end
    local panel = lua_panelMgr:GetPanelByName(guide_step.panel)
    if panel then
        self.model.has_guide = true
        local parent = self:GetNode(panel, guide_step.node)
        if parent and not IsNil(parent.gameObject) and parent.gameObject.activeInHierarchy
                and cc.ActionManager:GetInstance():targetIsDone(parent) then
            local item = nil
            if guide_step.type == 1 then
                item = GuideItem(parent)
            elseif guide_step.type == 2 then
                item = GuideItem2(panel.transform)
            elseif guide_step.type == 3 then
                item = GuideItem3(panel.transform)
            end
            item:SetData(guide_step, parent)
            table.insert(self.model.items, item)
        end
    end
end

function GuideController:GetNode(panel, arr_node)
    local parent = panel
    arr_node = String2Table(arr_node)
    for i = 1, #arr_node do
        local node = arr_node[i]
        local node_name = node[1]
        if not IsNil(parent.transform) then
            parent = parent.transform:Find(node_name)
            if parent and #node == 2 then
                local index = parent.transform:GetSiblingIndex()
                if index - 1 + node[2] < parent.transform.parent.childCount then
                    parent = parent.parent:GetChild(index - 1 + node[2])
                end
            end
        end
    end
    return parent
end

function GuideController:NextStep(delay)
    for i = 1, #self.model.items do
        self.model.items[i]:destroy()
    end
    self.model.items = {}
    if not self.model.cur_guide then
        return
    end
    local steps = String2Table(self.model.cur_guide.guide_step)
    if self.model.step_index > #steps then
        self.model.guides[self.model.cur_guide.id] = true
        self.model.cur_guide = nil
        TaskModel:GetInstance():ResumeTask(true)
    end
    local function call_back()
        self:ShowGuide()
    end
    if delay > 0 then
        GlobalSchedule:StartOnce(call_back, delay)
    else
        call_back()
    end
end

function GuideController:ClearCurGuide()
    for i = 1, #self.model.items do
        self.model.items[i]:destroy()
    end
    self.model.items = {}
    self.model.cur_guide = nil
    self.model.has_guide = false
end

function GuideController:AddStrongGuide()
    local guide_step = Config.db_guide_step[153]
    local panel = lua_panelMgr:GetPanelByName(guide_step.panel)
    if not self.strong_guide then
        local parent = self:GetNode(panel, guide_step.node)
        self.strong_guide = GuideItem2(panel.transform)
        self.strong_guide:SetData(guide_step, parent)
    end
    local function call_back()
        self:ClearStrongGuide()
    end
    if not self.schedule_id then
        self.schedule_id = GlobalSchedule:StartOnce(call_back, guide_step.sec)
    end
end

function GuideController:ClearStrongGuide()
    if self.strong_guide then
        self.strong_guide:destroy()
        self.strong_guide = nil
    end
    if self.schedule_id then
        GlobalSchedule:Stop(self.schedule_id)
        self.schedule_id = nil
    end
end
