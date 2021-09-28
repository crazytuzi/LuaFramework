require "Core.Info.ProductInfo";
require "Core.Info.BaseAttrInfo"
require "Core.Manager.Item.ProductsContainer";
require "Core.Manager.Item.GemDataManager";

EquipDataManager = { }

EquipDataManager.container = ProductsContainer:New();
EquipDataManager.ext_eq_container = ProductsContainer:New();

EquipDataManager._productConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT)
EquipDataManager.fairy_groove_pos = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FAIRY_GROOVE_POS)
EquipDataManager.fairy_groove_value = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FAIRY_GROOVE_VALUE)

EquipDataManager.fairy_attribute = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FAIRY_ATTRIBUTE)
EquipDataManager.fairy_forging = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FAIRY_FORGING)

EquipDataManager.grade = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GRADE)

EquipDataManager.KIND_XIANBING = 9; -- 仙兵
EquipDataManager.KIND_XUANBING = 10; -- 玄兵

EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE = "MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE";


EquipDataManager.WISEEQUIPATTLIST_NUM = 6;

local _sortfunc = table.sort 
-- 角色装备数据初始化

function EquipDataManager.GetEquipGradName(eq_lv)
    for key, value in pairs(EquipDataManager.grade) do
        if value.min_level <= eq_lv and value.max_level >= eq_lv then
            return value.name;
        end
    end
    return "null";
end

--[[

"equip":[
{"st":2,"pt":"10100103","id":"1036","am":1,"idx":6,"spId":301006},
]]
function EquipDataManager.Init(data_arr)

    EquipDataManager.container:InitDatas(data_arr, "idx");

end

function EquipDataManager.InitExiEq(data_arr)
    EquipDataManager.ext_eq_container:InitDatas(data_arr, "idx");
end

function EquipDataManager.GetExtEqContainer()
    return EquipDataManager.ext_eq_container;
end

function EquipDataManager.DispatchEvent()
    -- 装备 发生改变， 那么 对应的 战斗力也会发生改变
    PlayerManager.CalculatePlayerAttribute()
    MessageManager.Dispatch(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE);
end


function EquipDataManager.GetProducts()
    return EquipDataManager.container:GetItem();
end

function EquipDataManager.GetProductByKind(kind)


    if kind == EquipDataManager.KIND_XIANBING then

        return EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx1)
    elseif kind == EquipDataManager.KIND_XUANBING then
        return EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx2)
    end


    local obj = EquipDataManager.container:FindByAttKey("kind", kind);
    return obj;

end





function EquipDataManager.SetProductByIdx(info, idx)
    EquipDataManager.container:SetBykey(info, idx);
end

function EquipDataManager.UpDataProductBaseData(baseData)

    if baseData.st == ProductManager.ST_TYPE_IN_EQUIPBAG then
        local res = EquipDataManager.GetProductByIdx(baseData.idx);
        res:Init(baseData);
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Equip)
        MessageManager.Dispatch(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE);
        --        EquipDataManager.DispatchEvent();
    end

end 


-- 下标从0开始 与后台一直
function EquipDataManager.GetProductByIdx(idx)

    local obj = EquipDataManager.container:GetByKey(idx);
    return obj;
end

function EquipDataManager.GetProductById(id)

    local obj = EquipDataManager.container:FindByAttKey("id", id);
    return obj;
end

function EquipDataManager:Replace(other_container, other_data, self_data)
    EquipDataManager.container:Replace(other_container, other_data, self_data);
end

function EquipDataManager.GetContainer()
    return EquipDataManager.container;
end

-- 获取自己8个装备槽的属性相加  
function EquipDataManager.GetMyEquipsAllAttrs()
    return EquipDataManager.GetAllEuipsAttrs()
end  

function EquipDataManager.GetMyWiseEquipsAllAttrs()
    -- 新添加的 两个装备
    local res = BaseAdvanceAttrInfo:New()
    local attkeys = BaseAdvanceAttrInfo.GetProperty();
    local attkeys_num = table.getn(attkeys);

    local eq = nil;

    for i = 1, 2 do
        eq = EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx["Idx" .. i])

        if eq ~= nil then
            local att = eq:GetWiseEqAllAtt()
            for k = 1, attkeys_num do
                ProductInfo.TryAddAtt(res, attkeys[k], att);
            end
        end
    end
    return res;
end  

