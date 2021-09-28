-- 游戏中全局事件唯 一事件名[用于与其他功能之间交互的 GlobalDispatcher 监听-派发 ]（如果只是功能内的，事件名写在自己功能里面）

EventName = {}

EventName.LOADER_ALL_COMPLETED = "LOADER_ALL_COMPLETED" -- (CSharpDispatcher)第一次加载完成全部资源[作为启动lua的起始事件]

EventName.OPENVIEW = "EventName.OPENVIEW" -- 打开事件参数ID BaseView 全屏窗口 参数{...}

-- 网络
	EventName.NET_CONNECTED = "EventName.NET_CONNECTED"  -- 网络连接成功
	EventName.NET_RECONNECT = "EventName.NET_RECONNECT"  -- 重新网络
	EventName.NET_DISCONNECT = "EventName.NET_DISCONNECT"  -- 网络断开
	EventName.NET_TIMEOUT = "EventName.NET_TIMEOUT" --网络连接超时

-- 登录
	EventName.ROLE_INITED = "EventName.ROLE_INITED"  -- 主角初始数据入场景(每次换场，但未入场景)
	EventName.RELOGIN_ROLE = "EventName.RELOGIN_ROLE" -- 重新角色上线
	EventName.SERVER_EXCEPTION = "EventName.SERVER_EXCEPTION" -- 后端错误提示码
	EventName.SERVER_TIME_CHANGE = "EventName.SERVER_TIME_CHANGE" -- 服务器时间变化
	EventName.ENTER_DATA_INITED = "EventName.ENTER_DATA_INITED" -- 登入初始数据
	EventName.DELETE_ROLE = "EventName.DELETE_ROLE" --删除角色
	EventName.DELETE_FAMILYINFO = "EventName.DELETE_FAMILYINFO" -- 删除家族信息

