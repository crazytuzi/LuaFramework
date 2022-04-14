--
-- @Author: chk
-- @Date:   2019-01-17 10:02:04
--
BaseBagIconSettor = BaseBagIconSettor or class("BaseBagIconSettor", BaseWidget)
local BaseBagIconSettor = BaseBagIconSettor

function BaseBagIconSettor:ctor(parent_node, layer)
    --self.abName = "system"
    --self.assetName = "BagItem"
    self.layer = layer

    self.had_add_event = false
    self.globalEvents = {}
    self.events = self.events or {}
    --self.model = BagModel:GetInstance()
    self.__item_index = -1
    self.need_load_by_bagid_end = false
    self.need_set_lock_end = false
    self.equipSettor = nil             --装备类
    self.stoneSettor = nil             --宝石类
    self.bag = nil
    self.is_multy_selet = false       --是否多选状态
    self.is_select = false
    --self.need_deal_quick_double_click = false
    self.last_click_time = 0
    self.time_scheld_id = nil
    --BaseBagIconSettor.super.Load(self)
end

function BaseBagIconSettor:dctor()
    self:DeleteEvents();
    self:DeleteItem()
    if self.ui_effect then
        self.ui_effect:destroy()
        self.ui_effect = nil
    end
    self.equipSettor = nil
    self.stoneSettor = nil
    if self.model then
        self.model.baseGoodSettorCLS = nil
    end
    self.model = nil

    if self.fashionTipView then
        self.fashionTipView:destroy();
    end
    self.fashionTipView = nil;

    if self.magicTipView then
        self.magicTipView:destroy()
    end
    self.magicTipView=nil

    if self.frameTipView then
        self.frameTipView:destroy()
        self.frameTipView = nil
    end

    if self.mountTipView then
        self.mountTipView:destroy();
    end
    self.mountTipView = nil;

    if self.reddot then
        self.reddot:destroy()
        self.reddot = nil
    end
end

function BaseBagIconSettor:LoadCallBack()
    self.nodes = {
        "selectBg",
        "container",
        --"lockIcon",
        "touch",
    }

    self:GetChildren(self.nodes)
    --self:AddEvent()

    local a = self.touch
end

--要在子类重载，调用 AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
--因为有时候调UpdateItem时，还没获取完控件
function BaseBagIconSettor:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(BagEvent.LoadItemByBagId, handler(self, self.LoadItemInfoByBgId))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(BagEvent.AddItems, handler(self, self.AddItem))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.MultySelect, handler(self, self.DealMultySelect))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.SingleSelect, handler(self, self.DealSingleSelect))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.SelectItem, handler(self, self.SelectItem))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.GoodsDetail, handler(self, self.DealGoodsDetailInfo))
    --self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.EnabledQuickDoubleClick, handler(self, self.DealEnabledQuickDoubleClick))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(BagEvent.ClickItem, handler(self, self.ClickItem))
end

function BaseBagIconSettor:SetData(data)

end

function BaseBagIconSettor:ClickItem(uid)
    if not self.is_multy_selet then
        self:SetSelected(self.uid == uid)
    end
end

function BaseBagIconSettor:AddClickItemEvent()
    if BagModel.GetInstance().EnabledQuickDoubleClick then
        local tcher = self.gameObject:GetComponent(typeof(Toucher))
        if tcher == nil then
            tcher = self.gameObject:AddComponent(typeof(Toucher))
        end
        tcher:SetClickEvent(handler(self, self.OnTouchenBengin))
    end
end

function BaseBagIconSettor:QuickDoubleClickEnd()
    if self.time_scheld_id ~= nil then
        GlobalSchedule:Stop(self.time_scheld_id)
        self.time_scheld_id = nil
    end

    self:DealNormalClickEvent()
end

--设置是否选中
function BaseBagIconSettor:SetSelected(show)
    if self.selectBg ~= nil and tostring(self.selectBg) ~= "null" and self.is_loaded then
        SetVisible(self.selectBg, show)
    end
end

