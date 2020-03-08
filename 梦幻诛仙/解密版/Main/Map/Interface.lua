local MapInterface = {}
local MapUtility = require("Main.Map.MapUtility")
local MapModule = require("Main.Map.MapModule")
function MapInterface.GetMapCfg(mapID)
  return MapUtility.GetMapCfg(mapID)
end
function MapInterface.GetCurMapId()
  return MapModule.Instance():GetMapId()
end
function MapInterface.GetCurMapCfg()
  local mapid = MapInterface.GetCurMapId()
  return MapInterface.GetMapCfg(mapid)
end
function MapInterface.GetCurMapSize()
  if MapModule.Instance().scene == nil then
    return nil
  end
  return MapScene.GetMapSize(MapModule.Instance().scene)
end
return MapInterface
