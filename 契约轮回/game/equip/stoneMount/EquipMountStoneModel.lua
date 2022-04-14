--
-- @Author: chk
-- @Date:   2018-09-25 19:39:36
--

EquipMountStoneModel = EquipMountStoneModel or class("EquipMountStoneModel", BaseBagModel)
local EquipMountStoneModel = EquipMountStoneModel

function EquipMountStoneModel:ctor()
    EquipMountStoneModel.Instance = self

    self.operateItemId = nil
    self.operateSlot = nil  --当前操作的装备的装备位
    self.operateHole = nil  --当前操作的装备的孔位
    self.minStrongEquip = nil
    self.slotMapPhaselv = {}
    --self.last_select_item = nil
    self.last_select_gem_item = nil  --最后选择的宝石栏装备项
    self.last_select_spar_item = nil  --最后选择的晶石栏装备项
    self.stoneUpViewContain = nil


    self.states = {}
	self.states.gem = 1  --宝石
	self.states.spar = 2  --晶石

	self.cur_state = self.states.gem --当前状态

    self:Reset()
end

function EquipMountStoneModel:Reset()

end

function EquipMountStoneModel.GetInstance()
    if EquipMountStoneModel.Instance == nil then
        EquipMountStoneModel()
    end
    return EquipMountStoneModel.Instance
end

--判断是否最高宝石等级
function EquipMountStoneModel:JudgeIsMaxLv(stoneId,state)
    self:CheckStateParam(state)
    local isMax = false
    local cfg = Config.db_stone[stoneId]
    if state == self.states.spar then
        cfg = Config.db_spar[stoneId]
    end
    if cfg ~= nil and cfg.next_level_id == 0 then
        isMax = true
    end

    return isMax
end

--指定装备位上是否镶嵌了指定ID和孔位的石头
function EquipMountStoneModel:GetStoneIsMount(slot, stoneId, hole,state)
    self:CheckStateParam(state)
    local isMount = false
    local equipDetail = EquipModel.Instance.putOnedEquipDetailList[slot]
    if equipDetail ~= nil then
        local stones = equipDetail.equip.stones
        for i, v in pairs(stones) do
            if stoneId == v and hole == i then
                isMount = true
                break
            end
        end
    end

    return isMount
end

--获取石头属性数据
function EquipMountStoneModel:GetAttStrongValue(att, strongCfg)
    local vlu = 0
    for i, v in pairs(String2Table(strongCfg.attrib)) do
        if att == v[1] then
            vlu = v[2]
            break
        end
    end

    return vlu
end

--获取指定装备开放孔位数量
function EquipMountStoneModel:GetOpenHoleCount(equipId,state)
    self:CheckStateParam(state)
    local openCount = 0
    local roleData = RoleInfoModel.Instance:GetMainRoleData()
    local equipCfg = Config.db_equip[equipId]
    for i = 1, 6 do
        local cfg = Config.db_stones_hole[i]
        if state == self.states.spar then
            local value = i + 100
            cfg = Config.db_spar_unlock[value]
        end

        local cndtionTbl = String2Table(cfg.open_condition)
        for i, v in pairs(cndtionTbl) do
            if v[1] == "order" and equipCfg.order >= v[2] then
                openCount = openCount + 1
            elseif v[1] == "vip" and roleData.viplv >= v[2] then
                openCount = openCount + 1
            end
        end
    end

    return openCount
end

--计算需要的石头
function EquipMountStoneModel:calc_need_stones(itemid, need_num, had,state)
    self:CheckStateParam(state)
    local hadnum = BagModel.Instance:GetItemNumByItemID(itemid)
    if hadnum >= need_num then
        had[itemid] = need_num
        return true, had
    else
        local stonecfg = Config.db_stone[itemid]
        if state == self.states.spar then
            stonecfg = Config.db_spar[itemid]
        end
        had[itemid] = hadnum
        if stonecfg.pre_level_id > 0 then
            local stonecfg2 = Config.db_stone[stonecfg.pre_level_id]
            if state == self.states.spar then
                stonecfg2 = Config.db_spar[stonecfg.pre_level_id]
            end

            return self:calc_need_stones(stonecfg.pre_level_id, (need_num-hadnum)*stonecfg2.need_num, had,state)
        else
            return false, had
        end
    end
end

