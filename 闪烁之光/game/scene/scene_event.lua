SceneEvent = SceneEvent or {}

SceneEvent.FIRST_TIME_LOAD_FINISH = "SceneEvent.FIRST_TIME_LOAD_FINISH"

SceneEvent.SCENE_START = "SceneEvent.SCENE_START"

SceneEvent.SCENE_ADDROLE = "SceneEvent.SCENE_ADDROLE"

SceneEvent.WALK_PATH_CHANGE = "SceneEvent.WALK_PATH_CHANGE"

SceneEvent.SCENE_WALKEND = "SceneEvent.SCENE_WALKEND"


SceneEvent.SCENE_WALKNEXT = "SceneEvent.SCENE_WALKNEXT"
SceneEvent.SCENE_SUCCESS = "SceneEvent.SCENE_SUCCESS"

SceneEvent.SCENE_REMOVEROLE = "SceneEvent.SCENE_REMOVEROLE"
SceneEvent.CROSS_FIND_EVENT = "SceneEvent.CROSS_FIND_EVENT"
SceneEvent.WALK_TO_POINT = "SceneEvent.WALK_TO_POINT"

SceneEvent.FIND_TARGET_CHANGE_POS = "SceneEvent.FIND_TARGET_CHANGE_POS"

SceneEvent.SCENE_PLAYER_CLICK = "SceneEvent.SCENE_PLAYER_CLICK"
SceneEvent.SCENE_UNIT_CLICK = "SceneEvent.SCENE_UNIT_CLICK"

SceneEvent.SCENE_NPC_CLICK = "SceneEvent.SCENE_NPC_CLICK"
SceneEvent.SCENE_DOOR_CLICK = "SceneEvent.SCENE_DOOR_CLICK"
SceneEvent.SCENE_BOX_CLICK = "SceneEvent.SCENE_BOX_CLICK"
SceneEvent.SCENE_MONSTER_CLICK = "SceneEvent.SCENE_MONSTER_CLICK"

SceneEvent.SCENE_ROLE_MOVE = "SceneEvent.SCENE_ROLE_MOVE"
SceneEvent.SCENE_ADDNPC    = "SceneEvent.SCENE_ADDNPC"
SceneEvent.SCENE_ADDDOOR = "SceneEvent.SCENE_ADDDOOR"
SceneEvent.SCENE_ADDBOX = "SceneEvent.SCENE_ADDBOX"
SceneEvent.SCENE_ADDMON = "SceneEvent.SCENE_ADDMON"
SceneEvent.SCENE_NEAR_NPC = "SceneEvent.SCENE_NEAR_NPC"

SceneEvent.UPDATE_HEAD_PHOTO = "SceneEvent.UPDATE_HEAD_PHOTO"
SceneEvent.ONTOUCHSCENE_BEGAN = "SceneEvent.ONTOUCHSCENE_BEGAN"

-- 退出战斗
SceneEvent.EXIT_FIGHT = "SceneEvent.EXIT_FIGHT"

-- 进入战斗 
SceneEvent.ENTER_FIGHT = "SceneEvent.ENTER_FIGHT"


--点击客户端创建的元素
SceneEvent.SCENE_CLIENT_ELEM_CLICK = "scene_client_elem_click"

-- 点击怪物,采集物,传送门的时候新的事件
SceneEvent.SCENE_WALKEND_NEW = "SceneEvent.SCENE_WALKEND_NEW"

-- 场景单位状态变化,可能是looks,可能是战斗状态
SceneEvent.UPDATE_UNIT_ATTRIBUTE = "SceneEvent.UPDATE_UNIT_ATTRIBUTE"

--挖宝停止寻路
SceneEvent.FINDING_STOP_WALK = "SceneEvent.FINDING_STOP_WALK"


-- ----------------------------------------------新改版事件
-- 收获成功之后的播放特效
SceneEvent.PLAY_HARVEST_EFFECT = "SceneEvent.PLAY_HARVEST_EFFECT"

-- 港口事件更新
SceneEvent.WHARF_EVENT = "SceneEvent.WHARF_EVENT"
--港口倒计时
SceneEvent.WHARF_COUNTDOWN = "SceneEvent.WHARF_COUNTDOWN"

-- 炼金场和钻石场满能量的提示
SceneEvent.MainSceneEnergyNotice = "SceneEvent.MainSceneEnergyNotice"

-- 深渊场景的UI显示或关闭
SceneEvent.AbyssSceneUIShowStatus = "SceneEvent.AbyssSceneUIShowStatus"

-- 切换场景状态事件
SceneEvent.ChangeSceneEvent = "SceneEvent.ChangeSceneEvent"

-- 移动场景镜头到指定的建筑身上
SceneEvent.MoveToBuildEvent = "SceneEvent.MoveToBuildEvent"

--切后台港口倒计时更新
SceneEvent.RefreshPortTime = "SceneEvent.RefreshPortTime"

--播放解锁场景,面板
SceneEvent.LevUpgradeAction = "SceneEvent.LevUpgradeAction"

-- 炼金场更新数据
SceneEvent.UpdateAlchmeyInfo = "SceneEvent.UpdateAlchmeyInfo"
SceneEvent.UpdateAlchmeyInfoEvent = "SceneEvent.UpdateAlchmeyInfoEvent"



-- 构建主城建筑数据完成，可以创建建筑了
SceneEvent.CreateBuildVoOver = "SceneEvent.CreateBuildVoOver"