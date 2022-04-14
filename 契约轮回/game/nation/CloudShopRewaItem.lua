-- @Author: lwj
-- @Date:   2019-12-27 15:58:13 
-- @Last Modified time: 2019-12-27 15:58:16

CloudShopRewaItem = CloudShopRewaItem or class("CloudShopRewaItem", BaseCloneItem)
local CloudShopRewaItem = CloudShopRewaItem

function CloudShopRewaItem:ctor(parent_node, layer)
    CloudShopRewaItem.super.Load(self)
end

function CloudShopRewaItem:dctor()
    destroySingle(self.itemIcon)
end

function CloudShopRewaItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "rewa_con", "name",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)

    self:AddEvent()
end

function CloudShopRewaItem:AddEvent()

end

function CloudShopRewaItem:SetData(data, stencil_id)
    self.data = data
    self.Stencil_id = stencil_id
    self:UpdateView()
end

function CloudShopRewaItem:UpdateView()
    local str = "Result coming"
    local name = self.data.role_name
    if name and name ~= "" then
        --已开奖
        local s_name = RoleInfoModel:GetInstance():GetServerName(self.data.suid)
        local num_str = ""
        if self.data.num and self.data.num >= 2 then
            num_str = "（<color=#3ab60e>" .. self.data.num .. "</color>）"
        end
        str = string.format("<color=#ff8942>%s</color>-<color=#eb0000>%s</color>%s", s_name, name, num_str)
    end
    self.name.text = str

    local cf = OperateModel.GetInstance():GetShopCfByRewaId(self.data.id)
    local rewa_tbl = String2Table(cf.rewards)[1]
    local param = {}
    local operate_param = {}
    param["item_id"] = rewa_tbl[1]
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 74, y = 74 }
    param["num"] = rewa_tbl[2]
    param.bind = rewa_tbl[3]

    local color = Config.db_item[rewa_tbl[1]].color - 1
    param["color_effect"] = color
    param["effect_type"] = 2  --活动特效：2

    param["stencil_id"] = self.Stencil_id
    param["stencil_type"] = 3
    if not self.itemIcon then
        self.itemIcon = GoodsIconSettorTwo(self.rewa_con)
    end
    self.itemIcon:SetIcon(param)
end