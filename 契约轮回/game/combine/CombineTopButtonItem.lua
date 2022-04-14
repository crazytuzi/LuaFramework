--
-- Created by IntelliJ IDEA.
-- User: jielin
-- Date: 2018/9/26
-- Time: 19:37
-- To change this template use File | Settings | File Templates.
--

CombineTopButtonItem = CombineTopButtonItem or class("CombineTopButtonItem", BaseItem)
local CombineTopButtonItem = CombineTopButtonItem

function CombineTopButtonItem:ctor(parent_node, layer)
    self.abName = "combine"
    self.assetName = "CombineTopButtonItem"
    self.layer = layer

    self.model = CombineModel:GetInstance()
    BaseItem.Load(self)
end

function CombineTopButtonItem:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.update_event_id then
        GlobalEvent:RemoveListener(self.update_event_id)
        self.update_event_id = nil
    end
    if self.udpate_rd_switch_event_id then
        GlobalEvent:RemoveListener(self.udpate_rd_switch_event_id)
        self.udpate_rd_switch_event_id = nil
    end
end

function CombineTopButtonItem:LoadCallBack()
    self.nodes = {
        "Text",
        "Image",
        "sel_img",
        "red_con",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.Text)

    self:AddEvent()
    SetVisible(self.red_con, not self.model.is_hide_combine_rd)
    self:UpdateView()
end

function CombineTopButtonItem:AddEvent()
    local function call_back(target, x, y)
        local TypeId = self.data[1]
        self.model.select_type_id = TypeId
        GlobalEvent:Brocast(CombineEvent.TopButtonClick, TypeId)
    end
    AddClickEvent(self.Image.gameObject, call_back)

    local function callback(is_hide_rd)
        SetVisible(self.red_con, not is_hide_rd)
    end
    self.udpate_rd_switch_event_id = GlobalEvent:AddListener(CombineEvent.UpdateRDSwitch, callback)
    self.update_event_id = GlobalEvent:AddListener(CombineEvent.UpdateCombineArea, handler(self, self.CheckRedDot))
end

function CombineTopButtonItem:CheckRedDot()
    local id = self.data[1]
    local is_show_top_rd = self.model:IsShowTopRdById(id)
    self:SetRedDot(is_show_top_rd)
end

function CombineTopButtonItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self.des.text = data[2]
    end
end

function CombineTopButtonItem:UpdateView()
    self.des.text = self.data[2]
    if self.model.select_type_id == self.data[1] then
        local color_str = self.model.select_type_id == self.data[1] and '8584b0' or 'fefefe'
        self.des.text = string.format(ConfigLanguage.Combine.TopItemText, color_str, self.data[2])

        GlobalEvent:Brocast(CombineEvent.SelectFoldMenuDefault, self.model.select_type_id)
        self.model.default_tog = nil
    end
    self:CheckRedDot()
    if self.is_need_update_select then
        self:Select(self.update_id)
        self.is_need_update_select = false
        self.update_id = nil
    end
end

function CombineTopButtonItem:getWidth()
    return 149
end

function CombineTopButtonItem:Select(id)
    SetVisible(self.sel_img, id == self.data[1])
    if self.des then
        local color_str = id == self.data[1] and '8584b0' or 'fefefe'
        self.des.text = string.format(ConfigLanguage.Combine.TopItemText, color_str, self.data[2])
    else
        self.is_need_update_select = true
        self.update_id = id
    end
end

function CombineTopButtonItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end