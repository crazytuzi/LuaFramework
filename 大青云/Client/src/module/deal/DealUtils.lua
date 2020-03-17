--[[
交易utils
郝户
2014年11月4日17:38:36
]]

_G.DealUtils = {};

--获取物品品质
function DealUtils:GetQualityUrl(tid)
    local cfg = t_equip[tid] or t_item[tid];
    local qURL = cfg and ResUtil:GetSlotQuality( cfg.quality) or "";
    return qURL;
end

--获取物品属性
function DealUtils:GetGoodsAttrById(tid, attr)
    local item = t_item[tid] or t_equip[tid];
    return item and item[attr];
end
