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
	
	MyActId = 主角走到后播这个动作
	bMyActLoop = 主角是否循环播放动作
	
	dwStartSayId = 开始走时说得话
	dwStopSayId = 走到时说的话
--]]
local npc_id = 999
local Patrol = {
	bLoop = true,
	dwDefault = 1,
	[1] = {
		{x=978,y=-507,speed=100,dir=2},
		{x=978,y=-517,speed=100,dir=2},
		{x=988,y=-517,speed=100,dir=2,npcStay=2000,npcActId='dialog',bActLoop=true},
		{x=998,y=-517,speed=100,dir=2}
	},
}
-------------------------------------------------------
StoryScriptManager:AddScript(npc_id,Patrol)
-------------------------------------------------------