---
--- Created by R2D2.
--- DateTime: 2019/1/15 14:52
---

WelfareLevelItemView = WelfareLevelItemView or class("WelfareLevelItemView", Node)
local this = WelfareLevelItemView

function WelfareLevelItemView:ctor(obj, data)
    self.gameObject = obj
    self.transform = obj.transform
    self.transform_find = self.transform.Find

    self.data = data
    self.image_ab = "welfare_image";

    self:InitUI();
    self:AddEvent();
end

function WelfareLevelItemView:dctor()
    if (self.redPoint) then
        self.redPoint:destroy()
        self.redPoint = nil
    end

    for _, v in pairs(self.goodItems) do
        v:destroy()
    end
    self.goodItems = nil

    self.gameObject = nil
    --self.transform = nil
end

function WelfareLevelItemView:InitUI()
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

    self.valueText.text = self.data.level .. "jlb"
    --self.limitedImage.enabled = self.data.count > 0
    self:RefreshGoodItem()
    self:RefreshState()
end

function WelfareLevelItemView:RefreshData(data)
    self.data = data

    self.valueText.text = self.data.level .. "jlb"
    --self.limitedImage.enabled = self.data.count > 0
    self:RefreshGoodItem()
    self:RefreshState()
end

function WelfareLevelItemView:RefreshGoodItem()

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

function WelfareLevelItemView:AddEvent()
    local function OnReceiveClick()
        WelfareController:GetInstance():RequestLevelReward(self.data.level)
    end
    AddButtonEvent(self.Button.gameObject, OnReceiveClick)

    local function OnDisableButton()
        Notify.ShowText("You didn't meet the level requirement")
    end
    AddButtonEvent(self.DisableButton.gameObject, OnDisableButton)
end

function WelfareLevelItemView:ShowGoodItem(goodsData)
    self.goodItems = self.goodItems or {}

    local goods = goodsData
    local count = #goods

    for i, v in ipairs(goods) do
        local item = self.goodItems[i]
        if(not item) then
            --local item = AwardItem(self.goodsParent)
            local item = GoodsIconSettorTwo(self.goodsParent)
            --item:SetData(v[1], v[2], true)
            --item:AddClickTips()
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
            --item:SetData(v[1], v[2], true)
        end
    end

    for i = count + 1, #self.goodItems do
        local item = self.goodItems[i]
        if( item) then
            SetVisible(item.transform, false)
        end
    end
end

function WelfareLevelItemView:GenerateGoodParam(goodData)
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

function WelfareLevelItemView:RefreshState()
    self:RefreshRemain()

    local lv = RoleInfoModel:GetInstance():GetRoleValue("level")
    --local lv = RoleInfoModel.GetInstance():Get :GetMainRoleData().level
    local icon = self.data.chest

    if self.data.isReceived then
        icon = icon .. "B"
        self:ReceivedStyle()
    else
        icon = icon .. "A"
        --if not self.data.isLimited then
            if lv >= self.data.level then
                self:ReachedStyle()
            else
                self:UnreachedStyle()
            end
        --else
        --    if self.data.remain > 0 then
        --        if lv >= self.data.level then
        --            self:ReachedStyle()
        --        else
        --            self:UnreachedStyle()
        --        end
        --    else
        --        self:DepletedStyle()
        --    end
        --end
    end

    lua_resMgr:SetImageTexture(self, self.chestImage, self.image_ab, icon, false, nil, false);
end

function WelfareLevelItemView:RefreshRemain()
    if (self.data.count <= 0) or (self.data.remain <= 0) then
        self.remainText.text = "No limit"
    else
        self.remainText.text = "Left:" .. self.data.remain
    end
end

--已领取
function WelfareLevelItemView:ReceivedStyle()
    self.receivedImage.enabled = true
    self.depletedImage.enabled = false
    SetGameObjectActive(self.Button, false)
    SetGameObjectActive(self.DisableButton, false)
    self:SetRedPoint(false)
end

--不可领取（等级未足）
function WelfareLevelItemView:UnreachedStyle()
    self.receivedImage.enabled = false
    self.depletedImage.enabled = false
    SetGameObjectActive(self.Button, false)
    SetGameObjectActive(self.DisableButton, true)
    self:SetRedPoint(false)
end

--可领取
function WelfareLevelItemView:ReachedStyle()
    self.receivedImage.enabled = false
    self.depletedImage.enabled = false
    SetGameObjectActive(self.Button, true)
    SetGameObjectActive(self.DisableButton, false)
    self:SetRedPoint(true)
end

--已领完
function WelfareLevelItemView:DepletedStyle()
    self.receivedImage.enabled = false
    self.depletedImage.enabled = true
    SetGameObjectActive(self.Button, false)
    SetGameObjectActive(self.DisableButton, false)
    self:SetRedPoint(false)
end

function WelfareLevelItemView:SetRedPoint(isShow)
    if self.redPoint == nil then
        self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(50, -162)
    end

    self.redPoint:SetRedDotParam(isShow)
end