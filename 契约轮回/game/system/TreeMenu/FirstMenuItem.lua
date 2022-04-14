FirstMenuItem = FirstMenuItem or class("FirstMenuItem", BaseTreeOneMenu)
local FirstMenuItem = FirstMenuItem

function FirstMenuItem:ctor(parent_node, layer, parent_cls_name)
    self.abName = "system"
    self.assetName = "FirstMenuItem"
    --self.layer = layer
    --self.parent_cls_name = parent_cls_name
    self.twoLvMenuCls = SecondMenuItem

    FirstMenuItem.super.Load(self)
end

function FirstMenuItem:dctor()
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
    FirstMenuItem.super.dctor(self)
end

function FirstMenuItem:LoadCallBack()
    self.nodes = {
        "red_content",
    }
    self:GetChildren(self.nodes)
    SetVisible(self.red_content, not CombineModel.GetInstance().is_hide_combine_rd)
    FirstMenuItem.super.LoadCallBack(self)
end

function FirstMenuItem:AddEvent()
    self.update_event_id = GlobalEvent:AddListener(CombineEvent.UpdateCombineArea, handler(self, self.CheckRedDot))
    local function callback(is_hide_rd)
        SetVisible(self.red_content, not is_hide_rd)
    end
    self.udpate_rd_switch_event_id = GlobalEvent:AddListener(CombineEvent.UpdateRDSwitch, callback)
    FirstMenuItem.super.AddEvent(self)
end

function FirstMenuItem:CheckRedDot()
    local typeId = self.data[1]
    local is_show_red = CombineModel.GetInstance():IsShowStairRdById(typeId)
    self:SetRedDot(is_show_red)
    return is_show_red
end

function FirstMenuItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_content, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end