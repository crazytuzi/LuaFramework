-- 
-- @Author: LaoY
-- @Date:   2018-07-23 16:24:18
-- 

SceneConstant = {}

--地图编辑器对应的信息
SceneConstant.MaskBitList = {
	Block   	= BitState.State[0],		-- 阻挡
	Clean 		= BitState.State[1],		-- 行走
	Water 		= BitState.State[2],		-- 水(浅水)
	Shadow 		= BitState.State[3],		-- 阴影
	Born  		= BitState.State[4],		-- 出生点
	Reborn 		= BitState.State[5],		-- 复活点
	JumpPath 	= BitState.State[6],		-- 跳跃点寻路
	Swim 		= BitState.State[7],		-- 游泳区域
	Safe 		= BitState.State[8],		-- 安全区
	Hunt 		= BitState.State[9],		-- 寻宝区
	PathNot 	= BitState.State[10],		-- 伪寻路
}

-- 神灵出现配置
SceneConstant.God = {
	intervalTime 	= 20, 	-- 待机多长时间开始
	showTime 		= 4.5, 	-- 出现时间
}

-- 跑步的单次音效时间
SceneConstant.RunSoundEffTime = {
	Run = 0.6,
}

SceneConstant.DataType = {
	Client = 1,
	Server = 2,	
}

-- 小飞鞋距离表现配置 
-- 不在范围内的用飞
SceneConstant.FlyDisConfig = {
	Rush = 800,			-- 小飞鞋冲刺表现距离
	Jump = 3000,		-- 小飞鞋跳跃表现距离
}

-- 切换场景飞的 延时
SceneConstant.FlyDelayTime = {
	Up = 0.5,
	Down = 0.5,
}

-- 地块大小
SceneConstant.BlockSize = {
	w = 20,
	h = 20,
}

SceneConstant.SceneRotateOffset = 0
SceneConstant.SceneRotateRate = 1
SceneConstant.SceneRotate = {
	x = -33,
	y = 180,
	z = 0,
}

-- 转身速度
SceneConstant.TurnSpeed = 1200

SceneConstant.SynchronousType = {
	Move 	= 1,
	Rocker 	= 2,
	Stop 	= 3,
}

SceneConstant.JumpType = {
	Ordinary = 0,
	Point = 1,
}

-- 默认速度
SceneConstant.ObjectSpeed = 400
-- 误差距离
SceneConstant.ErrorOff = SceneConstant.ObjectSpeed/30

-- 锁定范围
SceneConstant.LockRange 	= 600 

-- 冲刺
SceneConstant.RushCD 		= 1.0	-- 冲刺Cd
SceneConstant.RushDis 		= 200 	-- 加上技能的攻击距离
SceneConstant.RushMinDis 	= 40	-- 冲刺最短距离

-- 人物攻击距离，没有确定技能的情况用这个距离代替。选中某个技能，就用技能的攻击距离
SceneConstant.AttactDis 	= 300

-- 采集距离
SceneConstant.PickUpDis 	= 150

--没有目的点，原地起跳的最远距离
SceneConstant.JumpDis		= {
	[1] = 380,
	[2] = 420,
	[3] = 480,
	[4] = 480,
}

SceneConstant.JumpSpeed = 500

--每个动作跳跃的高度
SceneConstant.JumpHeightList = {
	130,130,130,0
}


SceneConstant.JumpCd = {
	[1] = 0.5,
	[2] = 0.5,
	[3] = 0.5,
}

-- 通用的跳跃配置，和跳跃动作无关
SceneConstant.JumpTimeConfig = {
	-- 男
	[1] = {
		-- 横向速度
		h_speed = {
			[1] = 500,
			[2] = 500,
			[3] = 500,
		},
		-- 垂直速度
		v_speed = {
			[1] = 700,
			[2] = 600,
			[3] = 0,
		},
	},
	-- 女
	[2] = {
		h_speed = {
			[1] = 500,
			[2] = 500,
			[3] = 500,
		},
		v_speed = {
			[1] = 700,
			[2] = 600,
			[3] = 0,
		},
	},
}

--跳跃动作相关配置
SceneConstant.JumpConfig = {
	[1] = {                           ---男
		--动作发力起跳蓄力的时间
		StartTime = {
			[1] = 0.1,
			[2] = 0.1,
			[3] = 0,
		},
		--空中运动的时间（不包括起跳蓄力，已经落地缓存时间，但是包括完整的上升下落）
		ActionTime = {
			[1] = 0.7,
			[2] = 0.4,
			[3] = 0.4,
		},
	} ,

	[2] = {                            ---女
		--动作发力起跳蓄力的时间
		StartTime = {
			[1] = 0.2,
			[2] = 0.1,
			[3] = 0,
		},
		--空中运动的时间（不包括起跳蓄力，已经落地缓存时间，但是包括完整的上升下落）
		ActionTime = {
			[1] = 0.6,
			[2] = 0.4,
			[3] = 0.4,
		},
	} ,
}


