--宠物装备继承界面
PetEquipInheritPanel = PetEquipInheritPanel or class("PetEquipInheritPanel",WindowPanel)
local ConfigLanguage = require('game.config.language.CnLanguage');
function PetEquipInheritPanel:ctor()
    self.abName = "pet"
    self.assetName = "PetEquipInheritPanel"
    self.layer = "UI"

    self.panel_type = 3
    self.use_background = true  
    self.is_click_bg_close = true

    self.pet_equip_model = PetEquipModel.GetInstance()
    self.pet_equip_model_events = {}

    self.bag_model = BagModel.GetInstance()
    self.bag_model_events = {}

    self.global_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.scroll_view = nil --虚拟列表

    self.pet_equip_items = self:GetPetEquipBagItems()

    --点击状态 0无点击 1点击左加号 2点击右加号
    self.click_state = 0

    self.left_item = nil
    self.right_item = nil
    self.left_goods_icon = nil
    self.right_goods_icon = nil
    
    self.left_effect = nil
    self.right_effect = nil

    self.stencil_id = nil
end

function PetEquipInheritPanel:dctor()
    if table.nums(self.pet_equip_model_events) > 0 then
        self.pet_equip_model:RemoveTabListener(self.pet_equip_model_events)
        self.pet_equip_model_events = nil
    end

    if table.nums(self.global_events) > 0 then
        GlobalEvent:RemoveTabListener(self.global_events)
        self.global_events = nil
    end

    if table.nums(self.bag_model_events) > 0 then
        self.bag_model:RemoveTabListener(self.bag_model_events)
        self.bag_model_events = nil
    end

    if self.scroll_view then
        self.scroll_view:OnDestroy()
        self.scroll_view = nil
    end

    if self.left_goods_icon then
        self.left_goods_icon:destroy()
        self.left_goods_icon = nil
    end

    if self.right_goods_icon then
        self.right_goods_icon:destroy()
        self.right_goods_icon = nil
    end

    if self.left_effect then
        self.left_effect:destroy()
        self.left_effect = nil
    end

    if self.right_effect then
        self.right_effect:destroy()
        self.right_effect = nil
    end

    if self.stencil_mask then
        destroy(self.stencil_mask)
        self.stencil_mask = nil
    end
end

function PetEquipInheritPanel:LoadCallBack(  )
    self.nodes = {
        "left/up/txt_right_item_name","left/up/left_item_icon","left/up/right_item_icon","left/up/txt_left_item_name",
        "left/bottom/txt_equip_inherit_tip","left/bottom/btn_ok",

        "left/up/btn_left_add","left/up/btn_right_add",

        "right/scrollview_equip/viewport","right/scrollview_equip/viewport/content","right/scrollview_equip",
    }

    self:GetChildren(self.nodes)

    self:InitUI()
    self:SetMask()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    self:SetTileTextImage("pet_image","title_inheritn")
end

function PetEquipInheritPanel:InitUI()

    self.txt_left_item_name = GetText(self.txt_left_item_name)
    self.txt_right_item_name = GetText(self.txt_right_item_name)
    self.txt_equip_inherit_tip = GetText(self.txt_equip_inherit_tip)
    self.txt_equip_inherit_tip.text = ConfigLanguage.Pet.PetEquipInheritDesc

    self.left_effect = UIEffect(self.left_item_icon, 20429)
    self.right_effect = UIEffect(self.right_item_icon, 20429)

    local pos = { x = 0, y = 0, z = 0 }
    self.left_effect:SetConfig({ pos = pos })
    self.right_effect:SetConfig({ pos = pos })

    local param = {}
    local cellSize = {width = 75,height = 75}
    param["scrollViewTra"] = self.scrollview_equip.transform
    param["cellParent"] = self.content
    param["cellSize"] = cellSize
    param["cellClass"] = PetEquipInheritBagIconSettor
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 10
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] =  Config.db_bag[BagModel.PetEquip].cap
    param["totalColumn"] = 4
    self.scroll_view = ScrollViewUtil.CreateItems(param)
end

