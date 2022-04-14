
--宠物装备背包项Icon 负责主要逻辑处理
PetEquipBagIconSettor = PetEquipBagIconSettor or class("PetEquipBagIconSettor", BaseBagIconSettor)

function PetEquipBagIconSettor:ctor(parent_node, parent_panel)
    self.abName = "system"
    self.assetName = "BagItem"

    PetEquipBagIconSettor.super.Load(self)

    --宠物装备tips
    self.petEquipDetailView = nil
end

function PetEquipBagIconSettor:dctor(  )
    
end

--重写父类方法 注册点击事件
function PetEquipBagIconSettor:AddEvent()
    PetEquipBagIconSettor.super.AddEvent(self)
    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end

--重写父类方法，处理背包Item点击
function BaseBagIconSettor:DealClickEvent()

    local panel = lua_panelMgr:GetPanel(PetEquipInheritPanel)
    if panel then
        --继承面板打开时不处理点击
        return
    end

    self:SetSelected(true)
    self.model.baseGoodSettorCLS = self

    --没有外面的回调，默认请求背包的物品信息
    if self.click_call_back == nil then
        GoodsController.Instance:RequestItemInfo(self.bag, self.uid)
    else
        self.click_call_back(self.uid)
    end
end

--重写父类方法，处理背包Item点击后请求item数据的返回
function PetEquipBagIconSettor:DealGoodsDetailInfo(...)
    if self.gameObject and tostring(self.gameObject) ~= "null" and not self.gameObject.activeInHierarchy then
        return
    end

    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end
  
    local panel = lua_panelMgr:GetPanel(PetEquipInheritPanel)
    if panel then
        --继承面板打开时不处理数据返回
        return
    end

    if self.time_scheld_id ~= nil then
        GlobalSchedule:Stop(self.time_scheld_id)
        self.time_scheld_id = nil
    end

    self.last_click_time = 0
 
    --附加给tips的操作参数
    local operate_param = PetEquipHelper.GetInstance():GetOperateParam(item)

    --宠物装备
    local _param = {}

    --宠物装备的配置表特殊处理
    _param["cfg"] = Config.db_pet_equip[item.id.."@"..item.equip.stren_phase]

    _param["operate_param"] = operate_param
    _param["p_item"] = item

    self.petEquipDetailView = PetEquipTipView(self.transform)
    self.petEquipDetailView:ShowTip(_param)
end

--param
-- multy_select 多选
-- get_item_cb  获取格子数据的回调
-- model      管理数据的类
-- selectItemCB 选中该物品回调，(可选)
-- get_item_select_cb 如果是多选，在创建(更新)的时候，获取是否选中的回调 (可选)
-- click_call_back 点击回调
-- show_reddot 是否显示红点                          
function PetEquipBagIconSettor:InitItem(param)
    self.is_multy_selet = param["multy_select"]
    self.get_item_cb = param["get_item_cb"]
    self.get_item_select_cb = param["get_item_select_cb"]
    self.model = param["model"]
    self.bag = param["bag"]
    self.itemSize = param["itemSize"]
    self.selectItemCB = param["selectItemCB"]
    self.click_call_back = param["click_call_back"]
    self.quick_double_click_call_back = param["quick_double_click_call_back"]
    self.stencil_id = param["stencil_id"]
    self.cellSize = param["cellSize"];
    self.effect_id = param["effect_id"]
    self.lv = param["lv"]
    self.bind = param["bind"]

    if self.equipSettor ~= nil then
        SetVisible(self.equipSettor.transform,false)
    end

   
    self.is_select = false
    self.uid = nil

    self.is_select = false
    self:SetSelected(self.is_select)

    if not self.had_add_event then
        self.had_add_event = true
        self:AddEvent()
    end
end

--param 带的参数
--type 类型  item_type
--uid 唯一id
--id  配置表的id
--num 数量
--bag  背包id
--bind 是否绑定
--outTime 过期时间戳
-- multy_select 多选
--get_item_cb 获取格子数据的回调
--getItemSelectCB --如果是多选，在创建(更新)的时候，获取是否选中的回调
-- model 管理数据的类
-- get_item_cb 选中该物品回调，(可选)
-- get_item_select_cb --如果是多选，在创建(更新)的时候，获取是否选中的回调 (可选)
-- click_call_back 点击回调
-- operate_param  操作参数
function PetEquipBagIconSettor:UpdateItem(param)
    if self.bag == nil or self.bag == param["bag"] then
        self.type = param["type"]
        self.uid = param["uid"]
        self.id = param["id"]
        self.num = param["num"]
        self.bag = param["bag"]
        self.bind = param["bind"]
        self.outTime = param["outTime"]
        self.itemSize = param["itemSize"]
        self.is_multy_selet = param["multy_select"]
        self.itemDatas = param["itemDatas"]
        self.model = param["model"]
        self.get_item_cb = param["get_item_cb"]
        self.get_item_select_cb = param["get_item_select_cb"]
        self.selectItemCB = param["selectItemCB"]
        self.click_call_back = param["click_call_back"]
        self.quick_double_click_call_back = param["quick_double_click_call_back"]
        self.operate_param = param["operate_param"]
        self.stencil_id = param["stencil_id"]
        self.cellSize = param["cellSize"];
        self.show_reddot = param["show_reddot"]  --是否显示Icon的红点
        self.reddot_tab = param["reddot_tab"]  --操作按钮红点状态表
        self.effect_id = param["effect_id"]
        self.lv = param["lv"]
        
         --宠物装备
        if self.equipSettor == nil then
            self.equipSettor = PetEquipBagGoodsSettor(self.container)
        else
            SetVisible(self.equipSettor.transform,true)
        end
        self.equipSettor:UpdateInfo(param)


        if self.is_multy_selet and self.get_item_select_cb ~= nil then
            self.is_select = self.get_item_select_cb(self.uid)
            self:SetSelected(self.is_select)
        else
            self.is_select = false
            self:SetSelected(self.is_select)
        end

        local color = Config.db_item[self.id].color

        self.last_click_time = 0
        if self.time_scheld_id ~= nil then
            GlobalSchedule:Stop(self.time_scheld_id)
            self.time_scheld_id = nil
        end
    end

    if not self.had_add_event then
        self.had_add_event = true
        self:AddEvent()
    end


end

function PetEquipBagIconSettor:DeleteItem()
    if self.model ~= nil then
        self.model.baseGoodSettorCLS = nil
    end

    self.uid = nil
    self.bag = nil
    if self.equipSettor ~= nil then
        self.equipSettor:destroy()
        self.equipSettor = nil
    end


    self:SetSelected(false);
    self.is_select = false

    if self.petEquipDetailView then
        self.petEquipDetailView:destroy()
        self.petEquipDetailView = nil
    end

end





