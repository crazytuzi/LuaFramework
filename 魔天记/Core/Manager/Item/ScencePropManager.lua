
ScencePropManager = { };
ScencePropManager.cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SCENCE_PROP);

ScencePropManager.SCENCE_PROP_TYPE_1=1;-- 和场景一起出现


function ScencePropManager.GetCfData(id)
    return ScencePropManager.cf[id];
end


function ScencePropManager.GetItems(in_map_id, type)

    local res = { };
    local res_index = 1;

    for key, value in pairs(ScencePropManager.cf) do
        if value.type == type and value.in_map_id == in_map_id then
            res[res_index] = value;
            res_index = res_index + 1;
        end
    end

    return res;
end