-- 场景
	EventName.FIRST_ENTER_SCENE = "EventName.FIRST_ENTER_SCENE"  -- 仅第一次场景加载中
	EventName.REQ_CHANGE_SCENE = "EventName.REQ_CHANGE_SCENE"  --每次请求切换场景
	EventName.UNLOAD_SCENE = "EventName.UNLOAD_SCENE"  -- 每次切换场景时触发: 卸载场景
	EventName.LOADING_SCENE = "EventName.LOADING_SCENE"  --ENTER_SCENE事件后每次切换场景触发：正在加载场景
	EventName.UpdateServerTime = "EventName.UpdateServerTime" -- 本地服务器时间被刷新了
	EventName.CAMERA_READY = "EventName.CAMERA_READY" 			-- 摄像机完成
	EventName.SCENE_LOAD_FINISH = "EventName.SCENE_LOAD_FINISH"  -- 每次切换场景的触发： 场景加载完成
	EventName.SceneLoader_CLOSE = "EventName.SceneLoader_CLOSE" -- 加载读条UI关闭

	EventName.PLAYER_ADDED = "EventName.PLAYER_ADDED"  -- 玩家入场(model) ->
	EventName.PLAYER_REMOVED = "EventName.PLAYER_REMOVED"  -- 玩家离场(model) ->
	EventName.PLAYER_UPDATED = "EventName.PLAYER_UPDATED"  -- 玩家变化更新
	EventName.MAINPLAYER_UPDATE = "EventName.MAINPLAYER_UPDATE"  --主角属性变化
	EventName.SCENE_PLAYER_ADDED = "EventName.SCENE_PLAYER_ADDED"  -- (view) ->
	EventName.MAIN_ROLE_ADDED = "EventName.MAIN_ROLE_ADDED" -- 主角添加入场景 -- (view) 
	EventName.PLAYER_TITLE = "EventName.PLAYER_TITLE" -- 玩家称谓
	EventName.PLAYER_MODEL = "EventName.PLAYER_MODEL" -- 玩家模型变化

	EventName.AutoFightStart = "AutoFightStart"  --自动战斗开始
	EventName.AutoFightEnd = "AutoFightEnd"  --自动战斗结束
	EventName.Player_AutoRun = "EventName.Player_AutoRun"  --玩家自动寻路
	EventName.WALKING = "EventName.WALKING" -- 玩家走动中
	EventName.Player_AutoRunEnd = "EventName.Player_AutoRunEnd"--玩家自动结束

	EventName.Player_MoveToTarget = "EventName.Player_MoveToTarget"  --玩家跑到指定点
	EventName.Player_StopWorldNavigation = "EventName.Player_StopWorldNavigation" --玩家世界地图寻路结束
	EventName.StartReturnMainCity = "EventName.StartReturnMainCity" -- 开始启动回城
	EventName.StopReturnMainCity = "EventName.StopReturnMainCity" -- 终止回城

	EventName.MAINROLE_WALKING = "MAINROLE_WALKING" -- 主角走动(前端用)
	EventName.MAINROLE_STOPWALK = "EventName.MAINROLE_STOPWALK" -- 主角请求停止走动
	EventName.MAINROLE_DIE = "EventName.MAINROLE_DIE"   		--主角死亡
	EventName.MAINROLE_RELIFE = "EventName.MAINROLE_RELIFE"   	--主角复活

	EventName.CROSS_PATH = "EventName.CROSS_PATH" 	-- 跨场景寻路
	EventName.CROSS_PATH_END = "EventName.CROSS_PATH_END" 		-- 到达目标
	EventName.TRANSFERNOTICE = "EventName.TRANSFERNOTICE"-- 传送通知

	EventName.MONSTER_ADDED = "EventName.MONSTER_ADDED"  -- 怪物入场 (model)-> 
	EventName.MONSTER_REMOVED = "EventName.MONSTER_REMOVED"  -- 怪物离场 (model)-> 
	EventName.MONSTER_UPDATED = "EventName.MONSTER_UPDATED"  -- 怪物变化更新
	EventName.SCENE_MONSTER_ADDED = "EventName.SCENE_MONSTER_ADDED"  -- (view)-> --params[唯一Id, 死亡阶段, 是否为Boss]
	EventName.MONSTER_DEAD = "EventName.MONSTER_DEAD" 			--怪物死亡通知
	
	EventName.SummonThing_ADDED = "EventName.SummonThing_ADDED"  -- 召唤物入场 (model)-> 
	EventName.SummonThing_REMOVED = "EventName.SummonThing_REMOVED"  -- 召唤物离场 (model)-> 
	EventName.SummonThing_UPDATED = "EventName.SummonThing_UPDATED"  -- 召唤物变化更新
	EventName.SCENE_SummonThing_ADDED = "EventName.SCENE_SummonThing_ADDED"  -- (view)-> --params[唯一Id, 死亡阶段, 是否为Boss]
	EventName.SummonThing_DEAD = "EventName.SummonThing_DEAD" 			--召唤物死亡通知

	EventName.BOSS_ENTER = "EventName.BOSS_ENTER"			--需要显示信息的怪物入场
	EventName.BOSS_OUTTER = "EventName.BOSS_OUTTER"			--需要显示信息的怪物离场
	EventName.BOSS_INFO_UPDATE = "EventName.BOSS_INFO_UPDATE "  -- 需要刷新怪物数据的信息

	EventName.NPC_ADDED = "EventName.NPC_ADDED"  -- 入场 model
	EventName.NPC_REMOVED = "EventName.NPC_REMOVED"  -- 离场 model
	EventName.NPC_UPDATED = "EventName.NPC_UPDATED"  -- 变化更新
	EventName.NPC_ENTERSCENE = "EventName.NPC_ENTERSCENE" -- npc进场

	EventName.DROP_ADDED = "EventName.DROP_ADDED"  -- 掉落入场 model

	EventName.DOOR_ADDED = "EventName.DOOR_ADDED"  -- 传送门 model
	EventName.DOOR_REMOVED = "EventName.DOOR_REMOVED"  --  model

	EventName.WIGSKILL_ADDED = "EventName.WIGSKILL_ADDED" -- 地效添加

	EventName.OBJECT_ONCLICK = "EventName.OBJECT_ONCLICK"  -- 场景对象被点击
	EventName.AllOBJECT_ONCLICK = "AllOBJECT_ONCLICK" --射线穿透的所有场景对象++++++++

	EventName.PAUSE_GAME = "EventName.PAUSE_GAME"--暂停游戏
	EventName.CONTINUE_GAME = "EventName.CONTINUE_GAME" --继续游戏

	EventName.BATTLE_PLAYER_HP_CHAGNGE = "EventName.BATTLE_PLAYER_HP_CHAGNGE" --玩家血量变化
	EventName.BATTLE_MONSTOR_HP_CHAGNGE = "EventName.BATTLE_MONSTOR_HP_CHAGNGE"--怪物血量变化
