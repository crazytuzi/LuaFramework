--SpillFlowerConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  SpillFlowerConstant.lua
 --* Author:  liucheng
 --* Modified: 2015年8月26日 15:49:14
 --* Purpose: Implementation of the class SpillFlower 
 -------------------------------------------------------------------*/

BASIC_FLOWER_ITEM_ID = 1490

SPILLFLOWER_SUCC = 13
SPILLFLOWER_OFF_LINE = 14
SPILLFLOWER_BROAD_MSG_ID = 45

--YANHUO  35  ITEM  1022

SPILLFLOWER_PUBLIC_SPACE = 1
SPILLFLOWER_MAX_RECORD = 10
SPILLFLOWER_LEVEL_LIMIT = 24

SPILLFLOWER_ERR_TIMES_LIMIT = -8   		--送花次数不足
SPILLFLOWER_ERR_INGOT_LIMIT = -34 		--送花元宝不足
SPILLFLOWER_ERR_TO_SELF = -52 			--不能给自己送花
SPILLFLOWER_ERR_LEVEL_LIMIT = -58 		--送花等级不能低于24


CALL_MEMBER_SPACE = 180			--两次使用穿云箭的间隔
CALL_MEMBER_MAX = 10 			--穿云箭最多能传送多少人
ARROW_ITEM_ID = 1080

CALL_MEMBER_NO_FACTINO = 15
CALL_MEMBER_IN_CD		= 23 		--同行会已有人使用
CALL_MEMBER_ERR_STATION_OUT = 25 	--守等状态无法被传送
CALL_MEMBER_ERR_STATION = 26 		--驻守等状态无法使用
CALL_MEMBER_COPYMAP	= 17			--当前区域无法使用此道具
CALL_MEMBER_IN_COPY	= 18 			--请结束战斗后再支援
CALL_MEMBER_ANSWER		= 19 		--%s 已响应您的召唤
CALL_MEMBER_SUCC 		= 3

CALL_MEMBER_ERR_MAX = 24 		--人数达到最大
CALL_MEMBER_ERR_FACTION = 25 	--数据错误


---operation
PLAYER_LOGIN = 1