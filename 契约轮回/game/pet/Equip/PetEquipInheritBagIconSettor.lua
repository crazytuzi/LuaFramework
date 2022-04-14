
--宠物装备继承背包项Icon
PetEquipInheritBagIconSettor = PetEquipInheritBagIconSettor or class("PetEquipInheritBagIconSettor", BaseBagIconSettor)

function PetEquipInheritBagIconSettor:ctor(parent_node, parent_panel)
    self.abName = "system"
    self.assetName = "BagItem"

    PetEquipInheritBagIconSettor.super.Load(self)
end

--重写父类方法 注册点击事件
function PetEquipInheritBagIconSettor:AddEvent()
    PetEquipInheritBagIconSettor.super.AddEvent(self)
    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end

----重写父类方法，处理背包Item点击,点击时不调用SetSelected
function PetEquipInheritBagIconSettor:DealClickEvent()
    if not self.is_can_click then
        return
    end

    self.model.baseGoodSettorCLS = self

    GoodsController.Instance:RequestItemInfo(self.bag, self.uid)
    
end

--覆盖掉ClickEvent 不派发ClickItem事件
function PetEquipInheritBagIconSettor:ClickEvent()
    if self.uid ~= nil and BagModel.GetInstance().EnabledQuickDoubleClick then
        if self.last_click_time == 0 then
            self.last_click_time = UnityEngine.Time.realtimeSinceStartup
            self.time_scheld_id = GlobalSchedule:StartOnce(handler(self, self.QuickDoubleClickEnd), 0.32, false)
        else
            local span_time = UnityEngine.Time.realtimeSinceStartup - self.last_click_time
            if span_time <= 0.3 then
                if self.time_scheld_id ~= nil then
                    GlobalSchedule:Stop(self.time_scheld_id)
                    self.time_scheld_id = nil
                end
                if self.quick_double_click_call_back ~= nil then
                    self.quick_double_click_call_back(self.__item_index)
                end
            end

            self.last_click_time = 0
        end
    else
        self:DealNormalClickEvent()
    end
end

--重写父类方法，处理背包Item点击后请求item数据的返回处理
function PetEquipInheritBagIconSettor:DealGoodsDetailInfo(...)
    if not self.gameObject.activeInHierarchy then
        return
    end
    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    local panel = lua_panelMgr:GetPanel(PetEquipInheritPanel)
    --logError("点击-"..self.__item_index)
    panel:ClickItem(item)
  
end

--高亮
function PetEquipInheritBagIconSettor:HightLight(flag)
    self.is_can_click = flag
    --self:SetSelected(flag)
end

--param
-- multy_select 多选
-- get_item_cb  获取格子数据的回调
-- model      管理数据的类
-- selectItemCB 选中该物品回调，(可选)
-- get_item_select_cb 如果是多选，在创建(更新)的时候，获取是否选中的回调 (可选)
-- click_call_back 点击回调
-- show_reddot 是否显示红点                          
function PetEquipInheritBagIconSettor:InitItem(param)
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
function PetEquipInheritBagIconSettor:UpdateItem(param)
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

function PetEquipInheritBagIconSettor:DeleteItem()
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







