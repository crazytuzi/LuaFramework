-- @Author: lwj
-- @Date:   2019-02-14 11:21:22
-- @Last Modified time: 2020-03-05 20:54:24

RechargePanel = RechargePanel or class("RechargePanel", BaseItem)
local RechargePanel = RechargePanel

function RechargePanel:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "RechargePanel"
    self.layer = layer

    self.model = VipModel.GetInstance()

    BaseItem.Load(self)
end

function RechargePanel:dctor()
    for i, v in pairs(self.item_list) do
        if v then
            v:destroy()
        end
    end
    self.item_list = {}
end

function RechargePanel:LoadCallBack()
    self.nodes = {
        "Scroll/Viewport/itemContent",
        "Scroll/Viewport/itemContent/RechargeItem",
    }
    self:GetChildren(self.nodes)
    self.recharge_gameObject = self.RechargeItem.gameObject

    self:AddEvent()
    self:InitPanel()
end

function RechargePanel:AddEvent()
end

function RechargePanel:InitPanel()
    local list = Config.db_recharge
    self.item_list = self.item_list or {}
    local way_id = PlatformManager.GetInstance():GetChannelID()
    local len = #list
    for i = 1, len do
        local data = list[i]
        local is_show = false
        if way_id ~= "" then
            --有渠道
			if data.desc=="" or data.desc == nil then
				is_show=true
			else
				local id_tbl = String2Table(data.desc)
				for ii = 1, #id_tbl do
					if tostring(id_tbl[ii]) == way_id then
						is_show = true
						break
					end
				end
			end
        else
            is_show = true
        end
        if is_show then
            local item = self.item_list[i]
            if not item then
                item = RechargeItem(self.recharge_gameObject, self.itemContent)
                self.item_list[i] = item
            else
                item:SetVisible(true)
            end
            item:SetData(list[i])
        end
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end
