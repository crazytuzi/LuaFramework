-- @Author: lwj
-- @Date:   2019-09-20 19:37:38 
-- @Last Modified time: 2019-09-20 19:37:40

NationHighRewaItem = NationHighRewaItem or class("NationHighRewaItem", BaseCloneItem)
local NationHighRewaItem = NationHighRewaItem

function NationHighRewaItem:ctor(parent_node, layer)
    NationHighRewaItem.super.Load(self)
end

function NationHighRewaItem:dctor()
    for i, v in pairs(self.rewa_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rewa_item_list = {}
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function NationHighRewaItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "btn_get/btn_text", "des", "rewa_con", "btn_get", "not_achi", "btn_get/red_con",
    }
    self:GetChildren(self.nodes)
    self.btn_text = GetText(self.btn_text)
    self.des = GetText(self.des)
    self.btn_img = GetImage(self.btn_get)
    self.tag_img = GetImage(self.not_achi)

    self:AddEvent()
    self:SetRedDot(true)
end

function NationHighRewaItem:AddEvent()
    local function callback()
        if self.data.ser_info.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
            return
        end
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.cf.act_id, self.data.cf.id, self.data.cf.level)
    end
    AddButtonEvent(self.btn_get.gameObject, callback)
end

function NationHighRewaItem:SetData(data, stencil_id, stencil_type)
    self.stencil_id = stencil_id
    self.data = data
    self.stencil_type = stencil_type
    self:UpdateView()
end

function NationHighRewaItem:UpdateView()
    self.des.text = string.format(ConfigLanguage.OpenHigh.SaveProgressCanGet, self.data.ser_info.count, self.data.cf.desc)
    self:LoadReward()
    local state = self.data.ser_info.state
    if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        lua_resMgr:SetImageTexture(self, self.tag_img, "common_image", "img_have_not_Reach_2", true, nil, false)
        SetVisible(self.btn_get, false)
        SetVisible(self.not_achi, true)
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        SetVisible(self.not_achi, false)
        SetVisible(self.btn_get, true)
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
        self.btn_text.text = ConfigLanguage.OpenHigh.BtnFetchText
        self.btn_img.raycastTarget = true
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        lua_resMgr:SetImageTexture(self, self.tag_img, "common_image", "img_have_received_1", false, nil, false)
        SetVisible(self.btn_get, false)
        SetVisible(self.not_achi, true)
    end

end

function NationHighRewaItem:LoadReward()
    local list = String2Table(self.data.cf.reward)
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.rewa_con)
            self.rewa_item_list[i] = item
        end
        item:SetVisible(false)
        local param = {}
        local operate_param = {}
        local item_id = list[i][1]
        param["item_id"] = item_id
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["num"] = list[i][2]
        param['size'] = { x = 60, y = 60 }
        if type(item_id) == "table" then
            item_id = item_id[1]
        end
        local cf = Config.db_item[item_id]
        local color = cf.color
        if color >= 6 then
            color = color - 1
            param["color_effect"] = color
            param["effect_type"] = 2  --活动特效：2
        end
        param['stencil_id'] = self.stencil_id
        param['stencil_type'] = self.stencil_type
        item:SetIcon(param)
        item:SetVisible(true)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function NationHighRewaItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end