-- 战斗
	EventName.GOTOFIGHT = "EventName.GOTOFIGHT" -- 前往战斗
	EventName.EXECUTE_SKILL = "EventName.EXECUTE_SKILL" -- 执行技能
	EventName.AUTO_FIGHT = "EventName.AUTO_FIGHT"  	--改变挂机状态
-- 手柄
	EventName.JOYSTICK_MOVE = "EventName.JOYSTICK_MOVE"  -- 手柄移动
	EventName.JOYSTICK_END = "EventName.JOYSTICK_END"  -- 手柄移动结束

-- 主UI
	EventName.MAINUI_OPEN = "EventName.MAINUI_OPEN" -- 打开
	EventName.MAINUI_CLOSE = "EventName.MAINUI_CLOSE" 
	EventName.MAINUI_BOTTOM_CLOSE = "EventName.MAINUI_BOTTOM_CLOSE" --主UI下方按钮关闭
	EventName.MAINUI_RED_TIPS = "EventName.MAINUI_RED_TIPS"
	EventName.MAINUI_EXIST = "EventName.MAINUI_EXIST" --MainCityUI存在

	EventName.AUTO_HPMP = "EventName.AUTO_HPMP" -- 全自动补血补蓝

-- 背包
	EventName.BAG_INITED = "EventName.BAG_INITED" -- 背包数据完成初始化
	EventName.BAG_CHANGE = "EventName.BAG_CHANGE" -- 背包数量变化或更新(参数list [bid]=num)
	EventName.EQUIPINFO_CHANGE = "EventName.EQUIPINFO_CHANGE" -- 装备信息变化
	EventName.MEDICINE_CHANGE = "EventName.MEDICINE_CHANGE" -- 药品变化
	EventName.USE_GOODS = "EventName.USE_GOODS" -- 使用物品事件
	EventName.USE_BLUE_MEDICINE = "EventName.USE_BLUE_MEDICINE" -- 使用蓝药
	EventName.USE_RED_MEDICINE = "EventName.USE_RED_MEDICINE" -- 使用红药
-- 聊天
	EventName.FriendChat = "EventName.FriendChat"  --与好友私聊
	EventName.WoldChat = "EventName.WoldChat"  --双击主界面聊天，到世界频道
	EventName.IsClickPrivate = "EventName.IsClickPrivate" --点击私聊按钮++

-- 邮件
	EventName.NEWMAIL_NOTICE = "EventName.NEWMAIL_NOTICE" -- 新邮件通知

-- 家族
	EventName.FAMILY_CREATE = "EventName.FAMILY_CREATE" -- 创建家族
	EventName.FAMILY_DISBAND = "EventName.FAMILY_DISBAND" -- 家族不存在(被踢或主动退出或解散)
	EventName.FAMILY_CHANGE = "EventName.FAMILY_CHANGE" -- 家族变化
	EventName.FAMILY_INVITE = "EventName.FAMILY_INVITE" -- 家族邀请
	EventName.FAMILY_ZD = "EventName.FAMILY_ZD" -- 家族组队
--vip
	EventName.VIPLV_CHANGE = "EventName.VIPLV_CHANGE"	--收到vip激活消息
	EventName.GETVIPINFO_CHANGE = "EventName.GETVIPINFO_CHANGE" --获取玩家vip信息
	EventName.VipDailyState = "EventName.VipDailyState"  --vip每日领取状态

--副本
	EventName.FBFinishCutDown = "EventName.FBFinishCutDown"  ---服务器通知fb进入销毁倒计时

--Buff
	EventName.BUFF_UPDATE_EVENT = "EventName.BUFF_UPDATE_EVENT" --更新buff
	EventName.ReqPranayama = "EventName.ReqPranayama" --请求进入调试
	EventName.ReqUnPranayama = "EventName.ReqUnPranayama" --请求打断调息
	EventName.BuffDataUpdate = "EventName.BuffDataUpdate" --更新buff数据
	EventName.BuffRemove = "EventName.BuffRemove" --移除buff
	EventName.BuffDataChanged = "EventName.BuffDataChanged"
	
