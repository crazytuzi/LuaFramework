--
-- @Author: chk
-- @Date:   2018-08-20 19:15:34
--

require('game.bag.RequireBag')

BagController = BagController or class("BagController", BaseController)
local this = BagController

function BagController:ctor()
    BagController.Instance = self
    self.goodsViews = {}
    self.view_index = 0
    self.model = BagModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function BagController:dctor()
end

function BagController:GetInstance()
    if not BagController.Instance then
        BagController.new()
    end
    return BagController.Instance
end

function BagController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1101_bag_pb"
    self:RegisterProtocal(proto.BAG_INFO, self.HandleBagInfo)
    self:RegisterProtocal(proto.BAG_OPEN, self.HandleOpenCell)
    self:RegisterProtocal(proto.BAG_UPDATE, self.HandleBagUpdate)
end

function BagController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()
    -- self:RequestLoginVerify()
    -- end
    -- self.model:AddListener(BagModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)


    self:AddOpenBagPanelEvent()
    self.model:AddListener(BagEvent.UseGoodsView, handler(self, self.DealAddItems))
    self.model:AddListener(BagEvent.UseGoods, handler(self, self.DealUseGoods))

    self.model:AddListener(BagEvent.LoadBagItems, handler(self,self.UpdateBagRedDot))
    GlobalEvent:AddListener(BagEvent.UpdateGoods, handler(self,self.UpdateBagRedDotAndSmelt))

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(BagSmeltPanel):Open()
    end
    GlobalEvent:AddListener(BagEvent.OpenBagSmeltPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(OpenBagInputPanel):Open()
    end
    GlobalEvent:AddListener(BagEvent.OpenBagInputPanel, call_back)

    local function call_back(index)
        self.goodsViews[index] = nil
    end
    GlobalEvent:AddListener(BagEvent.DesUseGoodsView, call_back)
end

function BagController:AddOpenBagPanelEvent()
    local function callBack (...)
        print('--chk BagController.lua,line 47-- data=', data)
        local jump_param = {...}  -- 跳转参数
        BagModel.openPanelIndex = jump_param[1]
        lua_panelMgr:GetPanelOrCreate(BagPanel):Open(jump_param)
    end

    print('--chk BagController.lua,line 52-- data=', data)
    GlobalEvent:AddListener(BagEvent.OpenBagPanel, callBack)
end

function BagController:DealUseGoods(goodsItem,auto_use_count)
    local itemCfg = Config.db_item[goodsItem.id]
    --lua_panelMgr:GetPanelOrCreate(BatchUsePanel):Open(goodsItem)
    if itemCfg.use_num == 1 then
        GoodsController.GetInstance():RequestUseItem(goodsItem.uid, 1)
    else
        local item_id = BagModel:GetInstance():GetItemIdByUid(goodsItem.uid)
        local gift_config = GoodsModel:GetInstance():GetGiftConfig(item_id)
        if gift_config and gift_config.type == enum.GIFT_TYPE.GIFT_TYPE_SELECT then
            GoodsController.GetInstance():RequestUseItem(goodsItem.uid, 1)
        elseif goodsItem.num == 1 then
            GoodsController.GetInstance():RequestUseItem(goodsItem.uid, 1)
        else
            lua_panelMgr:GetPanelOrCreate(BatchUsePanel):Open(goodsItem,auto_use_count)
        end
    end
end

function BagController:DealAddItems(goodsItem)
    local itemCfg = Config.db_item[goodsItem.id]
    local roleData = RoleInfoModel:GetInstance():GetMainRoleData()
    if roleData.level < itemCfg.level_limit then
        return
    end
    if itemCfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        if goodsItem.id == 11020147 then
            return
        end
        local equipConfig = Config.db_equip[goodsItem.id]
        if not (EquipModel.Instance:GetEquipIsMapCareer(goodsItem.id) and roleData.wake >= equipConfig.wake) then
            return
        end

        if BagModel.GetInstance():IsExpire(goodsItem.etime) then
            return
        end

        if roleData.level >= itemCfg.level then
            local putOnEquip = BagModel.Instance:GetPutOn(goodsItem.id)
            if putOnEquip ~= nil then
                if putOnEquip.score < goodsItem.score or BagModel.GetInstance():IsExpire(putOnEquip.etime) then
                    self.view_index = self.view_index + 1
                    self.goodsViews[self.view_index] = UseGoodsView()
                    self.goodsViews[self.view_index]:UpdateInfo(goodsItem, self.view_index)
                end
            else
                self.view_index = self.view_index + 1
                self.goodsViews[self.view_index] = UseGoodsView()
                self.goodsViews[self.view_index]:UpdateInfo(goodsItem, self.view_index)
            end
        end

    elseif itemCfg.quick_use == 1 then
        self.view_index = self.view_index + 1
        self.goodsViews[self.view_index] = UseGoodsView()
        self.goodsViews[self.view_index]:UpdateInfo(goodsItem, self.view_index)
    end
end

-- overwrite
function BagController:GameStart()
    local function step()
        self:RequestBagInfo(BagModel.bagId)
        self:RequestBagInfo(BagModel.wareHouseId)
        --self:RequestBagInfo(BagModel.Stigmata)
        self:RequestBagInfo(BagModel.beast)
        self:RequestBagInfo(BagModel.illustration)
        self:RequestBagInfo(BagModel.God)
        self:RequestBagInfo(BagModel.mecha)
        self:RequestBagInfo(BagModel.PetEquip)
        --self:RequestBagInfo(BagModel.artifact)
        self:UpdateBagRedDot()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Best)
