-- @Author: lwj
-- @Date:   2019-08-14 20:57:26 
-- @Last Modified time: 2019-08-14 20:57:29

ColeGoodsItem = ColeGoodsItem or class("ColeGoodsItem", BaseCloneItem)
local ColeGoodsItem = ColeGoodsItem

function ColeGoodsItem:ctor(parent_node, layer)
    ColeGoodsItem.super.Load(self)
end

function ColeGoodsItem:dctor()
    if self.itemIcon then
        self.itemIcon:destroy()
        self.itemIcon = nil
    end
end

function ColeGoodsItem:LoadCallBack()
    self.model = OpenHighModel.GetInstance()
    self.nodes = {
        "num", "icon_con",
    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)

    self:AddEvent()
end

function ColeGoodsItem:AddEvent()

end

function ColeGoodsItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function ColeGoodsItem:UpdateView()
    if not self.itemIcon then
        self.itemIcon = GoodsIconSettorTwo(self.icon_con)
    end
    local param = {}
    local operate_param = {}
    param["item_id"] = self.data[1]
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 60, y = 60 }
    param["is_dont_set_pos"] = true
    param.bind = 2
    self.itemIcon:SetIcon(param)

    local num = BagModel.Instance:GetItemNumByItemID(self.data[1])
    local color_str = "FFFFFF"
    --local final_num = self.data[2]
    local final_num = BagModel.Instance:GetItemNumByItemID(self.data[1])
    if final_num < self.data[2] then
        color_str = "f53b3b"
    end
    self.num.text = string.format("<color=#%s>%d</color>/%d", color_str, final_num, self.data[2])
end