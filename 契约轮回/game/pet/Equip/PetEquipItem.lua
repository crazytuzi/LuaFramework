--宠物装备项
PetEquipItem = PetEquipItem or class("PetEquipItem",BaseItem)

function PetEquipItem:ctor(parent_node)
    self.abName = "pet"
    self.assetName = "PetEquipItem"
    self.layer = "UI"

    self.pet_equip_model = PetEquipModel.GetInstance()
    self.pet_equip_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.goods_icon = nil 

    PetEquipItem.Load(self)
end

function PetEquipItem:dctor()
    if table.nums(self.pet_equip_model_events) > 0 then
        self.pet_equip_model:RemoveTabListener(self.pet_equip_model_events)
        self.pet_equip_model_events = nil
    end

    if self.goods_icon then
        self.goods_icon:destroy()
        self.goods_icon = nil
    end
end

function PetEquipItem:LoadCallBack(  )
    self.nodes = {
        "icon",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function PetEquipItem:InitUI(  )
    
end

function PetEquipItem:AddEvent(  )
    
end

--data
--item 宠物装备数据
function PetEquipItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function PetEquipItem:UpdateView()
    self.need_update_view = false

    if not self.data.item then
        SetVisible(self.icon,false)
        return
    end

    SetVisible(self.icon,true)




    self:UpdateIcon()
end

--刷新icon
function PetEquipItem:UpdateIcon()
    self.goods_icon = self.goods_icon or GoodsIconSettorTwo(self.icon)
    local param = {}

    param["p_item"] = self.data.item
    param["item_id"] = self.data.item.id
    param["can_click"] = true

    --宠物装备的配置表特殊处理
    param["cfg"] = self.pet_equip_model.pet_equip_cfg[self.data.item.id][self.data.item.equip.stren_phase]

    local operate_param = PetEquipHelper.GetInstance():GetOperateParam(self.data.item)
    param["operate_param"] = operate_param

    self.goods_icon:SetIcon(param)
end
