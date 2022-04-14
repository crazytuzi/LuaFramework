-- 
-- @Author: LaoY
-- @Date:   2018-08-15 20:50:01
-- 


FightEvent = FightEvent or {
	AutoFight 		= "FightEvent.AutoFight",		--自动战斗切换
	StartAutoFight 	= "FightEvent.StartAutoFight",	--自动战斗切换
	StopAutoFight 	= "FightEvent.StopAutoFight",	--自动战斗切换
	TemAutoFight 	= "FightEvent.TemAutoFight",	--自动战斗切换

	StartPickUp		= "FightEvent.StartPickUp",		--采集相关
	EndPickUp		= "FightEvent.EndPickUp",		--
	UpdatePickUp	= "FightEvent.UpdatePickUp",	


	Revive 			= "FightEvent.Revive",			--复活
	ReqPKMode 		= "FightEvent.ReqPKMode",		--请求切换pk模式
	AccPKMode 		= "FightEvent.AccPKMode",		--收到切换pk模式

	ReqCollect 		= "FightEvent.ReqCollect",		--请求采集
	AccCollect 		= "FightEvent.AccCollect",		--收到采集

	ReqPickUp 		= "FightEvent.ReqPickUp",		--请求拾取
	AccPickUp 		= "FightEvent.AccPickUp",		--收到拾取

	ReqAutoPickUp = "FightEvent.ReqAutoPickUp",      --请求自动拾取
	AccAutoPickUp = "FightEvent.AccAutoPickUp",      --收到自动拾取

	UpdateEnemy   = "FightEvent.UpdateEnemy",
}

