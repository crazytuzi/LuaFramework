-- @Author: lwj
-- @Date:   2019-10-29 21:41:40 
-- @Last Modified time: 2019-10-29 21:41:43

OpenTipAttrItem = OpenTipAttrItem or class("OpenTipAttrItem", BaseCloneItem)
local OpenTipAttrItem = OpenTipAttrItem

function OpenTipAttrItem:ctor(parent_node, layer)
    OpenTipAttrItem.super.Load(self)

    self.show_percent_after_idx = 12        --这个数字之后的属性都是百分比属性
end

function OpenTipAttrItem:dctor()
end

function OpenTipAttrItem:LoadCallBack()
    self.model = OpenTipModel.GetInstance()
    self.nodes = {
        "des"
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
end

function OpenTipAttrItem:AddEvent()

end

function OpenTipAttrItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function OpenTipAttrItem:UpdateView()
    local title = GetAttrNameByIndex(self.data[1])
    local value = self.data[2]
    if self.data[1] > self.show_percent_after_idx then
        value = value / 100
        value = value .. "%"
    end
    if string.utf8len(title) == 2 then
        title = table.concat(string.utf8list(title), "       ")
    end
    self.des.text = string.format("%s：<color=#4ef541>+%s</color>", title, value)
end