--添加数量
function BaseBagIconSettor:AddItem(bagId, index)
    if self.bag == bagId and self.__item_index == index and self.get_item_cb ~= nil then
        local param = {}
        local itemBase = self.get_item_cb(index)
        if itemBase ~= nil then
            local itemConfig = Config.db_item[itemBase.id]
            param["itemIndex"] = index
            param["type"] = itemConfig.type
            param["uid"] = itemBase.uid
            param["id"] = itemConfig.id
            param["num"] = itemBase.num
            param["bag"] = self.bag
            param["bind"] = itemBase.bind
            param["itemSize"] = self.itemSize
            param["outTime"] = itemBase.etime
            param["multy_select"] = self.is_multy_selet
            param["get_item_select_cb"] = self.get_item_select_cb
            param["get_item_cb"] = self.get_item_cb
            param["model"] = self.model
            param["selectItemCB"] = self.selectItemCB
            param["click_call_back"] = self.click_call_back
            param["quick_double_click_call_back"] = self.quick_double_click_call_back
            param["stencil_id"] = self.stencil_id
        end
        self:UpdateItem(param)
    end
end

function BaseBagIconSettor:ClickEvent()
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
    if self.uid ~= nil then
        GlobalEvent:Brocast(BagEvent.ClickItem, self.uid)
    end
end

function BaseBagIconSettor:DealClickEvent()
    --[[    if self.model.baseGoodSettorCLS ~= nil then
    self.model.baseGoodSettorCLS:SetSelected(false)
    end--]]

    self:SetSelected(true)
    self.model.baseGoodSettorCLS = self

    --没有外面的回调，默认请求背包的物品信息
    if self.click_call_back == nil then
        GoodsController.Instance:RequestItemInfo(self.bag, self.uid)
    else
        self.click_call_back(self.uid)
    end
end

function BaseBagIconSettor:DealNormalClickEvent()
    if self.uid ~= nil and not self.is_multy_selet then
        self:DealClickEvent()
    elseif self.is_multy_selet and self.uid ~= nil then
        self.is_select = not self.is_select
        self:SetSelected(self.is_select)
        self.selectItemCB(self.uid, self.is_select)
    end
end

function BaseBagIconSettor:DealMultySelect(bagId)
    if self.bag == bagId and self.gameObject.activeInHierarchy then
        self.is_multy_selet = true

        self.is_select = false
        self:SetSelected(self.is_select)
    end
end

function BaseBagIconSettor:DealSingleSelect(bagId)
    if self.bag == bagId then
        self.is_multy_selet = false
        self.is_select = false
        self:SetSelected(self.is_select)
        self.selectItemCB(self.uid, self.is_select)
    end
end

function BaseBagIconSettor:DelItem(bagId, uid)
    if self.bag == bagId and self.uid == uid then
        self.model.baseGoodSettorCLS = nil
        self.is_select = false
        self:SetSelected(self.is_select)
        self:DeleteItem()

        self.uid = nil
    end
end

--[[function BaseBagIconSettor:DealEnabledQuickDoubleClick(bagid, enabled)
    if self.gameObject.activeInHierarchy and self.bag == bagid then
        self.need_deal_quick_double_click = enabled
    end
end--]]