function PetEquipInheritPanel:AddEvent(  )

    --左加号
    local function call_back()
        self.click_state = 1
        self.scroll_view:ForceUpdate()

        SetVisible(self.left_effect.transform,false)

        if not self.right_item then
            SetVisible(self.right_effect.transform,true)
        end
    end
    AddClickEvent(self.btn_left_add.gameObject,call_back)

    --右加号
    local function call_back()
        self.click_state = 2
        self.scroll_view:ForceUpdate()

        SetVisible(self.right_effect.transform,false)
        if not self.left_item then
            SetVisible(self.left_effect.transform,true)
        end
    end
    AddClickEvent(self.btn_right_add.gameObject,call_back)

    --继承按钮
    local function call_back(  )
        --logError("确定继承")
        if self.left_item == nil or self.right_item == nil then
            Notify.ShowText("Select the gear")
            return             
        end

        local function ok_func(  )
            PetController.GetInstance():RequestPetEquipInherit(self.left_item.uid,self.right_item.uid)
        end

        local cfg = self.pet_equip_model.pet_equip_cfg[self.right_item.id][self.right_item.equip.stren_phase]

        local message = string.format("After inheriting, %s changed to Tier %s, enhance Lv.%s",cfg.name,self.left_item.equip.stren_phase,self.left_item.equip.stren_lv) 
        Dialog.ShowTwo('Tip',message,'Confirm',ok_func,nil,'Cancel',nil,nil,nil)

        
    end
    AddClickEvent(self.btn_ok.gameObject,call_back)

    --继承返回处理
    local function call_back(src_item,dst_item)
        
        self.left_item = nil
        self.right_item = nil
        SetVisible(self.left_goods_icon.transform,false)
        SetVisible(self.right_goods_icon.transform,false)
        self.txt_left_item_name.text = ""
        self.txt_right_item_name.text = ""
        
        --重新请求背包
        BagController.GetInstance():RequestBagInfo(BagModel.PetEquip)

        Notify.ShowText("Inherited")
    end
    self.pet_equip_model_events[#self.pet_equip_model_events + 1] = self.pet_equip_model:AddListener(PetEquipEvent.HandlePetEquipInherit, call_back)

    --背包返回处理
    local function call_back(bag_id)

        if bag_id ~= BagModel.PetEquip then
            return
        end

        --刷新items
        local bags = BagModel.GetInstance().bags
        BagModel.GetInstance():ArrangeGoods(bags[BagModel.PetEquip].bagItems)
        self.pet_equip_items = self:GetPetEquipBagItems() 
        if self.scroll_view ~= nil then
            self:ResetHighLight()
        end
    end

    self.bag_model_events[#self.bag_model_events + 1] = self.bag_model:AddListener(BagEvent.LoadItemByBagId,call_back )

end

function PetEquipInheritPanel:SetMask()
    --self.stencil_id = GetFreeStencilId()
    self.stencil_mask = AddRectMask3D(self.viewport.gameObject)
    self.stencil_mask.id = self.stencil_id
end

--data
--stencil_id 模板id
function PetEquipInheritPanel:SetData(data)
    self.data = data
    self.stencil_id = self.data.stencil_id
    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function PetEquipInheritPanel:UpdateView()
    self.need_update_view = false
end

--虚拟列表Item刷新
function PetEquipInheritPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function PetEquipInheritPanel:UpdateCellCB(itemCLS)

    itemCLS.bag = BagModel.PetEquip
    if self.pet_equip_items ~=nil then
        local itemBase = self.pet_equip_items[itemCLS.__item_index]
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

                param["pet_equip_effect_id"] = nil

                --根据点击状态和强化等级来进行高亮
                if self.click_state == 1 and itemBase.misc.stren_lv >= 1 then
                    param["pet_equip_effect_id"] = 20429
                    itemCLS:HightLight(true)
                elseif self.click_state == 2 and itemBase.misc.stren_lv == 0 then
                    param["pet_equip_effect_id"] = 20429
                    itemCLS:HightLight(true)
                else
                    itemCLS:HightLight(false)
                end

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

function PetEquipInheritPanel:GetItemDataByIndex(index)
       return BagModel.GetInstance().bags[BagModel.PetEquip].bagItems[index]
end

--点击了Item
function PetEquipInheritPanel:ClickItem(item)

    local goods_icon = nil
    local txt_name = nil
    local is_left = true
    if self.click_state == 1 then
        --点击左加号后点击的item
        self.left_goods_icon = self.left_goods_icon or GoodsIconSettorTwo(self.left_item_icon)
        goods_icon = self.left_goods_icon
        txt_name = self.txt_left_item_name
        self.left_item = item
    elseif self.click_state == 2 then
        --点击右加号后点击的item
        self.right_goods_icon = self.right_goods_icon or GoodsIconSettorTwo(self.right_item_icon)
        goods_icon = self.right_goods_icon
        txt_name = self.txt_right_item_name
        self.right_item = item
        is_left = false
    end

    local pet_equip_cfg = self.pet_equip_model.pet_equip_cfg[item.id][item.equip.stren_phase]

    SetVisible(goods_icon.transform,true)
    txt_name.text = pet_equip_cfg.name

    local bag_item = nil

    --从要显示的items里移除掉
    local need_remove_index = 0
    for k,v in pairs(self.pet_equip_items) do
         if item.uid == v.uid then
             need_remove_index = k
             bag_item = v
             break;
         end
    end
    --logError("移除Item,索引"..need_remove_index)
    self.pet_equip_items[need_remove_index] = nil

    local param = {}
   
    param["item_id"] = item.id
    param["p_item"] = item
    param["can_click"] = true
    param["cfg"] = pet_equip_cfg

    local operate_param = {}
    local function take_off(  )
        --卸下操作
        --logError("卸下")

        SetVisible(goods_icon.transform,false)
        txt_name.text = ""

        if is_left then
            --置空响应的引用
            self.left_item = nil
        else
            self.right_item = nil
        end

        self.pet_equip_items[need_remove_index] = bag_item

        GlobalEvent:Brocast(GoodsEvent.CloseTipView)

        --重置下高亮状态
        self:ResetHighLight()
    end
    GoodsTipController.Instance:SetTakeOffCB(operate_param, take_off, {})
    param["operate_param"] = operate_param

    goods_icon:SetIcon(param)

    --重置下高亮状态
    self:ResetHighLight()

end

--获取背包的宠物装备(只筛选Color >= 4的)
function PetEquipInheritPanel:GetPetEquipBagItems(  )
    local result = {}
    local tbl = self.pet_equip_model:GetPetEquipItems()

    for k,v in pairs(tbl) do
        local cfg = self.pet_equip_model.pet_equip_cfg[v.id][v.misc.stren_phase]
        if cfg.color >= 4 then
            table.insert( result, v)
        end
    end
    return result
end

--重置加号按钮高亮特效
function PetEquipInheritPanel:ResetHighLight(  )
    --重置下高亮状态
    self.click_state = 0
    self.scroll_view:ForceUpdate()

    --根据左边是否有item，决定是否显示左加号上的特效
    if self.left_item then
       
        SetVisible(self.left_effect.transform,false)
    else
        SetVisible(self.left_effect.transform,true)
    end

    --根据右边是否有item，决定是否显示右加号上的特效
    if self.right_item then
        
        SetVisible(self.right_effect.transform,false)
    else
        SetVisible(self.right_effect.transform,true)
    end
   
    
end

