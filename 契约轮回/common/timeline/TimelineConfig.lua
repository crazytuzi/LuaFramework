--时间轴配置
--一个Timeline Config由多个Monster和多个Action组成

--索引 场景id
--AllTime 时间轴的总时间 到达总时间后才会结束时间轴

--Monster参数
--MonsterId 怪物在creep.xlsx配置表中的id
--InstanceId 怪物实例id
--CreateTime 怪物创建时间 相对于时间轴起点
--IsPrecreate 是否为预创建（若为true则会在创建后隐藏，等到作为Action的TargetType时才会显示）
--PosX/Y/Z 位置,z轴一样
--RotX/Y/Z 旋转

--通用Action参数
--ActionType 动作类型 
--1：移动 2：震屏（仅限于摄像机，TargetType可不设置） 3：动画（仅限于怪物或主角，EndTime可不设置） 
--4：特效 5：缩放（仅限于摄像机，TargetType可不设置） 6：显示怪物名字（TargetType，EndTime可不设置）
--7：显示怪物对话（仅限于怪物，TargetType）
--TargetType 目标类型 1：摄像机 2：怪物 3:主角 
--StartTime 开始时间 相对于时间轴起点
--EndTime 结束时间 相对于时间轴起点
--Order 排序（如果两个Action开始时间相同，则Order小的在前，可不设置）
--MonsterInstanceId 对应怪物的实例id（TargetType为怪物时设置）

--移动Action参数
--MoveTargetPosX/Y  移动位置

--震屏Action参数
--ShakeDirX/Y/Z x/y/z轴震动最大距离（以摄像机x/y/z点为中心点）
--ShakeInterval 震动间隔（最小为Time.deltaTime，若不设置则默认为Time.deltaTime）

--动画Action参数
--AnimName 动画名（播放完后会自动切到idle）

--特效Action参数
--EffectName 特效名
--EffectNodeName 特效节点名
--IsLoop 是否循环
--EffectOrder 特效排序
--RotX/Y/Z 旋转(可不设置)

--缩放Action参数
--ScaleTargetSize 摄像机缩放目标大小

--显示怪物名字Action参数
--MonsterId 怪物在creep.xlsx配置表中的avatar数字
--ShowFadeTime 出现时的淡入时间 为0则直接出现
--ShowTime 完全出现后的显示持续时间
--HideFadeTime 消失时的淡出时间 为0则直接消失

--显示怪物对话Action参数
--TalkText 对话文本
--TalkPosY 对话文本的Y轴位置 （若不设置则读取模型高度）

--时间轴动作类型
TimelineActionType = {

    --移动
    Move = 1,

    --震屏
    Shake = 2,

    --动画
    Anim = 3,

    --特效
    Effect = 4,

    --缩放
    Scale = 5,

    --显示怪物名字
    ShowMonsterName = 6,

    --显示怪物对话
    ShowMonsterTalk = 7
}

--时间轴目标类型
TimelineTargetType = {

    --摄像机
    Camera = 1,

    --怪物
    Monster = 2,

    --主角
    MainRole = 3
}

