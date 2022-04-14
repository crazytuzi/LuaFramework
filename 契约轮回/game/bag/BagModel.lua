--
-- @Author: chk
-- @Date:   2018-08-20 16:43:45
--
BagModel = BagModel or class("BagModel", BaseBagModel)
local this = BagModel
local tableInsert = table.insert

BagModel.bagId = 101                   --背包id
BagModel.wareHouseId = 201             --仓库id
BagModel.stHouseId = 202               --寻宝仓库
BagModel.cardBag = 103                 --卡片仓库
BagModel.UpShelfBag = 203              --市场上架界面
BagModel.beast = 104                   --神兽仓库
BagModel.Pet = 105                     --宠物仓库
BagModel.Stigmata = 102                --圣痕仓库
BagModel.baby = 106                    --子女背包
BagModel.illustration  = 107           --图鉴背包
BagModel.God = 108                     --神灵背包
BagModel.mecha = 109                     --机甲背包
BagModel.PetEquip = 110                 --宠物装备
BagModel.artifact = 401                 --神器背包
BagModel.toems = 402                    --图腾背包


function BagModel:ctor()


    BagModel.Instance = self
    self:Reset()

    --BagModel.super.ctor(self)
end

function BagModel:Reset()
    self.openCellTitle = {}
    self.openCellCount = 1
    self.hasRequest = false            --是否请求过背包中的物品
    self.bagGoodsTipCon = nil          --背包中的物品tip挂载点
    self.bagEquipTipCon = nil          --背包中的装备tip挂载点
    self.baseGoodSettorCLS = nil
    self.canSellItems = {}             --可以出售的物品
    self.sellItemsId = {}             --出售物品的状态(0:没选中出售,1:选中出售)
    self.openPanelIndex = 1            --打开的背包页面标签页
    self.bagOpenCells = 0              --背包开吂的格子数
    self.bagCellsCount = 0             --背包格子数
    self.bagItems = {}                 --背包的物品(p_item_base)
    self.bagTypeItems = {}             --背包分类
    self.wareGoodsTipCon = nil         --仓库中的物品tip挂载点
    self.wareEquipTipCon = nil         --仓库中的装备tip挂载点
    self.wareHouseItems = {}           --仓库的物品(p_item_base)
    self.wareHouseOpenCells = 0        --仓库开吂的格子数
    self.wareHouseCellCount = 0        --仓库格子数
    self.slot_scores = {}              --记录部位最高评分装备

    ----圣痕
    self.stigmataItems = {}             --圣痕背包的物品(p_item_base)
    self.stigmataOpenCells = 0          --圣痕背包开启的格子数
    self.stigmataCellCount = 0          --圣痕背包格子数


    ---子女
    self.babyItems = {}             --子女背包的物品(p_item_base)
    self.babyOpenCells = 0          --子女背包开启的格子数
    self.babyCellCount = 0          --子女背包格子数

    ---图鉴
    self.illustrationItems = {}             --图鉴背包的物品(p_item_base)
    self.illustrationOpenCells = 0          --图鉴背包开启的格子数
    self.illustrationCellCount = 0          --图鉴背包格子数

    ---神灵
    self.godItems = {}
    self.godOpenCells = 0
    self.godCellCount = 0

    --机甲
    self.mechaItems = {}
    self.mechaOpenCells = 0
    self.mechaCellCount = 0


    self.artifactItems = {}
    self.artifactOpenCells = 0
    self.artifactCellCount = 0

    self.openCellTitle[101] = ConfigLanguage.Bag.ExtendBag
    self.openCellTitle[201] = ConfigLanguage.Bag.ExtendWare
    self.EnabledQuickDoubleClick = false --是否允许双击操作

    --其他背包，仓库数据
    self.bags = {}

    self.smelt_equips = {}             --可熔炼物品

    self.usegoodsviews = {}

    self.filter_type = 0
    self.art_flilter_type = 0
end

function BagModel.GetInstance()
    if BagModel.Instance == nil then
        BagModel()
    end
    return BagModel.Instance
end


-- 不用
function BagModel:GetGoldAndItemNumByItemID(itemId)
    if (Constant.GoldIDMap[itemId]) then
        return RoleInfoModel:GetInstance():GetRoleValue(itemId)
    end
    return self:GetItemNumByItemID(itemId)
end

-- 常用
function BagModel:GetItemNumByItemID(itemID)
    if (Constant.GoldIDMap[itemID]) then
        return RoleInfoModel:GetInstance():GetRoleValue(itemID)
    end
    local num = 0
    for i, v in pairs(self.bagItems) do
        if v ~= 0 and v.id == itemID then
            num = num + v.num
        end
    end
    return num
end

function BagModel:GetOpenCellCount(clickIdx, bagWareId)
    if bagWareId == BagModel.bagId then
        return clickIdx - self.bagOpenCells
    elseif bagWareId == BagModel.wareHouseId then
        return clickIdx - self.wareHouseOpenCells
    elseif bagWareId == BagModel.Stigmata then
        return clickIdx - self.stigmataOpenCells
    elseif bagWareId == BagModel.illustration then
        return clickIdx - self.illustrationOpenCells
    end
end

function BagModel:GetItemIdByUid(uid)
    local itemId = 0
    for i, v in pairs(self.bagItems) do
        if v ~= 0 and v.uid == uid then
            itemId = v.id
            break
        end
    end

    return itemId
end

function BagModel:GetUidByItemID(itemID)
    local num = 0
    for i, v in pairs(self.bagItems) do
        if v ~= 0 and v.id == itemID then
            return v.uid;
        end
    end
end

function BagModel:GetEquipsByMoreQuality(quality)
    local equips = {}
    for i, v in pairs(self.bagItems) do
        if v ~= 0 then
            local itemCfg = Config.db_item[v.id]
            if itemCfg.color >= quality and itemCfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
                table.insert(equips, v)
            end
        end

    end
    return equips
end

function BagModel:GetItemsByType(type)
    local items = {}
    for i, v in pairs(self.bagItems) do
        if v ~= 0 and Config.db_item[v.id].type == type then
            table.insert(items, v)
        end
    end

    return items
