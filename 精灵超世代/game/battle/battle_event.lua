BattleEvent = BattleEvent or {}

BattleEvent.MapDirection= {
	horizontal = 0, 		-- 横向
    vertical = 1, 	    -- 竖向
}

BattleEvent.BattleFightType = {
    no_battle = 0, --没战斗
    real_battle = 1, --真实战斗
    brocast_battle = 2,--播报战斗
}


--打下一层试炼塔
BattleEvent.BATTLE_NEXT_TRIALTOWER = "BattleEvent.BATTLE_NEXT_TRIALTOWER"


BattleEvent.BATTLE_EXIT_MAIN = "BattleEvent.BATTLE_EXIT_MAIN"


BattleEvent.BATTLE_GET_EQUIP = "BattleEvent.BATTLE_GET_EQUIP"

BattleEvent.BATTLE_DEBUG = "BattleEvent.BATTLE_DEBUG"


BattleEvent.ENTERBACKGROUND = "BattleEvent.ENTERBACKGROUND"

BattleEvent.ENTERFOREGROUND = "BattleEvent.ENTERFOREGROUND"

BattleEvent.VIPVIEW = "BattleEvent.VIPVIEW"

BattleEvent.DISCONNECTVIEW = "BattleEvent.DISCONNECTVIEW"

--关闭结算界面
BattleEvent.CLOSE_RESULT_VIEW = "BattleEvent.CLOSE_RESULT_VIEW"
--结算界面后的界面显示
BattleEvent.NEXT_SHOW_RESULT_VIEW = "BattleEvent.NEXT_SHOW_RESULT_VIEW"

BattleEvent.DUNGEON_SELECT_CARD = "BattleEvent.DUNGEON_SELECT_CARD"

BattleEvent.UPDATE_SELECT_CARD = "BattleEvent.UPDATE_SELECT_CARD"

--地图加载总数
BattleEvent.MAP_LOAD_SUM_NUM = 2


--上阵伙伴更新
BattleEvent.UPDATE_PVP_FORM_UP_DATA = "BattleEvent.UPDATE_PVP_FORM_UP_DATA"

--下阵伙伴更新
BattleEvent.UPDATE_PVP_FORM_DOWN_DATA = "BattleEvent.UPDATE_PVP_FORM_DOWN_DATA"

--敌方阵容更新
BattleEvent.UPDATE_PVP_FORM_RIGHT_DATA = "BattleEvent.UPDATE_PVP_FORM_RIGHT_DATA"

BattleEvent.UPDATE_PVP_RIGHT_READY_DATA = "BattleEvent.UPDATE_PVP_RIGHT_READY_DATA"

BattleEvent.UPDATE_PVP_LEFT_READY_DATA = "BattleEvent.UPDATE_PVP_LEFT_READY_DATA"

BattleEvent.UPDATE_SELECT_CARD_EQUIP = "BattleEvent.UPDATE_SELECT_CARD_EQUIP"

BattleEvent.UPDATE_SELECT_CARD_TEAM = "BattleEvent.UPDATE_SELECT_CARD_TEAM"

-- 战斗类型返回，有一些窗体，需要等这个事件之后，才判断是否显示面板
BattleEvent.COMBAT_TYPE_BACK = "BattleEvent.COMBAT_TYPE_BACK"

BattleEvent.MOVE_DRAMA_EVENT = "BattleEvent.MOVE_DRAMA_EVENT"


BattleEvent.UPDATE_WORLDBOSS_INFO = "BattleEvent.UPDATE_WORLDBOSS_INFO"
BattleEvent.UPDATE_WORLDBOSS_BUFF = "BattleEvent.UPDATE_WORLDBOSS_BUFF"

-- 回合数更新
BattleEvent.UPDATE_ROUND_NUM = "UPDATE_ROUND_NUM"

--战斗boss血量
BattleEvent.Battle_Boss_Hp_Event = "Battle_Boss_Hp_Event"

