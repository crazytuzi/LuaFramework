
require "Core.Manager.Item.ProductsContainer";

BackpackDataManager = { };
BackpackDataManager.container = ProductsContainer:New();
BackpackDataManager._bsize = 0;
BackpackDataManager.FREEBAGNUM = 40;

--  event for BackpackDataManager
BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE = "MESSAGE_BAG_PRODUCTS_CHANGE";
local _sortfunc = table.sort 
 
function BackpackDataManager.Init(data_arr, bsize)

    BackpackDataManager._bsize = bsize;
    BackpackDataManager.Reset(data_arr);
end

function BackpackDataManager.Reset(data_arr)
    if data_arr == nil then
        data_arr = { };
    end

    BackpackDataManager.container:InitDatas(data_arr, "idx");
    BackpackDataManager.DispatchEvent();
end


function BackpackDataManager.TryAllStrengthen()


    if AutoFightManager.strengthen_eq_kind ~= nil then

        local my_info = HeroController:GetInstance().info;
        local my_career = my_info:GetCareer();

        local res = { };
        local res_index = 1;
        local b = false;
        ----------------------------------strengthen_eq_quality1----------------------------------------
        if AutoFightManager.strengthen_eq_quality1 then
            local list = BackpackDataManager.GetProductsByTypes3(1, 0, true);
            local t_num = table.getn(list);
            for i = 1, t_num do
                b = BackpackDataManager.CheckHasBetterFight(list[i]);

                if not b then
                    res[res_index] = list[i];
                    res_index = res_index + 1;

                elseif list[i].configData.career ~= my_career then
                    res[res_index] = list[i];
                    res_index = res_index + 1;
                end


            end
        end

        -------------------------------------strengthen_eq_quality2-------------------------------------
        if AutoFightManager.strengthen_eq_quality2 then
            local list = BackpackDataManager.GetProductsByTypes3(1, 1, true);
            local t_num = table.getn(list);
            for i = 1, t_num do
                b = BackpackDataManager.CheckHasBetterFight(list[i]);
                if not b then
                    res[res_index] = list[i];
                    res_index = res_index + 1;

                elseif list[i].configData.career ~= my_career then
                    res[res_index] = list[i];
                    res_index = res_index + 1;
                end
            end
        end

        -------------------------------------strengthen_eq_quality3-------------------------------------
        if AutoFightManager.strengthen_eq_quality3 then
            local list = BackpackDataManager.GetProductsByTypes3(1, 2, true);
            local t_num = table.getn(list);
            for i = 1, t_num do
                b = BackpackDataManager.CheckHasBetterFight(list[i]);
                if not b then
                    res[res_index] = list[i];
                    res_index = res_index + 1;

                elseif list[i].configData.career ~= my_career then
                    res[res_index] = list[i];
                    res_index = res_index + 1;
                end
            end
        end

        -------------------------------------strengthen_eq_quality4-------------------------------------

        if AutoFightManager.strengthen_eq_quality4 then
            local list = BackpackDataManager.GetProductsByTypes3(1, 3, true);
            local t_num = table.getn(list);
            for i = 1, t_num do
                b = BackpackDataManager.CheckHasBetterFight(list[i]);
                if not b then
                    res[res_index] = list[i];
                    res_index = res_index + 1;

                elseif list[i].configData.career ~= my_career then
                    res[res_index] = list[i];
                    res_index = res_index + 1;
                end
            end
        end


        --------------------------------------------------------------------

        local len = table.getn(res);
        local can_st_num = 5;
        -- 可以自动强化的 边界值

        if len >= can_st_num then

            local sendData = { };
            sendData.idx = AutoFightManager.strengthen_eq_kind - 1;
            sendData.items = { };
            sendData.amounts = { };

            for i = 1, len do
                local info = res[i];
                local id = info:GetId();

                sendData.items[i] = id;
                sendData.amounts[i] = 1;
            end

            EquipProxy.TryEquipStrong(sendData);

        end

    end
end



---------------------------  检测并 自动强化 装备 ------------------------------------
--[[
  如果 自动强化 现在 品质 数量 >=5 那么就自动强化

]]
function BackpackDataManager.CheckAndStrengthen()


    -- 只有在 自动战斗的时候才会 出发 自动合成
    local ins = HeroController:GetInstance();

    if ins ~= nil then

        local isAuto = ins:IsAutoFight() or ins:IsAutoKill();
        if isAuto then
            BackpackDataManager.TryAllStrengthen();
        end

    end


