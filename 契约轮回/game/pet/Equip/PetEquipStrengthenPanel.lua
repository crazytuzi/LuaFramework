--宠物装备强化界面
PetEquipStrengthenPanel = PetEquipStrengthenPanel or class("PetEquipStrengthenPanel",WindowPanel)

function PetEquipStrengthenPanel:ctor()
    self.abName = "pet"
    self.assetName = "PetEquipStrengthenPanel"
    self.layer = "UI"

    self.panel_type = 3
    self.use_background = true  
    self.is_click_bg_close = true

    self.pet_equip_model = PetEquipModel.GetInstance()
    self.pet_equip_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.strengthen_items = {} --可强化的宠物装备item列表


    --当前选中的item的索引
    self.cur_select_index = 1

    --当前选中的宠物装备Item数据
    self.cur_select_item = nil
    
    --当前强化的目标Item的goods
    self.goods_icon = nil

    --是否有足够的精华强化
    self.is_can_stren = false

    --是否有足够的材料升阶
    self.is_can_uporder = false


    --进阶界面的goods
    self.cur_order_goods_icon = nil
    self.next_order_goods_icon = nil

    self.cost_goods_icons = {}
end

function PetEquipStrengthenPanel:dctor()
    if table.nums(self.pet_equip_model_events) > 0 then
        self.pet_equip_model:RemoveTabListener(self.pet_equip_model_events)
        self.pet_equip_model_events = nil
    end

    for k,v in pairs(self.strengthen_items) do
        v:destroy()        
    end
    self.strengthen_items = nil

    if self.goods_icon then
        self.goods_icon:destroy()
        self.goods_icon = nil
    end

    if self.cur_order_goods_icon then
        self.cur_order_goods_icon:destroy()
        self.cur_order_goods_icon = nil
    end

    if self.next_order_goods_icon then
        self.next_order_goods_icon:destroy()
        self.next_order_goods_icon = nil
    end

    for k,v in pairs(self.cost_goods_icons) do
        v:destroy()        
    end
    self.cost_goods_icons = nil
end

