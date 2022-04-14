--右侧无组合的普通图鉴界面
illustrationRightNormalPanel = illustrationRightNormalPanel or class("illustrationRightNormalPanel",BaseItem)

function illustrationRightNormalPanel:ctor (parent_node)
    self.abName = "illustration"
    self.assetName = "illustrationRightNormalPanel"
    self.layer = "UI"

    self.ill_model = illustrationModel.GetInstance()
    self.ill_model_events = {}
    self.bag_model = BagModel.GetInstance()
    self.bag_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.top_btns = {}  --三级菜单UI项
    self.cur_select_top_btn_index = nil  --当前选择的三级菜单索引

    self.ill_monster_items = {}  --怪物图鉴项
    self.cur_select_monster_index = nil  --当前点击的图鉴项索引
    self.ill_id_and_monster_item_map = {} --图鉴id与图鉴项的映射
    
    self.prop_items = {}  --属性信息相关UI

    self.icon_settors = {}  --物品icon相关UI

    self.enough = true  --升星材料是否足够
    self.not_enough_tip = nil  --材料不够时的提示文本

    BaseItem.Load(self)
end

function illustrationRightNormalPanel:dctor ()
    if table.nums(self.top_btns) > 0 then
        for k,v in pairs(self.top_btns) do
            v:destroy()
        end
        self.top_btns = nil
    end
    if table.nums(self.ill_monster_items) > 0 then
        for k,v in pairs(self.ill_monster_items) do
            v:destroy()
        end
        self.ill_monster_items = nil
    end
    if table.nums(self.icon_settors) > 0 then
        for k,v in pairs(self.icon_settors) do
            v:destroy()
        end
        self.ill_monster_items = nil
    end
    if table.nums(self.ill_model_events) > 0 then
        self.ill_model:RemoveTabListener(self.ill_model_events)
        self.ill_model_events = nil
    end
    if table.nums(self.bag_model_events) > 0 then
        self.bag_model:RemoveTabListener(self.bag_model_events)
        self.bag_model_events = nil
    end

    self.ill_id_and_monster_item_map = nil
end

