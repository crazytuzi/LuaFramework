local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local MapEntityFactory = Lplus.Class(CUR_CLASS_NAME)
local EntityBase = import(".EntityBase")
local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
local def = MapEntityFactory.define
local type2classname = {
  [MapEntityType.MET_FURNITURE] = "Furniture",
  [MapEntityType.MGT_SERVANT] = "HomelandServant",
  [MapEntityType.MGT_EXPLORE_CAT] = "ExplorerCat",
  [MapEntityType.MGT_HOME_LAND_BASIC_INFO] = "HomelandInfo",
  [MapEntityType.MGT_WORLD_GOAL_INFO] = "WorldGoalEntity",
  [MapEntityType.MGT_FLOOR_TILE] = "FloorTitle",
  [MapEntityType.MGT_WALLPAPER] = "Wallpaper",
  [MapEntityType.MET_CHILDREN] = "ChildEntity",
  [MapEntityType.MET_MYSTERY_VISITOR] = "MysteryVisitorEntity",
  [MapEntityType.MET_ANIMAL] = "PokemonEntity",
  [MapEntityType.MET_BARRIERS] = "CourtyardFenceEntity",
  [MapEntityType.MET_ROADS] = "CourtyardRoadEntity",
  [MapEntityType.MET_TERRAIN] = "CourtyardGroundEntity",
  [MapEntityType.MET_SINGLE_BATTLE_POSITION] = "TowerEntity",
  [MapEntityType.MET_SINGLE_BATTLE_GATHER_ITEM] = "GatherItemEntity",
  [MapEntityType.MET_SINGLE_BATTLE_BUFF] = "BattlefieldBuffEntity",
  [MapEntityType.MET_GOLD_STATUE] = "GoldStatueEntity",
  [MapEntityType.MET_FLOAT_PARADE] = "AnniversayParadeEntity",
  [MapEntityType.MET_CAKE_OVEN] = "CakeOvenEntity",
  [MapEntityType.MET_CHRISTMAS_STOCKING] = "ChristmasTreeEntity",
  [MapEntityType.MET_BALL_BATTLE_GROUND_ITEM] = "AagrGroundItemEntity"
}
local function create(className)
  local className = className or "EntityBase"
  local Class = import("." .. className, CUR_CLASS_NAME)
  local obj = Class()
  return obj
end
def.static("number", "userdata", "number", "table", "table", "=>", EntityBase).Create = function(entityType, instanceid, cfgid, locs, extra_info)
  local obj = create(type2classname[entityType])
  obj:Create(entityType, instanceid, cfgid, locs, extra_info)
  return obj
end
def.const("table").NOT_OWN_VIEW_MAP_ENTITY_TYPES = {
  [MapEntityType.MET_FURNITURE] = true,
  [MapEntityType.MGT_HOME_LAND_BASIC_INFO] = true,
  [MapEntityType.MGT_WORLD_GOAL_INFO] = true,
  [MapEntityType.MGT_FLOOR_TILE] = true,
  [MapEntityType.MGT_WALLPAPER] = true,
  [MapEntityType.MET_ANIMAL] = true,
  [MapEntityType.MET_BARRIERS] = true,
  [MapEntityType.MET_ROADS] = true,
  [MapEntityType.MET_TERRAIN] = true,
  [MapEntityType.MET_SINGLE_BATTLE_POSITION] = true,
  [MapEntityType.MET_SINGLE_BATTLE_GATHER_ITEM] = true,
  [MapEntityType.MET_SINGLE_BATTLE_BUFF] = true,
  [MapEntityType.MET_CAKE_OVEN] = true
}
return MapEntityFactory.Commit()