end

function BagModel:GetItemByItemId(itemId)
    local item = nil
    for i, v in pairs(self.bagItems) do
        if v ~= 0 and v.id == itemId then
            item = v
            break
        end
    end

    return item
end

function BagModel:GetItemByUid(uid)
    local item = nil
    local bag_id = self:GetBagIdByUid(uid)
    if bag_id == self.bagId then
        for i, v in pairs(self.bagItems) do
            if v ~= 0 and v.uid == uid then
                item = v
                break
            end
        end
    elseif bag_id == self.wareHouseId then
        for i, v in pairs(self.wareHouseItems) do
            if v ~= 0 and v.uid == uid then
                item = v
                break
            end
        end
    end

    return item
end

function BagModel:GetBagItemByUid(uid)
    local item = nil
    for i, v in pairs(self.bagItems) do
        if v ~= 0 and v.uid == uid then
            item = v
            break
        end
    end

    return item
end

function BagModel:GetWarehouseItemByUid(uid)
    local item = nil
    for i, v in pairs(self.wareHouseItems) do
        if v ~= 0 and v.uid == uid then
            item = v
            break
        end
    end

    return item
end

function BagModel:GetOtherBagItemByUid(uid)
    local item = nil
    local bagId = self:GetBagIdByUid(uid)
    for i, v in pairs(self.bags[bagId].bagItems or {}) do
        if v ~= 0 and v.uid == uid then
            item = v
            break
        end
    end

    return item
end

function BagModel:GetillustrationItemByUid(uid)
    local item = nil
    for i, v in pairs(self.illustrationItems) do
        if v ~= 0 and v.uid == uid then
            item = v
            break
        end
    end
    return item
end

function BagModel:GetAriItemByUid(uid)
    local item = nil
    for i, v in pairs(self.artifactItems) do
        if v ~= 0 and v.uid == uid then
            item = v
            break
        end
    end
    return item
end


function BagModel:GetBagIdByUid(uid)
    return math.floor(uid / 1000000)
end

