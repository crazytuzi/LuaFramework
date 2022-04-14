--宠物装备界面
PetEquipBagPanel = PetEquipBagPanel or class("PetEquipBagPanel",BaseItem)

function PetEquipBagPanel:ctor(parent_node, parent_panel)
    self.abName = "pet"
    self.assetName = "PetEquipBagPanel"
    self.layer = "UI"

    self.pet_equip_model = PetEquipModel.GetInstance()
    self.pet_equip_model_events = {}

    self.pet_model = PetModel:GetInstance()
    self.pet_model_events = {}

    self.bag_model = BagModel.GetInstance()
    self.bag_model_events = {}

    self.global_events = {}

    self.role_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.scroll_view = nil --虚拟列表

    --背包中需要显示物品的三个条件项
    self.show_order = 0
    self.show_color = 0
    self.show_slot = 8000

    local bags = BagModel.GetInstance().bags
    BagModel.GetInstance():ArrangeGoods(bags[BagModel.PetEquip].bagItems)
    self.pet_equip_items = self.pet_equip_model:GetPetEquipItems(self.show_order,self.show_color,self.show_slot)

    self.loading_items = false

    --强化按钮的红点
    self.stren_red_dot = nil

    --刷新虚拟列表的定时器id
    self.force_update_schedule_id = nil

    --是否需要强制刷新虚拟列表
    self.is_need_force_update = false

    local function call_back(  )
        if self.is_need_force_update and self.scroll_view  then
            --logError("刷新虚拟列表")
             --刷新虚拟列表
             BagModel.GetInstance():ArrangeGoods(BagModel.GetInstance().bags[BagModel.PetEquip].bagItems)
             self:UpdatePetEquipBag()
             self.is_need_force_update = false
        end
    end
    self.force_update_schedule_id = GlobalSchedule:Start(call_back)

    PetEquipBagPanel.super.Load(self)
end

function PetEquipBagPanel:dctor()
    if table.nums(self.pet_equip_model_events) > 0 then
        self.pet_equip_model:RemoveTabListener(self.pet_equip_model_events)
        self.pet_equip_model_events = nil
    end

    if table.nums(self.pet_model_events) > 0 then
        self.pet_model:RemoveTabListener(self.pet_model_events)
        self.pet_model_events = nil
    end

    if table.nums(self.bag_model_events) > 0 then
        self.bag_model:RemoveTabListener(self.bag_model_events)
        self.bag_model_events = nil
    end

    if table.nums(self.global_events) > 0 then
        GlobalEvent:RemoveTabListener(self.global_events)
        self.global_events = nil
    end

    for _, event_id in pairs(self.role_events) do
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(event_id)
    end
    self.role_events = nil

    if self.scroll_view then
        self.scroll_view:OnDestroy()
        self.scroll_view = nil
    end

    if self.stren_red_dot then
        self.stren_red_dot:destroy()
        self.stren_red_dot = nil
    end

    if self.stencil_mask then
        destroy(self.stencil_mask)
        self.stencil_mask = nil
    end

    if self.force_update_schedule_id then
        GlobalSchedule:Stop(self.force_update_schedule_id)
        self.force_update_schedule_id = nil
    end
end

function PetEquipBagPanel:LoadCallBack(  )
    self.nodes = {
        "left/title/txt_max_equip_color","left/not_active",
        --"left/equips/equip_2","left/equips/equip_4","left/equips/equip_1","left/equips/equip_3",
        "right/drops/dropdown_color","right/drops/dropdown_order","right/drops/dropdown_slot",
        "right/scrollview_bag","right/scrollview_bag/viewport/content","right/scrollview_bag/viewport",
        "right/btns/btn_suit","right/btns/btn_decompose","right/btns/btn_strengthen","right/btns/btn_inherit",
        "left/title/title_bg",
    }

    self:GetChildren(self.nodes)

    self:InitUI()
    self:SetMask()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    --local main_role_data =  RoleInfoModel.GetInstance():GetMainRoleData()
    --logError(main_role_data.id)
end

