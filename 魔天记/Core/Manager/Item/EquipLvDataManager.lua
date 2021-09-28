EquipLvDataManager = { }

EquipDataManager.MESSAGE_EQUIP_EQUIP_LV_CHANGE = "MESSAGE_EQUIP_EQUIP_LV_CHANGE";

local equip_lv = nil;

--[[
"ext_equip_lv":[
{"idx":0,"bl":[{"exp":0,"lev":0,"attr_key":"mag_def"},{"exp":0,"lev":0,"attr_key":"mag_att"}]},
{"idx":1,"bl":[{"exp":0,"lev":0,"attr_key":"mag_def"},{"exp":0,"lev":0,"attr_key":"mag_att"}]}],
]]
local ext_equip_lv = { }; -- 仙兵锻造等级

-- equip_lv:[{idx 部位0开始,slv强化等级,sexp强化经验,rlv精炼等级, plv:强化（新）等级,plck:幸运值,plck_id:幸运值上限对应的id},..]
-- "equip_lv":[{"idx":0,"slv":1,"rlv":0,"sexp":0},{"idx":1,"slv":1,"rlv":0,"sexp":0},{"idx":2,"slv":1,"rlv":0,"sexp":0},{"idx":3,"slv":1,"rlv":0,"sexp":0},{"idx":4,"slv":1,"rlv":0,"sexp":0},{"idx":5,"slv":1,"rlv":0,"sexp":0},{"idx":6,"slv":1,"rlv":0,"sexp":0},{"idx":7,"slv":1,"rlv":0,"sexp":0}],

-- equip_lv:[{idx 部位0开始,slv强化等级,sexp强化经验,rlv精炼等级,gems:idx1,idx2,idx3,idx4(大于0：嵌入宝石ID，等于0：没有嵌入宝石，等于-1：还没有解锁位置),
-- plv:强化（新）等级,plck:幸运值,plck_id:幸运值上限对应的id,suit_id套装id,suit_lev套装等级},..]
function EquipLvDataManager.Init(data)
    equip_lv = { };


    for key, value in pairs(data) do

        local obj = { };
        obj.idx = value.idx + 1;
        obj.slv = value.slv;
        obj.rlv = value.rlv;
        obj.sexp = value.sexp;

        obj.suit_id = value.suit_id;
        obj.suit_lev = value.suit_lev;

        equip_lv[obj.idx] = obj;
    end

end

--[[
"ext_equip_lv":[{"idx":0,"bl":[{"exp":0,"lev":0,"attr_key":"mag_def"},{"exp":10,"lev":10,"attr_key":"mag_att"}]},
                {"idx":1,"bl":[{"exp":0,"lev":0,"attr_key":"phy_def"},{"exp":0,"lev":0,"attr_key":"hp_max"}]}],
]]
function EquipLvDataManager.Set_ext_equip_lv(_ext_equip_lv)

    ext_equip_lv = { };
    for key, value in pairs(_ext_equip_lv) do

        if value.idx == 0 then
            ext_equip_lv[EquipDataManager.KIND_XIANBING] = value.bl;
        elseif value.idx == 1 then
            ext_equip_lv[EquipDataManager.KIND_XUANBING] = value.bl;
        end

    end

end

function EquipLvDataManager.Set_ext_equip_lv_byIdx(idx, bl)

    if idx == 0 then
        ext_equip_lv[EquipDataManager.KIND_XIANBING] = bl;
    elseif idx == 1 then
        ext_equip_lv[EquipDataManager.KIND_XUANBING] = bl;
    end

end

-- {[attr_key:属性名，比如 phy_att),lev:等级,exp:经验]} 
function EquipLvDataManager.GetWiseEqAtt(att_key, kind)
    if ext_equip_lv[kind] ~= nil then
        for key, value in pairs(ext_equip_lv[kind]) do
            if value.attr_key == att_key then
                return value;
            end
        end
    end
    return nil;
end







function EquipLvDataManager.SetSuitLv(idx, suit_id, suit_lev)

    local tidx = idx + 1;
    if equip_lv[tidx] == nil then
        equip_lv[tidx] = { };
    end
    equip_lv[tidx].idx = tidx;
    equip_lv[tidx].suit_id = suit_id;
    equip_lv[tidx].suit_lev = suit_lev;

    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.EquipSuit)
    MessageManager.Dispatch(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE);

