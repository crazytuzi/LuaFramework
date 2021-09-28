-- Filename: WorldCarnivalConstant.lua
-- Author: bzx
-- Date: 2014-08-31
-- Purpose: 跨服嘉年华常量

module("WorldCarnivalConstant", package.seeall)

RANK_4TO2 = 4 						-- 半决赛
RANK_2TO1 = 2						-- 决赛
RANK_1 = 1 							-- 冠军已经决出

STATUS_WAITING = 0  				-- 等待中
STATUS_FIGHTING = 10   				-- 战斗中
STATUS_DONE = 100					-- 战斗结束

ROUND_PREPARE = 0     				-- 准备期间
ROUND_1 = 1          				-- 超凡入圣比赛
ROUND_2 = 2   						-- 举世无双比赛
ROUND_3 = 3							-- 最强主公比赛

ROUND_MAX = ROUND_3    				-- 最大的round

STATUS_WIN = 1						-- 胜利
STATUS_LOSING = 2					-- 失败
STATUS_WAITING = 3                  -- 结果未知