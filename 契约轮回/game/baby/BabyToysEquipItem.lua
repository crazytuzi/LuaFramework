---
--- Created by  Administrator
--- DateTime: 2019/11/11 19:32
---
BabyToysEquipItem = BabyToysEquipItem or class("BabyToysEquipItem", BaseItem)
local this = BabyToysEquipItem

function BabyToysEquipItem:ctor(parent_node, layer)
    self.abName = "baby"
    self.assetName = "BabyToysEquipItem"
    self.layer = layer
    self.events = {}
    self.model = BabyModel:GetInstance()
    BabyToysEquipItem.super.Load(self)
end

function BabyToysEquipItem:dctor()
    self.model:RemoveTabListener(self.events)
    if self.itemicon then
        self.itemicon:destroy()
    end
    self.itemicon = nil

    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function BabyToysEquipItem:LoadCallBack()
    self.nodes = {
        "iconParent","select","level","redPointPrent","bgImg",
    }
    self:GetChildren(self.nodes)
    self.level = GetText(self.level)
    self.bgImg = GetImage(self.bgImg)
    self:InitUI()
    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.slot,self.type,self.isNext)
    end
    if self.is_need_setSelect then
        self:SetSelect(self.selectState)
    end



end

function BabyToysEquipItem:InitUI()

end

function BabyToysEquipItem:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyEquipPutOn,handler(self,self.EquipPutOn))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.UpdateRedPoint, handler(self, self.UpdateRedPoint))
end

function BabyToysEquipItem:UpdateRedPoint()
    self:SetRedPoint()
end

--type 1装备  2升级
function BabyToysEquipItem:SetData(data,type,isNext)
    self.slot = data
    self.type = type
    self.isNext = isNext
    if not self.slot then
        return
    end
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self.item = self.model:GetPutOnBySlot(self.slot)
    if self.item  then

        self:CreateIcon()
        local lv = self.item.extra
        if self.isNext then
            if not self.model:IsMaxUpLv(self.item ) then
                lv = self.item.extra + 1
            end
        end
        SetVisible(self.level,lv > 0)
        self.level.text = "+"..lv
        SetVisible(self.bgImg,false)
    else
        SetVisible(self.level,false)
        if self.type == 1 then
            SetVisible(self.bgImg,true)
            lua_resMgr:SetImageTexture(self, self.bgImg,"baby_image", "baby_equip_"..self.slot, false, nil, false)
        end
    end

    
    
    self:SetRedPoint()
end

function BabyToysEquipItem:SetRedPoint()
    if self.type ~= 2 then
        if not self.red then
            self.red = RedDot(self.redPointPrent, nil, RedDot.RedDotType.Nor)
            self.red:SetPosition(40, 37)
        end
        self.red:SetRedDotParam(self.model.babyToysRedPoints[self.slot])
    end
end

function BabyToysEquipItem:EquipPutOn(slot)
    if self.type == 2 then
        return
    end
    if slot == self.slot then
        self:CreateIcon()
    end
end




function BabyToysEquipItem:CreateIcon()
    if not self.item then
        return
    end
    local operate_param = {}
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    local param = {}
    param["p_item"] = self.item
    param["model"] = BagModel
    param["item_id"] = self.item.id
    param["can_click"] = self.type == 1
    param["size"] = {x = 78,y = 78}
    if self.type == 1 then
        GoodsTipController.Instance:SetStrongCB(operate_param,handler(self,self.OnStrong),{self.item})
        param["operate_param"] = operate_param
        param["out_call_back"] = handler(self,self.IconClick)
    end
    self.itemicon:SetIcon(param)
end

function BabyToysEquipItem:IconClick()
    self.model:Brocast(BabyEvent.EquipItemClick,self.slot)
end

function BabyToysEquipItem:SetSelect(isShow)
    self.selectState = isShow
    if not self.is_loaded then
        self.is_need_setSelect = true
        return
    end
    SetVisible(self.select,isShow)
end


function BabyToysEquipItem:OnStrong(param)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    self.model:Brocast(BabyEvent.OnStrongClick)
end

