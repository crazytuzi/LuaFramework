-- @Author: lwj
-- @Date:   2018-12-04 20:31:49
-- @Last Modified time: 2018-12-04 20:31:54

ShiftWord = ShiftWord or class("ShiftWord", BaseItem)
local ShiftWord = ShiftWord

ShiftWord.FlyHeight = 40
ShiftWord.OffHeight = 15
ShiftWord.FlyTime = 1
ShiftWord.DeltaTime = 0.5
ShiftWord.FlySpeed = ShiftWord.FlyTime / ShiftWord.FlyHeight

function ShiftWord:ctor(parent_node, builtin_layer, str)
    self.abName = "vip"
    self.assetName = "ShiftWord"
    ShiftWord.super.Load(self)
    self.str = str
end

function ShiftWord:dctor()
    self:SetVisible(false)
    self:StopAction()
end

function ShiftWord:LoadCallBack()
    self.nodes = {
        "Text"
    }
    self:GetChildren(self.nodes)
    self.show_text = self.Text:GetComponent('Text')
    self.show_text.text = self.str
    --self.img_component = self.img_bg:GetComponent('Image')
    self:AddEvent()
    self.start_x, self.start_y, self.start_z = self:GetPosition()
    self:StartAction()
end

function ShiftWord:AddEvent()
end

function ShiftWord:__reset(...)
    ShiftWord.super.__reset(self,...)
    self:SetPosition(self.start_x, self.start_y, self.start_z)
    SetAlpha(self.show_text, 1)
end

function ShiftWord:__clear()
    self:StopAction()
    ShiftWord.super.__clear(self)
end

function ShiftWord:GetDelayTime()
    local height = self:GetFlyHeight() - ShiftWord.OffHeight
    height = height <= 0 and 0 or height
    return height * ShiftWord.FlySpeed
end

function ShiftWord:StartAction()
    self:StopAction()
    local speed = ShiftWord.FlySpeed
    local _, y = self:GetPosition()
    local action
    if y <= self.start_y + ShiftWord.FlyHeight then
        local time = (self.start_y + ShiftWord.FlyHeight - y) * speed
        local moveAction = cc.MoveTo(time, self.start_x, self.start_y + ShiftWord.FlyHeight, self.start_z)
        action = self:ComboAction(action, moveAction)
    end
    local delayaction = cc.DelayTime(ShiftWord.DeltaTime)
    action = self:ComboAction(action, delayaction)

    --local function on_callback()
    --    SystemTipManager:GetInstance():RemoveTextNotify(self)
    --end
    --local call_action = cc.CallFunc(on_callback)
    --action = self:ComboAction(action,call_action)

    local fadeout_action = cc.FadeOut(0.1, self.show_text)
    action = self:ComboAction(action, fadeout_action)
    local function on_end_callback()
        self:destroy()
    end
    local end_action = cc.CallFunc(on_end_callback)
    action = self:ComboAction(action, end_action)
    cc.ActionManager:GetInstance():addAction(action, self.transform)
end

function ShiftWord:ComboAction(action1, action2)
    if action1 and action2 then
        return cc.Sequence(action1, action2)
    elseif not action1 then
        return action2
    elseif not action2 then
        return action1
    end
end

function ShiftWord:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end