--获取宝石升级的状态
--  -1 表示材料不够
--  0  表示最高级，不用升级
--  1  够材料，能升级
function EquipMountStoneModel:GetUpLvType(itemId,state)
    self:CheckStateParam(state)
    local type = 0
    local stoneCfg = Config.db_stone[itemId]
    if state == self.states.spar then
        stoneCfg = Config.db_spar[itemId]
    end

    if stoneCfg.next_level_id > 0 then
        --local num = BagModel.Instance:GetItemNumByItemID(itemId)+1
        if self:calc_need_stones(itemId, stoneCfg.need_num-1, {},state) then
            type = 1
        else
            type = -1
        end
    end

    return type
end

--获取宝石id，根据部位和孔位
function EquipMountStoneModel:GetOnStoneIdBySlotHole(slot, hole)
    local stoneId = nil
    local equipDetail = EquipModel.Instance.putOnedEquipDetailList[slot]
    for i, v in pairs(equipDetail.equip.stones) do
        if i == hole then
            stoneId = v
            break
        end
    end

    return stoneId
end

--获取可以装备到指定装备位的石头的Id
function EquipMountStoneModel:GetStoneIdBySlot(slot,state)
    self:CheckStateParam(state)
    local stoneId = nil
    local cfg = Config.db_stone
    if state == self.states.spar then
        cfg = Config.db_spar
    end
    for i, v in pairs(cfg) do
        local slotsTbl = String2Table(v.slots)
        for ii, vv in pairs(slotsTbl) do
            if vv == slot then
                stoneId = v.id
                break
            end
        end

        if stoneId ~= nil then
            return stoneId
        end
    end
end

--获取下一级石头等级
function EquipMountStoneModel:GetNextStoneLevel(stoneId,state)
    self:CheckStateParam(state)
    local nextStoneLv = 0
    local stoneCfg = Config.db_stone[stoneId]
    if state == self.states.spar then
        stoneCfg = Config.db_spar[stoneId]
    end
    local nextStoneCfg = Config.db_stone[stoneCfg.next_level_id]
    if state == self.states.spar then
        nextStoneCfg = Config.db_spar[stoneCfg.next_level_id]
    end


    if nextStoneCfg ~= nil then
        nextStoneLv = nextStoneCfg.level
    end

    return nextStoneLv
end

--获取下一级石头id
function EquipMountStoneModel:GetNextUpStoneId(stoneId,state)
    self:CheckStateParam(state)
    local nextStoneId = 0
    local stoneCfg = Config.db_stone[stoneId]
    if state == self.states.spar then
        stoneCfg = Config.db_spar[stoneId]
    end
    local nextStoneCfg = Config.db_stone[stoneCfg.next_level_id]
    if state == self.states.spar then
        nextStoneCfg = Config.db_spar[stoneCfg.next_level_id]
    end
    if nextStoneCfg ~= nil then
        nextStoneId = nextStoneCfg.id
    end

    return nextStoneId
end

function EquipMountStoneModel:GetLessInfo(stoneId,state)
    self:CheckStateParam(state)
    local hasNum = BagModel.Instance:GetItemNumByItemID(stoneId)
    local stoneCfg = Config.db_stone[stoneId]
    if state == self.states.spar then
        stoneCfg = Config.db_spar[stoneId]
    end

    local itemCfg = Config.db_item[stoneId]

    local lessCount = stoneCfg.need_num - hasNum - 1
    return itemCfg.name .. "*" .. lessCount

end

--获取下一级石头消耗
function EquipMountStoneModel:GetNextStoneUpCost(stoneId,state)
    self:CheckStateParam(state)
    local hasNum = BagModel.Instance:GetItemNumByItemID(stoneId)
    local stoneCfg = Config.db_stone[stoneId]
    if state == self.states.spar then
        stoneCfg = Config.db_spar[stoneId]
    end
    local voucherCfg = Config.db_voucher[stoneId]
    local cost = (stoneCfg.need_num - hasNum - 1) * voucherCfg.price
    return cost
end

--获取石头属性
function EquipMountStoneModel:GetStoneAttrInfo2(stoneId,state)
    self:CheckStateParam(state)
    local cfg = Config.db_stone[stoneId]
    
    if state == self.states.spar then
        cfg = Config.db_spar[stoneId]
    end
    local info = ""
    local attibTbl = String2Table(cfg.attrib)
    local num = table.nums(attibTbl)
    local crntNum = 0
    for i, v in pairs(attibTbl) do
        crntNum = crntNum + 1

        info = info .. enumName.ATTR[v[1]] .. ": +" .. v[2]

        if crntNum < num then
            info = info .. "\n"
        end
    end

    return info