end

------------------------------------------------------------

function BackpackDataManager.DispatchEvent()

    BackpackDataManager.CheckAndStrengthen();
    MessageManager.Dispatch(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE);
end

function BackpackDataManager.ResetSize(size)
    BackpackDataManager._bsize = size;
    BackpackDataManager.DispatchEvent();
end


function BackpackDataManager.GetProductNum()
    return BackpackDataManager.container:GetItemNum();
end

function BackpackDataManager.GetBagSize()
    return BackpackDataManager._bsize;
end

-- 获取 背包中 一共开锁了多少个格子
function BackpackDataManager.GetTotalUnLockBagBoxNum()
    return BackpackDataManager._bsize - BackpackDataManager.FREEBAGNUM;
end

function BackpackDataManager.GetProperty()
    return { hp_max = BackpackDataManager.GetTotalUnLockBagBoxNum() * 20 }
end

-- key -- > idx
--  byList  如果为 true  以数组信息 返回数据
function BackpackDataManager.GetAllProducts(byList)

    local listMap = BackpackDataManager.container:GetItem();
    if byList then

        local res = { };
        local res_index = 1;
        for key, value in pairs(listMap) do
            res[res_index] = value;
            res_index = res_index + 1;
        end
        return res;
    end

    return listMap;
end




-- 获取适合  装备属性转移 的 装备
-- 条件  quality >= 4   and  lev>=60
--  需要进行 排序 
--[[
正确排序规则：
1、优先显示神器，之后显示其他金色装备   ()
2、神器排序规则：
  a) 优先按照装备星级从高到低进行排序；装备星级相同，按照装备部位进行排序
  b) 装备部位排序规则：武器>项链>戒指>护手>头盔>衣服>裤子>鞋子
3、金色装备排序规则：
  a) 优先按照装备等级从高到低进行排序；装备等级相同，按照装备部位进行排序
  b) 装备部位排序规则：武器>项链>戒指>护手>头盔>衣服>裤子>鞋子
]]
function BackpackDataManager.GetFitForZYEqs()
    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();
    local eqs = BackpackDataManager.GetProductsByTypes( { 1 });

    local res = { };
    local res_index = 1;

    for key, value in pairs(eqs) do
        local lev = value:GetReq_lev();
        local career = value:GetCareer();
        local quality = value:GetQuality();

        if quality >= 4 and career == my_career and lev >= 60 then
            res[res_index] = value;
            res_index = res_index + 1;
        end
    end

    _sortfunc(res, function(a, b)

        local a_quality = a:GetQuality();
        local b_quality = b:GetQuality();

        local a_star = a:GetStar();
        local b_star = b:GetStar();

        local a_lev = a:GetReq_lev();
        local b_lev = b:GetReq_lev();

        local a_kind = 10 - a:GetKind();
        local b_kind = 10 - b:GetKind();

        local priority =(a_quality - b_quality) * 1000 +(a_star - b_star) * 100 +(a_lev - b_lev) * 10 +(a_kind - b_kind)
        if (priority > 0) then
            return true
        else
            return false
        end
    end );

    return res;
end

function BackpackDataManager.GetProductsByTypes(types)

    local t_num = table.getn(types);
    local res = { };
    local res_index = 1;

    local proudcts = BackpackDataManager.GetAllProducts(false);

    for key, value in pairs(proudcts) do
        local pType = value:GetType();

        for j = 1, t_num do
            if pType == types[j] then
                res[res_index] = value;
                res_index = res_index + 1;
            end
            -- end if
        end

    end


    return res;
end

-- isfilter_WiseEquip  是否 过滤仙器 
function BackpackDataManager.GetProductsByTypes3(type, quality, isfilter_WiseEquip, career)
    local res = { };
    local res_index = 1;

    local items = BackpackDataManager.GetProductsByTypes( { [1] = type });

    if items ~= nil then
        for key, value in pairs(items) do
            if value:GetQuality() == quality then
                if isfilter_WiseEquip then
                    local kind = value:GetKind();
                    if kind ~= EquipDataManager.KIND_XIANBING and kind ~= EquipDataManager.KIND_XUANBING then
                        res[res_index] = value;
                        res_index = res_index + 1;
                    end

                else
                    if career ~= nil then
                        if value.configData.career == career or value.configData.career == 0 then
                            res[res_index] = value;
                            res_index = res_index + 1;
                        end
                    else
                        res[res_index] = value;
                        res_index = res_index + 1;
                    end

                end


            end
        end
    end

    return res;

