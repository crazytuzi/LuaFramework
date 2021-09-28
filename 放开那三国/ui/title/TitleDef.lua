-- FileName: TitleDef.lua 
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号系统 常量Def

module("TitleDef",package.seeall)

-- 称号类型 signtype 1普通称号，2活动称号，3跨服称号
kTitleTypeNormal 	= 1
kTitleTypeActivity 	= 2
kTitleTypeCross 	= 3

-- 称号时效类型 time_type 1 永久 2 持续时间（精确到小时)
kTimeTypeForever 	= 1
kTimeTypeLimited 	= 2

-- 称号属性加成类型 property_type 1 只增装备该称号的武将属性 2 增加全体上阵武将的属性
kTitleAttrOwn	= 1
kTitleAttrAll	= 2

-- 称号状态 1 已装备 2 已获得(待装备) 3 未获得或失效(去获取)
kTitleStatusEquiped = 1
kTitleStatusIsGot 	= 2
kTitleStatusNotGot  = 3

-- 称号图鉴状态 0 未获得过 1 获得过
kTitleIllustrateNotGot = 0
kTitleIllustrateHadGot = 1

-- 称号显示状态 appear 0 不显示 1 显示
kTitleAppearStatusHide = 0
kTitleAppearStatusShow = 1