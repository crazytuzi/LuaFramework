---
--- Created by R2D2.
--- DateTime: 2019/1/16 10:21
---
WelfarePowerItemView = WelfarePowerItemView or class("WelfarePowerItemView", Node)
local this = WelfarePowerItemView

function WelfarePowerItemView:ctor(obj, data)
    self.gameObject = obj
    self.transform = obj.transform
    self.transform_find = self.transform.Find

    self.data = data
    self.image_ab = "welfare_image";

    self:InitUI();
    self:AddEvent();
end

function WelfarePowerItemView:dctor()

    if (self.redPoint) then
        self.redPoint:destroy()
        self.redPoint = nil
    end

    if(self.goodItems) then
        for _, v in pairs(self.goodItems) do
            v:destroy()
        end
        self.goodItems = nil
    end

    self.gameObject = nil
end

function WelfarePowerItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "BoxParent/Box", "Value", "Remain", "Limited",
                   "Received", "Depleted", "ItemParent", "Button","DisableButton"
    }
    self:GetChildren(self.nodes)

    self.chestImage = GetImage(self.Box)
    self.valueText = GetText(self.Value)
    self.remainText = GetText(self.Remain)
    self.limitedImage = GetImage(self.Limited)
    self.receivedImage = GetImage(self.Received)
    self.depletedImage = GetImage(self.Depleted)
    self.goodsParent = self.ItemParent.transform

    self.valueText.text = "f" .. self.data.power
    --self.limitedImage.enabled = self.data.count > 0
    self:RefreshGoodItem()
    self:RefreshState()
end

function WelfarePowerItemView:RefreshData(data)
    self.data = data

    self.valueText.text = "f" .. self.data.power
    --self.limitedImage.enabled = self.data.count > 0
    self:RefreshGoodItem()
    self:RefreshState()
end

function WelfarePowerItemView:AddEvent()
    local function OnReceiveClick()
        WelfareController:GetInstance():RequestPowerReward(self.data.power)
    end
    AddButtonEvent(self.Button.gameObject, OnReceiveClick)

    local function OnDisableButton()
        Notify.ShowText("You don't have required CP")
    end
    AddButtonEvent(self.DisableButton.gameObject, OnDisableButton)
end

function WelfarePowerItemView:RefreshGoodItem()
    local goods = self.data.reward

    if(self.data.isLimited) then
        if(self.data.remain > 0) then
            self.limitedImage.enabled = true
            ---限量的如果有剩余的则显示限量奖励
            goods = self.data.reward2
        else
            self.limitedImage.enabled = false
        end

    else
        self.limitedImage.enabled =false
    end

    self:ShowGoodItem(goods)
end

function WelfarePowerItemView:ShowGoodItem(goodsData)

    self.goodItems = self.goodItems or {}
    local goods = goodsData
    local count = #goods

    for i, v in ipairs(goods) do

        local item = self.goodItems[i]
        if (not item) then
            local item = GoodsIconSettorTwo(self.goodsParent)      
            local param = self:GenerateGoodParam(v)
            item:SetIcon(param)         
           
            local index = #self.goodItems
            local col = index % 2
            local row = math.floor(index / 2)

            SetLocalScale(item.transform, 1, 1, 1)
            SetLocalPosition(item.transform, col * 84, row * -86, 0)

            table.insert(self.goodItems, item)
        else
            SetVisible(item.transform, true)
            local param = self:GenerateGoodParam(v)
            item:SetIcon(param)
        end
    end

    for i = count + 1, #self.goodItems do
        local item = self.goodItems[i]
        if( item) then
            SetVisible(item.transform, false)
        end
    end
end

function WelfarePowerItemView:GenerateGoodParam(goodData)
    local param = {}
    type_id = RoleInfoModel:GetInstance():GetItemId(goodData[1])
    if Config.db_item[type_id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        param["cfg"] = Config.db_equip[type_id]
    else
        param["cfg"] = Config.db_item[type_id]
    end
    param["model"] = BagModel.Instance
    param["can_click"] =  true
    param["num"] = goodData[2]
    param["is_dont_set_pos"] = true

    return param
end

function WelfarePowerItemView:RefreshState()
    self:RefreshRemain()
    local power =RoleInfoModel:GetInstance():GetRoleValue("power");
    --local power = RoleInfoModel.GetInstance():GetMainRoleData().power
    local icon = self.data.chest

if self.data.isReceived then
    icon = icon .. "B"
    self:ReceivedStyle()
else
    icon = icon .. "A"

    if power >= self.data.power then
        self:ReachedStyle()
    else
        self:UnreachedStyle()
    end
end

    lua_resMgr:SetImageTexture(self, self.chestImage, self.image_ab, icon, false, nil, false);
end

function WelfarePowerItemView:RefreshRemain()
    if self.data.count <= 0 then
        self.remainText.text = "No limit"
    else
        self.remainText.text = "Left:" .. self.data.remain
    end
end

--已领取
function WelfarePowerItemView:ReceivedStyle()
    self.receivedImage.enabled = true
    self.depletedImage.enabled = false
    SetGameObjectActive(self.Button, false)
    SetGameObjectActive(self.DisableButton, false)
    self:SetRedPoint(false)
end

--不可领取（等级未足）
function WelfarePowerItemView:UnreachedStyle()
    self.receivedImage.enabled = false
    self.depletedImage.enabled = false
    SetGameObjectActive(self.Button, false)
    SetGameObjectActive(self.DisableButton, true)
    self:SetRedPoint(false)
end

--可领取
function WelfarePowerItemView:ReachedStyle()
    self.receivedImage.enabled = false
    self.depletedImage.enabled = false
    SetGameObjectActive(self.Button, true)
    SetGameObjectActive(self.DisableButton, false)
    self:SetRedPoint(true)
end

--已领完
function WelfarePowerItemView:DepletedStyle()
    self.receivedImage.enabled = false
    self.depletedImage.enabled = true
    SetGameObjectActive(self.Button, false)
    SetGameObjectActive(self.DisableButton, false)
    self:SetRedPoint(false)
end

function WelfarePowerItemView:SetRedPoint(isShow)
    if self.redPoint == nil then
        self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(50, -162)
    end

    self.redPoint:SetRedDotParam(isShow)
end