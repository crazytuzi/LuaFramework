-- @Author: lwj
-- @Date:   2019-04-24 16:43:43
-- @Last Modified time: 2019-04-23 16:43:57

FreeGiftSideItem = FreeGiftSideItem or class("FreeGiftSideItem", BaseCloneItem)
local FreeGiftSideItem = FreeGiftSideItem

function FreeGiftSideItem:ctor(parent_node, layer)
    FreeGiftSideItem.super.Load(self)
end

function FreeGiftSideItem:dctor()
    if self.click_event_id then
        self.model:RemoveListener(self.click_event_id)
        self.click_event_id = nil
    end
    if self.update_rd_event_id then
        self.model:RemoveListener(self.update_rd_event_id)
        self.update_rd_event_id = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function FreeGiftSideItem:LoadCallBack()
    self.model = FreeGiftModel.GetInstance()
    self.nodes = {
        "sel_img/sel_name", "bg", "name", "sel_img", "red_con",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.sel_name = GetText(self.sel_name)

    self:AddEvent()
end

function FreeGiftSideItem:AddEvent()
    local function callback()
        self.model:Brocast(FreeGiftEvent.SideItemClick, self.data.act_id)
    end
    AddClickEvent(self.bg.gameObject, callback)

    self.click_event_id = self.model:AddListener(FreeGiftEvent.SideItemClick, handler(self, self.Selected))
    self.update_rd_event_id = self.model:AddListener(FreeGiftEvent.UpdateSuccess, handler(self, self.CheckRD))
end

function FreeGiftSideItem:SetData(data)
    self.data = data
    self.con_gift_data = Config.db_yunying_gift[self.data.act_id]
    self:UpdateView()
end

function FreeGiftSideItem:UpdateView()
    self:CheckRD()
    self:SelDefault()
    self.name.text = self.con_gift_data.desc
    self.sel_name.text = self.con_gift_data.desc
end

function FreeGiftSideItem:CheckRD()
    if self.model:CheckIsShowRDByActId(self.data.act_id) then
        self:SetRedDot(true)
    else
        self:SetRedDot(false)
    end
end

function FreeGiftSideItem:SelDefault()
    if self.data.act_id == self.model.defaut_act_id then
        self.model:Brocast(FreeGiftEvent.SideItemClick, self.data.act_id)
    end
end

function FreeGiftSideItem:Selected(act_id)
    SetVisible(self.sel_img, act_id == self.data.act_id)
    if act_id == self.data.act_id then
        self.red_dot:SetPosition(0, -3)
    else
        self.red_dot:SetPosition(72.5, -14.6)
    end
end

function FreeGiftSideItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetRedDotParam(isShow)
end