-- 世界坐标对应的像素
SceneConstant.PixelsPerUnit = 100

-- 场景对象的z轴
SceneConstant.SceneZ = {
	Object = 1000,
	Map = 18000,
}

SceneConstant.SceneType = {
	City 	= 1,
	Feild 	= 2,
	Boss 	= 3,
	Dungeon = 4,
}

-- 主角停下来(进入待机动作)的检测位置的时间为
SceneConstant.StopCheckTime = 0.2
-- 与传送门距离
SceneConstant.DoorRange = 100
-- 与NPC距离
SceneConstant.NPCRange 	= 150
-- 与掉落物品
SceneConstant.DropRange 	= 25

SceneConstant.MonsterRange 	= 550

-- 
-- 场景模型动作名字
SceneConstant.ActionName = {
	idle 	= "idle",		--待机
	ride 	= "ride",		--坐骑待机
	idle2 	= "idle2",		--游泳待机

	run 	= "run",		--跑步
	riderun = "riderun",	--坐骑跑步
	run1 	= "run",		--坐骑跑步
	run2 	= "run2",		--游泳跑步

	death 		= "death",
	attack 		= "attack",
	attack1 	= "attack1",
	attack2 	= "attack2",
	attack3 	= "attack3",
	attack4 	= "attack4",
	skill  		= "skill",
	skill1  	= "skill1",
	skill2  	= "skill2",
	skill3  	= "skill3",
	skill4  	= "skill4",
	skill5  	= "skill5",
	skill6  	= "skill6",
	skill7  	= "skill7",
	skill8  	= "skill8",
	Bigger  	= "Bigger", 	-- 变身

	rush 		= "rush",		--冲刺
	rush2 		= "rush2",
	collect 	= "collect",
	collect2 	= "collect2",   --水中采集
	jump1 		= "jump1",
	jump2 		= "jump2",
	jump3 		= "jump3",
	jump4 		= "jump4",

	Fly         = "fly",
	Fly1 		= "fly1",
	Fly2 		= "fly2",

	casual 		= "casual",		--怪物随机待机动作

	rideup 		= "rideup",		--上坐骑动作
	ridedown 	= "ridedown",	--下坐骑动作

	hited 		= "hited",	--受击动作

	show 		= "show",	--npc等展示动作1
	show1 		= "show1",	--npc等展示动作1
	show2 		= "show2",	--npc等展示动作1

	dance1  	= "dance1", -- 跳舞1
	dance2  	= "dance2", -- 跳舞1
}

local ActionNameGroup = {
	[SceneConstant.ActionName.idle] 	= "idle",		--待机
	[SceneConstant.ActionName.ride] 	= "idle",		--坐骑待机
	[SceneConstant.ActionName.idle2] 	= "idle",		--游泳待机

	[SceneConstant.ActionName.run] 		= "run",		--跑步
	[SceneConstant.ActionName.riderun]  = "run",	--坐骑跑步
	[SceneConstant.ActionName.run1] 	= "run",		--坐骑跑步
	[SceneConstant.ActionName.run2] 	= "run",		--游泳跑步

	[SceneConstant.ActionName.death] 		= "death",
	[SceneConstant.ActionName.attack] 		= "attack",
	[SceneConstant.ActionName.attack1] 	= "attack",
	[SceneConstant.ActionName.attack2] 	= "attack",
	[SceneConstant.ActionName.attack3] 	= "attack",
	[SceneConstant.ActionName.attack4] 	= "attack",
	[SceneConstant.ActionName.skill]  		= "attack",
	[SceneConstant.ActionName.skill1]  	= "attack",
	[SceneConstant.ActionName.skill2]  	= "attack",
	[SceneConstant.ActionName.skill3]  	= "attack",
	[SceneConstant.ActionName.skill4]  	= "attack",
	[SceneConstant.ActionName.skill5]  	= "attack",
	[SceneConstant.ActionName.skill6]  	= "attack",
	[SceneConstant.ActionName.skill7]  	= "attack",
	[SceneConstant.ActionName.skill8]  	= "attack",
	[SceneConstant.ActionName.Bigger]  	= "attack", 	-- 变身

	[SceneConstant.ActionName.rush] 		= "rush",		--冲刺
	[SceneConstant.ActionName.rush2] 		= "rush",
	[SceneConstant.ActionName.collect] 	= "collect",
	[SceneConstant.ActionName.collect2] 	= "collect",   --水中采集
	[SceneConstant.ActionName.jump1] 		= "jump",
	[SceneConstant.ActionName.jump2] 		= "jump",
	[SceneConstant.ActionName.jump3] 		= "jump",
	[SceneConstant.ActionName.jump4] 		= "jump",

	[SceneConstant.ActionName.Fly1] 		= "fly",
	[SceneConstant.ActionName.Fly2] 		= "fly",

	[SceneConstant.ActionName.casual] 	= "casual",		--怪物随机待机动作

	[SceneConstant.ActionName.rideup] 	= "rideup",		--上坐骑动作
	[SceneConstant.ActionName.ridedown] 	= "ridedown",	--下坐骑动作

	[SceneConstant.ActionName.hited] 		= "hited",	--受击动作

	[SceneConstant.ActionName.show] 		= "show",	--npc等展示动作1
	[SceneConstant.ActionName.show1] 		= "show",	--npc等展示动作1
	[SceneConstant.ActionName.show2] 		= "show",	--npc等展示动作1

	[SceneConstant.ActionName.dance1] 		= "dance",	--npc等展示动作1
	[SceneConstant.ActionName.dance2] 		= "dance",	--npc等展示动作1
}