end

function EquipLvDataManager.GetNumForSuit_lev(suit_id, suit_lev)

    local res = 0;
    for key, value in pairs(equip_lv) do

        if tonumber(value.suit_id) == tonumber(suit_id) and tonumber(value.suit_lev) == tonumber(suit_lev) then
            res = res + 1;
        end
    end

    return res;
end

-- 3/5/8 件转变套装属性
function EquipLvDataManager.GetAllSuitAtt()
    local res = { };

    local suitlNum = { };

    for i = 1, 8 do
        local sqlvdata = EquipLvDataManager.getItem(i);

        if sqlvdata ~= nil then
            local suit_id = sqlvdata.suit_id;
            local suit_lev = sqlvdata.suit_lev;
            if suit_id ~= nil and suit_id ~= 0 and suit_lev ~= nil and suit_lev ~= 0 then
                local key = suit_id .. "_" .. suit_lev;

                if suitlNum[key] == nil then
                    suitlNum[key] = { suit_id = suit_id, suit_lev = suit_lev, value = 0 };
                end
                suitlNum[key].value = suitlNum[key].value + 1;
                -- 同一个套装属性id 和同一个等级  累计
            end
        end
    end

    local need_num1 = EquipSuitDataManager.attForSuitNums[1];
    local need_num2 = EquipSuitDataManager.attForSuitNums[2];
    local need_num3 = EquipSuitDataManager.attForSuitNums[3];

    local rnum = 0;

    local attkeys = BaseAdvanceAttrInfo.GetProperty();
    local attkeys_num = table.getn(attkeys);

    local hasSet3 = { };
    local hasSet2 = { };
    local hasSet1 = { };

    for key, value in pairs(suitlNum) do

        for i = 1, 3 do
            rnum = 0;
            local t_key = value.suit_id .. "_" .. value.suit_lev;
            if value.value >= need_num3 and not hasSet3[t_key] then
                rnum = need_num3;
                hasSet3[t_key] = true;
                EquipLvDataManager.CheckAndAddAtt(value, rnum, res, attkeys)
            end

            if value.value >= need_num2 and not hasSet2[t_key] then
                rnum = need_num2;
                hasSet2[t_key] = true;
                EquipLvDataManager.CheckAndAddAtt(value, rnum, res, attkeys)
            end

            if value.value >= need_num1 and not hasSet1[t_key] then
                rnum = need_num1;
                hasSet1[t_key] = true;
                EquipLvDataManager.CheckAndAddAtt(value, rnum, res, attkeys)
            end

        end

    end

    return res;

end


function EquipLvDataManager.CheckAndAddAtt(value, rnum, res, attkeys)

    if rnum > 0 then
        local attkeys_num = table.getn(attkeys);

        local key = value.suit_id .. "_" .. value.suit_lev .. "_" .. rnum;
        local suit_att = EquipSuitDataManager.GetSuitAttbutiByKey(key);
        for k = 1, attkeys_num do
            ProductInfo.TryAddAtt(res, attkeys[k], suit_att);
        end

    end

end


----  1 --- 8
function EquipLvDataManager.getItem(idx)
    return equip_lv[idx];
end

function EquipLvDataManager.GetEquip_lv()
    return equip_lv
end

-- idx 部位1开始,slv强化等级,sexp强化经验,rlv精炼等级
-- {"idx":0,"slv":1,"rlv":0,"sexp":0}
-- {"idx":0,"slv":1,"sexp":1}
--  S <-- 19:11:47.043, 0x040A, 44, {"idx":0,"rlv":1}
-- <-- 19:18:36.685, 0x0409, 29,    {"idx":0,"slv":1,"sexp":8}
function EquipLvDataManager.UpData(data)
    local idx = data.idx + 1;

    local res = equip_lv[idx];

    if data.slv ~= nil then
        res.slv = data.slv;
    end

    if data.sexp ~= nil then
        res.sexp = data.sexp;
    end

    if data.rlv ~= nil then
        res.rlv = data.rlv;
    end

    if data.suit_id ~= nil then
        res.suit_id = data.suit_id;
    end

    if data.suit_lev ~= nil then
        res.suit_lev = data.suit_lev;
    end



    MessageManager.Dispatch(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE);

end