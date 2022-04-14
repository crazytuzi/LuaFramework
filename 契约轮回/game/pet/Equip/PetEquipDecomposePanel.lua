--宠物装备分解界面
PetEquipDecomposePanel = PetEquipDecomposePanel or class("PetEquipDecomposePanel",WindowPanel)

function PetEquipDecomposePanel:ctor()
    self.abName = "pet"
    self.assetName = "PetEquipDecomposePanel"
    self.layer = "UI"

    self.panel_type = 3
    self.use_background = true  
    self.is_click_bg_close = true

    self.pet_equip_model = PetEquipModel.GetInstance()
    self.pet_equip_model_events = {}

    self.bag_model = BagModel.GetInstance()
    self.bag_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.scroll_view = nil --虚拟列表

    
    --背包中需要显示物品的条件项
    self.show_order = 1
    self.show_color = 5

    self.pet_equip_decompose_items = self:GetPetEquipItems(self.show_order,self.show_color) --可显示的可分解宠物装备列表
    self.bag_smelt_items = {} --已创建的bagsmelitem列表
    self.selected_item_uids = {}  --选中了要分解的item  key为uid

    --分解获得经验
    self.decompose_get = 0
 
    --默认勾选0星
    self.select_star = 0

end

function PetEquipDecomposePanel:dctor()
    if table.nums(self.pet_equip_model_events) > 0 then
        self.pet_equip_model:RemoveTabListener(self.pet_equip_model_events)
        self.pet_equip_model_events = nil
    end

    if table.nums(self.bag_model_events) > 0 then
        self.bag_model:RemoveTabListener(self.bag_model_events)
        self.bag_model_events = nil
    end

    if self.scroll_view then
        self.scroll_view:destroy()
    end

    if self.stencil_mask then
        destroy(self.stencil_mask)
        self.stencil_mask = nil
    end
end

function PetEquipDecomposePanel:LoadCallBack(  )
    self.nodes = {
        "drops/dropdown_color","drops/dropdown_order",
        "scrollview_decompose","scrollview_decompose/viewport","scrollview_decompose/viewport/content",
        "toggle_get_double",
        "cost/img_cost","cost/txt_cost_num","get/img_get","get/txt_cost_get",
        "btn_decompose",
        "toggle_one_star",
    }

    self:GetChildren(self.nodes)

    self:InitUI()
    self:SetMask()
    self:AddEvent()


    if self.need_update_view then
       self:UpdateView()
    end

    self:SetTileTextImage("pet_image","title_decompose")
end

function PetEquipDecomposePanel:InitUI(  )
    self.txt_cost_get = GetText(self.txt_cost_get)
    self.dropdown_color = GetDropDown(self.dropdown_color)
    self.dropdown_order = GetDropDown(self.dropdown_order)

    self.toggle_one_star = GetToggle(self.toggle_one_star)

    self.img_get = GetImage(self.img_get)

    local icon_id = 90010034
    lua_resMgr:SetImageTexture(self,self.img_get,"iconasset/icon_goods_900",icon_id,true)

    --初始筛选橙色及以下与1阶的
    self.dropdown_color.value = 1
    self.dropdown_order.value = 1

    --初始默认选中全部
    self:SelectAll(true)

    self:CreateItems()
end

function PetEquipDecomposePanel:AddEvent(  )
    
    --阶位筛选
    local function call_back(go, value)

        if value == self.show_order then
            return
        end

        self.show_order = value
        self:UpdatePetEquipDecomposeItems()
    end
    AddValueChange(self.dropdown_order.gameObject, call_back)

    --颜色筛选
    local function call_back(go, value)

        if value ~= 0 then
            value = value + 4
        end

        if value == self.show_color then
            return
        end

        self.show_color = value
        self:UpdatePetEquipDecomposeItems()
    end
    AddValueChange(self.dropdown_color.gameObject, call_back)

    --选中一星装备
    local function call_back(target, value)
        --logError("选中一星装备")

		if value then
            self.select_star = 1
            self:SelectAll(true)
            self.scroll_view:ForceUpdate()
		else
            self.select_star = 0

            --取消一星选中
            for k,v in pairs(self.pet_equip_decompose_items) do

                local cfg = self.pet_equip_model.pet_equip_cfg[v.id][v.misc.stren_phase]

                if cfg.star == 1 then
                      
                    self:SelectTarget(v.id,v.uid,v.misc.stren_phase,false)
                end

            end

            self.scroll_view:ForceUpdate()

        end


        
	end
	AddValueChange(self.toggle_one_star.gameObject, call_back)

    --确定分解
    local function call_back(  )
        --logError("确定分解")
        if table.nums(self.selected_item_uids) == 0 then
            Notify.ShowText("Select the gears which need to be dismantled")
            return
        end

        PetController.GetInstance():RequestPetEquipSmelt(self.selected_item_uids)
        self:Close()
    end
    AddClickEvent(self.btn_decompose.gameObject,call_back)



    local function call_back(pitem)
        self:SelectItem(pitem)
    end
    self.bag_model_events[#self.bag_model_events+1] = self.bag_model:AddListener(BagEvent.SmeltItemClick, call_back)
end

--data
function PetEquipDecomposePanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function PetEquipDecomposePanel:UpdateView()
    self.need_update_view = false

end

function PetEquipDecomposePanel:SetMask()
    self.stencil_id = GetFreeStencilId()
    self.stencil_mask = AddRectMask3D(self.viewport.gameObject)
    self.stencil_mask.id = self.stencil_id
end

--创建虚拟列表
function PetEquipDecomposePanel:CreateItems()

    local param = {}
    local cellSize = {width = 70,height = 70}
    param["scrollViewTra"] = self.scrollview_decompose.transform
    param["cellParent"] = self.content
    param["cellSize"] = cellSize
    param["cellClass"] = BagSmeltItem 
    param["begPos"] = Vector2(47,-50)
    param["spanX"] = 12.5
    param["spanY"] = 12.25
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] =  Config.db_bag[BagModel.PetEquip].cap
    self.scroll_view = ScrollViewUtil.CreateItems(param)