-- state_name 为 run run1 run2 相当于 run
function IsSameStateGroup(state_name,state)
	if state == state_name then
		return true
	end
	return ActionNameGroup[state_name] == ActionNameGroup[state]
end

--人物模型的复位时间（物理时间，不是比例） 不填默认0.1
--怪物的复位时间另外起配置
SceneConstant.ResetTime = {
	[SceneConstant.ActionName.idle] = 0.3,
	[SceneConstant.ActionName.ride] = 0.1,
	[SceneConstant.ActionName.run] = 0.1, 
	[SceneConstant.ActionName.death] = 0.1,
	[SceneConstant.ActionName.attack1] = 0,
	[SceneConstant.ActionName.attack2] = 0,
	[SceneConstant.ActionName.attack3] = 0,
	[SceneConstant.ActionName.attack4] = 0,
	[SceneConstant.ActionName.rush] = 0.1,
	[SceneConstant.ActionName.rush2] = 0.1,
	[SceneConstant.ActionName.collect] = 0.1,
	[SceneConstant.ActionName.jump1] = 0.1,
	[SceneConstant.ActionName.jump2] = 0.1,
	[SceneConstant.ActionName.jump3] = 0.1,

	[SceneConstant.ActionName.skill1] = 0.1,
	[SceneConstant.ActionName.skill2] = 0.1,
	[SceneConstant.ActionName.skill3] = 0.1,
	[SceneConstant.ActionName.skill4] = 0.1,
}


--模型挂接点
SceneConstant.BoneNode =
{
	Head  		= "head",
	LSanp 		= "lsanp",
	RSanp 		= "rsanp",
	LHand 		= "lhand",
	RHand 		= "rhand",
	BHand 		= "bhand",
	Root  		= "root",
	LFoot 		= "lfoot",
	RFoot 		= "rfoot",
	Waist 		= "waist",

	-- 跳跃 手上面的特效挂点
	BRHand 		= "Bip001 L Hand",
	BRLand 		= "Bip001 R Hand",

	Ride  		= "ride",
	SceneObj 	= "SceneObj",
	Gyro 		= "gyro",
	Ride_Root 	= "ride_root",
	Wing 		= "wing",

	Transform 	= "transform",
	EffectRoot 	= "effectRoot",
}

--1头、45左右手、6手、7脚底、89左右脚、10腰部、14坐骑、15坐骑根节点、16翅膀、20场景层 21 transform(模型本身) 22 专门特效挂载点，在模型上层
--特效挂接点 前面10个表示模型身上的挂点  11 12 13表示三个位置的武器挂点  14契兽挂接点  20模型最顶级挂接点 脱离模型 不受模型旋转的影响
SceneConstant.EffectBoneNode =
{
	
	[1] = SceneConstant.BoneNode.Head,
	[2] = SceneConstant.BoneNode.LSanp,
	[3] = SceneConstant.BoneNode.RSanp,
	[4] = SceneConstant.BoneNode.LHand,
	[5] = SceneConstant.BoneNode.RHand,
	[6] = SceneConstant.BoneNode.BHand,
	[7] = SceneConstant.BoneNode.Root,
	[8] = SceneConstant.BoneNode.LFoot,
	[9] = SceneConstant.BoneNode.RFoot,
	[10] = SceneConstant.BoneNode.Waist,

	[14] = SceneConstant.BoneNode.Ride,
	[15] = SceneConstant.BoneNode.Ride_Root,
	[16] = SceneConstant.BoneNode.Wing,

	[20] = SceneConstant.BoneNode.SceneObj,
	[21] = SceneConstant.BoneNode.Transform,
	[22] = SceneConstant.BoneNode.EffectRoot,
}

SceneConstant.SwimHideBone = {
	SceneConstant.BoneNode.RHand,
	SceneConstant.BoneNode.Wing,
}