-- 获取所有装备的所有属性相加后的值
function EquipDataManager.GetAllEuipsAttrs()
    -- 装备的基础属性
    local res = BaseAttrInfo:New()

    local attkeys = BaseAttrInfo.GetAttKeys();
    local attkeys_num = table.getn(attkeys);

    local productcf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT_ATTR);
    local slv = 0;
    local eq = nil;
    local spId = nil;
    for i = 1, 8 do

        eq = EquipDataManager.GetProductByKind(i);
        if eq ~= nil then
            spId = eq.spId;

            local eqlv = EquipLvDataManager.getItem(i);
            slv = eqlv.slv;
            slv = 0;
            -- 基础属性必须 设置 强化等级为 0

            local key = spId .. "_" .. slv;
            local pro_att = productcf[key];
            if pro_att ~= nil then

                for k = 1, attkeys_num do
                    ProductInfo.TryAddAtt(res, attkeys[k], pro_att);
                end
            end

        end

    end




    return res
end

function EquipDataManager.GetAllEuipsFoMoAttrs()

    local res = { };

    local attkeys = BaseAdvanceAttrInfo:GetProperty();
    local attkeys_num = table.getn(attkeys);

    for j = 9, 10 do
        eq = EquipDataManager.GetExtEquipByKind(j)
        if eq ~= nil then
            for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
                local isopen = eq:IsOpenFairyGroove(i);
                if isopen then
                    local att = eq:GetFairyGroove(i);
                    if att ~= nil then
                        for k = 1, attkeys_num do
                            ProductInfo.TryAddAtt(res, attkeys[k], att);
                        end
                    end

                end
            end

        end
    end

    return res;
end  
 
--[[
function EquipDataManager.GetItemTexturePath(name)
    return "product/" .. name
end
]]

-- 获取七天活动 前端的装备强化等级
function EquipDataManager.GetDaysRankStrength()
    local num = NewEquipStrongManager.GetAllStrongLevel()
    return num;
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- 获取 对应槽位配置
function EquipDataManager.GetFairy_groove_pos(pos_index)
    return EquipDataManager.fairy_groove_pos[pos_index];
end


-- 获取额外装备 idx 1：装备1  2：装备2
EquipDataManager.ExtEquipIdx = {
    Idx1 = 0,
    Idx2 = 1
};

EquipDataManager.MESSAGE_EXTEQUIP_CHANGE = "MESSAGE_EXTEQUIP_CHANGE";

EquipDataManager.fairy_groove_value_fairy_levList = { };


local _sortfunc = table.sort

function EquipDataManager.GetFairyGrooveCfByFairy_lev(fairy_lev)

    if EquipDataManager.fairy_groove_value_fairy_levList[fairy_lev] == nil then
        local cf = EquipDataManager.fairy_groove_value;

        local jdList = { };
        local index = 1;

        for key, value in pairs(cf) do
            if value.fairy_lev == fairy_lev then
                jdList[index] = value;
                index = index + 1;
            end
        end

        _sortfunc(jdList, function(a, b) return a.id < b.id end)

        EquipDataManager.fairy_groove_value_fairy_levList[fairy_lev] = jdList;

    end
    return EquipDataManager.fairy_groove_value_fairy_levList[fairy_lev];
end


function EquipDataManager.GetFairyGrooveCf(fairy_lev, quality)

    local list = EquipDataManager.GetFairyGrooveCfByFairy_lev(fairy_lev)


    for key, value in pairs(list) do
        if value.quality == quality then
            return value;
        end
    end
    return nil;
end 


--[[
 获取 仙器属性对应的颜色值
 fairy_lev  仙器等级
 max_attr_lev 可生成最高词条等级

 规则：
 在同一个 fairy_lev 值， 获取带一个区间的数据记录
 s_max_attr_lev 和在这个区间的 dd.max_attr_lev 相比， 取不大于 s_max_attr_lev 的最大一个 max_attr_lev 对应的颜色值

]]
function EquipDataManager.GetFairyGroove(fairy_lev, s_max_attr_lev)

    local jdList = EquipDataManager.GetFairyGrooveCfByFairy_lev(fairy_lev);
    local t_num = table.getn(jdList);

    for i = 1, t_num do

        if jdList[i].max_attr_lev == s_max_attr_lev then
            return jdList[i];
        elseif jdList[i].max_attr_lev > s_max_attr_lev then
            if i > 1 then
                return jdList[i - 1];
            else
                return jdList[1];
            end
        end
    end
    return jdList[t_num];
end


