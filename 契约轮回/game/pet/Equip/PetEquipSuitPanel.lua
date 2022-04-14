--宠物装备套装界面
PetEquipSuitPanel = PetEquipSuitPanel or class("PetEquipSuitPanel",WindowPanel)

function PetEquipSuitPanel:ctor()
    self.abName = "pet"
    self.assetName = "PetEquipSuitPanel"
    self.layer = "UI"

    self.panel_type = 3
    self.use_background = true  
    self.is_click_bg_close = true

    self.pet_equip_model = PetEquipModel.GetInstance()
    self.pet_equip_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.pet_model = nil  --宠物模型

    self.suit_items = {}  --套装Item列表
    self.pet_equip_items = {} --宠物装备item列表

    self.reached_suit_id_list = {}  --已激活的套装id列表
end

function PetEquipSuitPanel:dctor()
    if table.nums(self.pet_equip_model_events) > 0 then
        self.pet_equip_model:RemoveTabListener(self.pet_equip_model_events)
        self.pet_equip_model_events = nil
    end

    if self.pet_model then
        self.pet_model:destroy()
    end

    if table.nums(self.suit_items) > 0 then
        for k,v in pairs(self.suit_items) do
            v:destroy()
        end
    end
    self.suit_items = nil
    self.reached_suit_id_list = nil

    for k,v in ipairs(self.pet_equip_items) do
        v:destroy()
    end
    self.pet_equip_items = nil

end

function PetEquipSuitPanel:LoadCallBack(  )
    self.nodes = {
        "model_parent","txt_name",
        "equips/equip_8002","equips/equip_8003","equips/equip_8004","equips/equip_8001",
        "scrollview_suit/viewport/content",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    self:SetTileTextImage("pet_image","title_suit")
end

function PetEquipSuitPanel:InitUI(  )
    self.txt_name = GetText(self.txt_name)

end

function PetEquipSuitPanel:AddEvent(  )
    self.pet_equip_model_events[#self.pet_equip_model_events] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquips,handler(self, self.UpdatePetEquip))
end

--data
function PetEquipSuitPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function PetEquipSuitPanel:UpdateView()
    self.need_update_view = false

    self:UpdateModel()
    self:UpdatePetEquip()
    self:UpdateSuitItems()

end

--刷新宠物模型
function PetEquipSuitPanel:UpdateModel()
    local pet_data = self.pet_equip_model.cur_pet_data

    --宠物名字
    if pet_data.Config.type == 2 then
        self.txt_name.text = string.format("%s  %s", ConfigLanguage.Pet.ActivityType, pet_data.Config.name)
    else
        self.txt_name.text = string.format("T%s  %s", ChineseNumber(pet_data.Config.order_show), pet_data.Config.name)
    end


    --模型显示
    self.pet_model = UIPetCamera(self.model_parent, nil, pet_data.Config.model, nil, nil, LuaPanelManager:GetInstance():GetPanelInLayerIndex(self.layer, self))

    local located = String2Table(pet_data.Config.located)
    local config = {}
    config.offset = { x = located[1] or 0, y = located[2] or 0, z = located[3] or 0 }
    self.pet_model:SetConfig(config)

end

--刷新套装列表
function PetEquipSuitPanel:UpdateSuitItems(  )
    local cfg = self.pet_equip_model.suit_cfg[self.pet_equip_model.cur_pet_data.Config.id]
    local index =  1
    for k,v in pairs(cfg) do
        self.suit_items[index] = self.suit_items[index] or PetEquipSuitItem(self.content)
        local data = {}
        data.cfg = v
        data.panel = self
        self.suit_items[index]:SetData(data)

        index = index + 1
    end
end

--刷新宠物装备
function PetEquipSuitPanel:UpdatePetEquip()
    for k,v in pairs(self.pet_equip_model.cur_pet_equips) do
        self.pet_equip_items[k] =  self.pet_equip_items[k] or PetEquipItem(self["equip_"..k])
        local data = {}
        data.item = v
        self.pet_equip_items[k]:SetData(data)
    end
end

--设置已激活的套装id列表
function PetEquipSuitPanel:SetReachedSuitId(id,item)
    self.reached_suit_id_list[id] = item
end

--设置最大已激活套装id的“已激活”图标显示
function PetEquipSuitPanel:SetMaxReachedSuitIdActive()
    local max_id_item = nil
    for k,v in pairs(self.reached_suit_id_list) do
        SetVisible(v.img_reached,false)
        max_id_item = v
    end
    SetVisible(max_id_item.img_reached,true)

end
