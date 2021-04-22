--	speak    :文字;持续时间;类型
--  turn     :方向("left","right")
--  skill    :技能ID;技能等级
--  move     :x距离;y距离
--  action   :动作名称;
--  dialog   :文字;方向(y:左);是否打字机(y:是);名字;图片路径;
--  create   :actorID;x;y
--  remove   :移除
--  hide_view:隐藏
--  show_view:显示
--  hero_enter:英雄入场 这个只需要写time与action就可以了
--  play_dragon_soul:播放boss武魂真身特效
--  interlude:

-- dungeon_monster表里的每个需要引导的monster的ID需要和story_line中的id对应
-- 英雄和引导中创建出来的npc需要配置wave,dungeon_monster中的monster的wave无需在story_line中再配置

local story_line = {
	sociaty_dragon_shouwuhun_1 = {
		maxWave = 1,
		wave1 = {
			{time = 0, action = "play_weather_effect", tutorial = "5"},
			{id = "dizuo", time = 0, action = "create", tutorial = "61019;6.1;2.2"},
			{id = "dizuo", time = 0, action = "turn", tutorial = "left"},
			{time = 0, action = "hero_enter"},
			
			{id = "dizuo", time = 0.2, action = "play_dragon_soul"},
			{id = "dizuo", time = 2.7, action = "skill", tutorial = "51353;1"},
			
			{id = "dizuo", time = 3.5, action = "skill", tutorial = "51354;1"},
			{id = "boss_zhuti", time = 3.5, action = "create", tutorial = "61001;6.2;1.8"},
			{id = "boss_up", time = 3.5, action = "create", tutorial = "61004;6.1;2"},
			{id = "boss_down", time = 3.5, action = "create", tutorial = "61007;6.1;1.6"},
			{id = "boss_zhuti", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_up", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_down", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_zhuti", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_up", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_down", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "dizuo", time = 6.5, action = "hide_view"},
			{id = "boss_zhuti", time = 7.6, action = "action", tutorial = "stand"},
			{id = "boss_up", time = 7.6, action = "action", tutorial = "stand"},
			{id = "boss_down", time = 7.6, action = "action", tutorial = "stand"},
		},
	},
	sociaty_dragon_shouwuhun_2 = {
		maxWave = 1,
		wave1 = {
			{time = 0, action = "play_weather_effect", tutorial = "5"},
			{id = "dizuo", time = 0, action = "create", tutorial = "61020;6.1;2.2"},
			{id = "dizuo", time = 0, action = "turn", tutorial = "left"},
			{time = 0, action = "hero_enter"},
			
			{id = "dizuo", time = 0.2, action = "play_dragon_soul"},
			{id = "dizuo", time = 2.7, action = "skill", tutorial = "51353;1"},
			
			{id = "dizuo", time = 3.5, action = "skill", tutorial = "51354;1"},
			{id = "boss_zhuti", time = 3.5, action = "create", tutorial = "61002;6.2;1.8"},
			{id = "boss_up", time = 3.5, action = "create", tutorial = "61005;6.1;2"},
			{id = "boss_down", time = 3.5, action = "create", tutorial = "61008;6.1;1.6"},
			{id = "boss_zhuti", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_up", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_down", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_zhuti", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_up", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_down", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "dizuo", time = 6.5, action = "hide_view"},
			{id = "boss_zhuti", time = 7.6, action = "action", tutorial = "stand"},
			{id = "boss_up", time = 7.6, action = "action", tutorial = "stand"},
			{id = "boss_down", time = 7.6, action = "action", tutorial = "stand"},
		},
	},
	sociaty_dragon_shouwuhun_3 = {
		maxWave = 1,
		wave1 = {
			{time = 0, action = "play_weather_effect", tutorial = "5"},
			{id = "dizuo", time = 0, action = "create", tutorial = "61021;6.1;2.2"},
			{id = "dizuo", time = 0, action = "turn", tutorial = "left"},
			{time = 0, action = "hero_enter"},
			
			{id = "dizuo", time = 0.2, action = "play_dragon_soul"},
			{id = "dizuo", time = 2.7, action = "skill", tutorial = "51353;1"},
			
			{id = "dizuo", time = 3.5, action = "skill", tutorial = "51354;1"},
			{id = "boss_zhuti", time = 3.5, action = "create", tutorial = "61003;6.2;1.8"},
			{id = "boss_up", time = 3.5, action = "create", tutorial = "61006;6.1;2"},
			{id = "boss_down", time = 3.5, action = "create", tutorial = "61009;6.1;1.6"},
			{id = "boss_zhuti", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_up", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_down", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_zhuti", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_up", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_down", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "dizuo", time = 6.5, action = "hide_view"},
			{id = "boss_zhuti", time = 7.6, action = "action", tutorial = "stand"},
			{id = "boss_up", time = 7.6, action = "action", tutorial = "stand"},
			{id = "boss_down", time = 7.6, action = "action", tutorial = "stand"},
		},
	},
	sociaty_dragon_shouwuhun_4 = {
		maxWave = 1,
		wave1 = {
			{time = 0, action = "play_weather_effect", tutorial = "5"},
			{id = "dizuo", time = 0, action = "create", tutorial = "61044;6.1;2.2"},
			{id = "dizuo", time = 0, action = "turn", tutorial = "left"},
			{time = 0, action = "hero_enter"},
			
			{id = "dizuo", time = 0.2, action = "play_dragon_soul"},
			{id = "dizuo", time = 2.7, action = "skill", tutorial = "51353;1"},
			
			{id = "dizuo", time = 3.5, action = "skill", tutorial = "51354;1"},
			{id = "boss_zhuti", time = 3.5, action = "create", tutorial = "61036;6.2;2"},
			{id = "boss_up", time = 3.5, action = "create", tutorial = "61037;6.1;2.2"},
			{id = "boss_down", time = 3.5, action = "create", tutorial = "61038;6.1;1.8"},
			{id = "boss_zhuti", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_up", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_down", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_zhuti", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_up", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_down", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "dizuo", time = 6.5, action = "hide_view"},
			{id = "boss_zhuti", time = 7.6, action = "action", tutorial = "stand"},
			{id = "boss_up", time = 7.6, action = "action", tutorial = "stand"},
			{id = "boss_down", time = 7.6, action = "action", tutorial = "stand"},
		},
	},
	
	sociaty_dragon_qiwuhun_1 = {
		maxWave = 1,
		wave1 = {
			{time = 0, action = "play_weather_effect", tutorial = "5"},
			{id = "dizuo", time = 0, action = "create", tutorial = "61022;6.1;2.2"},
			{id = "dizuo", time = 0, action = "turn", tutorial = "left"},
			{time = 0, action = "hero_enter"},
			
			{id = "dizuo", time = 0.2, action = "play_dragon_soul"},
			{id = "dizuo", time = 2.7, action = "skill", tutorial = "51353;1"},
			
			{id = "boss_zhuti", time = 3.5, action = "create", tutorial = "61010;6.1;2.1"},
			{id = "boss_up", time = 3.5, action = "create", tutorial = "61016;6.1;2.3"},
			{id = "boss_down", time = 3.5, action = "create", tutorial = "61013;6.1;1.9"},
			{id = "boss_zhuti", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_up", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_down", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_zhuti", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_up", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_down", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "dizuo", time = 3.9, action = "hide_view"},
			{id = "boss_zhuti", time = 5.3, action = "action", tutorial = "stand"},
			{id = "boss_up", time = 5.3, action = "action", tutorial = "stand"},
			{id = "boss_down", time = 5.3, action = "action", tutorial = "stand"},
		},
	},
	sociaty_dragon_qiwuhun_2 = {
		maxWave = 1,
		wave1 = {
			{time = 0, action = "play_weather_effect", tutorial = "5"},
			{id = "dizuo", time = 0, action = "create", tutorial = "61023;6.1;2.2"},
			{id = "dizuo", time = 0, action = "turn", tutorial = "left"},
			{time = 0, action = "hero_enter"},
			
			{id = "dizuo", time = 0.2, action = "play_dragon_soul"},
			{id = "dizuo", time = 2.7, action = "skill", tutorial = "51353;1"},
			
			{id = "boss_zhuti", time = 3.5, action = "create", tutorial = "61011;6.1;2.1"},
			{id = "boss_up", time = 3.5, action = "create", tutorial = "61017;6.1;2.3"},
			{id = "boss_down", time = 3.5, action = "create", tutorial = "61014;6.1;1.9"},
			{id = "boss_zhuti", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_up", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_down", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_zhuti", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_up", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_down", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "dizuo", time = 3.9, action = "hide_view"},
			{id = "boss_zhuti", time = 5.3, action = "action", tutorial = "stand"},
			{id = "boss_up", time = 5.3, action = "action", tutorial = "stand"},
			{id = "boss_down", time = 5.3, action = "action", tutorial = "stand"},
		},
	},
	sociaty_dragon_qiwuhun_3 = {
		maxWave = 1,
		wave1 = {
			{time = 0, action = "play_weather_effect", tutorial = "5"},
			{id = "dizuo", time = 0, action = "create", tutorial = "61024;6.1;2.2"},
			{id = "dizuo", time = 0, action = "turn", tutorial = "left"},
			{time = 0, action = "hero_enter"},
			
			{id = "dizuo", time = 0.2, action = "play_dragon_soul"},
			{id = "dizuo", time = 2.7, action = "skill", tutorial = "51353;1"},
			
			{id = "boss_zhuti", time = 3.5, action = "create", tutorial = "61012;6.1;2.1"},
			{id = "boss_up", time = 3.5, action = "create", tutorial = "61018;6.1;2.3"},
			{id = "boss_down", time = 3.5, action = "create", tutorial = "61015;6.1;1.9"},
			{id = "boss_zhuti", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_up", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_down", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_zhuti", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_up", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_down", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "dizuo", time = 3.9, action = "hide_view"},
			{id = "boss_zhuti", time = 5.3, action = "action", tutorial = "stand"},
			{id = "boss_up", time = 5.3, action = "action", tutorial = "stand"},
			{id = "boss_down", time = 5.3, action = "action", tutorial = "stand"},
		},
	},
	sociaty_dragon_qiwuhun_4 = {
		maxWave = 1,
		wave1 = {
			{time = 0, action = "play_weather_effect", tutorial = "5"},
			{id = "dizuo", time = 0, action = "create", tutorial = "61045;6.1;2.2"},
			{id = "dizuo", time = 0, action = "turn", tutorial = "left"},
			{time = 0, action = "hero_enter"},
			
			{id = "dizuo", time = 0.2, action = "play_dragon_soul"},
			{id = "dizuo", time = 2.7, action = "skill", tutorial = "51353;1"},
			
			{id = "boss_zhuti", time = 3.5, action = "create", tutorial = "61039;6.1;2.1"},
			{id = "boss_up", time = 3.5, action = "create", tutorial = "61041;6.1;2.3"},
			{id = "boss_down", time = 3.5, action = "create", tutorial = "61040;6.1;1.9"},
			{id = "boss_zhuti", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_up", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_down", time = 3.5, action = "turn", tutorial = "left"},
			{id = "boss_zhuti", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_up", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "boss_down", time = 3.5, action = "action", tutorial = "attack21"},
			{id = "dizuo", time = 3.9, action = "hide_view"},
			{id = "boss_zhuti", time = 5.3, action = "action", tutorial = "stand"},
			{id = "boss_up", time = 5.3, action = "action", tutorial = "stand"},
			{id = "boss_down", time = 5.3, action = "action", tutorial = "stand"},
		},
	},




-- 	wailing_caverns_4 = { 
-- 	    maxWave = 1,
-- 	    wave1 = {
-- 	        {id = "waiter", time = 0, action = "create", tutorial = "3722;3.5;3.5"},
-- 	        {id = "tangsan", time = 0, action = "create", tutorial = "1002;2.6;2.7"},
-- 			{id = "xiaowu", time = 0, action = "create", tutorial = "3730;2;2.7"},
-- 			{id = "waiter", time = 0, action = "turn", tutorial = "left"},
-- 			{id = "waiter", time = 0, action = "skill", tutorial = "50919;1"},
-- 			{id = "xiaowu", time = 0, action = "turn", tutorial = "right"},
-- 			{id = "tangsan", time = 8, action = "turn", tutorial = "left"},
-- 			{id = "tangsan", time = 8, action = "turn", tutorial = "right"},
-- 			{id = "xiaowu", time = 2.6, action = "speak", tutorial = "三哥，赶了这么久的路，先在这玫瑰酒店休息一晚吧。;3.3;1"},
-- 			{id = "xiaowu", time = 7, action = "action", tutorial = "stand"},
-- 			{id = "tangsan", time = 6.1, action = "speak", tutorial = "好，听你的。;1.5;1"},
-- 			{id = "tangsan", time = 7.1, action = "action", tutorial = "stand"},
-- 			{id = "xiaowu", time = 7.1, action = "action", tutorial = "stand"},
-- 			{id = "tangsan", time = 7.8, action = "speak", tutorial = "麻烦给我们开两间房。;1.5;1"},
-- 			{id = "waiter", time = 9.5, action = "action", tutorial = "stand2"},
-- 			{id = "waiter", time = 9.5, action = "speak", tutorial = "实在抱歉，我们只剩一间房了。;2;1"},
-- 			{id = "waiter", time = 11.7, action = "action", tutorial = "stand"},
-- 			{id = "xiaowu", time = 11.7, action = "speak", tutorial = "好，那么麻烦你帮我们开这间房吧。;2;1"},
-- 			{id = "xiaowu", time = 11.7, action = "action", tutorial = "victory"},
-- 			{id = "xiaowu", time = 13.9, action = "action", tutorial = "stand"},
-- 			{id = "daimubai", time = 13, action = "create", tutorial = "3725;6.7;2.1"},
-- 			{id = "nvban1", time = 13, action = "create", tutorial = "3723;6.5;2.4"},
-- 			{id = "nvban2", time = 13, action = "create", tutorial = "3724;6.8;1.9"},
-- 			{id = "daimubai", time = 13, action = "turn", tutorial = "left"},
-- 			{id = "daimubai", time = 13, action = "skill", tutorial = "50910;1"},
-- 			{id = "daimubai", time = 25, action = "action", tutorial = "stand_1"},
-- 			{id = "nvban1", time = 13.3, action = "move", tutorial = "-300;0"},
-- 			{id = "nvban2", time = 13.3, action = "move", tutorial = "-300;0"},
-- 			{id = "waiter", time = 14.5, action = "turn", tutorial = "right"},
-- 			{id = "daimubai", time = 14, action = "speak", tutorial = "慢着！我说，这间房应该属于我吧！;2.5;1"},
-- 			{id = "tangsan", time = 15, action = "turn", tutorial = "right"},
-- 			{id = "xiaowu", time = 15, action = "turn", tutorial = "right"},
-- 			{id = "tangsan", time = 16.8, action = "speak", tutorial = "这位大哥，似乎是我们先来的？;2;1"},
-- 			{id = "tangsan", time = 16.8, action = "action", tutorial = "attack13"},
-- 			{id = "tangsan", time = 18.5, action = "action", tutorial = "stand"},
-- 			{id = "daimubai", time = 19, action = "speak", tutorial = "那又怎样？！;1.2;1"},
-- 			{id = "xiaowu", time = 20.4, action = "skill", tutorial = "50914;1"},
-- 			{id = "xiaowu", time = 21.4, action = "speak", tutorial = "不怎么样，让你滚蛋！;2;1"},
-- 			{id = "nvban1", time = 23.5, action = "move", tutorial = "150;0"},
-- 			{id = "nvban2", time = 23.5, action = "move", tutorial = "150;0"},
-- 			{id = "nvban1", time = 25, action = "turn", tutorial = "left"},
-- 			{id = "nvban2", time = 25, action = "turn", tutorial = "left"},
-- 			{id = "nvban1", time = 25, action = "action", tutorial = "stand"},
-- 			{id = "nvban2", time = 25, action = "action", tutorial = "stand"},
-- 			-- {id = "daimubai", time = 25.5, action = "skill", tutorial = "50914;1"},
-- 			{id = "daimubai", time = 23, action = "speak", tutorial = "很好，打得过我，我立刻就走。;2.5;1"},
-- 			{id = "daimubai", time = 25.7, action = "speak", tutorial = "否则，请你们表演一下滚这个字！;2.5;1"},
-- 			-- {id = "daimubai", time = 28.5, action = "action", tutorial = "stand_1"},
-- 			{id = "tangsan", time = 29.2, action = "skill", tutorial = "50912;1"},
-- 	        {id = "xiaowu", time = 29.2, action = "skill", tutorial = "50913;1"},
-- 	    },    
--     },
--     wailing_caverns_6 = { 
-- 	    maxWave = 1,
-- 	    wave1 = {
-- 	        {id = "nvxueyuan1", time = 0, action = "create", tutorial = "3728;4.5;3.2"},
-- 	        {id = "nvxueyuan2", time = 0, action = "create", tutorial = "3728;4.5;1.9"},
-- 	        {id = "nanxueyuan1", time = 0, action = "create", tutorial = "3727;3.7;1"},
-- 	        {id = "nanxueyuan2", time = 0, action = "create", tutorial = "3727;3.2;2.5"},
-- 	        {id = "nanxueyuan3", time = 0, action = "create", tutorial = "3727;3.7;4"},
-- 	        {id = "tangsan", time = 0, action = "create", tutorial = "1002;2.5;3.2"},
-- 			{id = "xiaowu", time = 0, action = "create", tutorial = "1001;2.5;1.5"},
-- 			{id = "nvxueyuan1", time = 0, action = "turn", tutorial = "right"},
-- 	        {id = "nvxueyuan2", time = 0, action = "turn", tutorial = "right"},
-- 	        {id = "nanxueyuan1", time = 0, action = "turn", tutorial = "right"},
-- 	        {id = "nanxueyuan2", time = 0, action = "turn", tutorial = "right"},
-- 	        {id = "nanxueyuan3", time = 0, action = "turn", tutorial = "right"},
-- 	        {id = "tangsan", time = 0, action = "turn", tutorial = "right"},
-- 			{id = "xiaowu", time = 0, action = "turn", tutorial = "right"},
-- 	        {id = "nvxueyuan2", time = 2, action = "speak", tutorial = "嘿嘿，今天，我就要成为史莱克学院的学员！;3;1"},
-- 	        {id = "nvxueyuan2", time = 2, action = "action", tutorial = "attack01"},
-- 	        {id = "nvxueyuan2", time = 4, action = "action", tutorial = "stand"},
-- 	        {id = "nanxueyuan2", time = 5, action = "speak", tutorial = "以我的魂力，一定能通过测试！;2;1"},
-- 	        {id = "nanxueyuan2", time = 5, action = "action", tutorial = "attack12"},
-- 	        {id = "nanxueyuan2", time = 7, action = "action", tutorial = "stand"},
-- 			{id = "liuerlong", time = 4, action = "create", tutorial = "3726;7;2.5"},
-- 			{id = "liuerlong", time = 4, action = "hide_view"},
-- 			{id = "liuerlong", time = 4, action = "move", tutorial = "-300;0"},
-- 	        {id = "liuerlong", time = 7, action = "skill", tutorial = "50911;1"},
-- 	        {id = "liuerlong", time = 7.1, action = "show_view"},
-- 	        {id = "nvxueyuan2", time = 7.8, action = "action", tutorial = "attack22"},
-- 	        {id = "nvxueyuan2", time = 9.8, action = "action", tutorial = "attack22_1"},
-- 	       	{id = "nvxueyuan1", time = 7.8, action = "action", tutorial = "attack22"},
-- 	        {id = "nvxueyuan1", time = 9.8, action = "action", tutorial = "attack22_1"},
-- 	        {id = "nvxueyuan2", time = 12, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan1", time = 12, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan2", time = 13, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan1", time = 13, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan2", time = 14, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan1", time = 14, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan2", time = 15, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan1", time = 15, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan2", time = 16, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan1", time = 16, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan2", time = 17, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan1", time = 17, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan2", time = 18, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan1", time = 18, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan2", time = 19, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan1", time = 19, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan2", time = 20, action = "action", tutorial = "stand_1"},
-- 	        {id = "nvxueyuan1", time = 20, action = "action", tutorial = "stand_1"},
-- 	        -- {id = "nanxueyuan1", time = 9.5, action = "speak", tutorial = "魂圣！;1;1"},
-- 	        -- {id = "nanxueyuan2", time = 9.5, action = "speak", tutorial = "魂圣！;1;1"},
-- 	        -- {id = "nanxueyuan3", time = 9.5, action = "speak", tutorial = "魂圣！;1;1"},
-- 	        -- {id = "nvxueyuan1", time = 9.5, action = "speak", tutorial = "魂圣！;1;1"},
-- 	        -- {id = "nvxueyuan2", time = 9.5, action = "speak", tutorial = "魂圣！;1;1"},
-- 	        -- {id = "liuerlong", time = 11, action = "action", tutorial = "attack11"},
-- 	        {id = "nanxueyuan1", time = 8.7, action = "surprise"},
-- 	        {id = "nanxueyuan2", time = 8.7, action = "surprise"},
-- 	        {id = "nanxueyuan3", time = 8.7, action = "surprise"},
-- 	        {id = "nanxueyuan1", time = 9.7, action = "action", tutorial = "stand"},
-- 	        {id = "nanxueyuan2", time = 9.7, action = "action", tutorial = "stand"},
-- 	        {id = "nanxueyuan3", time = 9.7, action = "action", tutorial = "stand"},
-- 	        {id = "liuerlong", time = 10.2, action = "speak", tutorial = "年龄不行！魂力不行！;2;1"},
-- 	        {id = "liuerlong", time = 12.4, action = "speak", tutorial = "史莱克，只收怪物学生！请回吧！;2.7;1"},
-- 	        {id = "liuerlong", time = 10.2, action = "action", tutorial = "victory"},
-- 	        {id = "liuerlong", time = 12.4	, action = "action", tutorial = "attack02"},
-- 	        {id = "nanxueyuan1", time = 15, action = "skill", tutorial = "50484;1"},
-- 	        {id = "nanxueyuan2", time = 15, action = "skill", tutorial = "50485;1"},
-- 	        {id = "nanxueyuan3", time = 15, action = "skill", tutorial = "50486;1"},
-- 	        {id = "nvxueyuan1", time = 15, action = "skill", tutorial = "50487;1"},
-- 	        {id = "nvxueyuan2", time = 15, action = "skill", tutorial = "50916;1"},
-- 	        {id = "liuerlong", time = 14.2, action = "action", tutorial = "stand"},
-- 	        {id = "tangsan", time = 18.2, action = "speak", tutorial = "史莱克果然不一般！让我们试试！;2.5;1"},
-- 	        {id = "tangsan", time = 20.7, action = "skill", tutorial = "50912;1"},
-- 	        {id = "xiaowu", time = 20.7, action = "skill", tutorial = "50913;1"},
-- 	        {id = "nanxueyuan1", time = 19.2, action = "remove"},
-- 	        {id = "nanxueyuan2", time = 18.2, action = "remove"},
-- 	        {id = "nanxueyuan3", time = 19.2, action = "remove"},
-- 	        {id = "nvxueyuan1", time = 20.7, action = "remove"},
-- 	        {id = "nvxueyuan2", time = 20.7, action = "remove"},
-- 	        {id = "liuerlong", time = 21.7, action = "speak", tutorial = "这两个小家伙不错，让我来试试！;2.7;1"},
-- 	        {id = "liuerlong", time = 23, action = "skill", tutorial = "50918;1"},
-- 	    },    
--     },
--     wailing_caverns_8 = { 
-- 	    maxWave = 1,
-- 	    wave1 = {
-- 	        {id = "tangsan", time = 0, action = "create", tutorial = "1002;3.2;2.5"},
-- 			{id = "xiaowu", time = 0, action = "create", tutorial = "3730;2.9;1.5"},
-- 	        {id = "tangsan", time = 0, action = "turn", tutorial = "right"},
-- 			{id = "xiaowu", time = 0, action = "turn", tutorial = "right"},
-- 	        {id = "zhaowuji", time = 0, action = "create", tutorial = "3037;7.8;1.5"},
-- 	        {id = "zhaowuji", time = 0, action = "skill", tutorial = "50920;1"},
-- 	        {id = "zhaowuji", time = 9, action = "skill", tutorial = "50812;1"},
-- 	        -- {id = "xiaowu", time = 6.7, action = "skill", tutorial = "50525;1"},
-- 	        {id = "zhaowuji", time = 3.5, action = "speak", tutorial = "哈哈，听说今年的小怪物不少！;2;1"},
-- 	        {id = "zhaowuji", time = 5.7, action = "speak", tutorial = "这关就由我亲自来陪你们玩玩。;2.3;1"},
-- 	        {id = "xiaowu", time = 8, action = "speak", tutorial = "哼！有什么了不起的！;1.5;1"},
-- 	        {id = "xiaowu", time = 9.3, action = "skill", tutorial = "50921;1"},
-- 	        {id = "tangsan", time = 11, action = "surprise"},
-- 	        {id = "tangsan", time = 12, action = "turn", tutorial = "left"},
-- 	        -- {id = "tangsan", time = 13, action = "skill", tutorial = "50923;1"},
-- 	        -- {id = "tangsan", time = 8.7, action = "turn", tutorial = "left"},
-- 	        {id = "tangsan", time = 12.5, action = "move", tutorial = "-50;-100"},
-- 	        -- {id = "tangsan", time = 15.2, action = "turn", tutorial = "right"},
-- 	        -- {id = "zhaowuji", time = 7.7, action = "action", tutorial = "stand"},
-- 	        {id = "tangsan", time = 13.5, action = "speak", tutorial = "小舞，你没事吧！;1.5;1"},
-- 	        {id = "xiaowu", time = 15, action = "speak", tutorial = "好强！三哥，这个老师……已达到魂圣境界！;3;1"},
-- 	        {id = "tangsan", time = 18, action = "turn", tutorial = "right"},
-- 	        {id = "tangsan", time = 18, action = "speak", tutorial = "竟——敢——伤我小舞！;1.5;1"},
-- 	        {id = "tangsan", time = 18, action = "action", tutorial = "attack01"},
-- 	        {id = "tangsan", time = 19.5, action = "action", tutorial = "stand"},
-- 	        {id = "tangsan", time = 19.5, action = "speak", tutorial = "就算是魂圣，我唐三，也要和你一战！;3;1"},
-- 	        {id = "tangsan", time = 21.5, action = "skill", tutorial = "50917;1"},
-- 	        {id = "zhaowuji", time = 24.5, action = "speak", tutorial = "能抵挡我的攻击一柱香时间，就算你们赢！;3;1"},
-- 	        {id = "zhaowuji", time = 26.5, action = "skill", tutorial = "50915;1"},
-- 	    },    
--     },                          
}

return story_line