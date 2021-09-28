-- Filename: RuneCompoundConst.lua
-- Author: zhangqiang
-- Date: 2016-07-26
-- Purpose: 符印合成数据

module("RuneCompoundConst", package.seeall)

ShowEntry = true      --是否打开入口


--合成符印类型
RuneCompoundType = {
	kHorseRuneType = 1,
	kBookRuneType  = 2,

}

--RuneCompoundLayer上菜单索引
MenuItemIdx = {
	kHorseRuneIdx = 1,
	kBookRuneIdx  = 2,
}

--符印合成事件名
EventName = {
	RUNE_COMPOUND_SUCCESS = "RUNE_COMPOUND_SUCCESS",
	RUNE_COMPOUND_COST_ITEM_PUSH = "RUNE_COMPOUND_COST_ITEM_PUSH",
}