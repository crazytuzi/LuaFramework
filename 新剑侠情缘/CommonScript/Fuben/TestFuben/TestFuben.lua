
local tbFubenSetting = {};
Fuben:SetFubenSetting(6, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "PersonalFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "测试副本"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/PersonalFuben/TestFuben/NpcPos.tab"			-- NPC点
tbFubenSetting.szNpcExtAwardPath 		= "Setting/Fuben/PersonalFuben/TestFuben/ExtNpcAwardInfo.tab"	-- 掉落表
tbFubenSetting.szPathFile 				= "Setting/Fuben/TestFuben/NpcPos.tab"							-- 寻路点
tbFubenSetting.tbBeginPoint 			= {404, 640}											-- 副本出生点
tbFubenSetting.tbRevivePos				= {444, 666}											--复活点

-- AddNpc						说明：添加NPC
--								参数：nIndex npc序号(可用NUM内参数), nNum 添加数量(可用NUM内参数), nLock 死亡解锁Id, szGroup 所在分组名, szPointName 刷新点名([NpcGroup=BOSS]), bRevive 是否重生(不可用), nDir 添加的Npc方向, nDealyTime 延迟添加, nEffectId 特效Id, nEffectTime 特效时间
--								示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},

-- AddSimpleNpc					说明：添加辅助 Npc，只是添加Npc 不负责管理，一般用于副本结束的篝火Npc等类似Npc，无法销毁
--								参数：nNpcTemplateId Npc 模板 Id, nX, nY, nDir 方向
--								示例：{"AddSimpleNpc", 100, 1000, 1000, 20},

-- NpcHpUnlock					说明：Npc设置血量解锁
--								参数：szGroup Npc所在组, nLockId 解锁Id, nPercent 解锁时血量
--								示例：{"NpcHpUnlock", "BOSS", 3, 50},

-- DelNpc						说明：删除某一组内的所有npc
--								参数：szGroup 要删除的Npc所在的组
--								示例：{"DelNpc", "NpcGroup1"},

-- SetAiActive					说明：是否激活AI
--								参数：szGroup
--								示例：{"SetAiActive", "NpcGroup1", 0},

-- SetNpcAi						说明：切换AI
--								参数：szGroup Npc所在组，szAiFile Ai文件路径
--								示例：{"SetNpcAi", "NpcGroup1", "Setting/Npc/Ai/TestAi.ini"},

-- ChangeTrap					说明：更换trap传送点
--								参数：szClassName Trap点名字, tbPoint 传送点坐标, tbJump 跳跃点（点，跳跃方式）, bFight 传送后是否为战斗状态, bExit 是否离开副本, szEvent 是否调用对应事件函数, bSyncOther 是否拉同伴和助战者
--								示例：{"ChangeTrap", "Trapname", {1533, 3660}, {3373, 4983, 2}, 0, 1, "GameWin", true},

-- TrapAddSkillState			说明：踩 trap点添加buff
--								参数：szClassName trap 点名字, nSkillId 技能Id, nSkilLevel 技能等级, nTime 持续时间, bSaveDeath 是否死亡保留, bForce 是否强制替换, nUsableTime 最大使用次数，不填默认一次, nNpcTemplateId 添加NpcId, nX Npc所在X坐标, nY Y坐标
--								示例：{"TrapAddSkillState", "TrapLock1", 1001, 1, 10, 0, 0, 1002, 455, 199},

-- TrapCastSkill				说明：踩 trap点释放技能
--								参数：szClassName trap 点名字, nSkillId 技能Id, nSkilLevel 技能等级, nParam1 技能参数 1, nParam2 技能参数 2, nUsableTime 最大使用次数, nNpcTemplateId 添加Npc的模板, nX x坐标, nY y坐标
--								示例：{"TrapCastSkill", "TrapLock1", 1001, -1, -1, 2, 1002, 455, 199},

-- TrapUnlock					说明：玩家踩Trap 解锁
--								参数：szClassName Trap点名字, nLockId 解锁ID
--								示例：{"TrapUnlock", "Trapname", 1},

-- CloseLock					说明：关闭锁
--								参数：nBeginLockId 起始LockId, nEndLockId 结束Id
--								示例：{"CloseLock", 2, 4}, (关闭了 2，3，4 三个锁)， {"CloseLock", 2}, (只关闭 2号锁)

-- ChangeNpcAi					说明：改变AI, 参数: npc分组名,AI子指令（AI有以下类型可以更改)：
		-- Move 移动， 参数：路径名, 到达解锁ID, 是否主动攻击，是否还击，是否到达删除，是否自动循环，例 {"ChangeNpcAi", "guaiwu", "Move", "Path1", 4, 1, 1, 1, 0},
		-- AttackType 设置攻击方式， 参数：是否主动攻击，是否还击，例 {"ChangeNpcAi", "guaiwu", "AttackType", 1, 1},
		-- AddAiLockTarget 设置Npc固定攻击目标，参数: 目标Npc所在组名，例 {"ChangeNpcAi", "guaiwu", "AddAiLockTarget", "target"},
		-- RandomAiTarget 重新随机一个玩家作为Npc目标，参数：无，例 {"ChangeNpcAi", "BOSS", "RandomAiTarget"},

