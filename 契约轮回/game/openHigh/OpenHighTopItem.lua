-- @Author: lwj
-- @Date:   2019-07-18 15:59:55  
-- @Last Modified time: 2019-07-18 16:00:01

OpenHighTopItem = OpenHighTopItem or class("OpenHighTopItem", BaseCloneItem)
local OpenHighTopItem = OpenHighTopItem

function OpenHighTopItem:ctor(parent_node, layer)
    OpenHighTopItem.super.Load(self)
end

function OpenHighTopItem:dctor()
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function OpenHighTopItem:LoadCallBack()
    self.model = OpenHighModel.GetInstance()
    self.nodes = {
        "bg", "sel_img", 'des', "red_con","sel_img/Text",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.des1 = GetText(self.Text)

    self:AddEvent()
end

function OpenHighTopItem:AddEvent()
    local function callback()
        local is_data_empty = table.isempty(self.data)
        if is_data_empty or self.model:CheckInfoExsitByActId(self.data.id) == false then
            Notify.ShowText(ConfigLanguage.OpenHigh.PleaseWait)
            return
        end
        self:ClickFun()
    end
    AddClickEvent(self.bg.gameObject, callback)

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(OpenHighEvent.TopItemClick, handler(self, self.Selected))
    self.model_event[#self.model_event + 1] = self.model:AddListener(OpenHighEvent.UpdateTopItemRD, handler(self, self.HandleUpdateTopItemRD))
end

function OpenHighTopItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function OpenHighTopItem:UpdateView()
    if table.isempty(self.data) or self.model:CheckInfoExsitByActId(self.data.id) == false then
        self.des.text = ConfigLanguage.OpenHigh.PleaseWait
        self.des1.text = ConfigLanguage.OpenHigh.PleaseWait
    else
        self.des.text = self.data.name
        self.des1.text = self.data.name
        if self.data.id == self.model.default_sel_theme then
            self:ClickFun()
        end
    end
    self:SetRedDot(self.model.rd_list[self.data.id])
end

function OpenHighTopItem:ClickFun()
    self.model.cur_theme = self.data.id
    self.model:Brocast(OpenHighEvent.TopItemClick, self.data.id)
end

function OpenHighTopItem:Selected(id)
    if not self.data or id == nil then
        return
    end
    SetVisible(self.sel_img, id == self.data.id)
    SetVisible(self.des, id ~= self.data.id)
end

function OpenHighTopItem:HandleUpdateTopItemRD(act_id, is_show)
    if act_id ~= self.data.id then
        return
    end
    self:SetRedDot(is_show)
end

function OpenHighTopItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end