end

function BackpackDataManager.GetProductsByTypes2(type, kind)

    local res = { };
    local res_index = 1;

    local items = BackpackDataManager.GetProductsByTypes( { [1] = type });

    if items ~= nil then
        for key, value in pairs(items) do
            if value.kind == kind then
                res[res_index] = value;
                res_index = res_index + 1;
            end
        end
    end

    return res;

end

function BackpackDataManager.GetProductsByTypes2k(type, kind1, kind2)

    local res = { };
    local res_index = 1;

    local items = BackpackDataManager.GetProductsByTypes( { [1] = type });

    if items ~= nil then
        for key, value in pairs(items) do
            if value.kind == kind1 or value.kind == kind2 then
                res[res_index] = value;
                res_index = res_index + 1;
            end
        end
    end

    return res;

end

local insert = table.insert;

-- 获取所有没有鉴定的 装备
function BackpackDataManager.GetAllUnJDWiseEquip()

    local my_info = HeroController:GetInstance().info;
    local my_level = my_info.level;
    local my_career = my_info:GetCareer();

    local xianb_eqs = BackpackDataManager.GetProductsByTypeAndKind(ProductManager.type_1, EquipDataManager.KIND_XIANBING, my_career);
    local xuanb_eqs = BackpackDataManager.GetProductsByTypeAndKind(ProductManager.type_1, EquipDataManager.KIND_XUANBING, my_career);

    local res = { };
    for key, value in pairs(xianb_eqs) do
        local info = value;
        local req_lev = info:GetReq_lev();
        local hasJD = info:IsHasFairyGroove();
        if my_level >= req_lev and not hasJD then
            insert(res, value);
        end
    end

    for key, value in pairs(xuanb_eqs) do
        local info = value;
        local req_lev = info:GetReq_lev();
        local hasJD = info:IsHasFairyGroove();
        if my_level >= req_lev and not hasJD then
            insert(res, value);
        end
    end

    return res;
end

-- 获取一些 适合自己装的装备
function BackpackDataManager.GetFixMyEqByTypeAndKind(type, kind, career)

    local my_info = HeroController:GetInstance().info;
    local my_level = my_info.level;

    local eqs = BackpackDataManager.GetProductsByTypeAndKind(type, kind, career);
    local res_Arr = { };
    local index = 1;

    local len = table.getn(eqs);
    for i = 1, len do
        local info = eqs[i];
        local req_lev = info:GetReq_lev();
        if my_level >= req_lev then
            res_Arr[index] = info;
            index = index + 1;
        end
    end

    return res_Arr;
end

function BackpackDataManager.GetProductsByType(type, career, needLv)

    local res = { };
    local res_index = 1;

    local items = BackpackDataManager.GetProductsByTypes( { [1] = type });
    if items ~= nil then
        for key, value in pairs(items) do

            if value.configData.career == career or value.configData.career == 0 then
                if needLv == nil or(needLv ~= nil and needLv >= value.configData.req_lev) then
                    res[res_index] = value;
                    res_index = res_index + 1;
                end
            end
        end
    end

    return res;

end

function BackpackDataManager.GetProductsByTypeAndKind(type, kind, career)

    local res = { };
    local res_index = 1;

    local items = BackpackDataManager.GetProductsByTypes( { [1] = type });
    if items ~= nil then
        for key, value in pairs(items) do

            if value.kind == kind and(value.configData.career == career or value.configData.career == 0) then
                res[res_index] = value;
                res_index = res_index + 1;
            end
        end
    end

    return res;

end

--[[

   ]]
