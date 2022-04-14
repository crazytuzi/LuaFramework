-- @Author: lwj
-- @Date:   2020-01-06 15:04:47 
-- @Last Modified time: 2020-01-06 15:04:50

GundamActDayItem = GundamActDayItem or class("GundamActDayItem", BaseCloneItem)
local GundamActDayItem = GundamActDayItem

function GundamActDayItem:ctor(parent_node, layer)
    self.color_str = ""
    GundamActDayItem.super.Load(self)
end

function GundamActDayItem:dctor()
    destroySingle(self.red_dot)
    self.red_dot = nil
    if self.update_rd_event_id then
        self.model:RemoveListener(self.update_rd_event_id)
        self.update_rd_event_id = nil
    end
    if self.sel_event_id then
        self.model:RemoveListener(self.sel_event_id)
        self.sel_event_id = nil
    end
end

function GundamActDayItem:LoadCallBack()
    self.model = GundamActModel.GetInstance()
    self.nodes = {
        "bg", "sel_img", "text_img", "red_con",
    }
    self:GetChildren(self.nodes)
    self.des_img = GetImage(self.text_img)

    self:AddEvent()
end

function GundamActDayItem:AddEvent()
    local function callback()
        if self.cb then
            self.cb(self.data.idx)
        end
    end
    AddClickEvent(self.bg.gameObject, callback)

    self.sel_event_id = self.model:AddListener(GundamActEvent.DayItemClick, handler(self, self.Select))
    self.update_rd_event_id = self.model:AddListener(GundamActEvent.UpdateGundamPanelRD, handler(self, self.HandleUpdateRD))
end

function GundamActDayItem:AddCallBack(cb)
    self.cb = cb
end

function GundamActDayItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function GundamActDayItem:UpdateView()
    SetLocalPositionY(self.transform, self.data.pos_y or 0)
    lua_resMgr:SetImageTexture(self, self.des_img, "gundam_act_image", "gundam_title_" .. self.data.idx, false, nil, false)
    self:HandleUpdateRD()
end

function GundamActDayItem:Select(idx)
    SetVisible(self.sel_img, idx == self.data.idx)
    local str = idx == self.data.idx and "2b3a73" or "FFFFFF"
    local scale = idx == self.data.idx and 1.07 or 1
    if str ~= self.color_str then
        local r, g, b = HtmlColorStringToColor(str)
        SetColor(self.des_img, r, g, b)
        SetLocalScale(self.text_img, scale, scale, scale)
    end
end

function GundamActDayItem:HandleUpdateRD()
    local is_show_rd = self.model:IsShowDayRD(self.data.idx)
    if not is_show_rd then
        is_show_rd = false
    end
    self:SetRedDot(is_show_rd)
end

function GundamActDayItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end