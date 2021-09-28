--FightTeamConstant.lua

FIGHTTEAM_MAX_TEAM_NUM = 3
FIGHTTEAM_MIN_LEVEL = 40
FIGHTTEAM_NEED_MONEY = 300000

--战队职务
FIGHTTEAM_POSITION =
{
	Leader				= 1,	--队长
	Mem			= 2,	--成员
}

---------------------------error code---------------------------
FIGHTTEAM_NEED_LEVEL = -1					 --XXX等级不够XXX级
FIGHTTEAM_NO_TEAM_STATE = -2			 --不在组队状态，操作失败
FIGHTTEAM_NO_TEAM_LEADER = -3			 --不是队伍队长，操作失败
FIGHTTEAM_NO_NAME = -4					 --请输入战队名字
FIGHTTEAM_HAS_OTHER_TEAM = -5					 --XXX已加入其他战队
FIGHTTEAM_MEMBER_TOO_FAR = -6					 --XXX离得太远
FIGHTTEAM_NAME_TOO_LONG = -7					 --战队名字太长
FIGHTTEAM_INGOT_NOT_ENOUGH = -8					 --元宝不足XXX，操作失败
FIGHTTEAM_MONEY_NOT_ENOUGH = -9					 --金币不足XXX，操作失败
FIGHTTEAM_CREATE_NEED_NUM = -10					 --创建战队人数必须为XX人，操作失败
FIGHTTEAM_TARGET_PLAYER_OFFLINE = -11					 --该玩家不在线，操作失败
FIGHTTEAM_TARGET_PLAYER_HAS_TEAM = -12					 --该玩家已加入其他战队，操作失败
FIGHTTEAM_NO_DROIT = -13								 --您无权限操作
FIGHTTEAM_NAME_EXISTED = -14								 --战队名重复
FIGHTTEAM_CANNOT_OP = -15								 --禁止操作时期
FIGHTTEAM_OUT_MAX_TEAM_NUM = -16								 --战队人数已满，操作失败

FIGHTTEAM_CREATE_TEAM_SUC = 1					--恭喜XX成功创建XX战队
FIGHTTEAM_ADD_TEAM_SUC = 2						--欢迎XX加入XX战队，战队如虎添翼
FIGHTTEAM_REMOVE_TEAM_SUC = 3						--XX将XX移除战队
FIGHTTEAM_LEAVE_TEAM_SUC = 4						--XX离开了战队
FIGHTTEAM_REFUSE = 5						--XX拒绝加入战队