--处理装备(物品)详细信息,要重载
--第1个参数 请求物品的返回的p_item (必传)
--第2个参数 对请求的物品的操作参数 (看着办)
--第3个参数 身上穿的,装备的        (看着办)
function BaseBagIconSettor:DealGoodsDetailInfo(...)
    if self.gameObject and tostring(self.gameObject) ~= "null" and not self.gameObject.activeInHierarchy then
        return
    end

    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    if self.time_scheld_id ~= nil then
        GlobalSchedule:Stop(self.time_scheld_id)
        self.time_scheld_id = nil
    end

    self.last_click_time = 0
    local puton_item = param[3]
    if puton_item == nil then
        puton_item = self.model.Instance:GetPutOn(item.id)
    end
    local itemcfg = Config.db_item[item.id]
    if itemcfg.tip_type == 1 then
        local _param = {}
        _param["cfg"] = itemcfg
        _param["operate_param"] = param[2]
        _param["p_item"] = item
        self.fashionTipView = FashionTipView(self.transform)
        self.fashionTipView:ShowTip(_param)
        return
    elseif itemcfg.tip_type == 10 then
        local _param = {}
        _param["cfg"] = itemcfg
        _param["operate_param"] = param[2]
        _param["p_item"] = item
        self.fashionTipView = FashionMulTipView(self.transform)
        self.fashionTipView:ShowTip(_param)
        return
    elseif itemcfg.tip_type == 11 or itemcfg.tip_type == 12 then
        local _param = {}
        _param["cfg"] = itemcfg
        _param["operate_param"] = param[2]
        _param["p_item"] = item
        self.frameTipView = FrameTipView(self.transform)
        self.frameTipView:ShowTip(_param)
        return
    elseif itemcfg.tip_type == 13 then
        local _param = {}
        _param["cfg"] = itemcfg
        _param["operate_param"] = param[2]
        _param["p_item"] = item
        self.magicTipView = MagicTipView(self.transform)
        self.magicTipView:ShowTip(_param)
        return
    end
    if Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST
        or Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP
    then


        if puton_item ~= nil then

            --_param
            --self_item 在背包的装备item
            --self_cfg 第1个参数的配置信息
            --puton_item 上身穿戴的装备item
            --puton_cfg 第3个参数的配置表信息
            --operate_param 操作参数
            --model 管理数据的model

            local _param = {}
            _param["self_item"] = item
            _param["self_cfg"] = self.model:GetConfig(item.id)
            _param["puton_item"] = puton_item
            _param["puton_cfg"] = self.model:GetConfig(puton_item.id)
            _param["operate_param"] = param[2]
            _param["model"] = self.model
            lua_panelMgr:GetPanelOrCreate(EquipComparePanel):Open(_param)
        else

            --_param包含参数
            --cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
            --p_item 服务器给的，服务器没给，只传cfg就好
            --model 管理该tip数据的实例
            --operate_param --操作参数

            local _param = {}
            _param["cfg"] = self.model:GetConfig(item.id)
            _param["p_item"] = item
            _param["model"] = self.model
            _param["operate_param"] = param[2]

            self.equipDetailView = EquipTipView(self.transform)
            self.equipDetailView:ShowTip(_param)
        end
        --下面是坐骑神兵法宝翅膀副手神灵
    elseif Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_MISC and (Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH
            or Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH
            or Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH
            or Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH
            or Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH
            or Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH
			or Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_BABY_WING_MORPH) then
        local pos = self.transform.position
        --local screenPos = LayerManager:UIWorldToScreenPoint(pos.x, pos.y)
        local _param = {}
        _param["cfg"] = Config.db_item[item.id]
        _param["p_item"] = item
        _param["basePos"] = pos
        _param["stype"] = Config.db_item[item.id].stype;
        _param["operate_param"] = param[2]
        self.mountTipView = MountTipView(self.transform)
        self.mountTipView:ShowTip(_param)

    elseif Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_MISC and Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_PET_EGG
            and not param[4] then
        local pos = self.transform.position
        --local screenPos = LayerManager:UIWorldToScreenPoint(pos.x, pos.y)
        local _param = {}
        _param["cfg"] = Config.db_item[item.id]
        _param["p_item"] = item
        _param["basePos"] = pos

        local view = lua_panelMgr:GetPanelOrCreate(PetEggTipView)
        view:SetData(_param)

    elseif Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_MISC and (
            Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_SOUL
                    or Config.db_item[item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_SOUL_EXP
    ) then


        --圣痕tip
        local _param = {}
        _param["cfg"] = Config.db_item[item.id]
        _param["operate_param"] = param[2]
        _param["p_item"] = item
        _param["reddot_tab"] = self.reddot_tab
        _param["bind"] = 2
        self.stigmataDetailView = StigmataTipView(self.transform)
        self.stigmataDetailView:ShowTip(_param)
    elseif Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BABY then
        --子女
        local _param = {}
        _param["cfg"] = Config.db_item[item.id]
        _param["operate_param"] = param[2]
        _param["p_item"] = item
        _param["puton_item"] = puton_item
        self.babyDetailView = BabyTipView(self.transform)
        self.babyDetailView:ShowTip(_param)
    elseif Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_GOD then
        --神灵
        local _param = {}
        _param["cfg"] = Config.db_item[item.id]
        _param["operate_param"] = param[2]
        _param["p_item"] = item
        _param["puton_item"] = puton_item
        self.godDetailView = GodTipView(self.transform)
        self.godDetailView:ShowTip(_param)
    elseif Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_MECHA then
        --机甲
        local _param = {}
        _param["cfg"] = Config.db_item[item.id]
        _param["operate_param"] = param[2]
        _param["p_item"] = item
        _param["puton_item"] = puton_item
        self.mechaDetailView = MachineArmorTipView(self.transform)
        self.mechaDetailView:ShowTip(_param)

    elseif Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_ARTI_EQUIP then
        local _param = {}
        _param["cfg"] = self.model:GetConfig(item.id)
        _param["p_item"] = item
        _param["model"] = self.model
        _param["operate_param"] = param[2]
        _param["is_compare"] = true
        --local equipCfg = Config.db_equip[item.id]
        --if equipCfg then
        --    _param["puton_item"] = ArtifactModel:GetInstance():GetEquipInfo(ArtifactModel.GetInstance().curArtId,equipCfg.slot)
        --end

        self.artiDetailView = ArtifactEquipTipView(self.transform)
        self.artiDetailView:ShowTip(_param)
    -- elseif Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
    --     --宠物装备
    --     local _param = {}

    --     --宠物装备的配置表特殊处理
    --     _param["cfg"] = Config.db_pet_equip[item.id.."@"..item.equip.stren_phase]

    --     _param["operate_param"] = param[2]
    --     _param["p_item"] = item
    --     self.petEquipDetailView = PetEquipTipView(self.transform)
    --     self.petEquipDetailView:ShowTip(_param)
    else
        local _param = {}
        _param["cfg"] = Config.db_item[item.id]
        _param["operate_param"] = param[2]
        _param["p_item"] = item
        self.goodsDetailView = GoodsTipView(self.transform)
        self.goodsDetailView:ShowTip(_param)
    end


end

function BaseBagIconSettor:DeleteEvents()
    for k, v in pairs(self.events) do
        self.model:RemoveListener(v)
    end

    self.events = {}

    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end
    self.globalEvents = {}
end

function BaseBagIconSettor:DeleteItem()
    if self.model ~= nil then
        self.model.baseGoodSettorCLS = nil
    end

    self.uid = nil
    self.bag = nil
    if self.equipSettor ~= nil then
        self.equipSettor:destroy()
        self.equipSettor = nil
    end

    if self.stoneSettor ~= nil then
        self.stoneSettor:destroy()
        self.stoneSettor = nil
    end
    self:SetSelected(false);
    self.is_select = false
    if self.goodsDetailView then
        self.goodsDetailView:destroy()
        self.goodsDetailView = nil
    end
    if self.equipDetailView then
        self.equipDetailView:destroy()
        self.equipDetailView = nil
    end

    if self.stigmataDetailView then
        self.stigmataDetailView:destroy()
        self.stigmataDetailView = nil
    end

    if self.babyDetailView then
        self.babyDetailView:destroy()
        self.babyDetailView = nil
    end
    if self.godDetailView then
        self.godDetailView:destroy()
        self.godDetailView = nil
    end

    if self.mechaDetailView then
        self.mechaDetailView:destroy()
        self.mechaDetailView = nil
    end

    if self.petEquipDetailView then
        self.petEquipDetailView:destroy()
        self.petEquipDetailView = nil
    end
    if self.artiDetailView then
        self.artiDetailView:destroy()
        self.artiDetailView = nil
    end


    if self.ui_effect then
        self.ui_effect:destroy()
        self.ui_effect = nil
    end
end

--param
-- multy_select 多选
-- get_item_cb  获取格子数据的回调
-- model      管理数据的类
-- selectItemCB 选中该物品回调，(可选)
-- get_item_select_cb 如果是多选，在创建(更新)的时候，获取是否选中的回调 (可选)
-- click_call_back 点击回调
-- show_reddot 是否显示红点                          
function BaseBagIconSettor:InitItem(param)
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
        self.equipSettor:destroy()
        self.equipSettor = nil
    end

    if self.stoneSettor ~= nil then
        self.stoneSettor:destroy()
        self.stoneSettor = nil
    end
    --SetVisible(self.bg1.gameObject,false)
    self.is_select = false
    self.uid = nil

    self.is_select = false
    self:SetSelected(self.is_select)

    if not self.had_add_event then
        self.had_add_event = true
        self:AddEvent()
    end
end


--根据数据的下标加载相应格子的信息
function BaseBagIconSettor:LoadItemInfoByBgId(id)
    local param = {}
    if id == self.bag and self.get_item_cb ~= nil then
        local itemBase = self.get_item_cb(self.__item_index)
        if itemBase ~= nil and itemBase ~= 0 then
            --Chkprint("加载的__item_index",self.__item_index)
            local configItem = Config.db_item[itemBase.id]
            if configItem ~= nil then
                --配置表存该物品
                --type,uid,id,num,bag,bind,outTime
                param["itemIndex"] = self.__item_index
                param["type"] = configItem.type
                param["stype"] = configItem.stype
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = self.bag
                param["bind"] = itemBase.bind
                param["outTime"] = itemBase.etime
                param["itemSize"] = self.itemSize
                param["multy_select"] = self.is_multy_selet
                param["get_item_cb"] = self.get_item_cb
                param["model"] = self.model
                param["selectItemCB"] = self.selectItemCB
                param["select_param"] = self.select_param
                param["click_call_back"] = self.click_call_back
                param["quick_double_click_call_back"] = self.quick_double_click_call_back
                param["get_item_select_cb"] = self.get_item_select_cb
                param["stencil_id"] = self.stencil_id
                param["cellSize"] = self.cellSize;
                param["show_reddot"] = self.show_reddot or false
                param["reddot_tab"] = self.reddot_tab or nil
                param["effect_id"] = self.effect_id or nil
                param["lv"] = self.lv or nil
                self:UpdateItem(param)
            end
        else
            self:DeleteItem()
        end
    end
end

function BaseBagIconSettor:SelectItem(bagId, select)
    if self.bag == bagId and self.gameObject.activeInHierarchy and self.selectItemCB ~= nil and self.uid ~= nil then
        self.is_select = select
        self:SetSelected(select)
        self.selectItemCB(self.uid, self.is_select)

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
function BaseBagIconSettor:UpdateItem(param)
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
        if self.equipSettor then
            self.equipSettor:destroy()
            self.equipSettor = nil
        end
        if self.stoneSettor then
            self.stoneSettor:destroy()
            self.stoneSettor = nil
        end
        if param["type"] == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or param["type"] == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST or param["type"] == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
            --该物品是装备
            if self.equipSettor == nil then
                self.equipSettor = BagEquipSettor(self.container)
            end
            self.equipSettor:UpdateInfo(param)
        elseif param["type"] == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BABY then
            if self.equipSettor == nil then
                self.equipSettor = BabyEquipSettor(self.container)
            end
            self.equipSettor:UpdateInfo(param)
        elseif param["type"] == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_GOD then
            if self.equipSettor == nil then
                self.equipSettor = GodEquipSettor(self.container)
            end
            self.equipSettor:UpdateInfo(param)
        elseif param["type"] == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_MECHA then
            if self.equipSettor == nil then
                self.equipSettor = MachineArmorEquipSettor(self.container)
            end
            self.equipSettor:UpdateInfo(param)
            --下放到子类处理了
        -- elseif param["type"] == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
        --     --宠物装备
        --     if self.equipSettor == nil then
        --         self.equipSettor = PetEquipBagGoodsSettor(self.container)
        --     end
        --     self.equipSettor:UpdateInfo(param)

        elseif param["type"] == enum.ITEM_TYPE.ITEM_TYPE_ARTI_EQUIP then
            if self.equipSettor == nil then
                self.equipSettor = ArtifactEquipSettor(self.container)
            end
            self.equipSettor:UpdateInfo(param)

        else
            if self.stoneSettor == nil then
                self.stoneSettor = BagStoneSettor(self.container)
            end

            self.stoneSettor:UpdateInfo(param)
        end

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


--是否激活射线检测（接收点击事件）
function BaseBagIconSettor:UpdateRayTarget(visable)
    GetImage(self.touch).raycastTarget = visable
end