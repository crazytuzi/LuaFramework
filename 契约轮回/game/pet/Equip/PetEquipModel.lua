PetEquipModel = PetEquipModel or class('PetEquipModel',BaseBagModel)

function PetEquipModel:ctor()
    PetEquipModel.Instance = self

    --宠物装备套装数据 key为宠物id 套装id value为套装数据列表
    self.suit_cfg = {}

    --宠物装备数据 key为装备id 套装id value为配置数据
    self.pet_equip_cfg = {}

    self.get_mode = {}
    self.get_mode.equal = 1  --等于
    self.get_mode.less_than_or_equal = 2  --小于等于

    self:InitConfig()

    self:Reset()
end

function PetEquipModel:Reset()

    --当前选择的宠物数据
    self.cur_pet_data = nil


    --当前选择的宠物已穿戴的装备数据 key为slot value为item
    self.cur_pet_equips = {}

    --所有宠物已穿戴的装备数据 [pet_id][slot] = item
    self.all_pet_equips = {}
   
end

function PetEquipModel.GetInstance()
    if PetEquipModel.Instance == nil then
        PetEquipModel.new()
    end
    return PetEquipModel.Instance
end

--初始化配置
function PetEquipModel:InitConfig(  )
    local cfg = Config.db_pet_equip_suite
    for k,v in pairs(cfg) do
        self.suit_cfg[v.pet_id] = self.suit_cfg[v.pet_id] or {}
        self.suit_cfg[v.pet_id][v.id] = v
    end

    cfg = Config.db_pet_equip
    for k,v in pairs(cfg) do
        self.pet_equip_cfg[v.id] =  self.pet_equip_cfg[v.id] or {}
        self.pet_equip_cfg[v.id][v.order] = v
        self.pet_equip_cfg[v.id][v.order].slot = Config.db_item[v.id].stype
    end
end

--宠物装备列表返回处理
function PetEquipModel:HandlePetEquips(pet_id,equips)

    if pet_id == self.cur_pet_data.Config.order then
        self.cur_pet_equips = {}
    end
    self.all_pet_equips[pet_id] = {}
   
    for k,v in pairs(equips) do
        local cfg = self.pet_equip_cfg[v.id][v.equip.stren_phase]

        if pet_id == self.cur_pet_data.Config.order then
            self.cur_pet_equips[cfg.slot] = v
        end

        --self.all_pet_equips[pet_id] = self.all_pet_equips[pet_id] or {}
        self.all_pet_equips[pet_id][cfg.slot] = v
      
    end
end

--宠物装备穿戴返回处理
function PetEquipModel:HandlePetEquipPuton(pet_id,slot,equip)
    --刷新宠物装备列表数据
    --self.cur_pet_equips[slot] = equip
end

--宠物装备卸下返回处理
function PetEquipModel:HandlePetEquipPutoff(pet_id,slot)
    --self.cur_pet_equips[slot] = nil
end

--宠物装备强化返回处理
function PetEquipModel:HandlePetEquipReinf(pet_id,slot,equip)
    
end

--宠物装备升阶返回处理
function PetEquipModel:HandlePetEquipUporder(pet_id,slot,equip)
    
end

--获取背包宠物装备列表
function PetEquipModel:GetPetEquipItems(order,color,slot)

    order = order or 0
    color = color or 0
    slot = slot or 8000


    local items = BagModel.GetInstance().bags[BagModel.PetEquip].bagItems
    if not items then
        --没有宠物装备背包物品信息
        return {}
    end

    -- if order == 0 and color == 0 and slot == 8000 then
    --     --没有筛选要求 全部返回
    --     return items
    -- end

    local result = {}

    for k,v in pairs(items) do
        
        if v ~= 0 then
            local cfg = self.pet_equip_cfg[v.id][v.misc.stren_phase]
            if (order == 0 or cfg.order == order) and (color == 0 or cfg.color == color) and (slot == 8000 or cfg.slot == slot)then
                table.insert(result,v)
            end
        end
        
    end

    return result
end



--获取指定位置上的宠物装备数据
function PetEquipModel:GetPutOnBySlot(slot)
    return self.cur_pet_equips[slot]
end

--检查指定宠物身上是否有已生效的宠物套装
function PetEquipModel:CheckAllSuit(pet_id,order)
    for k,v in pairs(self.suit_cfg[pet_id]) do
        local cfg = self.suit_cfg[pet_id][k]
        if self:CheckTargetSuit(order,cfg) then
            --logError("宠物id-"..pet_id.."身上有已生效的宠物套装")
            return true
        end
    end
    --logError("宠物id-"..pet_id.."身上没有已生效的宠物套装")
    return false
end

