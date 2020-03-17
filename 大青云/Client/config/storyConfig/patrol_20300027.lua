--[[
	npc寻路配置
	-----------
	dwDefault = 默认寻路id
	bLoop = 是否循环
	x，y = 走到这个坐标
	speed = 速度
	npcStay = 走到后，停在那多久
	npcActId = 走到后播这个动作
	bActLoop = 是否循环播放动作

	dwStartSayId = 开始走时说得话
	dwStopSayId = 走到时说的话
--]]
local npc_id = 20300027
local Patrol = {
	dwDefault = 1,
	bLoop = false,
	[1] = {
		{x=-747,y=447,speed=75,dir=0.1},
		{x=-705,y=295,speed=75,dir=0.1},
		{x=-720,y=243,speed=75,dir=0.1},
	},
}
-------------------------------------------------------
StoryScriptManager:AddScript(npc_id,Patrol)
-------------------------------------------------------