function PetEquipStrengthenPanel:LoadCallBack(  )
    self.nodes = {
        "left/scrollview_strengthen","left/scrollview_strengthen/viewport/content","left/scrollview_strengthen/viewport",

        "right/not_equip_tip",

        "right/strengthen",
        "right/strengthen/up/strengthen_target_icon",
        "right/strengthen/up/txt_next_level","right/strengthen/up/txt_cur_level","right/strengthen/up/txt_uporder_condition","right/strengthen/up/txt_strengthen_target_name",
        "right/strengthen/middle/txt_next_strengthen_attr2","right/strengthen/middle/txt_strengthen_cost","right/strengthen/middle/txt_cur_strengthen_attr2","right/strengthen/middle/img_strengthen_cost","right/strengthen/middle/txt_cur_strengthen_attr1","right/strengthen/middle/txt_next_strengthen_attr1",
        "right/strengthen/bottom/btn_onekey_strengthen","right/strengthen/bottom/txt_progress","right/strengthen/bottom/img_progress","right/strengthen/bottom/btn_strengthen",
    
        "right/uporder",
        "right/uporder/up/next_order_icon","right/uporder/up/cur_order_icon","right/uporder/up/txt_cur_order_name","right/uporder/up/txt_next_order_name",
        "right/uporder/middle/next_order_attr",
        "right/uporder/middle/cur_order_attr/txt_cur_best_attr_value3","right/uporder/middle/cur_order_attr/txt_cur_best_attr_value4","right/uporder/middle/cur_order_attr/txt_cur_best_attr_value1","right/uporder/middle/cur_order_attr/txt_cur_base_attr_name2","right/uporder/middle/cur_order_attr/txt_cur_base_attr_value1","right/uporder/middle/cur_order_attr/txt_cur_best_attr_name4","right/uporder/middle/cur_order_attr/txt_cur_best_attr_name1","right/uporder/middle/cur_order_attr/txt_cur_best_attr_name3","right/uporder/middle/cur_order_attr/txt_cur_base_attr_value2","right/uporder/middle/cur_order_attr/txt_cur_base_attr_name1","right/uporder/middle/cur_order_attr/txt_cur_best_attr_name2","right/uporder/middle/cur_order_attr/txt_cur_best_attr_value2",
        "right/uporder/middle/next_order_attr/txt_next_best_attr_value4","right/uporder/middle/next_order_attr/txt_next_best_attr_value3","right/uporder/middle/next_order_attr/txt_next_best_attr_value1","right/uporder/middle/next_order_attr/txt_next_best_attr_name1","right/uporder/middle/next_order_attr/txt_next_best_attr_value2","right/uporder/middle/next_order_attr/txt_next_base_attr_name1","right/uporder/middle/next_order_attr/txt_next_base_attr_value2","right/uporder/middle/next_order_attr/txt_next_best_attr_name2","right/uporder/middle/next_order_attr/txt_next_best_attr_name3","right/uporder/middle/next_order_attr/txt_next_best_attr_name4","right/uporder/middle/next_order_attr/txt_next_base_attr_name2","right/uporder/middle/next_order_attr/txt_next_base_attr_value1",
        "right/uporder/bottom",
        "right/uporder/bottom/uporder_cost","right/uporder/bottom/btn_uporder",

        "right/uporder/up/cur_order_bg","right/uporder/up/next_order_bg","right/uporder/middle/arrow",
        "right/uporder/middle/cur_order_attr",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    self:SetTileTextImage("pet_image","title_strengthen")
end

function PetEquipStrengthenPanel:InitUI()
    self.txt_strengthen_target_name = GetText(self.txt_strengthen_target_name)
    self.txt_uporder_condition = GetText(self.txt_uporder_condition)
    self.txt_cur_level = GetText(self.txt_cur_level)
    self.txt_next_level = GetText(self.txt_next_level)
    self.txt_cur_strengthen_attr1 = GetText(self.txt_cur_strengthen_attr1)
    self.txt_cur_strengthen_attr2 = GetText(self.txt_cur_strengthen_attr2)
    self.txt_next_strengthen_attr1 = GetText(self.txt_next_strengthen_attr1)
    self.txt_next_strengthen_attr2 = GetText(self.txt_next_strengthen_attr2)
    self.txt_strengthen_cost = GetText(self.txt_strengthen_cost)
    self.txt_cur_order_name = GetText(self.txt_cur_order_name)
    self.txt_next_order_name = GetText(self.txt_next_order_name)

    self.txt_cur_base_attr_name1 = GetText(self.txt_cur_base_attr_name1)
    self.txt_cur_base_attr_value1 = GetText(self.txt_cur_base_attr_value1)
    self.txt_cur_base_attr_name2 = GetText(self.txt_cur_base_attr_name2)
    self.txt_cur_base_attr_value2 = GetText(self.txt_cur_base_attr_value2)

    self.txt_cur_best_attr_name1  =GetText(self.txt_cur_best_attr_name1)
    self.txt_cur_best_attr_value1  =GetText(self.txt_cur_best_attr_value1)
    self.txt_cur_best_attr_name2  =GetText(self.txt_cur_best_attr_name2)
    self.txt_cur_best_attr_value2  =GetText(self.txt_cur_best_attr_value2)
    self.txt_cur_best_attr_name3 =GetText(self.txt_cur_best_attr_name3)
    self.txt_cur_best_attr_value3  =GetText(self.txt_cur_best_attr_value3)
    self.txt_cur_best_attr_name4  =GetText(self.txt_cur_best_attr_name4)
    self.txt_cur_best_attr_value4  =GetText(self.txt_cur_best_attr_value4)

    self.txt_next_base_attr_name1 = GetText(self.txt_next_base_attr_name1)
    self.txt_next_base_attr_value1 = GetText(self.txt_next_base_attr_value1)
    self.txt_next_base_attr_name2 = GetText(self.txt_next_base_attr_name2)
    self.txt_next_base_attr_value2 = GetText(self.txt_next_base_attr_value2)

    self.txt_next_best_attr_name1 =GetText(self.txt_next_best_attr_name1)
    self.txt_next_best_attr_value1  =GetText(self.txt_next_best_attr_value1)
    self.txt_next_best_attr_name2  =GetText(self.txt_next_best_attr_name2)
    self.txt_next_best_attr_value2  =GetText(self.txt_next_best_attr_value2)
    self.txt_next_best_attr_name3 =GetText(self.txt_next_best_attr_name3)
    self.txt_next_best_attr_value3  =GetText(self.txt_next_best_attr_value3)
    self.txt_next_best_attr_name4  =GetText(self.txt_next_best_attr_name4)
    self.txt_next_best_attr_value4  =GetText(self.txt_next_best_attr_value4)

    self.img_strengthen_cost = GetImage(self.img_strengthen_cost)

    local icon_id = 90010034
    lua_resMgr:SetImageTexture(self,self.img_strengthen_cost,"iconasset/icon_goods_900",icon_id,true)
end

function PetEquipStrengthenPanel:AddEvent(  )

    --点击强化按钮
    local function call_back(  )
        if not self.is_can_stren then
            Notify.ShowText("Not enough Pet Gear Essence, can't upgrade")
            return
        end
        local cfg = self.pet_equip_model.pet_equip_cfg[self.cur_select_item.id][self.cur_select_item.equip.stren_phase]
        PetController.GetInstance():RequestPetEquipReinf(self.pet_equip_model.cur_pet_data.Config.order,cfg.slot)
    end
    AddClickEvent(self.btn_strengthen.gameObject,call_back)

    --点击升阶按钮
    local function call_back(  )
        if not self.is_can_uporder then
            Notify.ShowText("Not enough material, can't upgrade")
            return
        end
        local cfg = self.pet_equip_model.pet_equip_cfg[self.cur_select_item.id][self.cur_select_item.equip.stren_phase]
        PetController.GetInstance():RequestPetEquipUporder(self.pet_equip_model.cur_pet_data.Config.order,cfg.slot)
    end
    AddClickEvent(self.btn_uporder.gameObject,call_back)

    

    --强化或升阶的返回处理
    local function call_back(pet_id,slot,equip)
        --重新刷新Item
        for k,v in pairs(self.strengthen_items) do
            if v.data.slot == slot then
                local data = {}
                data.slot = slot
                data.item = equip
                data.panel = self
                data.index = v.data.index
                v:SetData(data)
            end
        end

    end
    self.pet_equip_model_events[#self.pet_equip_model_events + 1] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquipReinf,call_back)
    self.pet_equip_model_events[#self.pet_equip_model_events + 1] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquipUporder,call_back)
end

--data
--select_index 默认选中的item的index
function PetEquipStrengthenPanel:SetData(data)
    self.data = data
    self.cur_select_index = self.data.select_index or 1
    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function PetEquipStrengthenPanel:UpdateView()
    self.need_update_view = false

    self:UpdateItems()
end

--刷新可强化宠物装备items
function PetEquipStrengthenPanel:UpdateItems()

    --没有穿戴宠物装备
    if table.nums(self.pet_equip_model.cur_pet_equips) == 0 then
        SetVisible(self.strengthen,false)
        SetVisible(self.uporder,false)
        SetVisible(self.not_equip_tip,true)
        return
    end

    SetVisible(self.not_equip_tip,false)

    local index =  1
    for k,v in pairs(self.pet_equip_model.cur_pet_equips) do

        local cfg = self.pet_equip_model.pet_equip_cfg[v.id][v.equip.stren_phase]
       
        if cfg.color >= 4 then
            
            local item = PetEquipStrengthenItem(self.content)
            table.insert( self.strengthen_items, item)

            local data = {}
            data.slot = k
            data.item = v
            data.panel = self
            data.index = index
            item:SetData(data)

            index = index + 1
        end
    end
end

--选中Item时的处理
function PetEquipStrengthenPanel:SelectItem(target)
    for k,v in pairs(self.strengthen_items) do
        if target == v then
            v:ShowSelectBG(true)
            self.cur_select_index = v.data.index
            self.cur_select_item = v.data.item
        else
            v:ShowSelectBG(false)
        end
    end

    self:UpdateRightUI()
end

--刷新右侧UI
function PetEquipStrengthenPanel:UpdateRightUI(  )
    local cfg = self.pet_equip_model.pet_equip_cfg[self.cur_select_item.id][self.cur_select_item.equip.stren_phase]


    if self.cur_select_item.equip.stren_lv == cfg.order * 10  then
        --强化等级为 阶数 * 10，且颜色>=5才能进阶
        if cfg.color >= 5 then
            self:UpdateUporder()
        else
            --TODO:提示无法进阶
        end
       
    else

        self:UpdateStrengthen()
    end
end

--刷新右侧强化界面
function PetEquipStrengthenPanel:UpdateStrengthen(  )
    SetVisible(self.strengthen,true)
    SetVisible(self.uporder,false)
    SetVisible(self.not_equip_tip,false)

    local cfg = self.pet_equip_model.pet_equip_cfg[self.cur_select_item.id][self.cur_select_item.equip.stren_phase]

    --刷新icon
    self.goods_icon = self.goods_icon or GoodsIconSettorTwo(self.strengthen_target_icon)
    local param = {}
	param["not_need_compare"] = true
	param["p_item"] = self.cur_select_item
	param["item_id"] = self.cur_select_item.id
    param["size"] = {x = 76,y=76}
    param["cfg"] = cfg
    self.goods_icon:SetIcon(param)

    --刷新名称
    self.txt_strengthen_target_name.text = cfg.name

    --刷新进阶等级要求
    self.txt_uporder_condition.text =  cfg.order * 10

    --刷新当前强化等级与下一强化等级
    self.txt_cur_level.text = "LvL" .. self.cur_select_item.equip.stren_lv
    self.txt_next_level.text ="LvL" .. (self.cur_select_item.equip.stren_lv + 1)

    --刷新当前等级强化属性与下一级强化属性
    local slot = cfg.slot

    local stren_cfg = Config.db_pet_equip_strength[slot.."@"..self.cur_select_item.equip.stren_lv]
    local attr = String2Table(stren_cfg.attr)
    local index = 1
    for k,v in pairs(attr) do
         
        local attr_index = v[1]
		local attr_value = v[2]

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        self["txt_cur_strengthen_attr"..index].text = enumName.ATTR[attr_index] .. info
        index = index + 1
    end

    local stren_cfg = Config.db_pet_equip_strength[slot.."@"..(self.cur_select_item.equip.stren_lv + 1)]
    if not stren_cfg then
        --没有下一个强化等级
        SetVisible(self.txt_next_strengthen_attr1.gameObject,false)
        SetVisible(self.txt_next_strengthen_attr2.gameObject,false)
        SetVisible(self.txt_strengthen_cost.gameObject,false)
        SetVisible(self.btn_strengthen.gameObject,false)
        return
    end

    SetVisible(self.txt_next_strengthen_attr1.gameObject,true)
    SetVisible(self.txt_next_strengthen_attr2.gameObject,true)
    SetVisible(self.txt_strengthen_cost.gameObject,true)
    SetVisible(self.btn_strengthen.gameObject,true)

    local attr = String2Table(stren_cfg.attr)
    local index = 1
    for k,v in pairs(attr) do
         
        local attr_index = v[1]
		local attr_value = v[2]

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        self["txt_next_strengthen_attr"..index].text = enumName.ATTR[attr_index] .. info
        index = index + 1
    end

    --刷新强化消耗
    local stren_cfg = Config.db_pet_equip_strength[slot.."@"..self.cur_select_item.equip.stren_lv]
    local cost = String2Table(stren_cfg.cost)
    local have = RoleInfoModel:GetInstance():GetRoleValue(cost[1])
    have = have or 0
    local color
    if cost[2] > have then
        self.is_can_stren = false
        color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
    else
        self.is_can_stren = true
        color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
    end

    local str =  string.format("%s/%s",have,cost[2])


    self.txt_strengthen_cost.text = string.format("<color=#%s>%s</color>",color,str)

end

--刷新右侧进阶界面
function PetEquipStrengthenPanel:UpdateUporder(  )
    SetVisible(self.strengthen,false)
    SetVisible(self.uporder,true)
    SetVisible(self.not_equip_tip,false)

    local cfg = self.pet_equip_model.pet_equip_cfg[self.cur_select_item.id][self.cur_select_item.equip.stren_phase]
    local next_order_cfg = self.pet_equip_model.pet_equip_cfg[cfg.id][cfg.order + 1]
    local max_str = ""
    if next_order_cfg then
        self:OnMaxOrder(false)
    else
        self:OnMaxOrder(true)
        local color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
        max_str = string.format( "<color=#%s>%s</color>",color,"(Max)")
    end

    --刷新icon
    self.cur_order_goods_icon = self.cur_order_goods_icon or GoodsIconSettorTwo(self.cur_order_icon)
    local param = {}
	param["not_need_compare"] = true
	param["p_item"] = self.cur_select_item
	param["item_id"] = self.cur_select_item.id
    param["size"] = {x = 76,y=76}
    param["cfg"] = cfg
    self.cur_order_goods_icon:SetIcon(param)

    --刷新名称
    self.txt_cur_order_name.text = cfg.name

    --刷新基础属性
    local base_attr = String2Table(cfg.base)
    local index = 1
    for k, v in pairs(base_attr) do
        local attr_index = v[1]
		local attr_value = v[2]

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        self["txt_cur_base_attr_name" .. index].text = enumName.ATTR[attr_index]
        self["txt_cur_base_attr_value" .. index].text = info..max_str
        index = index + 1
    end
    
    --刷新极品属性
    local rare1_attr = EquipModel.GetInstance():TranslateAttr(self.cur_select_item.equip.rare1)
    local rare2_attr = EquipModel.GetInstance():TranslateAttr(self.cur_select_item.equip.rare2)
    local rare3_attr = EquipModel.GetInstance():TranslateAttr(self.cur_select_item.equip.rare3)
    index = 1
    for i=1,4 do
        SetVisible(self["txt_cur_best_attr_name" .. i],false)
        SetVisible(self["txt_cur_best_attr_value" .. i],false)
    end
    for k, v in pairs(rare1_attr) do
        local attr_index = k
		local attr_value = v

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        SetVisible(self["txt_cur_best_attr_name" .. index],true)
        SetVisible(self["txt_cur_best_attr_value" .. index],true)
        self["txt_cur_best_attr_name" .. index].text = enumName.ATTR[attr_index]
        self["txt_cur_best_attr_value" .. index].text =  info..max_str
        index = index + 1
    end
    for k, v in pairs(rare2_attr) do
        local attr_index = k
		local attr_value = v

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        SetVisible(self["txt_cur_best_attr_name" .. index],true)
        SetVisible(self["txt_cur_best_attr_value" .. index],true)
        self["txt_cur_best_attr_name" .. index].text = enumName.ATTR[attr_index]
        self["txt_cur_best_attr_value" .. index].text =  info..max_str
        index = index + 1
    end
    for k, v in pairs(rare3_attr) do
        local attr_index = k
		local attr_value = v

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        SetVisible(self["txt_cur_best_attr_name" .. index],true)
        SetVisible(self["txt_cur_best_attr_value" .. index],true)
        self["txt_cur_best_attr_name" .. index].text = enumName.ATTR[attr_index]
        self["txt_cur_best_attr_value" .. index].text =  info..max_str
        index = index + 1
    end
    


    if not next_order_cfg then
        --没有下阶了
        return
    end
   
    --刷新下阶icon
    self.next_order_goods_icon = self.next_order_goods_icon or GoodsIconSettorTwo(self.next_order_icon)
    param = {}
	param["not_need_compare"] = true
	--param["p_item"] = self.cur_select_item
	param["item_id"] = next_order_cfg.id
    param["size"] = {x = 76,y=76}
    param["cfg"] = next_order_cfg
    self.next_order_goods_icon:SetIcon(param)

    --刷新下阶名称
    self.txt_next_order_name.text = next_order_cfg.name

    --刷新下阶基础属性
    local base_attr = String2Table(next_order_cfg.base)
    index = 1
    for k, v in pairs(base_attr) do
        local attr_index = v[1]
		local attr_value = v[2]

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        self["txt_next_base_attr_name" .. index].text = enumName.ATTR[attr_index]
        self["txt_next_base_attr_value" .. index].text = info
        index = index + 1
    end

    --刷新下阶极品属性
    local next_rare1_attr = self:GetNextRareAttr(rare1_attr,String2Table(next_order_cfg.rare1))
    local next_rare2_attr = self:GetNextRareAttr(rare2_attr,String2Table(next_order_cfg.rare2))
    local next_rare3_attr = self:GetNextRareAttr(rare3_attr,String2Table(next_order_cfg.rare3))
    index = 1
    for i=1,4 do
        SetVisible(self["txt_next_best_attr_name" .. i],false)
        SetVisible(self["txt_next_best_attr_value" .. i],false)
    end
    for k, v in pairs(next_rare1_attr) do
        local attr_index = k
		local attr_value = v

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        SetVisible(self["txt_next_best_attr_name" .. index],true)
        SetVisible(self["txt_next_best_attr_value" .. index],true)
        self["txt_next_best_attr_name" .. index].text = enumName.ATTR[attr_index]
        self["txt_next_best_attr_value" .. index].text =  info
        index = index + 1
    end
    for k, v in pairs(next_rare2_attr) do
        local attr_index = k
		local attr_value = v

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        SetVisible(self["txt_next_best_attr_name" .. index],true)
        SetVisible(self["txt_next_best_attr_value" .. index],true)
        self["txt_next_best_attr_name" .. index].text = enumName.ATTR[attr_index]
        self["txt_next_best_attr_value" .. index].text =  info
        index = index + 1
    end
    for k, v in pairs(next_rare3_attr) do
        local attr_index = k
		local attr_value = v

        local info = EquipModel.GetInstance():GetAttrTypeInfo(attr_index,attr_value)
        SetVisible(self["txt_next_best_attr_name" .. index],true)
        SetVisible(self["txt_next_best_attr_value" .. index],true)
        self["txt_next_best_attr_name" .. index].text = enumName.ATTR[attr_index]
        self["txt_next_best_attr_value" .. index].text =  info
        index = index + 1
    end

    --刷新升阶消耗
    local cost = String2Table(next_order_cfg.cost)
    for k,v in pairs(self.cost_goods_icons) do
        SetVisible(v.transform,false)
    end
    index = 1
    self.is_can_uporder = true
    for k,v in pairs(cost) do

        local id = v[1]
        local num = v[2]

        local have = BagController:GetInstance():GetItemListNum(id)
        if have < num then
            self.is_can_uporder = false
        end

        self.cost_goods_icons[index] = self.cost_goods_icons[index] or GoodsIconSettorTwo(self.uporder_cost)
        SetVisible(self.cost_goods_icons[index].transform,true)
        

        param = {}
	    param["not_need_compare"] = true
	    param["item_id"] = id
        param["size"] = {x = 70,y=70}
        param["cfg"] = Config.db_item[id]
        param["need_num"] = num
        param["have_num"] = have
        param["can_click"] = true
        self.cost_goods_icons[index]:SetIcon(param)

        index = index + 1
    end

end

--获取下一阶对应的极品属性
function PetEquipStrengthenPanel:GetNextRareAttr(cur_rare_attr,next_rare_attr)
    local attr = {}
    for k,v in pairs(next_rare_attr) do
        for kk,vv in pairs(cur_rare_attr) do
            if v[1] == kk then
                attr[v[1]] = v[2]
            end
        end
    end
    return attr
end

--根据是否满阶进行不同的UI处理
function PetEquipStrengthenPanel:OnMaxOrder(is_max)



    SetVisible(self.next_order_bg,not is_max)
    SetVisible(self.next_order_icon,not is_max)
    SetVisible(self.txt_next_order_name,not is_max)

    SetVisible(self.arrow,not is_max)
    SetVisible(self.next_order_attr,not is_max)
    SetVisible(self.bottom,not is_max)

    

    if is_max then
        SetLocalPositionX(self.cur_order_bg.transform,2.7)
        SetLocalPositionX(self.cur_order_icon.transform,5)
        SetLocalPositionX(self.txt_cur_order_name.transform,1.4)
        SetLocalPositionX(self.cur_order_attr.transform,6)
    else
        SetLocalPositionX(self.cur_order_bg.transform,-145)
        SetLocalPositionX(self.cur_order_icon.transform,-142.6)
        SetLocalPositionX(self.txt_cur_order_name.transform,-146.3)
        SetLocalPositionX(self.cur_order_attr.transform,-141.7)
    end
end