--时间轴配置
TimelineConfig = {
    --霜毒蜘蛛
	[60007] = {
        AllTime = 6.5,
        Monster={
            {
                MonsterId = 1100102,
                InstanceId = 1,
                CreateTime = 0,
                IsPrecreate = true,
                PosX = 12.37,
                PosY = 11.79,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            }
        },
        Action = {
            {
                ActionType = TimelineActionType.Move,
                TargetType = TimelineTargetType.Camera,
                StartTime = 0.8,
                EndTime = 1.2,
                MoveTargetPosX = 12.76,
                MoveTargetPosY = 12.58,
            },
            {
                ActionType = TimelineActionType.Anim,
                TargetType = TimelineTargetType.Monster,
                StartTime = 1.3,
                MonsterInstanceId = 1,
                AnimName = "show",
            },
            {
                ActionType = TimelineActionType.ShowMonsterName,
                StartTime = 2.2,
                MonsterId = 50304,
                ShowFadeTime = 0.5,
                ShowTime = 2,
                HideFadeTime = 0.5,
            },      
            {
                ActionType = TimelineActionType.Effect,
                TargetType = TimelineTargetType.Camera,
                StartTime = 3.4,
                EndTime = 7,
                EffectName = "effect_monster_50304",
                IsLoop = false,
                EffectOrder = 2,
            },
            {
                ActionType = TimelineActionType.Shake,
                StartTime = 3.6,
                EndTime = 5,
                ShakeX = 0.5,
                ShakeY = 1,
                ShakeZ = 0,
            },

			
        },
        


    },
	
	--恶魔之主
    [60005] = {
	
        AllTime = 5,
        Monster={
            {
                MonsterId = 6000401,
                InstanceId = 1,
                CreateTime = 0,
                IsPrecreate = true,
                PosX = 9.38,
                PosY = 5.08,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            }
        },
        Action = {
            {
                ActionType = TimelineActionType.Move,
                TargetType = TimelineTargetType.Camera,
                StartTime = 0.5,
                EndTime = 0.8,
                MoveTargetPosX = 9.38,
                MoveTargetPosY = 6.08,
            },
            {
                ActionType = TimelineActionType.Anim,
                TargetType = TimelineTargetType.Monster,
                StartTime = 0.9,
                MonsterInstanceId = 1,
                AnimName = "show",
            },
            {
                ActionType = TimelineActionType.Shake,
                StartTime = 2,
                EndTime = 3.2,
                ShakeX = 1,
                ShakeY = 1,
                ShakeZ = 0,
            },
			{
                ActionType = TimelineActionType.ShowMonsterName,
                StartTime = 2,
                MonsterId = 51002,
                ShowFadeTime = 0.5,
                ShowTime = 2,
                HideFadeTime = 0.5,
            },  
			{
                ActionType = TimelineActionType.Effect,
                TargetType = TimelineTargetType.Monster,
                StartTime = 2,
                EndTime = 3.2,
                MonsterInstanceId = 1,
                EffectName = "effect_monster_51002",
                EffectNodeName = "Bip001 R Foot",
                IsLoop = false,
                EffectOrder = 2,
            },
        },
        


    },
	--幻灵副本
    [60004] = {
        AllTime = 6,
        Monster={
            {
                MonsterId = 1100030,
                InstanceId = 1,
                CreateTime = 0.8,
                IsPrecreate = false,
                PosX = 11.99,
                PosY = 8.23,
                PosZ = -4760.2,
                RotX = 33,
                RotY = 180,
                RotZ = 0,
            },
        },
        Action = {
			{
                ActionType = TimelineActionType.Move,
                TargetType = TimelineTargetType.Camera,
                StartTime = 0.5,
                EndTime = 0.8,
                MoveTargetPosX = 11.99,
                MoveTargetPosY = 9.23,
            },
			{
                ActionType = TimelineActionType.Scale,
                StartTime = 0.8,
                EndTime = 1.1,
                ScaleTargetSize = 2.8,
            },
			{
                ActionType = TimelineActionType.Scale,
                StartTime = 4.8,
                EndTime = 5,
                ScaleTargetSize = 4.3,
            },
			{
                ActionType = TimelineActionType.ShowMonsterTalk,
                StartTime = 1.2,
                EndTime = 6,
                MonsterInstanceId = 1,
                TalkText = "Equip me to gain <color=#fff600>+58% EXP earning</color>!",
            },
			{
                ActionType = TimelineActionType.Anim,
                TargetType = TimelineTargetType.Monster,
                StartTime = 1,
                MonsterInstanceId = 1,
                AnimName = "show",
            },
        },
        


    },

	--偷鸡副本
    [60008] = {
        AllTime = 7.2,
        Monster={
            {
                MonsterId = 6000803,
                InstanceId = 1,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 28.08,
                PosY = 18.45,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            },
			{
                MonsterId = 6000806,
                InstanceId = 2,
                CreateTime = 0,
                IsPrecreate = true,
                PosX = 10.36,
                PosY = 12.66,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            }
        },
        Action = {
			{
                ActionType = TimelineActionType.Move,
                TargetType = TimelineTargetType.Camera,
                StartTime = 0,
                EndTime = 0,
                MoveTargetPosX = 11.36,
                MoveTargetPosY = 13.66,
            },
			{
                ActionType = TimelineActionType.Scale,
                StartTime = 0,
                EndTime = 0,
                ScaleTargetSize = 3.5,
            },
            {
                ActionType = TimelineActionType.Move,
                TargetType = TimelineTargetType.Camera,
                StartTime = 3.6,
                EndTime = 3.9,
                MoveTargetPosX = 26.08,
                MoveTargetPosY = 17.45,
            },
			{
                ActionType = TimelineActionType.ShowMonsterTalk,
                StartTime = 0.5,
                EndTime = 3,
                TalkPosY = 1478,
                MonsterInstanceId = 2,
                TalkText = "I'm scared!\nto death... (╥﹏╥)"
            },
			{
                ActionType = TimelineActionType.ShowMonsterTalk,
                StartTime = 4,
                EndTime = 7,
                TalkPosY = 2061,
                MonsterInstanceId = 1,
                TalkText = "I heard that you can get the cute Nekomata from this egg!\nAnd I'm gonna give it to the boss!"
            },
			{
                ActionType = TimelineActionType.Scale,
                StartTime = 3.6,
                EndTime = 3.9,
                ScaleTargetSize = 4.3,
            },

        },
        


    },
    --终焉之龙
    [60010] = {
        AllTime = 4,
        Monster={
            {
                MonsterId = 6001001,
                InstanceId = 1,
                CreateTime = 0,
                IsPrecreate = true,
                PosX = 20.34,
                PosY = 2,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            }
        },
        Action = {
            {
                ActionType = TimelineActionType.Move,
                TargetType = TimelineTargetType.Camera,
                StartTime = 0,
                EndTime = 0,
                MoveTargetPosX = 13.60,
                MoveTargetPosY = 7.38,
            },
			{
                ActionType = TimelineActionType.Scale,
                StartTime = 0,
                EndTime = 0,
                ScaleTargetSize = 7,
            },
			{
                ActionType = TimelineActionType.Anim,
                TargetType = TimelineTargetType.Monster,
                StartTime = 0.5,
                MonsterInstanceId = 1,
                AnimName = "show",
            },
			{
                ActionType = TimelineActionType.Scale,
                StartTime = 1,
                EndTime = 2,
                ScaleTargetSize = 4.3,
            },
			{
                ActionType = TimelineActionType.Move,
				TargetType = TimelineTargetType.Camera,
                StartTime = 1,
                EndTime = 2,
                MoveTargetPosX = 18.89,
                MoveTargetPosY = 5,
            },
            {
                ActionType = TimelineActionType.Effect,
                TargetType = TimelineTargetType.Camera,
                StartTime = 0,
                EndTime = 4,
                EffectName = "effect_monster_50407_hanqi",
                IsLoop = true,
                EffectOrder = 2,
            },
            {
                ActionType = TimelineActionType.Shake,
                StartTime = 2.4,
                EndTime = 3.4,
                ShakeX = 1.5,
                ShakeY = 1.5,
                ShakeZ = 0,
            },
			{
                ActionType = TimelineActionType.ShowMonsterName,
                StartTime = 2.3,
                MonsterId = 50407,
                ShowFadeTime = 0.5,
                ShowTime = 3.8,
                HideFadeTime = 0.5,
            },  
			
        },
        


    },
    --狂暴齿轮
    [60009] = {
        AllTime = 8.2,
        Monster={
            {
                MonsterId = 6000901,
                InstanceId = 1,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 17.49,
                PosY = 15.78,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            },
			{
                MonsterId = 6000903,
                InstanceId = 2,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 27.60,
                PosY = 9.11,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            },
			{
                MonsterId = 6000903,
                InstanceId = 3,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 31.00,
                PosY = 10.95,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            },
			{
                MonsterId = 6000903,
                InstanceId = 4,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 25.39,
                PosY = 10.24,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            },
			{
                MonsterId = 6000903,
                InstanceId = 5,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 28.07,
                PosY = 12.17,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            },
			{
                MonsterId = 6000903,
                InstanceId = 6,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 22.50,
                PosY = 11.49,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            },
			{
                MonsterId = 6000903,
                InstanceId = 7,
                CreateTime = 0.5,
                IsPrecreate = false,
                PosX = 25.59,
                PosY = 13.50,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            },
			{
                MonsterId = 6000903,
                InstanceId = 8,
                CreateTime = 0.5,
                IsPrecreate = false,
                PosX = 14.57,
                PosY = 14.54,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            },
			{
                MonsterId = 6000903,
                InstanceId = 9,
                CreateTime = 0.5,
                IsPrecreate = false,
                PosX = 20.45,
                PosY = 17.54,
                PosZ = -4760.2,
                RotX = 23.884,
                RotY = -236.481,
                RotZ = -19.126,
            },
        },
        Action = {
            {
                ActionType = TimelineActionType.Move,
                TargetType = TimelineTargetType.Camera,
                StartTime = 1,
                EndTime = 1.5,
                MoveTargetPosX = 26.67,
                MoveTargetPosY = 11.46,
            },
			{
                ActionType = TimelineActionType.Move,
                TargetType = TimelineTargetType.Camera,
                StartTime = 4.2,
                EndTime = 4.8,
                MoveTargetPosX = 16.76,
                MoveTargetPosY = 17.53,
            },
            {
                ActionType = TimelineActionType.Anim,
                TargetType = TimelineTargetType.Monster,
                StartTime = 4.9,
                MonsterInstanceId = 1,
                AnimName = "show",
            },
            {
                ActionType = TimelineActionType.Shake,
                StartTime = 6.7,
                EndTime = 7.7,
                ShakeX = 1.2,
                ShakeY = 1.2,
                ShakeZ = 0,
            },
			{
                ActionType = TimelineActionType.ShowMonsterName,
                StartTime = 5.2,
                MonsterId = 50201,
                ShowFadeTime = 0.5,
                ShowTime = 3.8,
                HideFadeTime = 0.5,
            },  
			{
                ActionType = TimelineActionType.ShowMonsterTalk,
                StartTime = 1.5,
                EndTime = 5,
                MonsterInstanceId = 4,
                TalkText = "Beat me or I'll explode! (╥﹏╥)",
				TalkPosY = 1144,
            },
			{
                ActionType = TimelineActionType.ShowMonsterTalk,
                StartTime = 1.5,
                EndTime = 5,
                MonsterInstanceId = 5,
                TalkText = "<color=#fff600>Explode? Whoa, that’s funny! </color>",
				TalkPosY = 1357,
            },
			{
                ActionType = TimelineActionType.Effect,
                TargetType = TimelineTargetType.Monster,
                StartTime = 5,
                EndTime = 8,
                MonsterInstanceId = 1,
                EffectName = "effect_monster_50202",
                EffectNodeName = "Bip001 R Foot",
                IsLoop = false,
                EffectOrder = 2,
            },
			
        },
        


    },


	--决战之时
    [60011] = {
	
        AllTime = 6,
        Monster={
            {
                MonsterId = 6001101,
                InstanceId = 1,
                CreateTime = 0,
                IsPrecreate = true,
                PosX = 19.22,
                PosY = 12.05,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            },
			{
                MonsterId = 6001103,
                InstanceId = 2,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 9.14,
                PosY = 9.02,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            },
			{
                MonsterId = 6001103,
                InstanceId = 3,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 11.1,
                PosY = 9.95,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            },
			{
                MonsterId = 6001103,
                InstanceId = 4,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 12.91,
                PosY = 10.81,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            },
			{
                MonsterId = 6001103,
                InstanceId = 5,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 16.8,
                PosY = 8.92,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            },
			{
                MonsterId = 6001103,
                InstanceId = 6,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 15,
                PosY = 8.04,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            },
			{
                MonsterId = 6001103,
                InstanceId = 7,
                CreateTime = 0,
                IsPrecreate = false,
                PosX = 13,
                PosY = 7.04,
                PosZ = -4760.2,
                RotX = 18.1,
                RotY = 228.68,
                RotZ = 24.65,
            },
			
        },
        Action = {
            {
                ActionType = TimelineActionType.Move,
                TargetType = TimelineTargetType.Camera,
                StartTime = 0.5,
                EndTime = 1.5,
                MoveTargetPosX = 17.22,
                MoveTargetPosY = 11.05,
            },
            {
                ActionType = TimelineActionType.Anim,
                TargetType = TimelineTargetType.Monster,
                StartTime = 1.6,
                MonsterInstanceId = 1,
                AnimName = "show",
            },
            {
                ActionType = TimelineActionType.Shake,
                StartTime = 2.2,
                EndTime = 2.3,
                ShakeX = 0,
                ShakeY = 1,
                ShakeZ = 0,
            },
			 {
                ActionType = TimelineActionType.Shake,
                StartTime = 2.7,
                EndTime = 2.8,
                ShakeX = 0,
                ShakeY = 1,
                ShakeZ = 0,
            },
			{
                ActionType = TimelineActionType.Shake,
                StartTime = 3.3,
                EndTime = 3.4,
                ShakeX = 0,
                ShakeY = 1,
                ShakeZ = 0,
            },
			{
                ActionType = TimelineActionType.Shake,
                StartTime = 4,
                EndTime = 4.1,
                ShakeX = 0,
                ShakeY = 1,
                ShakeZ = 0,
            },
			 {
                ActionType = TimelineActionType.Shake,
                StartTime = 4.6,
                EndTime = 5.5,
                ShakeX = 0.5,
                ShakeY = 0.5,
                ShakeZ = 0,
            },
			{
                ActionType = TimelineActionType.ShowMonsterName,
                StartTime = 2.5,
                MonsterId = 50409,
                ShowFadeTime = 0.5,
                ShowTime = 2.5,
                HideFadeTime = 0.5,
            },  
			{
                ActionType = TimelineActionType.Effect,
                TargetType = TimelineTargetType.Monster,
                StartTime = 4.6,
                EndTime = 6,
                MonsterInstanceId = 1,
                EffectName = "model_pet_10003_show_leipi",
                EffectNodeName = "Bip01 L Foot",
                IsLoop = false,
                EffectOrder = 2,
                RotX = 180,
                RotY = 0,
                RotZ = 0,
            },
        },
        


    },
	}

