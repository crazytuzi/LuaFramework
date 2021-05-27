return {
{
	scenceid = 1,
	scencename = Lang.SceneName.s00001,
	mapfilename = "Huashanpai_1",
	progress = 0,
	zyType = 1,
	isDurKill = false,
    sceneType = 0,
    isAddUpExp = 0,
    isAddUpBindCoin = 0,
	autoFightPoints =
	{
		{x = 69 , y = 100},
		{x = 42 , y = 104},
		{x = 30 , y = 86},
		{x = 26 , y = 57},
		{x = 53 , y = 35},
		{x = 94 , y = 43},
		{x = 71 , y = 66},
	},
	area =
	{
		{
			name = "西门",
			range = { 10,10,20,20,60,50,120,30},
			center = { 35,35},
			attri =
			{
				{ type = 1, value = {}  },
				{ type = 12, value = {30}  },
				{ type = 33, value = {10,22,40}  },
				{ type = 2, value = {2}},
			},
		},
	},
    magicPassPoints = {1,2,56,32},
	refresh =
	{
		--#include "refresh_smple.lua"
	},
	npc =
	{
	    {
	        --name=Lang.EntityName.n00002, posx = 88 , posy = 10,script="data/script/Huashanpai/ZhaoTianYuan.lua",
			modelid=1,icon = 1,title="铁匠",hideLocation =false, idleInterval = 120000,hideName=false
	    },
  	},
	teleport =
	{
	    { posx = 102, posy = 15,toSceneid = 2,toPosx = 102, toPosy = 15,modelid = 1 ,name="去武当山",passid = 1,dist = 3,mapHide =false},
	},
	landscape =
	{
		{posx1=24,posy1=22,posx2=24,posy2=30,modelid=2,xinterval=2,yinterval=2,name = ""},
	},
	sceneconsum =
	{
		{type=5,id=0,count=10000},
	},
	consumTime = 60,
},
}