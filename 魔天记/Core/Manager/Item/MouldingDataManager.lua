require "Core.Info.ProductInfo";
require "Core.Info.BaseAttrInfo"

-- 神器 数据 管理器

MouldingDataManager = { }
MouldingDataManager.hasInit = false;
MouldingDataManager.currSuit_id = 0;  -- 当前套装 属性 对应的配置 id
MouldingDataManager.ISSQ_QUALITY = 6;
MouldingDataManager.ISSQ_LV = 60;
MouldingDataManager.SQ_MAX_STAR = 10;

local _star_level_attrCf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STAR_LEVEL_ATTR)
local _moulding_itemCf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MOULDING_ITEM)
local _treasuretypeCf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TREASURETYPE)


function MouldingDataManager.Init()

    -- if not hasInit then
    MouldingDataManager.InitCf();
    --  end


end


function MouldingDataManager.InitCf()

    ----------------------------------------------------------------------------------------------
    local star_level_attr = { };

    for key, value in pairs(_star_level_attrCf) do

        local vkey = value.career .. "_" .. value.kind .. "_" .. value.moulding_lev;
        star_level_attr[vkey] = value;
    end

    MouldingDataManager.star_level_attr = star_level_attr;

    ---------------------------------------------------------------------------------------

    local _treasuretype = { };
    local _treasuretype_byId = { };
    for key, value in pairs(_treasuretypeCf) do

        local vkey = value.career .. "_" .. value.star .. "_" .. value.piece;
        _treasuretype[vkey] = value;

        local vkey1 = value.career .. "_" .. value.id;

        _treasuretype_byId[vkey1] = value;

    end
    MouldingDataManager.treasuretype = _treasuretype;
    MouldingDataManager.treasuretype_byId = _treasuretype_byId;

    --------------------------------------------------------

    local _moulding_item = { };
    for key, value in pairs(_moulding_itemCf) do

        local vkey = value.career .. "_" .. value.kind;
        _moulding_item[vkey] = value;
    end
    MouldingDataManager.moulding_item = _moulding_item;

    -----------------------------------------------------------


    hasInit = true;
end

--[[
单个神器属性

]]
function MouldingDataManager.Get_star_level_attr(career, kind, moulding_lev)
    local vkey = career .. "_" .. kind .. "_" .. moulding_lev;
    --  log("-- vkey "..vkey);
    local obj = MouldingDataManager.star_level_attr[vkey];
    return obj;
end

function MouldingDataManager.Get_moulding_item(career, kind)
    local vkey = career .. "_" .. kind;
    local obj = MouldingDataManager.moulding_item[vkey];
    return obj;
end

function MouldingDataManager.Get_treasuretype_attribute(career, star, piece)

    local vkey = career .. "_" .. star .. "_" .. piece;
    local obj = MouldingDataManager.treasuretype[vkey];
    return obj;

end

function MouldingDataManager.Get_treasuretype_attribute_byId(id, career)

    local vkey1 = career .. "_" .. id;
    local obj = MouldingDataManager.treasuretype_byId[vkey1];
    return obj;
end

function MouldingDataManager.GetEqNumByStar(_star)

    local rnum = 0;
    for i = 1, 8 do

        local eq = EquipDataManager.GetProductByKind(i);
        if eq ~= nil then
            local star = eq:GetStar();
            if star >= _star then
                rnum = rnum + 1;
            end
        end
    end

    return rnum;
end


-- 获取 在装备栏里面 对应 星级的 数量 , 如果没有的 star 属性的话， 那么 说明这个是普通装备
function MouldingDataManager.GetStarEqNum()

    local star_num = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    star_num[0] = 0;

    for i = 1, 8 do

        local eq = EquipDataManager.GetProductByKind(i);
        if eq ~= nil then
            local star = eq:GetStar();

            star_num[star] = star_num[star] + 1;

            for j = 1, 9 do
                local p_star = star - j;
                if p_star > 0 then
                    star_num[p_star] = star_num[p_star] + 1;
                end
            end
        end
    end
    return star_num;
end

function MouldingDataManager.GetAllEqAttribureNum()

    local allEqStarNum = EquipDataManager.GetStarEqNum();

    local res = nil;

    for i = 8, 1, -1 do
        if allEqStarNum[i] == num then

            if num == 3 or num == 5 or num == 8 then
                res = { star = i, eq_num = num };
            end
            -- -

        end
    end

    return res;
end


-- 获取所有神器属性累加
function MouldingDataManager.GetAllSqAtt()

    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();

    local res = { };

    local attkeys = BaseAttrInfo.GetAttKeys();
    local attkeys_num = table.getn(attkeys);
    ------------------------  首先 先 获取 神器套装属性 -----------------------------------------------
    local c_id = MouldingDataManager.currSuit_id;
    local att;
    if c_id > 0 then

        local suit_att = MouldingDataManager.Get_treasuretype_attribute_byId(c_id, my_career);
        for k = 1, attkeys_num do
            ProductInfo.TryAddAtt(res, attkeys[k], suit_att);
        end
    end

    -------------------------- 神器属性 -------------------------------------------------

    for i = 1, 8 do

        local info = EquipDataManager.GetProductByKind(i);
        if info ~= nil then

            local career = info:Get_career();
            local kind = info:GetKind();
            local star = info:GetStar();


            local sq_att = MouldingDataManager.Get_star_level_attr(career, kind, star);

            if sq_att ~= nil then
                for k = 1, attkeys_num do
                    ProductInfo.TryAddAtt(res, attkeys[k], sq_att);
                end
            end

        end

    end


    return res;

end