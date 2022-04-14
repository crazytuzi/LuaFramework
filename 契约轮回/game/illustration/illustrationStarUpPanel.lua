--点击有组合的图鉴项后弹出升星界面
illustrationStarUpPanel = illustrationStarUpPanel or class("illustrationStarUpPanel",WindowPanel)

function illustrationStarUpPanel:ctor(parent_node)
    self.abName = "illustration"
    self.assetName = "illustrationStarUpPanel"
    self.layer = "UI"

    self.panel_type = 4
    self.use_background = true  
    self.is_click_bg_close = true

    self.ill_model = illustrationModel.GetInstance()
    self.ill_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
    self.ill_item = nil
    self.icon_settor_1 = nil
    self.icon_settor_2 = nil
    self.prop_items = {}

    self.enough = true  --升星材料是否足够
    self.not_enough_tip = nil --材料不够时的提示文本
end

function illustrationStarUpPanel:dctor()
    if table.nums(self.ill_model_events) > 0 then
        self.ill_model:RemoveTabListener(self.ill_model_events)
        self.ill_model_events = nil
    end

    if self.ill_item then
        self.ill_item:destroy()
        self.ill_item = nil
    end
    if self.icon_settor_1 then
        self.icon_settor_1:destroy()
        self.icon_settor_1 = nil
    end
    if self.icon_settor_2 then
        self.icon_settor_2:destroy()
        self.icon_settor_2 = nil
    end
end

