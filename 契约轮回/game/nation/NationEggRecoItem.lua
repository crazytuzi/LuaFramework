-- @Author: lwj
-- @Date:   2019-09-25 11:08:41
-- @Last Modified time: 2019-09-24 11:08:44

NationEggRecoItem = NationEggRecoItem or class("NationEggRecoItem", BaseCloneItem)
local NationEggRecoItem = NationEggRecoItem

function NationEggRecoItem:ctor(parent_node, layer)
    self.single_reco_height = 47
    self.single_move_duration = 0.05       --移动到下一条记录位置的时间

    NationEggRecoItem.super.Load(self)
end

function NationEggRecoItem:dctor()
    if self.start_act_event_id then
        self.model:RemoveListener(self.start_act_event_id)
        self.start_act_event_id = nil
    end
    if self.first_action then
        cc.ActionManager:GetInstance():removeAction(self.first_action)
        self.first_action = nil
    end
    if self.repeate_act then
        cc.ActionManager:GetInstance():removeAction(self.repeate_act)
        self.repeate_act = nil
    end
end

function NationEggRecoItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "des",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.rect_trans = GetRectTransform(self)

    self:AddEvent()
end

function NationEggRecoItem:AddEvent()
    self.start_act_event_id = self.model:AddListener(NationEvent.StartMoveReco, handler(self, self.StartMoveAct))
end

function NationEggRecoItem:SetData(data, end_y, start_y, sum_count)
    self.data = data
    self.end_y = end_y
    self.start_y = start_y
    self.sum_count = sum_count
    self:UpdateView()
end

function NationEggRecoItem:UpdateView()
    local item_cf = Config.db_item[self.data.item_id]
    local item_name = item_cf.name
    local item_color = item_cf.color
    local color_code = ColorUtil.GetColor(item_color)
    self.des.text = string.format(ConfigLanguage.Nation.CrackEggRecoText, self.data.role_name, color_code, item_name)
    SetAnchoredPosition(self.rect_trans, self.rect_trans.anchoredPosition.x, self.start_y)
end

function NationEggRecoItem:StartMoveAct()
    local cur_pos = self.rect_trans.anchoredPosition
    local end_pos = Vector2(0, self.end_y)
    local first_move_dis = Vector2.Distance(cur_pos, end_pos)
    local first_duration = first_move_dis * self.single_move_duration
    self.first_action = cc.MoveTo(first_duration, 0, self.end_y, 0)
    self.reset_y = (self.sum_count - 1) * -self.single_reco_height
    local function end_callback()
        cc.ActionManager:GetInstance():removeAction(self.first_action)
        SetAnchoredPosition(self.rect_trans, self.rect_trans.anchoredPosition.x, self.reset_y)
        self:RepeatAction()
        self.first_action = nil
    end
    local end_action = cc.CallFunc(end_callback)
    self.first_action = self:ComboAction(self.first_action, end_action)
    cc.ActionManager:GetInstance():addAction(self.first_action, self.transform)
end

function NationEggRecoItem:RepeatAction()
    local cur_pos = self.rect_trans.anchoredPosition
    local end_pos = Vector2(0, self.end_y)
    local first_move_dis = Vector2.Distance(cur_pos, end_pos)
    local duration = first_move_dis * self.single_move_duration
    self.repeate_act = cc.MoveTo(duration, 0, self.end_y, 0)
    local function end_callback()
        SetAnchoredPosition(self.rect_trans, self.rect_trans.anchoredPosition.x, self.reset_y)
    end
    local end_action = cc.CallFunc(end_callback)
    self.repeate_act = self:ComboAction(self.repeate_act, end_action)

    self.repeate_act = cc.RepeatForever(self.repeate_act)
    cc.ActionManager:GetInstance():addAction(self.repeate_act, self.transform)
end

function NationEggRecoItem:ComboAction(action1, action2)
    if action1 and action2 then
        return cc.Sequence(action1, action2)
    elseif not action1 then
        return action2
    elseif not action2 then
        return action1
    end
end

function NationEggRecoItem:StopMove()
    if self.first_action then
        cc.ActionManager:GetInstance():removeAction(self.first_action)
        self.first_action = nil
    end
    if self.repeate_act then
        cc.ActionManager:GetInstance():removeAction(self.repeate_act)
        self.repeate_act = nil
    end
end

function NationEggRecoItem:GetYPos()
    return self.rect_trans.anchoredPosition.y
end

function NationEggRecoItem:AdjustPos(offset)
    SetAnchoredPosition(self.rect_trans, self.rect_trans.anchoredPosition.x, self.rect_trans.anchoredPosition.y + offset)
end