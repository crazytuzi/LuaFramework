--图鉴组合项
illustrationComposeItem = illustrationComposeItem or class("illustrationComposeItem",BaseItem)

function illustrationComposeItem:ctor(parent_node)
    self.abName = "illustration"
    self.assetName = "illustrationComposeItem"
    self.layer = "UI"

    self.ill_model = illustrationModel.GetInstance()
    self.ill_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.ill_monster_items = {}  --怪物图鉴项
    self.progress = nil  --组合进度
    self.prop_items = {}  --属性信息相关UI

    self.cur_click_item_index = nil

    BaseItem.Load(self)
end

function illustrationComposeItem:dctor()
    if table.nums(self.ill_model_events) > 0 then
        self.ill_model:RemoveTabListener(self.ill_model_events)
        self.ill_model_events = nil
    end
    if table.nums(self.ill_monster_items) > 0 then
        for k,v in pairs(self.ill_monster_items) do
            v:destroy()
        end
        self.ill_monster_items = nil
    end
end

function illustrationComposeItem:LoadCallBack(  )
    self.nodes = {
        "compose/img_progress","compose/txt_compose_name","compose/txt_progress",
        "prop/prop_item3","prop/prop_item3/name3","prop/prop_item2","prop/prop_item2/name2","prop/prop_item4/value4","prop/prop_item1/name1","prop/prop_item4","prop/prop_item4/name4","prop/prop_item1","prop/prop_item2/value2","prop/prop_item3/value3","prop/prop_item1/value1",
        "scroll_view/view_port/content",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function illustrationComposeItem:InitUI(  )
    for i=1,4 do
        local prop_item = {}
        prop_item.item = self["prop_item"..i]
        prop_item.name = GetText(self["name"..i])
        prop_item.value = GetText(self["value"..i])
        table.insert(self.prop_items, prop_item)
    end

    self.img_progress = GetImage(self.img_progress)
    self.txt_progress = GetText(self.txt_progress)
    self.txt_compose_name = GetText(self.txt_compose_name)
    
end

function illustrationComposeItem:AddEvent(  )
      --图鉴信息更新
      local function call_back()
        
        if  IsGameObjectNull(self.gameObject)   then
            self:destroy()
            return
        end

        if not self.gameObject.activeInHierarchy then
            return
        end

        if not self.cur_click_item_index then
            return
        end

       
        local item = self.ill_monster_items[self.cur_click_item_index]

        if not item then
            return
        end

          --刷新当前图鉴项星数
        local cur_star_num = self.ill_model.ill_info[item.data.ill_id].star
        item:UpdateCurStarNum(cur_star_num)

        self:UpdateProgress()
        self:UpdateProps()
    end

    self.ill_model_events[#self.ill_model_events + 1] = self.ill_model:AddListener(illustrationEvent.UpStarComplete,call_back)
end

--data
--name 组件名
--ill_ids 组合图鉴的id
--props 组合属性
function illustrationComposeItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function illustrationComposeItem:UpdateView()
    self.txt_compose_name.text = self.data.name
   
    self:UpdateillustrationMonsterItem()
    self:UpdateProgress()
    self:UpdateProps()    
end

--刷新图鉴项
function illustrationComposeItem:UpdateillustrationMonsterItem()
    for i,v in ipairs(self.data.ill_ids) do
        --logError(v)
        local item = self.ill_monster_items[i] or illustrationMonsterItem(self.content,"UI")
        self.ill_monster_items[i] = item

        local ill_cfg =self.ill_model.ill_cfg[v]
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
        data.star_type = 1
        data.is_show_select = false
        data.is_show_reddot = true

        item:SetData(data)

    end

    --多出来的图鉴项UI隐藏掉
    local max_num = table.nums(self.data.ill_ids)
    for i,v in ipairs(self.ill_monster_items) do
        SetVisible(v.transform,i <= max_num)
    end
end

--刷新组合进度
function illustrationComposeItem:UpdateProgress()

    --图鉴总数
    local all_ill_num = table.nums(self.data.ill_ids)

    --每一个图鉴占的总数百分比
    local num = 100 / all_ill_num

    local counter = 0
    for k,v in pairs(self.data.ill_ids) do
        if self.ill_model.ill_info[v] then
            --已激活 计数+1
            counter = counter + 1
        end
    end

    local progress = counter * num
    
    --四舍五入留整
    progress = math.floor(progress + 0.5)

    if self.progress == progress then
        return
    end

    self.progress = progress

    self.txt_progress.text = progress .. "%"
    self.img_progress.fillAmount = progress / 100
end

--刷新组合属性
function illustrationComposeItem:UpdateProps()

    local flag = self.progress ~= 100

    for i,v in ipairs(self.data.props) do
        local name =self.ill_model:GetAttrNameByIndex(v[1]).."："
        local value = v[2]
        if flag then
            --组合属性 未激活的显示为0
            value = 0
        end
       
        local valueType = Config.db_attr_type[v[1]].type == 2
        if valueType then
            --处理百分比属性
            value = (value / 100) .. "%"
        end
        

        self.prop_items[i].name.text = name
        self.prop_items[i].value.text = value
    end

    --多余的属性UI隐藏
    local max_prop_num = table.nums(self.data.props)
    for i=1,#self.prop_items do
        SetVisible(self.prop_items[i].item,i <= max_prop_num)
    end
end



--图鉴项点击
function illustrationComposeItem:SelectItem(index)
    
    local item = self.ill_monster_items[index]
    if not item then
        --logError("图鉴项点击索引无效："..index)
        return
    end

   self.ill_model:Brocast(illustrationEvent.SelectItem,item)

   self.cur_click_item_index = index
   local panel = lua_panelMgr:GetPanelOrCreate(illustrationStarUpPanel)
   panel:Open()

   local data = {}
   data.ill_id = item.data.ill_id
   panel:SetData(data)
end