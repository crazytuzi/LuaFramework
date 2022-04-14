-- @Author: lwj
-- @Date:   2019-09-26 22:10:55 
-- @Last Modified time: 2019-09-26 22:10:58

NationEggRewaItem = NationEggRewaItem or class("NationEggRewaItem", BaseCloneItem)
local NationEggRewaItem = NationEggRewaItem

function NationEggRewaItem:ctor(parent_node, layer)
    NationEggRewaItem.super.Load(self)
end

function NationEggRewaItem:dctor()
    if self.update_count_show_event_id then
        self.model:RemoveListener(self.update_count_show_event_id)
        self.update_count_show_event_id = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.item then
        self.item:destroy()
        self.item = nil
    end
    if self.success_exchange_event_id then
        GlobalEvent:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
end

function NationEggRewaItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "item_con", "count", "btn_get", "btn_get/red_con", "btn_gray", "btn_gray/gray_text", "tag",
    }
    self:GetChildren(self.nodes)
    self.count = GetText(self.count)
    self.gray_text = GetText(self.gray_text)

    self:AddEvent()
    self:SetRedDot(true)
end

function NationEggRewaItem:AddEvent()
    local function callback()
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
    end
    AddButtonEvent(self.btn_get.gameObject, callback)

   self:RegistEvent()
end


function NationEggRewaItem:SetData(data)
    self.data = data
    self.ser_data = self.model:GetSingleTaskInfo(self.data.act_id, self.data.id)
    self:UpdateView()
end

function NationEggRewaItem:UpdateView()
    local rewa_cf = String2Table(self.data.reward)[1]
    local param = {}
    local operate_param = {}
    local item_id = rewa_cf[1]
    local num = rewa_cf[2]
    param["item_id"] = item_id
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 68, y = 68 }
    param["num"] = num
    param.bind = rewa_cf[3]
    self.count.text = string.format(ConfigLanguage.Nation.RewardCount, self.data.task)
    local is_set_icon_gray = false
    if self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        SetVisible(self.btn_get, false)
        SetVisible(self.btn_gray, true)
        self.gray_text.text = ConfigLanguage.Nation.Fetch_2
    elseif self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        SetVisible(self.btn_get, true)
        SetVisible(self.btn_gray, false)
        self.gray_text.text = ConfigLanguage.Nation.Fetch_2
        local color = Config.db_item[item_id].color - 1
        param["color_effect"] = color
        param["effect_type"] = 2  --活动特效：2
    elseif self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        SetVisible(self.btn_get, false)
        SetVisible(self.btn_gray, true)
        self.gray_text.text = ConfigLanguage.Nation.AlreadyFetch
        is_set_icon_gray = true
    end
    if not self.item then
        self.item = GoodsIconSettorTwo(self.item_con)
    end
    self.item:SetIcon(param)
    if is_set_icon_gray then
        self.item:SetIconGray()
    else
        self.item:SetIconNormal()
    end
    SetVisible(self.tag, is_set_icon_gray)
end

function NationEggRewaItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function NationEggRewaItem:HandleSuccessExchange(data)
    if not self.model:IsSelfAct(data.act_id) then
        return
    end
    if data.id == self.data.id then
        self.ser_data.count = self.ser_data.count + 1
        self.ser_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
    end
    self:UpdateView()
end

function NationEggRewaItem:HandleUpdateState()
    local info = self.model:GetEggCrackInfo()
    local cur_crack = info.crack
    if cur_crack >= tonumber(self.data.task) and self.ser_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        self.ser_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_FINISH
        self:UpdateView()
    end
end

--注册事件监听
function NationEggRewaItem:RegistEvent(  )
    self.success_exchange_event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuccessExchange))
    self.update_count_show_event_id = self.model:AddListener(NationEvent.UpdateEggRewaShow, handler(self, self.HandleUpdateState))
end

--注销事件监听
function NationEggRewaItem:UnregistEvent(  )
    if self.success_exchange_event_id then
        GlobalEvent:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
  
    if self.update_count_show_event_id then
        self.model:RemoveListener(self.update_count_show_event_id)
    self.update_count_show_event_id = nil
    end
    
end