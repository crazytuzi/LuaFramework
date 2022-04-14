-- @Author: lwj
-- @Date:   2018-12-03 15:58:11
-- @Last Modified time: 2018-12-03 15:59:12


ComDesItem = ComDesItem or class("ComDesItem", BaseCloneItem)
local ComDesItem = ComDesItem

function ComDesItem:ctor(parent_node, layer)
    ComDesItem.super.Load(self)
end

function ComDesItem:dctor()

end

function ComDesItem:LoadCallBack()
    self.nodes = {
        "check", "check_blue", "special", "cross", "normal",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
end

function ComDesItem:AddEvent()

end

function ComDesItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function ComDesItem:UpdateView()
    if self.data.isHave then
        if tonumber(self.data.value) ~= 0 then
            --是功能开启
            if self.data.isSpecial then
                --是V4
                SetVisible(self.check_blue, true)
            else
                SetVisible(self.check, true)
            end
        end
    else
        --不是功能开启
        if tonumber(self.data.value) ~= 0 then
            if self.data.isSpecial then
                --v4
                SetVisible(self.special, true)
                self.special:GetComponent('Text').text = self.data.value
            else
                SetVisible(self.normal, true)
                self.normal:GetComponent('Text').text = self.data.value
            end
        end
    end
    if tonumber(self.data.value) == 0 then
        SetVisible(self.cross, true)
    end
end

