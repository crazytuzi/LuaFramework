
-- User: cloud
-- Date: 2017.2.10
-- [[文件功能：角色相关的计算方面的问题]]
RoleCalculate = RoleCalculate or BaseClass()

--[[装备是否在的职业、等级限制之内可穿
-- @param is_role  是否是主角色
-- @param role_vo  角色或者是英雄的数据
-- @param equip_vo 装备的数据vo
-- ]]
function RoleCalculate.isLimitCareer(is_role, role_vo, equipVo)
    --判断是否有归属
    if role_vo ~= nil and equipVo ~= nil then
        if CommonGoodsType.isRolePartnerEquip(equipVo.bid) then
            local bool = RoleCalculate.isCanPutOn(equipVo, is_role)
            if bool == false then
                return bool
            end
            --等级限制
            bool = RoleCalculate.isLevLimit(role_vo, equipVo)
            if bool == false then
                return bool
            end
            --职业限制
            bool = RoleCalculate.isCareerLimit(is_role, role_vo, equipVo)
            if bool == false then
                return bool
            end
        end
    end
    return true
end


--是否在职业限制中，职业限制
function RoleCalculate.isCareerLimit(is_role, role_vo, equipVo)
    local career
    local flag = true
    if is_role then
        career = role_vo.career
    else
        career = Config.PartnerBase[role_vo.bid].career
    end
    local config = Config.Item[equipVo.bid]
    if config["condition"] and config["condition"]["career"] then --职业限制
        local equip_career = config["condition"]["career"]
        local len = string.len(career)
        local ok = false
        for i = len, 1, -1 do
            local temp = tonumber(string.sub(career, 1, i))
            if temp == equip_career then
                ok = true
                break
            end
        end
        if ok == false then
            flag = ok
        end
    end
    return flag
end


--不是在等级限制中
function RoleCalculate.isLevLimit(role_vo, equipVo)
    local flag = true
    if role_vo and equipVo then
        local lev = role_vo.lev
        --装备
        local config = Config.Item[equipVo.bid]
        if config and config.lev > lev then --等级限制
            flag = false
        end
    end
    return flag
end


--判断装备的互相之间的可穿性(单纯判断装备的归属性)
function RoleCalculate.isCanPutOn(equipVo, is_role)
    if CommonGoodsType.isRolePartnerEquip(equipVo.bid) then
        if equipVo.object then
            if is_role then --角色
                if equipVo.object == RoleConstants.Object.Hero then
                    return false
                end
            else  --英雄
                if equipVo.object == RoleConstants.Object.Role then
                    return false
                end
            end
        end
    end
    return true
end




--检查单个物品数据
function RoleCalculate.checkEquipCell(goods_vo, equip_pos, role_vo, is_role)
    local bid = goods_vo.bid
    if CommonGoodsType.isRolePartnerEquip(bid) then
        --属于英雄的装备部分
        local type = Config.Item[goods_vo.bid].type
        local pos = Config.EqmPos_2[type].pos
        if equip_pos == pos then --表示是同一个格子的装备
            if RoleCalculate.isEquipLimit(goods_vo, role_vo, is_role) then --排除限制
                return goods_vo
            end
        end
    else

    end
end

--是否有职业限制
function RoleCalculate.isEquipLimit(equipVo, role_vo, is_role)
    return RoleCalculate.isLimitCareer(is_role, role_vo, equipVo)
--    local lev = role_vo.lev
--    local career
--    local flag = true
--
--    --判断是否有归属
--    local bool = RoleCalculate.isCanPutOn(equipVo, is_role)
--    if bool == false then
--        return bool
--    end
--
--    --在检测其他的
--    if is_role then
--        career = GameData:getInstance():getRoleVo().career
--    else
--        career = Config.PartnerBase[role_vo.bid].career
--    end
--    --装备
--    local config = Config.Item[equipVo.bid]
--    if config.lev > lev then --等级限制
--        flag = false
--    elseif config["condition"] and config["condition"]["career"] then --职业限制
--        local equip_career = config["condition"]["career"]
--        local len = string.len(career)
--        local ok = false
--        for i = len, 1, -1 do
--            local temp = tonumber(string.sub(career, 1, i))
--            if temp == equip_career then
--                ok = true
--                break
--            end
--        end
--        if ok == false then
--            flag = ok
--        end
--    end
--    return flag
end


--对于当前等级段内，主角可以买到相应格子的装备
function RoleCalculate.getEquipByShop(pos, is_role)
    local max_lev = 0
    local config, mall_config
    local role_vo = GameData:getInstance():getRoleVo()
    for k, item in pairs(Config.MallGoods) do
        --是否存在商品
        if CommonGoodsType.isRolePartnerEquip(item.item_bid) then
            local vo = Config.Item[item.item_bid]
            if vo then
                if ShopModel:getInstance():hasGoodsByBidOnEquip(item.item_bid, vo.lev)  then
