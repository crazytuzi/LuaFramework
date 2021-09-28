--AdoreConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  AdoreConstant.lua
 --* Author:  seezon
 --* Modified: 2015年7月29日
 --* Purpose: 膜拜常量定义
 -------------------------------------------------------------------*/

ADORE_LEVEL_LIMIT	= 25				--膜拜等级限制
ADORE_FREE_TIME = 1
ADORE_INGOT_TIME = 3
--定义错误号
ADORE_ERR_ID_INGOT_NOT_ENOUGH = -1			--元宝不足
ADORE_ERR_ID_NO_TIMES = -2			--没有膜拜次数
ADORE_ERR_ID_SUCC = -3			--提示玩家膜拜成功
ADORE_ERR_NO_FACTION = -4			--没有帮派，无法领取领地战奖励
ADORE_ERR_NOT_SHA = -5			--只有沙巴克成员才能膜拜沙巴克城主
ADORE_ERR_NOT_LEVEL = -6			--您的等级不足%s,无法操作


--膜拜对象
ADORETYPE = {
	ZHONGZHOU			= 1,	--中州王
	SHABAKE			= 2,	--沙巴克城主
}