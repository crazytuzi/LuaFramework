--[[
 条件 判断管理器
]]
 
ConditionDataManager = { };
ConditionDataManager.cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CONDITION); -- require "Core.Config.condition";


-- ['pass_conditions'] = {'1_80_0','2_180_0','5_0_0'},	--通关条件

-- 1_80_0
-- 通过 参数 获取 条件 文本描述
function ConditionDataManager.GetConditionMsg(id, p1, p2, use_minute)
   
    local res = LanguageMgr.Get("ConditionDataManager/none");

    id = id + 0;
    p1 = p1 + 0;


    local obj = ConditionDataManager.cf[id];

    if id == 1 then
        res = obj.name .. p1 .. "%";
    elseif id == 2 then
        if use_minute then
            res = obj.name .. GetTimeMinuteByStr(p1);
        else
            res = obj.name .. GetTimeByStr(p1);
        end

    elseif id == 5 then
        res = obj.name;

    elseif id == 17 then
        -- 17_125056_70
        local monster_cf = ConfigManager.GetMonById(tonumber(p1));
        res = monster_cf.name .. obj.name .. p2 .. "%";
    end

    return res;
end

