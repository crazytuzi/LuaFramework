--------------------------------------------------------------------------------------
-- 文件名:	Game_SelectGameLevel3.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2015-3-7 19:37
-- 版  本:	1.0
-- 描  述:	界面
-- 应  用:  副本难度选择  继承 Game_SelectGameLevel1 实现
---------------------------------------------------------------------------------------
Game_SelectGameLevel3 = class("Game_SelectGameLevel3",function() return Game_SelectGameLevel1.new()  end)
Game_SelectGameLevel3.__index = Game_SelectGameLevel3