end

--请求打开背包
function BagController:RequestBagInfo(bagId)
    local pb = self:GetPbObject("m_bag_info_tos")
    pb.bag_id = tonumber(bagId)
    self:WriteMsg(proto.BAG_INFO, pb)

    print('--BagController 请求背包 70-- data=', pb.bag_id)
end

function BagController:HandleBagInfo()
    local data = self:ReadMsg("m_bag_info_toc")

    if data.bag_id == BagModel.bagId then
        self.model.bagOpenCells = data.opened
        self.model.bagItems = data.items
        self.model:AddBagItemsType(data.items)
        self.model:ArrangeGoods(self.model.bagItems)
        self.model:Brocast(BagEvent.LoadBagItems, data.bag_id)
    elseif data.bag_id == BagModel.wareHouseId then
        self.model.wareHouseOpenCells = data.opened
        self.model.wareHouseItems = data.items
        self.model:ArrangeGoods(self.model.wareHouseItems)
        self.model:Brocast(BagEvent.LoadWareItems, data.bag_id)
    elseif data.bag_id == BagModel.Stigmata then
        self.model.stigmataOpenCells = data.opened
        self.model.stigmataItems = data.items
        self.model:ArrangeGoods(self.model.stigmataItems)
        self.model:Brocast(StigmataEvent.LoadStigmataItems, data.bag_id)
    elseif data.bag_id == BagModel.cardBag then
        CardModel:GetInstance():HandleCardBags(data);
    elseif data.bag_id == BagModel.Pet then
        GlobalEvent:Brocast(BagEvent.PetBagDataEvent, data)
    elseif data.bag_id == BagModel.baby then
        self.model.babyOpenCells = data.opened
        self.model.babyItems = data.items
        self.model:ArrangeGoods(self.model.babyItems)
        GlobalEvent:Brocast(BabyEvent.BabyBagInfo, data)
    elseif data.bag_id == BagModel.illustration then
        self.model.illustrationOpenCells = data.opened
        self.model.illustrationItems = data.items
        self.model:ArrangeGoods(self.model.illustrationItems)
        self.model:Brocast(illustrationEvent.LoadillustrationItems, data)
    elseif data.bag_id == BagModel.God then
        self.model.godOpenCells = data.opened
        self.model.godItems = data.items
        self.model:ArrangeGoods(self.model.godItems)
        GlobalEvent:Brocast(GodEvent.GodBagInfo, data)
    elseif data.bag_id == BagModel.mecha then
        self.model.mechaOpenCells = data.opened
        self.model.mechaItems = data.items
        self.model:ArrangeGoods(self.model.mechaItems)
        GlobalEvent:Brocast(MachineArmorEvent.MechaBagInfo, data)
    elseif data.bag_id == BagModel.artifact then
        self.model.artifactOpenCells = data.opened
        self.model.artifactItems = data.items
        self.model:AddAriBagItemsType(data.items)
        self.model:ArrangeGoods(self.model.artifactItems)
        GlobalEvent:Brocast(ArtifactEvent.ArtifactBagInfo, data)
    else
        self.model:SetOtherBags(data)
    end

    self.model:Brocast(BagEvent.LoadItemByBagId, data.bag_id)
