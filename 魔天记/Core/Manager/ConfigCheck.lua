ConfigCheck = { };


-- 检测 配置关联 
function ConfigCheck.StartCheck()

    ConfigCheck.Check_npc_to_fb_id();
    ConfigCheck.Check_Instance_to_map_id();
end


function ConfigCheck.Check_npc_to_fb_id()

    local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NPC);

    for key, value in pairs(config) do

        local func = value.func;

        local temp = string.split(func, "#");
        local func_s = temp[2];
        if func_s ~= nil then
            if string.sub(func_s, 1, 3) == "Nav" then
                local args = string.split(func_s, "_");
                local fb_id = tonumber(args[2]);
                local fb_cf = InstanceDataManager.GetMapCfById(fb_id);

                if fb_cf == nil then
                    Error("-------------- Config Error-------------- npc.lua error func bf_id " .. fb_id .. " not found----------------------");
                end
            end
        end

    end

end


-- 检查 instance配置表的 map_id 字段 在 map 配置表示是否存在
function ConfigCheck.Check_Instance_to_map_id()

    local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_INSTANCE);
    for key, value in pairs(config) do

        local map_id = value.map_id;
        local mapcf = ConfigManager.GetMapById(map_id);
         if mapcf == nil then
                    Error("-------------- Config Error-------------- instance.lua error  map_id " .. map_id .. " not found----------------------");
          end
    end

end