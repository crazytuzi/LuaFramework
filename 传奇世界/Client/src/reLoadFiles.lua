local reload_files = {
    "src/base/PropDef",
    "src/layers/beautyWoman/RoleAndBeautyLayer",
    "src/layers/skill/SkillsLayer",
    --"src/layers/friend/FriendsLayer",
    "src/layers/faction/FactionLayer",
    "src/layers/faction/FactionListLayer",
    "src/layers/bag/BagView",
    "src/layers/shop/shopLayer",
    "src/layers/setting/SettingLayer",
    "src/layers/mission/MissionLayer",    
    --"src/layers/fb/FBHallView",
    "src/layers/newFunction/NewFunctionDefine",
    "src/layers/chat/Chat",
    "src/config/CommDef",  
}

for k,v in pairs(reload_files)do 
    require(v)
end
require "src/layers/bag/PackManager"

require("src/base/ActionState")
require("src/layers/skyArena/skyArenaMsgHandler")
require("src/layers/exerciseRoom/ExerciseRoomMsgHandler")


function globalDataInit()
    require("src/layers/random_versus/versus_net"):on_logout()

    require("src/layers/battle/BattleListData"):init()
    require("src/layers/activity/ActivityData"):__init()

    require("src/functional/CombatPowerUp"):nolisten()
    local MPackManager = require "src/layers/bag/PackManager"
    MPackManager:updateDressPack(true, nil)

    local MRoleStruct = require("src/layers/role/RoleStruct")
    MRoleStruct:leadingRoleSwitchScene()
    require("src/layers/bag/PropGuide")
    require("src/layers/pkmode/PkModeLayer"):setCurMode(0)
    -- 关闭寄售
    local MConsignOp = require "src/layers/consign/ConsignOp"
    MConsignOp:closeConsign()

    -- 新屠龙传说
    require("src/layers/DragonSliayer/DragonData")
    DragonData:Init();
    -- 新3V3
    require("src/layers/VS/VSDataManager")
    VSDataManager:Init();

    DirtyWords:Init();

    require "src/young/animation"
    require "src/young/util/stack"
    require "src/layers/tuto/TutoDefine"
    require "src/layers/bag/PackManager"

     --模块控制
    require("src/layers/control/ControlDefine")
    require("src/layers/control/ControlData")
    if G_CONTROL then G_CONTROL:init() end      --重置模块控制
    
    -- 清除数据
    if TMP_G_SKILLPROP_POS and TMP_G_SKILLPROP_POS.keys then
        TMP_G_SKILLPROP_POS.keys = nil;
    end
end