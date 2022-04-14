-- @Author: lwj
-- @Date:   2019-03-20 11:37:14
-- @Last Modified time: 2019-11-12 19:01:46

VipRenewPanel = VipRenewPanel or class("VipRenewPanel", WindowPanel)
local VipRenewPanel = VipRenewPanel

function VipRenewPanel:ctor()
    self.abName = "vip"
    self.assetName = "VipRenewPanel"
    self.layer = "UI"

    self.panel_type = 3
    self.model = VipModel.GetInstance()
end

function VipRenewPanel:dctor()

end

function VipRenewPanel:Open()
    WindowPanel.super.Open(self)
end

function VipRenewPanel:LoadCallBack()
    self.nodes = {
        "CardContent/VipRenewCard",
        "CardContent",
    }
    self:GetChildren(self.nodes)
    self.card_obj = self.VipRenewCard.gameObject
    self:SetTileTextImage("vip_image", "Renew_Title_Img")
    self:SetPanelSize(652.02, 474.44)
    SetLocalPosition(self.CardContent.transform, -16.66, -13.2, 0)
    self:SetBackgroundImage("system_image", "panel_bg_3")
    --self:SetDecoShow(false)

    self:AddEvent()
    self:InitPanel()
end

function VipRenewPanel:AddEvent()
    local function callback()
        self:Close()
    end
    self.close_self_event_id = self.model:AddListener(VipEvent.CloseRenewPanel, callback)
end

function VipRenewPanel:InitPanel()
    self:LoadCard()
end

function VipRenewPanel:OpenCallBack()
    local rect = GetRectTransform(self)
    SetLocalPositionZ(rect, -1000)
    SetLocalPosition(self.bg_win.transform, -11.8, 13.76, 0)
end

function VipRenewPanel:LoadCard()
    self.vipCard_List = {}
    local idx = 4
    for i = 1, 3 do
        local level = idx
        local card_cf = Config.db_vip_card[idx]
        local mallId = card_cf.goods
        local data = {}
        data.limitDate = card_cf.last
        data.mallId = mallId
        data.level = level
        local item_id = String2Table(Config.db_mall[mallId].item)[1]
        data.item_id = item_id
        local mall_config = Config.db_mall[mallId]
        data.curPrice = String2Table(mall_config.price)[2]
        data.price_type = String2Table(mall_config.price)[1]
        local item = VipRenewCard(self.card_obj, self.CardContent)
        item:SetData(data)
        table.insert(self.vipCard_List, item)
        idx=idx-1
    end
end

function VipRenewPanel:CloseCallBack()
    for i, v in pairs(self.vipCard_List) do
        if v then
            v:destroy()
        end
    end
    self.vipCard_List = nil
    if self.close_self_event_id then
        self.model:RemoveListener(self.close_self_event_id)
        self.close_self_event_id = nil
    end
end

