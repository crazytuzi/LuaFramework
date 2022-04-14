--
-- @Author: LaoY
-- @Date:   2019-05-16 17:12:56
--
MainTaskTipItem = MainTaskTipItem or class("MainTaskTipItem", BaseCloneItem)

function MainTaskTipItem:ctor(obj, parent_node, layer)
    MainTaskTipItem.super.Load(self)
end

function MainTaskTipItem:dctor()
    self:DelEffect()
end

function MainTaskTipItem:LoadCallBack()
    self.nodes = {
        "button","button/text",
    }
    self:GetChildren(self.nodes)

    -- SetLocalScale(self.button , 0.85, 0.85, 0.85)

    self.text_component = self.text:GetComponent('Text')
    self:AddEvent()
end

function MainTaskTipItem:SetCallBack(call_back)
    self.call_back = call_back
end

function MainTaskTipItem:AddEvent()

    local function call_back(target, x, y)
        if self.call_back then
            self.call_back()
        end

        if type(self.data.param) == "function" then
            self.data.param()
        else
            MainIconOpenLink(unpack(self.data.param))
        end
    end
    AddClickEvent(self.button.gameObject, call_back)
end

function MainTaskTipItem:SetData(index, data)
    self.data = data
    self.text_component.text = data.text
    if index == 1 then
        self:PlayEffect()
    end
end

function MainTaskTipItem:PlayEffect()
    if not self.effect then
        self.effect = UIEffect(self.transform, 30012, false, self.layer)
        self.effect:SetPosition(2,-1)
    end
end

function MainTaskTipItem:DelEffect()
    if self.effect then
        self.effect:destroy()
        self.effect = nil
    end
end