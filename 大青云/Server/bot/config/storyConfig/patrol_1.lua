--[[
	npc寻路配置
	-----------
	dwDefault = 默认寻路id
	bLoop = 是否循环
	x，y = 走到这个坐标
	speed = 速度
	npcStay = 走到后，停在那多久
	
	MyActId = 主角走到后播这个动作
	bMyActLoop = 主角是否循环播放动作
	
	dwStartSayId = 开始走时说得话
	dwStopSayId = 走到时说的话
	
	playerEffect = 走到时播的人物身上特效
	sceneEffect =  走到时播的场景身上特效
	sceneEffectPos = ｛1,2,3｝3是相聚地面的位置
--]]
local Patrol = {
	bLoop = false,
	[1] = {
		{x=799,y=800,speed=40,dir=2.55,MyActId=5,bMyActLoop=false},
	},
	[2] = {
	    {x=-545,y=75,speed=1000,dir=0,MyActId=1,bMyActLoop=true},
	},
	[3] = {
	    {x=-530,y=-734,speed=500,dir=4.58,MyActId=4,bMyActLoop=false},
	},
	[4] = {
	    {x=-370,y=239,speed=120,dir=0.65,mountID={60100001,60200001,60300001,60400001}},
		{x=-82,y=226,speed=120,dir=0.65,MyActId = 1,bMyActLoop = true},
	},
	[5] = {
	    {x=135,y=575,speed=175,mountID={60000099,60000099,60000099,60000099},useStoryPosZ=true,RotateTime=500},
		{x=250,y=456,speed=175,useStoryPosZ=true},
		{x=276,y=417,speed=175,useStoryPosZ=true},
		{x=253,y=258,speed=175,useStoryPosZ=true},
		{x=184,y=153,speed=175,useStoryPosZ=true},
		{x=132,y=-10,speed=175,useStoryPosZ=true},
		--{x=-16,y=-100,speed=175,useStoryPosZ=true},
		--{x=-118,y=-194,speed=175,useStoryPosZ=true},
		--{x=-190,y=-323,speed=175,useStoryPosZ=true},
		--{x=-129,y=-434,speed=175,useStoryPosZ=true},
		--{x=-35,y=-516,speed=175,useStoryPosZ=true},
		--{x=20,y=-695,speed=175,useStoryPosZ=true},
		{x=81,y=-874,speed=175,useStoryPosZ=true},
	},
	[6] = {
		{x=-362,y=-46,speed=60,dir=4.75},
	},
}
-------------------------------------------------------
StoryScriptManager:AddMyScript(Patrol)
-------------------------------------------------------