--技能
	EventName.SkillUpgrade = "SKILL_UPGRADE_RESULT" --升级技能结果
	EventName.SyncSkillMastery = "SYNC_SKILL_MASTERY" --同步技能熟练度

	EventName.SkillBtnClick = "SkillBtnClick" --技能按键按下
	EventName.SkillUseBegin = "SkillUseBegin" --开始使用技能
	EventName.SkillUseEnd = "SkillUseEnd" --结束使用技能
	EventName.ResetSkillManagerComplete = "ResetSkillManagerComplete" --重置技能管理器完成
	EventName.SkillBtnResetComplete = "SkillBtnResetComplete" --重置技能按钮完成

-----------------------------------战斗同步 start------------------------------------------
	EventName.PlayerAttack = "EventName.PlayerAttack"
	EventName.Hit = "EventName.Hit"
	EventName.SummonAttack = "EventName.SummonAttack"
----------------------------------- 战斗同步 end ------------------------------------------

--震屏
	EventName.Shake = "Shake"

--位置更新
	EventName.ReqUpdatePosition = "ReqUpdatePosition"

 --任务
 	EventName.UpdateTaskList = "UpdateTaskList"
 	EventName.UpdateTaskState = "UpdateTaskState"
 	EventName.InitTaskList = "InitTaskList"
 	EventName.FinishNPCDramaDialog = "FinishNPCDramaDialog"
 	EventName.FinishSubmitDramaDialog = "FinishSubmitDramaDialog"
 	EventName.AbandonTask = "EventName.AbandonTask"
 	EventName.FinishTask = "EventName.FinishTask"
 	EventName.AUTO_DONEXT_TASK = "EventName.AUTO_DONEXT_TASK"

--组队
	EventName.HasTeamerNoApplyEnterFB = "EventName.HasTeamerNoApplyEnterFB" --有队友不同意进副本
	EventName.SocialTeam = "EventName.SocialTeam"  --调用社交2级弹窗
	EventName.FriendTeam = "EventName.FriendTeam"  --与在好友列表邀请组队
	EventName.CreateTeam = "EventName.CreateTeam"			--创建队伍(*)
	EventName.FriendListRefresh = "FriendListRefresh"  --收到好友列表刷新邀请列表

	EventName.TEAM_CHANGED = "EventName.TEAM_CHANGED" -- 队伍信息变化
	EventName.MEMBER_HP_CHANGED = "EventName.MEMBER_HP_CHANGED" -- 成员hp变化
	EventName.NOTICE_REQ_INTEAM = "EventName.NOTICE_REQ_INTEAM" -- 有申请入队事件
	
--采集
	EventName.AddCollectItem = "EventName.AddCollectItem" --添加采集物
	EventName.RemoveCollectItem = "EventName.RemoveCollectItem" --删除采集物
	EventName.StartCollect = "EventName.StartCollect" --开始采集
	EventName.AddCollectItemList = "EventName.AddCollectItemList" --开始采集列表
	EventName.RemoveCollectItemList = "EventName.RemoveCollectItemList" --移除采集列表
	EventName.EndCollect = "EventName.EndCollect"
	EventName.StopCollect = "EventName.StopCollect"

--pk模式
	EventName.PkModelChange = "PkModelChange" --pk模式切换

--斗神印
	EventName.RefershGodFightRune = "EventName.RefershGodFightRune" --刷新斗神印数据
	EventName.RefershMainWeapon = "EventName.RefershMainWeapon" --刷新玩家身上的主武器数据
	EventName.RefershWeaponInscription = "EventName.RefershWeaponInscription" --刷新武器铭文信息
	EventName.CompoundRuneSucc = "EventName.CompoundRuneSucc"

--功能指引
	EventName.GuideFunctionTrigger = "EventName.GuideFunctionTrigger" --引导功能触发

--NPC头顶状态该改变
	EventName.UpdateNPCHeadState = "EventName.UpdateNPCHeadState"

--在线时长奖励
	EventName.GetOnlineReward = "EventName.GetOnlineReward"
	EventName.SyncOnlineRewardList = "EventName.SyncOnlineRewardList"
--疯狂冲级
	EventName.GetOnLevelReward = "EventName.GetOnLevelReward"
	EventName.SyncOnLevelRewardList = "EventName.SyncOnLevelRewardList"
