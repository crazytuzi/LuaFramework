-- @Author: lwj
-- @Date:   2020-01-06 17:00:20
-- @Last Modified time: 2020-01-08 19:31:10

GundamActTaskItem = GundamActTaskItem or class("GundamActTaskItem", BaseCloneItem)
local GundamActTaskItem = GundamActTaskItem

function GundamActTaskItem:ctor(parent_node, layer)
    self.btn_mode = 1           --1：跳转  2：领取    3：已领取

    GundamActTaskItem.super.Load(self)
end

function GundamActTaskItem:dctor()
    destroySingle(self.red_dot)
    self.red_dot = nil
    if self.update_rd_event_id then
        self.model:RemoveListener(self.update_rd_event_id)
        self.update_rd_event_id = nil
    end
    if self.succ_fetch_event_id then
        GlobalEvent:RemoveListener(self.succ_fetch_event_id)
        self.succ_fetch_event_id = nil
    end
    destroyTab(self.rewa_item_list, true)
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function GundamActTaskItem:LoadCallBack()
    self.model = GundamActModel.GetInstance()
    self.nodes = {
        "des", "Rewa_Scroll/Viewport", "button/btn_text", "Rewa_Scroll/Viewport/rewa_con", "button", "title",
        "button/red_con",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.btn_text = GetText(self.btn_text)
    self.btn_img = GetImage(self.button)

    SetLocalPositionXY(self.red_con, 48, 18)

    self:SetMask()
    self:AddEvent()
end

function GundamActTaskItem:AddEvent()
    local function callback()
        if self.btn_mode == 1 then
            --if self.data.id == 8 or self.data.id == 12 then
                --Notify.ShowText("该功能尚未开放")
                --return
            --end
            local list = String2Table(self.data.sundries)
            OpenLink(unpack(list[2]))
            self.model:Brocast(GundamActEvent.ClosePanel)
        elseif self.btn_mode == 2 then
            GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
        end
    end
    AddButtonEvent(self.button.gameObject, callback)

    self.succ_fetch_event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleFetchSucc))
    local function callback()
        self:CheckRDShow()
    end
    self.update_rd_event_id = self.model:AddListener(GundamActEvent.UpdateGundamPanelRD, callback)
end

function GundamActTaskItem:CheckRDShow()
    local is_show_rd = self.model:IsShowRewaRD(self.data.act_id, self.data.id)
    if not is_show_rd then
        is_show_rd = false
    end
    self:SetRedDot(is_show_rd)
end

function GundamActTaskItem:SetData(data)
    self.data = data
    dump(data.id, "<color=#6ce19b>GundamActTaskItem   GundamActTaskItem  GundamActTaskItem  GundamActTaskItem</color>")
    self:UpdateView()
    self:SetSerData()
end

function GundamActTaskItem:SetSerData()
    self.ser_data = self.model:GetInfoByRewaId(self.data.act_id, self.data.id)
    if (not self.ser_data) or (RoleInfoModel.GetInstance():GetMainRoleLevel() < 180) then
        self.ser_data = {}
        self.ser_data.state = 0
    end
    self:UpdateState()
end

function GundamActTaskItem:UpdateView()
    self.des.text = self.data.desc
    SetVisible(self.title, self.data.idx == 1)
    self:LoadRewa()
    self:CheckRDShow()
end

function GundamActTaskItem:LoadRewa()
    self.rewa_item_list = self.rewa_item_list or {}
    local list = String2Table(self.data.reward)
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.rewa_con)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local rewa_data = list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = rewa_data[1]
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 64, y = 64 }
        param["num"] = rewa_data[2]
        param.bind = rewa_data[3]
        local color = Config.db_item[rewa_data[1]].color - 1
        param["color_effect"] = color
        param["effect_type"] = 2  --活动特效：2
        param["stencil_id"] = self.StencilId
        param["stencil_type"] = 3
        item:SetIcon(param)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function GundamActTaskItem:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function GundamActTaskItem:UpdateState()
    local str = "Go"
    self.btn_mode = 1
    local is_normal = true
    if self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        self.btn_mode = 2
        str = "Claim"
    elseif self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        self.btn_mode = 3
        is_normal = false
        str = "Claimed"
    elseif self.ser_data.state == 0 then
        self.btn_mode = 4
        is_normal = false
        str = "Level too low"
    end
    self.btn_text.text = str
    if is_normal then
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
    else
        ShaderManager:GetInstance():SetImageGray(self.btn_img)
    end
end

function GundamActTaskItem:HandleFetchSucc(data)
    if self.data.act_id ~= data.act_id or self.data.id ~= data.id then
        return
    end
    self.ser_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
    self:UpdateState()

    if self.model.rd_list[self.data.act_id] then
        self.model.rd_list[self.data.act_id][self.data.id] = nil
        self.model:Brocast(GundamActEvent.UpdateGundamPanelRD)
        --GlobalEvent:Brocast(GundamActEvent.UpdateGundamIconRD, is_show_icon_rd)
        self.model:IsShowMainRD()
    end
end

function GundamActTaskItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end