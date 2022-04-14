--
-- @Author: LaoY
-- @Date:   2019-01-28 16:41:22
--

PowerChange = PowerChange or class("PowerChange", BasePanel)

function PowerChange:ctor()
    self.abName = "main"
    self.assetName = "PowerChange"
    self.layer = LayerManager.LayerNameList.Top

    self.is_exist_always = true

    self.logout_close = false

    self.use_background = false
    self.change_scene_close = false
    self.max_item_count = 10
    self.last_add_time = -10
    self.last_index = self.max_item_count
    self.item_list = {}
end

function PowerChange:dctor()
    self:StopAction()
    self:StopTime()

    if self.effect then
        self.effect:destroy();
    end
    self.effect = nil;

    if self.action then
        self.action:destroy()
        self.action = nil
    end
end

function PowerChange:Open(old_power, new_power, attr_list)

    -- Yzprint('--LaoY PowerChange.lua,line 45--',old_power, new_power)
    -- Yzdump(attr_list,"attr_list")

    self.last_add_power_time = Time.time

    self.old_power = old_power
    self.new_power = new_power
    self.attr_list = attr_list
    PowerChange.super.Open(self)
end

function PowerChange:ChangeAttr(old_power, new_power, attr_list)

    Yzprint('--LaoY PowerChange.lua,line 56--',old_power, new_power,self.is_exist_always and not self.isShow and self.is_loaded)
    Yzdump(attr_list,"attr_list")

    -- if self.is_exist_always and not self.isShow and self.is_loaded then
    if not self.isShow then
        self:Open(old_power, new_power, attr_list)
        return
    end
    if not table.isempty(attr_list) then
        if self.attr_list then
            for k, v in pairs(attr_list) do
                table.insert(self.attr_list, v)
            end
        else
            self.attr_list = attr_list
        end
    end
    if Time.time > self.last_add_power_time then
        self.old_power = old_power or 0
    end
    self.last_add_power_time = Time.time
    if not self.old_power and old_power then
        self.old_power = old_power
    end
    if not self.new_power or (new_power and new_power >= self.new_power) then
        self.new_power = new_power
        if self.is_loaded then
            self:PlayEffect()
            self:UpdateView()
        end
    end
end

function PowerChange:LoadCallBack()
    self.nodes = {
        "EffectParent", "img_power_bg/text_power", "img_power_bg/text_add_power", "img_power_bg", "PowerChangeText","img_power_bg/add"
    }
    self:GetChildren(self.nodes)

    self.text_power_component = self.text_power:GetComponent('Text')
    self.text_add_power_component = self.text_add_power:GetComponent('Text')

    self.power_pos_x = GetLocalPositionX(self.text_power)

    self.PowerChangeText_gameObject = self.PowerChangeText.gameObject
    SetVisible(self.PowerChangeText, false)

    --local orderIndex = LayerManager:GetInstance():GetLayerOrderByName(self.layer)

    local _, orderIndex = GetParentOrderIndex(self.gameObject)
  --  UIDepth.SetOrderIndex(self.img_power_bg.gameObject, true, orderIndex + 60)

    --self.textCanvas.sortingOrder = orderIndex + 5

    -- self:AddEffect()
    self:AddEvent()
end

function PowerChange:AddEffect()

    if (self.old_power > self.new_power) then
        return
    end
    if not self.effect or self.effect.is_dctored then
        self.effect = UIEffect(self.EffectParent, 10112, false, self.layer);
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.text_power.transform, nil, true, nil, false, 20)
       -- LayerManager.GetInstance():AddOrderIndexByCls(self, self.text_add_power.transform, nil, true, nil, false, 30)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.add.transform, nil, true, nil, false, 30)
    end
end

function PowerChange:AddEvent()

end

function PowerChange:OpenCallBack()
    self:UpdateView()
    self:StartTime()
    self:PlayEffect()
end

function PowerChange:UpdateView()
    if not self.old_power or not self.new_power or self.old_power > self.new_power then
        self.new_power = 0
        SetVisible(self.img_power_bg, false)
        return
    end
    -- if self.action and not self.action:isDone() and self.action.cur_num then
    --     self.old_power = math.floor(self.action.cur_num)
    -- end
    SetVisible(self.img_power_bg, true)
    self.text_power_component.text = self.new_power
    local width = self.text_power_component.preferredWidth
    SetLocalPositionX(self.text_add_power, self.power_pos_x + width + 10)
    self.text_power_component.text = self.old_power
    self.text_add_power_component.text = "a" .. (self.new_power - self.old_power)
    self:StartAction()
