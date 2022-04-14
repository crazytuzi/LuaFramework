--
-- @Author: chk
-- @Date:   2019-01-15 10:36:41
--
GoodsIconSettorTwo = GoodsIconSettorTwo or class("GoodsIconSettorTwo", BaseWidget)
local this = GoodsIconSettorTwo

function GoodsIconSettorTwo:ctor(parent_node, layer, abName, assetName)
    self.abName = "system"
    self.assetName = "GoodsIconSettorTwo"
    self.layer = layer

    self.globalEvents = {}
    self.itemId = nil
    self.uid = nil
    self.itemNum = 0
    self.reddot = nil
    local pnode = parent_node
    local str = ""
    while not IsGameObjectNull(pnode) do
        str = string.format("%s/%s", pnode.name, str)
        pnode = pnode.parent
    end
    self.path_str = str
    --self.clickEvent = ClickGoodsIconEvent.Click.NONE

    self.need_deal_quick_double_click = false
    self.last_click_time = 0

    GoodsIconSettorTwo.super.Load(self)
end

function GoodsIconSettorTwo:dctor()
    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end

    if self.ui_effect ~= nil then
        self.ui_effect:destroy()
        self.ui_effect = nil
    end
    self.path_str = ""
    self.model = nil;

    if self.goodsDetailView then
        self.goodsDetailView:destroy();
    end
    self.goodsDetailView = nil;

    if self.equipDetailView then
        self.equipDetailView:destroy();
        self.equipDetailView = nil;
    end

    if self.fashionTipView then
        self.fashionTipView:destroy()
        self.fashionTipView=nil
    end
    if self.frameTipView then
        self.frameTipView:destroy()
        self.frameTipView=nil
    end
    if self.magicTipView then
        self.magicTipView:destroy()
        self.magicTipView=nil
    end

    if self.reddot then
        self.reddot:destroy()
        self.reddot = nil
    end
end

function GoodsIconSettorTwo:LoadCallBack()
    self.nodes = {
        "touch",
        "bindIcon",
        "step",
        "quality",
        "icon",
        "starContain",
        "num",
        "countBG",
        "countBG/count",
        "upPowerTip",
        "notCantPutPutOn",
        "lv",
        "needNum",
        "strengthText"
    }
    self:GetChildren(self.nodes)
    self:AddEvent()

    self.countTxt = self.count:GetComponent('Text')
    self.quality_component = self.quality:GetComponent('Image')
    self.icon_component = self.icon:GetComponent('Image')
    self.step_component = self.step:GetComponent('Text')

    self.touch_component = self.touch:GetComponent('Image')

    self.starContain_componen = self.starContain:GetComponent("GridLayoutGroup")

    self.lv = GetText(self.lv)
    self.needNum = GetText(self.needNum)
    self.txt_num = GetText(self.num)

    if self.position == nil then
        SetAnchoredPosition(self.transform, 0, 0)
    end
end

function GoodsIconSettorTwo:AddEvent()
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail, handler(self, self.DealEquipUpdate))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, handler(self, self.DealUpdateNumByUid))
    --self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.GoodsDetail, handler(self, self.DealGoodsDetailInfo))
end

function GoodsIconSettorTwo:AddClickEvent()
    local function call_back(target, x, y)
        --self:ClickCallBack()
        if not self.is_showtip then
            self:ClickEvent()
        end

        if self.out_call_back ~= nil then
            self:out_call_back(self)
        end
    end
    AddClickEvent(self.touch.gameObject, call_back, nil, 0)
end

function GoodsIconSettorTwo:DealGoodsDetailInfo(...)
    if IsGameObjectNull(self.gameObject) then
        logError(string.format("未释放的GoodsIconSettorTwo:%s", self.path_str))
        self:destroy();
        return
    end
    if not self.gameObject.activeInHierarchy then
        return
    end

    local param = { ... }
    local item = param[1]

    if self.p_item == nil and self.p_item_base == nil then
        return
    end

    if self.p_item ~= nil and self.p_item.uid ~= item.uid then
        return
    end

    if self.p_item_base ~= nil and self.p_item_base.uid ~= item.uid then
        return
    end

    local puton_item = nil
    if not self.not_need_compare then
        puton_item = param[3]
        if puton_item == nil then
            puton_item = self.model.Instance:GetPutOn(item.id)
        end
    end
    if Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or
            Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST
        or  Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP
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
            _param["operate_param"] = self.operate_param

            self.equipDetailView = EquipTipView(self.transform)
            self.equipDetailView:ShowTip(_param)
        end
    else
        local _param = {}
        _param["cfg"] = Config.db_item[item.id]
        _param["operate_param"] = param[2]
        self.goodsDetailView = GoodsTipView(self.transform)
        self.goodsDetailView:ShowTip(_param)
    end
