-- @Author: lwj
-- @Date:   2019-06-11 20:32:40
-- @Last Modified time: 2019-06-11 20:32:41

VipGiftPanel = VipGiftPanel or class("VipGiftPanel", BaseItem)
local VipGiftPanel = VipGiftPanel

function VipGiftPanel:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "VipGiftPanel"
    self.layer = layer

    self.model = VipModel.GetInstance()
    BaseItem.Load(self)
end

function VipGiftPanel:dctor()
    for i, v in pairs(self.item_list) do
        if v then
            v:destroy()
        end
    end
    self.item_list = {}
end

function VipGiftPanel:LoadCallBack()
    self.nodes = {
        "Right/Scroll/Viewport/item_con/VipGiftItem", "Right/Scroll/Viewport/item_con",
    }
    self:GetChildren(self.nodes)
    self.item_obj = self.VipGiftItem.gameObject

    self:AddEvent()
    self:CheckFirstRD()
    self:InitPanel()
end

function VipGiftPanel:AddEvent()

end

function VipGiftPanel:InitPanel()
    local list = self.model:GetVipGiftCF()
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = VipGiftItem(self.item_obj, self.item_con)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        local ser_data = ShopModel.GetInstance():GetGoodsBoRecordById(list[i].id)
        item:SetData(list[i], ser_data)
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function VipGiftPanel:CheckFirstRD()
    if self.model.is_showed_first_rd and self.model:GetSideRD(3) then
        self.model:RemoveSideRD(3)
        local is_hide_main_rd = self.model:IsCanHideMainIconRD()
        GlobalEvent:Brocast(VipEvent.ShowMainVipRD, not is_hide_main_rd)
        self.model:Brocast(VipEvent.UpdateVipSideRD)
    end
end