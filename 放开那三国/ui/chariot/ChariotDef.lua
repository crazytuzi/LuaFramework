-- FileName: ChariotDef.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车相关常量Def

module("ChariotDef", package.seeall)

-- 战车信息显示状态 ChariotInfoType
kChariotInfoTypeBase 	= 101 -- 显示type1 tid  	   	无按钮
kChariotInfoTypeBag 	= 102 -- 显示type2 item_id  	战车背包 强化 进阶
kChariotInfoTypeEquip	= 103 -- 显示type3 item_id  	战车装备 更换 卸下 强化 进阶
kChariotInfoTypeRival	= 104 -- 显示type4 item_id 	对方阵容无按钮

-- 战车Cell显示状态 CellShowType
kCellShowTypeEquip	= 201 -- 显示装备界面
kCellShowTypeRival	= 202 -- 显示对方阵容界面

-- 战车图鉴显示状态 illustrateType
kShowTypeIllustrate 	= 1001 -- 显示战车图鉴
kShowTypeSuit 			= 1002 -- 显示战车组合


-- 战车图鉴显示状态 show 0 不显示 1 显示
kIllustrateStatusHide = 0
kIllustrateStatusShow = 1