function EquipDataManager.GetFairyGrooveColor(fairy_lev, s_max_attr_lev)

    local obj = EquipDataManager.GetFairyGroove(fairy_lev, s_max_attr_lev);
    return obj.color;
end


function EquipDataManager.GetExtEquipByKind(kind)

    if kind == EquipDataManager.KIND_XIANBING then
        return EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx1);
    elseif kind == EquipDataManager.KIND_XUANBING then
        return EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx2);
    end

    return nil;
end


-- 设置额外装备 idx EquipDataManager.ExtEquipIdx
function EquipDataManager.GetExtEquip(idx)
    local obj = EquipDataManager.ext_eq_container:GetByKey(tonumber(idx));
    -- 后台是从0 开始
    return obj;

end



function EquipDataManager.GetExt_eqs()
    return EquipDataManager.ext_eq_container:GetItem();
end

-- 设置新的附魔信息
function EquipDataManager.UpFMInfo(id, fm)
    local item = EquipDataManager.GetExt_eqs();
    for key, value in pairs(item) do
        if value.id == id then
            value.fm = fm;
            EquipDataManager.DispatchExtEquipEvent();
            return;
        end
    end
end


function EquipDataManager.DispatchExtEquipEvent()
    -- 装备 发生改变， 那么 对应的 战斗力也会发生改变

    MessageManager.Dispatch(EquipDataManager, EquipDataManager.MESSAGE_EXTEQUIP_CHANGE);
end

--  检测是否有 仙器 可以 铸造或者附魔 
function EquipDataManager.WiseEquipCanDo()
    local b1 = EquipDataManager.IsCanFuMo();
    local b2 = EquipDataManager.IsCanDuanZao();

    return b1 or b2;
end

--  检测是否有 仙器 可以 铸造或者附魔 
function EquipDataManager.IsCanFuMo()
    local b1 = EquipDataManager.IsCanFuMoByKind(EquipDataManager.KIND_XIANBING);
    local b2 = EquipDataManager.IsCanFuMoByKind(EquipDataManager.KIND_XUANBING);

    return b1 or b2;
end

-- 是否可以锻造
function EquipDataManager.IsCanDuanZao()

    local b1 = EquipDataManager.IsCanDuanZaoByKind(EquipDataManager.KIND_XIANBING);
    local b2 = EquipDataManager.IsCanDuanZaoByKind(EquipDataManager.KIND_XUANBING);
     local sb2 = SystemManager.IsOpen(SystemConst.Id.WiseEquip_DuanZao);

    return sb2 and (b1 or b2) ;

end

function EquipDataManager.IsCanDuanZaoByKind(kind)

    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();
    local att_keys = EquipDataManager.GetWiseEquipAttKeys(my_career, kind);

    local eq = EquipDataManager.GetProductByKind(kind);
    if eq ~= nil then
        local att_k = nil;
        local att = nil;
        local lev = nil;
        local dz_att = nil;
        local consume_item = nil;

        for i = 1, 2 do
            att_k = att_keys[i];
            att = EquipLvDataManager.GetWiseEqAtt(att_k, kind);
            if att ~= nil then
                lev = att.lev;
                dz_att = EquipDataManager.GetWiseEquip_forging(kind, att_k, lev);
                if dz_att ~= nil then
                    consume_item = dz_att.consume_item;
                    for key, value in pairs(consume_item) do
                        local am = BackpackDataManager.GetProductTotalNumBySpid(value)
                        if am > 0 then
                            return true;
                        end
                    end
                end
            end
        end
    end

    return false;
end


-- 是否可以附魔 kind == 9  kind == 10
function EquipDataManager.IsCanFuMoByKind(kind)
    local eq = EquipDataManager.GetProductByKind(kind);
    if eq ~= nil then
        -- 寻找背包中是否有材料可以附魔的
        local eqsInBag = BackpackDataManager.GetProductsByTypes2(ProductManager.type_1, kind);
        for key, value in pairs(eqsInBag) do

            local b = EquipDataManager.IsCanFuMoByPro(eq, value);
            if b then
                return true;
            end
        end
    end

    return false;
end

-- 寻找是否有同属性并且 比 e_att 大的
function EquipDataManager.GetFitFMAttInEq(cinfo, e_att, hasCheckList)

    --  有空孔
    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        local isopen = cinfo:IsOpenFairyGroove(i);
        if isopen then
            local att = cinfo:GetFairyGroove(i);

            if att ~= nil then

                if att.attr_key == e_att.attr_key then

                    hasCheckList[att.attr_key] = true;

                    if att.att_value > e_att.att_value then
                        return true;
                    end

                end
            end

        end
    end

    return false;
