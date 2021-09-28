--GiveWineConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  GiveWineConstant.lua
 --* Author:  liucheng
 --* Modified: 2016年2月11日 15:49:14 
 --* Purpose: Implementation of the class GiveWineConstant
 -------------------------------------------------------------------*/

WINE_ITEM_ID = 6200024
WINE_BUFFER_ID = 143
WINE_ADD_EXP_CD = 9
WINE_DRINK_LEVEL = 30
FREE_WINE_GET_LEVEL = 10
FREE_WINE_GET_SPAN = 3*3600 + 3500
FREE_WINE_GET_NUM = 1

WINE_ERR_GETWINE_AGAIN 		= -1 	--不能重复领取
WINE_ERR_GET_NO_ACTIVITY 	= -2 	--不在活动时间内不能领取
WINE_ERR_DRINK_MAX			= -3 	--喝过三坛了
WINE_ERR_DRINK_CD			= -4 	--物品使用cd
WINE_ERR_LEVEL_LIMIT		= -5	--等级不足
WINE_ERR_DRINK_NO_ACTIVITY	= -6 	--不在活动时间内不能喝酒
WINE_GET_SUCC				= -7 	--领取成功
WINE_DRINK_SUCC				= -8 	--饮用成功
WINE_ERR_GET_LEVEL_LIMIT 	= -9	--领取美酒等级不足