end

function GoodsIconSettorTwo:DealEquipUpdate(equipDetail)
    if self.show_noput then
        if self.uid ~= nil and self.uid == equipDetail.uid then
            self.item_data = equipDetail
            if self.model and self.model:GetEquipCanPutOn(self.item_data.id) and not self.model:IsExpire(self.item_data.etime) then
                SetVisible(self.notCantPutPutOn, false)
            else
                SetVisible(self.notCantPutPutOn, true)
            end
        end
    end
end

function GoodsIconSettorTwo:UpdatePutOn(etime)
    if self.show_noput then
        if self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
            if self.model and self.model:GetEquipCanPutOn(self.item_id) and not self.model:IsExpire(etime) then
                SetVisible(self.notCantPutPutOn, false)
            else
                SetVisible(self.notCantPutPutOn, true)
            end
        else
            SetVisible(self.notCantPutPutOn, false)
        end
    end
end

function GoodsIconSettorTwo:DealUpdateNumByUid(bagId, uid, num)
    if self.uid == uid then
        self:UpdateNum(num)
    end
end

function GoodsIconSettorTwo:ClickCallBack()

    self.last_click_time = 0

    if self.p_item_base ~= nil and self.out_call_back ~= nil then
        --self.out_call_back(self.p_item_base)
    elseif self.p_item ~= nil then
        --服务器发过来的
        if self.item_cfg ~= nil then
            if self.item_cfg.tip_type == 1 then
                local _param = {}
                _param["cfg"] = self.item_cfg
                _param["item"] = self.p_item
                _param["operate_param"] = self.operate_param
                self.fashionTipView = FashionTipView(self.transform)
                self.fashionTipView:ShowTip(_param)
                return
            elseif self.item_cfg.tip_type == 11 or self.item_cfg.tip_type == 12 then
                local _param = {}
                _param["cfg"] = self.item_cfg
                _param["operate_param"] = self.operate_param
                _param["item"] = self.p_item
                self.frameTipView = FrameTipView(self.transform)
                self.frameTipView:ShowTip(_param)
                return
            elseif self.item_cfg.tip_type == 13 then
                local _param = {}
                _param["cfg"] = self.item_cfg
                _param["operate_param"] = self.operate_param
                _param["item"] = self.p_item
                self.magicTipView = MagicTipView(self.transform)
                self.magicTipView:ShowTip(_param)
                return
            end
            if self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP
                    or self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST or self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
                local equipCfg = Config.db_equip[self.p_item.id]
                local bagId = self.model:GetBagIdByUid(self.p_item.uid)
                local puton_item = nil
                local strong_item = nil;
                if not self.not_need_compare then
                    puton_item = self.model:GetPutOn(self.p_item.id)
                    --strong_item = self.model:Get
                end

                if bagId ~= 0 and puton_item ~= nil and self.p_item.uid ~= puton_item.uid then
                    --判断身上有没有装备
                    local _param = {}
                    _param["self_item"] = self.p_item
                    _param["self_cfg"] = self.model:GetConfig(self.p_item.id)
                    _param["puton_item"] = puton_item
                    _param["puton_cfg"] = self.model:GetConfig(puton_item.id)
                    _param["operate_param"] = self.operate_param
                    _param["model"] = self.model
                    lua_panelMgr:GetPanelOrCreate(EquipComparePanel):Open(_param)

                else
                    local _param = {}
                    _param["cfg"] = self.cfg
                    _param["p_item"] = self.p_item
                    _param["model"] = self.model
                    _param["bind"] = self.bind
                    _param["operate_param"] = self.operate_param

                    self.equipDetailView = EquipTipView(self.transform)
                    self.equipDetailView:ShowTip(_param)

                end
            elseif self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_PET then
                local pos = self.transform.position
                local view = PetShowTipView()

                view:SetData(self.p_item, PetModel.TipType.PetEgg, pos)

            elseif Config.db_item[self.p_item.id].type == enum.ITEM_TYPE.ITEM_TYPE_MISC and Config.db_item[self.p_item.id].stype == enum.ITEM_STYPE.ITEM_STYPE_SOUL then

                --圣痕tip
                local _param = {}
                _param["cfg"] = Config.db_item[self.p_item.id]
                _param["operate_param"] = self.operate_param
                _param["p_item"] = self.p_item
                _param["reddot_tab"] = self.reddot_tab
                _param["bind"] = 2
                self.stigmataDetailView = StigmataTipView(self.transform)
                self.stigmataDetailView:ShowTip(_param)

            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_MISC and (self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_BABY_WING_MORPH) then
                local pos = self.transform.position
                --local screenPos = LayerManager:UIWorldToScreenPoint(pos.x, pos.y)
                local _param = {}
                _param["cfg"] = self.cfg
                _param["basePos"] = pos
                _param["item"] = self.p_item
                _param["operate_param"] = self.operate_param
                _param["stype"] = self.cfg.stype;
                self.mountTipView = MountTipView(self.transform)
                self.mountTipView:ShowTip(_param)
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BABY then
                if BabyModel:GetInstance().openToysType == 1 then
                    local _param = {}
                    _param["cfg"] = Config.db_item[self.p_item.id]
                    _param["operate_param"] = self.operate_param
                    _param["p_item"] = self.p_item
                    self.goodsDetailView = BabyTipView(self.transform)
                    self.goodsDetailView:ShowTip(_param)
                end
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_GOD then
                if GodModel:GetInstance().openEquipType == 1 then
                    local _param = {}
                    _param["cfg"] = Config.db_item[self.p_item.id]
                    _param["operate_param"] = self.operate_param
                    _param["p_item"] = self.p_item
                    self.goodsDetailView = GodTipView(self.transform)
                    self.goodsDetailView:ShowTip(_param)
                end
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_MECHA then
                if MachineArmorModel:GetInstance().openEquipType == 1 then
                    local _param = {}
                    _param["cfg"] = Config.db_item[self.p_item.id]
                    _param["operate_param"] = self.operate_param
                    _param["p_item"] = self.p_item
                    self.goodsDetailView = MachineArmorTipView(self.transform)
                    self.goodsDetailView:ShowTip(_param)
                end
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
                --宠物装备tip
                local _param = {}
                 _param["cfg"] = Config.db_pet_equip[self.p_item.id .."@"..self.p_item.equip.stren_phase]
                 _param["operate_param"] = self.operate_param
                 _param["p_item"] = self.p_item
                self.goodsDetailView = PetEquipTipView(self.transform)
                self.goodsDetailView:ShowTip(_param)
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_ARTI_EQUIP then
                local _param = {}
                _param["cfg"] = self.cfg
                _param["p_item"] = self.p_item
                _param["model"] = self.model
                _param["bind"] = self.bind
                _param["operate_param"] = self.operate_param

                self.equipDetailView = EquipTipView(self.transform)
                self.equipDetailView:ShowTip(_param)
            else

                --cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
                --p_item 服务器给的，服务器没给，只传cfg就好
                --operate_param --操作参数

                local operate_param = {}
                local param = {}
                param["cfg"] = self.cfg
                param["p_item"] = self.p_item
                param["model"] = self.model
                param["operate_param"] = self.operate_param
                self.goodsDetailView = GoodsTipView(self.transform)
                self.goodsDetailView:ShowTip(param)
            end
        end
    elseif self.cfg ~= nil then
        ---显示配置表中的tip
        if self.item_cfg ~= nil then
            if self.item_cfg.tip_type == 1 then
                local _param = {}
                _param["cfg"] = self.cfg
                _param["operate_param"] = self.operate_param
                self.fashionTipView = FashionTipView(self.transform)
                self.fashionTipView:ShowTip(_param)
                return
            elseif self.item_cfg.tip_type == 11 or self.item_cfg.tip_type == 12 then
                local _param = {}
                _param["cfg"] = self.cfg
                _param["operate_param"] = self.operate_param
                self.frameTipView = FrameTipView(self.transform)
                self.frameTipView:ShowTip(_param)
                return
            elseif self.item_cfg.tip_type == 13 then
                local _param = {}
                _param["cfg"] = self.cfg
                _param["operate_param"] = self.operate_param
                self.magicTipView = MagicTipView(self.transform)
                self.magicTipView:ShowTip(_param)
                return
            end
            if self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or
                    self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST or self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
                --local equipCfg = Config.db_equip[self.item_id]
                local puton_item = nil
                if not self.not_need_compare then
                    puton_item = self.model:GetPutOn(self.item_id)
                end

                if puton_item ~= nil then
                    local _param = {}
                    --_param["self_item"] = self.p_item
                    _param["self_cfg"] = self.cfg
                    _param["puton_item"] = puton_item
                    _param["puton_cfg"] = self.model:GetConfig(puton_item.id)
                    _param["operate_param"] = self.operate_param
                    _param["bind"] = self.bind
                    _param["model"] = self.model
                    lua_panelMgr:GetPanelOrCreate(EquipComparePanel):Open(_param)
                else

                    --cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
                    --p_item 服务器给的，服务器没给，只传cfg就好
                    --model 管理该tip数据的实例
                    --operate_param --操作参数

                    local _param = {}
                    _param["cfg"] = self.cfg
                    _param["model"] = self.model
                    _param["bind"] = self.bind
                    _param["operate_param"] = self.operate_param

                    self.equipDetailView = EquipTipView(self.transform)
                    self.equipDetailView:ShowTip(_param)
                end
            elseif (self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_MISC) and (self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_PET) then
                local pos = self.transform.position
                local view = PetShowTipView()

                view:SetData(self.item_cfg.id, PetModel.TipType.PetEgg, pos)
                --魂卡
            elseif self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_MAGICCARD then
                local param = {}
                param["cfg"] = self.cfg
                param["bind"] = self.bind
                param["model"] = self.model
                param["operate_param"] = self.operate_param
                self.goodsDetailView = MagicCardView(self.transform)
                self.goodsDetailView:ShowTip(param)

            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_MISC and self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_SOUL then

                --圣痕tip
                local param = {}
                param["cfg"] = self.cfg

                self.item_cfg.extra = 1  --圣痕合成界面的圣痕，视为1级圣痕

                --这几个得加上 不然会报错
                self.item_cfg.equip = {}
                self.item_cfg.equip.suite = {}
                self.item_cfg.equip.cast = 0

                param["p_item"] = self.item_cfg

                param["bind"] = 2
                param["operate_param"] = self.operate_param
                self.stigmataDetailView = StigmataTipView(self.transform)
                self.stigmataDetailView:ShowTip(param)

            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_MISC and (self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH
                    or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH
					or self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_BABY_WING_MORPH) then
                local pos = self.transform.position
                --local screenPos = LayerManager:UIWorldToScreenPoint(pos.x, pos.y)
                local _param = {}
                _param["cfg"] = self.cfg
                _param["basePos"] = pos
                _param["operate_param"] = self.operate_param
                _param["stype"] = self.cfg.stype;
                self.mountTipView = MountTipView(self.transform)
                self.mountTipView:ShowTip(_param)
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BABY then
                if BabyModel:GetInstance().openToysType == 1 then
                    local _param = {}
                    _param["cfg"] = self.cfg
                    _param["operate_param"] = self.operate_param
                    _param["p_item"] = self.p_item
                    self.goodsDetailView = BabyTipView(self.transform)
                    self.goodsDetailView:ShowTip(_param)
                end
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_GOD then
                if GodModel:GetInstance().openEquipType == 1 then
                    local _param = {}
                    _param["cfg"] = self.cfg
                    _param["operate_param"] = self.operate_param
                    _param["p_item"] = self.p_item
                    self.goodsDetailView = GodTipView(self.transform)
                    self.goodsDetailView:ShowTip(_param)
                end
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_MECHA then
                if MachineArmorModel:GetInstance().openEquipType == 1 then
                    local _param = {}
                    _param["cfg"] = self.cfg
                    _param["operate_param"] = self.operate_param
                    _param["p_item"] = self.p_item
                    self.goodsDetailView = MachineArmorTipView(self.transform)
                    self.goodsDetailView:ShowTip(_param)
                end
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
                   local _param = {}
                    _param["cfg"] = self.cfg
                    _param["operate_param"] = self.operate_param
                    _param["p_item"] = self.p_item
                    self.goodsDetailView = PetEquipTipView(self.transform)
                    self.goodsDetailView:ShowTip(_param)
            elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_ARTI_EQUIP then
                local _param = {}
                _param["cfg"] = self.cfg
                _param["model"] = self.model
                _param["bind"] = self.bind
                _param["operate_param"] = self.operate_param

                self.equipDetailView = EquipTipView(self.transform)
                self.equipDetailView:ShowTip(_param)

            else
                --cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
                --p_item 服务器给的，服务器没给，只传cfg就好
                --operate_param --操作参数

                local param = {}
                param["cfg"] = self.cfg
                param["bind"] = self.bind
                param["operate_param"] = self.operate_param
                self.goodsDetailView = GoodsTipView(self.transform)
                self.goodsDetailView:ShowTip(param)
            end
        end
    end
