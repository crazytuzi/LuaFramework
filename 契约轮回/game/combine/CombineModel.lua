--
-- Created by IntelliJ IDEA.
-- User: jielin
-- Date: 2018/9/26
-- Time: 15:20
-- To change this template use File | Settings | File Templates.
--

CombineModel = CombineModel or class("CombineModel", BaseBagModel)
local CombineModel = CombineModel

function CombineModel:ctor()
    CombineModel.Instance = self
    self:Reset()
end

function CombineModel:Reset()
    self.select_type_id = nil
    self.default_tog = nil
    self.default_first_id = nil
    self.default_sec_id = nil
    self.is_auto_judge_gender_tog = false

    --self.select_fst_menu_idx = nil
    self.select_fst_menu_id = nil
    self.select_sec_menu_id = nil
    self.cur_top_id = nil
    self.used_uids = {}  --记录已经添加的材料uid
    self.cur_Select_TypeSetId = nil
    self.cur_grid_index = 1

    self.curBagType = nil
    self.cur_Stars = nil
    self.cur_Colors = nil
    self.cur_Stairs = nil
    self.can_combine_list = {}
    self.help_color_text = nil

    self.cur_first_menu_list = {}
    self.scan_list = {}       --合成红点扫描阶位列表
    self.rd_list = {}         --红点列表
    self.top_star_list = {}
    self.stair_star_list = {}
    self:GetRedDotScanList()
    self:SortStairLockList()
    self:GetStairList()
    self.is_hide_combine_rd = false
    self.side_rd_list = {}      --标签栏红点
end

function CombineModel.GetInstance()
    if CombineModel.Instance == nil then
        CombineModel()
    end
    return CombineModel.Instance
end