-- SetNpcLife					说明：设置Npc血量
--								参数：szNpcGroup Npc所在组, nLife 血量值百分比
--								示例：{"SetNpcLife", "BOSS", 25},   (设置BOSS血量为 25%)

-- GameWin						说明：副本胜利，无参数

-- GameLost						说明：副本失败，无参数

-- RaiseEvent					说明：触发副本事件，不同类型副本所支持事件不同，具体事件说明请直接联系相关程序
--								参数：szEventName 事件名，... 事件所需参数
--								示例：{"RaiseEvent", "Log", "unlock lock 4"},

-- SetPos						说明：改变所有玩家所在坐标
--								参数：nX 设置X坐标, nY 设置Y坐标
--								示例：{"SetPos", 1589, 3188},

-- BlackMsg						说明：给所有副本内玩家黑条提示
--								参数：szMsg
--								示例：{"BlackMsg", "那啥？"},

-- UseSkill						说明：让指定NPC在某个坐标点释放技能
--								参数：szGroup npc组, nSkillId 技能ID, nMpsX, nMpsY
--								示例：{"UseSkill", "guaiwu", 734, 51224, 101860},

-- CastSkill 					说明：让指定Npc释放技能（不会检查当前Npc是否有此技能）
-- 								参数：szGroup npc组, nSkillId 技能Id, nSkilLevel 技能等级, nParam1 参数1, nParam2 参数2
-- 								示例：{"CastSkill", "guaiwu", 3, 1, -1, -1},

-- CastSkillMulti 				说明：让指定Npc释放技能（不会检查当前Npc是否有此技能）
-- 								参数：szGroup npc组, nSkillId 技能Id, nSkilLevel 技能等级, szParamName 参数名（在 NpcPoint.tab 里配置）, nCount 释放数量
-- 								示例：{"CastSkillMulti", "guaiwu", 3, 1, "skill_point_1", 5},

-- CastSkillCycle 				说明：让指定Npc释放技能（不会检查当前Npc是否有此技能）
-- 								参数：szType 当前循环的名称, szGroup 释放技能Npc组, nTimeSpace 循环时间间隔, nSkillId 技能Id, nSkilLevel 技能等级, nParam1 参数1, nParam2 参数2
-- 								示例：{"CastSkillCycle", "cycle1", "tr", 2, 3, 1, -1, -1},

-- StartTimeCycle				说明：开启一个定时循环器
--								参数：szType 当前循环名称, nTimeSpace 循环时间间隔（单位：s）, nCycleCount 循环次数(nil或者小于1 为不限制), ... 事件
--								示例：{"StartTimeCycle", "cycle_1", 10, 5, {"UseSkill", "guaiwu", 734, 51224, 101860}, {"UseSkill", "guaiwu2", 734, 51224, 101860}},

-- CloseCycle					说明：关闭循环器  (CastSkillCycle, StartTimeCycle 都可以)
--								参数：szType 要关闭循环名
--								示例：{"CloseCycle", "cycle_1"},

-- OpenDynamicObstacle			说明：打开当前地图的动态障碍
--								参数：szObsName 动态障碍名
--								示例：{"OpenDynamicObstacle", "ops1"},

-- PlayCameraAnimation			说明：播放录制好的摄像机动画，同时摄像机进入动画模式，此模式下，摄像机不跟随玩家移动，播放结束后解锁 nLockId
--								参数：nAnimationId 动画Id 在 tbFubenSetting.ANIMATION 中定义, nLockId 播放结束后解锁的ID
--								示例：{"PlayCameraAnimation", 1, 2},

-- PlaySceneCameraAnimation		说明：（新版，播放时会切换主摄像机）播放录制好的场景摄像机动画，同时摄像机进入动画模式，此模式下，摄像机不跟随玩家移动，播放结束后解锁 nLockId
--								参数：szObjectName 场景对象， szAnimName 动画名, nLockId 播放结束后解锁的ID
--								示例：{"PlaySceneCameraAnimation", "szObjectName", "szAnimName", nLockId},

-- MoveCamera					说明：在nTime时间内平滑移动摄像机到目标位置，同时摄像机进入动画模式，此模式下，摄像机不跟随玩家移动，移动到目标位置时解锁 nLockId
--								参数：nLockId 播放结束后解锁的Id, nTime 移动到目标点需要耗时,
--										nX 目标点 X 坐标（参数为 0 表示保持原参数）, nY 目标点 Y 坐标（参数为 0 表示保持原参数）, nZ 目标点 Z 坐标（参数为 0 表示保持原参数）,
--										nrX 目标旋转 X（参数为 0 表示保持原参数）, nrY 目标旋转 Y（参数为 0 表示保持原参数）, nrZ 目标旋转 Z（参数为 0 表示保持原参数）
--								示例：{"MoveCamera", 3, 2, 28.06, 34.81, 20.03, 60.44, 81.254, 178.59},