end

function EquipDataManager.GetNotHasSameAttKey(cinfo, e_att, hasCheckList)
    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        local isopen = cinfo:IsOpenFairyGroove(i);
        if isopen then
            local att = cinfo:GetFairyGroove(i);

            if att ~= nil then
                if hasCheckList[att.attr_key] == nil and att.attr_key ~= e_att.attr_key then
                    return true;
                end
            end
        end
    end

    return false;
end

-- 背包里的装备 eqInfo  和 cinfo 对比， 判断是否可以附魔
-- 判断规则， cinfo  有一条属性 在 eqInfo 里是没有的或者， 有一条属性比 eqInfo 属性值要高
function EquipDataManager.IsCanFuMoByPro(eqInfo, cinfo)

    if eqInfo == nil then
        return true;
    end

    local hasCheckList = { };

    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        local isopen = eqInfo:IsOpenFairyGroove(i);
        if isopen then
            local att = eqInfo:GetFairyGroove(i);
            if att ~= nil then

                local b = EquipDataManager.GetFitFMAttInEq(cinfo, att, hasCheckList);
                if b then
                    return true;
                end

            end
        end
    end



    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        local isopen = eqInfo:IsOpenFairyGroove(i);
        if isopen then
            local att = eqInfo:GetFairyGroove(i);
            if att ~= nil then

                -- 已穿戴的仙器 有空 孔
                local hasNotSameAtt = EquipDataManager.GetNotHasSameAttKey(cinfo, att, hasCheckList)
                if hasNotSameAtt then
                    return true;
                end

            end
        end
    end



    return false;
end

------------------------
-- 最高等级 100
EquipDataManager.fairy_forging_max_lev = 100;

function EquipDataManager.GetWiseEquipAttKeys(career, kind)
    local key = kind .. "_" .. career;
    local cf = EquipDataManager.fairy_attribute[key];
    return cf.fairy_attribute;
end

function EquipDataManager.GetWiseEquip_forging(kind, att_key, xianwen_lev)
    local key = kind .. "_" .. att_key .. "_" .. xianwen_lev;
    local cf = EquipDataManager.fairy_forging[key];
    return cf;
end

--[[
   1、按照装备战斗力进行排序，战斗力高的装备排在最前
   2、装备的战斗力相同时，按照装备的品质从低到高进行排序，装备品质从高到低分别为：白、绿、蓝、紫、金、红
   ]]
function EquipDataManager.GetEqBySort(bag_equips)

    return EquipDataManager.SortByFightAndQuality(bag_equips);
end

-- 通过战力排序 和 品质  2  重排序
function EquipDataManager.SortByFightAndQuality(item)
    _sortfunc(item, function(a, b)

        if a:GetFight() == b:GetFight() then
            return a:GetQuality() > b:GetQuality()
        else
            return a:GetFight() > b:GetFight()
        end

    end )
    -- 从大到小排
    return item;
end

function EquipDataManager.IsCanFuLing()
    for i = 1, 8 do
        local b = EquipDataManager.IsCanFuLingByKind(i);
        if b then
            return true;
        end
    end
    return false;
end

-- http://192.168.0.8:3000/issues/9449
function EquipDataManager.FilterEq(list)
    local res = { };
    local len = table.getn(list);
    for i = 1, len do
        local pinfo = list[i];
        local quality = pinfo:GetQuality();
        local kind = pinfo:GetKind();
        local type = pinfo:GetType();

        local eqbagInfo = EquipDataManager.GetProductByKind(kind);

        if quality < 5 then

            if type == ProductManager.type_1 then
                local isFitCareer = pinfo:IsFitMyCareer();
                if isFitCareer then
                    if eqbagInfo == nil then
                        table.insert(res, pinfo);
                    else
                        local bag_fight = pinfo:GetFight();
                        -- 对应装备栏里的总 战斗力
                        local eq_bag_fight = eqbagInfo:GetFight();
                        if bag_fight <= eq_bag_fight then
                            table.insert(res, pinfo);
                        end
                    end
                end
            else
                table.insert(res, pinfo);
            end
        end
    end
    return res;
end

