--热血装备显示配置
--装备位置索引id
--[[
热血神剑:0
热血神甲:1
热血面甲:2
热血护肩:3
热血斗笠:4
热血战鼓:5
热血吊坠:6
热血护膝:7
--]]
return {
	--基础属性,有配置的才显示在基础属性中
	--第1层按显示的类型 [1基础属性 2特殊属性]
	--第2层按玩家职业索引
	attr_types = {
		-- 基础属性
		[1] = {
			[1] = {5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33},--战士
			[2] = {5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33},--法师
			[3] = {5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33},--道士
		},
		-- 特殊属性
		[2] = {
			[1] = {96, 97, 98, 99, 160, 161, 162},
			[2] = {96, 97, 98, 99, 160, 161, 162},
			[3] = {96, 97, 98, 99, 160, 161, 162},
		},
	},

	--第1层索引为装备位置
	--第2层为物品id索引
	--skill_desc:技能描述
	--effect_id:特效id
	equip_cfg = {
----------------------------------------	
		[0] = {-- 热血神剑
[2972] = {effect_id = 120, skill_desc = "      无"},--热血神剑
[2980] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·星
[2988] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·月
[2996] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·宇
[3004] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·宙
[3012] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·乾
[3020] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·坤
[3028] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·神
[3036] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·皇
[3044] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·皓
[3052] = {effect_id = 120, skill_desc = "      无"},--上古热血神剑·尊
		},
		[1] = {-- 热血神甲
[2973] = {effect_id = 121, skill_desc = "      无"},--热血神甲
[2981] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·星
[2989] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·月
[2997] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·宇
[3005] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·宙
[3013] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·乾
[3021] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·坤
[3029] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·神
[3037] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·皇
[3045] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·皓
[3053] = {effect_id = 121, skill_desc = "      无"},--上古热血神甲·尊
		},
		[2] = {-- 热血面甲
[2978] = {effect_id = 122, skill_desc = "      无"},--热血面甲
[2986] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·星
[2994] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·月
[3002] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·宇
[3010] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·宙
[3018] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·乾
[3026] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·坤
[3034] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·神
[3042] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·皇
[3050] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·皓
[3058] = {effect_id = 122, skill_desc = "      无"},--上古热血面甲·尊
		},
		[3] = {-- 热血护腕
[2977] = {effect_id = 123, skill_desc = "      无"},--热血护腕
[2985] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·星
[2993] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·月
[3001] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·宇
[3009] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·宙
[3017] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·乾
[3025] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·坤
[3033] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·神
[3041] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·皇
[3049] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·皓
[3057] = {effect_id = 123, skill_desc = "      无"},--上古热血护腕·尊
		},
		[4] = {-- 热血斗笠
[2975] = {effect_id = 124, skill_desc = "       无"},--热血斗笠
[2983] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·星
[2991] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·月
[2999] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·宇
[3007] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·宙
[3015] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·乾
[3023] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·坤
[3031] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·神
[3039] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·皇
[3047] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·皓
[3055] = {effect_id = 124, skill_desc = "       无"},--上古热血斗笠·尊
		},
		[5] = {-- 热血战鼓
[2974] = {effect_id = 125, skill_desc = "      无"},--热血战鼓
[2982] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·星
[2990] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·月
[2998] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·宇
[3006] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·宙
[3014] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·乾
[3022] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·坤
[3030] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·神
[3038] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·皇
[3046] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·皓
[3054] = {effect_id = 125, skill_desc = "      无"},--上古热血战鼓·尊
		},
		[6] = {-- 热血吊坠
[2976] = {effect_id = 126, skill_desc = "      无"},--热血吊坠
[2984] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·星
[2992] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·月
[3000] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·宇
[3008] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·宙
[3016] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·乾
[3024] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·坤
[3032] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·神
[3040] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·皇
[3048] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·皓
[3056] = {effect_id = 126, skill_desc = "      无"},--上古热血吊坠·尊
		},
		[7] = {-- 热血护膝
[2979] = {effect_id = 127, skill_desc = "      无"},--热血护膝
[2987] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·星
[2995] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·月
[3003] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·宇
[3011] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·宙
[3019] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·乾
[3027] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·坤
[3035] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·神
[3043] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·皇
[3051] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·皓
[3059] = {effect_id = 127, skill_desc = "      无"},--上古热血护膝·尊
		},
-----------------------------------------
	}
}