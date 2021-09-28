-- FileName: FightHead.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: 战斗所使用yin
--[[TODO List]]

module("FightHead", package.seeall)

require "script/fight/FightDef"
require "script/fight/FightMainLoop"
require "script/fight/entity/FightHeroEntity"

require "script/fight/model/FightModel"
require "script/fight/model/FightStrModel"

require "script/fight/node/CardSprite"
require "script/fight/node/FightBgSprite"
require "script/fight/node/EnemyCardNode"
require "script/fight/node/PlayerCardNode"
require "script/fight/node/TeamNode"
require "script/fight/node/FightCraftNode"
require "script/fight/node/FightUILayer"

require "script/fight/action/FightAtkAction"
require "script/fight/action/FightBufferAction"
require "script/fight/action/FightDefAction"
require "script/fight/action/FightCardAction"
require "script/fight/action/FightPetAction"
require "script/fight/action/FightCardStatus"
require "script/fight/action/FightSceneAction"

require "script/fight/service/ACopyFightService"
require "script/fight/service/ECopyFightService"
require "script/fight/service/HCopyFightService"
require "script/fight/service/NCopyFightService"
require "script/fight/service/TowerFightService"

require "script/fight/FightController"

require "script/fight/util/FightUtil"
require "script/fight/util/FightDBUtil"

require "script/fight/test/FightTest"

require "script/utils/BTNumerLabel"
require "script/animation/XMLActionSprite"

require "script/battle/BT_Skill"
require "db/DB_Team"
require "db/DB_Monsters_tmpl"
require "db/DB_Monsters"
require "db/DB_Buffer"
require "db/DB_Method"
require "db/DB_Army"