-- MoveCameraToPosition			说明：在nTime时间内平滑移动摄像机到目标位置，同时摄像机进入动画模式，此模式下，摄像机不跟随玩家移动，移动到目标位置时解锁 nLockId
--								参数：nLockId 播放结束后解锁的Id, nTime 移动到目标点需要耗时,
--										nX 目标点 X 坐标（为游戏逻辑坐标，参数为 0 表示保持原参数）, nY 目标点 Y 坐标（为游戏逻辑坐标 参数为 0 表示保持原参数）, nDist（摄像机距离目标点距离修正值当前距离为 23）
--								示例：{"MoveCameraToPosition", 3, 2, 1000, 1500, 10},

-- ChangeCameraSetting			说明：改变摄像机基础设置
-- 								参数：fDistance 摄像机于玩家距离, fLookDownAngle 摄像机俯仰角度, fFieldOfView 摄像机广角
--								示例：{"ChangeCameraSetting", 28, 35, 20},

-- MoveCameraByTarget			说明：在跟随玩家的模式下旋转摄像机的 Y 角度
-- 								参数：nLockId 播放结束后解锁 Id, nTime 多久移动结束， rY 目标 Y 旋转
--								示例：{"MoveCameraByTarget", 3, 2, 80},

-- LeaveAnimationState			说明：摄像机离开动画模式，恢复为摄像机跟随玩家
--								参数：bRestoreCameraRotation 是否恢复摄像机原来角度，不填默认恢复
--								实例：{"LeaveAnimationState", false},

-- RestoreCameraRotation 		说明：摄像机恢复初始旋转角度，无参数

-- PlayEffect					说明：在指定位置播放特效
--								参数：nResId 特效资源 Id, nX 坐标 X（填 0 或者不填，则表示使用玩家当前坐标）, nY 坐标 Y（填 0 或者不填，则表示使用玩家当前坐标）, nZ 高度 （不填则表示 0）bRenderPos 是否表现位置,
--								实例：{"PlayEffect", 206, 0, 0, 0, 1},

-- PlayFactionEffect			说明：在指定位置播放门派特效
--								参数：{{门派1男特效资源Id， 门派1女特效资源Id}, {门派2男特效资源Id， 门派2女特效资源Id}}, , nX 坐标 X（填 0 或者不填，则表示使用玩家当前坐标）, nY 坐标 Y（填 0 或者不填，则表示使用玩家当前坐标）, nZ 高度 （不填则表示 0）,bRenderPos(原点时填1)
--								实例：{"PlayFactionEffect", {{1, 1}, {2, 2}, {3, 3}, {4, 4}}, nX, nY, nZ},

-- PlayCameraEffect				说明：在指定位置播放特效
--								参数：nResId 特效资源 Id
--								实例：{"PlayCameraEffect", 206},

-- PlaySound					说明：播放声音
--								参数：声音ID
--								实例：{"PlaySound", 206},

-- PlayCGAnimation				说明：在指定位置播放特效
--								参数：nCGID
--								实例：{"PlayCGAnimation", 206},

-- OpenWindow                   说明：打开窗口
--								参数：... 参数说明请教程序
--								实例：弹出提示ui：{"OpenWindow", "RockerGuideNpcPanel", "提示文字"},
--								实例：弹出黑屏剧情：{"OpenWindow", "StoryBlackBg", "剧情文字", "剧情标题", 3 --内容动画时间, 2 --内容停留时间(在动画完成后开始计时), 1 --淡入淡出时间},
--								实例：弹出boss出场特写：{"OpenWindow", "BossReferral", "名字第一个单字", "名字剩余字", "身份描述文字"},

-- OpenWindowAutoClose          说明：打开窗口（离开副本后自动关闭）
--								参数：... 参数说明请教程序
--								实例：弹出提示ui：{"OpenWindowAutoClose", "RockerGuideNpcPanel", "提示文字"},
--								实例：弹出黑屏剧情：{"OpenWindowAutoClose", "StoryBlackBg", "剧情文字", "剧情标题", 3 --内容动画时间, 2 --内容停留时间(在动画完成后开始计时), 1 --淡入淡出时间},
--								实例：弹出boss出场特写：{"OpenWindowAutoClose", "BossReferral", "名字第一个单字", "名字剩余字", "身份描述文字"},


-- SetDynamicRevivePoint		说明：设置复活点
--								参数：nX, nY
--								示例：{"SetDynamicRevivePoint", 1000, 2000},

-- CloseWindow                  说明：关闭窗口
--								参数：... 参数说明请教程序
--								实例：{"CloseWindow", 窗口名},

-- ShowAllRepresentObj			说明：是否显示所有Npc表现
--								参数：是否显示
--								实例：{"ShowAllRepresentObj", false},

-- SetTargetPos					说明：设置玩家当前寻路目标点
--								参数：nX, nY
--								示例：{"SetTargetPos", 1000, 2000},

-- ClearTargetPos				说明：关闭副本方向指引
--								参数：无
--								示例：{"ClearTargetPos"},

-- ChangeFightState				说明：改变所有玩家的战斗状态
-- 								参数：nFightState 战斗状态 1 战斗状态， 0 非战斗状态
--								示例：{"ChangeFightState", 1},

-- SetFubenProgress				说明：设置当前玩家显示的副本进度
--								参数：nPersent 当前进度，szInfo 副本目标，如果不填则表示目标提示不改变
--								示例：{"SetFubenProgress", 35, "消灭大魔王"},

