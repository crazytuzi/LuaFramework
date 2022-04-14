---
--- Created by  Administrator
--- DateTime: 2019/11/29 10:22
---
GodEquipItem = GodEquipItem or class("GodEquipItem", BaseItem)
local this = GodEquipItem

function GodEquipItem:ctor(parent_node, layer)
    self.abName = "god"
    self.assetName = "GodEquipItem"
    self.layer = layer
    self.events = {}
    self.gEvents = {}
    self.model = GodModel:GetInstance()
    GodEquipItem.super.Load(self)
end

function GodEquipItem:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener( self.gEvents )
    if self.itemicon then
        self.itemicon:destroy()
    end
    self.itemicon = nil

    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function GodEquipItem:LoadCallBack()
    self.nodes = {
        "iconParent","select","level","redPointPrent","bgImg","lockObj","lockObj/lockText",
        "kuang","lockObj/lockClick",
    }
    self:GetChildren(self.nodes)
    self.level = GetText(self.level)
    self.bgImg = GetImage(self.bgImg)
    self.lockText = GetText(self.lockText)
    self.kuang = GetImage(self.kuang)
    self:InitUI()
    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.slot,self.type,self.isNext,self.pos,self.index)
    end
    if self.is_need_setSelect then
        self:SetSelect(self.selectState)
    end


end

function GodEquipItem:InitUI()

end

function GodEquipItem:AddEvent()

    local function call_back()
        local cfg = Config.db_god_equip_open[self.slot]
        if  cfg then
            local tab = String2Table(cfg.open)
            local str = ""
            local type = tab[1]
            if type == "own" then
                local color = enumName.COLOR[tab[2]]
                str = string.format("After having at least <color=#3ab60e>%s%s avatars,</color> you can unlock this slot.\nunlock now?",tab[3],color)
            elseif type == "dunge" then
                str = string.format("Clear <color=#3ab60e>Path of Avatars %s wave.</color> You can unlock this slot.\nunlock now?",tab[2])
            end
            local function ok_func()
                OpenLink(150,1,1,6)
            end
            Dialog.ShowTwo("Tip",str,"Go",ok_func)
        end
    end
    AddClickEvent(self.lockClick.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(GodEvent.GodEquipPutOnInfo,handler(self,self.EquipPutOn))
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(GodEvent.CheckRedPoint, handler(self, self.UpdateRedPoint))
end


function GodEquipItem:UpdateRedPoint()
    self:SetRedPoint()
end

--type 1装备  2升级
function GodEquipItem:SetData(data,type,isNext,pos,index)
    self.slot = data
    self.type = type
    self.isNext = isNext
    self.pos = pos
    self.index = index
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
        SetVisible(self.lockObj,false)
        if self.type == 1  then
            SetVisible(self.kuang,true)
            if self.pos == 1 then --左边
                local x = 0
                if self.index == 2 then
                    x = -35
                end
                SetLocalPosition(self.transform,x,(self.index - 1)*-140,0)
                lua_resMgr:SetImageTexture(self, self.kuang,"god_image", "god_equip_kuang1", false, nil, false)
            elseif self.pos == 2 then --中间
                lua_resMgr:SetImageTexture(self, self.kuang,"god_image", "god_equip_kuang2", false, nil, false)
            else
                local x = 0
                if self.index == 2 then
                    x = 35
                end
                SetLocalPosition(self.transform,x,(self.index - 1)*-140,0)
                lua_resMgr:SetImageTexture(self, self.kuang,"god_image", "god_equip_kuang1", false, nil, false)
            end
        else
            SetVisible(self.kuang,false)
        end
    else
        SetVisible(self.level,false)
        if self.type == 1 then
            SetVisible(self.kuang,true)
            if self.model:GetSlotLock(self.slot) then --未解锁
                local cfg = Config.db_god_equip_open[self.slot]
                if  cfg then
                    local tab = String2Table(cfg.open)
                    local str = ""
                    local type = tab[1]
                    if type == "own" then
                        local color = enumName.COLOR[tab[2]]
                        str = string.format("Owned: %s*%s above deity",tab[3],color)
                    elseif type == "dunge" then
                        str = string.format("Clear Path of Avatars: Wave %s",tab[2])
                    end
                    self.lockText.text = str
                end
            end
            --logError(self.model:GetSlotLock(self.slot))
            SetVisible(self.lockObj,self.model:GetSlotLock(self.slot))
            SetVisible(self.bgImg,true)
            lua_resMgr:SetImageTexture(self, self.bgImg,"god_image", "god_equip_"..self.slot, false, nil, false)
            if self.pos == 1 then --左边
                local x = 0
                if self.index == 2 then
                    x = -35
                end
                SetLocalPosition(self.transform,x,(self.index - 1)*-140,0)
                lua_resMgr:SetImageTexture(self, self.kuang,"god_image", "god_equip_kuang1", false, nil, false)
                lua_resMgr:SetImageTexture(self, self.kuang,"god_image", "god_equip_kuang1", false, nil, false)
            elseif self.pos == 2 then --中间
                lua_resMgr:SetImageTexture(self, self.kuang,"god_image", "god_equip_kuang2", false, nil, false)
            else
                local x = 0
                if self.index == 2 then
                    x = 35
                end
                SetLocalPosition(self.transform,x,(self.index - 1)*-140,0)
                lua_resMgr:SetImageTexture(self, self.kuang,"god_image", "god_equip_kuang1", false, nil, false)
                lua_resMgr:SetImageTexture(self, self.kuang,"god_image", "god_equip_kuang1", false, nil, false)
            end
        else
            SetVisible(self.kuang,false)
        end
    end


    self:SetRedPoint()
end

function GodEquipItem:SetRedPoint()
    if self.type ~= 2 then
        if not self.red then
            self.red = RedDot(self.redPointPrent, nil, RedDot.RedDotType.Nor)
            self.red:SetPosition(40, 37)
        end
        self.red:SetRedDotParam(self.model.equipRedPoints[self.slot])
    end
end

function GodEquipItem:EquipPutOn(slot)
    if self.type == 2 then
        return
    end
    if slot == self.slot then
        self:CreateIcon()
    end
end




function GodEquipItem:CreateIcon()
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

function GodEquipItem:IconClick()
    self.model:Brocast(GodEvent.EquipItemClick,self.slot)
end

function GodEquipItem:SetSelect(isShow)
    self.selectState = isShow
    if not self.is_loaded then
        self.is_need_setSelect = true
        return
    end
    SetVisible(self.select,isShow)
end


function GodEquipItem:OnStrong(param)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    self.model:Brocast(GodEvent.OnStrongClick)
end