function BackpackDataManager.GetIntensifyMaterialsBySort(bag_equips)

    _sortfunc(bag_equips, function(a, b)

        local a_type = a:GetType();
        local b_type = b:GetType();

        local a_lev = a:GetLevel();
        local b_lev = b:GetLevel();

        local a_quality = a:GetQuality();
        local b_quality = b:GetQuality();

        local a_kind = a:GetKind();
        local b_kind = b:GetKind();

        if a_type == 3 then
            a_lev = 0;
            a_kind = 0;
        end

        if b_type == 3 then
            b_lev = 0;
            b_kind = 0;
        end
        --[[
        原来
        1 物品类型   附灵石 -> 装备
        2 同类型物品  等级 从高到底
        3 同类型物品  同等级 品质从高到底
        4 同类型物品  同等级 同品质   kind从高到底

       改为

        1 物品类型   附灵石 -> 装备
        2 同类型物品  等级 从底到高
        3 同类型物品  同等级 品质从底到高
        4 同类型物品  同等级 同品质   kind从高到底

       ]]

        --  local priority =(a_type - b_type) * 1000000 +(a_lev - b_lev) * 10000 +(a_quality - b_quality) * 100 +(a_kind - b_kind)
        local priority =(a_type - b_type) * 1000000 +(b_lev - a_lev) * 10000 +(b_quality - a_quality) * 100 +(a_kind - b_kind)

        if (priority > 0) then
            return true
        else
            return false
        end
    end
    )

    return bag_equips;


end


function BackpackDataManager.GetMaterialsBySort()
    local intensifyMaterials = BackpackDataManager.GetIntensifyMaterial();
    intensifyMaterials = BackpackDataManager.GetIntensifyMaterialsBySort(intensifyMaterials);
    return intensifyMaterials;
end

--  获取强化材料  type==1  ||  type==3 & kind == 1
--[[
 需要进行排序，先装备，品质， 然后 到材料 品质
]]
function BackpackDataManager.GetIntensifyMaterial()

    local res = { };
    local res_index = 1;

    local items = BackpackDataManager.GetProductsByTypes( { [1] = 1, [2] = 3 });

    if items ~= nil then
        for key, value in pairs(items) do

            local quality = value:GetQuality();
            local kind = value:GetKind();

            -- if quality < 5
            -- (ty==1 and kind ~= 9 and kind ~= 10) 额外装备过滤
            if quality <= 6 then
                -- http://192.168.0.8:3000/issues/2992
                -- 品质为5的也可以添加
                -- 材料 quality >4 的都需要过滤
                if value:GetType() == 1 then
                    if kind ~= 9 and kind ~= 10 then
                        res[res_index] = value;
                        res_index = res_index + 1;
                    end

                elseif value:GetType() == 3 and value:GetKind() == 1 then
                    res[res_index] = value;
                    res_index = res_index + 1;
                end
            end
        end
    end

    return res;

end

function BackpackDataManager.GetQualityNumInList(list, s_quality)


    local res = 0;
    for key, value in pairs(list) do
        local quality = value:GetQuality();
        if s_quality == quality then
            res = res + value:GetAm();
        end
    end

    return res;
end

function BackpackDataManager.GetProductById(id)
    local obj = BackpackDataManager.container:FindByAttKey("id", id);
    return obj;
end


function BackpackDataManager.GetProductBySpid(spId)
    local obj = BackpackDataManager.container:FindByAttKey("spId", spId);
    return obj;
end

function BackpackDataManager.GetProductTotalNumBySpid(spId)
    local total_num = BackpackDataManager.container:FindTotalNumByKey("spId", tonumber(spId));
    return total_num;
end

-- 获取不是神器的物品
function BackpackDataManager.GetProductTotalNumBySpidNotSQ(spId)
    local total_num = 0;

    local list = BackpackDataManager.GetAllProducts(true);
    local t_num = table.getn(list);

    for i = 1, t_num do
        local obj = list[i];
        local am = obj:GetAm()
        if tonumber(obj.spId) == tonumber(spId) then
            total_num = total_num + am;
        end
    end

    return total_num;
end

function BackpackDataManager.GetFreeIdx()

    local idx = 0;
    for i = 1, BackpackDataManager._bsize do
        local info = BackpackDataManager.container:GetByKey(idx);
        if info == nil then
            return idx;
        end
        idx = idx + 1;
    end
    return -1;
end

function BackpackDataManager.GetProductByIdx(idx)


    local obj = BackpackDataManager.container:GetByKey(tonumber(idx));
    return obj;
end


function BackpackDataManager.SetProductByIdx(info, idx)
    BackpackDataManager.container:SetBykey(info, idx);
    BackpackDataManager.DispatchEvent();
end