--                    lfl(Config.Item[item.item_bid].name, Config.ItemTypeName[Config.Item[item.item_bid].type])
                    if RoleCalculate.isEquipLimit(vo, role_vo, (is_role or true)) then
                        
                        --判断格子是否符合
                        local type = vo.type
                        if Config.EqmPos_2[type].pos == pos then
                            local lev = vo.lev
                            if lev > max_lev then
                                max_lev = lev
                                config = vo
                                mall_config = item
                            end
                        end
                    end
                end
            end
        end
    end
    return config, mall_config
end

--对于当前等级段内，英雄可以买到相应格子的装备
function RoleCalculate.getHeroEquipByShop(pos, hero_vo)
    local max_lev = 0
    local config, mall_config
    local role_vo = hero_vo
    for k, item in pairs(Config.MallGoods) do
        --是否存在商品
        if CommonGoodsType.isRolePartnerEquip(item.item_bid) then
            local vo = Config.Item[item.item_bid]
            if vo then
                if ShopModel:getInstance():hasGoodsByBidOnEquip(item.item_bid, vo.lev) then
                    if RoleCalculate.isEquipLimit(vo, role_vo, false) then
                        --判断格子是否符合
                        local type = vo.type
                        if Config.EqmPos_2[type].pos == pos then
                            local lev = vo.lev
                            if lev > max_lev then
                                max_lev = lev
                                config = vo
                                mall_config = item
                            end
                        end
                    end
                end
            end
        end
    end
    return config, mall_config
end


--判断是否可以卸下
function RoleCalculate.isCanTakeOff(bid)
    return (not RoleCalculate.isFaBao(bid))
end


--判断是否法宝
function RoleCalculate.isFaBao(bid)
    return CommonGoodsType.isPartnerFaBao(bid)
end

--获取下时装标签页
function RoleCalculate.getFashionPageType(bid)
    local item_config = Config.Item[bid]
    if item_config then
        local type = item_config.type
        if type == 200 then
            --return RoleTabConstants.headwear
            return RoleTabConstants.all_style
        elseif type == 201 then
            --return RoleTabConstants.clothes
            return RoleTabConstants.all_style
        elseif type == 202 then
            return RoleTabConstants.shinering
        elseif type == 203 then
            return RoleTabConstants.footprint
        elseif type == 255 then
            return RoleTabConstants.all_style
        end
    end
end

-- 判断是否时装、头饰、足迹等
function RoleCalculate.isItemFashion(bid)
    local ret = false
    local item_config = Config.Item[bid]
    if item_config then
        local type = item_config.type
        if type == 200 then
            ret = true
        elseif type == 201 then
            ret = true
        elseif type == 202 then
            ret = true
        elseif type == 203 then
            ret = true
        elseif type == 255 then
            ret = true  
        end
    end
    return ret
end

-- 判断是否可以精炼
function RoleCalculate.isItemJingLian(bid)
    local ret = false
    local item_config = Config.Item[bid]
    if item_config then
        local type = item_config.type
        if type == 201 then
            ret = true
        end
    end
    return ret
end

--获取根据时装的数组列表
function RoleCalculate.getFashionArrByType(type)
    local array = Array.New()
    local roleVo = GameData:getInstance():getRoleVo()
    for bid, tempVo in pairs(Config.Fashion) do
        if type == tempVo.type and roleVo and (roleVo.career == tempVo.career or tempVo.career == 100) and (roleVo.sex == tonumber(tempVo.sex) or tonumber(tempVo.sex) == 100) then
            --获取下时装背包的数据
            local fashionVo = BackPackCtrl:getInstance():getData():getFashionVoByBid(bid)
            array:PushBack({bid = bid, config = tempVo, goodsVo = fashionVo})
        end
    end
    if array:GetSize() > 0 then
        array:LowerSort("bid")
    end
    return array
end

