--宠物装备套装项
PetEquipSuitItem = PetEquipSuitItem or class("PetEquipSuitItem",BaseItem)

function PetEquipSuitItem:ctor(parent_node)
    self.abName = "pet"
    self.assetName = "PetEquipSuitItem"
    self.layer = "UI"

    self.pet_equip_model = PetEquipModel.GetInstance()
    self.pet_equip_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.color_map = {}
    self.color_map[3] = "Blue"
    self.color_map[4] = "Purple"
    self.color_map[5] = "Orange"
    self.color_map[6] = "Red"
    self.color_map[7] = "Pink"

    PetEquipSuitItem.Load(self)
end

function PetEquipSuitItem:dctor()
    if table.nums(self.pet_equip_model_events) > 0 then
        self.pet_equip_model:RemoveTabListener(self.pet_equip_model_events)
        self.pet_equip_model_events = nil
    end
    self.data = nil
end

function PetEquipSuitItem:LoadCallBack(  )
    self.nodes = {
        "txt_condition_tip","txt_condition","txt_suit_name",
        "attrs/txt_suit_attr1","attrs/txt_suit_attr2","attrs/txt_suit_attr4","attrs/txt_suit_attr3","attrs/txt_suit_attr5","attrs/txt_suit_attr6",
        "btn_active","img_not_reached","img_reached",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function PetEquipSuitItem:InitUI(  )
    self.txt_suit_name = GetText(self.txt_suit_name)
    self.txt_condition_tip = GetText(self.txt_condition_tip)
    self.txt_condition = GetText(self.txt_condition)
    

    for i=1,6 do
        self["txt_suit_attr" .. i] = GetText( self["txt_suit_attr" .. i])
    end

    
end

function PetEquipSuitItem:AddEvent(  )

    --TODO:激活套装
    local function call_back(  )
        --logError("激活套装")
    end
    AddClickEvent(self.btn_active.gameObject,call_back)
end

--data
--cfg 宠物套装配置
--panel 宠物装备套装界面
function PetEquipSuitItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function PetEquipSuitItem:UpdateView()
    self.need_update_view = false

    self:UpdateSuitName()
    self:UpdateCondition()
    self:UpdateAttrs()
    self:CheckCondition()
end

--刷新名称
function PetEquipSuitItem:UpdateSuitName(  )
    --local color = ColorUtil.GetColor(self.data.cfg.com_color)
    local name = self.data.cfg.name

    --local str = string.format( "<color=#%s>%s</color>",color,name)
    local str = name
    self.txt_suit_name.text = str
end

--刷新条件
function PetEquipSuitItem:UpdateCondition ( )
    --local color = ColorUtil.GetColor(self.data.cfg.com_color)
    
    --local color_equip = string.format("<color=#%s>%s%s</color>", color, self.color_map[self.data.cfg.com_color],"装备")
    local color_equip = self.color_map[self.data.cfg.com_color] .. "Gear"
    local str = string.format( "Equip %s pcs %s Star to activate",self.data.cfg.com_sum,self.data.cfg.com_star,color_equip)

    self.txt_condition_tip.text = str
end

--刷新属性
function PetEquipSuitItem:UpdateAttrs()
     local attrs = String2Table(self.data.cfg.attr)
     local count = 1
     for k,v in pairs(attrs) do
        local text = self["txt_suit_attr" .. count]

        SetVisible(text,true)

        local type = v[1]
        local value = v[2]
        
        local value = EquipModel.GetInstance():GetAttrTypeInfo(type,value)

        local color = ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep)

        value = string.format("<color=#%s>%s</color>", color, value )

        text.text = GetAttrNameByIndex(type) .. value


        count = count + 1
     end
end

--检查是否达到可激活条件
function PetEquipSuitItem:CheckCondition()
    SetVisible(self.img_not_reached,true)
    SetVisible(self.img_reached,false)
    SetVisible(self.btn_active,false)

    --符合星数和颜色要求的装备数量
    local num = 0

    for k,v in pairs(self.pet_equip_model.cur_pet_equips) do

        local cfg = self.pet_equip_model.pet_equip_cfg[v.id][v.equip.stren_phase]

        if cfg.color >= self.data.cfg.com_color and cfg.star >= self.data.cfg.com_star then
            num = num + 1
        end
    end

    local color = ColorUtil.GetColor(ColorUtil.ColorType.White)
    if self.data.cfg.com_sum <= num then
        SetVisible(self.img_not_reached,false)
        SetVisible(self.img_reached,true)
        self.data.panel:SetReachedSuitId(self.data.cfg.id,self)
        self.data.panel:SetMaxReachedSuitIdActive()
        --SetVisible(self.btn_active,true) --不需要客户端手动激活了
        color = ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep)
    end

    self.txt_condition.text = string.format( "<color=#%s>(%s/%s)</color>",color,num,self.data.cfg.com_sum)

    

end