end

--[[function GoodsIconSettorTwo:RemoveUpdateNumEvent()
    if self.UpdateNumEvent then
        GlobalEvent:RemoveListener(self.UpdateNumEvent);
    end
    self.UpdateNumEvent = nil;
end--]]


--[[
    @author LaoY
    @des    
    @param1 cf {type_id, num} 这种配置表的格式，可以用该接口
--]]
function GoodsIconSettorTwo:SetConfig(cf)
    self:SetData(cf[1], cf[2])
end

function GoodsIconSettorTwo:SetData(type_id, num, is_click)
    local param = {}
    type_id = RoleInfoModel:GetInstance():GetItemId(type_id)
    if Config.db_item[type_id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        param["cfg"] = Config.db_equip[type_id]
    else
        param["cfg"] = Config.db_item[type_id]
    end
    param["model"] = BagModel.Instance
    param["can_click"] = is_click == nil and true or is_click
    param["num"] = num
    self:SetIcon(param)
end

--param包含参数
--item_id 配置表id
--cfg  该物品(装备)的配置
--p_item 服务器给的，服务器没给，只传cfg就好
--model 管理  p_item 数据数
--p_item_base 服务器给的，服务器没给，只传cfg就好
--size {x = 0,y=0}
--num 数量
--can_click  是否可点击
--out_call_back  点击回调
--operate_param --点击传给tip的操作参数
--not_need_compare true 表示不需要对比
--show_up_tip : 是否显示战力上升
--up_tip_action : 向上提示是否有动画
--effect_type : 特效类型(1-物品特效，2-活动特效，不赋值默认1)
--color_effect : 大于该颜色值的会有特效
--stencil_id : 在滚动容器中的时候，传入滚动容器设置的动态id(如果在滚动容器中，不设置就不能挡住特效)
--stencil_type : 在滚动容器中的时候，传入type
--no_show_order : true/false 不显示阶
--bind : 是否绑定（1-绑定，2-非绑，默认1）
--show_num:数量为0，1时是否显示数量(默认不显示)
--show_noput:是否显示禁止穿戴
--reddot_tab:操作按钮红点状态表
--show_reddot:是否显示红点
--quick_double_click_call_back 双击回调
-- is_showtip 点击是否需要显示tip
--need_num 需要数量
--hava_num 拥有数量
--stren_lv 强化等级
function GoodsIconSettorTwo:SetIcon(param)
    self.cfg = param["cfg"]
    self.model = param["model"] or BagModel.GetInstance()
    self.p_item = param["p_item"]
    self.p_item_base = param["p_item_base"]
    self.size = param["size"]
    self.num = param["num"]
    self.sex = param["sex"]
    self.can_click = param["can_click"]
    self.out_call_back = param["out_call_back"]
    self.operate_param = param["operate_param"]
    self.not_need_compare = param["not_need_compare"]
    self.is_dont_set_pos = param["is_dont_set_pos"]
    self.show_up_tip = param["show_up_tip"] or false
    self.up_tip_action = param["up_tip_action"] or false
    self.color_effect = param["color_effect"] or 999
    self.stencil_id = param["stencil_id"]
    self.stencil_type = param["stencil_type"]
    self.no_show_order = param["no_show_order"]
    self.effect_type = param["effect_type"] or 1
    self.bind = param["bind"] or 1
    self.show_num = param["show_num"] or false
    self.show_noput = param["show_noput"] or false
    self.reddot_tab = param["reddot_tab"]
    self.show_reddot = param["show_reddot"] or false
    self.quick_double_click_call_back = param["quick_double_click_call_back"]
    self.last_click_time = 0
    self.is_hide_quatily = param["is_hide_quatily"] or false
    self.is_hide_bind = param["is_hide_bind"] or false
    self.is_showtip = param["is_showtip"] or false
    if param["item_id"] ~= nil then
        self.item_id = RoleInfoModel:GetInstance():GetItemId(param["item_id"])
        self.item_cfg = Config.db_item[self.item_id]
    else
        self.item_cfg = Config.db_item[self.cfg.id]
        self.item_id = self.cfg.id
    end

    if self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        self.cfg = Config.db_equip[self.item_id]
    elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
        self.cfg = Config.db_beast_equip[self.item_id]
    elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
        self.cfg = Config.db_totems_equip[self.item_id]
    elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP and not self.cfg then
        --是宠物装备并且没有传入宠物装备的配置表时，尝试处理配置表
        local order = 1
        if self.p_item and self.p_item.equip and self.p_item.equip.stren_phase then
            order = self.p_item.equip.stren_phase
        elseif self.p_item_base and self.p_item_base.misc and self.p_item_base.mise.stren_phase then
            order = self.p_item_base.mise.stren_phase
        end
        self.cfg = Config.db_pet_equip[self.item_id.."@"..order]
    elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_ARTI_EQUIP then
        self.cfg = Config.db_equip[self.item_id]
    else
        self.cfg = self.cfg or Config.db_item[self.item_id]
    end

    local bind = (self.bind == 1 and true or false)
    local etime = 0
    if self.p_item ~= nil then
        self.uid = self.p_item.uid
        bind = self.p_item.bind
        etime = self.p_item.etime
    elseif self.p_item_base ~= nil then
        self.uid = self.p_item_base.uid
        bind = self.p_item_base.bind
        etime = self.p_item_base.etime
    end

    local icon = self.item_cfg.icon
    local iconTbl = LuaString2Table("{" .. icon .. "}")
    local abName = ""
    if type(iconTbl) == "table" then
        local _sex = self.sex
        if _sex == nil then
            local roleData = RoleInfoModel.Instance:GetMainRoleData()
            _sex = roleData.sex
            self.sex = _sex
        end

        if iconTbl[self.sex] ~= nil then
            icon = iconTbl[self.sex]
        else
            for i, v in pairs(iconTbl) do
                icon = v
                break
            end
        end
    end

    --宠物装备icon特殊处理
    if self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
        icon = self.cfg.icon
    end

    self:UpdateIconImage(icon)
    self:UpdateQuality(self.item_cfg.color)
    self:UpdateBind(bind)
    self:UpdatePutOn(etime)
    if self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        self:UpdateSizeEquip(self.size)
        if self.cfg.order ~= nil and self.item_cfg.stype ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY
                and self.item_cfg.stype ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY2 then
            self:UpdateStep("T"..self.cfg.order)
        end

        self:UpdateStar(self.cfg.star)

    elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST or self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP then
        self:UpdateSizeEquip(self.size)
        if self.cfg.order ~= nil and self.item_cfg.stype ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY then
            self:UpdateStep("T"..self.cfg.order)
        end
        if self.p_item and self.p_item.extra > 1 then
            self:UpdateStep("+" .. self.p_item.extra);
        end
        self:UpdateStar(self.cfg.star)
    elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
        --宠物装备
        self:UpdateSizeEquip(self.size)

        --有p_item
        if self.p_item and self.p_item.equip then
            self:UpdateStep("T" .. self.p_item.equip.stren_phase)

            --强化等级
            if self.p_item.equip.stren_lv > 0 then
                SetVisible(self.txt_num.transform,true)
                self.txt_num.text = "+"..self.p_item.equip.stren_lv
            else
                SetVisible(self.txt_num.transform,false)
            end
        
            
        end

        --没p_item
        if param["stren_lv"]then
            if param["stren_lv"]>0 then
              --强化等级
                SetVisible(self.txt_num.transform,true)
                self.txt_num.text = "+"..param["stren_lv"]
            else
                SetVisible(self.txt_num.transform,false)
            end
        end

        if self.cfg.order then
            self:UpdateStep("T" .. self.cfg.order)
        end
      

        self:UpdateStar(self.cfg.star)
    elseif self.item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_ARTI_EQUIP then
        self:UpdateStep(self.cfg.order .. ArtifactModel.desTab.jie)
        self:UpdateStar(self.cfg.star)
    else
        self:UpdateSize(self.size)
        self:UpdateStep("")
        SetVisible(self.starContain, false)
    end

    self:UpdateNum(self.num)

    if self.can_click then
        self:AddClickEvent()
    end
    SetVisible(self.upPowerTip, self.show_up_tip)
    if self.show_up_tip and self.up_tip_action then
        local time = 1
        local offset_y = 5
        local x = self.upPowerTip.transform.localPosition.x
        local y = self.upPowerTip.transform.localPosition.y
        local moveAction = cc.MoveTo(time, x, offset_y, 0)
        local moveAction2 = cc.MoveTo(0, x, y, 0)
        local action = cc.Sequence(moveAction, moveAction2)
        local action2 = cc.RepeatForever(action)
        cc.ActionManager:GetInstance():addAction(action2, self.upPowerTip)
    end

    -- if not self.is_dont_set_pos then
    --     SetAnchoredPosition(self.transform, 0, 0)
    -- end
    self:UpdateEffect(self.item_cfg.color)

    self:UpdateReddot(self.show_reddot)

    self:UpdateLV(param["lv"])
    self:UpdateNeedNum(param["need_num"],param["have_num"])
end

function GoodsIconSettorTwo:UpdateSize(size)
    --[[    local IconRect = self.icon:GetComponent("RectTransform")
        IconRect.offsetMax = Vector2(-4.7, -3)
        IconRect.offsetMin = Vector2(6.5, 7.3)--]]
    if not size then
        return
    end
    local w = (type(size) == "table" and size.x or size)
    --[[    local set_w = type(size) == "table" and size.x or size
        local w = 54
        if set_w >= 94 then
            w = 94
        elseif set_w >= 76 then
            w = 76
        elseif set_w >= 60 then
            w = 60
            SetLocalScale(self.countBG.transform, 0.9, 0.9, 1)
            SetAnchoredPosition(self.countBG.transform, -67.61, 24.3)
        end
        -- self.selfRectTra.sizeDelta = Vector2(w, w)
        SetSizeDelta(self.transform, w, w)--]]
    SetSizeDelta(self.transform, w, w)
end

function GoodsIconSettorTwo:UpdateSizeEquip(size)
    if not size then
        return
    end

    local new_x = size.x / 78 * 15
    local new_y = size.y / 78 * 14
    self.starContain_componen.cellSize = Vector2(new_x, new_y)
    SetSizeDelta(self.transform, size.x, size.y)
end

function GoodsIconSettorTwo:UpdateBind(bind)

    if self.is_hide_bind then
        SetVisible(self.bindIcon.gameObject, false)
        return
    end

    SetVisible(self.bindIcon.gameObject, bind)
end

function GoodsIconSettorTwo:UpdateStep(step)
    if step ~= nil then
        self.step_component.text = step
    else
        self.step_component.text = ""
    end
    if self.no_show_order then
        self.step_component.text = ""
    end
end

function GoodsIconSettorTwo:SetIconGray()
    -- local qualityImg = self.quality:GetComponent('Image')
    -- local iconImg = self.icon:GetComponent('Image')
    ShaderManager.GetInstance():SetImageGray(self.quality_component, self.stencil_id, self.stencil_type)
    ShaderManager.GetInstance():SetImageGray(self.icon_component, self.stencil_id, self.stencil_type)
    if self.ui_effect then
        self.ui_effect:destroy()
        self.ui_effect = nil
    end
end

function GoodsIconSettorTwo:SetIconNormal()
    -- local qualityImg = self.quality:GetComponent('Image')
    -- local iconImg = self.icon:GetComponent('Image')
    ShaderManager.GetInstance():SetImageNormal(self.quality_component)
    ShaderManager.GetInstance():SetImageNormal(self.icon_component)
end

function GoodsIconSettorTwo:ShowTips()

end

function GoodsIconSettorTwo:UpdateIconImage(icon)
    if self.last_goods_icon == icon then
        return
    end
    self.last_goods_icon = icon
    -- local iconImg = self.icon:GetComponent('Image')
    GoodIconUtil.GetInstance():CreateIcon(self, self.icon_component, icon, true)
end

function GoodsIconSettorTwo:UpdateStar(star)
    star = star or 0
    SetVisible(self.starContain, true)
    local startCount = self.starContain.childCount
    for i = 0, startCount - 1 do
        if i < star then
            SetVisible(self.starContain:GetChild(i), true)
        else
            SetVisible(self.starContain:GetChild(i), false)
        end
    end
end

function GoodsIconSettorTwo:UpdateNum(num)
    --if self.num == nil then
    --    return
    --end
    if not self.is_loaded then
        return
    end
    if num == nil then
        num = ""
        SetVisible(self.countBG.gameObject, false)
    else
        SetVisible(self.countBG.gameObject, true)
        if type(num) ~= "string" then
            num = GetShowNumber(num)
            if num == 0 or num == 1 then
                if not self.show_num then
                    SetVisible(self.countBG.gameObject, false)
                end
            end
        end
    end

    self.countTxt.text = tostring(num)
end

--更新品质
function GoodsIconSettorTwo:UpdateQuality(quality)

    if self.is_hide_quatily then
        SetVisible(self.quality, false)
        return
    end

    if self.last_quality == quality then
        return
    end
    self.last_quality = quality
    lua_resMgr:SetImageTexture(self, self.quality_component, "common_image", "com_icon_bg_" .. quality, true)
end

--是否激活射线检测（接收点击事件）
function GoodsIconSettorTwo:UpdateRayTarget(visable)
    self.touch_component.raycastTarget = visable
end

function GoodsIconSettorTwo:UpdateEffect(color)
    local scale = GetSizeDeltaX(self.transform) / 96
    local pos = { x = 0, y = 0, z = 0 }
    if self.ui_effect then
        self.ui_effect:destroy()
        self.ui_effect = nil
    end
    if color > self.color_effect and not self.ui_effect then
        local effect_id = self.model:GetEffectIdByColor(color, self.effect_type)
        if effect_id > 0 then
            self.ui_effect = UIEffect(self.transform, effect_id)
            self.ui_effect:SetConfig({ scale = scale, pos = pos })
        end
        if self.stencil_id then
            if self.ui_effect then
                self.ui_effect:SetConfig({ useStencil = true, stencilId = self.stencil_id, stencilType = self.stencil_type, scale = scale, pos = pos })
            end
        end
    end
end

function GoodsIconSettorTwo:UpdateReddot(visible)
    --不需要显示红点 并且没实例化过红点的 就不需要后续处理了
    if not visible and not self.reddot then
        return
    end

    self.reddot = self.reddot or RedDot(self.transform)
    SetLocalPositionZ(self.reddot.transform, 0)
    SetAnchoredPosition(self.reddot.transform, 34.5, 35)
    SetVisible(self.reddot, visible)
end

function GoodsIconSettorTwo:ClickEvent()
    if AppConfig.Debug then
        --Notify.ShowText(self.item_id)
    end
    if self.uid ~= nil and self.need_deal_quick_double_click then
        if self.last_click_time == 0 then
            self.last_click_time = UnityEngine.Time.realtimeSinceStartup
            self.time_scheld_id = GlobalSchedule:StartOnce(handler(self, self.QuickDoubleClickEnd), 0.32, false)
        else
            local span_time = UnityEngine.Time.realtimeSinceStartup - self.last_click_time
            if span_time <= 0.3 then
                --双击检测时间0.3秒
                if self.time_scheld_id ~= nil then
                    GlobalSchedule:Stop(self.time_scheld_id)
                    self.time_scheld_id = nil
                end
                if self.quick_double_click_call_back ~= nil then
                    self.quick_double_click_call_back()
                end
            end

            self.last_click_time = 0
        end
    else
        self:ClickCallBack()
    end
    if self.uid ~= nil then
        GlobalEvent:Brocast(BagEvent.ClickItem, self.uid)
    end
end

function GoodsIconSettorTwo:QuickDoubleClickEnd()
    if self.time_scheld_id ~= nil then
        GlobalSchedule:Stop(self.time_scheld_id)
        self.time_scheld_id = nil
    end

    self:ClickCallBack()
end

--更新等级
function GoodsIconSettorTwo:UpdateLV(lv)

    if not lv then
        SetVisible(self.lv, false)
        return
    end

    SetVisible(self.lv, true)
    self.lv.text = "LV." .. lv

end

--更新需要数量
function GoodsIconSettorTwo:UpdateNeedNum(need_num,have_num)
    if not need_num and not have_num then
        SetVisible(self.needNum,false)
        return
    end
    SetVisible(self.needNum,true)

    local color
    if need_num <= have_num then
        color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
    else
        color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
    end
    have_num = GetShowNumber(have_num)
    local str = string.format("<color=#%s>%s/%s</color>",color,have_num,need_num)
    self.needNum.text = str
end