end

function PowerChange:PlayEffect()

    if (self.old_power > self.new_power) then
        return
    end

    if self.effect then
        self.effect:destroy()
        self.effect = nil
    end

    if (self.effect and self.effect.is_loaded) then
       self.effect:SetVisible(false)
       self.effect:SetVisible(true)
    else
        self:AddEffect()
    end
end

function PowerChange:OnDisable()
    self:StopAction()
    self:StopTime()
end

function PowerChange:StartAction()
    self.action_state = true
    self:StopAction()
   -- local number_action = cc.NumberTo(0.5, self.old_power, self.new_power, true, "%s", self.text_power_component)
    local number_action = cc.NumberTo(0.5, 0, self.new_power - self.old_power, true, "%s", self.text_power_component)
    self.action = number_action
    local action = cc.Sequence(cc.DelayTime(0.02), number_action)
    local function end_call_back()
        self.action_state = false
        SetVisible(self.img_power_bg, false)
    end
    action = cc.Sequence(action, cc.DelayTime(0.5), cc.CallFunc(end_call_back))
    cc.ActionManager:GetInstance():addAction(action, self.text_power)
end

function PowerChange:StopAction()
    if self.text_power then
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.text_power)
    end
end

function PowerChange:StartTime()
    self:StopTime()
    local function step()
        self:Update()
    end
    self.time_id = GlobalSchedule:Start(step, 0.02, -1)
end

function PowerChange:Update()
    self:CheckItem()
    if Time.time - self.last_add_time > 0.2 and not table.isempty(self.attr_list) then
        local index = self:GetItemIndex()
        if index then
            local data = table.remove(self.attr_list, 1)
            self:CreateItem(index, data)
        end
    end

    if not self.action_state and self:AllDone() then
        self:Close()
    end
end

function PowerChange:CheckItem()
    local del_tab
    for k, v in pairs(self.item_list) do
        if v.is_dctored then
            del_tab = del_tab or {}
            del_tab[#del_tab + 1] = k
        elseif v:IsDone() then
            v:destroy()
            del_tab = del_tab or {}
            del_tab[#del_tab + 1] = k
        end
    end

    if del_tab then
        for k, v in pairs(del_tab) do
            self.item_list[v] = nil
        end
    end
end

function PowerChange:AllDone()
    for k, v in pairs(self.item_list) do
        if not v.is_dctored and not v:IsDone() then
            return false
        end
    end
    return true
end

function PowerChange:CreateItem(index, data)
    if self.item_list[index] then
        return
    end
    self.last_index = index
    self.last_add_time = Time.time
    local item = PowerChangeText(self.PowerChangeText_gameObject, self.transform)
    self.item_list[index] = item
    item:SetData(index, data)
    local x = -350
    local y = 150 - (self.max_item_count - index) * 43
    item:SetPosition(x, y - 65)
    item:StartAction(0.15, x, y)
end

function PowerChange:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
        self.time_id = nil
    end
end

function PowerChange:GetItemIndex()
    for i = self.last_index, 1, -1 do
        if not self.item_list[i] then
            return i
        end
    end
    for i = self.max_item_count, 1, -1 do
        if not self.item_list[i] then
            return i
        end
    end
    return nil
end

function PowerChange:CloseCallBack()
    for k, item in pairs(self.item_list) do
        item:destroy()
    end
    self.item_list = {}

    self.old_power = nil
    self.new_power = nil

    if self.effect then
        self.effect:destroy()
    end
    self.effect = nil
end

function PowerChange:Close()
    if self.is_dctored then
        return
    end
    lua_panelMgr:ToClosePanel(self)
    if not self.is_exist_always then
        self.isShow = false
        self:CloseCallBack()
        -- lua_panelMgr:ToClosePanel(self)
        self:destroy()
    else
        self.isShow = false
        self:SetVisibleInside(false)
        self:CloseCallBack()
    end
end