function illustrationStarUpPanel:LoadCallBack(  )
    self.nodes = {
        "ill_content",
        "prop_item1/next_value1","prop_item4/name4","prop_item3/cur_value3","prop_item1/name1","prop_item2/next_value2","prop_item4/cur_value4","prop_item3","prop_item4","prop_item2/name2","prop_item1/cur_value1","prop_item3/name3","prop_item3/next_value3","prop_item2/cur_value2","prop_item2","prop_item4/next_value4","prop_item1",
        "prop_item4/arrow4","prop_item1/arrow1","prop_item2/arrow2","prop_item3/arrow3",
        "icon1","txt_or","icon2",
        "btn_star_up","btn_star_up/txt_star_up",
        "txt_essence_num",
        "img_max_star",
        "txt_power",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    self:SetTileTextImage("illustration_image","title_star_up",false)
end

function illustrationStarUpPanel:InitUI(  )
    self.txt_star_up = GetText(self.txt_star_up)
    self.txt_essence_num = GetText(self.txt_essence_num)
    self.txt_power = GetText(self.txt_power)

    for i=1,4 do
        local prop_item = {}
        prop_item.item = self["prop_item"..i]
        prop_item.name = GetText(self["name"..i])
        prop_item.cur_value = GetText(self["cur_value"..i])
        prop_item.next_value = GetText(self["next_value"..i])
        prop_item.arrow = self["arrow"..i]
        table.insert(self.prop_items, prop_item)
    end
end

function illustrationStarUpPanel:AddEvent(  )

    local item = self.ill_item

     --图鉴信息更新
    local function call_back()
        self:UpdateView()
    end

    self.ill_model_events[#self.ill_model_events + 1] = self.ill_model:AddListener(illustrationEvent.UpStarComplete,call_back)


    --图鉴升星按钮
    local function call_back(  )

        if not self.enough then
            Notify.ShowText(self.not_enough_tip)
            return
        end

        illustrationController.GetInstance():RequestUpStar(self.data.ill_id)
    end
    AddClickEvent(self.btn_star_up.gameObject,call_back)
end

--data
function illustrationStarUpPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function illustrationStarUpPanel:UpdateView()
    self.need_update_view = false

    self:Updateillustration()
    self:UpdatePropsAndNeedItem()
end

--刷新图鉴项
function illustrationStarUpPanel:Updateillustration(  )

    self.ill_item = self.ill_item or illustrationMonsterItem(self.ill_content,"UI")
    local ill_id = self.data.ill_id
    local ill_cfg = self.ill_model.ill_cfg[ill_id]
    local data = {}
    data.ill_id = ill_id
    data.name = ill_cfg.name
    data.monster_id = ill_cfg.bossid
    data.type = ill_cfg.leftcorner
    data.layer = ill_cfg.rightcorner
    data.color_num = ill_cfg.color
    data.cur_star_num = 0
    if self.ill_model.ill_info[ill_id] then
        data.cur_star_num = self.ill_model.ill_info[ill_id].star
    end
    data.max_star_num =  ill_cfg.max_star
    data.star_type = 1
    data.is_show_reddot = false
    data.scale = 0.9
    self.ill_item:SetData(data)

   
end

--刷新属性和升级消耗
function illustrationStarUpPanel:UpdatePropsAndNeedItem(  )
    local item = self.ill_item

    local cur_star_cfg = self.ill_model.star_cfg[item.data.ill_id][item.data.cur_star_num]
    local next_star_cfg = self.ill_model.star_cfg[item.data.ill_id][item.data.cur_star_num + 1]
    local cur_prop
    local next_prop
    if not cur_star_cfg then
        --0星 本星属性全部处理为0
        cur_prop = String2Table(next_star_cfg.attr)
        for i,v in ipairs(cur_prop) do
            cur_prop[i][2] = 0
        end

        self.txt_star_up.text = "Activate"
        self.not_enough_tip = "Insufficient activation items"
    else
        cur_prop = String2Table(cur_star_cfg.attr)

        self.txt_star_up.text = "Star up"
        self.not_enough_tip = "Star up item missing"
    end

    if not next_star_cfg then
        --满星 下星属性用本星属性代替
        next_prop = cur_prop
    else
        next_prop = String2Table(next_star_cfg.attr)
    end

    --属性
    for i=1,#cur_prop do
        local name = self.ill_model:GetAttrNameByIndex(cur_prop[i][1]).."："
        local cur_value = cur_prop[i][2]
        local next_value = next_prop[i][2]
        local valueType = Config.db_attr_type[cur_prop[i][1]].type == 2
        if valueType then
            --处理百分比属性
            cur_value = (cur_value / 100) .. "%"
            next_value = (next_value / 100) .. "%"
        end

        self.prop_items[i].name.text = name
        self.prop_items[i].cur_value.text = cur_value
        self.prop_items[i].next_value.text = next_value
    end

    --战力
    local power = GetPowerByConfigList(cur_prop)
    self.txt_power.text = power

    --多余的隐藏
    local max_prop_num = table.nums(cur_prop)
    for i=1,#self.prop_items do
        SetVisible(self.prop_items[i].item,i <= max_prop_num)
    end

    if not next_star_cfg then
        --满星了
        SetVisible(self.icon1,false)
        SetVisible(self.icon2,false)
        SetVisible(self.icon3,false)
        SetVisible(self.txt_or,false)
        SetVisible(self.btn_star_up,false)
        SetVisible(self.txt_essence_num,false)
        SetVisible(self.img_max_star,true)

        --处理满星时的属性显示
        for i=1,4 do
            SetVisible(self.prop_items[i].next_value,false)
            SetVisible(self.prop_items[i].arrow,false)

            SetLocalPositionX(self.prop_items[i].item,152)
        end
        

        return
    end
    

    SetVisible(self.img_max_star,false)
    SetVisible(self.btn_star_up,true)

    --处理非满星时的属性显示
    for i=1,4 do
        SetVisible(self.prop_items[i].next_value,true)
        SetVisible(self.prop_items[i].arrow,true)

        SetLocalPositionX(self.prop_items[i].item,113)
    end

   

    --升级消耗
    
    SetVisible(self.btn_star_up,true)

    local item = String2Table(next_star_cfg.item)
    local essence = String2Table(next_star_cfg.essence)

    self.enough = false

    local item_have = self.ill_model:GetillItemNumByItemID(item[1][1])
    local item_need = item[1][2]
    local essence_have
    local essence_need

    if item_need <= item_have then
        self.enough = true
    end

    --物品Icon
    self.icon_settor_1 = self.icon_settor_1 or GoodsIconSettorTwo(self.icon1)
    local param = {}
	param["item_id"] = item[1][1]
    param["size"] = {x=65,y=65}
	param["can_click"] = true
	param["color_effect"] = 4
    param["effect_type"] = 2
    param["need_num"] = item[1][2]
    param["have_num"] = self.ill_model:GetillItemNumByItemID(item[1][1])
    self.icon_settor_1:SetIcon(param)

    local settor_index = 1
    local icon1 =self.icon1


    local is_show_essence = false
    if table.nums(essence) > 0 then

        essence_have = self.ill_model:GetillItemNumByItemID(essence[1][1])
        essence_need = essence[1][2]

        if essence_need <= essence_have then
            self.enough = true
        end

        --物品和材料同时满足 只显示物品消耗
        if item_have >= item_need and essence_have >= essence_need then
            is_show_essence = false
        else
            is_show_essence = true
        end
    end

    if not is_show_essence then
        SetVisible(self.icon2,false)
        SetVisible(self.txt_or,false)
        SetVisible(self.txt_essence_num,false)
    else
        SetVisible(self.icon2,true)
        SetVisible(self.txt_or,true)
        SetVisible(self.txt_essence_num,true)
        
        --材料Icon
        local essence = String2Table(next_star_cfg.essence)
      --[[   self.icon_settor_2 = self.icon_settor_2 or GoodsIconSettorTwo(self.icon2)
        local param = {}
	    param["item_id"] = essence[1][1]
        param["size"] = {x=50,y=50}
	    param["can_click"] = true
	    param["color_effect"] = 4
        param["effect_type"] = 2
      
        self.icon_settor_2:SetIcon(param)   
 ]]
        local color
        if essence_need <= essence_have then
            color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
        else
            color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
        end
        local str = string.format("<color=#%s>%s</color>",color,essence_need)

        self.txt_essence_num.text  =  str
    end
    
end