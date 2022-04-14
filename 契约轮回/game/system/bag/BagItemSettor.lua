--
-- @Author: chk
-- @Date:   2018-08-20 20:28:33
--
 BagItemSettor = BagItemSettor or class("BagItemSettor", BaseBagIconSettor)
local BagItemSettor = BagItemSettor

function BagItemSettor:ctor(parent_node, layer)
    self.abName = "system"
    self.assetName = "BagItem"
    self.layer = layer
    --self.need_deal_quick_double_click = true

    BagItemSettor.super.Load(self)
end

function BagItemSettor:LoadCallBack()
    self.nodes = {
        "lockIcon",
    }

    self:GetChildren(self.nodes)

    BagItemSettor.super.LoadCallBack(self)

    if self.need_set_lock_end then
        self:SetCellIsLock(self.bag)
    end
end

function BagItemSettor:AddEvent()
    BagItemSettor.super.AddEvent(self)
    self.events[#self.events + 1] = self.model:AddListener(BagEvent.OpenCell, handler(self, self.ResponeOpenCell))
    self.events[#self.events + 1] = self.model:AddListener(BagEvent.BagArrange, handler(self, self.DealBagArrange))
    self.events[#self.events + 1] = self.model:AddListener(BagEvent.CheckQuickUse, handler(self, self.DealCheckQuickUse))

    --self.events[#self.events + 1] = self.model:AddListener(StigmataEvent.GetStigmataPanelData, handler(self, self.GetPanelData))

    AddClickEvent(self.touch.gameObject, handler(self, self.ClickEvent), nil, 0)
end

function BagItemSettor:SetData(data)

end

--存储物品
function BagItemSettor:StoreItem(param)
    GoodsController.Instance:RequestStoreItem(param[1].uid, param[1].num)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--使用物品
function BagItemSettor:UseItem(param)

    local itemConfig = Config.db_item[param[1].id]
    if itemConfig.usage == 1 then
        BagModel.Instance:Brocast(BagEvent.UseGoods, param[1])
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    elseif itemConfig.usage == 2 then
        local jumpTbl = String2Table(itemConfig.jump)
        OpenLink(unpack(jumpTbl))
        --TempOpenLink(unpack(jumpTbl))
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
        --if table.nums(jumpTbl) >= 2 then
        --    if table.nums(jumpTbl) >= 2 then
        --        for i, v in pairs(jumpTbl) do
        --            if tonumber(v) then
        --                jumpTbl[i] = tonumber(v)
        --            end
        --        end
        --        OpenLink(unpack(jumpTbl));
        --    end
        --end


    end

    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--出售物品
function BagItemSettor:SellItem(param)
    local itemBase = BagModel.GetInstance():GetItemByUid(param[1].uid)
    local num = itemBase.num
    local itemcfg = Config.db_item[itemBase.id]

    local function call_back()
        local _param = {}
        local kv = { key = param[1].uid, value = num }
        table.insert(_param, kv)
        GoodsController.Instance:RequestSellItems(_param)
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    end
    --if itemcfg.color >= enum.COLOR.COLOR_ORANGE or itemcfg.stype == enum.ITEM_STYPE.ITEM_STYPE_FAIRY then
        local message = string.format("Sure to sell %s*%s？\nCan get gold x<color=#3ab60e>%s</color>\nIt will disappear if you sell it.",
            ColorUtil.GetHtmlStr(itemcfg.color, itemcfg.name), num, itemcfg.price*num)
        Dialog.ShowTwo("Tip",message,"Confirm",call_back)
    --else
    --    call_back()
    --end
    
end

--从仓库取出
function BagItemSettor:TakeOut(param)
    GoodsController.Instance:RequestTakeOut(param[1].uid, param[1].num)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--摧毁道具
function BagItemSettor:DestroyGoodsItem(param)
    GoodsController.Instance:RequestChuckItem(param[1].uid, param[1].num)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--合成跳转
function BagItemSettor:ComposeGoods(param)
    local itemcfg = Config.db_item[param[1].id]
    OpenLink(unpack(String2Table(itemcfg.compose)))
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end


--穿戴装备
function BagItemSettor:PutOnEquip(param)
    EquipController.Instance:RequestPutOnEquipByItem(param[1])
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--续期
function BagItemSettor:RequestValidate(param)
    GlobalEvent:Brocast(ShopEvent.OpenBuyFairyPanel, param[1], param[2])
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--佩戴圣痕
function BagItemSettor:WearSoul(param)

    GlobalEvent:Brocast(GoodsEvent.CloseTipView)

    if not StigmataModel:GetInstance():SoulIsCanPutOnPlayer(param[3].id) then
       Notify.ShowText("You can equip one stigmata with same attributes")
       return
    end

    if not StigmataModel:GetInstance():HaveSetPos(param[4]) then
        local slot = "Common"
        if param[4] == 2 then
            slot = "Core"
        end
        Notify.ShowText(slot .. "This slot is socketed, please remove a stigmata first")
        return
     end

    StigmataController:GetInstance():RequestSoulPutOn(param[1],param[2])
    
end

--凝聚圣痕(单属性圣痕)
function BagItemSettor:CohesionSoul(param)
    --self.model:Brocast(StigmataEvent.OpenStigmataCombine,param[1].id)
    local itemcfg = Config.db_item[param[1].id]
    UnpackLinkConfig(itemcfg.jump)

    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--进阶圣痕(双属性圣痕)
function BagItemSettor:MoveUpSoul(param)
    --self.model:Brocast(StigmataEvent.OpenStigmataCombine,param[1].id)
    local itemcfg = Config.db_item[param[1].id]
    UnpackLinkConfig(itemcfg.jump)

    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end


----卸下圣痕
--function BagItemSettor:TakeOffSoul(param)
--    StigmataController:GetInstance():RequestSoulPutOff(param)
--    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
--end
--
----升级圣痕
--function BagItemSettor:LevelUpSoul(param)
--    StigmataController:GetInstance():RequestSoulUpLevel(param)
--    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
--end

--分解圣痕
function BagItemSettor:DecomposeSoul(param)
    StigmataController:GetInstance():DecomposeSoul(param)
end

--拆解圣痕
function BagItemSettor:DismantleSoul(param)
    StigmataController:GetInstance():DismantleSoul(param)
end

--拆解装备
function BagItemSettor:DismantleEquip(param)

    local item = param[1]

    local panel = lua_panelMgr:GetPanelOrCreate(ComIconTipTwo)
    panel:Open()

    local data = {}

    local function call_back(  )
       --logError(item.uid)
        EquipController.GetInstance():RequestDecombine(item.uid)
        panel:Close()
    end
    data.ok_callback = call_back

    local items = {}

    if table.nums(item.equip.combine) > 0 then
        --有记录返还 直接读combie字段
        data.tip = "Dismantle this gear can get materials back\n Can get following items"
        for k,v in pairs(item.equip.combine) do
            local temp = {v.id,v.num,2}
            table.insert( items, temp)
        end
    else
        --没记录返还 读配置表
        data.tip = "Dismantle this gear and have a chance to get the following items"
        local cfg = Config.db_equip_combine[item.id]
        local cost = String2Table(cfg.cost)
        local other_cost = String2Table(cfg.other_cost)
        local min_num = cfg.min_num

        for k,v in pairs(cost) do
            local temp = {v[1],v[2],2}
            table.insert( items,temp )
        end


        for i=1,min_num do
            local length = #other_cost
            local random_index = Mathf.Random(1,length)
            local v = other_cost[random_index]

            local temp = {v,1,2}
            table.insert( items,temp )

            --只剩一个元素的情况下就不删了 直接用那个元素
            if length >= 2 then
                table.remove( other_cost, random_index)
            end
        end
    end

    --排序一下
    local function sort_func(a,b)
        local a_id = a[1]
        local b_id = b[1]
        local a_cfg = Config.db_item[a_id]
        local b_cfg = Config.db_item[b_id]

        if a_cfg.type ~= b_cfg.type then
            --非装备排在装备前
            return a_cfg.type > b_cfg.type
        end

        if a_id ~= b_id then
            return a_id < b_id
        end
    end
    table.sort( items, sort_func )

    data.items = items

    panel:SetData(data)

    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

function BagItemSettor:DealCheckQuickUse()
    local itemBase = self.model.bagItems[self.__item_index]
    if itemBase ~= nil then
        local ItemCfg = Config.db_item[itemBase.id]
        if ItemCfg.type ~= enum.ITEM_TYPE.ITEM_TYPE_EQUIP and ItemCfg.re_use == 1 then
            self.model:Brocast(BagEvent.UseGoodsView, itemBase)
        end
    end
end

--处理装备(物品)详细信息,要重载
--第1个参数 请求物品的返回的p_item (必传)
--第2个参数 对请求的物品的操作参数 (看着办)
--第3个参数 身上穿的,装备的        (看着办)
function BagItemSettor:DealGoodsDetailInfo(...)
    if not self.gameObject.activeInHierarchy then
        return
    end

    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    local operate_param = {}
    if item.bag == BagModel.bagId then
        --是背包中的物品
        if GoodsModel.GetInstance().isOpenWarePanel then
            --打开了仓库,只有存入操作
            GoodsTipController.Instance:SetStoreCB(operate_param,
                    handler(self, self.StoreItem), { item })
            BagItemSettor.super.DealGoodsDetailInfo(self, item, operate_param)
            return
            --出售

        end
        local cfg_item = Config.db_item[item.id]
        --摧毁道具
        if cfg_item.chuck > 0 then
            GoodsTipController.Instance:SetDestroyCB(operate_param, handler(self, self.DestroyGoodsItem), { item })
        end
        if cfg_item.compose ~= "" then
            GoodsTipController.Instance:SetComposeCB(operate_param, handler(self, self.ComposeGoods), { item })
        end
        if cfg_item.price > 0 then
            GoodsTipController.Instance:SetSellCB(operate_param, handler(self, self.SellItem), { item })
        end
        if MarketModel:GetInstance():GetCanUpShelfItemByItemID(cfg_item.id) and not item.bind and RoleInfoModel:GetInstance():GetMainRoleLevel() >= 90 then
            GoodsTipController.Instance:SetPutOnSellCB(operate_param, handler(self,self.UpShelf), {item})
        end
        if cfg_item.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then

            local puton_item = nil
            if EquipModel.Instance:GetEquipIsMapCareer(item.id)
                    and (item.etime == 0 or item.etime > os.time()) then
                --是否可穿戴
                GoodsTipController.Instance:SetPutOnCB(operate_param,
                        handler(self, self.PutOnEquip), { item })

                puton_item = self.model:GetPutOn(item.id)
            end
            --精灵
            if cfg_item.stype == enum.ITEM_STYPE.ITEM_STYPE_FAIRY then
                if item.etime < os.time() then
                    GoodsTipController.Instance:SetValidateCB(operate_param, handler(self, self.RequestValidate), { item.uid, item.id })
                end
            end

            --判断是否可拆解
            --9阶及以上的粉色装备才能拆解
            local equip_cfg = Config.db_equip[item.id]
            if equip_cfg.order >= 9 and cfg_item.color >= 7 then
                GoodsTipController.Instance:SetDismantleCB(operate_param, handler(self, self.DismantleEquip), { item })
            end

           

            --第1个参数 请求物品的返回的p_item 必传
            --第2个参数 对请求的物品的操作参数
            --第3个参数 身上穿的,装备的

            BagItemSettor.super.DealGoodsDetailInfo(self, item, operate_param, puton_item)
        else
            if cfg_item.usage > 0 then
                GoodsTipController.Instance:SetUseCB(operate_param, handler(self, self.UseItem), { item })
            end

            BagItemSettor.super.DealGoodsDetailInfo(self, item, operate_param)
        end
    elseif item.bag == BagModel.wareHouseId or item.bag == BagModel.stHouseId then
        GoodsTipController.Instance:SetTakeOutCB(operate_param,
                handler(self, self.TakeOut), { item })
        BagItemSettor.super.DealGoodsDetailInfo(self, item, operate_param)

    elseif item.bag == BagModel.Stigmata then   --  当是圣痕背包时的Tips
        local cfg_soul = Config.db_soul[item.id]

        local pos = StigmataModel.GetInstance():ReturnCanSetPos(item.id)

        local attr_type = StigmataModel.GetInstance():ReturnSoulItemAttr_Type(cfg_soul)

        if cfg_soul.slot ~= 0 then

            GoodsTipController.Instance:SetWearCB(operate_param, handler(self, self.WearSoul), { item.uid, pos,item,cfg_soul.slot})
            if #attr_type < 2 then
                if StigmataModel:GetInstance():GetCanJump(item.id) and Config.db_item[item.id].color >= 4 then
                    GoodsTipController.Instance:SetCohesionCB(operate_param, handler(self, self.CohesionSoul), { item })
                end
                
                GoodsTipController.Instance:SetDecomposeCB(operate_param, handler(self, self.DecomposeSoul), { item })
            else
                if StigmataModel:GetInstance():GetCanJump(item.id) then
                    GoodsTipController.Instance:SetMoveUpCB(operate_param, handler(self, self.MoveUpSoul), { item })
                end
            
                GoodsTipController.Instance:SetDismantleCB(operate_param, handler(self, self.DismantleSoul), { item })
            end
        else
            GoodsTipController.Instance:SetDecomposeCB(operate_param, handler(self, self.DecomposeSoul), { item })
        end

        --GoodsTipController.Instance:SetLevelUpCB(operate_param, handler(self, self.LevelUpSoul), { item })
        --GoodsTipController.Instance:SetTakeOffCB(operate_param, handler(self, self.TakeOffSoul), { item })

        BagItemSettor.super.DealGoodsDetailInfo(self, item, operate_param)
    elseif item.bag == BagModel.illustration then 
        BagItemSettor.super.DealGoodsDetailInfo(self, item, operate_param)
    end
end

function BagItemSettor:UpShelf(item)
    --print2("-------1-1-----------")
    GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn, 1,true)
    MarketModel.GetInstance().selectItem = item[1]
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

function BagItemSettor:ClickEvent()
    BagItemSettor.super.ClickEvent(self)
    if self.lockIcon.gameObject.activeInHierarchy then
        self.model:Brocast(BagEvent.OpenCellView, self.bag, self.__item_index)
    end
end

--处理背包整理事件
function BagItemSettor:DealBagArrange(bagId, index)
    Chkprint("整理背包的下标___", index, self.__item_index)
    if bagId == self.bag and self.__item_index == index then
        if self.__item_index == 1 then
            local a = 3
        end
        if bagId == BagModel.bagId then
            if self.model.bagItems ~= nil then
                if index == 1 then
                    local a = 3
                end
                local itemBase = self.model.bagItems[self.__item_index]
                if itemBase == nil or itemBase == 0 then
                    self:DeleteItem()
                else
                    self:DeleteItem()
                    self:LoadItemInfoByBgId(self.bag)
                    local ItemCfg = Config.db_item[itemBase.id]
                    if ItemCfg.type ~= enum.ITEM_TYPE.ITEM_TYPE_EQUIP and ItemCfg.re_use == 1 then
                        self.model:Brocast(BagEvent.UseGoodsView, itemBase)
                    end
                end
            else
                self:DeleteItem()
            end
        elseif bagId == BagModel.wareHouseId then
            if self.model.wareHouseItems ~= nil then
                local itemBase = self.model.wareHouseItems[self.__item_index]
                if itemBase == nil or itemBase == 0 then
                    self:DeleteItem()
                else
                    self:DeleteItem()
                    self:LoadItemInfoByBgId(self.bag)
                end
            else
                self:DeleteItem()
            end
        else
            local mybag = self.model:GetBag(bagId)
            if mybag and mybag.bagItems then
                local itemBase = mybag.bagItems[self.__item_index]
                if itemBase == nil or itemBase == 0 then
                    self:DeleteItem()
                else
                    self:DeleteItem()
                    self:LoadItemInfoByBgId(bagId)
                end
            else
                self:DeleteItem()
            end
        end
    end
end

--接收到打开格子的通知，处理
function BagItemSettor:ResponeOpenCell(bagId, index)
    if bagId == self.bag and self.__item_index == index then
        SetVisible(self.lockIcon, false)
        RemoveClickEvent(self.gameObject)
    end
end

--设置锁按钮
function BagItemSettor:SetCellIsLock(bagId)
    --if 	self.bag == bagId and self.is_loaded then
    local openCells = 0
    if bagId == BagModel.bagId then
        openCells = BagModel.Instance.bagOpenCells
    elseif bagId == BagModel.wareHouseId then
        openCells = BagModel.Instance.wareHouseOpenCells
    elseif bagId == BagModel.Stigmata then
        openCells = BagModel.Instance.stigmataOpenCells
    elseif bagId == BagModel.beast then
        openCells = Config.db_bag[BagModel.beast].cap
    else
        openCells = self.model:GetBag(bagId).opened
    end

    if self.__item_index <= openCells then
        SetVisible(self.lockIcon, false)
    else
        SetVisible(self.lockIcon, true)
        --self:AddOpenCellEvent()
    end

    self.bag = bagId
end

function BagItemSettor:DeleteEvents()
    for k, v in pairs(self.events) do
        self.model:RemoveListener(v)

    end

    self.events = {}

    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end
    self.globalEvents = {}
end

function BagItemSettor:DeleteItem()
    self.is_select = false
    self:SetSelected(self.is_select)
    self.uid = nil
    if self.equipSettor ~= nil then
        self.equipSettor:destroy()
        self.equipSettor = nil
    end

    if self.stoneSettor ~= nil then
        self.stoneSettor:destroy()
        self.stoneSettor = nil
    end
end

--设置是否选中 重写父类同名方法 根据情况选择要显示的selectBg
--对于圣痕来说因为红点放在了stoneSettor下，所以selectBg也需要显示settor下的那个             
function BagItemSettor:SetSelected(show)

    if self.equipSettor then
        BagItemSettor.super.SetSelected(self,show)
        return
    end

    local settor = self.stoneSettor
    if not settor then
        return
    else
        if settor.selectBg ~= nil and tostring(settor.selectBg) ~= "null" and settor.is_loaded then
            SetVisible(settor.selectBg, show)
        end
    end
  
end