--冲战斗力
	EventName.GetOnBattleReward = "EventName.GetOnBattleReward"
	EventName.SyncOnBattleRewardList = "EventName.SyncOnBattleRewardList"
	EventName.WhenTimeEndClose = "EventName.WhenTimeEndClose"
--环任务
	EventName.SyncPlayerAttr = "EventName.SyncPlayerAttr"
	EventName.SyncCycleTaskNum = "EventName.SyncCycleTaskNum"

--每日任务
	EventName.SynDailyTaskList = "EventName.SynDailyTaskList"
	EventName.AbandonDailyTask = "EventName.AbandonDailyTask"
	EventName.SubmitDailyTask = "EventName.SubmitDailyTask"
	EventName.SyncDailyTaskNum = "EventName.SyncDailyTaskNum"

--时装
	EventName.ChangeStyleSuccess = "EventName.ChangeStyleSuccess"

--其他
	EventName.CheckOtherPlayerInfo = "EventName.CheckOtherPlayerInfo"
	EventName.ShowPlayerFuncPanel = "EventName.ShowPlayerFuncPanel" --选中界面
	EventName.PayPanelLayout = "EventName.PayPanelLayout" -- 充值界面完成布局
	EventName.GetFirstPayList = "EventName.GetFirstPayList" -- 获取已充值列表
	EventName.BuyJiJinSuccess = "EventName.BuyJiJinSuccess" --购买基金成功
--选服
	EventName.SelectServer = "EventName.SelectServer"

--签到红点状态
	EventName.SignRedChange = "EventName.SignRedChange"
--活动功能第一次开启
	EventName.ActivityFirstOpen = "EventName.ActivityFirstOpen"

--通过手机找回密码
	EventName.GetBackPassword = "EventName.GetBackPassword"
--队伍信息变更(队伍id变更 or 队伍成员变更)
	EventName.TeamListChange = "EventName.TeamListChange"
--装备卸下 or 装备穿上
	EventName.PlayerEquipStateChange = "EventName.PlayerEquipStateChange"

--新手引导
	EventName.StartNewbieGuide = "EventName.StartNewbieGuide" --开始某个引导任务对应的新手引导(由引导ID不为0的引导类型任务触发)
	EventName.EndNewbieGuide = "EventName.EndNewbieGuide" --结束某个引导任务对应的的新手引导
	EventName.FinishNewbieGuideStep = "EventName.FinishNewbieGuideStep" --完成当前新手引导的当前步骤

--开场CG
	EventName.StartCG = "EventName.StartCG"

--重置密码
	EventName.ResetPassword = "EventName.ResetPassword"

--登录进入主界面后弹窗
	EventName.PopCheckStateChange = "EventName.PopCheckStateChange"

--角色界面更新红点状态
	EventName.RefershPlayerInfoRedTips = "EventName.RefershPlayerInfoRedTips"

--显示活动红点状态
	EventName.RefershDayLimitActivityRedTips = "EventName.RefershDayLimitActivityRedTips"

--天梯对手入场
	EventName.TiantiRoleEnter = "EventName.TiantiRoleEnter"
	EventName.TiantiRoleAttrUpdate = "EventName.TiantiRoleAttrUpdate"
	EventName.TiantiFinishCutDown = "EventName.TiantiFinishCutDown"

--设置界面退出游戏
	EventName.ExitGame = "EventName.ExitGame"

--充值活动
	EventName.UpdateTotalRechargeData = "EventName.UpdateTotalRechargeData" --更新累积充值的相关数据
	EventName.FinishPay = "EventName.FinishPay" --完成购买某个商品
	EventName.RefershTotalRechargeRedTipsState = "EventName.RefershTotalRechargeRedTipsState"
	EventName.RefershConsumRed = "EventName.RefershConsumRed" -- 更新累计消费红点

--大荒塔层数改变
	EventName.TowerLayerChange = "EventName.TowerLayerChange"
--转盘红点变化
	EventName.TurnRedChange = "EventName.TurnRedChange"
	EventName.SevenRechargeRedChange = "EventName.SevenRechargeRedChange"

	EventName.KEYCODE_MOVE = "EventName.KEYCODE_MOVE"
	EventName.DizzyStateChange = "EventName.DizzyStateChange"
--帮会CLAN_INFOCHANGED
	EventName.CLAN_INFOCHANGED = "EventName.CLAN_INFOCHANGED" --帮会信息变化