end

--请求开吂格子
function BagController:RequestOpenCell(bagId, count)
    Chkprint('--chk BagController.lua,请求开启背包格子 92-- bagId=', bagId)
    local pb = self:GetPbObject("m_bag_open_tos")
    pb.bag_id = tonumber(bagId)
    pb.num = tonumber(count)
    self:WriteMsg(proto.BAG_OPEN, pb)
end

function BagController:HandleOpenCell()
    Chkprint('--chk BagController.lua,开启背包格子返回 100-- data=', data)
    local data = self:ReadMsg("m_bag_open_toc")
    self.model:SetOpenBagNum(data)
end

function BagController:HandleBagUpdate()
    local data = self:ReadMsg("m_bag_update_toc")
    local isTip = self.model:IsNotify(data.way)
    if data.del ~= nil then
        self.model:DelItems(data.del, isTip)
        self.model:DelOtherItems(data.del)
    end

    if data.add ~= nil then
        self.model:AddItems(data.add, isTip)
        self.model:AddToOtherBags(data.add)
    end

    if data.chg ~= nil then
        self.model:UpdateItems(data.chg, isTip)
        self.model:UpdateOtherItems(data.chg)
    end

    self:ItemFlyAction(data)
end

--根据itemid获取物品数量(可叠加的物品)
function BagController:GetItemListNum(ItemId)
    local item = Config.db_item[ItemId]
    local Num = 0
    local bagitems = self.model:GetBagItems()
    for _, p_item_base in pairs(bagitems) do
        if type(p_item_base) == "table" and p_item_base.id == ItemId then
            if item.lap == 1 then
                return p_item_base.num
            else
                Num = Num + p_item_base.num
            end
        end
    end
    return Num
end

--获取装备列表
function BagController:GetEquipList(ItemId)
    local item = Config.db_item[ItemId]
    if item.type ~= enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        return
    end
    local result = {}
    local bagitems = self.model:GetBagItems()
    for _, p_item_base in pairs(bagitems) do
        if type(p_item_base) == "table" and p_item_base.id == ItemId then
            table.insert(result, p_item_base)
        end
    end
    return result
end

function BagController:UpdateBagRedDot()
    self.model:UpdateCanSmeltEquips()
    local open_level = tonumber(String2Table(Config.db_game["smelt_lv"].val)[1])
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    local num = self.model:FilterSmelt()
    local sell_num = self.model:GetCanSellItems()
    local can_level_up = StigmataModel:GetInstance():GetCanStigmataLevelUp()
    local can_put_on = StigmataModel:GetInstance():GetCanStigmataPutOn()
    local show_reddot = ((level>=open_level and num > 5) or sell_num >= 20 or can_level_up or can_put_on)
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "bag", show_reddot)
end

function BagController:UpdateBagRedDotAndSmelt()
    self:UpdateBagRedDot()
    self.model:AutoSmelt()
end

function BagController:ItemFlyAction(data)
    local log = data.way
    local add = data.add
    local chg = data.chg
    local result = BagItemFlyConfig.logs[log]
    local need_fly = false
    if result then
        if type(result) == "table" then
            local scene_id = SceneManager:GetInstance():GetSceneId()
            local scenecfg = Config.db_scene[scene_id]
            if scenecfg and result[scenecfg.stype] then
                need_fly = true
            end
        else
            need_fly = true
        end
    end
    if need_fly then
        local icons = {}
        for _, v in ipairs(add) do
            local itemid = v.id
            local itemcfg = Config.db_item[itemid]
            if itemcfg.fly == 1 then
                table.insert(icons, itemcfg.icon)
            end
        end
        for uid, _ in pairs(chg) do
            local pitem = self.model:GetItemByUid(uid)
            if pitem then
                local itemcfg = Config.db_item[pitem.id]
                if itemcfg.fly == 1 then
                    table.insert(icons, itemcfg.icon)
                end
            end
        end
        local index = 1
        local function fly_action()
            local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Top)
            local item = BagFlyItem(UITransform)
            local icon = icons[index]
            item:SetData(icon)
            index = index+1
            if index == #icons then
                GlobalSchedule:Stop(self.fly_schedule)
                self.fly_schedule = nil
            end
        end
        if #icons > 0 then
            self.fly_schedule = GlobalSchedule:Start(fly_action, 0.5, #icons)
        end
    end
end
