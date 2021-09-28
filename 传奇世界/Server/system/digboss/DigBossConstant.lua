
--DigBossConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  DigBossConstant.lua
 --* Author:  liucheng
 --* Modified: 2015年6月1日 15:49:14
 --* Purpose: Implementation of the class DigBossConstant
 -------------------------------------------------------------------*/

DIG_MAX = 3				--同一个boss可挖掘的最大次数

DIG_PROP_ID = 1021		--boss挖掘消耗的挖掘符ID

DIG_INGOT = 30			--boss挖掘消耗元宝数量

DIG_FIRST_ID = 1101		--boss首次挖掘获取的道具ID
DIG_FIRST_NUM = 10 		--boss首次挖掘获取的道具的数目

DIG_DROP_ID = 904		--boss挖掘掉落ID

DIG_NO_FREE_SLOT = -1 	--背包已满
DIG_ERR_INGOT = 6		--元宝不足
DIG_MSG_ITEM_USE = 3	--消耗某道具

EVENT_BASIC_SETS = 1 	--物品获得使用基本的事件
DIG_MSG_ITEM_GET = 2 	--获得某物品

DIG_SPE_ITEM_GET = {6004,6005,6006}		--几种特殊掉落需要跑马灯提示
DIG_BROAD_MSG_ID = 38	--boss挖掘跑马灯消息ID

DIG_INGOT_RECORD = 34	--boss挖掘的元宝日志
