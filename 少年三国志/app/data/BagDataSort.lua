local BagDataSort = class("BagDataSort")
require("app.cfg.fragment_info")
require("app.cfg.treasure_info")
require("app.cfg.equipment_info")
require("app.cfg.item_info")
function BagDataSort:ctor(...)

end

--道具
function BagDataSort.sortPropList()
	local sortFunc = function(a,b)
        -- return a.id < b.id
        local item01 = item_info.get(a.id)
        local item02 = item_info.get(b.id)
        if item01.use_type ~= item02.use_type then
            --return item01.use_type < item02.use_type
            if item01.use_type == 1 then
                return true
            end
            if item02.use_type == 1 then
                return false
            end
        end
        if item01.quality ~= item02.quality then
            return item01.quality > item02.quality
        end
        return item01.id > item02.id
    end
    G_Me.bagData.propList:sortList(sortFunc)
end

--装备
function BagDataSort.sortEquipmentList()
	local sortFunc = function(a,b)
        --星级,潜能
        --判断是否已上阵
        local knightIdA = G_Me.formationData:getWearEquipmentKnightId(a.id)
        local knightIdB = G_Me.formationData:getWearEquipmentKnightId(b.id)

        local isALineupIn = knightIdA > 0 and 1 or 0
        local isBLineupIn = knightIdB > 0 and 1 or 0
        if isALineupIn ~= isBLineupIn then
            return isALineupIn > isBLineupIn
        end 

        local equipA = equipment_info.get(a.base_id)
        local equipB = equipment_info.get(b.base_id)
        if equipA.quality ~= equipB.quality then
            return equipA.quality > equipB.quality
        end
        if a.level ~= b.level then
            return a.level > b.level
        end 

        return equipA.id > equipB.id
    end
    G_Me.bagData.equipmentList:sortList(sortFunc)
end
--knight
function BagDataSort.sortKnightList()
--不在此做排序
end

--碎片
function BagDataSort.sortFragmentList()
	local sortFunc = function(a,b)
        local fragA = fragment_info.get(a.id)
        local fragB = fragment_info.get(b.id)
        
        local aBool = (a.num  >= fragA.max_num)
        local bBool = (b.num  >= fragB.max_num)
        --优先可合成
        if aBool ~= bBool then
            return aBool and true or false
        end
        --品质
        if fragA.quality ~= fragB.quality then
            return fragA.quality > fragB.quality
        end
        
        --数量
        if a.num ~= b.num then
            return a.num > b.num
        end
        return a.id > b.id
	end
	    
    G_Me.bagData.fragmentList:sortList(sortFunc)
end
--宝物
function BagDataSort.sortTreasureList()
	local sortFunc = function(a,b)
        if not a then 
            return false
        end
        if not b then
            return true
        end

        local knightIdA = G_Me.formationData:getWearTreasureKnightId(a.id or 0) or 0
        local knightIdB = G_Me.formationData:getWearTreasureKnightId(b.id or 0) or 0

        local isALineupIn = knightIdA > 0 and 1 or 0
        local isBLineupIn = knightIdB > 0 and 1 or 0
        if isALineupIn ~= isBLineupIn then
            return isALineupIn > isBLineupIn
        end 

        local treasureA = treasure_info.get(a.base_id)
        local treasureB = treasure_info.get(b.base_id)
        if not treasureA then 
            return false
        end
        if not treasureB then
            return true
        end
        if treasureA.quality ~= treasureB.quality then
            return treasureA.quality > treasureB.quality
        end
        if a.level ~= b.level then
            return a.level > b.level
        end
        return a.id > b.id
    end
    G_Me.bagData.treasureList:sortList(sortFunc)
end
--宝物碎片
function BagDataSort.sortTreasureFragmentList()
	--G_Me.bagData.treasureFragmentList:sortList(sortFunc)
end


return BagDataSort