function illustrationRightNormalPanel:LoadCallBack()
    self.nodes = {
        "top_scroll_view/view_port/top_content",
        "mid_scroll_view/view_port/mid_content",
        "ill_star_up/btn_star_up/txt_star_up","ill_star_up/btn_star_up",
       
        "ill_star_up/prop_item2/arrow2","ill_star_up/prop_item4/name4","ill_star_up/prop_item4/cur_value4","ill_star_up/prop_item3/arrow3","ill_star_up/prop_item3/next_value3","ill_star_up/prop_item2","ill_star_up/prop_item2/name2","ill_star_up/prop_item2/next_value2","ill_star_up/prop_item3/name3","ill_star_up/prop_item3/cur_value3","ill_star_up/prop_item2/cur_value2","ill_star_up/prop_item3","ill_star_up/prop_item4/arrow4","ill_star_up/prop_item4/next_value4","ill_star_up/prop_item4","ill_star_up/prop_item1/arrow1","ill_star_up/prop_item1","ill_star_up/prop_item1/cur_value1","ill_star_up/prop_item1/next_value1","ill_star_up/prop_item1/name1",

        "ill_star_up/icon2","ill_star_up/txt_or","ill_star_up/icon3","ill_star_up/icon1",
        "ill_star_up/txt_essence_num",
        "ill_star_up/img_max_star",
        "ill_star_up/txt_power",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function illustrationRightNormalPanel:InitUI( )
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

function illustrationRightNormalPanel:AddEvent( )

    --图鉴信息更新
    local function call_back()
        if not self.gameObject.activeInHierarchy then
            return
        end

        --刷新当前三级菜单项进度
        if self.cur_select_top_btn_index ~= 0 then
            local top_btn = self.top_btns[self.cur_select_top_btn_index]
            local progress = self:GetTopBtnProgress(self.cur_select_top_btn_index)
            top_btn:UpdateProgress(progress)    
        end
     
         --刷新当前图鉴项星数
        local item = self.ill_monster_items[self.cur_select_monster_index]
        
        if not item then
            return
        end

        local info= self.ill_model.ill_info[item.data.ill_id]
        if not info then
            return
        end

        local cur_star_num = info.star
        item:UpdateCurStarNum(cur_star_num)

        --刷新升星界面信息
        --self:UpdateStarUp()
    end

    self.ill_model_events[#self.ill_model_events + 1] = self.ill_model:AddListener(illustrationEvent.UpStarComplete,call_back)


     --图鉴背包信息刷新
    local function call_back()
        --刷新升星界面信息
        self:UpdateStarUp()
    end
    self.bag_model_events[#self.bag_model_events+1] = self.bag_model:AddListener(illustrationEvent.LoadillustrationItems, call_back)

    --图鉴升星按钮
    local function call_back()

        if not self.enough then
            Notify.ShowText(self.not_enough_tip)
            return
        end

        local item =self.ill_monster_items[self.cur_select_monster_index]
        local ill_id = item.data.ill_id
        illustrationController.GetInstance():RequestUpStar(ill_id)

    end
    AddClickEvent(self.btn_star_up.gameObject,call_back)

end

--data
--top_btn_config 三级菜单配置
function illustrationRightNormalPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function illustrationRightNormalPanel:UpdateView(  )
    self.need_update_view = false

    self:UpdateTopBtn()
    
end

--刷新三级菜单项
function illustrationRightNormalPanel:UpdateTopBtn()
    if self.data.top_btn_config[0] then
        --没有三级菜单
        --logError("没有三级菜单")
        for k,v in pairs(self.top_btns) do
            --隐藏三级菜单项
            SetVisible(v.transform,false)
        end
        
        self.cur_select_top_btn_index = 0
    else
        --有三级菜单
        --logError("有三级菜单")
        for i,v in ipairs(self.data.top_btn_config) do
            --实例化三级菜单项
            local top_btn = self.top_btns[i] or illustrationTopButtonItem(self.top_content,"UI")
            local data = {}
            data.name = v.sname
            data.panel = self
            data.first_id = self.data.top_btn_config.first_id
            data.second_id = self.data.top_btn_config.second_id
            data.index = i
            data.is_default_select = i == 1
            data.progress = self:GetTopBtnProgress(i)

            top_btn:SetData(data)

            SetVisible(top_btn.transform,true)
            self.top_btns[i] = top_btn
        end

          --多出来的三级菜单UI隐藏掉
          local count = 0
          for k,v in pairs(self.data.top_btn_config) do
               if type(v) == "table" then
                   count = count + 1
               end
          end

          local max_num = count
          for i,v in ipairs(self.top_btns) do
            SetVisible(v.transform,i <= max_num)
          end


        self.cur_select_top_btn_index = 1
    end

    --默认选中的三级菜单
    self:SelectTopBtn(self.cur_select_top_btn_index)
end

--选中三级菜单项
function illustrationRightNormalPanel:SelectTopBtn(index)

    self.cur_select_top_btn_index = index

    for i,v in ipairs(self.top_btns) do
        v:Select(i == index)
    end
    
    --切换三级菜单后默认选中第一个图鉴项
    self.cur_select_monster_index = 1

    self:Updateillustration()
end

--刷新图鉴
function illustrationRightNormalPanel:Updateillustration()
    --logError("刷新图鉴-"..self.cur_select_top_btn_index)
    local cfg =  self.data.top_btn_config[self.cur_select_top_btn_index]

    --刷新图鉴项UI

    self.ill_id_and_monster_item_map = {}

    for i,v in ipairs(cfg.ill_id) do
        --logError(v)
        local item = self.ill_monster_items[i] or illustrationMonsterItem(self.mid_content,"UI")
        self.ill_monster_items[i] = item
        self.ill_id_and_monster_item_map[v] = item

        local ill_cfg = self.ill_model.ill_cfg[v]

        local data = {}
        data.index = i
        data.ill_id = v
        data.name = ill_cfg.name
        data.monster_id = ill_cfg.bossid
        data.type = ill_cfg.leftcorner
        data.layer = ill_cfg.rightcorner
        data.color_num = ill_cfg.color
        data.cur_star_num = 0
        if self.ill_model.ill_info[v] then
            data.cur_star_num = self.ill_model.ill_info[v].star
        end
        data.max_star_num =  ill_cfg.max_star
        data.panel = self
        data.star_type = 2
        data.is_default_select = i == self.cur_select_monster_index
        data.is_show_select = true
        data.is_show_reddot = true

        item:SetData(data)

    end

    --多出来的图鉴项UI隐藏掉
    local max_num = table.nums(cfg.ill_id)
    for i,v in ipairs(self.ill_monster_items) do
        SetVisible(v.transform,i <= max_num)
    end
end

--获取三级菜单项进度
function illustrationRightNormalPanel:GetTopBtnProgress(index)

    local cfg =  self.data.top_btn_config[index]

    --图鉴总数
    local all_ill_num = table.nums(cfg.ill_id)

    --每一个图鉴占的总数百分比
    local num = 100 / all_ill_num

    local counter = 0
    for k,v in pairs(cfg.ill_id) do
        if self.ill_model.ill_info[v] then
            --已激活 计数+1
            counter = counter + 1
        end
    end

    local progress = counter * num

    --四舍五入留整
    progress = math.floor(progress + 0.5)

    return progress
end

--图鉴项点击
function illustrationRightNormalPanel:SelectItem(index)

    local item = self.ill_monster_items[index]
    if not item then
        --logError("图鉴项点击索引无效："..index)
        return
    end
    self.cur_select_monster_index = index

    self.ill_model:Brocast(illustrationEvent.SelectItem,index)

    self:UpdateStarUp()
end

--刷新升星界面信息
function illustrationRightNormalPanel:UpdateStarUp()
    local item =self.ill_monster_items[self.cur_select_monster_index]

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

            SetLocalPositionX(self.prop_items[i].item,42)
        end
        

        return

    end

    SetVisible(self.img_max_star,false)
    SetVisible(self.btn_star_up,true)

    --处理非满星时的属性显示
    for i=1,4 do
        SetVisible(self.prop_items[i].next_value,true)
        SetVisible(self.prop_items[i].arrow,true)

        SetLocalPositionX(self.prop_items[i].item,0)
    end



    --升级消耗

    local item = String2Table(next_star_cfg.item)
    local essence = String2Table(next_star_cfg.essence)

    local settor_index = 1
    local icon1 =self.icon1

    self.enough = false

    local item_have = self.ill_model:GetillItemNumByItemID(item[1][1])
    local item_need = item[1][2]
    local essence_have
    local essence_need

    if item_need <= item_have then
        self.enough = true
    end

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
        SetVisible(self.icon1,true)
        SetVisible(self.icon2,false)
        SetVisible(self.icon3,false)
        SetVisible(self.txt_or,false)
        SetVisible(self.txt_essence_num,false)
        settor_index = 1
        icon1 = self.icon1
    else
        SetVisible(self.icon1,false)
        SetVisible(self.icon2,true)
        SetVisible(self.icon3,true)
        SetVisible(self.txt_or,true)
        SetVisible(self.txt_essence_num,true)

        settor_index = 2
        icon1 = self.icon2

        --材料icon
       
      --[[   self.icon_settors[3] = self.icon_settors[3] or GoodsIconSettorTwo(self.icon3)
        local param = {}
	    param["item_id"] = essence[1][1]
        param["size"] = {x=50,y=50}
	    param["can_click"] = true
	    param["color_effect"] = 4
        param["effect_type"] = 2
        param["bind"] = 2
        self.icon_settors[3]:SetIcon(param)    ]]



        local color
        if essence_need <= essence_have then
            color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
        else
            color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
        end
        local str = string.format("<color=#%s>%s</color>",color,essence_need)

        self.txt_essence_num.text  =  str
    end

    --物品icon
    self.icon_settors[settor_index] = self.icon_settors[settor_index] or GoodsIconSettorTwo(icon1)
    local param = {}
	param["item_id"] = item[1][1]
    param["size"] = {x=80,y=80}
	param["can_click"] = true
	param["color_effect"] = 4
    param["effect_type"] = 2
    param["need_num"] = item[1][2]
    param["have_num"] = self.ill_model:GetillItemNumByItemID(item[1][1])
    self.icon_settors[settor_index]:SetIcon(param)

end
