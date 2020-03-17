--[[
    Created by IntelliJ IDEA.
    User: Hongbin Yang
    Date: 2016/6/30
    Time: 20:16
   ]]

_G.StoveUtil = {};

function StoveUtil:GetStoveTableVO(type, level)
    for k, v in pairs(t_stoveplay) do
        if v.type == type and v.level == level then
            return v;
        end
    end
    return nil;
end

--获得神炉的名字图片
function StoveUtil:GetStoveTid(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.id;
end

--获得神炉的名字图片
function StoveUtil:GetStoveNameIcon(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.name_icon;
end

--获得神炉的等级图片
function StoveUtil:GetStoveLevelIcon(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.lvl_icon;
end

--获得神炉的图标
function StoveUtil:GetStoveIcon(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.icon;
end

--获得神炉的模型
function StoveUtil:GetStoveUISen(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.ui_sen;
end

--获得神炉的配置表属性
function StoveUtil:GetStoveAttr(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.attr;
end

--获得神炉的配置表每星的属性
function StoveUtil:GetStoveAttrStar(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.attr_star;
end

--获得神炉的材料
function StoveUtil:GetStoveNeedItemList(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return split(stoveTableItem.itemtype, "#");
end

--获得神炉的配表ID
function StoveUtil:GetStoveTid(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.id;
end

--获得神炉的升级经验
function StoveUtil:GetStovePlan(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.plan;
end

--获得神炉的消耗道具VO
function StoveUtil:GetStoveCostItem(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return split(stoveTableItem.item, ",");
end

--获得神炉的当前阶段星级数量
function StoveUtil:GetStoveXingJi(type, level)
    local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
    if not stoveTableItem then return ""; end
    return stoveTableItem.xingji;
end

--获得神炉的快速购买itemid
function StoveUtil:GetStoveQuickBuyItemID(type, level)
local stoveTableItem = StoveUtil:GetStoveTableVO(type, level);
if not stoveTableItem then return ""; end
return stoveTableItem.quickBuyItemID;
end