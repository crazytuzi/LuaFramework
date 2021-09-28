FarmsDataManager = { }


FarmsDataManager.farmsConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FARM_PLANT); --require "Core.Config.farm_plant"
FarmsDataManager.farmsBaseConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FARM_BASE); --require "Core.Config.farm_base"

FarmsDataManager.farm_guardConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FARM_GUARD); --require "Core.Config.farm_guard"
FarmsDataManager.farm_stealConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FARM_STEAL); --require "Core.Config.farm_steal"

FarmsDataManager.farm_farm_levelConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FARM_LEVEL); --require "Core.Config.farm_level"

FarmsDataManager.farm_guard = nil;

FarmsDataManager.farms = { };

FarmsDataManager.MESSAGE_FARMS_DATA_CHANGE = "MESSAGE_FARMS_DATA_CHANGE";

FarmsDataManager.sts = nil;
FarmsDataManager.wt = nil;

FarmsDataManager.jiaoshuiElseTime = 0;
FarmsDataManager.touyaoElseTime = 0;

function FarmsDataManager.InitData(data)

    FarmsDataManager.farms = data;

    MessageManager.Dispatch(FarmsDataManager, FarmsDataManager.MESSAGE_FARMS_DATA_CHANGE);
end

-- 是否有成熟 的植物
function FarmsDataManager.IfHasChengshu()

    local farms = FarmsDataManager.farms.farms;
    local t_num = table.getn(farms);
    for i = 1, t_num do

        if farms[i].gt == 0 and  farms[i].s ~= "" then
            return true;
        end
    end

    return false;
end


function FarmsDataManager.GetMy_pf()
    return FarmsDataManager.farms.pf;
end

function FarmsDataManager.SetMyExp(v)
    FarmsDataManager.farms.pf.exp = v;
end

function FarmsDataManager.GetFarmMaxExp(lv)
    local obj = FarmsDataManager.farm_farm_levelConfig[lv];
    return obj.up_exp;
end


function FarmsDataManager.GetCfBySeed_id(seed_id)
    return FarmsDataManager.farmsConfig[seed_id + 0];
end


function FarmsDataManager.GetFarmBaseConfig()
    return FarmsDataManager.farmsBaseConfig[1];
end


function FarmsDataManager.GetFarm_guard(key1, key2)

    if FarmsDataManager.farm_guard == nil then
        FarmsDataManager.farm_guard = { };

        for i = 1, 5 do
            local obj = FarmsDataManager.farm_guardConfig[i];

            FarmsDataManager.farm_guard[i .. "_1"] = { value = obj.gold, name = obj.gold_des };
            FarmsDataManager.farm_guard[i .. "_2"] = { value = obj.wood, name = obj.wood_des };
            FarmsDataManager.farm_guard[i .. "_3"] = { value = obj.water, name = obj.water_des };
            FarmsDataManager.farm_guard[i .. "_4"] = { value = obj.fire, name = obj.fire_des };
            FarmsDataManager.farm_guard[i .. "_5"] = { value = obj.soil, name = obj.soil_des };

        end

    end

    local key = key1 .. "_" .. key2;
    return FarmsDataManager.farm_guard[key];
end

--[[
		['id'] = 1,	--阶段id
		['min_per'] = 0,	--最小百分值
		['max_per'] = 30,	--最大百分值
		['des'] = '[ff4b4b]低[-]',	--成功率描述
]]

function FarmsDataManager:GetDesByPc(pc)

    local list = FarmsDataManager.farm_stealConfig;
    local t_num = table.getn(list);

    for i = 1, t_num do
        local obj = list[i];

        if obj.min_per <= pc and obj.max_per >= pc then
            return obj.des;
        end

    end

    return ""..pc;

end