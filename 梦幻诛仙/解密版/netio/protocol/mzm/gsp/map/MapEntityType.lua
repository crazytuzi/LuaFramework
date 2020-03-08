local OctetsStream = require("netio.OctetsStream")
local MapEntityType = class("MapEntityType")
MapEntityType.MET_FURNITURE = 0
MapEntityType.MGT_SERVANT = 1
MapEntityType.MGT_EXPLORE_CAT = 2
MapEntityType.MGT_HOME_LAND_BASIC_INFO = 3
MapEntityType.MGT_WORLD_GOAL_INFO = 4
MapEntityType.MGT_FLOOR_TILE = 5
MapEntityType.MGT_WALLPAPER = 6
MapEntityType.MET_CHILDREN = 7
MapEntityType.MET_ANIMAL = 8
MapEntityType.MET_MYSTERY_VISITOR = 9
MapEntityType.MET_BARRIERS = 10
MapEntityType.MET_ROADS = 11
MapEntityType.MET_TERRAIN = 12
MapEntityType.MET_SINGLE_BATTLE_POSITION = 13
MapEntityType.MET_SINGLE_BATTLE_GATHER_ITEM = 14
MapEntityType.MET_SINGLE_BATTLE_BUFF = 15
MapEntityType.MET_GOLD_STATUE = 16
MapEntityType.MET_FLOAT_PARADE = 17
MapEntityType.MET_CAKE_OVEN = 18
MapEntityType.MET_CHRISTMAS_STOCKING = 19
MapEntityType.MET_BALL_BATTLE_GROUND_ITEM = 20
function MapEntityType:ctor()
end
function MapEntityType:marshal(os)
end
function MapEntityType:unmarshal(os)
end
return MapEntityType
