---
--- Created by  Administrator
--- DateTime: 2019/12/24 17:38
---
MachineArmorEquipItem = MachineArmorEquipItem or class("MachineArmorEquipItem", BaseItem)
local this = MachineArmorEquipItem

function MachineArmorEquipItem:ctor(parent_node, parent_panel)

    self.abName = "machinearmor"
    self.assetName = "MachineArmorEquipItem"
    self.layer = "UI"
    self.events = {}
    self.gEvents = {}
    self.model = MachineArmorModel:GetInstance()
    MachineArmorEquipItem.super.Load(self)
end

function MachineArmorEquipItem:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gEvents)
    if self.itemicon then
        self.itemicon:destroy()
    end
    self.itemicon = nil

    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function MachineArmorEquipItem:LoadCallBack()
    self.nodes = {
        "kuang","select","level","redPointPrent","iconParent","bgImg",
        "lockObj/lockText","lockObj/lockClick","lockObj",
    }
    self:GetChildren(self.nodes)
    self.level = GetText(self.level)
    self.bgImg = GetImage(self.bgImg)
    self.lockText = GetText(self.lockText)
    SetVisible(self.select,false)
    SetVisible(self.bgImg,false)
    SetVisible(self.lockObj,false)
    self:InitUI()
    self:AddEvent()
    if   self.is_need_setData then
        self:SetData(self.slot,self.type,self.mechaID)
    end
    if self.is_need_setSelect then
        self:SetSelect(self.selectState)
    end
end

function MachineArmorEquipItem:InitUI()

end

function MachineArmorEquipItem:AddEvent()
    local function call_back()
        
    end
    AddClickEvent(self.lockClick.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MachineArmorEvent.MechaEquipPutOnInfo,handler(self,self.MechaEquipPutOnInfo))
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(MachineArmorEvent.CheckRedPoint,handler(self,self.CheckRedPoint))
end

function MachineArmorEquipItem:SetData(data,type,mechaID)
    self.slot = data
    self.type = type
    self.mechaID = mechaID
    if not self.slot then
        return
    end
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end

    self.item = self.model:GetPutOnBySlot(mechaID,self.slot)
    if self.item  then
        self:CreateIcon()
        local lv = self.item.extra
        SetVisible(self.level,lv > 0)
        self.level.text = "+"..lv
        SetVisible(self.lockObj,false)
      --  SetVisible(self.bgImg,false)
    else
        if self.itemicon then
            self.itemicon:destroy()
            self.itemicon = nil
        end
        SetVisible(self.level,false)
        if self.type == 1 then
            if not self.model:isSlotLock(mechaID,self.slot) then--沒有鎖
                SetVisible(self.lockObj,false)
            else
                local cfg = Config.db_mecha_equip_open[tostring(mechaID).."@"..self.slot]
                local openTab = String2Table(cfg.open)
                if openTab[1] == "star" then
                    local star = openTab[2]
                    local showCfg = Config.db_mecha_star[mechaID.."@"..star]
                    self.lockText.text = string.format("Unlock at Mecha T%sS%s",showCfg.star_client,showCfg.plot_client)
                end
                SetVisible(self.lockObj,true)
            end
           -- SetVisible(self.bgImg,true)
           -- lua_resMgr:SetImageTexture(self, self.bgImg,"baby_image", "baby_equip_"..self.slot, false, nil, false)
        end
    end

    SetVisible(self.kuang,self.slot == enum.ITEM_STYPE.ITEM_STYPE_MECHA_EQUIP_CORE)
    self:SetRedPoint()
end

function MachineArmorEquipItem:CheckRedPoint()
    self:SetRedPoint()
end


function MachineArmorEquipItem:SetRedPoint()
    if self.type ~= 2 then
        if not self.red then
            self.red = RedDot(self.redPointPrent, nil, RedDot.RedDotType.Nor)
            self.red:SetPosition(40, 37)
        end
        if not table.isempty(self.model.equipRedPoints[self.mechaID]) then
            self.red:SetRedDotParam(self.model.equipRedPoints[self.mechaID][self.slot])
        else
            self.red:SetRedDotParam(false)
        end

    end
end

function MachineArmorEquipItem:CreateIcon()
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

function MachineArmorEquipItem:OnStrong()
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    self.model:Brocast(MachineArmorEvent.OnStrongClick)
end

function MachineArmorEquipItem:IconClick()
    self.model:Brocast(MachineArmorEvent.EquipItemClick,self.slot)
end


function MachineArmorEquipItem:SetSelect(isShow)
    self.selectState = isShow
    if not self.is_loaded then
        self.is_need_setSelect = true
        return
    end
    SetVisible(self.select,isShow)
end

function MachineArmorEquipItem:MechaEquipPutOnInfo(data)
    if self.type == 2 then
        return
    end
    if data.slot == self.slot then
        self:CreateIcon()
    end
end