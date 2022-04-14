-- @Author: lwj
-- @Date:   2019-09-04 16:57:32 
-- @Last Modified time: 2019-09-04 16:57:35

NationMenuItem = NationMenuItem or class("NationMenuItem", BaseCloneItem)
local NationMenuItem = NationMenuItem

function NationMenuItem:ctor(parent_node, layer)
    NationMenuItem.super.Load(self)
end

function NationMenuItem:dctor()
    if self.upadate_page_event_id then
        self.model:RemoveListener(self.upadate_page_event_id)
        self.upadate_page_event_id = nil
    end
    if self.click_event_id then
        self.model:RemoveListener(self.click_event_id)
        self.click_event_id = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function NationMenuItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "sel_img", "name", "Bg", "red_con",
    }
    self:GetChildren(self.nodes)
    self.name_out_line = GetOutLine(self.name)
    self.name = GetText(self.name)

    self:AddEvent()
end

function NationMenuItem:AddEvent()
    self.click_event_id = self.model:AddListener(NationEvent.MenuItemClick, handler(self, self.Select))
    self.upadate_page_event_id = self.model:AddListener(NationEvent.UpdatePageShow, handler(self, self.HandleUpdatePage))

    AddClickEvent(self.Bg.gameObject, handler(self, self.ClickFun))
end

function NationMenuItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function NationMenuItem:UpdateView()
    self.name.text = self.data.name
    self:CheckDefault()
end

function NationMenuItem:HandleUpdatePage(act_id)
    if self.data.id == act_id then
        self:ClickFun()
    end
end

function NationMenuItem:CheckDefault()
    if not self.model.default_sel_menu then
        if self.data.idx == 1 then
            self:ClickFun()
        end
    elseif self.data.id == self.model.default_sel_menu then
        self:ClickFun()
    end
end

function NationMenuItem:ClickFun()
    self.model:Brocast(NationEvent.MenuItemClick, self.data.id)
end

function NationMenuItem:Select(id)
    local is_equal = self.data.id == id
    local rgb_tbl = is_equal and { 255, 155, 67, 255 } or { 41, 103, 156, 255 }
    SetOutLineColor(self.name_out_line, unpack(rgb_tbl))
    SetVisible(self.sel_img, self.data.id == id)
end

function NationMenuItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end