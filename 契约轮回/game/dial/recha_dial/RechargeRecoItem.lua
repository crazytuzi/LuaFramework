-- @Author: lwj
-- @Date:   2019-12-08 10:46:15
-- @Last Modified time: 2019-12-08 10:46:23

RechargeRecoItem = RechargeRecoItem or class("RechargeRecoItem", BaseCloneItem)
local RechargeRecoItem = RechargeRecoItem

function RechargeRecoItem:ctor(parent_node, layer)
    RechargeRecoItem.super.Load(self)
end

function RechargeRecoItem:dctor()
end

function RechargeRecoItem:LoadCallBack()
    --self.model = CanMdyModel.GetInstance()
    self.nodes = {
        "des"
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
end

function RechargeRecoItem:AddEvent()

end

function RechargeRecoItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function RechargeRecoItem:UpdateView()
    local id = self.data.item_id
    if not id then
        return
    end
    local cf = Config.db_item[id]
    if not cf then
        return
    end
    local item_name = cf.name
    self.des.text = string.format("<color=#58f650>[%s]</color> obtained in Treasure Hunt <color=#ea9a02>%s*%d</color>", self.data.role_name, item_name, self.data.item_num)
end