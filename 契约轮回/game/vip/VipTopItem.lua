-- @Author: lwj
-- @Date:   2018-12-05 19:20:17
-- @Last Modified time: 2019-10-18 17:40:05

VipTopItem = VipTopItem or class("VipTopItem", BaseItem)
local VipTopItem = VipTopItem

function VipTopItem:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "VipTopItem"
    self.layer = layer

    self.locateFlag = nil
    self.model = VipModel:GetInstance()
    BaseItem.Load(self)
end

function VipTopItem:dctor()
end

function VipTopItem:LoadCallBack()
    self.nodes = {
        "sel_img", "name", "bg",
    }
    self:GetChildren(self.nodes)
    self.name=GetText(self.name)
    self.reTrans = GetRectTransform(self)
    SetAnchoredPosition(self.reTrans, self.data.position.x, self.data.position.y)
    self:AddEvent()
    self:UpdateView()
end

function VipTopItem:AddEvent()
    local function call_back()
        self.model:Brocast(VipEvent.UpdateVipBtnSelect, self.data.level)
    end
    AddClickEvent(self.bg.gameObject, call_back)
end

function VipTopItem:SetData(data)
    self.data = data
    if self.is_loaded then
        if self.name then
            local color_str = tonumber(id) == self.data.level and '8584b0' or 'fefefe'
            self.name.text = string.format(ConfigLanguage.Combine.TopItemText, color_str, "VIP" .. self.data.level)
        end
    end
end

function VipTopItem:UpdateView()
    if self.name then
        local color_str = tonumber(id) == self.data.level and '8584b0' or 'fefefe'
        self.name.text = string.format(ConfigLanguage.Combine.TopItemText, color_str, "VIP" .. self.data.level)
    end
    if self.locateFlag ~= nil then
        self:Select(self.locateFlag)
    end
end

function VipTopItem:Select(id)
    SetVisible(self.sel_img, tonumber(id) == self.data.level)
     if self.name then
        local color_str = tonumber(id) == self.data.level and '8584b0' or 'fefefe'
        self.name.text = string.format(ConfigLanguage.Combine.TopItemText, color_str, "VIP" .. self.data.level)
    end
end

function VipTopItem:SetSelectFlag(flag)
    self.locateFlag = flag
    if self.is_loaded then
        self:UpdateView()
    end
end