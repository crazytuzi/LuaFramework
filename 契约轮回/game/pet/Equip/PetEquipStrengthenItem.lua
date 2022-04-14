--宠物装备强化Item
PetEquipStrengthenItem = PetEquipStrengthenItem or class("PetEquipStrengthenItem",BaseItem)

function PetEquipStrengthenItem:ctor(parent_node)
    self.abName = "equip"
	self.assetName = "EquipStrongItem"
    self.layer = "UI"

    self.pet_equip_model = PetEquipModel.GetInstance()
    self.pet_equip_model_events = {}

    self.role_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.goods_icon = nil

    self.red_dot = nil


    PetEquipStrengthenItem.Load(self)
end

function PetEquipStrengthenItem:dctor()
    if table.nums(self.pet_equip_model_events) > 0 then
        self.pet_equip_model:RemoveTabListener(self.pet_equip_model_events)
        self.pet_equip_model_events = nil
    end

    for _, event_id in pairs(self.role_events) do
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(event_id)
    end
    self.role_events = nil

    if self.goods_icon then
        self.goods_icon:destroy()
        self.goods_icon = nil
    end

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end

    self.data = nil
end

function PetEquipStrengthenItem:LoadCallBack(  )
    self.nodes = {
        "icon",
        "name","name_type","phase","select",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function PetEquipStrengthenItem:InitUI(  )
    self.txt_name = GetText(self.name)
    self.txt_name_type = GetText(self.name_type)
    self.txt_phase = GetText(self.phase)

    self.txt_name.fontSize = 16

    SetLocalPositionX(self.txt_name_type.transform,101.9)
    SetSizeDeltaX(self.txt_name_type.transform,87)
    self.txt_name_type.fontSize = 16


   

end

function PetEquipStrengthenItem:AddEvent(  )
    AddClickEvent(self.gameObject,handler(self,self.SelectItem))

    -- local function call_back(  )
    --     self:CheckReddot()
    -- end
    -- self.pet_equip_model_events[#self.pet_equip_model_events + 1] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquipReinf,call_back)
   

    local function call_back(  )
        self:CheckReddot()
    end
    self.role_events[#self.role_events + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("PetEquipExp", call_back)
    self.pet_equip_model_events[#self.pet_equip_model_events + 1] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquipUporder,call_back)
end

--data
--slot 部位
--item 装备item
--panel 宠物装备强化面板
--index 索引
function PetEquipStrengthenItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function PetEquipStrengthenItem:UpdateView()
    self.need_update_view = false

    self:UpdateIcon()
    self:UpdateInfo()
    self:CheckReddot()

    if self.data.index == self.data.panel.cur_select_index then
        self:SelectItem()
    end


end

function PetEquipStrengthenItem:UpdateIcon(  )
    self.goods_icon = self.goods_icon or GoodsIconSettorTwo(self.icon)
    local param = {}
	param["not_need_compare"] = true
	param["p_item"] = self.data.item
	param["item_id"] = self.data.item.id
    param["size"] = {x = 76,y=76}
    param["cfg"] = self.pet_equip_model.pet_equip_cfg[self.data.item.id][self.data.item.equip.stren_phase]
    self.goods_icon:SetIcon(param)
end

--刷新信息
function PetEquipStrengthenItem:UpdateInfo( )
    self.txt_name.text = self.pet_equip_model.pet_equip_cfg[self.data.item.id][self.data.item.equip.stren_phase].name
    self.txt_name_type.text = enumName.ITEM_STYPE[self.data.slot]

    local order = self.data.item.equip.stren_phase
    local stren_lv = self.data.item.equip.stren_lv
    local max_str = ""
    if order ~= 0 and stren_lv == order * 10 then

        local next_order_cfg = self.pet_equip_model.pet_equip_cfg[self.data.item.id][order + 1]
        local color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
        if next_order_cfg then
            max_str = "(Can be advanced)"
        else
            max_str = "(Max)"
        end
        max_str = string.format( "<color=#%s>%s</color>",color,max_str)
       
    end

    local order_str = string.format( "Tier%s LV.%s %s",order,stren_lv,max_str )
    self.txt_phase.text = order_str
end

--点击事件
function PetEquipStrengthenItem:SelectItem()
    self.data.panel:SelectItem(self)
end

--显示被选中时的背景图
function PetEquipStrengthenItem:ShowSelectBG(visible)
    --logError("ShowSelectBG-"..tostring(visible).."-index-"..self.data.index)
    SetVisible(self.select,visible)
end

--检查红点
function PetEquipStrengthenItem:CheckReddot()
    local flag = self.pet_equip_model:CheckStrenReddotByTarget(self.data.item)
    self.red_dot = self.red_dot or RedDot(self.transform)
    SetAnchoredPosition(self.red_dot.transform,132.4,35.7)
    self.red_dot:SetRedDotParam(flag)
end