end

--获取石头属性
function EquipMountStoneModel:GetStoneAttrInfo(stoneId,state)
    self:CheckStateParam(state)
    local cfg = Config.db_stone[stoneId]
    if state == self.states.spar then
        cfg = Config.db_spar[stoneId]
    end
    local info = ""
    local attibTbl = String2Table(cfg.attrib)
    local num = table.nums(attibTbl)
    local crntNum = 0
    for i, v in pairs(attibTbl) do
        crntNum = crntNum + 1

        info = info .. string.format("<color=#%s>", "A25D2B") ..
                enumName.ATTR[v[1]] .. ": +" .. v[2] .. "</color>"

        if crntNum < num then
            info = info .. "\n"
        end
    end

    return info
end

--获取提示上显示的石头属性
function EquipMountStoneModel:GetStoneAttrInfoInTip(stoneId,state)
    self:CheckStateParam(state)
    local cfg = Config.db_stone[stoneId]
    if state == self.states.spar then
        cfg = Config.db_spar[stoneId]
    end
    local info = ""
    local attibTbl = String2Table(cfg.attrib)
    local num = table.nums(attibTbl)
    local crntNum = 0
    for i, v in pairs(attibTbl) do
        crntNum = crntNum + 1

        info = info .. enumName.ATTR[v[1]] .. ": +" .. v[2]

        if crntNum < num then
            info = info .. "\n"
        end
    end

    return info
end

--获取指定孔位是否显示红点
function EquipMountStoneModel:GetNeedShowRedDotByHole(equipDetail, hole,state)
    self:CheckStateParam(state)

    
    --未开启晶石系统时检查晶石红点 直接返回false
    if state == self.states.spar and not OpenTipModel.GetInstance():IsOpenSystem(120,6) then
        return false
    end

    local showRedHot = false
    local equipCfg = Config.db_equip[equipDetail.id]

    --根据state决定获取宝石还是晶石
    local type = enum.ITEM_TYPE.ITEM_TYPE_STONE
    if state == self.states.spar then
        type = enum.ITEM_TYPE.ITEM_TYPE_STONE2
    end

    local stones = self:GetStoneBySlot(equipCfg.slot,state) or {} --根据要镶嵌的部位获取石头
    
    local equip_stones = equipDetail.equip.stones


    if equip_stones[hole] == nil then
        --身上没有镶嵌该孔位的石头
        local cfg = Config.db_stones_hole[hole]

        if state == self.states.spar then
            cfg = Config.db_spar_unlock[hole]
        end

        local cndtionTbl = String2Table(cfg.open_condition)
        for i, v in pairs(cndtionTbl) do
            if v[1] == "order" then
                if equipCfg.order < v[2] then
                    --达不到阶位
                    return false
                else
                    if table.isempty(stones) then
                        return false
                    else
                        return true
                    end
                end
            elseif v[1] == "vip" then
                if RoleInfoModel.GetInstance():GetMainRoleVipLevel() < v[2] then
                    --达不到vip等级
                    return false
                else
                    if table.isempty(stones) then
                        return false
                    else
                        return true
                    end
                end
            end
        end
    else
        local isMaxLv = self:JudgeIsMaxLv(equip_stones[hole],state)
        if table.isempty(stones) or isMaxLv then
            return false
        else
            for i, v in pairs(stones) do
                local upType = self:GetUpLvType(v.id,state)
                if upType == 0 then
                    --最高级，直接删除
                    return false
                else
                    local bag_stone_cfg = Config.db_stone[v.id]
                    if state == self.states.spar then
                        bag_stone_cfg = Config.db_spar[v.id]
                    end

                    local stone_cfg = Config.db_stone[equip_stones[hole]]
                    if state == self.states.spar then
                        stone_cfg = Config.db_spar[equip_stones[hole]]
                    end

                    if bag_stone_cfg ~= nil and stone_cfg ~= nil then
                        if tonumber(bag_stone_cfg.level) > tonumber(stone_cfg.level) then
                            --背包中有比已经镶嵌的等级大
                            showRedHot = true
                            break
                        else
                            showRedHot = false
                        end
                    end
                end
            end
        end
    end

    return showRedHot
end