-- {"m":[{"st":2,"pt":"10100103","id":"1057","idx":1},{"st":1,"pt":"10100103","id":"0","idx":23}]}
function BackpackDataManager.ProductChange(data)

    local a = data.a;
    local u = data.u;

    local b = false;

    if a ~= nil then
        BackpackDataManager.AddProduct(a);
        b = true;
    end

    if u ~= nil then
        BackpackDataManager.UpDataProduct(u);
        b = true;
    end

    -- 如果有宝石发生改变, 重新更新背包宝石数据
    if (GemDataManager.gemChg) then
        GemDataManager.UpdateBag();
    end

    if b then
        BackpackDataManager.DispatchEvent();
    end
end

function BackpackDataManager:Replace(other_container, other_data, self_data)
    BackpackDataManager.container:Replace(other_container, other_data, self_data);
end

function BackpackDataManager.GetContainer()
    return BackpackDataManager.container;
end

function BackpackDataManager.AddProduct(arr)
    local t_num = table.getn(arr);

    for i = 1, t_num do
        local obj = arr[i];
        if obj.st == ProductManager.ST_TYPE_IN_BACKPACK then
            local idx = obj.idx;
            BackpackDataManager.container:SetBykey(obj, idx);
        end

        if obj.spId == 508000 then
            -- 获得vip试用卡, 弹出VIP试用面板
            ModuleManager.SendNotification(VipTryNotes.OPEN_VIP_TRY_PANEL, { s = 1, id = obj.spId })
        end

        ItemMoveManager.Check(ItemMoveManager.interface_ids.getProAndMoveToBt, obj)


    end

    ConvenientUseControll.GetIns():AddProductAndCheck(arr);
end

-- {"u":[{"st":1,"pt":"10100103","id":"1070","am":0,"idx":0}]}
function BackpackDataManager.UpDataProduct(arr)

    local addList = { };

    local t_num = table.getn(arr);
    for i = 1, t_num do
        local obj = arr[i];
        local idx = obj.idx;
        if obj.st == ProductManager.ST_TYPE_IN_BACKPACK then

            if obj.am == 0 then
                BackpackDataManager.container:SetBykey(nil, idx);
            else
                local res = BackpackDataManager.GetProductByIdx(idx);
                local isAdd = false;
                if res.am < obj.am then
                    --  说明是添加 数量
                    isAdd = true;
                end

                res.fm = obj.fm;
                res.am = obj.am;
                res.idx = obj.idx;

                if obj.bind ~= nil then
                 res.bind = obj.bind;
                end 

                if isAdd then
                    table.insert(addList, res);
                end
            end

        elseif obj.st == ProductManager.ST_TYPE_IN_EXT_EQUIP then
            -- 在仙器装备栏容器上

            local res = EquipDataManager.GetExtEquip(idx);

            res.fm = obj.fm;
            res.am = obj.am;
            res.idx = obj.idx;

        end
    end

    if table.getCount(addList) > 0 then
        ConvenientUseControll.GetIns():AddProductAndCheck(addList);

    end


end 

-- baseData

function BackpackDataManager.UpDataProductBaseData(baseData)

    if baseData.st == ProductManager.ST_TYPE_IN_BACKPACK then
        local res = BackpackDataManager.GetProductByIdx(baseData.idx);
        res:Init(baseData);
        BackpackDataManager.DispatchEvent();
    end

end 

function BackpackDataManager.CheckHasBetterFight(bagItem)
    if bagItem ~= nil then

        local kind = bagItem:GetKind();
        local eqbagInfo = EquipDataManager.GetProductByKind(kind);
        if eqbagInfo == nil then
            return true;
        else
            -- 对应装备栏里的总 战斗力
            local eq_bag_fight = eqbagInfo:GetFight();
            -- 背包中的 属性
            local bag_fight = bagItem:GetFight();

            if bag_fight > eq_bag_fight then
                return true;
            end
        end

    end

    return false;
end

-- http://192.168.0.8:3000/issues/7619
function BackpackDataManager.NeedShowBagMainPoint()

    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();
    local my_lv = my_info.level;

    local bagEqs = BackpackDataManager.GetProductsByType(ProductManager.type_1, my_career, my_lv);
    local t_num = table.getn(bagEqs);

    for i = 1, t_num do
        local bagItem = bagEqs[i];

        local b = BackpackDataManager.CheckHasBetterFight(bagItem);
        if b then
            return true;
        end
    end

    return false;
end 

-- endregion
