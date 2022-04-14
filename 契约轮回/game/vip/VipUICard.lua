-- @Author: lwj
-- @Date:   2018-11-30 15:01:59
-- @Last Modified time: 2018-11-30 15:02:02

VipUICard = VipUICard or class("VipUICard", BaseItem)
local VipUICard = VipUICard

function VipUICard:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "VipUICard"
    self.layer = layer

    self.model = VipModel.GetInstance()
    BaseItem.Load(self)
end

function VipUICard:dctor()
    if self.itemIcon ~= nil then
        self.itemIcon:destroy()
        self.itemIcon = nil
    end
end

function VipUICard:LoadCallBack()
    self.nodes = {
        "icon", "btn_Activate", "IndateT/curDate", "originImg", "CurT/curPrice", "title",
        "bg_normal", "bg_special",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self:UpdateView()
end

function VipUICard:AddEvent()
    local function call_back()
        self.model:Brocast(VipEvent.ActivateVipCard, self.data)
    end
    AddButtonEvent(self.btn_Activate.gameObject, call_back)

    --local function call_back()
    --end
    --AddButtonEvent(self.icon.gameObject, call_back)
end

function VipUICard:SetData(data)
    self.data = data
end

function VipUICard:UpdateView()
    local is_vfour = false
    local param = {}
    param["model"] = self.model
    param["item_id"] = self.data.id
    param["size"] = { x = 80, y = 80 }
    param["can_click"] = true
    if self.data.level >= 4 then
        SetVisible(self.bg_normal, false)
        SetVisible(self.bg_special, true)
        self.title:GetComponent('Text').text = "<color=#c54100>" .. self.data.name .. "</color>"
        local color = Config.db_item[self.data.id].color - 1
        param["color_effect"] = color
        param["effect_type"] = 2
        is_vfour = true
    else
        self.title:GetComponent('Text').text = self.data.name
    end
    self.itemIcon = GoodsIconSettorTwo(self.icon)
    self.itemIcon:SetIcon(param)
    local str = self.data.limitDate / (60 * 60 * 24) .. "Days"
    if is_vfour then
        str = "Permanent"
    end
    self.curDate:GetComponent('Text').text = str
    self.originImg:GetComponent('UILineText').text = ConfigLanguage.Vip.OriginalPriceText .. self.data.originalPrice
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.Gold)
    local color = nil
    if self.data.curPrice > roleBalance then
        color = "ec1c1c"
    else
        color = "18c114"
    end
    self.curPrice:GetComponent('Text').text = string.format("<color=#%s>%s</color>", color, self.data.curPrice)
end