function EquipDataManager.IsCanFuLingByKind(kind)

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    local intensifyMaterials = BackpackDataManager.GetIntensifyMaterial();
    intensifyMaterials = EquipDataManager.FilterEq(intensifyMaterials);

    local len = table.getn(intensifyMaterials);

    local result = false;
    local total_num = 0;

    if len > 0 then
        for i = 1, len do
            local pinfo = intensifyMaterials[i];
            total_num = total_num + pinfo:GetAm();
        end
    end

    if total_num >= 3 then

        -- for i = 1, 8 do

        local productInfo = EquipDataManager.GetProductByIdx(kind - 1);
        local qh = EquipLvDataManager.getItem(kind)
        local eq_slv = 0;
        if qh ~= nil and qh.slv ~= nil then
            eq_slv = qh.slv;
        end

        if productInfo ~= nil and eq_slv < my_lv then
            -- 可以强化
            result = true;
            return result;
        end
        -- end
    else
        -- 需要看看 物品的数量是否 超过 3
        result = false;
    end

    return result;
end


---------------------------------------------------------------------------------------------------------------------------------

-- 检测 装备栏装备是否需要显示 红点 （强化）
--[[已穿戴装备 并且 强化材料数量>=3时，可强化的装备（未达强化上限）显示红点

  http://192.168.0.8:3000/issues/2992
  3.强化红点优化：当可用作强化的材料只剩余橙色的装备时，不显示强化红点。 （Quality 6）
  品质为6的装备 不列入 计算范围
]]
function EquipDataManager.Check_Npoint_for_classify_1()

    local result = false;

    local resuleData = { };

    for i = 1, 8 do
        local b = EquipDataManager.IsCanFuLingByKind(i);
        resuleData[i] = b;
        if b then
            result = true;
        end
    end

    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_1_CHANGE, { result = result, resuleData = resuleData });

    return result;

end

function EquipDataManager.Check_engouth_sh(need_item)

    for key, pinfo in pairs(need_item) do

        local spid = pinfo:GetSpId();
        local needAm = pinfo:GetAm();
        local totalInBag = BackpackDataManager.GetProductTotalNumBySpidNotSQ(spid);

        if totalInBag < needAm then
            return false;
        end
    end
    return true;
end

-- 检测 装备栏装备是否需要显示 红点 （精炼）
--[[精炼 右侧已穿戴装备时显示有红点时 已穿戴装备 对应部位的精炼材料满足时（材料&灵石）
]]
function EquipDataManager.Check_Npoint_for_classify_2()


    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;
    local my_career = heroInfo:GetCareer()
    local my_gd = MoneyDataManager.Get_money();


    local result = false;
    local resuleData = { };
    local refData = nil;
    local refData_next = nil;

    for i = 1, 8 do

        -- local eq_rlv = tem_ctr.eq_rlv;
        local productInfo = EquipDataManager.GetProductByIdx(i - 1);


        if productInfo ~= nil then

            local qh = EquipLvDataManager.getItem(i)
            local eq_rlv = qh.rlv;
            if eq_rlv == nil then
                eq_rlv = 0;
            end

            local kind = productInfo:GetKind();
            -- tem_ctr.kind;
            refData_next = RefineDataManager.GetRefine_item(kind, my_career, eq_rlv + 1);

            if refData_next ~= nil then
                -- 还没升级到顶级
                local needobj = RefineDataManager.GetRefine_item(kind, my_career, eq_rlv + 1);
                local need_item = needobj.need_item;
                local need_money = needobj.need_money;

                local b = EquipDataManager.Check_engouth_sh(need_item)


                if b and(my_gd >= need_money) then
                    -- 可以精炼
                    result = true;
                    resuleData[i] = true;

                else
                    resuleData[i] = false;

                end

            end
        end
    end


    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_2_CHANGE, { result = result, resuleData = resuleData });

    return result;


end


-- 检测 装备栏装备是否需要显示 红点 （宝石）
function EquipDataManager.Check_Npoint_for_classify_4()
    local result = false;
    local slotResult = false;
    result = false;
    local resuleData = { };

    for i = 1, 8 do
        slotResult = GemDataManager.GetGemRedPointBySlot(i);
        resuleData[i] = slotResult;
        result = result or slotResult;
    end

    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_4_CHANGE, { result = result, resuleData = resuleData });

    return result;
end

EquipDataManager.hasFistOpen = false;
-- 检测装备强化是否有红点
function EquipDataManager.Check_Npoint_for_classify_5()
    local result = false;
    local slotResult = false;
    result = false;
    local resuleData = { };

    if EquipDataManager.hasFistOpen then
        result = false;
    else
        for i = 1, 8 do
            slotResult = NewEquipStrongManager.GetCanStrongByIdx(i);

            result = result or slotResult;
            resuleData[i] = result;

        end
    end


    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_5_CHANGE, { result = result, resuleData = resuleData });

    return result;
