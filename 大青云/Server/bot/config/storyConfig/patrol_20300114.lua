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
	
	playerEffect = 走到时播的人物身上特效
	sceneEffect =  走到时播的场景身上特效
	sceneEffectPos = ｛1,2,3｝3是相聚地面的位置
--]]
local npc_id = 20300114
local Patrol = {
	dwDefault = 1,
	bLoop = false,	
	[1] = {
		{x=-22,y=-144,speed=15,dir=0,npcActId ='idle',bActLoop =true},
	},
}
-------------------------------------------------------
StoryScriptManager:AddScript(npc_id,Patrol)
-------------------------------------------------------