function BagModel:AddItems(items, isTip)
    local bag_Id = 0

    local config
    for i, v in pairs(items) do
        config = Config.db_item[v.id]
        if isTip and config and config.mid_inexca == 1 then
            Notify.ShowGoods(v.id, v.num)
        end

        if isTip and self:GetBagIdByUid(v.uid) ~= BagModel.wareHouseId then
            Notify.ShowPickup(v.id, v.num)
        end

        bag_Id = self:GetBagIdByUid(v.uid)
        if self.bagId == bag_Id then
            local hasNil = false
            local nilIndex = 0
            for ii, vv in pairs(self.bagItems) do
                if vv == 0 then
                    hasNil = true
                    nilIndex = ii
                    break
                end
            end

            self:AddBagItemType(v, config)
            if hasNil then
                self.bagItems[nilIndex] = v
                if self.filter_type == 0 then
                    GlobalEvent:Brocast(BagEvent.AddItems, self.bagId, nilIndex)
                end
            else
                table.insert(self.bagItems, v)
                if self.filter_type == 0 then
                    GlobalEvent:Brocast(BagEvent.AddItems, self.bagId, #self.bagItems)
                end
            end

            self:Brocast(BagEvent.UseGoodsView, v)
        elseif self.wareHouseId == bag_Id then
            local hasNil = false
            local nilIndex = 0
            for ii, vv in pairs(self.wareHouseItems) do
                if vv == 0 then
                    hasNil = true
                    nilIndex = ii
                    break
                end
            end

            if hasNil then
                self.wareHouseItems[nilIndex] = v
                GlobalEvent:Brocast(BagEvent.AddItems, self.wareHouseId, nilIndex)
            else
                table.insert(self.wareHouseItems, v)
                GlobalEvent:Brocast(BagEvent.AddItems, self.wareHouseId, #self.wareHouseItems)
            end
        elseif self.Stigmata == bag_Id then
            local hasNil = false
            local nilIndex = 0
            for ii, vv in pairs(self.stigmataItems) do
                if vv == 0 then
                    hasNil = true
                    nilIndex = ii
                    break
                end
            end

            if hasNil then
                self.stigmataItems[nilIndex] = v
                GlobalEvent:Brocast(BagEvent.AddItems, self.Stigmata, nilIndex)
            else
                table.insert(self.stigmataItems, v)
                GlobalEvent:Brocast(BagEvent.AddItems, self.Stigmata, #self.stigmataItems)
            end
        elseif self.baby == bag_Id then
            local hasNil = false
            local nilIndex = 0
            for ii, vv in pairs(self.babyItems) do
                if vv == 0 then
                    hasNil = true
                    nilIndex = ii
                    break
                end
            end

            if hasNil then
                self.babyItems[nilIndex] = v
                GlobalEvent:Brocast(BagEvent.AddItems, self.baby, nilIndex)
            else
                table.insert(self.babyItems, v)
                GlobalEvent:Brocast(BagEvent.AddItems, self.baby, #self.babyItems)
            end
        elseif self.illustration == bag_Id then
            --图鉴
            local hasNil = false
            local nilIndex = 0
            for ii, vv in pairs(self.illustrationItems) do
                if vv == 0 then
                    hasNil = true
                    nilIndex = ii
                    break
                end
            end

            if hasNil then
                self.illustrationItems[nilIndex] = v
                GlobalEvent:Brocast(BagEvent.AddItems, self.illustration, nilIndex)
            else
                table.insert(self.illustrationItems, v)
                GlobalEvent:Brocast(BagEvent.AddItems, self.illustration, #self.illustrationItems)
            end
        elseif self.God == bag_Id then
            --神灵
            local hasNil = false
            local nilIndex = 0
            for ii, vv in pairs(self.godItems) do
                if vv == 0 then
                    hasNil = true
                    nilIndex = ii
                    break
                end
            end

            if hasNil then
                self.godItems[nilIndex] = v
                GlobalEvent:Brocast(BagEvent.AddItems, self.God, nilIndex)
            else
                table.insert(self.godItems, v)
                GlobalEvent:Brocast(BagEvent.AddItems, self.God, #self.godItems)
            end
        elseif self.mecha == bag_Id then
            --机甲
            local hasNil = false
            local nilIndex = 0
            for ii, vv in pairs(self.mechaItems) do
                if vv == 0 then
                    hasNil = true
                    nilIndex = ii
                    break
                end
            end

            if hasNil then
                self.mechaItems[nilIndex] = v
                GlobalEvent:Brocast(BagEvent.AddItems, self.mecha, nilIndex)
            else
                table.insert(self.mechaItems, v)
                GlobalEvent:Brocast(BagEvent.AddItems, self.mecha, #self.mechaItems)
            end
        elseif self.artifact == bag_Id then

            local hasNil = false
            local nilIndex = 0
            for ii, vv in pairs(self.artifactItems) do
                if vv == 0 then
                    hasNil = true
                    nilIndex = ii
                    break
                end
            end
            self:AddArisBagItemType(v, config)
            if hasNil then
                self.artifactItems[nilIndex] = v
                if self.art_flilter_type == 0 then
                    GlobalEvent:Brocast(BagEvent.AddItems, self.artifact, nilIndex)
                end

            else
                table.insert(self.artifactItems, v)
                if self.art_flilter_type == 0 then
                    GlobalEvent:Brocast(BagEvent.AddItems, self.artifact, #self.artifactItems)
                end

            end
        else
            GlobalEvent:Brocast(BagEvent.OtherBagAddEvent, bag_Id, isTip, v)
        end
        self:UpdateGoodsById(v.id)
    end
end

function BagModel:AddBagItemsType(items)
    self.bagTypeItems = {}
    for i=1, #items do 
        local pitem = items[i]
        local itemcfg = Config.db_item[pitem.id]
        local type_bag = itemcfg.type_bag
        self.bagTypeItems[type_bag] = self.bagTypeItems[type_bag] or {}
        local bagItems = self.bagTypeItems[type_bag]
        tableInsert(bagItems, pitem)
    end
end


function BagModel:AddBagItemType(pitem, itemcfg)
    local type_bag = itemcfg.type_bag
    self.bagTypeItems[type_bag] = self.bagTypeItems[type_bag] or {}
    local bagItems = self.bagTypeItems[type_bag]

    local hasNil = false
    local nilIndex = 0
    for ii, vv in pairs(bagItems) do
        if vv == 0 then
            hasNil = true
            nilIndex = ii
            break
        end
    end

    if hasNil then
        bagItems[nilIndex] = pitem
        if self.filter_type == type_bag then
            GlobalEvent:Brocast(BagEvent.AddItems, self.bagId, nilIndex)
        end
    else
        table.insert(bagItems, pitem)
        if self.filter_type == type_bag then
            GlobalEvent:Brocast(BagEvent.AddItems, self.bagId, #bagItems)
        end
    end
end



function BagModel:AddAriBagItemsType(items)
    self.ArisBagTypeItems = {}
    for i=1, #items do
        local pitem = items[i]
        local itemcfg = Config.db_item[pitem.id]
        local type_bag = itemcfg.type_bag
        self.ArisBagTypeItems[type_bag] = self.ArisBagTypeItems[type_bag] or {}
        local bagItems = self.ArisBagTypeItems[type_bag]
        tableInsert(bagItems, pitem)
    end
end

function BagModel:AddArisBagItemType(pitem, itemcfg)
    local type_bag = itemcfg.type_bag
    self.ArisBagTypeItems[type_bag] = self.ArisBagTypeItems[type_bag] or {}
    local bagItems = self.ArisBagTypeItems[type_bag]

    local hasNil = false
    local nilIndex = 0
    for ii, vv in pairs(bagItems) do
        if vv == 0 then
            hasNil = true
            nilIndex = ii
            break
        end
    end

    if hasNil then
        bagItems[nilIndex] = pitem
        if self.art_flilter_type == type_bag then
            GlobalEvent:Brocast(BagEvent.AddItems, self.artifact, nilIndex)
        end
    else
        table.insert(bagItems, pitem)
        if self.art_flilter_type == type_bag then
            GlobalEvent:Brocast(BagEvent.AddItems, self.artifact, #bagItems)
        end
    end
end


function BagModel:DelItem(item)

end

function BagModel:DeleteEmptyItems(bag_id)
    if self.bags[bag_id] ~= nil and self.bags[bag_id].bagItems ~= nil then
        table.removebyvalue(self.bags[bag_id].bagItems, 0, true)
    end

    if self.bags[bag_id] ~= nil and self.bags[bag_id].items ~= nil then
        table.removebyvalue(self.bags[bag_id].items, 0, true)
    end
end

function BagModel:DelBagItemType(uid, type_bag)
    local bagItems = self.bagTypeItems[type_bag] or {}
    for k, v in pairs(bagItems) do
        if v ~= 0 and v.uid == uid then
            bagItems[k] = 0
            break
        end
    end
end

function BagModel:DelAriBagItemType(uid, type_bag)
    local bagItems = self.ArisBagTypeItems[type_bag] or {}
    for k, v in pairs(bagItems) do
        if v ~= 0 and v.uid == uid then
            bagItems[k] = 0
            break
        end
    end
end

function BagModel:DelItems(dels)
    if dels ~= nil then
        for i, v in pairs(dels) do
            local del = false
            local itemid
            local bag_Id = self:GetBagIdByUid(v)
            if bag_Id == self.bagId then
                for ii, vv in pairs(self.bagItems) do
                    if vv ~= 0 and vv.uid == v then
                        del = true
                        itemid = vv.id
                        self.bagItems[ii] = 0
                        local type_bag = Config.db_item[vv.id].type_bag
                        self:DelBagItemType(v, type_bag)
                        break
                    end
                end

            elseif bag_Id == self.wareHouseId then
                for ii, vv in pairs(self.wareHouseItems) do
                    if vv ~= 0 and vv.uid == v then
                        del = true
                        itemid = vv.id
                        self.wareHouseItems[ii] = 0
                        --table.remove(self.wareHouseItems,ii)
                        break
                    end
                end
            elseif bag_Id == self.Stigmata then
                for ii, vv in pairs(self.stigmataItems) do
                    if vv ~= 0 and vv.uid == v then
                        del = true
                        itemid = vv.id
                        self.stigmataItems[ii] = nil
                        --table.remove(self.model.stigmataItems,ii)
                        break
                    end
                end
            elseif bag_Id == self.baby then
                for ii, vv in pairs(self.babyItems) do
                    if vv ~= 0 and vv.uid == v then
                        del = true
                        itemid = vv.id
                        self.babyItems[ii] = nil
                        --table.remove(self.model.stigmataItems,ii)
                        break
                    end
                end
            elseif bag_Id == self.illustration then
                --图鉴
                for ii, vv in pairs(self.illustrationItems) do
                    if vv ~= 0 and vv.uid == v then
                        del = true
                        itemid = vv.id
                        self.illustrationItems[ii] = nil
                        --table.remove(self.model.stigmataItems,ii)
                        break
                    end
                end
            elseif bag_Id == self.God then
                for ii, vv in pairs(self.godItems) do
                    if vv ~= 0 and vv.uid == v then
                        del = true
                        itemid = vv.id
                        self.godItems[ii] = nil
                        --table.remove(self.model.stigmataItems,ii)
                        break
                    end
                end
            elseif bag_Id == self.mecha then
                for ii, vv in pairs(self.mechaItems) do
                    if vv ~= 0 and vv.uid == v then
                        del = true
                        itemid = vv.id
                        self.mechaItems[ii] = nil
                        --table.remove(self.model.stigmataItems,ii)
                        break
                    end
                end
            elseif bag_Id == self.artifact then
                for ii, vv in pairs(self.artifactItems) do
                    if vv ~= 0 and vv.uid == v then
                        del = true
                        itemid = vv.id
                        self.artifactItems[ii] = nil
                        local type_bag = Config.db_item[vv.id].type_bag
                        self:DelAriBagItemType(v, type_bag)
                        --table.remove(self.model.stigmataItems,ii)
                        break
                    end
                end
            else
                GlobalEvent:Brocast(BagEvent.OtherBagDelEvent, bag_Id, v)
            end

            if del then
                GlobalEvent:Brocast(GoodsEvent.DelItems, bag_Id, v)
                self:UpdateGoodsById(itemid)
            end
        end
    end
end

function BagModel:UpdateItems(changeMap, isTip)
    for k, v in pairs(changeMap) do
        local bag_id = self:GetBagIdByUid(k)
        local item
        if bag_id == self.bagId then
            item = self:GetBagItemByUid(k)
            if item ~= nil then
                if isTip and v > item.num then
                    local config = Config.db_item[item.id]
                    local update_num = v - item.num
                    if config and config.mid_inexca == 1 then
                        Notify.ShowGoods(item.id, update_num)
                    end
                    Notify.ShowPickup(item.id, update_num)
                end
                local old_num = item.num
                item.num = v
                Chkprint("更新物品uid_数量", k, v)
                GlobalEvent:Brocast(GoodsEvent.UpdateNum, bag_id, k, v)
                if old_num < item.num then
                    self:Brocast(BagEvent.UseGoodsView, item)
                end 
            end
        elseif bag_id == self.wareHouseId then
            item = self:GetWarehouseItemByUid(k)
            if item ~= nil then
                if v > item.num then
                    local config = Config.db_item[item.id]
                    if config and config.mid_inexca == 1 then
                        Notify.ShowGoods(item.id, item.num)
                        Notify.ShowPickup(item.id, item.num)
                    end
                end
                item.num = v
                GlobalEvent:Brocast(GoodsEvent.UpdateNum, bag_id, k, v)
            end
        elseif bag_id == self.illustration then
            --图鉴背包物品数量更新
            item = self:GetillustrationItemByUid(k)
            if item ~= nil then
                if v > item.num then
                    local config = Config.db_item[item.id]
                    local update_num = v - item.num
                    if config and config.mid_inexca == 1 then
                        Notify.ShowGoods(item.id, update_num)
                    end
                    Notify.ShowPickup(item.id, update_num)
                end
                item.num = v
                GlobalEvent:Brocast(GoodsEvent.UpdateNum, bag_id, k, v)
            end
        elseif bag_id == self.artifact then
            --图鉴背包物品数量更新
            item = self:GetAriItemByUid(k)
            if item ~= nil then
                if v > item.num then
                    local config = Config.db_item[item.id]
                    local update_num = v - item.num
                    if config and config.mid_inexca == 1 then
                        Notify.ShowGoods(item.id, update_num)
                    end
                    Notify.ShowPickup(item.id, update_num)
                end
                item.num = v
                GlobalEvent:Brocast(GoodsEvent.UpdateNum, bag_id, k, v)
            end
        else
            GlobalEvent:Brocast(BagEvent.OtherBagUpdateEvent, bag_id, k, v)
        end
        if item then
            self:UpdateGoodsById(item.id)
        end
    end
end


--出售后，更新物品
function BagModel:UpdateItemsBySell(changeMap)
    local delIds = {}
    local delbeastIds = {}
    for k, v in pairs(changeMap) do
        local bag_id = self:GetBagIdByUid(k)
        if bag_id == self.bagId then
            local item = self:GetBagItemByUid(k)
            if item ~= nil then
                if v >= item.num then
                    table.insert(delIds, k)
                end
            end
        else
            local item = self:GetOtherBagItemByUid(k)
            if v >= item.num then
                table.insert(delbeastIds, k)
            end
        end
    end

    self:DelItems(delIds)
    self:DelOtherItems(delbeastIds)
end

function BagModel:SetOpenBagNum(data)
    local beginIdx = 0
    local endIdx = 0

    if data.bag_id == self.bagId then
        beginIdx = self.bagOpenCells
        self.bagOpenCells = data.num + self.bagOpenCells
        endIdx = self.bagOpenCells
    elseif data.bag_id == self.wareHouseId then
        beginIdx = self.wareHouseOpenCells
        self.wareHouseOpenCells = data.num + self.wareHouseOpenCells
        endIdx = self.wareHouseOpenCells
    elseif data.bag_id == self.Stigmata then
        beginIdx = self.stigmataOpenCells
        self.stigmataOpenCells = data.num + self.stigmataOpenCells
        endIdx = self.stigmataOpenCells
    elseif data.bag_id == self.baby then
        beginIdx = self.babyOpenCells
        self.babyOpenCells = data.num + self.babyOpenCells
        endIdx = self.babyOpenCells
    elseif data.bag_id == self.illustration then
        beginIdx = self.illustrationOpenCells
        self.illustrationOpenCells = data.num + self.illustrationOpenCells
        endIdx = self.illustrationOpenCells
    elseif data.bag_id == self.God then
        beginIdx = self.godOpenCells
        self.godOpenCells = data.num + self.godOpenCells
        endIdx = self.godOpenCells
    elseif data.bag_id == self.mecha then
        beginIdx = self.mechaOpenCells
        self.mechaOpenCells = data.num + self.mechaOpenCells
        endIdx = self.mechaOpenCells
    end

    for i = beginIdx, endIdx do
        self:Brocast(BagEvent.OpenCell, data.bag_id, i)    --开启第几个格子
    end

end


--整理物品
function BagModel:ArrangeGoods(items)
    local preSortItems = {}    --排序之前的items
    local fromSortIdx = 0
    local endSortIdx = 0
    if items ~= nil then
        for k, v in pairs(items) do
            preSortItems[k] = v
        end

        table.removebyvalue(items, 0, true)
        table.removebyvalue(items, nil, true)

        items = items or {}
        if type(items) == "table" and #items >= 2 then
            local function call_back(item1, item2)

                if item1 ~= nil and item2 ~= nil and Config.db_item[item1.id] ~= nil and Config.db_item[item2.id] ~= nil then
                    local itemCfg1 = Config.db_item[item1.id]
                    local itemCfg2 = Config.db_item[item2.id]
                    local sortKey1 = itemCfg1.type .. "@" .. itemCfg1.stype
                    local sortKey2 = itemCfg2.type .. "@" .. itemCfg2.stype
                    local sortItem1 = Config.db_item_type[sortKey1]
                    local sortItem2 = Config.db_item_type[sortKey2]
                    local order1 = (sortItem1 and sortItem1.order or 9999)
                    local order2 = (sortItem2 and sortItem2.order or 9999)

                    if order1 < order2 then
                        return true
                    elseif order1 == order2 then
                        local bind1 = (item1.bind and 1 or 0)
                        local bind2 = (item2.bind and 1 or 0)
                        if bind1 > bind2 then
                            return true
                        elseif bind1 == bind2 then
                            --装备
                            if itemCfg1.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
                                if item1.score > item2.score then
                                    return true
                                elseif item1.score == item2.score then
                                    return item1.id > item2.id
                                else
                                    return false
                                end
                                --道具
                            else
                                if itemCfg1.color > itemCfg2.color then
                                    return true
                                elseif itemCfg1.color == itemCfg2.color then
                                    return item1.id > item2.id
                                else
                                    return false
                                end
                            end
                        else
                            return false
                        end
                    else
                        return false
                    end
                end
            end
            table.sort(items, call_back)
        end

        if items == self.stigmataItems then
            StigmataModel.GetInstance():SortStigmataBag(items)
        end

        if items == self.illustrationItems then
            illustrationModel.GetInstance():SortIllustrationBag(items)
        end

        local preCount = #preSortItems
        if preCount > 0 then
            for i = 1, preCount do
                local preSortItem = preSortItems[i]
                local item = items[i]
                if preSortItem ~= 0 and preSortItem ~= nil and item ~= 0 and item ~= nil and preSortItem.uid ~= item.uid then
                    fromSortIdx = i
                    endSortIdx = #preSortItems
                    break
                elseif preSortItems[i] == 0 or preSortItems[i] == nil then
                    fromSortIdx = i
                    endSortIdx = #preSortItems
                    break
                end
            end
        end
        --for k,v in pairs(preSortItems) do
        --
        --end
    end

    return fromSortIdx, endSortIdx
end

function BagModel:DelSellItemByUid(uid)
    for i, v in pairs(self.sellItemsId) do
        if uid == v then
            local itemBase = self:GetSellItemByUid(uid)
            table.removebyvalue(self.canSellItems, itemBase)
            table.removebyvalue(self.sellItemsId, v)
            self:Brocast(BagEvent.SetSellMoney)
            break
        end
    end
end

function BagModel:GetSellItemByUid(uid)
    local itemBase = nil
    for i, v in pairs(self.canSellItems) do
        if v.uid == uid then
            itemBase = v
            break
        end
    end

    return itemBase
end

function BagModel:GetSellItemsMoney()
    local money = 0
    for i, v in pairs(self.sellItemsId) do
        local itemBase = self:GetItemByUid(v)
        local itemConfig = Config.db_item[itemBase.id]
        money = money + itemConfig.price * itemBase.num
    end

    return money
end

--出售物品的参数,传给后台
function BagModel:GetSellItemParam()
    local param = {}

    for i, v in pairs(self.sellItemsId) do
        local itemBase = self:GetItemByUid(v)
        local kv = { key = itemBase.uid, value = itemBase.num }
        table.insert(param, kv)
    end

    return param
end

--获取可以出售的物品
function BagModel:GetCanSellItems()
    self.sellItemsId = {}
    self.canSellItems = {}
    if self.bagItems ~= nil then

        for k, v in pairs(self.bagItems) do
            if v ~= 0 then
                local item = Config.db_item[v.id]
                if item ~= nil and item.color < 4 and item.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
                    table.insert(self.canSellItems, v)
                    table.insert(self.sellItemsId, v.uid)
                end
            end
        end
    end
    return #self.canSellItems
end

function BagModel:GetSellItemSelect(uid)
    local select = false
    for i, v in pairs(self.sellItemsId) do
        if v == uid then
            select = true
        end
    end

    return select

end

--设置出售项是否选中
function BagModel:SetSellItemSelect(uid, select)
    local hasUid = false
    for i, v in pairs(self.sellItemsId) do
        if v == uid then
            hasUid = true
            break
        end
    end

    if select then
        if not hasUid then
            table.insert(self.sellItemsId, uid)
            self:Brocast(BagEvent.SetSellMoney)
        end
    else
        if hasUid then
            table.removebyvalue(self.sellItemsId, uid)
            self:Brocast(BagEvent.SetSellMoney)
        end
    end
end

function BagModel:GetBagItems()
    return self.bagItems
end

function BagModel:GetCurrentBagItems()
    if self.filter_type == 0 then
        return self.bagItems
    end
    return self.bagTypeItems[self.filter_type] or {}
end

function BagModel:GetCurrentArtsItems(index)
    self.art_flilter_type = index
    if index == 1 then
        return self.artifactItems
    end
    return self.ArisBagTypeItems[self.art_flilter_type] or {}
end


function BagModel:UpdateGoodsById(id)
    -- local num = self:GetItemNumByItemID(id)
    GlobalEvent:Brocast(BagEvent.UpdateGoods, id)
end


--统一处理其他背包，仓库
function BagModel:SetOtherBags(data)
    local bag_id = data.bag_id
    local opened = data.opened
    local items = data.items
    self.bags[bag_id] = self.bags[bag_id] or {}
    self.bags[bag_id].opened = opened
    self.bags[bag_id].items = {}
    self.bags[bag_id].bagItems = items
    for i = 1, #items do
        local item = items[i]
        self.bags[bag_id].items[item.uid] = item
    end
end

function BagModel:AddToOtherBags(items)
    local update_beast_reddot = false
    for i = 1, #items do
        local item = items[i]
        local bag_id = item.bag
        if self.bags[bag_id] then
            self.bags[bag_id].items[item.uid] = item

            local hasNil = false
            local nilIndex = 0
            for ii, vv in pairs(self.bags[bag_id].bagItems) do
                if vv == 0 then
                    hasNil = true
                    nilIndex = ii
                    break
                end
            end

            if hasNil then
                self.bags[bag_id].bagItems[nilIndex] = item

                if bag_id == BagModel.beast then
                    BeastModel.GetInstance():AddEquipInBeastBag(nilIndex, item)
                    update_beast_reddot = true
                else
                    GlobalEvent:Brocast(BagEvent.AddItems, bag_id, nilIndex)
                end

            else
                table.insert(self.bags[bag_id].bagItems, item)

                if bag_id == BagModel.beast then
                    --异兽装备特殊处理
                    BeastModel.GetInstance():AddEquipInBeastBag(#self.bags[bag_id].bagItems, item)
                else
                    GlobalEvent:Brocast(BagEvent.AddItems, bag_id, #self.bags[bag_id].bagItems)
                end

            end


        elseif bag_id == BagModel.cardBag then
            CardModel:GetInstance():AddCardItem(items[i]);
        end
    end
    if update_beast_reddot then
        BeastModel.GetInstance():UpdateReddot()
    end
end

function BagModel:DelOtherItems(del)
    local update_beast_reddot = false
    for i = 1, #del do
        local uid = del[i]
        local bag_id = self:GetBagIdByUid(uid)
        if self.bags[bag_id] then
            local item = self.bags[bag_id].items[uid]
            self.bags[bag_id].items[uid] = nil
            local index = self:GetItemIndex(item)
            --table.remove(self.bags[bag_id].bagItems, index)
            self.bags[bag_id].bagItems[index] = 0

            local itemCfg = Config.db_item[item.id]
            if bag_id == BagModel.beast then
                BeastModel.GetInstance():DelEquipInBeastBag(item)
                BeastModel.GetInstance():DelItemDataInBeastBag(item)
                update_beast_reddot = true
            else
                GlobalEvent:Brocast(GoodsEvent.DelItems, bag_id, uid)
            end

        elseif bag_id == BagModel.cardBag then
            CardModel:GetInstance():DelectedCardItemByUid(uid);
        end
    end
    if update_beast_reddot then
        BeastModel.GetInstance():UpdateReddot()
    end
end

function BagModel:UpdateOtherItems(up)
    for uid, num in pairs(up) do
        local bag_id = self:GetBagIdByUid(uid)
        if self.bags[bag_id] then
            self.bags[bag_id].items[uid].num = num
            GlobalEvent:Brocast(GoodsEvent.UpdateNum, bag_id, uid, num)
        end
    end
end

function BagModel:GetItemIndex(item)
    local bag_id = item.bag
    if self.bags[bag_id] then
        for i = 1, #self.bags[bag_id].bagItems do
            if self.bags[bag_id].bagItems[i] ~= 0 and item.uid == self.bags[bag_id].bagItems[i].uid then
                return i
            end
        end
    end
end

function BagModel:GetBag(bagId)
    return self.bags[bagId]
end

--根据格子下标获取背包的数据
function BagModel:GetItemDataByIndex(index)
    if self.filter_type == 0 then
        return self.bagItems[index]
    else
        return self.bagTypeItems[self.filter_type][index]
    end
end

--根据格子下标获取仓库的数据
function BagModel:GetWareItemDataByIndex(index)
    return self.wareHouseItems[index]
end

--根据格子下标获取圣痕背包的数据
function BagModel:GetStigmataItemDataByIndex(index)
    return self.stigmataItems[index]
end

function BagModel:GetBabyItemDataByIndex(index)
    return self.babyItems[index]
end


function BagModel:GetGodItemDataByIndex(index)
    return self.godItems[index]
end

function BagModel:GetMechaItemDataByIndex(index)
    return self.mechaItems[index]
end

function BagModel:GetArtifactItemDataByIndex(index)
    if self.art_flilter_type == 0 then
        return self.artifactItems[index]
    else
        return self.ArisBagTypeItems[self.art_flilter_type][index]
    end
end

function BagModel:GetArtifactItemBySolt(artId)
    local tab = {}
    for i, v in pairs(self.artifactItems) do
        --if v.id ~= artId then
            local cfg = Config.db_equip[v.id]
            if not cfg  then
                local itemCfg = Config.db_item[v.id]
                if not string.isempty(itemCfg.effect) then
                    table.insert(tab,v)
                end

            else
                --local slot = Config.db_equip[artId].slot
                --local eSolt = cfg.solt
                --if eSolt == slot and cfg.color < 5 then
                --    table.insert(tab,v)
                --end
                local itemCfg = Config.db_item[v.id]
                if itemCfg.stype == artId and cfg.color < 5 then
                    table.insert(tab,v)
                end
            end
        --end
    end
    return tab
end




--获取身上该位置的装备
function BagModel:GetPutOn(equip_cfg_id)
    local equipCfg = Config.db_equip[equip_cfg_id]
    if equipCfg == nil then
        return nil
    else
        return EquipModel.Instance.putOnedEquipDetailList[equipCfg.slot]
    end

end

--获取配置表中装备分数
function BagModel:GetEquipScoreInCfg(item_id)
    return EquipModel.Instance:GetEquipScore(item_id)
end


--获取该物品在配置的信息
--p_item  服务器给的数据
function BagModel:GetConfig(item_id)
    return Config.db_equip[item_id]
end




--套装相关
--判断该装备是否可打造套装
--equipDetail  服务器发的p_item
--suitLv 套装等级
function BagModel:GetCanBuildSuit(equipDetail, suitLv)
    return EquipSuitModel.Instance:GetCanBuildSuit(equipDetail, suitLv)
end

--获取该装备激活的套装等级
-- equip_item 服务器发的p_item
function BagModel:GetShowSuitLvByEquip(equip_item)
    return EquipSuitModel.Instance:GetShowSuitLvByEquip(equip_item)
end

--获取激活套装的数量
--slot 部位
--order 阶位
--suitLv 套装等级
function BagModel:GetActiveSuitCount(slot, order, suitLv)
    return EquipSuitModel.Instance:GetActiveSuitCount(slot, order, suitLv)
end

--获取套装配置信息
--slot 部位
--order 阶位
--suitLv 套装等级
function BagModel:GetSuitConfig(slot, order, suitLv)
    return EquipSuitModel.Instance:GetSuitConfig(slot, order, suitLv)
end

--获取套装数量
--slot 部位
--order 阶位
--suitLv 套装等级
function BagModel:GetSuitCount(slot, order, suitLv)
    return EquipSuitModel.Instance:GetSuitCount(slot, order, suitLv)
end

--获取套装是否激活
-- slot 部位
--suitLv 套装等级
function BagModel:GetActiveByEquip(slot, suitLv)
    return EquipSuitModel.Instance:GetActiveByEquip(slot, suitLv)
end

--获取套装等级(类别)名字
-- suitLv 套装等级(类别)
function BagModel:GetSuitLvName(suitLv)
    return EquipSuitModel.Instance:GetSuitLvName(suitLv)
end

--获取可熔炼物品
function BagModel:UpdateCanSmeltEquips()
    local open_level = tonumber(String2Table(Config.db_game["smelt_lv"].val)[1])
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    local bagItems = self.bagItems
    local results = {}
    local have_strong_equip = false
    self.slot_scores = {}
    for k, v in pairs(bagItems) do
        if v ~= 0 then
            local item = Config.db_item[v.id]
            if item.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP and item.color >= enum.COLOR.COLOR_PURPLE
                    and item.color <= enum.COLOR.COLOR_RED and item.stype ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY
                    and item.stype ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY2
                    and item.stype ~= enum.ITEM_STYPE.ITEM_STYPE_RING1 and item.stype ~= enum.ITEM_STYPE.ITEM_STYPE_RING2 then
                local equip = Config.db_equip[v.id]
                --local slot = equip.slot
                --local score = v.score
                --local equip_score = self:GetEquipScore(slot)
                if item.color < enum.COLOR.COLOR_RED or (item.color == enum.COLOR.COLOR_RED and equip.star < 3) then
                    tableInsert(results, v)
                end
            elseif item.stype == enum.ITEM_STYPE.ITEM_STYPE_BAG_EXP then
                tableInsert(results, v)
            end
            --变强检测
            if item.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
                local equip = Config.db_equip[v.id]
                local slot = equip.slot
                local itemcfg = Config.db_item[v.id]
                if slot ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY and slot ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY2 then
                    local equip_score = self:GetEquipScore(slot)
                    if self:GetEquipCanPutOn(v.id) and not self:IsExpire(v.etime) and v.score > equip_score
                            and itemcfg.level <= level then
                        have_strong_equip = true
                    end
                    --记录评分最高装备
                    local old_score = (self.slot_scores[slot] and self.slot_scores[slot].score or 0)
                    if v.score > old_score and self:GetEquipCanPutOn(v.id) and not self:IsExpire(v.etime)
                      and itemcfg.level <= level then
                        self.slot_scores[slot] = v
                    end
                end
            end
        end
    end
    self.smelt_equips = results
    if level >= open_level then
        self:Brocast(BagEvent.SmeltRedDotEvent)
    end
    self:Brocast(BagEvent.UpdateHighScore)
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 45, have_strong_equip)
    return results
end

function BagModel:GetCanSmeltEquips()
    return self.smelt_equips
end

---显示物品pitem信息（不含操作）
function BagModel:ShowPItemTip(pItem, parent)
    local itemConfig = Config.db_item[pItem.id]

    if (itemConfig == nil) then
        return
    end

    local puton_item = self:GetPutOn(pItem.id)

    if itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or itemConfig == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST
            or itemConfig == enum.ITEM_TYPE.ITEM_TYPE_TOTEMS_EQUIP
    then
        if puton_item ~= nil then
            --_param
            ---self_item 在背包的装备item
            ---self_cfg 第1个参数的配置信息
            ---puton_item 上身穿戴的装备item
            ---puton_cfg 第3个参数的配置表信息
            ---operate_param 操作参数
            ---model 管理数据的model
            local _param = {}
            _param["self_item"] = pItem
            _param["self_cfg"] = self:GetConfig(pItem.id)
            _param["puton_item"] = puton_item
            _param["puton_cfg"] = self:GetConfig(puton_item.id)
            --_param["operate_param"] = param[2]
            _param["model"] = self
            lua_panelMgr:GetPanelOrCreate(EquipComparePanel):Open(_param)
        else
            ---_param包含参数
            ---cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
            ---p_item 服务器给的，服务器没给，只传cfg就好
            ---model 管理该tip数据的实例
            ---operate_param --操作参数
            local _param = {}
            _param["cfg"] = self:GetConfig(pItem.id)
            _param["p_item"] = pItem
            _param["model"] = self
            --_param["operate_param"] = param[2]

            self.equipDetailView = EquipTipView(parent)
            self.equipDetailView:ShowTip(_param)
        end
    elseif itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_MISC and itemConfig.stype == enum.ITEM_STYPE.ITEM_STYPE_PET_EGG then
        local pos = parent.position
        local _param = {}
        _param["cfg"] = itemConfig
        _param["p_item"] = pItem
        _param["basePos"] = pos

        local view = PetEggTipView()
        view:SetData(_param)
    elseif itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_MECHA then
       -- local pos = parent.position
        local _param = {}
        _param["cfg"] = itemConfig
        _param["p_item"] = pItem
      --  _param["basePos"] = pos

        local view = MachineArmorTipView(parent)
        view:ShowTip(_param)
    else
        local _param = {}
        _param["cfg"] = itemConfig
        --_param["operate_param"] = param[2]
        self.goodsDetailView = GoodsTipView(parent)
        self.goodsDetailView:ShowTip(_param)
    end
end

---显示物品TIP
function BagModel:ShowTip(itemId, parentNode)

    local itemConfig = Config.db_item[itemId]
    if (itemConfig == nil) then
        return
    end

    local puton_item = nil

    if itemConfig.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then

        puton_item = self:GetPutOn(itemId)

        if puton_item ~= nil then
            local _param = {}

            _param["puton_item"] = puton_item
            _param["puton_cfg"] = self:GetConfig(puton_item.id)
            _param["self_cfg"] = self:GetConfig(itemId)
            _param["model"] = self:GetInstance()
            local panel = lua_panelMgr:GetPanelOrCreate(EquipComparePanel)
            panel:Open(_param, parentNode);
        else
            local _param = {}

            _param["cfg"] = self:GetConfig(itemId)
            _param["model"] = self:GetInstance()

            local panel = EquipTipView(parentNode)
            panel:ShowTip(_param)
        end
    else
        local _param = {}

        _param["cfg"] = itemConfig

        local panel = GoodsTipView(parentNode)
        panel:ShowTip(_param)
    end
end

local value_2_color = {
    [0] = 6,
    [1] = 5,
    [2] = 4
}
local value_2_order = {
    [0] = 16,
    [1] = 15,
    [2] = 14,
    [3] = 13,
    [4] = 12,
    [5] = 11,
    [6] = 10,
    [7] = 9,
    [8] = 8,
    [9] = 7,
    [10] = 6,
    [11] = 5,
    [12] = 4,
    [13] = 16,
}

function BagModel:GetSmeltOrder()
    return value_2_order[CacheManager:GetInstance():GetInt("bag_smelt_order", 13)]
end

function BagModel:GetSmeltColor()
    return value_2_color[CacheManager:GetInstance():GetInt("bag_smelt_color", 2)]
end

function BagModel:GetSmeltStar()
    return CacheManager:GetInstance():GetInt("bag_smelt_star", 0)
end


--自动吞噬
function BagModel:AutoSmelt()
    if SettingModel:GetInstance():GetSmelt() == 1 then
        local left_bag_count = self.bagOpenCells - table.nums(self.bagItems)
        if left_bag_count < 5 then
            local cell_ids = {}
            local color = self:GetSmeltColor()
            local order = self:GetSmeltOrder()
            local star = self:GetSmeltStar()
            for i = 1, #self.smelt_equips do
                local pitembase = self.smelt_equips[i]
                local id = pitembase.id
                local uid = pitembase.uid
                local item = Config.db_item[id]
                if item.stype == enum.ITEM_STYPE.ITEM_STYPE_BAG_EXP then
                    cell_ids[self.smelt_equips[i].uid] = 1
                else
                    local equip = Config.db_equip[id]
                    if equip.order <= order and item.color <= color and equip.star <= star then
                        cell_ids[self.smelt_equips[i].uid] = 1
                    end
                end
            end
            if not table.isempty(cell_ids) then
                EquipController:GetInstance():RequestSmelt(cell_ids)
            end
        end
    end
end

--根据条件筛选可熔炼装备
function BagModel:FilterSmelt()
    local num = 0
    local color = self:GetSmeltColor()
    local order = self:GetSmeltOrder()
    local star = self:GetSmeltStar()
    for i = 1, #self.smelt_equips do
        local pitembase = self.smelt_equips[i]
        local id = pitembase.id
        local uid = pitembase.uid
        local item = Config.db_item[id]
        if item.stype == enum.ITEM_STYPE.ITEM_STYPE_BAG_EXP then
            num = num + 1
        else
            local equip = Config.db_equip[id]
            if equip.order <= order and item.color <= color and equip.star <= star then
                num = num + 1
            end
        end
    end
    return num
end

--是否提示
function BagModel:IsNotify(log)
    return log ~= 1101002 and log ~= 1101003
end
function BagModel:IsSomethingEnough(item_id, need_num)
    if (not item_id) or (not need_num) then
        return
    end
    local have_num = self:GetItemNumByItemID(item_id)
    local is_enough = true
    if need_num > have_num then
        is_enough = false
    end
    return is_enough
end


function BagModel:GetBagPos()
    return self.x, self.y
end

function BagModel:SetBagPos(btn_bag)
    local x, y = GetGlobalPosition(btn_bag)
    self.x = x*100
    self.y = y*100
end