-- 获取头饰和服装的组合
function RoleCalculate.getFashionArrByTypePro()
    local array = Array.New()
    local roleVo = GameData:getInstance():getRoleVo()
    local type = RoleTabConstants.headwear
    for bid, tempVo in pairs(Config.Fashion) do
        if type == tempVo.type and roleVo and (roleVo.career == tempVo.career or tempVo.career == 100) and (roleVo.sex == tonumber(tempVo.sex) or tonumber(tempVo.sex) == 100) then
            if tempVo.show == 1 then -- 0的暂时不显示
                --获取下时装背包的数据
                local fashionVo = BackPackCtrl:getInstance():getData():getFashionVoByBid(bid)
                array:PushBack({bid = bid, config = tempVo, goodsVo = fashionVo})
            end
        end
    end
    type = RoleTabConstants.bubble
    for bid, tempVo in pairs(Config.Fashion) do
        if type == tempVo.type and roleVo and (roleVo.career == tempVo.career or tempVo.career == 100) and (roleVo.sex == tonumber(tempVo.sex) or tonumber(tempVo.sex) == 100) then
            --获取下时装背包的数据
            local fashionVo = BackPackCtrl:getInstance():getData():getFashionVoByBid(bid)
            array:PushBack({bid = bid, config = tempVo, goodsVo = fashionVo})
        end
    end

    type = RoleTabConstants.clothes
    for bid, tempVo in pairs(Config.Fashion) do
        if type == tempVo.type and roleVo and (roleVo.career == tempVo.career or tempVo.career == 100) and (roleVo.sex == tonumber(tempVo.sex) or tonumber(tempVo.sex) == 100) then
            --获取下时装背包的数据
            local fashionVo = BackPackCtrl:getInstance():getData():getFashionVoByBid(bid)
            array:PushBack({bid = bid, config = tempVo, goodsVo = fashionVo})
        end
    end
    
    if array:GetSize() > 0 then
        array:LowerSort("bid")
    end
    return array
end


--判断下时装是否激活状态
function RoleCalculate.isActivateFashion(goodsVo)
    local is_activate = goodsVo ~= nil
    if goodsVo and goodsVo["expire_ts"] then
        local deadTime = goodsVo.expire_ts
        local net_time = GameNet:getInstance():getTime()
        is_activate = (deadTime > 0 and net_time < deadTime) or deadTime == 0
    end
    return is_activate
end


--时装的总属性计算
function RoleCalculate.getFashionAttribute( goodsVo, attr_key )
    -- body
    local attr_value = 0
    local bid = goodsVo.bid
    local config = Config.Fashion[bid]
    if config then 
        local activate_attr = config.activate_attr
        local base_attr = activate_attr[attr_key] or 0
        attr_value = attr_value + base_attr
        if base_attr > 0 and goodsVo["getAttrExtByCode"] then 
            local fashion_jie = goodsVo:getAttrExtByCode(GoodsVo.AttrExt.fashion_jie)
            local fashion_perfect = goodsVo:getAttrExtByCode(GoodsVo.AttrExt.fashion_perfect)
            local more_attr = RoleCalculate.getFashionAddAttr(bid, fashion_jie, fashion_perfect, attr_key)
            attr_value = attr_value + more_attr
        end
    end
    return attr_value
end


--获取指定阶数，完美度的加成属性
function RoleCalculate.getFashionAddAttr(bid, fashion_jie, fashion_perfect, attr_key)
    local more_attr = 0
    if Config.FashionUpgrade[bid] and Config.FashionUpgrade[bid][fashion_jie] and Config.FashionUpgrade[bid][fashion_jie][fashion_perfect] then
        local upgrade_config = Config.FashionUpgrade[bid][fashion_jie][fashion_perfect]
        local add_attr = upgrade_config["add_attr"]
        more_attr = add_attr[attr_key] or 0
    end
    return more_attr
end


--获取下一阶段的增值部分的属性(二貨的想法，把完美度餘下來的屬性全部加起來)
function RoleCalculate.getFashionNextAddAttr(bid, fashion_jie, fashion_perfect, attr_key)
    local cur_attr = RoleCalculate.getFashionAddAttr(bid, fashion_jie, fashion_perfect, attr_key)
    --下一阶段的属性
    local next_jie, next_perfect = fashion_jie, fashion_perfect
    if fashion_perfect < Config.FashionConstant[2].value then --完美度没有满
        next_perfect = 0  --fashion_perfect + 1
        next_jie = math.min(fashion_jie + 1, Config.FashionConstant[1].value)
        if fashion_jie == Config.FashionConstant[1].value then
            next_perfect = Config.FashionConstant[2].value
        end
    else --完美度满了
        if fashion_jie < Config.FashionConstant[1].value then --阶还没有满
            next_jie = math.min(fashion_jie + 1, Config.FashionConstant[1].value)
            next_perfect = 0
        else
            next_jie, next_perfect = 0, 0
        end
    end
    local next_attr_value = 0
    if next_jie > 0 or next_perfect > 0 then
        local full_perfect = next_perfect
        next_attr_value = RoleCalculate.getFashionAddAttr(bid, next_jie, full_perfect, attr_key) - cur_attr
    end
    return next_attr_value
end


--获取时装分类的标签数组
function RoleCalculate.getFashionTabByType()
    local tabType = {}
    for __, v in pairs(Config.Fashion) do
        if not tabType[v.type] then tabType[v.type] = true end
    end
    return tabType
end