--获取指定装备是否需要显示红点
function EquipMountStoneModel:GetNeedShowRedDotByEquip(pitem,state)
    self:CheckStateParam(state)

    --未开启晶石系统时检查晶石红点 直接返回false
    if state == self.states.spar and not OpenTipModel.GetInstance():IsOpenSystem(120,6) then
        return false
    end

    local cfg = Config.db_stones_hole
    if state == self.states.spar then
        cfg = Config.db_spar_unlock
    end

    for hole, _ in pairs(cfg) do
        if self:GetNeedShowRedDotByHole(pitem, hole,state) then
            return true
        end
    end
    return false
end

--检查所有装备，获取是否需要显示红点
function EquipMountStoneModel:GetNeedShowRedDot()
    local putOnedEquips = EquipModel.Instance:GetCanMountStoneEquips()
    for _, pitem in pairs(putOnedEquips) do
        if self:GetNeedShowRedDotByEquip(pitem,self.states.gem) or self:GetNeedShowRedDotByEquip(pitem,self.states.spar) then
            return true
        end
    end
    return false
end

--检查所有装备，获取是否需要显示宝石/晶石红点
function EquipMountStoneModel:GetNeedShowRedDotByState(state)

    --未开启晶石系统时检查晶石红点 直接返回false
    if state == self.states.spar and not OpenTipModel.GetInstance():IsOpenSystem(120,6) then
        return false
    end

    local putOnedEquips = EquipModel.Instance:GetCanMountStoneEquips()
    for _, pitem in pairs(putOnedEquips) do
        if self:GetNeedShowRedDotByEquip(pitem,state) then
            return true
        end
    end
    return false
end

--石头列表里是否包含指定石头
function EquipMountStoneModel:HasContainStone(stones, stone)
    local has = false
    for i, v in pairs(stones) do
        if v.id == stone.id then
            has = true
            break
        end
    end

    return has
end

--石头列表里是否包含指定id的石头
function EquipMountStoneModel:HasContainStoneById(stones, stoneId)
    local has = false
    for i, v in pairs(stones) do
        if v.id == stoneId then
            has = true
            break
        end
    end

    return has
end

--根据要镶嵌的部位获取石头
function EquipMountStoneModel:GetStoneBySlot(slot,state)
    self:CheckStateParam(state)
    local stones = {}
    local items = BagModel.Instance:GetItemsByType(enum.ITEM_TYPE.ITEM_TYPE_STONE)
    if state == self.states.spar then
        items = BagModel.Instance:GetItemsByType(enum.ITEM_TYPE.ITEM_TYPE_STONE2)
    end
    for i, v in pairs(items) do
        local cfg = Config.db_stone[v.id]
        if state == self.states.spar then
            cfg = Config.db_spar[v.id]
        end
        if cfg ~= nil then
            local slotsTbl = String2Table(cfg.slots)
            for ii, vv in pairs(slotsTbl) do
                if vv == slot and not self:HasContainStone(stones, v) then
                    table.insert(stones, v)
                    break
                end
            end
        end
    end

    return stones
end

--排序操作的宝石
--mountingItemId  镶嵌中的宝石id
function EquipMountStoneModel:SortOperationStones(mountingItemId, slot,state)
    self:CheckStateParam(state)
    local stones = self:GetStoneBySlot(slot,state)
    if table.isempty(stones) then
        return
    end

    local function call_back(stone1, stone2)
        local stone1W = 0
        local stone2W = 0

        local stone1Cfg = Config.db_stone[stone1.id]
        local stone2Cfg = Config.db_stone[stone2.id]
        if  state == self.states.spar then
            stone1Cfg = Config.db_spar[stone1.id]
            stone2Cfg = Config.db_spar[stone2.id]
        end


        if stone1Cfg ~= nil then
            if stone1Cfg.id == mountingItemId then
                stone1W = 1000
            else
                stone1W = stone1Cfg.level
            end
        end

        if stone2Cfg ~= nil then
            if stone2Cfg.id == mountingItemId then
                stone2W = 1000
            else
                stone2W = stone2Cfg.level
            end
        end

        return stone1W > stone2W
    end

    table.sort(stones, call_back)

    return stones
end

--获取只有宝石或晶石的stones表
function EquipMountStoneModel:GetStones(stones,state)
    self:CheckStateParam(state)

    local return_stones = {}

    if state == self.states.gem then
        for k,v in pairs(stones) do
            if k <= 6 then
                return_stones[k] = v
            end
            
        end
    else
        for k,v in pairs(stones) do
            if k >= 101 then
                return_stones[k] = v
            end
        end
    end

    return return_stones
end

function EquipMountStoneModel:CheckStateParam(state)
    if state == nil then
        logError("mount stone state nil")
    end
end