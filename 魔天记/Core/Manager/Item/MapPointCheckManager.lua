MapPointCheckManager = { };
MapPointCheckManager.hasInit = false;

MapPointCheckManager.mapPoints = { };
MapPointCheckManager.cf = nil;

MapPointCheckManager.FUN_ONLMOUNT = "onLMount"; -- 上 地面载具
MapPointCheckManager.FUN_ONFMOUNT = "onFMount"; -- 上 飞行载具


function MapPointCheckManager.CheckInit()

    if not MapPointCheckManager.hasInit then

       MapPointCheckManager.cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP_POINT_CHECK);

        MapPointCheckManager.mapPoints = { };

        for key, value in pairs(MapPointCheckManager.cf) do

            local in_map_id = value.in_map_id;

            if MapPointCheckManager.mapPoints[in_map_id] == nil then
                MapPointCheckManager.mapPoints[in_map_id] = { };
            end

            local type = value.type;

            if type == 1 then
                -- 现在只有1 才会添加到场景
                local t_num = table.getn(MapPointCheckManager.mapPoints[in_map_id]);
                t_num = t_num + 1;

                MapPointCheckManager.mapPoints[in_map_id][t_num] = value;
            end;

        end

        MapPointCheckManager.hasInit = true;

    end

end


function MapPointCheckManager.GetPointsByMapId(map_id)

    MapPointCheckManager.CheckInit();
    map_id = map_id + 0;
    return MapPointCheckManager.mapPoints[map_id];

end

function MapPointCheckManager.GetPointsId(id)
 
  MapPointCheckManager.CheckInit();

  id = id.."";
  return  MapPointCheckManager.cf[id];
 
end