-- SetGameWorldScale			说明：设置当前时间速度
--								参数：nScale 当前时间流速，如 nScale = 0.1 则表示以正常1/10的速度播放动画此参数必须在区间 [0.01 5]内
--								示例：{"SetGameWorldScale", 0.5},

-- ShowTaskDialog				说明：播放剧情对话
--								参数：nDialogId 对话Id, bIsOnce 是否是只播放一次，不填或者填 false 表示一直播放
--								示例：{"ShowTaskDialog", 10, true},

-- PlaySceneAnimation			说明：播放场景动画
--								参数：szObjectName 动画所在对象的名字, szAnimationName 动画的名字, nSpeed 速度（1表示正常速度，2表示正常 2 倍速）, bFinishHide 是否播放结束隐藏
--								示例：{"PlaySceneAnimation", "fb_erengu_men01_open", "wind", 0.2, true},

-- PlaySceneAnimationWithPlayer	说明：播放场景动画会将主角当前形象应用在动画中
--								参数：szObjectName 动画所在对象的名字, szAnimationName 动画的名字, nSpeed 速度（1表示正常速度，2表示正常 2 倍速）, bFinishHide 是否播放结束隐藏
--								示例：{"PlaySceneAnimationWithPlayer", "fb_erengu_men01_open", "wind", 0.2, true},

-- BatchPlaySceneAnimation		说明：批量播放动画
--								参数：szObjectName 被拼接对象初始名, nStartIdx 开始索引, nEndIdx 结束索引, szAnimationName 动画名, nSpeed 播放速度, bFinishHide 是否播放结束隐藏
--								示例：{"BatchPlaySceneAnimation", "wyqf0", 1, 9, "Take 001", 1, true},   -- 这个给播放  wyqf01 wyqf02 .. wyqf09 九个对象播放动画 Take 001

-- SetForbiddenOperation		说明：禁止玩家操作
--								参数：bForbidden 是否禁止玩家操作， 是否忽略摇杆
--								示例：{"SetForbiddenOperation", true, true},

-- ChangeNpcCamp				说明：改变 Npc所在阵营
--								参数：szNpcGroup Npc所在的组, nCamp 阵营
--								示例：{"ChangeNpcCamp", "BOSS", 1},

-- SetHeadVisiable				说明：设置 Npc头顶是否可见
--								参数：szNpcGroup Npc所在的组, bShow 是否显示, nDealyTime 延迟时间
--								示例：{"SetHeadVisiable", "BOSS", false, 10},

-- SetNpcBloodVisable			说明：设置 Npc血条是否可见
--								参数：szNpcGroup Npc所在的组, bShow 是否显示, nDealyTime 延迟时间
--								示例：{"SetNpcBloodVisable", "BOSS", false, 10},

-- SetNpcPos					说明：设置Npc位置
--								参数：szNpcGroup Npc所在的组，nX，nY
--								示例：{"SetNpcPos", "BOSS", 111, 222},

-- SetAllUiVisiable				说明：设置 UI 是否显示或隐藏
--								参数：bShow true显示，false 隐藏
--								示例：{"SetAllUiVisiable", false},

