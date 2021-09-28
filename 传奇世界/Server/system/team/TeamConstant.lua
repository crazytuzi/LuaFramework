--TeamConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  TeamConstant.lua
 --* Author:  Wang Lin
 --* Modified: 2014年4月3日 15:49:14
 --* Purpose: Implementation of the class TeamConstant
 -------------------------------------------------------------------*/

TEAM_MAX_MEMBER = 10 				--队伍人数限制
TEAM_AROUND_RAD = 50
TEAM_LEVEL_LIMIT = 9				--组队等级限制
TEAM_MAX_APPLY = 20 				--同一个队伍的申请列表，最多接受20条入队申请
TEAM_MAX_INVITE = 20				--单个玩家最多只能收到20个邀请
TEAM_MAX_APPLY_SAVE_TIME = 60 		--队伍申请记录过期时间
TEAM_MAX_INVITE_SAVE_TIME = 60 		--邀请记录保存时间
TEAM_FAST_ENTER_APPLYS = 3 			--快速入队时发送多少条入队申请
TEAM_FAST_RECRUIT_INVITES = 5 		--快速招募时发送多少条邀请 
TEAM_FAST_OPERATE_CD = 10
TEAM_SPE_MAX_COUNT = 30 			--根据队伍目标每次最多能获取多少条队伍信息
TEAM_AUTO_ENTER_CD = 10 			--自动匹配队伍的间隔时间
TEAM_AUTO_ENTER_MAX = 10 			--切换地图匹配队伍 最多匹配多少个队伍

--------------TEAM_TIPS---------------
TEAM_ERR_HAS_APPLYED = -1 			--已经申请过了
TEAM_ERR_MAX_MEMBER = -2 			--已经达到最大队伍人数
TEAM_ERR_HAS_JOIN_TEAM = -3 		--已经加入别的队伍
TEAM_ERR_NOT_LEADER = -4 			--不是队长
TEAM_ERR_HAS_INVITED = -5 			--已经邀请过了
TEAM_ERR_OUT_OF_DATE_OFFLINE = -6 	--不在线操作已过期
TEAM_ERR_OUT_OF_DATE_NOTLEADER = -7 --不是队长操作过期
TEAM_ERR_INVITE_REFUSED = -8 		--邀请被拒绝
TEAM_ERR_APPLY_REFUSED = -9 		--申请被拒绝
TEAM_ERR_IS_LEADER = -10 			--不能开除队长
TEAM_ERR_IS_OFFLINE = -11 			--离线不能提升队长
TEAM_ERR_NOT_IN_TEAM = -12 			--没有加入队伍
TEAM_ERR_INVITE_OUT_DATE = -13 		--邀请过期
TEAM_ERR_OFFLINE = -14 				--不在线
TEAM_ERR_HAS_TEAM = -15 			--已经有队伍了
TEAM_ERR_NOT_SAME_TEAM = -16 		--不在同一个队伍
TEAM_ERR_CAN_APPLY_JOIN = -17		--你已经有队伍了不能加入别的队伍
TEAM_ERR_APPLY_OUT_DATE = -18 		--申请过期
TEAM_ERR_NO_TEAM = -19				--当前队伍不存在！

TEAM_TIP_APPLYED_SUCCEED = 1 		--申请入队成功
TEAM_TIP_INVITE_SUCCEED = 2 		--邀请入队成功
TEAM_TIP_NEW_MEM_JOIN =3 			--有人加入队伍提示
TEAM_TIP_JOIN_SUCCEED = 4 			--加入队伍成功
TEAM_TIP_REMOVE_MEMBER = 5 			--队员离开队伍
TEAM_TIP_CHANGGE_LEADER = 6 		--变换队长
TEAM_TIP_LEAVE_TEAM = 7				--你离开队伍
TEAM_TIP_LEVEL_NOTENOUGH = 8		--邀请对方组队  对方等级不够
TEAM_TIP_OWNLEVEL_NOTENOUGH = 9		--自己等级不够  想邀请对方组队
TEAM_TIP_MEMINFO_ERR = 10			--memberInfo 出错
TEAM_TIP_INVITE_SEND_SUCCEED = 11 	--你已经成功向对方发起组队邀请
TEAM_TIP_APPLYED_SEND_SUCCEED = 12 	--入队申请已经发出
TEAM_TIP_PLAYER_BUSY = 13			--该玩家繁忙，请稍后再试！
TEAM_TIP_TEAM_BUSY = 14				--该队伍繁忙，请稍后再试！
TEAM_TIP_TEAM_NO_APPLY = 15 		--当前队伍没有申请记录
TEAM_TIP_NO_FAST_ENTER_TEAM = 16 	--没有适合快速入队的队伍
TEAM_TIP_NO_FREE_MEMBER = 17 		--没有适合快速招募的人员
TEAM_TIP_TOO_OFTEN = 18 			--操作过于频繁
TEAM_TIP_INTO_LEVEL_NOTENOUGH = 19 	--进入队伍  等级不够
TEAM_TIP_OTHER_BEGIN_COPY = 20 		--玩家准备进入副本
TEAM_TIP_OWN_BEGIN_COPY = 21 		--你准备进入副本


TEAM_DATA_SERVER_ID = 1
--------------TEAM_TIPS---------------

--------------Team operate------------
TEAM_OPT_LOGIN = 1
TEAM_OPT_INVALID = 2
TEAM_OPT_OUT = 3
TEAM_OPT_ACTIVE = 4
TEAM_OPT_OFF = 5
TEAM_OPT_SWITCH = 6

TEAM_OPT_CREATE = 10
TEAM_OPT_INVITE = 11
TEAM_OPT_APPLY = 12
TEAM_OPT_REMOVE = 13
TEAM_OPT_LEAVE = 14
TEAM_OPT_GET_INFO = 15
TEAM_OPT_CHANGE_LEADER = 16
TEAM_OPT_NEAR = 17
TEAM_OPT_AUTOINVITED = 18
TEAM_OPT_AROUND = 19
TEAM_OPT_POSMAP = 20
TEAM_OPT_UPDATE_POS = 21
TEAM_OPT_ANSWER_INIVITE = 22
TEAM_OPT_GET_TEAM_APPLY = 23

TEAM_OPT_LEVEL = 30
TEAM_OPT_WING = 31
TEAM_OPT_EQUIP = 32
TEAM_OPT_SURFACE = 33


----------------队伍目标-------------
TeamTargetType = {
NoTarget = 1, 			--无目标
MainTask = 2, 			--主线升级
DartEscort = 3, 		--组队镖车
DartLoot = 4, 			--组队劫镖
MultiGuard = 5, 		--多人守卫
MultiGuardDif = 6, 		--多人守卫困难
MultiGuardHard = 7, 	--多人守卫炼狱
PKKill = 8, 			--PK杀人
WorldBoss = 9, 			--世界boss
ManorFight = 10, 		--领地争夺
ShaWar = 11, 			--沙城争霸
}

--OldTreasure = 6, 		--远古宝藏
--队伍目标定义
--1.无目标2.主线升级3.组队镖车4.组队劫镖 5.多人守卫普通 6.多人守卫困难  7 多人守卫炼狱 8.PK杀人 9.世界BOSS  10.领地争夺 11.沙城争霸
