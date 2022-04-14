-- @Author: lwj
-- @Date:   2019-03-20 14:04:19
-- @Last Modified time: 2019-11-12 17:47:28

VipRenewCard = VipRenewCard or class("VipRenewCard", BaseCloneItem)
local VipRenewCard = VipRenewCard

function VipRenewCard:ctor(parent_node, layer)
    VipRenewCard.super.Load(self)
end

function VipRenewCard:dctor()
    if self.goods_item then
        self.goods_item:destroy()
        self.goods_item = nil
    end
end

function VipRenewCard:LoadCallBack()
    self.model = VipModel.GetInstance()
    self.nodes = {
         "icon", "currency", "price", "btn_renew", "Bg_2", 
    }
    self:GetChildren(self.nodes)
    self.price = GetText(self.price)
    self.currency = GetImage(self.currency)
    self.bg = GetImage(self.Bg_2)

    self:AddEvent()
end

function VipRenewCard:AddEvent()
    local function callback()
        local data = {}
        data.curPrice = self.data.curPrice
        data.typeId = self.data.level
        data.mallId = self.data.mallId
        self.model:Brocast(VipEvent.ActivateVipCard, data)
    end
    AddButtonEvent(self.btn_renew.gameObject, callback)
end

function VipRenewCard:SetData(data)
    self.data = data
    self:UpdateView()
end

function VipRenewCard:UpdateView() 
    self.price.text = self.data.curPrice
    local param = {}
    local operate_param = {}
    local cfg = Config.db_item[self.data.item_id]
    param["cfg"] = cfg
    param["model"] = self.model
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 80, y = 80 }
    self.goods_item = GoodsIconSettorTwo(self.icon)
    self.goods_item:SetIcon(param)
    lua_resMgr:SetImageTexture(self, self.bg, "vip_image", "vip_renew_bg_" .. self.data.level, true, nil, false)
    local key = tostring(Config.db_item[tonumber(self.data.price_type)].icon)
    GoodIconUtil:CreateIcon(self, self.currency, key, true)
end