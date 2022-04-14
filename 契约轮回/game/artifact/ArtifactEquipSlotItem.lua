---
--- Created by  Administrator
--- DateTime: 2020/6/24 10:05
---
ArtifactEquipSlotItem = ArtifactEquipSlotItem or class("ArtifactEquipSlotItem", BaseCloneItem)
local this = ArtifactEquipSlotItem

function ArtifactEquipSlotItem:ctor(obj, parent_node, parent_panel)
    self.events = {}
    self.model = ArtifactModel:GetInstance()
    ArtifactEquipSlotItem.super.Load(self)

end

function ArtifactEquipSlotItem:dctor()
    self.model:RemoveTabListener(self.events)
    if self.itemicon then
        self.itemicon:destroy()
    end
    if self.red then
        self.red:destroy()
        self.red = nil
    end

end

function ArtifactEquipSlotItem:LoadCallBack()
    self.nodes = {
        "solt_s_1","iconParent","des"
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self:InitUI()
    self:AddEvent()
end

function ArtifactEquipSlotItem:InitUI()

end

function ArtifactEquipSlotItem:AddEvent()
    local function call_back()
        if not self.model:GetArtiInfo(self.id) then
            Notify.ShowText("The current divine locked")
            return
        end
        lua_panelMgr:GetPanelOrCreate(ArtifactBagPanel):Open(self.id)
    end
    AddClickEvent(self.solt_s_1.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtifactPutOnInfo, handler(self, self.ArtifactPutOnInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtifactPutOffInfo, handler(self, self.ArtifactPutOffInfo))
end



function ArtifactEquipSlotItem:SetData(data,id,type)
    self.data = data --部位
    self.id = id
    self.type = type
    local info = self.model:GetEquipInfo(self.id,self.data)
    if not info then
        SetVisible(self.solt_s_1,true)
        SetVisible(self.iconParent,false)
        self.des.text = "Click to equip"

    else
        SetVisible(self.solt_s_1,false)
        SetVisible(self.iconParent,true)
        local id = info.id
        local cfg = Config.db_item[id]
        if cfg then
            self.des.text = cfg.name
        end
        self:CreateIcon(info)
    end
    
    if not  self.red then
        self.red = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.red:SetPosition(-24, 224)
    end
    self.red:SetRedDotParam(self.model.equipRedPoints[type][id][data])
end

function ArtifactEquipSlotItem:CreateIcon(pItem)
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    local param = {}
    param["p_item"] = pItem
    param["model"] = BagModel
    param["item_id"] = pItem.id
    param["can_click"] = true
    param["size"] = {x = 78,y = 78}
    local operate_param = {}
    GoodsTipController.Instance:SetTakeOffCB(operate_param, handler(self, self.TakeOff), { pItem })
    param["operate_param"] = operate_param
    self.itemicon:SetIcon(param)
end

function ArtifactEquipSlotItem:TakeOff(param)
    if param then
        self.model.curPItem = param[1]
        ArtifactController:GetInstance():RequstArtifactPutOffInfo(self.id,self.data)
    end
end

function ArtifactEquipSlotItem:ArtifactPutOnInfo(data)
    if data.slot_id == self.data then
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
        self:SetData(self.data,self.id,self.type)
    end

end

function ArtifactEquipSlotItem:ArtifactPutOffInfo(data)
    if data.slot_id == self.data then
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
        self:SetData(self.data,self.id,self.type)
    end
end