function PetEquipBagPanel:InitUI(  )
    self.txt_max_equip_color = GetText(self.txt_max_equip_color)
    self.dropdown_order = GetDropDown(self.dropdown_order)
    self.dropdown_color = GetDropDown(self.dropdown_color)
    self.dropdown_slot = GetDropDown(self.dropdown_slot)


    --虚拟列表
    local param = {}
    local cellSize = {width = 75,height = 75}
    param["scrollViewTra"] = self.scrollview_bag.transform
    param["cellParent"] = self.content
    param["cellSize"] = cellSize
    param["cellClass"] = PetEquipBagIconSettor 
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 5
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] =  Config.db_bag[BagModel.PetEquip].cap
    param["totalColumn"] = 5
    self.scroll_view = ScrollViewUtil.CreateItems(param)

    --红点
    self:CheckStrenReddot()
end

function PetEquipBagPanel:AddEvent(  )

    local function call_back(bag_id)

        if bag_id ~= BagModel.PetEquip then
            return
        end

        self.is_need_force_update = true

    end

    self.bag_model_events[#self.bag_model_events + 1] = self.bag_model:AddListener(BagEvent.LoadItemByBagId,call_back )
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(BagEvent.AddItems,call_back)
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems,call_back)

  

    local function call_back()
        self:OnPetDataUpdate()
    end
    self.pet_model_events[#self.pet_model_events + 1] = self.pet_model:AddListener(PetEvent.Pet_Model_SelectPetEvent, call_back)

    --强化按钮红点刷新
    local function call_back(  )
        self:CheckStrenReddot()
    end
    self.pet_equip_model_events[#self.pet_equip_model_events + 1] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquips, call_back)
    self.role_events[#self.role_events + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("PetEquipExp", call_back)
    -- local function call_back(  )
    --     if self.scroll_view ~= nil then
    --         logError("刷新虚拟列表")
    --         --刷新虚拟列表
    --         BagModel.GetInstance():ArrangeGoods(BagModel.GetInstance().bags[BagModel.PetEquip].bagItems)
    --         self:UpdatePetEquipBag()
    --     end
    -- end
    --self.pet_equip_model_events[#self.pet_equip_model_events + 1] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquipPutoff, call_back)
    --self.pet_equip_model_events[#self.pet_equip_model_events + 1] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquipPuton, call_back)

    --套装
    local function call_back(  )
        local panel = lua_panelMgr:GetPanelOrCreate(PetEquipSuitPanel)
		local data = {}
		panel:Open()
		panel:SetData(data)
    end
    AddClickEvent(self.btn_suit.gameObject,call_back)

    --分解
    local function call_back(  )
        local panel = lua_panelMgr:GetPanelOrCreate(PetEquipDecomposePanel)
		local data = {}
		panel:Open()
		panel:SetData(data)
    end
    AddClickEvent(self.btn_decompose.gameObject,call_back)

    --强化
    local function call_back(  )
        local panel = lua_panelMgr:GetPanelOrCreate(PetEquipStrengthenPanel)
		local data = {}
		panel:Open()
		panel:SetData(data)
    end
    AddClickEvent(self.btn_strengthen.gameObject,call_back)

    --继承
    local function call_back(  )
        local panel = lua_panelMgr:GetPanelOrCreate(PetEquipInheritPanel)
        local data = {}
        data.stencil_id = self.stencil_id
		panel:Open()
		panel:SetData(data)
    end
    AddClickEvent(self.btn_inherit.gameObject,call_back)

    --阶位筛选
    local function call_back(go, value)

        -- if value ~= 0 then
        --     value = value + 5
        -- end

        if value == self.show_order then
            return
        end

        self.show_order = value
        self.is_need_force_update = true
    end
    AddValueChange(self.dropdown_order.gameObject, call_back)

    --颜色筛选
    local function call_back(go, value)

        if value ~= 0 then
            if value == 1 then
                --点击第二个选项 映射到蓝色
                value = 3
            else
                --其他选项直接+3映射到正确的color
                value = value + 3
            end
        end

        if value == self.show_color then
            return
        end

        self.show_color = value
        self.is_need_force_update = true
    end
    AddValueChange(self.dropdown_color.gameObject, call_back)

    --部位筛选
    local function call_back(go, value)

        if value + 8000 == self.show_slot then
            return
        end

        self.show_slot = value + 8000
        self.is_need_force_update = true
    end
    AddValueChange(self.dropdown_slot.gameObject, call_back)
end

function PetEquipBagPanel:SetMask()
    self.stencil_id = GetFreeStencilId()
    self.stencil_mask = AddRectMask3D(self.viewport.gameObject)
    self.stencil_mask.id = self.stencil_id
end

--data
function PetEquipBagPanel:SetData()
    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function PetEquipBagPanel:UpdateView()
    self.need_update_view = false

    self:OnPetDataUpdate()

end

--虚拟列表Item刷新
function PetEquipBagPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function PetEquipBagPanel:UpdateCellCB(itemCLS)

    itemCLS.bag = BagModel.PetEquip
    if self.pet_equip_items ~=nil then

        --是否是符合筛选条件的宠物装备
        local itemBase = self.pet_equip_items[itemCLS.__item_index]

        --local itemBase = BagModel.GetInstance().bags[BagModel.PetEquip].bagItems[itemCLS.__item_index]

        if itemBase ~= nil and itemBase ~= 0 then
            local configItem = Config.db_item[itemBase.id]
            if configItem ~= nil then --配置表存该物品
                --type,uid,id,num,bag,bind,outTime
                local param = {}
                param["type"] = configItem.type
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = itemBase.bag
                param["bind"] = itemBase.bind
                param["itemSize"] = {x=78, y=78}
                param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
                param["model"] = self.pet_equip_model
                param["itemIndex"] = itemCLS.__item_index
                param["stencil_id"] = self.stencil_id
                --param["item"] = itemBase
                --itemCLS:DeleteItem()
                itemCLS:UpdateItem(param)
            end

        else
            local param = {}
            param["bag"] = BagModel.PetEquip
            param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["model"] = self.pet_equip_model
            --param["item"] = itemBase
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = BagModel.PetEquip
        param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["model"] = self.pet_equip_model
        --param["item"] = itemBase
        itemCLS:InitItem(param)
    end

end

function PetEquipBagPanel:GetItemDataByIndex(index)
    --return BagModel.GetInstance().bags[BagModel.PetEquip].bagItems[index]
    return self.pet_equip_items[index]
end

--当前选择的宠物刷新时调用
function PetEquipBagPanel:OnPetDataUpdate(  )
    self:UpdateActiveState()
    self:UpdatePetEquipLimit()
end

--刷新宠物激活状态
function PetEquipBagPanel:UpdateActiveState()

    --是否已激活标志
    local flag = PetEquipHelper.GetInstance():IsPetAvtive()

    SetVisible(self.not_active,not flag)
end

--刷新宠物装备Color限制
function PetEquipBagPanel:UpdatePetEquipLimit()
    -- local cfg = self.pet_equip_model.cur_pet_data.Config
    -- local equip_limit = self.pet_equip_model.cur_pet_data.Config.quality

    -- local color = ColorUtil.GetColor(equip_limit)
    -- local name = ColorUtil.GetColorName(equip_limit).. "装备"

    -- local str = string.format("<color=#%s>%s</color>", color, name )

    -- self.txt_max_equip_color.text = str

    local quatily = self.pet_equip_model.cur_pet_data.Config.quality
    if quatily <= 4 then
        SetVisible(self.title_bg.transform,false)
        SetVisible(self.txt_max_equip_color.transform,false)
       return
    end
    SetVisible(self.title_bg.transform,true)
    SetVisible(self.txt_max_equip_color.transform,true)

    local str = ""
    local color = ""
    if quatily == 5 then
        str = "Orange"
        color = ColorUtil.GetColor(ColorUtil.ColorType.Orange)
    elseif quatily == 6 then
        str = "Red 2-Star"
        color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
    elseif quatily == 7 then
        str = "Red 3-Star"
        color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
    elseif quatily == 8 then
        str = "Pink 3-Star"
        color = ColorUtil.GetColor(ColorUtil.ColorType.Pink)
    end

    str = string.format("Can equip <color=#%s>%sGear</color>", color, str )
    self.txt_max_equip_color.text = str
end

--刷新宠物装备背包
function PetEquipBagPanel:UpdatePetEquipBag(  )

    --logError("刷新宠物装备背包，阶位"..self.show_order..",颜色"..self.show_color..",部位"..self.show_slot)
    
    self.pet_equip_items = self.pet_equip_model:GetPetEquipItems(self.show_order,self.show_color,self.show_slot)
    self.scroll_view:ForceUpdate()
end 

--检查强化按钮红点
function PetEquipBagPanel:CheckStrenReddot(  )
    local flag = self.pet_equip_model:CheckStrenOrUporderReddotByTargetPet()
    self.stren_red_dot = self.stren_red_dot or RedDot(self.btn_strengthen.transform)
    SetAnchoredPosition(self.stren_red_dot.transform,57.5,20.2)
    self.stren_red_dot:SetRedDotParam(flag)
end
