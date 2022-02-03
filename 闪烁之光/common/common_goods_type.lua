
-- User: cloud
-- Date: 2017.2.10
-- 文件功能：物品的物品

CommonGoodsType = CommonGoodsType or {}

--[[物品配置类型
  1：英雄装备
  2：英雄装备碎片
  3：英雄装备图纸
  4: 英雄升星道具
  5：消耗品
  6：礼包
  7：角色材料
  11~30:宝石
  100~109：角色装备
]]

-- 背包物品分类 对应背包界面标签页索引
CommonGoodsType.bagItemType =
{
  BAG_ALL = 1,       -- 全部
  BAG_MATERIAL = 4,  -- 材料
}
--[[对物品进行分类
-- @param item_type 物品的类型
-- @return
-- ]]
function CommonGoodsType.getGoodsItemType(item_bid)
    local item_config = Config.ItemData.data_get_data(item_bid)
    if item_config then
        local item_type = item_config.type
        if item_type then
            if item_type >= 11 and item_type <= 20 then --宝石
                return CommonGoodsType.bagItemType.BAG_PROP
            elseif item_type == 0  then --材料
                return CommonGoodsType.bagItemType.BAG_MATERIAL
            elseif CommonGoodsType.isRoleEquip(item_bid) then --装备
                return CommonGoodsType.bagItemType.BAG_EQUIP
            end
        end
    end
end

-- 是否角色背包物品
function CommonGoodsType.isRoleBagGoods(item_bid)
    if (CommonGoodsType.isBaseItem(item_bid) or
            CommonGoodsType.isGiftItem(item_bid) or
            CommonGoodsType.isJewelItem(item_bid) or
            CommonGoodsType.isRoleEquip(item_bid)) then
        return true
    end
    return false
end


--是否是装备
function CommonGoodsType.isRoleEquip(item_bid)
    --角色的装备
    if CommonGoodsType.isRolePartnerEquip(item_bid) then
        return true
    end
    return false
end
--是否是伙伴神器
function CommonGoodsType.isArtifact(item_bid)
    if item_bid then
        local item_config = Config.ItemData.data_get_data(item_bid)
        if item_config then
            local item_type = item_config.type
            if item_type and item_type ==BackPackConst.item_type.ARTIFACTCHIPS then
                return true
            end
        end
    end
    return false
end

--是否是英雄专属装备
function CommonGoodsType.isRolePartnerEquip(item_bid)
    if item_bid then
        local item_config = Config.ItemData.data_get_data(item_bid)
        if item_config then
            local item_type = item_config.sub_type
            if item_type and item_type ==4 then
                return true
            end
        end
    end
    return false
end

--获取装备的物品的品质色
function CommonGoodsType.getQualityByVo(goods_vo)
    local quality = 1
    local item_bid_temp = goods_vo.base_id or goods_vo.bid
    if goods_vo and item_bid_temp  then
        local item_bid = item_bid_temp
        local item_config = Config.ItemData.data_get_data(item_bid)
        if item_config then
            if item_config.type>=1 and item_config.type<=6 then
                quality = goods_vo.quality 
                -- if not quality then
                --     if goods_vo.extra_attr then
                --         quality = #goods_vo.extra_attr
                --     end
                -- end
            else
                quality = item_config.quality
            end
            
        end
    end
    return quality
end

--是否需要批量购买
function CommonGoodsType.isMutiBuy(shop_type,item_type)
    --只有钻石商城才有批量购买
    if shop_type == 1 then 
        --钻石商城中体力，金币之类的不需要批量购买
        if item_type ~= 7 then 
            return true
        end
    end
    return false
end
--是否礼包物品
function CommonGoodsType.isGiftItem(item_bid)
    if item_bid then
        local item_config = Config.ItemData.data_get_data(item_bid)
        if item_config then
            local item_type = item_config.type
            --礼包,类型还没定
            if item_type == 100 or item_type == 101 then
                return true
            end
        end
    end
    return false
end
--是否可以批量使用
function CommonGoodsType.isCanBatchUse(bid)
    if bid then 
        if bid == 10220 then --三星召唤书不能批量使用
            return false
        end
    end
    return true
end

--是否可以丢弃的物品类型
function CommonGoodsType.isRemoveItem(item_bid)
    if item_bid then
        local item_config = Config.ItemData.data_get_data(item_bid)
        if item_config then
            local item_type = item_config.type
            if item_type ==0 then
                return true
            end
        end
    end
    return false
end

--是否资产
function CommonGoodsType.isAsset(item_bid)
    if item_bid then
        local item_config = Config.ItemData.data_get_data(item_bid)
        if item_config then
            local item_type = item_config.type
            if item_type == 7 then
                return true
            end
        end
    end
    return false
end


--是否伙伴碎片
function CommonGoodsType.isPartnerPiece(item_bid)
    if item_bid then
        local item_config = Config.ItemData.data_get_data(item_bid)
        if item_config then
            local item_type = item_config.type
            if item_type == 102 then
                return true
            end
        end
    end
    return false
end


--是否数据时装类型
function CommonGoodsType.isPartnerFashion(item_bid)
    if item_bid then
        local item_config = Config.ItemData.data_get_data(item_bid)
        if item_config then
            local item_type = item_config.type
            if item_type == 12 then
                return true
            end
        end
    end
    return false
end

--判断是否有激活头像框的物品
function CommonGoodsType.isHaveActiveGoods(list)
    local config = Config.AvatarData.data_avatar
    list = list or {}
    for i,v in pairs(config) do 
        
        if v and v.base_id and v.loss and v.loss[1] and v.loss[1][1] and v.loss[1][2] then 
            if not list[v.base_id] then 
                local bid = v.loss[1][1]
                local num = v.loss[1][2]
                local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(bid)
                if count and count >num then 
                    return true
                end
            end
        end
    end
    return false
end