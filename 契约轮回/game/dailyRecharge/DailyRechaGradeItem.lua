-- @Author: lwj
-- @Date:   2019-03-30 16:01:46
-- @Last Modified time: 2019-03-30 16:01:46

DailyRechaGradeItem = DailyRechaGradeItem or class("DailyRechaGradeItem", BaseCloneItem)
local DailyRechaGradeItem = DailyRechaGradeItem

function DailyRechaGradeItem:ctor(parent_node, layer)
    DailyRechaGradeItem.super.Load(self)
end

function DailyRechaGradeItem:dctor()
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function DailyRechaGradeItem:LoadCallBack()
    self.model = DailyRechargeModel.GetInstance()
    self.nodes = {
        "sel_img", "bg", "des", "red_con",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
end

function DailyRechaGradeItem:AddEvent()
    local function callback()
        self.model.cur_sel_data = self.data
        self.model:Brocast(DailyRechargeEvent.DailyRechargeGradeItemClick, self.data, self.info_data)
    end
    AddClickEvent(self.bg.gameObject, callback)

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(DailyRechargeEvent.DailyRechargeGradeItemClick, handler(self, self.Select))
    self.model_event[#self.model_event + 1] = self.model:AddListener(DailyRechargeEvent.UpdateGradeItemRD, handler(self, self.UpdateRD))
end

function DailyRechaGradeItem:SetData(data)
    self.data = data
    self.info_data = self.model:GetDailyInfoByIndex(self.data.level)
    --dump(self.info_data, "<color=#6ce19b>InfoData   InfoData  InfoData  InfoData</color>")
    self:UpdateView()
end

function DailyRechaGradeItem:UpdateView()
    self.data.target = tonumber(self.data.desc)
    if self.data.pos_index == self.model.default_sel_index then
        self.model.cur_sel_data = self.data
        self.model:Brocast(DailyRechargeEvent.DailyRechargeGradeItemClick, self.data, self.info_data)
    end
    if not self.info_data then
        return
    end
    local cur_recha = self.info_data.count
    self.des.text = string.format(ConfigLanguage.DailyRecharge.GradeBtnShowText, self.data.desc, cur_recha, tonumber(self.data.desc))
    self:UpdateRD()
end

function DailyRechaGradeItem:Select(data)
    SetVisible(self.sel_img, data.id .. data.level == self.data.id .. self.data.level)
end

function DailyRechaGradeItem:UpdateRD()
    if self.model:CheckGradeRDById(self.data.id) then
        self:SetRedDot(true)
    else
        self:SetRedDot(false)
    end
end

function DailyRechaGradeItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end
