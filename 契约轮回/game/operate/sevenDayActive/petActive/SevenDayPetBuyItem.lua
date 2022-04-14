---
--- Created by  Administrator
--- DateTime: 2019/8/23 14:29
---
SevenDayPetBuyItem = SevenDayPetBuyItem or class("SevenDayPetBuyItem", BaseCloneItem)
local this = SevenDayPetBuyItem

function SevenDayPetBuyItem:ctor(obj, parent_node, parent_panel)
    SevenDayPetBuyItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
end

function SevenDayPetBuyItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)

    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function SevenDayPetBuyItem:LoadCallBack()
    self.nodes = {
        "sell","soldOut","sell/buyBtn","sell/times","discount/discountNum","lastPicObj/lastPriIcon","lastPicObj/lastPic","curPicObj/curPriIcon","curPicObj/curPic",
        "rewardParent","titlebg/titleName"
    }
    self:GetChildren(self.nodes)
    self.discountNum = GetText(self.discountNum)
    self.lastPic = GetText(self.lastPic)
    self.lastPriIcon = GetImage(self.lastPriIcon)
    self.curPriIcon = GetImage(self.curPriIcon)
    self.curPic = GetText(self.curPic)
    self.times = GetText(self.times)
    self.titleName = GetText(self.titleName)
    self:InitUI()
    self:AddEvent()
end

function SevenDayPetBuyItem:InitUI()

end

function SevenDayPetBuyItem:AddEvent()

    local function call_back()
        -- print2(self.data.id)
        if   RoleInfoModel:GetInstance():CheckGold(self.curNum,self.curId) then
            ShopController:GetInstance():RequestBuyGoods(self.data.id,1)
        end



    end
    AddClickEvent(self.buyBtn.gameObject,call_back)
end

function SevenDayPetBuyItem:SetData(data,actid,stencilId)
    self.stencilId = stencilId
    self.data = data
    -- dump(self.data)
    self:SetInfo()

end

function SevenDayPetBuyItem:SetInfo()
    self.titleName.text = self.data.name
    local limitNum = self.data.limit_num  --限购数量
    local color = "0DB420"
    if limitNum - self.data.times <= 0 then
        --  color = "FF0000"
        SetVisible(self.soldOut,true)
        SetVisible(self.sell,false)
    else
        SetVisible(self.soldOut,false)
        SetVisible(self.sell,true)
    end
    self.times.text = string.format("Limit<color=#%s>%s/%s</color>",color,limitNum - self.data.times,limitNum)
    self.discountNum.text = (100 - (self.data.discount * 10)) .."% Off"

    local lastTab = String2Table(self.data.original_price)
    local curTab = self.data.price
    -- local curId
    --  local curNum
    for i, v in pairs(curTab) do
        self.curId = i
        self.curNum = v
    end
    self:SetPic(lastTab[2],self.curNum ,lastTab[1],self.curId )
    --self:SetTitle()
    self:CreateIcon()
    --end
end

function SevenDayPetBuyItem:SetPic(lastNum,curNum,lastId,curId)
    self.lastPic.text = lastNum
    self.curPic.text = curNum
    GoodIconUtil:CreateIcon(self, self.lastPriIcon, lastId, true)
    GoodIconUtil:CreateIcon(self, self.curPriIcon, curId, true)
end

function SevenDayPetBuyItem:CreateIcon()
    local index = 0
    local tab = String2Table(self.data.item)
    for i = 1, #tab  do
        index = index + 1
        if self.itemicon[index] == nil then
            self.itemicon[index] = GoodsIconSettorTwo(self.rewardParent)
        else
            return
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = tab[i][1]
        param["num"] = tab[i][2]
        param["bind"] = tab[i][3]
        param["can_click"] = true
        --  param["size"] = {x = 72,y = 72}
        param["effect_type"] = 1
        param["color_effect"] = 5 --5
        param["stencil_id"] = self.stencilId
        param["stencil_type"] = 3
        self.itemicon[index]:SetIcon(param)
    end
end

