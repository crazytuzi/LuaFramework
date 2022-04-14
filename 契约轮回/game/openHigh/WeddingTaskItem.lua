-- @Author: lwj
-- @Date:   2019-08-01 16:56:23 
-- @Last Modified time: 2019-08-01 16:56:25

WeddingTaskItem = WeddingTaskItem or class("WeddingTaskItem", BaseCloneItem)
local WeddingTaskItem = WeddingTaskItem

function WeddingTaskItem:ctor(parent_node, layer)
    WeddingTaskItem.super.Load(self)
end

function WeddingTaskItem:dctor()
    if self.success_exchange_event_id then
        self.model:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if not table.isempty(self.rewa_item_list) then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end
end

function WeddingTaskItem:LoadCallBack()
    self.model = OpenHighModel.GetInstance()
    self.nodes = {
        "deco_bg", "des", "tag", "btn_get", "item_con", "btn_get/red_con", "btn_go",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.tag = GetImage(self.tag)

    self:AddEvent()
    self:SetRedDot(true)
end

function WeddingTaskItem:AddEvent()
    local function callback()
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
    end
    AddButtonEvent(self.btn_get.gameObject, callback)

    local function callback()
        if not OpenTipModel.GetInstance():IsOpenSystem(1200, 2) then
            local sys_cf = Config.db_sysopen['1200@2']
            if sys_cf then
                local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
                if sys_cf.task == 0 then
                    local lv = GetLevelShow(sys_cf.level)
                    Notify.ShowText(string.format(ConfigLanguage.LevelShow.LevelLimit, lv))
                    --有任务
                else
                    if cur_lv >= sys_cf.level then
                        local name = Config.db_task[sys_cf.task].name
                        Notify.ShowText(string.format(ConfigLanguage.LevelShow.TaskLimit, name))
                    else
                        Notify.ShowText(ConfigLanguage.LevelShow.SystemNotOpen)
                    end
                end
            end
            return
        end
        lua_panelMgr:GetPanelOrCreate(MarryPropPanel):Open()
        self.model:Brocast(OpenHighEvent.CloseOpenHighPanel)
    end
    AddButtonEvent(self.btn_go.gameObject, callback)

    self.success_exchange_event_id = self.model:AddListener(OpenHighEvent.SuccessFetchRewa, handler(self, self.HandleSuccessExchange))
end

function WeddingTaskItem:SetData(data)
    self.data = data
    self.ser_data = self.model:GetSingleTaskInfo(self.data.act_id, self.data.id)
    --dump(self.ser_data, "<color=#6ce19b>WeddingTaskItem   WeddingTaskItem  WeddingTaskItem  WeddingTaskItem</color>")
    self:UpdateView()
end

function WeddingTaskItem:UpdateView()
    SetVisible(self.deco_bg, self.data.index == 1)
    local pro_str = " （%s</color>/1）"
    local num = self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE and "<color=#e61020>0" or "<color=#6ff745>1"
    local num_str = string.format(pro_str, num)
    self.des.text = self.data.name .. num_str
    local state = self.ser_data.state
    local show_model = 2        --1:未完成     2:已完成   3:已领取
    if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        lua_resMgr:SetImageTexture(self, self.tag, "openHigh_image", "not_achi", false, nil, false)
        show_model = 1
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        lua_resMgr:SetImageTexture(self, self.tag, "common_image", "finished_1", false, nil, false)
        show_model = 3
    end
    SetVisible(self.tag, show_model == 3)
    SetVisible(self.btn_get, show_model == 2)
    SetVisible(self.btn_go, show_model == 1)

    local list = String2Table(self.data.reward)
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.item_con)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local sin_data = list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = sin_data[1]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 70, y = 70 }
        param["num"] = sin_data[2]
        param.bind = 2
        item:SetIcon(param)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function WeddingTaskItem:HandleSuccessExchange(data)
    if data.act_id ~= self.data.act_id or self.data.id ~= data.id then
        return
    end
    self.ser_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
    self:UpdateView()
end

function WeddingTaskItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end
