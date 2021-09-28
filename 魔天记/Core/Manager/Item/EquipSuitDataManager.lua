
EquipSuitDataManager = { };

EquipSuitDataManager.suit_materials_cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SUIT_MATERIALS)
EquipSuitDataManager.suit_position_cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SUIT_POSITION)

EquipSuitDataManager.suit_materials_career = { };

-- 用于 检测拥有装备中是否可以有套装属性
EquipSuitDataManager.fitToSuitAttSpis = { };

EquipSuitDataManager.MAX_LEV = 2;

EquipSuitDataManager.SUIT_ATTRIBUTE_NUM = 3;

EquipSuitDataManager.SUIT_MAX_ATTRIBUTE = 4;

EquipSuitDataManager.NEED_MATERIALS_MAX_NUM = 2;

local sort = table.sort

EquipSuitDataManager.attForSuitNums = {
    [1] = 2,
    [2] = 5,
    [3] = 8,
};



function EquipSuitDataManager.CheckInit(career)

    career = tonumber(career);


    if EquipSuitDataManager.suit_materials_career[career] == nil then


        local suit_materialsList = { };
        local index = 1;

        for key, value in pairs(EquipSuitDataManager.suit_materials_cf) do
            if value.career == career then
                suit_materialsList[index] = value;
                index = index + 1;
                if EquipSuitDataManager.fitToSuitAttSpis[career] == nil then
                    EquipSuitDataManager.fitToSuitAttSpis[career] = { };
                end

                local suit_proid = value.suit_proid;
                for key1, value1 in pairs(suit_proid) do
                    EquipSuitDataManager.fitToSuitAttSpis[career][tonumber(value1)] = true;
                end
            end
        end

        sort(suit_materialsList, function(a, b) return a.suit_id < b.suit_id end);


        EquipSuitDataManager.suit_materials_career[career] = suit_materialsList;
    end
end


function EquipSuitDataManager.GetSuitAttbutiByKey(suit_key)
    return EquipSuitDataManager.suit_position_cf[suit_key];
end

function EquipSuitDataManager.GetSuitEqName(info, suit_lev, notSetCl)


    local quality = info:GetQuality();
    local name = ColorDataManager.GetColorTextByQuality(quality, info:GetName());
    if suit_lev > 0 then
        local sn = LanguageMgr.Get("EquipSuitDataManager/suit_names" .. suit_lev);

        if notSetCl == nil or not notSetCl then
            name = ColorDataManager.GetColorBySuit(suit_lev) .. sn .. "[-]" .. name;
        else
            name = sn .. info:GetName();
        end

    end
    return name;
end

function EquipSuitDataManager.GetSuitEqColorStr(str, suit_lev)
    return ColorDataManager.GetColorBySuit(suit_lev) .. str .. "[-]";
end

-- 检测是否可以有套装属性
function EquipSuitDataManager.IsCanBeSuitAtt(career, eq_spid)
    EquipSuitDataManager.CheckInit(career);

    if EquipSuitDataManager.fitToSuitAttSpis[tonumber(career)][tonumber(eq_spid)] ~= nil then
        return true;
    end
    return false;
end

function EquipSuitDataManager.GetfitToSuitAttSpis(career)
    EquipSuitDataManager.CheckInit(career);
    return EquipSuitDataManager.fitToSuitAttSpis[tonumber(career)];
end

function EquipSuitDataManager.Getsuit_materials_career(career)
    EquipSuitDataManager.CheckInit(career);
    return EquipSuitDataManager.suit_materials_career[tonumber(career)];
end


function EquipSuitDataManager.CheckKeys(suit_id, suit_lev, spid)


    if suit_id == 0 and spid ~= nil then
        --  如果  值非法的话， 那么需要自己找默认值了

        local my_info = HeroController:GetInstance().info;
        career = tonumber(my_info:GetCareer());
        local list = EquipSuitDataManager.Getsuit_materials_career(career);
        local t_num = table.getn(list);

        for i = 1, t_num do
            local obj = list[i];
            local suit_proid = obj.suit_proid;
            for key1, value1 in pairs(suit_proid) do
                if tonumber(spid) == tonumber(value1) then
                    return obj.suit_id, 1, spid;
                end
            end

        end

    end

    return suit_id, suit_lev, spid;

end

function EquipSuitDataManager.Get_suit_materials(suit_id, suit_lev, spid)


    local suit_id, suit_lev, spid = EquipSuitDataManager.CheckKeys(suit_id, suit_lev, spid);
    local key = suit_id .. "_" .. suit_lev;
    return EquipSuitDataManager.suit_materials_cf[key];

end