--检查指定宠物的指定套装是否已生效
function PetEquipModel:CheckTargetSuit(order,cfg)

     --符合星数和颜色要求的装备数量
     local num = 0

     for k,v in pairs(self.all_pet_equips[order]) do
 
         local equip_cfg = self.pet_equip_cfg[v.id][v.equip.stren_phase]
 
         if  equip_cfg.color >= cfg.com_color and  equip_cfg.star >= cfg.com_star then
             num = num + 1
         end
     end

     if cfg.com_sum <= num then
        return true
     else
        return false
     end
end

--检查指定宠物的穿戴中所有宠物装备是否有可强化或可进阶的
function PetEquipModel:CheckStrenOrUporderReddotByTargetPet(pet_id)

    pet_id = pet_id or self.cur_pet_data.Config.order

    if not self.all_pet_equips[pet_id] then
        return
    end

    for k,v in pairs(self.all_pet_equips[pet_id]) do
        if self:CheckStrenReddotByTarget(v) then
            --logError("宠物装备红点检查-true,pet_id-"..pet_id)
            return true
        end
    end
    --logError("宠物装备红点检查-false,pet_id-"..pet_id)
    return false
end

--检查穿戴中指定宠物装备是否可强化或可进阶
function PetEquipModel:CheckStrenReddotByTarget(item)

    local pet_equip_cfg = self.pet_equip_cfg[item.id][item.equip.stren_phase]

    if item.equip.stren_lv== item.equip.stren_phase * 10 then
        --可进阶检查

        if pet_equip_cfg.color < 5 then
            --颜色不够
            return false
        end

        local next_pet_equip_cfg = self.pet_equip_cfg[item.id][item.equip.stren_phase + 1]
        if not next_pet_equip_cfg then
            --没有下一阶配置
            return false
        end

        local cost = String2Table(next_pet_equip_cfg.cost)

        for k,v in pairs(cost) do

            local id = v[1]
            local num = v[2]
    
            local have = BagController:GetInstance():GetItemListNum(id)
            if have < num then
                --材料不足
               return false
            end
    
        end

        return true
    else
        
        --可强化检查
        if pet_equip_cfg.color < 4 then
            --颜色不够
            return false
        end

        local slot = Config.db_item[item.id].stype
        local stren_cfg = Config.db_pet_equip_strength[slot .. "@" .. item.equip.stren_phase]
        local cost = String2Table(stren_cfg.cost)
        local have = RoleInfoModel:GetInstance():GetRoleValue(cost[1])
        have = have or 0

        if have >= cost[2] then
            return true
        else
            --材料不足
            return false
        end
    end

    
end

--检查背包中是否有指定宠物品质可穿戴的装备
function PetEquipModel:CheckCanPutonReddotByTarget(quality)
    local items = BagModel.GetInstance().bags[BagModel.PetEquip].bagItems
    if not items or table.nums(items)  == 0 then
        --没有宠物装备背包物品信息
        --logError("宠物装备可穿戴红点检查-false，背包没有宠物装备")
        return false
    end

    for k,v in pairs(items) do
        if v ~= 0 then
            local cfg = self.pet_equip_cfg[v.id][v.misc.stren_phase]
            if PetEquipHelper.GetInstance():CheckEquipLimit(quality,cfg) then
                --logError("宠物装备可穿戴红点检查-true")
                return true
            end
        end
      
    end
    --logError("宠物装备可穿戴红点检查-false")
    return false
end

local function get_attr_value(rare, attr_id)
    for _, v in pairs(rare) do
        if v[1] == attr_id then
            return v[2]
        end
    end
end
--获取宠物装备分数
function PetEquipModel:GetEquipScoreInCfg(equipcfg)
	local base = String2Table(equipcfg.base)
    local other = String2Table(equipcfg.attr)
    local rare1 = String2Table(equipcfg.rare1)
    local rare2 = String2Table(equipcfg.rare2)
    local rare3 = String2Table(equipcfg.rare3)
    local basescore = 0
    for i=1, #base do
        local attr = base[i]
        local attr_id = attr[1]
        local attr_value = attr[2]
        local coef = (Config.db_attr_type[attr_id] and Config.db_attr_type[attr_id].coef or 0)
        basescore = basescore + coef * attr_value
    end
    
    local function get_score(attr_id)
        local scorecfg = Config.db_pet_equip_score[attr_id]
        if scorecfg then
            local QualityList = String2Table(scorecfg.quality_ratio)
        local ratio = scorecfg.ratio
        local color = equipcfg.color
        local attr_balue = (get_attr_value(rare1, attr_id) or get_attr_value(rare2, attr_id) or get_attr_value(rare3,attr_id) or 0)
        local ratio2 = 0
        for _, v in pairs(QualityList) do
            if v[1] == color then
                ratio2 = v[2]
                break
            end
        end
        return math.ceil(basescore * attr_balue * ratio/10000)
            + math.ceil(basescore * attr_balue * ratio2)
    else
        return 0
        end
        
    end
    local score = 0
    for _, v in pairs(other) do
        score = score + get_score(v[1])
    end
    return math.ceil(basescore + score)
end


