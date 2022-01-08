--[[
******游戏场景配置*******
]]
local SceneType = {}


SceneType.DEFAULT 		= "lua.logic.default.DefaultScene"
SceneType.LOGIN 		= "lua.logic.login.LoginScene"
SceneType.LOGINNOTICE 	= "lua.logic.login.LoginNoticeScene"
SceneType.CREATEPLAYER 	= "lua.logic.login.CreatePlayerScene"
SceneType.NOTE	 		= "lua.logic.note.NoteScene"
SceneType.HOME	 		= "lua.logic.home.HomeScene"
SceneType.MISSION		= "lua.logic.mission.MissionScene"
SceneType.ARMY	    	= "lua.logic.army.ArmyScene"
SceneType.FIGHT	    	= "lua.logic.fight.FightScene"
SceneType.FIGHTRESULT	= "lua.logic.fight.FightResultScene"
SceneType.THIRTYSIX		= "lua.logic.thirtysix.ThirtySixMainScene"
SceneType.ACTIVITY		= "lua.logic.activity.ActivityScene"
SceneType.BATTLE		= "lua.logic.battle.BattleScene"
SceneType.BATTLERESULT	= "lua.logic.battle.BattleResultScene"
SceneType.TESTBATTLE 		= "lua.logic.aabattle.AABattleScene"
return SceneType