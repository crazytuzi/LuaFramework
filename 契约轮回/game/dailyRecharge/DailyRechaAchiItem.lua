-- @Author: lwj
-- @Date:   2019-04-04 16:08:37 
-- @Last Modified time: 2019-04-04 16:08:58

DailyRechaAchiItem = DailyRechaAchiItem or class("DailyRechaAchiItem", BaseCloneItem)
local DailyRechaAchiItem = DailyRechaAchiItem

function DailyRechaAchiItem:ctor(parent_node, layer)
    DailyRechaAchiItem.super.Load(self)
end

function DailyRechaAchiItem:dctor()
    self:DestroyGoodsIcon()
    for i, v in pairs(self.global_event) do
        GlobalEvent:RemoveListener(v)
    end
    self.global_event = {}
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function DailyRechaAchiItem:LoadCallBack()
    self.model = DailyRechargeModel.GetInstance()
    self.nodes = {
        "title", "btn_get/btn_get_text", "icon", "btn_get",
        "rewarded", "red_con",
    }
    self:GetChildren(self.nodes)
    self.title = GetText(self.title)
    self.btn_text = GetText(self.btn_get_text)
    self.btn_img = GetImage(self.btn_get)

    self.btn_mode = 0       --0: 未达成    1:未领取   2:已领取

    self:AddEvent()
end

function DailyRechaAchiItem:AddEvent()
    local function callback()
        if self.btn_mode == 0 then
            Notify.ShowText(ConfigLanguage.DailyRecharge.NotEnoughToGetTip)
        elseif self.btn_mode == 1 then
            --可领取
            GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.data.act_id, self.data.id, self.data.level)
        end
    end
    AddClickEvent(self.btn_get.gameObject, callback)

    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuccessRewarded))
end

function DailyRechaAchiItem:DestroyGoodsIcon()
    if self.itemIcon then
        self.itemIcon:destroy()
        self.itemIcon = nil
    end
end

function DailyRechaAchiItem:HandleSuccessRewarded(data)
    if data.id ~= self.data.id or data.act_id ~= self.data.act_id then
        return
    end
    self:SetGetted()
    self.model:RemoveAchiRDById(self.data.id)
    self:UpdateRD()
    self.model:Brocast(DailyRechargeEvent.CheckRD)
end

function DailyRechaAchiItem:SetData(data)
    self.data = data
    self.info_data = self.model:GetAchiInfoByIndex(self.data.level)
    self:UpdateView()
end

function DailyRechaAchiItem:UpdateView()
    self:DestroyGoodsIcon()
    local des_tbl = String2Table(self.data.desc)
    local days = des_tbl[1]
    local target = des_tbl[2]
    local is_finish = 0
    if self.info_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH or self.info_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        is_finish = 1
    end
    self.title.text = string.format(ConfigLanguage.DailyRecharge.AchiTextShow, days, target, is_finish, 1)
    local tbl = String2Table(self.data.reward)
    local param = {}
    local operate_param = {}
    local cfg = Config.db_item[tbl[1][1]]
    param["cfg"] = cfg
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 60, y = 60 }
    local color = Config.db_item[tbl[1][1]].color - 1
    param["color_effect"] = color
    --param["effect_type"] = 2
    self.itemIcon = GoodsIconSettorTwo(self.icon)
    self.itemIcon:SetIcon(param)
    --更新按钮
    local state = self.info_data.state
    if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        --未完成
        self.btn_mode = 0
        ShaderManager.GetInstance():SetImageGray(self.btn_img)
        self.btn_text.text = ConfigLanguage.DailyRecharge.NotEnoughToGet
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        self.btn_mode = 1
        ShaderManager.GetInstance():SetImageNormal(self.btn_img)
        self.btn_text.text = ConfigLanguage.DailyRecharge.CanGetReward
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        self:SetGetted()
    end
    self:UpdateRD()
end

function DailyRechaAchiItem:SetGetted()
    self.btn_mode = 2
    SetVisible(self.btn_get, false)
    self:SetRedDot(false)
    SetVisible(self.rewarded, true)
end

function DailyRechaAchiItem:UpdateRD()
    if self.model:CheckAchiRDById(self.data.id) then
        self:SetRedDot(true)
    else
        self:SetRedDot(false)
    end
end

function DailyRechaAchiItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end