-- Random 						说明：随机解锁
--								参数：{nRandom1, nLockId1}, {nRandom2, nLockId2}, {nRandom3, nLockId3}, ...
--								示例：{"Random", {1000, 10}, {2000, 11}，,  这个代表 执行此锁的时候有 1000/1000000 的概率启动 10号锁， 2000/1000000 的概率启动11号锁，数量可一直加

-- IfCase						说明：条件控制，
--								参数：条件,子语句
--								示例: {"IfCase", "self.nLevel > 0", {"AddNpc", 1, 20, 3, "guaiwu", "yelang1"}, ....},
-- 								条件类型：
-- 											self.nLevel 当前玩家平均等级
-- 											self.nEnemyLevel 怪的等级
-- 											self.nPassedTime 当前副本经过的时间(秒)
-- 											self.nPlayerCount 当前地图总人数
--											self.nStarLevel 单机关卡有用（当前关卡的星级数量，0 1 2 3）
--											self.nFubenLevel 当前副本等级 （对于单机关卡，1是普通关卡，2是精英关卡;对于随机副本，1~3为难度模式）

-- IfPlayer						说明：玩家条件控制
--								参数：玩家条件,符合条件的人数(-1为要求全部玩家符合),子语句
--								示例: {"IfPlayer", "pPlayer.nLevel >= 60", -1, {"AddNpc", 1, 20, 3, "guaiwu", "yelang1"}, ...}
-- 								条件类型:
-- 								pPlayer.nLevel 玩家等级
-- 								pPlayer.nFaction 玩家门派
-- 								... 玩家所有脚本接口都可用

-- IfTrapCount					说明：踩Trap点数量控制，如果已踩trap点的玩家数量满足条件，则触发事件
-- 								参数：szClassName trap点名, nNeedCount 需要踩的数量, -1 表示全部玩家, ...
-- 								示例：{"IfTrapCount", "Trap9", 3, {"AddNpc", 1, 20, 3, "guaiwu", "yelang1"}, ...}

-- PauseLock					说明：暂停指定时间锁
--								参数：nLockId 锁 Id
--								示例：{"PauseLock", 28},

-- ResumeLock					说明：恢复指定时间锁
--								参数：nLockId 锁 Id
--								示例：{"ResumeLock", 28},

-- SetShowTime					说明：倒计时显示指定锁的剩余时间
--								参数：nLockId 锁Id, bNotNextFrame,szTimeTitle, bCache
--								示例：{"SetShowTime", 28, nil, "倒计时"},

-- StopEndTime					说明：暂停显示的倒计时
--								参数：无
--								示例：{"StopEndTime"},

-- SetTargetInfo				说明：显示当前提示内容，可插入一个锁的倒计时剩余时间
--								参数：szInfo 内容， nLockId 要嵌入的锁, bNotNextFrame, bCache
--								示例：{"SetTargetInfo", "还有%s秒10号锁就解开了！", 10},

-- AddAnger						说明：给所有玩家增加怒气
--								参数：nAnger 增加的怒气值
--								示例：{"AddAnger", 10},  增加10点怒气

-- DoDeath						说明：杀死 Npc
--								参数：szGroup 要杀死的Npc所在组
--								示例：{"DoDeath", "wall"},  杀死 wall 组的 Npc

-- UnLock 						说明：解锁
-- 								参数：nLockId 要解锁Id
-- 								示例：{"UnLock", 10}, 解一次10号锁

-- SetBossBlood 				说明：显示 Boss 血条
-- 								参数：szGroup 要显示的BOSS所在的组, nBloodLevel 要显示的血条的层数(现在最大5层), nDealyTime 延迟时间
-- 								示例：{"SetBossBlood", "BOSS", 5, 1},

-- ChangeNpcFightState			说明：改变Npc战斗状态
--								参数：szGroup 要改变Npc所在的组, nFightState 战斗状态(0非战斗状态， 1战斗状态， 2 幽灵状态), nDealyTime 延迟生效时间
--								示例：{"ChangeNpcFightState", "BOSS", 0, 5},

-- SetNpcProtected				说明：改变Npc保护状态
--								参数：szGroup 要改变的Npc所在组, nProtected 是否为保护状态（0非保护，1保护）
--								示例：{"SetNpcProtected", "guaiwu", 1},

-- SetPlayerProtected			说明：改变玩家的保护状态
--								参数：nProtected 是否为保护状态（0非保护，1保护）
--								示例：{"SetPlayerProtected", 1},

-- RemovePlayerSkillState		说明：移除所有玩家技能状态
--								参数：nSkillId 技能Id
--								示例：{"RemovePlayerSkillState", 110},

-- SaveNpcInfo					说明：当npc死亡时，保存它死亡时的位置和朝向, 添加Npc的时候可以使用 SAVE_POS 和 SAVE_DIR
--								参数：szGroup 要保存的Npc所在的组
--								示例：{"SaveNpcInfo", "BOSS"},

-- NpcAddBuff					说明：给Npc添加 buff
--								参数：szGroup 要添加的Npc所在组，nSkillId 技能Id, nSkilLevel 技能等级, nTime 持续时间
--								示例：{"NpcAddBuff", "BOSS", 110, 1, 100},

-- NpcRemoveBuff				说明：移除Npc buff
--								参数：szGroup 操作的Npc，nSkillId 移除的技能Id
--								示例 {"NpcRemoveBuff", "BOSS", 110},

-- AddBuff 						说明：给玩家添加 buff
--								参数：nSkillId 技能Id, nSkilLevel 技能等级, nTime 持续时间, bSaveDeath 是否死亡保留, bForce 是否强制替换
--								示例：{"AddBuff", 110, 1, 10, 0, 0},

-- NpcFindEnemyUnlock			说明：设置发现目标解锁
--								参数：szGroup 要设置Npc所在组, nLockId 解锁Id, nDealyTime 延迟生效时间(单位：秒)
--								示例：{"NpcFindEnemyUnlock", "BOSS", 1},

-- NpcFindEnemyRaiseEvent		说明：设置发现目标抛事件
--								参数：szGroup 要设置Npc所在组, bDelete 触发后是否删除自己, szEvent 事件, ... 其他参数
--								示例：{"NpcFindEnemyRaiseEvent", "Circle", true, "AddBuff", 123},

-- OpenGuide					说明：打开指引
--								参数：解锁的ID, 指引的箭头 文字描述 窗口名称 控件名称 偏移位置  是否不可点击操作界面  是否黑屏 是否要隐藏语音引导
--								示例：{"OpenGuide", nil, "PopT", "xxx", "HomeScreenBattle", "Attack", {10, 10}, true, true, false},

-- SetGuidingJoyStick			说明：是否能在UI下使用摇杆
--								参数：是否
--								示例：{"SetGuidingJoyStick", true},

-- SetSceneSoundScale			说明：设置场景声音的音量
--								参数：百分比
--								示例：{"SetSceneSoundScale", 100},

-- SetDialogueSoundScale		说明：设置Npc声音的音量
--								参数：百分比
--								示例：{"SetDialogueSoundScale", 100},

-- SetEffectSoundScale			说明：设置特效声音的音量
--								参数：百分比
--								示例：{"SetEffectSoundScale", 100},

-- SetNpcRange					说明：设置Npc视野范围和活动范围
--								参数：szNpcGroup Npc所在组, nVisionRadius 视野范围（0表示不设置）, nActiveRadius 活动范围（0表示不设置）, nDealyTime 延迟生效时间
--								示例：{"SetNpcRange", "BOSS", 10000, 10000, 4},

-- SetNpcDir					说明：设置Npc朝向
--								参数：szNpcGroup Npc所在组，nDir方向
--								示例：{"SetNpcDir", "BOSS", 20},

-- SetPlayerDir					说明：设置玩家朝向（只能在单机情况下使用）
--								参数：nDir 方向
--								示例：{"SetPlayerDir", 20},

-- DropBuffer					说明：掉落buff
--								参数：nX （坐标x，支持标签 [NpcGroup=BOSS]）, nY（坐标y）, szBuffInfo （buff内容，如：1|20;2|30;5   1号buff概率20   2号buff概率30   总共随机5次）
--								示例：{"DropBuffer", 1000, 2000, "1|20;2|30;5"},

-- DoCommonAct					说明：让Npc做动作
--								参数：szGroup Npc所在组，nActId 动作Id（找华强要）, nActEventId 动作事件ID（找华强要）, bLoop 是否循环( 1 循环， 0 不循环)，nFrame 播放帧数（0 使用默认帧数）
--								示例：{"DoCommonAct", "BOSS", 21, 2001, 1, 0},

-- SetNearbyRange				说明：设置同步范围
--								参数：nRange 同步范围
--								示例：{"SetNearbyRange", 1},

-- PlayerBubbleTalk				说明：让玩家发出近聊
--								参数：szMsg 近聊内容
--								示例：{"PlayerBubbleTalk", "哈哈哈"},

-- HomeScreenTip				说明：金色背景的中屏提示
--								参数：szTitle 标题, szInfo 内容, nShowTime 显示时间（单位：秒）, nDealyTime 延迟多久后显示（单位：秒）
--								示例：{"HomeScreenTip", "第一行标题", "第二行内容", 5, 2},

-- DoFinishTaskExtInfo			说明：完成指定类型的任务目标（仅能服务端副本可用）
--								参数：szExtInfo 要完成的任务目标
--								示例：{"DoFinishTaskExtInfo", "sssssss"}, 当前副本内的所有人完成目标为 sssssss 的任务

-- 单机副本支持接口
-- AddNpcWithAward				说明：添加 Npc，并且此Npc会随机分配掉落此npc对应奖励等级的物品
--								参数：nIndex npc序号(可用NUM内参数), nNum 添加数量(可用NUM内参数), nLock 死亡解锁Id, szGroup 所在分组名, szPointName 刷新点名, nAwardLevel 奖励等级, nDir Npc方向, nDealyTime 延迟添加, nEffectId 特效Id, nEffectTime 特效时间
--								示例：{"RaiseEvent", "AddNpcWithAward", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", 1, 30, 2, 206, 2},

-- ShowTaskDialog				说明：播放剧情对话并解锁制定锁
--								参数：nLockId 锁Id, nDialogId 对话Id, bIsOnce 是否只播放一次, nDealyTime 延迟一段时间后播放，小于0或者不填表示立即播放
--								示例：{"RaiseEvent", "ShowTaskDialog", 2, 10, true, 1},

-- SetFailMsg					说明：在失败界面显示副本失败原因，只会显示最后一次设置的内容
-- 								参数：szMsg 要显示的失败原因
--								示例：{"RaiseEvent", "SetFailMsg", "长得丑，所以~~"},

-- CloseDynamicObstacle			说明：关闭动态障碍
--								参数 szObsName 动态障碍名
--								示例：{"RaiseEvent", "CloseDynamicObstacle", "obs1"},

-- NpcBubbleTalk				说明：让Npc喊话
--								参数：szNpcGroup Npc所在组, szContent 喊话内容, nDuration 持续时间, nDealyTime 延迟喊话秒数, nMaxCount 最大喊话数量（不填则不限制）
--								示例：{"NpcBubbleTalk", "guaiwu1", "何人擅闯恶人谷！莫非是找死不成？", 3, 1, 1},

-- RegisterTimeoutLock			说明：注册计时锁
--								参数：无
--								示例：{"RaiseEvent", "RegisterTimeoutLock"},

-- ShowPlayer					说明：是否显示主角
--								参数：bShow 是否显示
--								示例：{"RaiseEvent", "ShowPlayer", false},

-- ShowPartnerAndHelper			说明：是否显示同伴和助战者
--								参数：bShow 是否显示
--								示例：{"RaiseEvent", "ShowPartnerAndHelper", false},

-- FllowPlayer					说明：是否跟随玩家
--								参数：szNpcGroup, bFllow
--								示例：{"RaiseEvent", "FllowPlayer", true},

-- PlayerRunTo					说明：让玩家走到一个点
--								参数：nX, nY
--								示例：{"RaiseEvent", "PlayerRunTo", 1110, 2220},

-- ChangeAutoFight				说明：切换自动战斗状态
--								参数：bAutoFight (true/false)
--								示例：{"RaiseEvent", "ChangeAutoFight", true},

-- CallPartner					说明：解开禁止同伴操作，同时召唤同伴
--								参数：无
--								示例：{"RaiseEvent", "CallPartner"}

-- PartnerSay					说明：让同伴说话
--								参数：szInfo 说话内容, nDuration 持续时间, nCount 同伴数量
--								示例：{"RaiseEvent", "PartnerSay", "2个同伴说3喵", 3, 2},

-- 组队副本支持接口
-- AddMissionScore				说明：增加事后奖励分数  （组队副本 随机副本可用）
--								参数：nScore 增加的分数，这个是给所有玩家增加分数的接口
--								示例：{"RaiseEvent", "AddMissionScore", 1},

-- CopyPlayer					说明：Call玩家分身（随机副本可用）
--								参数：（与AddNpc接口参数类似） Lock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime
--								示例：{"RaiseEvent", "CopyPlayer", 3, "guaiwu", "RandomFuben1_1_1",false, 0 , 0, 9004, 0.5},

-- DropAward					说明：进行一次掉落 （随机副本可用）
--								参数：szDropFile 掉落表路径, nPosX, nPosY, szMsg 如果物品需要世界喊话，则喊话内容为它 如："%s 在凌绝峰探险中不慎滑倒，竟然发现了 %%s #001" %s 为玩家名 %%s 为道具名可插入表情
--								示例：{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 1000, 2000, "%s 在凌绝峰探险中不慎滑倒，竟然发现了 %%s #001"},

-- DropCard                     说明：进行收集活动卡片 （随机副本可用）
--                              参数：nCardId, nRate(最大为1000000，-1为必掉)
--                              示例：{"RaiseEvent", "DropCard", 123, -1},

--CheckCollectionAct            说明：检查收集活动是否正在进行
--                              参数：子语句
--                              示例: {"RaiseEvent", "CheckCollectionAct", {"AddNpc", 1, 20, 3, "guaiwu", "yelang1"}, {"AddNpc", 1, 20, 3, "guaiwu", "yelang1"}, ...}
--

--SetKickoutPlayerDealyTime     说明：将地图上所有玩家延迟踢出地图，必须在GameWin或GameLost之前用，一般可以在1号锁用，用了之后会在GameWin或GameLost之后延迟踢玩家，nTime > 0
--                              参数：子语句
--                              示例: {"SetKickoutPlayerDealyTime", nTime},
--

--NpcRandomTalk     			说明：随机喊话，喊话内容在 TEXT_CONTNET 中配置
--                              参数：szNpcGroup Npc所在组, szContentGroup 喊话内容组, nDuration 持续时间, nDealyTime 延迟喊话秒数, nMaxCount 最大喊话数量（不填则不限制）
--                              示例: {"NpcRandomTalk", "guaiwu1", "NpcTalk", 3, 1, 1},
--

--SetPlayerDeathDoRevive        说明：设置玩家死亡后进行原地复活或者出生点复活，一般可以在1号锁用
--                              参数：nTime 多少秒之后复活，szMsg 延迟复活提示信息，默认为"您将在 %d 秒后复活"，bReviveHere为true原地复活，否则出生点复活
--                              示例: {"SetPlayerDeathDoRevive", 5, "您将在 %d 秒后复活", true},

--AddFurniture       	   		说明：摆家具
--                              参数：家具索引和组
--                              示例: {"AddFurniture", 1, "a"}

--DeleteFurniture       	    说明：删除家具
--                              参数：家具组
--                              示例: {"DeleteFurniture", "a"}

--AddFurnitureGroup       	    说明：按组摆家具
--                              参数：家具组
--                              示例: {"AddFurnitureGroup", "a"}

-- PlayHelpVoice	说明：播放帮助语音
--			参数：语音路径
--			示例：{"PlayHelpVoice", "voicepath"},

-- DoPlayerCommonAct			说明：让玩家做动作
--								参数：nActId 动作Id（找华强要）, nActEventId 动作事件ID（找华强要）, bLoop 是否循环( 1 循环， 0 不循环)，nFrame 播放帧数（0 使用默认帧数）
--								示例：{"DoPlayerCommonAct", 21, 2001, 1, 0},

-- SetNumber                    说明：自定义NUM，只能添加新的，不能修改已有的，防止误操作
--                              参数：NUM的key，数值
--                              示例: {"SetNumber", "NpcFenShen1", 101}

-- SetActiveForever             说明：设置NPC是否一直处于活动状态(会牵连该NPC所在的9个Region范围内NPC都active,这样的NPC太多会影响效率)
--                              参数：szNpcGroup, nActive(1为永久活跃)
--                              示例: {"SetActiveForever", "NpcFenShen1", 1}

-- 可用变量 NUM 的地方
-- 每个 LOCK 的 nTime  nNum
-- AddNpc 的参数 nIndex 和 nNum
-- 单机副本的 AddNpcWithAward 参数 nIndex

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM =
{
	NpcIndex1	 	= {1, 1},
	NpcIndex2	 	= {2, 2},
	NpcIndex3	 	= {3, 3},
	NpcIndex4	 	= {4, 4},
	NpcIndex5	 	= {5, 5},
	NpcIndex6	 	= {6, 6},
	NpcNum1 		= {3, 6},
	NpcNum2 		= {4, 4},
	NpcNum3 		= {5, 10},
	NpcNum4 		= {5, 5},
	NpcNum5 		= {1, 2},
	NpcNum6 		= {1, 1},
	LockNum1		= {3, 6},
	LockNum2		= {7, 12},
	LockNum3		= {1, 1},
}

tbFubenSetting.ANIMATION =
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC =
{
	[1] = {nTemplate = 3, nLevel = 20, nSeries = 1},
	[2] = {nTemplate = 4, nLevel = 20, nSeries = 2},
	[3] = {nTemplate = 5, nLevel = 20, nSeries = 3},
	[4] = {nTemplate = 6, nLevel = 20, nSeries = 4},
	[5] = {nTemplate = 7, nLevel = 1, nSeries = 0},
	[6] = {nTemplate = 12, nLevel = 1, nSeries = 0},
}

-- 文字内容集
tbFubenSetting.TEXT_CONTNET =
{
	NpcTalk =
	{
		[1] = "1111",
		[2] = "2222",
		[3] = "3333",
	},
}

tbFubenSetting.LOCK =
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 5, nNum = 0,
		--tbPrelock 前置锁，激活锁的必要条件{1, 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent =
		{
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent =
		{
			--{"RaiseEvent", "AddBoss",}, (nIndex, nLock, szGroup, szPointName, szAwardType)
			--{"RaiseEvent", "AddNpcWithoutAward",}, (nIndex, nNum, nLock, szGroup, szPointName, bRevive)
		},
	},
	[2] = {nTime = 0, nNum = 1,
			tbPrelock = {1},
			tbStartEvent =
		{
			{"SetFubenType", "Protect", 3},
			--{"AddNpc", "NpcIndex1", 1, 2, "1_1_1", "1_1_1"},
			{"BlackMsg", "战斗开始了！撒！一狗！消灭他们！"},
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock2", 2},
			{"SetTargetPos", 118, 814},
			--{"PlayCameraAnimation", 1, 2},
		},
			tbUnLockEvent =
		{
			{"RaiseEvent", "Log", "unlock lock 2"},
			{"BlackMsg", "你身上有八哥！我要对你进行纷争根绝！武力介入开始！"},
			{"RaiseEvent", "AddNpcWithAward", "NpcIndex1", "NpcNum1", 3, "Protect", "1_1_1", 1},
		},
	},
	[3] = {nTime = 0, nNum = "NpcNum1",
			tbPrelock = {2},
			tbStartEvent =
		{
			--{"MoveCamera", 3, 2, 28.06, 34.81, 20.03, 60.44, 81.254, 178.59},
		},
			tbUnLockEvent =
		{
			{"RaiseEvent", "Log", "unlock lock 3"},
			{"BlackMsg", "西南方传来了一段话：女施主，等等，面试完这个就到你了"},
			{"RaiseEvent", "AddNpcWithAward", "NpcIndex2", "NpcNum2", 4, "1_1_1", "1_1_2", 2},
		},
	},
	[4] = {nTime = 0, nNum = "NpcNum2",		-- 总计时
		tbPrelock = {3},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 4"},
			{"BlackMsg", "这个应该很简单的吧？这里改一下就好了啊！你惹怒了他们！"},
			{"RaiseEvent", "AddNpcWithAward", "NpcIndex3", "NpcNum3", 5, "1_1_1", "1_1_3", 3},
		},
	},
	[5] = {nTime = 0, nNum = "NpcNum3",
		tbPrelock = {4},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			--{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 5"},
			{"BlackMsg", "南方忽然传来了一道声音：来人啊！抓住吊起来打！"},
			{"RaiseEvent", "AddNpcWithAward", "NpcIndex4", "NpcNum4", 6, "1_1_1", "1_1_4", 4},
			{"ChangeNpcAi", "guaiwu", "Move", "Path1", 4, 1, 1, 1},
		},
	},
	[6] = {nTime = 0, nNum = "NpcNum4",
		tbPrelock = {5},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "东边忽然出现了一股灵压…这查克拉的感觉…马萨卡…"},
			{"RaiseEvent", "AddNpcWithAward", "NpcIndex5", "NpcNum5", 7, "1_1_1", "1_1_5", 5},
		},
	},
	[7] = {nTime = 0, nNum = "NpcNum5",
		tbPrelock = {6},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			{"BlackMsg", "你的前面忽然出现了奇怪的物体…难道是…"},
			{"AddNpc", "NpcIndex6", 1, 8, "1_1_1", "1_1_5"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent =
		{
			--{"BlackMsg", "哟西！成功解开诚哥的银行卡密码！答案是233333！"},
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "哈哈哈！天真！那只是本座的小伙伴分身！再来揍我啊！"},
			{"AddNpc", "NpcIndex5", "NpcNum5", 9, "1_1_1", "1_1_5"},
		},
	},
	[9] = {nTime = 0, nNum = "NpcNum5",
		tbPrelock = {8},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 9"},
			--{"RaiseEvent", "CheckResult"},
			{"GameWin"},
		},
	},
	[10] = {nTime = 300, nNum = 0,
		tbPrelock = {1},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"RaiseEvent", "ShowCurAward"},
			{"RaiseEvent", "Log", "unlock lock 10, game lost !!"},
			{"GameLost"},
		},
	},
}