function CombineModel:SortStairLockList()
    self.lock_list = {}
    local cf = Config.db_equip_combine_lock
    for i = 1, #cf do
        local config = cf[i]
        self.lock_list[config.sex] = self.lock_list[config.sex] or {}
        self.lock_list[config.sex][#self.lock_list[config.sex] + 1] = config
    end
end

function CombineModel:GetCurLockStair(top_id)
    local menu = top_id == 101 and 1 or 2
    local result = 4
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local list = self.lock_list[menu]
    for i = 1, #list do
        local cf = list[i]
        if cf.lv_low <= lv and cf.lv_up >= lv then
            result = cf.lock_subs
            break
        end
    end
    return result
end

function CombineModel:GetStairList()
    self.stair_list = {}
    for _, config in pairs(Config.db_equip_combine_sec_type) do
        local list = String2Table(config.thr_type)
        for i = 1, #list do
            self.stair_list[#self.stair_list + 1] = list[i]
        end
    end
end

function CombineModel:GetStairName(stair, top_id)
    if not stair then
        return
    end
    local cf = {}
    local list = {}
    if top_id then
        cf = Config.db_equip_combine_sec_type[top_id]
        if not cf then
            return
        end
        list = String2Table(cf.thr_type)
    else
        list = self.stair_list
    end
    local name = ""
    for i = 1, #list do
        local tbl = list[i]
        if tbl[1] == stair then
            name = tbl[2]
            break
        end
    end
    return name
end

function CombineModel:GetRedDotScanList()
    local list = Config.db_equip_combine_type_set
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    for stair, cf in pairs(list) do
        --0:不检测     1:按阶    2：逐个
        if cf.redpoint == 1 or cf.redpoint == 2 then
            self.scan_list[stair] = cf
        end
    end

    local cf = Config.db_equip_combine_type
    for i = 1, #cf do
        local type_config = cf[i]
        if not type_config then
            return
        end
        local type_cf = String2Table(type_config.sec_type)
        for _, sec_tbl in pairs(type_cf) do
            local top_id = sec_tbl[1]
            local stair_config = Config.db_equip_combine_sec_type[top_id]
            if stair_config then
                local stair_cf = String2Table(stair_config.thr_type)
                for _, thr_tbl in pairs(stair_cf) do
                    local stair_id = thr_tbl[1]
                    local star_config = Config.db_equip_combine_thr_type[stair_id]
                    if star_config then
                        local star_list = String2Table(star_config.four_type)
                        for _, star_tbl in pairs(star_list) do
                            local star_id = star_tbl[1]
                            self.top_star_list[top_id] = self.top_star_list[top_id] or {}
                            self.top_star_list[top_id][#self.top_star_list[top_id] + 1] = star_id

                            self.stair_star_list[stair_id] = self.stair_star_list[stair_id] or {}
                            self.stair_star_list[stair_id][#self.stair_star_list[stair_id] + 1] = star_id
                        end
                    end
                end
            end
        end
    end
end

function CombineModel:GetRDScanCfByStairId(star)
    return self.scan_list[star]
end

function CombineModel:AddUsedUid(uid, num)
    self.used_uids[uid] = num
end

--清除已添加的材料
function CombineModel:CleanUsedUids()
    self.used_uids = {}
end

--删除指定的uid
function CombineModel:RemoveSpecifiedUid(uid)
    for i, v in pairs(self.used_uids) do
        if i == uid then
            self.used_uids[i] = nil
            break
        end
    end
end

--是否已使用
function CombineModel:IsUidUsed(uid)
    return self.used_uids[uid]
end

--获取已添加材料数量
function CombineModel:GetUsedNum()
    return table.nums(self.used_uids)
end

function CombineModel:GetUsedUids()
    return self.used_uids
end

function CombineModel:GetFirstTypeName()
    local name = "Orange Gear"
    return name
end

function CombineModel:GetThirdTypeNameById(secTypeId, thirdTypeId)
    local name = ""
    local secCfg = Config.db_equip_combine_sec_type[secTypeId]
    secCfg = secCfg or {}
    local thirdTbl = String2Table(secCfg.thr_type)
    thirdTbl = thirdTbl or {}
    for i, v in pairs(thirdTbl) do
        if v[1] == thirdTypeId then
            name = v[2]
            break
        end
    end
    return name
end

function CombineModel:GetFourTypeNameById(thirdTypeId, fourTypeId)
    local name = ""
    local thirdCfg = Config.db_equip_combine_thr_type[thirdTypeId]
    thirdCfg = thirdCfg or {}
    local fourTbl = String2Table(thirdCfg.four_type)
    fourTbl = fourTbl or {}
    for i, v in pairs(fourTbl) do
        if v[1] == fourTypeId then
            name = v[2]
            break
        end
    end
    return name
end

function CombineModel:GetStairsName(itemId)
    local targetTbl = String2Table(Config.db_equip_combine_type_set[itemId].item_ids)
    local targetId = targetTbl[1]
    local targetCostTbl = String2Table(Config.db_equip_combine[targetId].other_cost)
    local needItemId = targetCostTbl[1]
    local order = Config.db_equip[needItemId].order
    local name = CombineStair_List[order]
    return name
end

function CombineModel:GetColorsName(itemId)
    local targetTbl = String2Table(Config.db_equip_combine_type_set[itemId].item_ids)
    local targetId = targetTbl[1]
    local targetCostTbl = String2Table(Config.db_equip_combine[targetId].other_cost)
    local needItemId = targetCostTbl[1]
    local order = Config.db_item[needItemId].color
    local name = CombineColor_List[order]
    return name
end

function CombineModel:GetStarsName(itemId)
    local targetTbl = String2Table(Config.db_equip_combine_type_set[itemId].item_ids)
    local targetId = targetTbl[1]
    local targetCostTbl = String2Table(Config.db_equip_combine[targetId].other_cost)
    local needItemId = targetCostTbl[1]
    local order = Config.db_equip[needItemId].star
    local name = CombineStars_List[order]
    return name
end

function CombineModel:CheckTypeNameColor(typeName)
    if typeName == nil then
        return
    end
    local color = nil
    if typeName == CombineColor_List[3] then
        color = ColorUtil.GetColor(ColorUtil.ColorType.Blue)
    elseif typeName == CombineColor_List[4] then
        color = ColorUtil.GetColor(ColorUtil.ColorType.Purple)
    elseif typeName == CombineColor_List[5] then
        color = ColorUtil.GetColor(ColorUtil.ColorType.Orange)
    elseif typeName == CombineColor_List[6] then
        color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
    elseif typeName == CombineColor_List[7] then
        color = ColorUtil.GetColor(ColorUtil.ColorType.Pink)
    end
    return color
end

function CombineModel:GetConfig(itemId)
    return Config.db_equip[itemId]
end

function CombineModel:GetRankedBagItem()
    local function sortFun(a, b)
        return a.score < b.score
    end
    table.sort(self.can_combine_list, sortFun)
    local tbl = {}
    local count = 20
    if #self.can_combine_list < count then
        count = #self.can_combine_list
    end
    for i = 1, count do
        tbl[#tbl + 1] = self.can_combine_list[i]
    end
    return tbl
end

function CombineModel:GetItemNumByTbl(tbl, need_puton)
    local rusult_List = {}
    for i = 1, #tbl do
        local itemid = tbl[i][1]
        local num = BagModel.Instance:GetItemNumByItemID(itemid)
        if not num then
            num = 0
        end
        if need_puton then
            local itemcfg = Config.db_item[itemid]
            local putonitem = EquipModel.GetInstance():GetEquipBySlot(itemcfg.stype)
            if putonitem and putonitem.id == itemid then
                num = num + 1
            end
        end
        rusult_List[#rusult_List + 1] = num
    end
    return rusult_List
end

--获取在当前一级菜单的idx
function CombineModel:GetFstMenuIdxByMenuId(id)
    local result = 1
    for idx, tbl in pairs(self.cur_first_menu_list) do
        if tbl[1] == id then
            result = idx
            break
        end
    end
    return result
end

function CombineModel:GetCurFstMenuFstId()
    return self.cur_first_menu_list[1][1]
end

function CombineModel:CheckScanListRD()
    self.rd_list = {}
    self.side_rd_list = { false, false, false }
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    for stair_idx, stair_cf in pairs(self.scan_list) do
        if lv >= stair_cf.open_level then
            --遍历物品
            local list = String2Table(stair_cf.item_ids)
            for idx = 1, #list do
                local id = list[idx]
                local is_ring_etc = self:NeedPutOnItem(id)
                local cur_unsettled_num = 0
                local cb_cf = Config.db_equip_combine[id]
                if cb_cf then
                    local unsettle_num = cb_cf.min_num
                    local is_unsettled_enough = false
                    if unsettle_num == 0 then
                        is_unsettled_enough = true
                    else
                        cur_unsettled_num = self:GetMaterialNum(cb_cf, 2)
                        if is_ring_etc then
                            local itemcfg = Config.db_item[id]
                            local putonitem = EquipModel.GetInstance():GetEquipBySlot(itemcfg.stype)
                            if putonitem and putonitem.id == id then
                                cur_unsettled_num = cur_unsettled_num + 1
                            end
                        end
                        if cur_unsettled_num >= unsettle_num then
                            is_unsettled_enough = true
                        end
                    end
                    local settled_tbl = String2Table(cb_cf.cost)
                    local is_settled_enough = true
                    --有固定材料
                    if #settled_tbl ~= 0 then
                        for s_idx = 1, #settled_tbl do
                            local need_num = settled_tbl[s_idx][2]
                            local mat_id = settled_tbl[s_idx][1]
                            local have_num = self:GetMaterialNum(cb_cf, nil, nil, mat_id)
                            if is_ring_etc then
                                local itemcfg = Config.db_item[settled_tbl[s_idx][1]]
                                local putonitem = EquipModel.GetInstance():GetEquipBySlot(itemcfg.stype)
                                if putonitem and putonitem.id == mat_id then
                                    have_num = have_num + 1
                                end
                            end
                            --拥有的某个固定材料数量不够
                            if need_num > have_num then
                                is_settled_enough = false
                                break
                            end
                        end
                    end
                    --物品可以合成
                    local str = tostring(stair_idx)
                    local first_str = string.match(str, "%d")
                    if is_settled_enough and is_unsettled_enough then
                        self.rd_list[stair_idx] = self.rd_list[stair_idx] or {}
                        self.rd_list[stair_idx][id] = true
                        self.side_rd_list[tonumber(first_str)] = true
                    end
                else
                end
            end
        end
    end
end

function CombineModel:IsShowTopRdById(id)
    local is_show = false
    local star_list = self.top_star_list[id]
    if star_list and (not table.isempty(star_list)) then
        for i = 1, #star_list do
            local star_id = star_list[i]
            if self.rd_list[star_id] then
                is_show = true
                break
            end
        end
    end
    return is_show
end

function CombineModel:IsShowStairRdById(id)
    local is_show = false
    local stair_list = self.stair_star_list[id]
    if stair_list and (not table.isempty(stair_list)) then
        for i = 1, #stair_list do
            local star_id = stair_list[i]
            if self.rd_list[star_id] then
                is_show = true
                break
            end
        end
    end
    return is_show
end

function CombineModel:GetStarRDList(id, item_id)
    if item_id then
        if self.rd_list[id] then
            return self.rd_list[id][item_id]
        end
        return false
    end
    return self.rd_list[id]
end

--type__________1:固定材料  2:不固定材料
function CombineModel:GetMaterialNum(cfg, tar_type, bag_type, item_id)
    local materialNum = 0
    local tar_type = tar_type or 1
    local tbl = tar_type == 1 and cfg.cost or cfg.other_cost
    local cost_tbl = String2Table(tbl)
    local id
    if not bag_type then
        if tar_type == 1 and item_id then
            id = item_id
        else
            local gain = cfg.gain
            id = String2Table(gain)[1][1]
        end
        local item_cf = Config.db_item[id]
        if not item_cf then
            return 0
        end
        bag_type = item_cf.bag
    end
    bag_type = bag_type or self.curBagType

    if item_id then
        if bag_type == BagModel.bagId then
            materialNum = materialNum + BagModel.Instance:GetItemNumByItemID(item_id)
        else
            materialNum = self:GetItemNumByBagIDItemID(bag_type,item_id)
            if materialNum == 0 then
                materialNum = materialNum + BagModel.Instance:GetItemNumByItemID(item_id)
            end
        end
    else
        for i, v in pairs(cost_tbl) do
            local value = type(v) == "number" and v or v[1]
            if bag_type == BagModel.bagId then
                materialNum = materialNum + BagModel.Instance:GetItemNumByItemID(value)
            else
                materialNum = materialNum + self:GetItemNumByBagIDItemID(bag_type,value)
            end
        end
    end
    -- if bag_type == 101 then
    --     --物品背包
    --     if item_id then
    --         materialNum = BagModel.GetInstance():GetItemNumByItemID(item_id)
    --     else
    --         for i, v in pairs(cost_tbl) do
    --             local value = type(v) == "number" and v or v[1]
    --             materialNum = materialNum + BagModel.GetInstance():GetItemNumByItemID(value)
    --         end
    --     end
    -- elseif bag_type == 104 then
    --     if item_id then
    --         materialNum = BeastModel.GetInstance():GetItemNumByItemID(item_id)
    --     else
    --         for i, v in pairs(cost_tbl) do
    --             local value = type(v) == "number" and v or v[1]
    --             materialNum = materialNum + BeastModel.GetInstance():GetItemNumByItemID(value)
    --         end
    --     end
    -- elseif bag_type == 106 then
    --     if item_id then
    --         materialNum = BabyModel.GetInstance():GetEquipNum(item_id)
    --         if materialNum == 0 then
    --             materialNum = materialNum + BagModel.Instance:GetItemNumByItemID(item_id)
    --         end
    --     else
    --         for i, v in pairs(cost_tbl) do
    --             local value = type(v) == "number" and v or v[1]
    --             materialNum = materialNum + BabyModel.GetInstance():GetEquipNum(value)
    --             if materialNum == 0 then
    --                 materialNum = materialNum + BagModel.Instance:GetItemNumByItemID(value)
    --             end
    --         end
    --     end
    -- elseif bag_type == 108 then
    --     if item_id then
    --         materialNum = GodModel.GetInstance():GetEquipNum(item_id)
    --         if materialNum == 0 then
    --             materialNum = materialNum + BagModel.Instance:GetItemNumByItemID(item_id)
    --         end
    --     else
    --         for i, v in pairs(cost_tbl) do
    --             local value = type(v) == "number" and v or v[1]
    --             materialNum = materialNum + GodModel.GetInstance():GetEquipNum(value)
    --             --0个数量的话，是碎片
    --             if materialNum == 0 then
    --                 materialNum = materialNum + BagModel.Instance:GetItemNumByItemID(value)
    --             end
    --         end
    --     end
    -- elseif bag_type == 109 then
    --     if item_id then
    --         materialNum = MachineArmorModel.GetInstance():GetEquipNum(item_id)
    --         if materialNum == 0 then
    --             materialNum = materialNum + BagModel.Instance:GetItemNumByItemID(item_id)
    --         end
    --     else
    --         for i, v in pairs(cost_tbl) do
    --             local value = type(v) == "number" and v or v[1]
    --             materialNum = materialNum + MachineArmorModel.GetInstance():GetEquipNum(value)
    --             --0个数量的话，是碎片
    --             if materialNum == 0 then
    --                 materialNum = materialNum + BagModel.Instance:GetItemNumByItemID(value)
    --             end
    --         end
    --     end
    -- end
    return materialNum
end

function CombineModel:NeedPutOnItem(id)
    local combinebase = Config.db_equip_combine[id]
    local gain = String2Table(combinebase.gain)[1]
    local r_item_id = gain[1]
    local itemcfg = Config.db_item[r_item_id]
    local need_puton = false
    if itemcfg.stype == enum.ITEM_STYPE.ITEM_STYPE_RING1 or itemcfg.stype == enum.ITEM_STYPE.ITEM_STYPE_RING2 then
        need_puton = true
    end
    return need_puton
end

function CombineModel:CheckAddItems(bagid,items)
    local bag = BagModel:GetInstance():GetBag(bagid)
    if not bag then
        return {}
    end
    local item_uids = {}
    local bagItems = bag.items
    for _, itemId in pairs(items) do
        for _, v in pairs(bagItems) do
            if itemId == v.id then
                -- if not self:IsUidUsed(v.uid) and #item_uids < 20 then
                if not self:IsUidUsed(v.uid) and #item_uids < 20 then
					if bagid == BagModel.PetEquip then
						if v.misc.stren_lv == 0 then
							item_uids[#item_uids + 1] = v
						end
					else	
                    	item_uids[#item_uids + 1] = v
					end
                end
            end
        end
    end
    return item_uids
end

function CombineModel:GetItemNumByBagIDItemID(bagid,item_id)
    local bagTab = {
        [BagModel.baby] = "babyItems",
        [BagModel.God] = "godItems",
        [BagModel.mecha] = "mechaItems",
        [BagModel.artifact] = "artifactItems",
    }
    if bagTab[bagid] then
        local equips = BagModel.GetInstance()[bagTab[bagid]]
        local num = 0
        for i, v in pairs(equips) do
            if item_id == v.id then
                num = num + v.num
            end
        end
        return num
    end
    local bag = BagModel.GetInstance():GetBag(bagid)
    if not bag then
        -- if AppConfig.Debug then
        --     logError("bag is nil , the bag id is ",bagid)
        -- end
        return 0
    end
    local num = 0
    for i, v in pairs(bag.items) do
        if v ~= 0 and v.id == item_id then
            if bagid == BagModel.PetEquip then
                if v.misc.stren_lv == 0 then
                    num = num + v.num
                end
            else
                num = num + v.num
            end
        end
    end
    return num
end