end

-- 检测装备套装是否有红点
function EquipDataManager.Check_Npoint_for_classify_6()
    local result = false;
    local slotResult = false;
    result = false;
    local resuleData = { };

    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();


    for i = 1, 8 do
        local productInfo = EquipDataManager.GetProductByIdx(i - 1);

        if productInfo ~= nil then
            local select_spid = productInfo:GetSpId();
            local isFitSuit = EquipSuitDataManager.IsCanBeSuitAtt(my_career, select_spid);
            if isFitSuit then

                local sqlvdata = EquipLvDataManager.getItem(i);
                local suit_id = sqlvdata.suit_id;
                local suit_lev = sqlvdata.suit_lev;

                local suit_material_cf = EquipSuitDataManager.Get_suit_materials(suit_id, suit_lev, select_spid)
                local suit_up_materials = nil;
                if suit_material_cf == nil then
                    -- suit_lev==0 的情况
                    suit_material_cf = EquipSuitDataManager.Get_suit_materials(suit_id, 1, select_spid);
                    if suit_material_cf ~= nil then
                        suit_up_materials = suit_material_cf.suit_up_materials;
                    end


                else
                    if suit_lev < 2 then
                        local tcf = EquipSuitDataManager.Get_suit_materials(suit_id, suit_lev + 1, select_spid)
                        suit_up_materials = tcf.suit_up_materials;
                    end
                end

                if suit_up_materials ~= nil then

                    -- 如果有足够材料就可以升级
                    local m_num = table.getn(suit_up_materials);

                    local true_num = 0;
                    for j = 1, m_num do
                        local infoArr = ConfigSplit(suit_up_materials[j]);
                        local n_spid = infoArr[1];
                        local n_num = tonumber(infoArr[2]);

                        local totalInBag = BackpackDataManager.GetProductTotalNumBySpidNotSQ(n_spid);

                        if totalInBag >= n_num then
                            true_num = true_num + 1;
                        end

                    end
                    if true_num >= m_num then
                        result = true;
                        resuleData[i] = true;
                    else
                        resuleData[i] = false;
                    end
                end

            end

        end

    end



    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_CHECK_NPOINT_FOR_CLASSIFY_6_CHANGE, { result = result, resuleData = resuleData });

    return result;
end

-- 需要在这里添加 强化，精连
function EquipDataManager.CheckMainEqBtNeedShowTip()

    local b1 = EquipDataManager.Check_Npoint_for_classify_1() and SystemManager.IsOpen(SystemConst.Id.EquipFuLing);
    local b2 = EquipDataManager.Check_Npoint_for_classify_2() and SystemManager.IsOpen(SystemConst.Id.EquipRefine);

    local b4 = EquipDataManager.Check_Npoint_for_classify_4() and SystemManager.IsOpen(SystemConst.Id.Gem);
    local b5 = EquipDataManager.Check_Npoint_for_classify_5();
    local b6 = EquipDataManager.Check_Npoint_for_classify_6() and SystemManager.IsOpen(SystemConst.Id.EquipSuit);


    return b1 or b2 or b4 or b5 or b6;
end

--[[检查 装备栏 是否需要显示 红点提示
]]
function EquipDataManager.Check_Npoint(classify)

    -- 当某些原因(数据回包延时很厉害) 导致 在界面已经不存在的是，调用 Check_Npoint 并且 set_npoint==true  的时候 有报错
    -- 处理方式，检测 EquipMainPanel 是否正在打开， 如果不打开的时候 设置 set_npoint=false

    if classify == EquipNotes.classify_1 then
        -- 附灵
        EquipDataManager.Check_Npoint_for_classify_1();

    elseif classify == EquipNotes.classify_2 then
        -- 精炼
        EquipDataManager.Check_Npoint_for_classify_2()

    elseif classify == EquipNotes.classify_4 then
        -- 宝石
        EquipDataManager.Check_Npoint_for_classify_4();
    elseif classify == EquipNotes.classify_5 then
        -- 宝石
        EquipDataManager.Check_Npoint_for_classify_5();
    elseif classify == EquipNotes.classify_6 then
        -- 宝石
        EquipDataManager.Check_Npoint_for_classify_6();
    end


end