end


function PetEquipDecomposePanel:GetItemDataByIndex(index)
    return self.pet_equip_decompose_items[index]
end


--虚拟列表Item刷新
function PetEquipDecomposePanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function PetEquipDecomposePanel:UpdateCellCB(itemCLS)

    local index = itemCLS.__item_index
    local item = self.pet_equip_decompose_items[index]
    itemCLS:SetData(item, self:IsSelect(item), self.stencil_id)
    if item then
        self.bag_smelt_items[index] = itemCLS
    end

end

--是否选中
function PetEquipDecomposePanel:IsSelect(pitem)
    if not pitem then
        return false
    end
    return self.selected_item_uids[pitem.uid]
end

--刷新要显示的可分解宠物装备
function PetEquipDecomposePanel:UpdatePetEquipDecomposeItems(  )

    --logError("刷新可分解宠物装备，阶位"..self.show_order..",颜色"..self.show_color)

    self:SelectAll(false)

    self.pet_equip_decompose_items = self:GetPetEquipItems(self.show_order,self.show_color)

    self:SelectAll(true)
    self.scroll_view:ForceUpdate()
    
end 

--获取需要显示的宠物装备
function PetEquipDecomposePanel:GetPetEquipItems(order,color)
    order = order or 0
    color = color or 0



    local items = BagModel.GetInstance().bags[BagModel.PetEquip].bagItems
    if not items then
        --没有宠物装备背包物品信息
        return {}
    end

    local result = {}

    for k,v in pairs(items) do
        local cfg = self.pet_equip_model.pet_equip_cfg[v.id][v.misc.stren_phase]
        --只能分解星数<2和强化等级0的
        if (order == 0 or cfg.order == order) and (color == 0 or cfg.color <= color) and cfg.star < 2 and v.misc.stren_lv == 0  then
            table.insert(result,v)
        end
    end

    return result
end

--点击了要分解的宠物装备
function PetEquipDecomposePanel:SelectItem(pitem)

    if self.selected_item_uids[pitem.uid] then
        --取消选中
        self:SelectTarget(pitem.id,pitem.uid,pitem.misc.stren_phase,false)
    else
        --选中
        self:SelectTarget(pitem.id,pitem.uid,pitem.misc.stren_phase,true)
    end
end

--选中或取消选中所有显示的可分解宠物装备
function PetEquipDecomposePanel:SelectAll(select)
    for k,v in pairs(self.pet_equip_decompose_items) do

        local cfg = self.pet_equip_model.pet_equip_cfg[v.id][v.misc.stren_phase]

       
        if select then
             --选中的话，进行星数检查
            if cfg.star <= self.select_star then
                --logError("星数检查，目标星数-"..self.select_star.."，自身星数-".. cfg.star .."，结果-"..tostring(true))
                self:SelectTarget(v.id,v.uid,v.misc.stren_phase,true)
            else
                --星数不对就取消选中
                --logError("星数检查，目标星数-"..self.select_star.."，自身星数-".. cfg.star .."，结果-"..tostring(false))
                self:SelectTarget(v.id,v.uid,v.misc.stren_phase,false)
            end
        else
            --取消选中的话，就不进行星数检查了，全部都取消选中
            self:SelectTarget(v.id,v.uid,v.misc.stren_phase,false)
        end
     
        
    end
end

--选中目标物品
function PetEquipDecomposePanel:SelectTarget(id,uid,order,select)

    local get = 0
    local cfg = self.pet_equip_model.pet_equip_cfg[id][order]

    if select then

        if not self.selected_item_uids[uid] then
            self.selected_item_uids[uid] = true
            get = cfg.exp
        end

    else

        if self.selected_item_uids[uid] then
            self.selected_item_uids[uid] = nil
            get = -cfg.exp
        end

    end

    self.decompose_get = self.decompose_get + get
    self.txt_cost_get.text = self.decompose_get
end
