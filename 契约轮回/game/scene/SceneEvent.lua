-- 
-- @Author: LaoY
-- @Date:   2018-07-27 14:42:57
-- 

SceneEvent = SceneEvent or {
	CreateMainRole 		= "SceneEvent.CreateMainRole",		--创建主角

	RequestMove 		= "SceneEvent.RequestMove",			--移动同步坐标
	RequestDest 		= "SceneEvent.RequestDest",			--移动同步路径
	RequestRush 		= "SceneEvent.RequestRush",			--冲刺
	RequestJump 		= "SceneEvent.RequestJump",			--跳跃
	RequestTalk 		= "SceneEvent.RequestTalk",			--场景怪物说话

	RequestChangeScene 	= "SceneEvent.RequestChangeScene",	--移动同步路径

	RequestTeleport 	= "SceneEvent.RequestTeleport",		--瞬移

	MainRolePos 		= "SceneEvent.MainRolePos",			--主角位置改变
	UpdateInfo 			= "SceneEvent.UpdateInfo",			--场景事件变化

	TouchBegin  		= "SceneEvent.TouchBegin",			--场景触摸事件
	TouchEnd 			= "SceneEvent.TouchEnd",			--场景触摸事件

    FIND_WAY_START 		= "SceneEvent.FIND_WAY_START",      --寻路开始
    FIND_WAY_END 		= "SceneEvent.FIND_WAY_END",        --寻路结束

    GAME_NOTIFY        = "SceneEvent.GameNotify",        --游戏通知

	ChangeMount 	= "SceneEvent.ChangeMount",				--坐骑改变

    MONSTER_HP_CHANGE = "SceneEvent.MonsterHpChange",       --怪物血量改变

    MONSTER_BELONG_CHANGE = "SceneEvent.MonsterBelongChange",       --怪物归属改变

    UPDATE_ACTOR_HP = "SceneEvent.UpdateActorHp",           --改变血量

    KILL_MONSTER = "SceneEvent.KILL_MONSTER",           --改变血量

    MainRoleMachineStateUpdate = "SceneEvent.MainRoleMachineStateUpdate",
}