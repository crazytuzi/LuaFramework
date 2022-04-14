SecondMenuItem = SecondMenuItem or class("SecondMenuItem", BaseTreeTwoMenu)
local SecondMenuItem = SecondMenuItem

function SecondMenuItem:ctor(parent_node, layer, first_menu_item)
    self.abName = "system"
    self.assetName = "SecondMenuItem"
    self.layer = layer
    self.first_menu_item = first_menu_item
    self.parent_cls_name = self.first_menu_item.parent_cls_name

    --self.globalEvents = {}
    --self.select_sub_id = -1
    -- self.model=CombineModel.GetInstance()
    SecondMenuItem.super.Load(self)
end

function SecondMenuItem:dctor()
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
    SecondMenuItem.super.dctor(self)
end

function SecondMenuItem:AddEvent()
    local function callback(is_hide_rd)
        SetVisible(self.red_con, not is_hide_rd)
    end
    self.udpate_rd_switch_event_id = GlobalEvent:AddListener(CombineEvent.UpdateRDSwitch, callback)
    self.update_event_id = GlobalEvent:AddListener(CombineEvent.UpdateCombineArea, handler(self, self.CheckRedDot))
    SecondMenuItem.super.AddEvent(self)
end

function SecondMenuItem:LoadCallBack()
    self.nodes = {
        "red_con",
    }
    self:GetChildren(self.nodes)
    SecondMenuItem.super.LoadCallBack(self)
end

function SecondMenuItem:ShowPanel()
    SetVisible(self.red_con, not CombineModel.GetInstance().is_hide_combine_rd)
    if self.data then
        if self.Text then
            self.Text:GetComponent('Text').text = self.data[2]
        end
        self:Select(self.select_sub_id)
        self:CheckRedDot()
    end
end

function SecondMenuItem:CheckRedDot()
    local star_id = self.data[1]
    local red_List = CombineModel.GetInstance():GetStarRDList(star_id)
    local is_show_red = false
    if red_List and (not table.isempty(red_List)) then
        for i, v in pairs(red_List) do
            if v then
                is_show_red = true
                break
            end
        end
    end
    self:SetRedDot(is_show_red)
    return is_show_red
end

function SecondMenuItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end