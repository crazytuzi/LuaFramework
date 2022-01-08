
local mapArray = 			MEMapArray:new()

--打第一关id = 1
mapArray:push({ id = 1,  	layer_name = "MenuLayer", 	widget_name = "pveBtn", 			next_step = 11,  tip_pos = {-270, 130}, hand_pos = {0,0}, 	tip = "千古大劫降临，天地巨变，我辈当尽力而为救世济民！请随我来~",rotation = 0})
mapArray:push({ id = 11,   	layer_name = "MissionLayer", 		widget_name = "",widget_rect = {47,52,175,465},next_step = 12, tip_pos = {400, 200}, hand_pos = {80,200},	tip = "此地阴阳汇聚暗藏玄机，你初出茅庐正需多加历练，去看看吧~",right = true })
mapArray:push({ id = 12,   	layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", next_step = 13,tip_pos = {-270, 100}, 	tip = "该出手时自当出手，擂鼓开战！"})
mapArray:push({ id = 13,   	layer_name = "FightUiLayer", 		widget_name = "roleskill1|roleicon",next_step = 14, tip_pos = {260, 100}, 	tip = "累积足够战意，就能释放法术了！点击这里立即释放！", force = false,right = true})
mapArray:push({ id = 14,   	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", next_step = 15 , tip_pos = {-100, 160}, 	tip = "恭喜你初战告捷！", save = true})
mapArray:push({ id = 15,	layer_name = "MissionLayer", 		widget_name = "btn_return", 		next_step = 0, tip_pos = {250, -800}, 	tip = ""})


--第一次抽卡固定抽钟灵id = 2
--mapArray:push({ id = 30,	layer_name = "MenuLayer", guideType = 1, 			widget_name = "zhaomuBtn", 						next_step = 35, picture = "ui_new/home/main_zhaomu_btn.png"})
mapArray:push({ id = 35,	layer_name = "MenuLayer", 			widget_name = "zhaomuBtn", 										right = true,next_step = 31, tip_pos = {280, 120}, hand_pos = {-5,10}, tip = "对手越来越强，得找更多帮手才行，来这里许愿吧！",rotation = 225 })
mapArray:push({ id = 31,	layer_name = "RecruitLayer", 			widget_name = "rolePanel1|getRoleBtn", offset = {-10,-145,-5,110},right = true ,next_step = 33, tip_pos = {300, 30}, 	tip = "集中精力，心中默许，看看他是否与你有缘？",save = true})
--mapArray:push({ id = 32,	layer_name = "MenuLayer", 			widget_name = "zhaomuBtn", 										next_step = 33, tip_pos = {-30, 340}, hand_pos = {-10,10}, tip = "一个好汉三个帮，再来找找其他人吧!",rotation = 225 })
--mapArray:push({ id = 33,	layer_name = "RecruitLayer", 			widget_name = "rolePanel1|getRoleBtn", offset = {0,0,0,0},right = true ,next_step = 0, tip_pos = {-20, 190}, 	tip = "通过这道门可以与更强的神灵结缘哦！"})
mapArray:push({ id = 33,	layer_name = "GetRoleResultLayer", 	widget_name = "returnBtn", 										next_step = 41, tip_pos = {-60, 170}, 	tip = "",next_functionId= 3})
--mapArray:push({ id = 34,	layer_name = "RecruitLayer", 			widget_name = "btn_return", 								next_step = 0, tip_pos = {250, -800},	tip = ""})

--第二次抽卡固定抽南海鳄神id = 3
mapArray:push({ id = 40,  open_lev = 0, 	layer_name = "MenuLayer", 			widget_name = "zhaomuBtn",rotation = 225, 		next_step = 41, right = true,tip_pos = {280, 120}, tip = "对手越来越强，你也需要更多帮手才行哟！",hand_pos = {-5,10}})
mapArray:push({ id = 41,  open_lev = 0, 	layer_name = "RecruitLayer", 		widget_name = "rolePanel2|getRoleBtn", 		 offset = {30,-140,-10,140},	next_step = 43, tip_pos = {-275,-150}, tip = "再次集中精力，心中默许，看看这次又是哪一位？",hand_pos = {10, 10},save = true})
mapArray:push({ id = 42,  open_lev = 0,		layer_name = "GetRoleResultLayer", 	widget_name = "rolebgImg",offset = {-560,-200,1100,600},next_step = 43, tip_pos = {-40, 170}, 	tip = "",	right = true,	hand_eff = "guide_hand", hand_pos = {110, -110}})
mapArray:push({ id = 43,  open_lev = 0, 	layer_name = "GetRoleResultLayer", 	widget_name = "returnBtn", 						next_step = 44, tip_pos = {-60, 170}, 	tip = ""})
mapArray:push({ id = 44,  open_lev = 0, 	layer_name = "RecruitLayer", 		widget_name = "btn_return", 					next_step = 0, tip_pos = {150, -800},	tip = "", right = true})

--钟灵上阵id = 4
mapArray:push({ id = 50,	layer_name = "MenuLayer", 			widget_name = "roleBtn", 			next_step = 51, tip_pos = {185, 260}, 	tip = "布阵是必须掌握的能力，巧妙的阵法可以发挥更大的威力。",rotation = 270,right = true})
mapArray:push({ id = 51,	layer_name = "ArmyLayer", 			widget_name = "panel_cardregional",  offset ={50,0,-80,-80}, next_step = 61, right = true ,tip_pos = {165, 240}, 	tip = "按住头像拖拽到位置上！", hand_pos = {-2, 242}, save = true,right = true, specialCall = 2 ,hand_eff = "guide_buzhen"})
mapArray:push({ id = 52,	layer_name = "ArmyLayer", 		widget_name = "btn_close", 			next_step = 0, tip_pos = {230, -170}, 	tip = ""})

--南海鳄神上阵id = 5,
mapArray:push({ id = 60,  open_lev = 0, 	layer_name = "MenuLayer", 			widget_name = "roleBtn", 						next_step = 61, tip_pos = {185, 260}, 	tip = "看看阵型布的如何了！",rotation = 270, right = true})
mapArray:push({ id = 61,  open_lev = 0, 	layer_name = "ArmyLayer", 			widget_name = "panel_cardregional", 			next_step = 71, tip_pos = {-300, 200}, tip = "阵位还没满，把所有人都派上阵吧！", hand_pos = {0, 240}, specialCall = 2, save = true , hand_eff = "guide_buzhen" ,hand_index = 1})

--南海鳄神移位id = 6,
mapArray:push({ id = 70,  open_lev = 0, 	layer_name = "MenuLayer", 			widget_name = "roleBtn", 						next_step = 71, tip_pos = {150, 260}, 	tip = "阵法精髓是攻守均衡，根据角色能力来安排合适的站位",hand_pos = {-10, 0},rotation = 270, right = true})
mapArray:push({ id = 71,  open_lev = 0, 	layer_name = "ArmyLayer", 			widget_name = "panel_buzhen", 					next_step = 72, right = true ,tip_pos = {680, 430}, 	tip = "已派上阵的角色可以拖拽来更换位置", specialCall = 3 ,hand_pos = {475, 320}, hand_eff = "guide_buzhen",hand_index = 2, save = true})
mapArray:push({ id = 72,  open_lev = 0, 	layer_name = "ArmyLayer", 			widget_name = "btn_close", 						next_step = 0,right = true , tip_pos = {250, -180}, tip = "看来你已掌握基本布阵之法了。"})

--领取上阵成就id = 7,
mapArray:push({ id = 80,	layer_name = "MenuLayer", 			widget_name = "taskBtn", 										next_step = 81, tip_pos = {210, 260}, hand_pos = {-5, 10},rotation = 225, 	tip = "有激励才有进步，每个成就虽然只是一小步，但奖励却很丰富！", right = true})
mapArray:push({ id = 81,	layer_name = "TaskLayer", 			widget_name = "listPanel|Button_Lingqu", 						next_step = 82, tip_pos = {200, 160}, tip = "恩，就是这里了，快点领取你的奖励吧!", hand_pos = {0, 0}, specialCall = 4, save = true, right = true})
mapArray:push({ id = 82,	layer_name = "TaskLayer", 			widget_name = "closeBtn", 										next_step = 0, tip_pos = {-50, -100}, 	tip = ""})

--打第二关id = 8
mapArray:push({ id = 90,	layer_name = "MenuLayer", 			widget_name = "pveBtn", 										next_step = 91, tip_pos = {-270, 130}, 	tip = "使命尚未完成，不可懈怠哟！"})
mapArray:push({ id = 91,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {277,52,175,465},next_step = 92, tip_pos = {0, 190}, hand_pos = {80,200},tip = ""  ,specialCall = 1 })
mapArray:push({ id = 92,	layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", 									next_step = 95, tip_pos = {-270, 100}, 	tip = "咦，这书生模样的人是谁？"})
mapArray:push({ id = 95,   	layer_name = "FightUiLayer", 		widget_name = "roleskill1|roleicon", 							next_step = 93, tip_pos = {250, 180}, 	tip = "", force = false})
mapArray:push({ id = 93,	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 										next_step = 94, tip_pos = {-150, 180}, 	tip = "哈哈，胜利如此简单!", save = true, next_functionId = 9})
mapArray:push({ id = 94,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {522,52,175,465}, 		next_step = 101, tip_pos = {-160, 180}, 	tip = "许仙你别着急，我们这就去同你一起去寻白娘子！"  ,specialCall = 1 , hand_pos = {80, 200}})
--mapArray:push({ id = 94,	layer_name = "MissionLayer", 		widget_name = "btn_return", 		225							next_step = 0})

--打第三关id = 9,
mapArray:push({ id = 100,	layer_name = "MenuLayer", 			widget_name = "pveBtn", 					next_step = 101, tip_pos = {-100, 200}, tip = "历练之路才刚开始呢",ight = true})
mapArray:push({ id = 101,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {522,52,175,465}, 		next_step = 102, tip_pos = {-160, 180}, 	tip = "许仙你别着急，我们这就去同你一起去寻白娘子！"  ,specialCall = 1 , hand_pos = {80, 200}})
mapArray:push({ id = 102,	layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", 			next_step = 103, tip_pos = {-10, 200}, 	tip = "", right = true})
mapArray:push({ id = 103,	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 					next_step = 104, tip_pos = {-170, 180}, 	tip = "先是许仙，再是小青，接着是不是该法海了！", save = true, next_functionId = 10})
mapArray:push({ id = 104,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {522,52,175,465}, next_step = 121, tip_pos = {-160, 180}, 	tip = "天材地宝能提高境界，是提升实力很重要的东西，切记切记！"  ,specialCall = 1 , hand_pos = {80, 200} })
--mapArray:push({ id = 104,	layer_name = "MissionLayer", 		widget_name = "btn_return", 				next_step = 0, tip_pos = {250, -800}, 	tip = ""})

--打第四关id = 10
mapArray:push({ id = 120,	layer_name = "MenuLayer", 			widget_name = "pveBtn", 					next_step = 121, tip_pos = {-100, 200}, tip = "路漫漫其修远兮~", right = true})
mapArray:push({ id = 121,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {522,52,175,465}, next_step = 122, tip_pos = {-160, 180}, 	tip = "天材地宝能提升境界，是提升实力很重要的东西，切记！"  ,specialCall = 1 , hand_pos = {80, 200} })
mapArray:push({ id = 122,		layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", 			next_step = 123, tip_pos = {-270, 100}, 	tip = "快进去看看，这里有没有我们需要的东西！"})
mapArray:push({ id = 123,	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 					next_step = 124, tip_pos = {-170, 180}, 	tip = "果然发现了有可以立即加以使用的仙草呢！",save = true})
mapArray:push({ id = 124,	layer_name = "MissionLayer", 		widget_name = "btn_return", 				next_step = 0, tip_pos = {250, -800}, 	tip = ""})

--穿戴秘籍id = 11,
mapArray:push({ id = 130,	layer_name = "MenuLayer", 			widget_name = "armature1", widget_rect = {238,100,125,220}, next_step = 131, tip_pos = {330, 100},  tip = "这里都是已上阵的角色，点击他们可以直接进行培养！", hand_pos = {50, 90}, right = true})
mapArray:push({ id = 131,	layer_name = "RoleInfoLayer", 		widget_name = "panel_book_1|img_quality", 	   	  next_step = 132, tip_pos = {-50,-170},   tip = "炼化天材地宝可提升境界，提升后会增强能力还能觉醒新技能"})
mapArray:push({ id = 132,	layer_name = "RoleBook_OnEquip", 	widget_name = "btn_qxkl", 						  next_step = 133, tip_pos = {-120, 160},  tip = "炼化后能获得一定的属性提升！试一试吧！", save = true})
mapArray:push({ id = 133,	layer_name = "RoleInfoLayer", 		widget_name = "btn_close", 						  next_step = 0, tip_pos = {250, -250}, tip = ""})

--打boss关id = 12
mapArray:push({ id = 140,	layer_name = "MenuLayer", 			widget_name = "pveBtn", 			next_step = 141, tip_pos = {-270, 130}, 	tip = "下一回还能这么轻松么?"})
mapArray:push({ id = 141,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {522,52,175,465}, 	next_step = 142, tip_pos = {-160, 180}, 	tip = "这不是白娘子嘛，赶快追上去吧。"  ,specialCall = 1 ,hand_pos = {80, 200}})
mapArray:push({ id = 142,	layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", 		next_step = 143, tip_pos = {-270, 100}, 	tip = ""})
mapArray:push({ id = 143,	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 			next_step = 144, tip_pos = {-170, 180}, 	tip = "",  save = true})
mapArray:push({ id = 144,	layer_name = "MissionLayer", 		widget_name = "btn_return", 		next_step = 0, tip_pos = {250, -800}, 	tip = ""})

--领取boss成就id = 21,
mapArray:push({ id = 145,	layer_name = "MenuLayer", 			widget_name = "taskBtn",rotation = 225, 			next_step = 146, tip_pos = {260, 130}, 	tip = "记得随时要留意是否有成就奖励可以领取哟！",right=true})
mapArray:push({ id = 146,	layer_name = "TaskLayer", 			widget_name = "listPanel|Button_Lingqu", 			next_step = 147, tip_pos = {250, 160},tip = "", hand_pos = {0, 0} ,specialCall = 4, save = true})
mapArray:push({ id = 147,	layer_name = "TaskLayer", 			widget_name = "closeBtn", 			next_step = 0, tip_pos = {-230, -100}, 	tip = "刚获得宝物别忘记用啦~"})

--装备3本秘籍 - 装备第二本id = 22
mapArray:push({ id = 148,	layer_name = "MenuLayer", 			widget_name = "armature1", widget_rect = {238,100,125,220}, next_step = 149, tip_pos = {300, 100},  tip = "", hand_pos = {50, 90}})
mapArray:push({ id = 149,	layer_name = "RoleInfoLayer", 		widget_name = "panel_book_2|img_quality", next_step = 1491, tip_pos = {-150,-170},   tip = "", hand_pos = {0, 0}})
mapArray:push({ id = 1491,	layer_name = "RoleBook_OnEquip", 	widget_name = "btn_qxkl", 			next_step = 1492, tip_pos = {-200, 150},  tip = "", save = true,next_functionId =23})

--装备3本秘籍 - 装备第三本id = 23
mapArray:push({ id = 1480,	layer_name = "MenuLayer", 			widget_name = "armature1", widget_rect = {238,100,125,220}, next_step = 1492, tip_pos = {300, 100},  tip = "", hand_pos = {50, 90}})
mapArray:push({ id = 1492,	layer_name = "RoleInfoLayer", 		widget_name = "panel_book_3|img_quality", next_step = 1493, tip_pos = {-150,-170},   tip = "", hand_pos = {0, 0}})
mapArray:push({ id = 1493,	layer_name = "RoleBook_OnEquip", 	widget_name = "btn_qxkl", 			next_step = 1494, tip_pos = {-200, 150},  tip = "", save = true,next_functionId =24})

--装备3本秘籍 - 装备第四本id = 24
mapArray:push({ id = 1481,	layer_name = "MenuLayer", 			widget_name = "armature1",  widget_rect = {238,100,125,220}, next_step = 1494, tip_pos = {300, 100},  tip = "", hand_pos = {50, 90}})
mapArray:push({ id = 1494,	layer_name = "RoleInfoLayer", 		widget_name = "panel_book_4|img_quality", next_step = 1495, tip_pos = {-150,-170},   tip = "", hand_pos = {0, 0}})
mapArray:push({ id = 1495,	layer_name = "RoleBook_OnEquip", 	widget_name = "btn_qxkl", 			next_step = 1496, tip_pos = {-200, 150},  tip = "", save = true})
mapArray:push({ id = 1496,	layer_name = "RoleInfoLayer", 		widget_name = "btn_close", 			next_step = 1497, tip_pos = {250, -250}, tip = "",next_functionId =28})

--装备3本秘籍 - 领成就id = 28
--mapArray:push({ id = 1482,	layer_name = "MenuLayer", 			widget_name = "armature1", offset ={-40,0,90,40}, next_step = 1497,  tip_pos = {-250, 70},  tip = "", hand_pos = {0, 80}})
mapArray:push({ id = 1497,	layer_name = "MenuLayer", 			widget_name = "taskBtn",rotation = 225, 		  next_step = 1498, tip_pos = {260, 130}, save = true,	tip = "成就中出现新的目标出现咯！",right=true})   ---打开成就面板
mapArray:push({ id = 1498,	layer_name = "TaskLayer", 			widget_name = "listPanel|Button_Qianwang", next_step = 1501, tip_pos = {250, 200},tip = "向着新的目标出发！", hand_pos = {0, 10} ,specialCall = 6, save = true,next_functionId = 29, right = true}) --点击前往，进入关卡
--mapArray:push({ id = 1499,	layer_name = "MissionLayer", 	widget_name = "cur_mission|btn_base", 			next_step = 1500, tip_pos = {-100, 200}, 	tip = "快去搜集剩下的秘籍吧！我猜在第八关会掉哦~",specialCall = 1, right = true,next_functionId = 29})

--打第六关id = 29
mapArray:push({ id = 1500,	layer_name = "MenuLayer", 			widget_name = "pveBtn", 			next_step = 1501, tip_pos = {-100, 200}, 	tip = "雷峰塔看上去就在不远处了！", right = true})
mapArray:push({ id = 1501,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {522,52,175,465}, next_step = 1502, tip_pos = {-160,180}, 	tip = ""  ,specialCall = 1 , hand_pos = {80,200}})
mapArray:push({ id = 1502,	layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", 		next_step = 1503, tip_pos = {-10, 200}, 	tip = "", right = true})
mapArray:push({ id = 1503,	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 			next_step = 1515, tip_pos = {-150, 180}, 	tip = "", right = true, save = true,next_functionId = 32})
mapArray:push({ id = 1515,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {522,52,175,465},next_step = 1505, tip_pos = {-160, 180}, 	tip = ""  ,specialCall = 1 , hand_pos = {80, 200}})

--打第七关id = 32
mapArray:push({ id = 1504,	layer_name = "MenuLayer", 			widget_name = "pveBtn", 			next_step = 1505, tip_pos = {-100, 200}, 	tip = "戾气太重了，小心为上！", right = true})
mapArray:push({ id = 1505,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {522,52,175,465},	next_step = 1506, tip_pos = {-160, 180}, 	tip = ""  ,specialCall = 1 , hand_pos = {80, 200}})
mapArray:push({ id = 1506,	layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", 		next_step = 1507, tip_pos = {-270, 100}, 	tip = "抓紧时间赶路！"})
mapArray:push({ id = 1507,	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 			next_step = 1617, tip_pos = {-150, 180}, 	tip = "", right = true, save = true,next_functionId = 25})
mapArray:push({ id = 1617,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {432,52,175,465},next_step = 160, tip_pos = {-160, 180}, 	tip = "", right = true,specialCall = 1, hand_pos = {80, 200}})

--武学升阶指引-第八关 id = 25
mapArray:push({ id = 1508,	layer_name = "MenuLayer", 			widget_name = "pveBtn", 			next_step = 160, tip_pos = {-100, 200}, 	tip = "", right = true})
mapArray:push({ id = 160,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {432,52,175,465},next_step = 161, tip_pos = {-160, 180}, 	tip = "", right = true,specialCall = 1, hand_pos = {80, 200}})
mapArray:push({ id = 161,	layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", 		next_step = 162, tip_pos = {-270, 100}, 	tip = "拿着佛珠，快赶路吧"})
mapArray:push({ id = 162,	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 			next_step = 163, tip_pos = {-170, 180}, 	tip = "会掉宝物的地方一定得多多留意！", save = true})
mapArray:push({ id = 163,	layer_name = "MissionLayer", 		widget_name = "btn_return", 		next_step = 164, tip_pos = {200, -160}, 	tip = "先去把新获得的仙草炼化了", right = true,next_functionId = 26})
-- mapArray:push({ id = 16999,	layer_name = "TaskLayer", 			widget_name = "closeBtn", 			next_step = 164, tip_pos = {-200, -150}, 	tip = ""})

--填秘籍&寻找秘籍 id = 26
mapArray:push({ id = 164,	layer_name = "MenuLayer", 		    widget_name = "armature1",  widget_rect = {238,100,125,220},			next_step = 165, tip_pos = {300, 100},	tip = "炼化能提升属性，把包里的都炼化了吧！", hand_pos = {50, 90}, right = true})
mapArray:push({ id = 165,	layer_name = "RoleInfoLayer", 		widget_name = "panel_book_5|img_quality", 			next_step = 166, tip_pos = {-250, 0}, 	tip = ""})---习得第五本秘籍
mapArray:push({ id = 166,	layer_name = "RoleBook_OnEquip", 	widget_name = "btn_qxkl", 			next_step = 167, tip_pos = {-200, 150},  tip = "",save = true,next_functionId = 33})

-- 扫荡第六本秘籍 guide id = 33
mapArray:push({ id = 1661,	layer_name = "MenuLayer", 		   widget_name = "armature1",  widget_rect = {238,100,125,220},		next_step = 167, tip_pos = {300, 100},	tip = "", hand_pos = {50, 90}, right = true})
mapArray:push({ id = 167,	layer_name = "RoleInfoLayer", 		widget_name = "panel_book_6|img_quality", 			next_step = 168, tip_pos = {-250, 0}, 	tip = "还差一点嘛，再炼化一个就可以提升境界了！"})
mapArray:push({ id = 168,	layer_name = "RoleBook_OnEquip", 	widget_name = "btn_qxkl", 			next_step = 169, tip_pos = {-120, 160},  tip = "看看最后这个要去哪里找。"}) -- 点击获取武学按钮
mapArray:push({ id = 169,	layer_name = "RoleBook_OnEquip",	widget_name = "pannel_getwaylist|HandbookOutPutCell", 		offset ={218,0,0,0},			next_step = 1691, tip_pos = {-350, 200}, tip = "", hand_pos = {218, 0},specialCall = 8})-- 点击掉落途径 前往关卡
mapArray:push({ id = 1691,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {432,52,175,465},	next_step = 1692, tip_pos = {-120, 180}, 	tip = ""  ,specialCall = 1 , hand_pos = {80, 200}, right = true}) -- 关卡按钮
mapArray:push({ id = 1692,	layer_name = "MissionDetailLayer", 	widget_name = "btn_quick1", 		next_step = 1693, tip_pos = {-80, 200}, 	tip = "扫荡能快速获得所需要的东西哟！", save = true}) -- 扫荡按钮
mapArray:push({ id = 1693,  layer_name = "QuickPassReslutListLayer", 	widget_name = "btn_close", 	next_step = 1694, tip_pos = {0, -150}, 	tip = "", hand_pos = {0, 0}}) --关闭扫荡
mapArray:push({ id = 1694,  layer_name = "MissionDetailLayer", 	 widget_name = "Btn_close", 	   next_step = 1695, tip_pos = {150, -100},	tip = "",right = true, hand_pos = {0, 0}})-- 关闭关卡挑战界面-点击任意区域
mapArray:push({ id = 1695,	layer_name = "MissionLayer", 		 widget_name = "btn_return", 	    next_step = 1696, tip_pos = {150, -200}, 	tip = "", right = true,next_functionId = 34}) --- 关卡返回  主界面
-- widget_name = "Btn_close", 		offset = {7,7,-15,-19}

--武学进阶（断掉后从主界面进入）id = 34
mapArray:push({ id = 16951,	layer_name = "MenuLayer", 		   widget_name = "armature1",  widget_rect = {238,100,125,220},		next_step = 16952, tip_pos = {300, 100},	tip = "炼化完6种了，可以进阶了！", hand_pos = {50, 90}, right = true}) -- 点击打开角色面板
mapArray:push({ id = 16952,	layer_name = "RoleInfoLayer", 		widget_name = "panel_book_6|img_quality", next_step = 1696, tip_pos = {-150,-170},   tip = "", hand_pos = {0, 0}})
mapArray:push({ id = 1696,	layer_name = "RoleBook_OnEquip", 	widget_name = "btn_qxkl", 		next_step = 1697, tip_pos = {-200, 150},    tip = "", save = true, next_functionId = 27}) ---点击习得

--武学进阶（没断掉后直接习得）id = 27
mapArray:push({ id = 16971,	layer_name = "MenuLayer", 		    widget_name = "armature1",  widget_rect = {238,100,125,220},	next_step = 1697, tip_pos = {300, 100},	tip = "炼化完6种了，可以进阶了！", hand_pos = {50, 90}, right = true}) -- 点击打开角色面板
mapArray:push({ id = 1697,	layer_name = "RoleInfoLayer",	 	widget_name = "btn_jinjie", 	next_step = 1698, tip_pos = {-100, -100},	tip = "大功即将告成，赶快点击进阶，就能把境界提升一重。" ,save = true,specialCall = 7})
mapArray:push({ id = 1698,	layer_name = "RoleBreakResultLayer", widget_name = "btn_close", 	next_step = 1670	, tip_pos = {20, -60},	right= true,    tip = "" ,force=false,next_functionId = 15,hand_pos = {0 ,0}})

--技能升级
--武学进阶（断掉后从主界面进入） id = 15
mapArray:push({ id = 16701,	layer_name = "MenuLayer", 		    widget_name = "armature1",  widget_rect = {238,100,125,220},	next_step = 1670, tip_pos = {300, 100},	tip = "技能的效果不是固定的，提升等级后会让作战更有利！", hand_pos = {50, 90}, right = true}) -- 点击打开角色面板
--技能升级（习得后直接升技能）
mapArray:push({ id = 1670,	layer_name = "RoleInfoLayer", 		widget_name = "btn_skill", 			next_step = 1671, tip_pos = {-250, 40}, 	tip = "点这里能对技能进行提升！"})
mapArray:push({ id = 1671,	layer_name = "RoleSkillListLayer", 	widget_name = "Image_RoleSkillListLayer_1",next_step = 1672, tip_pos = {-150,  -100},	tip = "这里是你现在拥有的技能点", hand_pos = {550, 510},trigger = true})
mapArray:push({ id = 1672,	layer_name = "RoleSkillListLayer", 	widget_name = "panel_item_1|btn_uplevel", 		next_step = 1673, 	 tip_pos = {130, -100},	tip = "点击这里会升级技能", save = true,hand_pos = {0, 0}, right = true})
mapArray:push({ id = 1673,	layer_name = "RoleSkillListLayer", 	widget_name = "btn_close", 		    next_step = 1674, 	 tip_pos = {0, -150},	tip = "", hand_pos = {0, 0}, right = true}) --关闭技能 
mapArray:push({ id = 1674,	layer_name = "RoleInfoLayer", 	    widget_name = "btn_close", 		    next_step = 1675,   tip_pos = {150, -100},	tip = "", next_functionId = 31,hand_pos = {0, 0}, right = true,next_functionId = 31}) --关闭角色界面

-- 领取进阶成就，前往关卡继续收集武学 id = 31
mapArray:push({ id = 1675,	layer_name = "MenuLayer", 			widget_name = "taskBtn",rotation = 225, 		next_step = 1676, tip_pos = {-270, 130}, 	tip = "看这里，又有新的成就完成啦，可以领取奖励咯~", right = true})
mapArray:push({ id = 1676,	layer_name = "TaskLayer", 			widget_name = "listPanel|Button_Lingqu", 		next_step = 1677, tip_pos = {250, 160},tip = "", hand_pos = {0, 0} ,specialCall = 4,save = true,next_functionId = 35, right = true}) --领取成就

-- 领取后，关闭界面重新进入，前往关卡继续收集武学 id = 35
mapArray:push({ id = 16751,	layer_name = "MenuLayer", 			widget_name = "taskBtn",rotation = 225, 		next_step = 1677, tip_pos = {-50, 269}, 	tip = "目标明确，提升战力更加得心应手"})
mapArray:push({ id = 1677,	layer_name = "TaskLayer", 			widget_name = "listPanel|Button_Qianwang", 			    next_step = 1678, tip_pos = {250, 160},tip = "继续历练，可以获得更多提升！", hand_pos = {0, 0},specialCall = 6,right = true}) --继续去关卡
mapArray:push({ id = 1678,	layer_name = "MissionLayer", 		widget_name = "", widget_rect = {666,52,175,465},		next_step =1679, tip_pos = {-120, 180}, 	tip = "", right = true, specialCall = 1,hand_pos = {80, 200}})--打关卡
mapArray:push({ id = 1679,   	layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", next_step = 1680,tip_pos = {-10, 200}, 	tip = ""})
mapArray:push({ id = 1680,   	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", next_step = 0 , tip_pos = {-100, 150}, 	tip = "接下来就看你自己的啦！", save = true})

--循环关卡
mapArray:push({ id = 1700,  	layer_name = "MenuLayer", 	widget_name = "pveBtn", 	force=false,		next_step = 1700, tip_pos = {-270, 150}, hand_pos = {0,0}, 	tip = "",rotation = 0})
-------------------------------玩法开放-----------------------------------------
 
--阵位4上阵
mapArray:push({ id = 3100, layer_name = "MenuLayer", 			widget_name = "taskBtn" ,rotation = 225,		    next_step = 3101, tip_pos ={260, 130}, tip = "新的阵位开启了，点击成就",name = "阵位开启",right = true})
mapArray:push({ id = 3101, layer_name = "TaskLayer", 			widget_name = "listPanel|Button_Lingqu", 		next_step = 3102, tip_pos = {240, 180}, tip = "竟然是黄河之神“河伯”", hand_pos = {0, 0}, specialCall = 4,right = true,save = true})
mapArray:push({ id = 3102, layer_name = "TaskLayer", 			widget_name = "closeBtn", 						next_step = 3103, tip_pos = {-20, -150}, 	tip = ""})
mapArray:push({ id = 3103, layer_name = "MenuLayer", 			widget_name = "armature4",widget_rect = {620,230,90,150},next_step = 0, tip_pos ={-100,-40}, tip = "点击上阵更多神灵吧！聚仙可以招募更多神灵哟~", hand_pos = {60,40}})

--阵位5上阵
mapArray:push({ id = 3200, layer_name = "MenuLayer",			widget_name = "armature5",widget_rect = {840,160,90,150}, next_step = 0, tip_pos ={-120,0}, tip = "新的阵位开启了~点击上阵更多神灵吧！聚仙可以招募更多神灵哟~", hand_pos = {60,40}, save = true,name = "阵位开启"})

--日常
mapArray:push({ id = 150,	layer_name = "MenuLayer",  guideType = 1, 			widget_name = "openBtn", 			next_step = 154, picture = "ui_new/task/cj_richang.png"}) --加入日常任务UI
mapArray:push({ id = 154,	layer_name = "MenuLayer", 			widget_name = "openBtn", 			next_step = 151, tip_pos = {-280, -50},rotation = 45, tip = "日常任务开启！新的修炼方式快来试试~", hand_pos = {0,0}}) --点选日常任务
mapArray:push({ id = 151,   layer_name = "TaskLayer", 			widget_name = "listPanel|Button_Lingqu", 			next_step = 0, tip_pos = {240,180}, tip = "团队等级需要大量经验值，日常任务的海量经验可不能错过哦！", save = true,right = true , specialCall = 4, hand_pos = {0,0}})
--mapArray:push({ id = 152,   layer_name = "TaskLayer", 			widget_name = "listPanel|Button_Qianwang", 			next_step = 153, tip_pos = {-150,-100}, tip = "戳一下前往，自动带路到任务地点~", hand_pos = {0,0}})
--mapArray:push({ id = 153,	layer_name = "MissionLayer", 		widget_name = "cur_mission|btn_base", 		next_step = 0, tip_pos = {100, 210}, 	tip = "一口气完成所有任务吧！ ", hand_pos = {0, 20}, right = true, specialCall = 1})

--奇遇


mapArray:push({ id = 2301,  layer_name = "MenuLayer", guideType = 1,    widget_name = "qiyuBtn",    next_step = 2302, picture = "ui_new/home/main_qiyu_btn.png"})
mapArray:push({ id = 2302,	layer_name = "MenuLayer", 			widget_name = "qiyuBtn", 			next_step = 2303, tip_pos = {-240, 60}, hand_pos = {0,10}, tip = "",save = true,rotation = 225})
mapArray:push({ id = 2303,	layer_name = "QiyuHomeLayer",	 	widget_name = "qiyuButton_5", 	next_step = 0	, tip_pos = {0, 300}, tip = "点这里进去就能签到了！",hand_pos = {75, 75}})

--商城
mapArray:push({ id = 2401,	layer_name = "MenuLayer", guideType = 1, widget_name = "mallBtn",	next_step = 2402, picture = "ui_new/home/main_shangcheng_btn.png"})
mapArray:push({ id = 2402,	layer_name = "MenuLayer",	 	widget_name = "mallBtn", 		next_step = 2403	, tip_pos = {200, 190}, tip = "商城终于开放啦~买买买！",right = true, rotation = 225, save = true})
mapArray:push({ id = 2403,	layer_name = "MallLayer", 			widget_name = "btn_2",		next_step = 2404	,tip_pos = {300,0}, tip = "送你个福利敢要不？~", right = true})
mapArray:push({ id = 2404,	layer_name = "MallLayer", 			widget_name = "",				next_step = 0	, tip_pos = {650,325}, tip = "VIP有超值礼包可以购买哦~先送你个VIP0礼包试试运气吧~", right = true, hand_pos = {1400,-850}, hand_eff = "guide_hand"})

--好友
mapArray:push({ id = 3300,	layer_name = "MenuLayer", guideType = 1, widget_name = "btn_friends",	next_step = 3301, picture = "ui_new/home/main_haoyou_btn.png"})
mapArray:push({ id = 3301, layer_name = "MenuLayer", widget_name ="btn_friends", next_step = 3302, tip_pos = {290,270}, tip = "好友玩法开放，快到这里来寻找志同道合的朋友吧！", rotation = 225,right = true, save = true, name = "好友系统"})--
--mapArray:push({ id = 3301, layer_name = "FriendLayer", widget_name = "btn_friends", next_step = 3302, tip_pos = {180,0}, tip = "这里是好友列表", right = true, hand_pos = {0,0}, hand_eff = "guide_hand"})
mapArray:push({ id = 3302, layer_name = "FriendLayer", widget_name = "btn_add" , next_step = 3303, tip_pos = {120,-200}, tip = "这里可以申请其他玩家为好友，还有推荐好友哦~",right = true})
mapArray:push({ id = 3303, layer_name = "FriendLayer", widget_name = "Btn_add" , next_step = 0, tip_pos = {0,-200}, tip = "点击全部申请，可以主动添加对方为好友哦~", hand_pos = {0,0}, rotation = 0})

--巡山
mapArray:push({ id = 3401,	layer_name = "MenuLayer", 			widget_name = "qiyuBtn", 		next_step = 3402, tip_pos = {-240, 0}, hand_pos = {0,10}, tip = "巡山开放，快快来击退他们。",rotation = 225,save = true, name = "护驾"})--
mapArray:push({ id = 3402,	layer_name = "QiyuHomeLayer",	 	widget_name = "qiyuButton_4", 	next_step = 3403, tip_pos = {-50, 300}, tip = "大王叫我来巡山，我把三界转一转。",hand_pos = {65, 65},rotation = 270})
--mapArray:push({ id = 3403,	layer_name = "QiyuHomeLayer",		widget_name = "btn_hujia", 		next_step = 0	 ,tip_pos = {-240,180}, tip = "快去击退刺客吧！连续多天护驾还有额外的大宝箱哦~可不能中断吖！",right = true})
mapArray:push({ id = 3403,	layer_name = "QiyuHomeLayer",		widget_name = "btn_hujia", 		next_step = 0	 ,tip_pos = {-270,50}, tip = "发现敌人，快去击退他们吧！连续多天巡山还有额外奖品哦~中间不能中断哟！",hand_pos = {0, 0}})

--挖矿系统
mapArray:push({ id = 3411,	layer_name = "MenuLayer", 			widget_name = "qiyuBtn", 		next_step = 3412, tip_pos = {-240, 60}, hand_pos = {0,10}, tip = "新玩法：铜币赢取宝石，快来试试手气！",rotation = 225,save = true, name = "三清仙境"})--
mapArray:push({ id = 3412,	layer_name = "QiyuHomeLayer",	 	widget_name = "qiyuButton_6", 	next_step = 3413, tip_pos = {0, 200}, tip = "",hand_pos = {0, 0}})
mapArray:push({ id = 3413,	layer_name = "QiyuHomeLayer",		widget_name = "", 		next_step = 0	 ,tip_pos = {660,450}, tip = "",hand_pos = {790, 210},rotation = 90, hand_eff = "guide_hand",right = true})

--聚贤斗法
mapArray:push({ id = 601,	layer_name = "MenuLayer", 			widget_name = "pvpBtn", 			next_step = 602,tip_pos = {0, 200}, 	tip = "聚贤斗法开启，快来与其他上仙在斗法大会上一比高下！", name = "聚贤斗法"})
mapArray:push({ id = 602,	layer_name = "ActivityLayer", 		widget_name = "btn_go",				next_step = 603,tip_pos = {-220, 20},	tip = "挑选一个对手就开始吧！"})
mapArray:push({ id = 603,	layer_name = "ArenaPlayerListLayer",widget_name = "btn_refresh", 		next_step = 604,tip_pos = {-300, 150},  tip = "对手有强有弱，选择和自己战力接近的对手更容易获得胜利。", trigger = true, hand_pos = {30, 0}, right = true})
mapArray:push({ id = 604,	layer_name = "ArenaPlayerListLayer",widget_name = "img_res_bg_1", 		next_step = 605,tip_pos = {0, -150},	tip = "拥有斗法战令才能进行挑战，数量在零点时会刷新。", hand_pos = {10, -60},  hand_pos = {500, 500},right = true})
mapArray:push({ id = 605,	layer_name = "ArenaPlayerListLayer",widget_name = "btn_duihuan", 		next_step = 606,tip_pos = {-150, -220},	tip = "这里是斗法商店，可以用获得的斗法积分兑换稀有道具！" , right = true})
mapArray:push({ id = 606,	layer_name = "ArenaPlayerListLayer",widget_name = "panel_role1", 		next_step = 607,tip_pos = {-200, 220},	tip = "斗法胜利可以获得积分，随着排名提升，奖励也会更加丰厚。", hand_pos = {100, 120}})
mapArray:push({ id = 607,	layer_name = "ArenaOtherArmyVSLayer",widget_name = "btn_challenge", 	next_step = 608,tip_pos = {-300, 130},	offset ={-20,0,0,0}, tip = "向着斗法巅峰进发吧！", save = true})
mapArray:push({ id = 608,	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 			next_step = 0, tip_pos = {-50, 220},	tip = "", right = true})

--钓鱼
mapArray:push({ id = 3501,	layer_name = "MenuLayer", 			widget_name = "qiyuBtn", 			next_step = 3502, tip_pos = {-240, 60}, hand_pos = {0,10}, tip = "钓鱼开放啦！",rotation = 225,save = true, name = "钓鱼"})--
mapArray:push({ id = 3502,	layer_name = "QiyuHomeLayer",	 	widget_name = "qiyuButton_3", 		next_step = 3503, tip_pos = {0, 300}, tip = "一天可以钓鱼五次，等待成果的时候上仙可以去玩别的玩法~",hand_pos = {65, 65},rotation = 315})
mapArray:push({ id = 3503,	layer_name = "QiyuHomeLayer",		widget_name = "btn_shuaxin", 					next_step = 0, 	  tip_pos = {-270,0},tip = "点击刷新按钮有机率获取高级鱼竿，越高级的鱼竿可以钓到更大的鱼，换取更多的铜钱哦~",hand_pos = {0, 0}})

--困难关卡
mapArray:push({ id = 5001,  open_lev = 15, 	layer_name = "MenuLayer", 			widget_name = "pveBtn"  , 			next_step = 5002, tip_pos = {-100, 200}, 	tip = "普通关卡太简单了？来困难关卡接受洗礼吧~",name = "宗师关卡"})
mapArray:push({ id = 5002,  open_lev = 15, 	layer_name = "MissionLayer", 		widget_name = "btn_zongshi", 		next_step = 5003, tip_pos = {-250, -100}, tip = "打完一整章的普通关卡就会开放该章的困难关卡", hand_pos = {0,0} , rotation = 45})
mapArray:push({ id = 5003,  open_lev = 15, 	layer_name = "MissionLayer", 		widget_rect = {47,52,175,465},next_step = 5004, tip_pos = {400, 200}, hand_pos = {80,200}, tip = "", specialCall = 1,})
mapArray:push({ id = 5004,  open_lev = 15, 	layer_name = "MissionDetailLayer", 	widget_name = "panel_fight", next_step = 5005,tip_pos = {-10, 200}, 	tip = "只有困难关卡才有装备产出哦~"})
mapArray:push({ id = 5005,					layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 			next_step = 0, tip_pos = {-70, 180}, 	tip = "得到第一把武器！！！", save = true})
--mapArray:push({ id = 5006,	layer_name = "MissionLayer", 		widget_name = "btn_return", 		next_step = 0, tip_pos = {250, -800}, 	tip = ""})

--装备海报
--mapArray:push({ id = 499,	layer_name = "MenuLayer",  guideType = 1, 			widget_name = "taskBtn", 			next_step = 154, picture = "ui_new/task/cj_richang.png"})
mapArray:push({ id = 500, layer_name = "MissionLayer", guideType = 2,    widget_name = "equipBtn",				    next_step = 501, picture = "ui_new/guide/img3.png",goto_name = "ui_new/guide/tiaozhuanxiao.png",save = true})
mapArray:push({ id = 501,	layer_name = "MissionLayer", 				widget_name = "btn_return", 				next_step = 504, tip_pos = {250, -800},	tip = "" ,next_functionId = 65})
--mapArray:push({ id = 501,  open_lev = 15, 	layer_name = "MenuLayer", 			widget_name = "taskBtn",rotation = 225, 			next_step = 502, tip_pos = {-30, 260}, 	tip = "成就又有奖励啦~",name = "穿戴装备"})
--mapArray:push({ id = 502,  open_lev = 15, 	layer_name = "TaskLayer", 			widget_name = "listPanel|getRewardBtn1", 			next_step = 503, tip_pos = {-150,-100}, tip = "哇(°-°)一把奇怪的武器", hand_pos = {0,0}})
--mapArray:push({ id = 503,  open_lev = 0, 	layer_name = "TaskLayer", 			widget_name = "closeBtn", 			next_step = 504, tip_pos = {250, -800}, tip = "关闭，去穿装"})

--穿戴装备
mapArray:push({ id = 504,  open_lev = 15, 	layer_name = "MenuLayer", 			widget_name = "armature1", widget_rect = {234,108,160,220},next_step = 507, tip_pos = {450, 70},  tip = "有了武器，战力大涨~敢快去穿装吧~", hand_pos = {80, 90}})
--mapArray:push({ id = 505,  open_lev = 0, 	layer_name = "RoleInfoLayer", 		widget_name = "",					next_step = 506, tip_pos = {650, 400},	tip = "", hand_pos = {240, 240}})
--mapArray:push({ id = 506,  open_lev = 0, 	layer_name = "RoleInfoLayer", 		widget_name = "img_zhiye", 			next_step = 507, tip_pos = {300, -150},	tip = "不同职业的侠客会有不同类型的技能以及属性成长", hand_pos = {80, -60} ,  hand_eff = "guide_hand"})
mapArray:push({ id = 507,  open_lev = 0, 	layer_name = "RoleInfoLayer", 		widget_name = "panel_equip_1|img_bg",next_step = 508, tip_pos = {400, 150}, right = true,tip = "“+”代表有可穿戴的装备", hand_pos = {0,0}})
mapArray:push({ id = 508,  open_lev = 0, 	layer_name = "RoleInfoLayer", 		widget_name = "btn_zhuangbei", 		next_step = 509, tip_pos = {150, 180}, 	tip = "点击“穿装”，装备选中的武器",save = true})
mapArray:push({ id = 509,  open_lev = 0, 	layer_name = "RoleInfoLayer", 		widget_name = "btn_close", 			next_step = 510, tip_pos = {150, -200}, tip = "", next_functionId = 67})

--装备强化
mapArray:push({ id = 510,  open_lev = 15, guideType = 1, 	layer_name = "MenuLayer", 			widget_name = "equipBtn", 			next_step = 5102, picture = "ui_new/home/main_zhuangbei_btn.png"})
mapArray:push({ id = 5102, open_lev = 15, 	layer_name = "MenuLayer", 			widget_name = "equipBtn", 			next_step = 511, tip_pos = {210, 220},	tip = "装备还可以进行强化，强化后的装备属性大大提升。",rotation = 225 })
mapArray:push({ id = 511, open_lev = 0, 	layer_name = "SmithyMainLayer", 	widget_name = "btn_other",			next_step = 512, tip_pos = {270,-100},	tip = "点标签可以浏览所有装备哟~", right = true,save = true})
mapArray:push({ id = 512, open_lev = 0, 	layer_name = "SmithyMainLayer", 	widget_name = "panel_list", 		next_step = 516, tip_pos = {70, 170},	tip = "选择需要强化的武器。", right = true,hand_pos = {70,300}})
mapArray:push({ id = 513, open_lev = 0, 	layer_name = "EquipDetailsDialog", 	widget_name = "btn_qianghua", 		next_step = 516, tip_pos = {0, 180},	tip = "请戳这里前去强化。", hand_pos = {0, 0}, right = true,sound = "26.mp3",soundTime = 5})
--mapArray:push({ id = 514, open_lev = 0, 	layer_name = "SmithyBaseLayer",		widget_name = "", 					next_step = 515, tip_pos = {550, 200},	tip = "这里是当前装备属性",  hand_pos = {350, 100}, hand_eff = "guide_hand", right = true})
--mapArray:push({ id = 515, open_lev = 0, 	layer_name = "SmithyBaseLayer",		widget_name = "", 					next_step = 516, tip_pos = {500, 280},	tip = "这里是强化的等级和提升的属性",   hand_pos = {750, 300}, hand_eff = "guide_hand"})
mapArray:push({ id = 516, open_lev = 0, 	layer_name = "SmithyBaseLayer", 	widget_name = "", 					next_step = 0,   tip_pos = {430, 200},	tip = "装备当前可强化的等级同团队等级相同。", hand_pos = {880, 140}})

--装备精炼
mapArray:push({ id = 1401,	layer_name = "MenuLayer", 			widget_name = "equipBtn",rotation = 225, 			next_step = 1402, tip_pos = {230, 190}, tip = "随着关卡难度的增加，上仙是否觉得会有些力不从心呢，装备精炼功能开启了哟！",name = "装备精炼"})
mapArray:push({ id = 1402,	layer_name = "SmithyMainLayer", 	widget_name = "btn_other",			next_step = 1403, tip_pos = {270,-100},	tip = "", hand_pos = {0,50}})
mapArray:push({ id = 1403,	layer_name = "SmithyMainLayer", 	widget_name = "panel_list", 		next_step = 1405, tip_pos = {0, 170},	tip = "", hand_pos = {75,290}})
--mapArray:push({ id = 1404,	layer_name = "EquipDetailsDialog", 	widget_name = "btn_qianghua", 		next_step = 1405, tip_pos = {0, 200},	tip = "", hand_pos = {0, 0}, right = true})
mapArray:push({ id = 1405,	layer_name = "SmithyBaseLayer", 	widget_name = "tab_4", 				next_step = 1406, tip_pos = {0, -200},	tip = "精炼可以大幅提高装备的附加属性（主属性除外的属性）。", save = true, hand_pos = {0,50}})
mapArray:push({ id = 1406,	layer_name = "SmithyBaseLayer",		widget_name = "", 					next_step = 1407, tip_pos = {600, 200},	tip = "这里显示当前装备总体的附加属性，附加属性对该神灵全部装备总数值生效", hand_pos = {380, 240},rotation = 90})
mapArray:push({ id = 1407,	layer_name = "SmithyBaseLayer",		widget_name = "", 					next_step = 1408, tip_pos = {500, 250},	tip = "这里可以预览精炼后所提升的附加属性。", hand_pos = {630, 410}})
mapArray:push({ id = 1408,	layer_name = "SmithyBaseLayer", 	widget_name = "", 					next_step = 1409, tip_pos = {876, 300},	tip = "精炼时，装备的多条属性会随机增减，使用灵玉上锁功能可以防止数值减少。", hand_pos = {876,142}})
mapArray:push({ id = 1409 , layer_name = "SmithyBaseLayer", 	widget_name ="", 					next_step =0 , 	  tip_pos ={555,300}, tip = "精炼满属性后，需要突破石来突破上限，上限受当前团队等级限制。", hand_pos = {555,142}})


--装备升星
mapArray:push({ id = 2001,	layer_name = "MenuLayer", 			widget_name = "equipBtn",rotation = 225, 			next_step = 2002, tip_pos = {200, 190}, tip = "装备升星开启！请戳这里。", name = "装备升星"})
mapArray:push({ id = 2002,	layer_name = "SmithyMainLayer", 	widget_name = "btn_other",			next_step = 2003, tip_pos = {270,-100},	tip = "",hand_pos = {0,50}})
mapArray:push({ id = 2003,	layer_name = "SmithyMainLayer", 	widget_name = "panel_list", 				next_step = 2005, tip_pos = {0,170},	tip = "", hand_pos = {75,290}})
--mapArray:push({ id = 2004,	layer_name = "EquipDetailsDialog", 	widget_name = "btn_qianghua", 		next_step = 2005, tip_pos = {0, 200},	tip = "", hand_pos = {0, 0}, right = true})
mapArray:push({ id = 2005,	layer_name = "SmithyBaseLayer", 	widget_name = "tab_2", 				next_step = 2006, tip_pos = {0, -300},	hand_pos = {0,50},tip = "装备升星可以提升装备的基础值和成长值，所强化出的装备战力也会成倍增长！", save = true})
mapArray:push({ id = 2006,	layer_name = "SmithyBaseLayer", 	widget_name = "", 		next_step = 2007,	 tip_pos = {200, 220},	tip = "在这里可以选择升星的消耗材料，精铁和低级装备是主要材料", hand_pos = {590, 240}})
mapArray:push({ id = 2007,	layer_name = "SmithyBaseLayer", 	widget_name = "", 		next_step = 0,	 tip_pos = {600, 200},	tip = "选择好材料后，点击这里给目标装备升星吧~", hand_pos = {880, 110}})

--宝石镶嵌
mapArray:push({ id = 2211,	layer_name = "MenuLayer", 			widget_name = "equipBtn",rotation = 225, 			next_step = 2212, tip_pos = {200, 190}, tip = "之前搜集到的宝石总算有用武之地啦！快去镶嵌宝石吧~",right = true, name = "宝石镶嵌"})
mapArray:push({ id = 2212,	layer_name = "SmithyMainLayer", 	widget_name = "btn_other",			next_step = 2213, tip_pos = {270,-100},	tip = "", hand_pos = {0,50}})
mapArray:push({ id = 2213,	layer_name = "SmithyMainLayer", 	widget_name = "panel_list", 		next_step = 2215, tip_pos = {0, 170},	tip = "", hand_pos = {75,290}})
--mapArray:push({ id = 2214,	layer_name = "EquipDetailsDialog", 	widget_name = "btn_qianghua", 	next_step = 2215, tip_pos = {0, 200},	tip = "", hand_pos = {0, 0}, right = true})
mapArray:push({ id = 2215,	layer_name = "SmithyBaseLayer", 	widget_name = "tab_6", 				next_step = 2216, tip_pos = {0, -150},hand_pos = {0, 50},	tip = "宝石镶嵌到装备上可以增加属性，点进镶嵌界面~",save = true})
mapArray:push({ id = 2216,	layer_name = "SmithyBaseLayer",		widget_name = "", 					next_step = 2217, tip_pos = {650, 200},	tip = "这里显示的是当前宝石的属性",right = true, hand_pos = {322, 165}})
mapArray:push({ id = 2217,	layer_name = "SmithyBaseLayer", 	widget_name = "", 		next_step = 2218, tip_pos = {340, 280},	tip = "在这里可以选择要镶嵌的宝石，不同装备部位需要的宝石不一样哦", hand_pos = {580, 395}})
mapArray:push({ id = 2218,	layer_name = "SmithyBaseLayer", 	widget_name = "", 		next_step = 2205, tip_pos = {750, 300},	tip = "点击“镶嵌”后，装备就拥有了宝石的额外属性，可以打造你自己的专属神器！",right = true, rotation = 315, hand_pos = {830, 75}})
mapArray:push({ id = 2205,	layer_name = "SmithyBaseLayer", 	widget_name = "tab_7", 	next_step = 2206, tip_pos = {-80, -100},hand_pos = {0, 50},tip = "合成功能可以将低级宝石合成高级宝石"})
mapArray:push({ id = 2206,	layer_name = "SmithyBaseLayer", 	widget_name = "", 		next_step = 2207, tip_pos = {340, 280},	tip = "在这里选择要合成的低级宝石，注意要四个宝石才能合成一个高级宝石~", hand_pos = {580, 395}})
mapArray:push({ id = 2207,	layer_name = "SmithyBaseLayer", 	widget_name = "", 		next_step = 0,	  tip_pos = {430, 160},	tip = "点击合成按钮便可以合成高级宝石了", hand_pos = {720,110}})


--无极幻境 开放等级20 --widget_name = "" ,widget_rect = {280,5,140,140}, 
--mapArray:push({ id = 800, layer_name = "MenuLayer", guideType = 2,    widget_name = "pvpBtn",    next_step = 801, picture = "ui_new/guide/img4.png",goto_name = "ui_new/guide/tiaozhuanxiao.png"})
mapArray:push({ id = 801, open_lev = 0, 	layer_name = "MenuLayer", 			widget_name = "pvpBtn", 			next_step = 802, tip_pos = {40, 200}, rotation = 315,tip = "无极幻境开放啦，去其中一探究竟吧!",name = "无极幻境"})
mapArray:push({ id = 802, open_lev = 0, 	layer_name = "ActivityLayer", 		widget_name = "layer_list", offset = {0,10,0,-45},			next_step = 803, tip_pos = {100, 290},	tip = "无极幻境中存在着大量的真气，可以帮助角色提升。",  hand_pos = {210, 70},rotation = 315})
mapArray:push({ id = 803, open_lev = 0, 	layer_name = "ActivityLayer", 		widget_name = "btn_go",				next_step = 804, tip_pos = {-270, 20},	tip = "一起来冲破幻境吧。"})
mapArray:push({ id = 804, open_lev = 0, 	layer_name = "ClimbMountainListLayer",widget_name = "", widget_rect = {650,20,183,183}, 	next_step = 805, tip_pos = {-250, 150},tip = "每一层都可以查看敌方基本信息，根据敌人阵容，提前布阵，克敌制胜！", hand_pos = {92, 92}, trigger = true,})
mapArray:push({ id = 805, open_lev = 0, 	layer_name = "ClimbMountainListLayer",widget_name = "", widget_rect = {330,90,272,86},		next_step = 806, tip_pos = {50, 220}, tip = "无极幻境中，还存在着大量的奖励等待你去发掘。", hand_pos = {136, 43}})
mapArray:push({ id = 806, open_lev = 0, 	layer_name = "ClimbMountainListLayer",widget_name = "btn_attack", 		next_step = 0, tip_pos = {-300,200},	tip = "金炉童子打开宝葫芦，叫到了你的名字，你敢答应吗？"	,rotation = 315, save = true})
-- mapArray:push({ id = 807, open_lev = 0, 	layer_name = "FightResultLayer", 	widget_name = "leaveBtn", 			next_step = 0, tip_pos = {-50, 180}, 	tip = "", right = true, save = true})

--无极幻境未打完或打输退出 	
--mapArray:push({ id = 811, layer_name = "ClimbMountainListLayer",  widget_name ="leaveBtn", next_step =812 , tip_pos ={0,0}, tip = "", hand_pos = {0,0}})
--mapArray:push({ id = 812, layer_name = "ActivityLayer", 			widget_name ="leaveBtn", next_step = 0, tip_pos ={0,0}, tip = "", hand_pos = {0,0}, save = true})

--角色炼体 开放等级20
mapArray:push({ id = 901, open_lev = 0, 	layer_name = "MenuLayer", 		    widget_name = "armature1", widget_rect = {230,110,140,220}, next_step = 902, tip_pos = {400, 100},	tip = "角色炼体开放！使用收集而来的真气增强属性吧。", hand_pos = {70, 110}})
mapArray:push({ id = 902, open_lev = 0, 	layer_name = "RoleInfoLayer", 		widget_name = "btn_jm", 			next_step = 905, tip_pos = {-2500, -100}, 	tip = "不同类型的神灵对应的炼体属性不一样，经脉可以增强暴击命中等属性。",save = true})
--mapArray:push({ id = 903, open_lev = 0, 	layer_name = "MeridianLayer", 		widget_name = "", 					next_step = 904, tip_pos = {400, 120},	tip = "这里显示经脉总的属性加成",  hand_pos = {280, 70}, hand_eff = "guide_hand",trigger = true, right = true})
--mapArray:push({ id = 904, open_lev = 0, 	layer_name = "MeridianLayer", 		widget_name = "", 					next_step = 905, tip_pos = {450, 400},	tip = "这里选择需要升级的经脉",  hand_pos = {550, 380}, hand_eff = "guide_hand"})
mapArray:push({ id = 905, open_lev = 0, 	layer_name = "MeridianLayer", 		widget_name = "img_res_bg_3",offset = {0,0,-20,0},next_step = 906, tip_pos = {0, -150},	tip = "这里是你当前的真气值",  hand_pos = {0, 0},})
mapArray:push({ id = 906, open_lev = 0, 	layer_name = "MeridianLayer", 		widget_name = "Image_TrainLayer_2", next_step = 907, tip_pos = {-450, -150},	tip = "这里则是该神灵的炼体属性",  hand_pos = {-90, -165}})
mapArray:push({ id = 907, open_lev = 0, 	layer_name = "MeridianLayer", 		widget_name = "btn_level_up", 		next_step = 0,   tip_pos = {-300, 100},	tip = "还等什么？赶快点击修炼，来增加神灵属性~"})

--群仙涿鹿
mapArray:push({ id = 1601,	layer_name = "MenuLayer", 			widget_name = "pvpBtn", 			next_step = 1602,tip_pos = {-260, 130},   tip = "炎黄大战日趋白热，赶快加入战斗吧！", name = "涿鹿之争"})
mapArray:push({ id = 1602,	layer_name = "ActivityLayer", 		widget_name = "layer_list", offset = {0,10,0,-45},		next_step = 1603,tip_pos = {360, 280},	tip = "群仙涿鹿，连战30关，赢取海量奖励。",  hand_pos = {362, 75}, save = true})
mapArray:push({ id = 1603,	layer_name = "ActivityLayer", 		widget_name = "btn_go",				next_step = 0,   tip_pos = {-270, 20},	tip = "合理设置出场阵容，一战到底！",soundTime = 5})

--仙盟
mapArray:push({ id = 3600,	layer_name = "MenuLayer", guideType = 1, widget_name = "btn_faction",	next_step = 3601, picture = "ui_new/home/main_bangpai_btn.png"})
mapArray:push({ id = 3601,	layer_name = "MenuLayer", 			widget_name = "btn_faction", 		next_step = 0, tip_pos = {250, 270}, 	tip = "仙盟解锁，赶快加入仙盟，寻找志同道合之人吧！", rotation = 225, right = true, name = "帮派", save = true})

--三垢奇阵
mapArray:push({ id = 1001,	layer_name = "MenuLayer", 			widget_name = "pvpBtn", 			next_step = 1002,tip_pos = {40, 200},   tip = "三垢奇阵，破解贪嗔痴！", name = "三垢奇阵"})
mapArray:push({ id = 1002,	layer_name = "ActivityLayer", 		widget_name = "btnTableView", offset = {0,10,0,-45},		next_step = 1003,tip_pos = {500, 280},	tip = "每日开放不同的挑战种类，有主角精魄和天阶神灵精魄掉落。", save = true,  hand_pos = {505, 75}})
mapArray:push({ id = 1003,	layer_name = "ActivityLayer", 		widget_name = "btn_go",				next_step = 1004,tip_pos = {-270, 20},	tip = "一旦战胜即可获得大量的神灵碎片！"})
mapArray:push({ id = 1004,	layer_name = "ClimbCarbonListLayer",widget_name = "", 		next_step = 0,tip_pos = {280, 320},	tip = "每种奇阵都有独特的应对方式，注意选择合适的神灵参战哦！",hand_pos = {2000, 3000}})

--宝石合成
--mapArray:push({ id = 1,	layer_name = "MenuLayer", 			widget_name = "equipBtn",rotation = 180, 			next_step = 0, tip_pos = {200, 190}, tip = "搜集到好多亮晶晶的宝石吖！快去合成宝石吧~", name = "宝石合成"})
--mapArray:push({ id = 1,	layer_name = "SmithyMainLayer", 	widget_name = "btn_other",			next_step = 0, tip_pos = {270,-100},	tip = ""})
--mapArray:push({ id = 1,	layer_name = "SmithyMainLayer", 	widget_name = "panel_list", 				next_step = 0, tip_pos = {0, 170},	tip = "", hand_pos = {80,400}})
--mapArray:push({ id = 1,	layer_name = "EquipDetailsDialog", 	widget_name = "btn_qianghua", 		next_step = 0, tip_pos = {0, 200},	tip = "", hand_pos = {0, 0}, right = true})
--mapArray:push({ id = 1,	layer_name = "SmithyBaseLayer", 	widget_name = "tab_6", 				next_step = 0, tip_pos = {-80, -300},	tip = "合成功能可以将低级宝石合成高级宝石",save = true})
--mapArray:push({ id = 1,	layer_name = "SmithyBaseLayer", 	widget_name = "", 		next_step = 0,	 tip_pos = {300, 220},	tip = "在这里选择要合成的低级宝石，注意要四个宝石才能合成一个高级宝石~", hand_eff = "guide_hand", hand_pos = {510, 380}})
--mapArray:push({ id = 1,	layer_name = "SmithyBaseLayer", 	widget_name = "", 		next_step = 0,	 tip_pos = {430, 130},	tip = "点击合成按钮便可以合成高级宝石了", hand_eff = "guide_hand", hand_pos = {740,40}})

--首充画报
--mapArray:push({ id = 2500,	layer_name = "MissionLayer", 		widget_name = "btn_return", 		next_step = 0})
--mapArray:push({ id = 2501, layer_name = "MissionLayer", guideType = 2,     next_step = 0, picture = "ui_new/guide/img1.png",goto_name = "ui_new/guide/tiaozhuanxiao.png",taskType = 1001,save = true, isgray = true, close_btn = true})--id16

--mapArray:push({ id = 2502, layer_name = "MissionLayer", guideType = 2,     next_step = 0, picture = "ui_new/guide/img2.png",goto_name = "ui_new/guide/tiaozhuanxiao.png",taskType = 1002,save = true, isgray = true, close_btn = true})--id17

--排行
mapArray:push({ id = 2601, layer_name = "MenuLayer", guideType = 1,    widget_name = "btn_paihang",    next_step = 0, picture = "ui_new/home/main_paihang_btn.png",save = true })

--侠客归隐
--mapArray:push({ id = 2701 , layer_name = "MenuLayer", 		widget_name ="btn_change", next_step = 2706, tip_pos ={0,0}, tip = "",rotation = 225, hand_pos = {-20,50}})
mapArray:push({ id = 2701 , layer_name = "MenuLayer", 		widget_name ="zhaomuBtn", 	next_step = 2702, tip_pos = {180, 270}, tip = "聚仙中有新功能开启啦！", hand_pos = {0,0} ,rotation = 225, right = true})
mapArray:push({ id = 2702 ,	layer_name = "RecruitLayer", 	widget_name = "btn_guiyin", next_step = 2703, tip_pos = {250,-80}, tip = "神灵归隐开启了，赶快戳这里吧。", rotation = 45, save = true})
mapArray:push({ id = 2703 , layer_name = "HermitLayer",	 	widget_name ="btn_fire", 	next_step = 2704, tip_pos = {180,-150}, tip = "这里可以将多余的神灵进行归隐，归隐神灵可以获得魂玉。", hand_pos = {0,0}, right = true})
mapArray:push({ id = 2704 , layer_name = "HermitLayer",	 	widget_name ="btn_rebirth", next_step = 2705, tip_pos = {300,-100}, tip = "这里可以将培养过的神灵进行重生，并返还培养资源。", hand_pos = {0,0}, right = true})
mapArray:push({ id = 2705 , layer_name = "HermitLayer",	 	widget_name ="btn_shop", 	next_step = 0, 	  tip_pos = {0,-200}, 	tip = "神灵商店可以用魂玉兑换神灵精魄哟！", hand_pos = {0,0}, rotation = 320})

--祈愿系统
--mapArray:push({ id = 2701 , layer_name = "MenuLayer", 		widget_name ="btn_change", next_step = 2706, tip_pos ={0,0}, tip = "",rotation = 225, hand_pos = {-20,50}})
mapArray:push({ id = 2711 , layer_name = "MenuLayer", 		widget_name ="zhaomuBtn", 	next_step = 2712, tip_pos = {180, 270}, tip = "聚仙中又有新功能开启啦！", hand_pos = {-10,10} ,rotation = 225, right = true})
mapArray:push({ id = 2712 ,	layer_name = "RecruitLayer", 	widget_name = "btn_qiyuan", next_step = 0, tip_pos = {250,-80}, tip = "选择你想要的神灵卡片进行祈愿吧，祈愿15天还能得天阶神灵整卡哟！", rotation = 45, save = true})

--更换主角
--mapArray:push({ id = 2701 , layer_name = "MenuLayer", 		widget_name ="btn_change", next_step = 2706, tip_pos ={0,0}, tip = "",rotation = 225, hand_pos = {-20,50}})
mapArray:push({ id = 2721 , layer_name = "MenuLayer", 		widget_name ="btn_touxiang", next_step = 2722, tip_pos = {180, 270}, tip = "打开主角信息面板~", hand_pos = {-10,10} ,rotation = 225, right = true})
mapArray:push({ id = 2722,	layer_name = "MainPlayerLayer", 	widget_name = "txt_equip_max", 		offset = {-233,128,0,20},	next_step = 2723, tip_pos = {0,0}, 	tip = "这里可以更换主角",right = true,hand_eff = "guide_hand", hand_pos = {-0, 100}})
mapArray:push({ id = 2723,	layer_name = "MainPlayerLayer", 	widget_name = "txt_equip_max", 		offset = {-233,78,0,20},	next_step = 0, tip_pos = {0,0}, 	tip = "这里可以更换头像",right = true,hand_eff = "guide_hand", hand_pos = {-0, 50}})


--降妖伏魔
mapArray:push({ id = 3001 , layer_name = "MenuLayer", 				 widget_name = "pvpBtn",   	 next_step = 3002, tip_pos ={40,200}, tip = "戾气对三界造成非常严重的破坏，有些神灵甚至已成魔，请火速赶往！", right = true, name = "降妖伏魔" })
mapArray:push({ id = 3002 , layer_name = "ActivityLayer", 			 widget_name ="btnTableView", offset = {0,10,0,-45}, next_step = 3003, tip_pos ={530,260}, tip = "成魔的神灵，破坏力和防御力惊人，千万不能掉以轻心。", hand_pos = {652, 75}, save = true})
mapArray:push({ id = 3003 , layer_name = "ActivityLayer", 			 widget_name = "btn_go",		 next_step = 0,   tip_pos = {-290, -20},	tip ="合理搭配神灵和阵法，将提高伏魔排行榜的名次与奖励，还不赶快行动？"})

--助阵
mapArray:push({ id = 3700, layer_name = "MenuLayer", widget_name ="roleBtn", next_step = 3701, tip_pos ={100,320}, tip = "助阵开启啦~不上阵也能获得缘分哟。", hand_pos = {0,0},rotation = 225, right = true})
mapArray:push({ id = 3701, layer_name = "ArmyLayer", widget_name ="assistFightView|bg", next_step = 3702, tip_pos ={400,50}, tip = "点击助阵栏，即便不上阵也能通过助阵激活缘分。", hand_pos = {110,55}, save = true})
mapArray:push({ id = 3702, layer_name = "AssistFightLayer", widget_name ="bg_zhenrong|z1", next_step = 0, tip_pos ={-230,0}, tip = "各助阵位开放条件不同，点开后与上阵神灵有缘的神灵会出现“缘”字标识。", hand_pos = {0,0}})

--洗练
mapArray:push({ id = 3801,	layer_name = "MenuLayer", 			widget_name = "equipBtn", 			next_step = 3802, tip_pos = {230, 190}, tip = "装备随机生成的属性不合心意？快来使用洗练打造称心如意的神兵利器吧~", name = "装备洗炼",rotation = 225})
mapArray:push({ id = 3802,	layer_name = "SmithyMainLayer", 	widget_name = "btn_other",			next_step = 3803, tip_pos = {270,-100},	tip = ""})
mapArray:push({ id = 3803,	layer_name = "SmithyMainLayer", 	widget_name = "panel_list", 		next_step = 3804, tip_pos = {0, 170},	tip = "", hand_pos = {80,400}})
mapArray:push({ id = 3804,	layer_name = "SmithyBaseLayer", 	widget_name = "tab_3", 				next_step = 3805, tip_pos = {0, -200},	tip = "戳这里进入洗练界面~", save = true})
mapArray:push({ id = 3805,	layer_name = "SmithyBaseLayer",		widget_name = "", 					next_step = 3806, tip_pos = {550, 200},	tip = "这里显示当前装备原附加属性，原附加属性若已精炼过会保存该属性的精炼加成值", hand_pos = {250, 120}, hand_eff = "guide_hand", right = true,rotation = 48})
mapArray:push({ id = 3806 , layer_name = "SmithyBaseLayer", 	widget_name ="", 					next_step = 3807 , 	  tip_pos ={440,200}, tip = "这里可以锁定你需要的属性，这样就不怕洗掉自己需要的属性了~", hand_pos = {770,380},rotation = 90, hand_eff = "guide_hand"})
mapArray:push({ id = 3807,	layer_name = "SmithyBaseLayer",		widget_name = "", 					next_step = 0, tip_pos = {580, 200},	tip = "洗练后新获得的属性精炼值为初始值，大侠快来试试装备洗练吧~", hand_pos = {770, 70}, hand_eff = "guide_hand",rotation = 90})

--契合
mapArray:push({ id = 3900, layer_name = "MenuLayer", widget_name ="roleBtn", next_step = 3901, tip_pos ={220,160}, tip = "神灵助战不光只有缘分啦，通过契合能使神灵自身属性也产生全队加成！", hand_pos = {0,0},rotation = 225, right = true})
mapArray:push({ id = 3901, layer_name = "ArmyLayer", widget_name ="assistFightView|bg", next_step = 3902, tip_pos ={400,50}, tip = "点击助战栏，进入开启契合的崭新的助战界面~", hand_pos = {0,0}, save = true})
mapArray:push({ id = 3902, layer_name = "AssistFightLayer", widget_name ="btn_qihe", next_step = 3903, tip_pos ={-230,0}, tip = "没有缘分的侠客通过契合也可以给全队增加属性，助战搭配更多样~", hand_pos = {0,0}})
mapArray:push({ id = 3903, layer_name = "AssistAgreeLayer", widget_name ="", next_step = 0, tip_pos ={460,230}, tip = "每一个助战位契合成功后对应一种属性加成，提升契合消耗勾玉", hand_pos = {870,220}, hand_eff = "guide_hand"})

--重铸
mapArray:push({ id = 4001,	layer_name = "MenuLayer", 			widget_name = "equipBtn", 			next_step = 4002, tip_pos = {230, 190}, tip = "感觉装备加的战力影响不到战局？来试试装备重铸吧~", name = "装备重铸",rotation = 225})
mapArray:push({ id = 4002,	layer_name = "SmithyMainLayer", 	widget_name = "btn_other",			next_step = 4003, tip_pos = {270,-100},	tip = ""})
mapArray:push({ id = 4003,	layer_name = "SmithyMainLayer", 	widget_name = "panel_list", 		next_step = 4004, tip_pos = {0, 170},	tip = "", hand_pos = {80,400}})
mapArray:push({ id = 4004,	layer_name = "SmithyBaseLayer", 	widget_name = "tab_5", 				next_step = 4005, tip_pos = {0, -200},	tip = "重铸界面入口在此~", save = true})--
mapArray:push({ id = 4005,	layer_name = "SmithyBaseLayer",		widget_name = "", 					next_step = 4006, tip_pos = {550, 200},	tip = "这里显示该装备当前属性，只有神品和极品装备才配得上逆天的属性百分比增长哦~", hand_pos = {250, 120}, hand_eff = "guide_hand", right = true,rotation = 48})
mapArray:push({ id = 4006 , layer_name = "SmithyBaseLayer", 	widget_name ="", 					next_step = 4007 , 	  tip_pos ={390,200}, tip = "通过吞噬相同的装备，当前重铸位重铸后若有品质提升，便开启下一重铸位", hand_pos = {520,300},rotation = 90, hand_eff = "guide_hand"})
mapArray:push({ id = 4007 , layer_name = "SmithyBaseLayer", 	widget_name ="", 					next_step = 4008 , 	  tip_pos ={440,200}, tip = "全部位置反复重铸到神铸品质，本装备属性会有爆炸性的增长，一出手便控制战局！", hand_pos = {720,150}, hand_eff = "guide_hand"})
mapArray:push({ id = 4008,	layer_name = "SmithyBaseLayer",		widget_name = "", 					next_step = 0, tip_pos = {440,200},	tip = "重铸后的属性百分百得到提升，大侠这么稳赚不赔的买卖可千万不要错过吖~", hand_pos = {820, 55}, hand_eff = "guide_hand",rotation = 90})

--挖矿
mapArray:push({ id = 6001 , layer_name = "MenuLayer", 				 widget_name = "pvpBtn",   	 next_step = 6002, tip_pos ={40,200}, tip = "神农帮发现了一处灵矿，面对巨额财富的诱惑，各方人士前来抢夺！为了铜钱，抢占宝地啊！", right = true, name = "挖矿" })
mapArray:push({ id = 6002 , layer_name = "ActivityLayer", 			 widget_name ="btnTableView", offset = {0,10,0,-45}, next_step = 6003, tip_pos ={550,220}, tip = "开采时间为8小时，需设置防守队伍抵御抢夺；刷新矿源可获得更高奖励！", hand_pos = {800, 85}, save = true})
mapArray:push({ id = 6003 , layer_name = "ActivityLayer", 			 widget_name = "btn_go",		 next_step = 6004,   tip_pos = {-290, 10},	tip ="睡一觉的时间便可获得数不尽的铜钱~快进入自己宝石洞穴看看吧！~"})
mapArray:push({ id = 6004 , layer_name = "MiningLayer", 			 widget_name = "",		 next_step = 0,   tip_pos = {590, 340},	tip ="被抢了不要气馁，每人每日有2次抢夺他人的机会；一处矿源也只会被成功劫走一次，更有超强好友助你护矿！", hand_pos = {370, 240}, hand_eff = "guide_hand"})

--游历玩法

--mapArray:push({ id = 7001,  layer_name = "MenuLayer", guideType = 1,    widget_name = "btn_youli",    next_step = 7002, picture = "ui_new/home/main_youli_btn.png"})
mapArray:push({ id = 7002,	layer_name = "MenuLayer", widget_name = "btn_youli", next_step = 7003, tip_pos = {-240, 60}, hand_pos = {0,10}, tip = "游历玩法会产出天书哦，赶快来体验吧",save = true,rotation = 225})
mapArray:push({ id = 7003,	layer_name = "AdventureHomeLayer", widget_name = "btn_buzheng", next_step = 7004, tip_pos = {0, 200}, tip = "进入布阵界面，设置第二阵容",hand_pos = {0, 0}})
mapArray:push({ id = 7004,	layer_name = "ZhengbaArmyLayer", widget_name = "btn_team2", next_step = 7005, tip_pos = {-100, -150}, tip = "点击阵容二，拖动一名侠客上阵",save = true,hand_pos = {0, 0}})
mapArray:push({ id = 7005,	layer_name = "AdventureHomeLayer", widget_name = "", next_step = 7006,hand_pos = {-100, -100}, tip_pos = {450, 350}, tip = "大侠是继小虾米之后第二个来到金庸世界的人，你的任务是集齐十四天书。无量剑的东西宗比剑就要开始了，去瞧瞧热闹吧。"})
mapArray:push({ id = 7006,	layer_name = "AdventureHomeLayer", widget_name = "imgMainGuide", next_step = 7007, tip_pos = {150, 200}, tip = "点击红色的寻路引导，找到主线任务的目标地点。绿色的寻路引导会带你找到随机事件的目标地点",hand_pos = {0, 0}})
mapArray:push({ id = 7007,	layer_name = "AdventureMissionDetailLayer", widget_name = "btn_attack", next_step = 7008, tip_pos = {0, 0}, tip = "",save = true,hand_pos = {0, 0}})
mapArray:push({ id = 7008,	layer_name = "AdventureHomeLayer", widget_name = "btn_zhuxian", next_step = 7009, tip_pos = {150, 200}, tip = "点击主线任务图标，进入下一回剧情",hand_pos = {0, 0}})
mapArray:push({ id = 7009,	layer_name = "AdventureMissionDetailLayer", widget_name = "btn_attack", next_step = 7010, tip_pos = {0, 0}, tip = "",save = true,hand_pos = {0, 0}})
mapArray:push({ id = 7010,	layer_name = "AdventureHomeLayer", widget_name = "btn_zhuxian", offset = {106,-92,0,0},next_step = 7011, tip_pos = {150, 140}, tip = "注意啦，这一回是BOSS关卡，会有两场战斗哦",hand_pos = {106, -92}})
mapArray:push({ id = 7011,	layer_name = "AdventureMissionDetailLayer", widget_name = "btn_team2", next_step = 7012, tip_pos = {-150, -200}, tip = "BOSS关卡有两场战斗，点击这里可以查看第二场战斗的敌人信息",hand_pos = {0, 0}})
mapArray:push({ id = 7012,	layer_name = "AdventureMissionDetailLayer", widget_name = "txt_xxxxx", offset = {0,-283,150,228},	next_step = 7013, tip_pos = {360,-240}, 	tip = "两场战斗全部胜利才可以获得全部奖励哦",right = true,hand_eff = "guide_hand", hand_pos = {320, -170}})
mapArray:push({ id = 7013,	layer_name = "AdventureMissionDetailLayer", widget_name = "btn_attack", next_step = 7014, tip_pos = {0, 0}, tip = "",save = true,hand_pos = {0, 0}})
mapArray:push({ id = 7014,	layer_name = "AdventureHomeLayer", widget_name = "btn_chapter", next_step = 7015, tip_pos = {0, 280}, tip = "点击这里可以扫荡之前3星通关的游历关卡",save = true,hand_pos = {0, 0}})
mapArray:push({ id = 7015,	layer_name = "AdventureHomeLayer", widget_name = "btn_shop", next_step = 7016, tip_pos = {120, 220}, tip = "在游历关卡中获得的残页可以在这里兑换相应的天书哦",hand_pos = {0, 0}})
mapArray:push({ id = 7016,	layer_name = "AdventureMallLayer", widget_name = "btn_5", next_step = 7017, tip_pos = {120, 220}, tip = "兑换残本天书，以后有了更高级的残页就能兑换高级天书哦",hand_pos = {0, 0}})
mapArray:push({ id = 7017,	layer_name = "AdventureMallLayer", widget_name = "shopPage|panel_list", next_step = 7018, tip_pos = {450, 350}, tip = "点击兑换天龙残本",hand_pos = {70, 380}})
mapArray:push({ id = 7018,	layer_name = "AdventureShoppingLayer", widget_name = "btn_buy", next_step = 7019, tip_pos = {120, 220}, tip = "",hand_pos = {0, 0}})
mapArray:push({ id = 7019,	layer_name = "AdventureHomeLayer", widget_name = "btn_return", next_step = 7020, tip_pos = {200, -200}, tip = "终于得到天书啦，虽然是残本，让我们把它装备起来",hand_pos = {0, 0}})
mapArray:push({ id = 7020,	layer_name = "MenuLayer", 			widget_name = "armature1", offset ={-40,0,50,40}, next_step = 7021, tip_pos = {-250, 70},  tip = "我们去角色界面装备天书", hand_pos = {0, 90}})
mapArray:push({ id = 7021,	layer_name = "RoleInfoLayer", widget_name = "panel_equip_6|img_bg", next_step = 7022, tip_pos = {100, 200}, tip = "点击天书按钮",hand_pos = {0, 0}})
mapArray:push({ id = 7022,	layer_name = "RoleInfoLayer", widget_name = "btn_zhuangpei", next_step = 0, tip_pos = {100, 200}, tip = "装配天书到身上就大功告成啦",hand_pos = {0, 0}})






--佣兵
mapArray:push({ id = 7001, layer_name = "MenuLayer", guideType = 1,    widget_name = "btn_employ",    next_step = 7002, picture = "ui_new/home/zjm_yb_icon.png",save = true })
mapArray:push({ id = 7002, layer_name = "MenuLayer", 			widget_name ="btn_employ", 			next_step = 0, tip_pos ={180,190}, tip = "派遣神灵供好友及仙盟成员使用，同样你也能使用对方提供的神灵。", hand_pos = {-10,10},rotation = 225, name = "佣兵"})



-----------------------------------------------条件触发引导-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--角色升星
mapArray:push({ id = 1201,	layer_name = "MenuLayer", 		    widget_name = "armature1", offset ={-40,0,60,40}, 			next_step = 1202,tip_pos = {-250, 70},  tip = "终于凑够了三十个精魄啦！赶快提升神灵星数吧，星数越高越强哟。", name = "角色修炼"})
mapArray:push({ id = 1202,	layer_name = "RoleInfoLayer", 		widget_name = "btn_xiulian", 		next_step = 1203,	 tip_pos = {-360,-20},  tip = "终于凑齐足够数量的精魄了，准备突破吧！",save = true})
mapArray:push({ id = 1203 , layer_name = "RoleStarUpPreviewLayer", widget_name ="Btn_tupo", next_step = 0 , tip_pos ={-450,160},offset ={-120,0,0,0}, tip = "突破后不仅提高属性，还会让技能将会有质的飞跃~还不快试试~", hand_pos = {-120,0}, rotation = 90,})

--武学升阶 id = 61
--mapArray:push({ id = 2101,	layer_name = "RoleInfoLayer",	 	widget_name = "btn_jinjie", next_step = 0	, tip_pos = {-100, -140},	tip = "集齐六本秘籍，点击进化！阿不，进阶" ,save = true})
--mapArray:push({ id = 2102,	layer_name = "RoleBreakResultLayer", 	widget_name = "", 	next_step = 0	, tip_pos = {800, 200},	tip = "" ,save = true, hand_pos = {-800, -900}})

--战斗加速(5级进入后第一场战斗)
--mapArray:push({ id = 2801, layer_name = "MissionLayer", widget_name ="cur_mission|btn_base", next_step = 2802, tip_pos ={0,0}, tip = "", specialCall = 1})
--mapArray:push({ id = 2802, layer_name = "MissionDetailLayer", widget_name ="btn_attack", next_step = 2803, tip_pos ={0,0}, tip = "",save = true})
mapArray:push({ id = 2801, layer_name = "FightUiLayer", 		widget_name = "speedBtn", 		next_step = 0, tip_pos = {-150, 180}, rotation = 135,	tip = "加速功能已开启，点击按钮试一下吧。",save = true ,force = false, right = true, hand_pos = {0,0}})

--角色传功
mapArray:push({ id = 1301,	layer_name = "MenuLayer", 			widget_name = "armature1",offset ={-40,0,60,40}, 			next_step = 1302, tip_pos = {-250, 70}, tip = "修炼开放啦！使用修炼功能可以让新的神灵快速提升等级", name = "角色传功"})
mapArray:push({ id = 1302,	layer_name = "RoleInfoLayer", 		widget_name = "btn_transfer", 		next_step = 1303, tip_pos = {-200,-70},tip = "修炼可以让新神灵快速提升等级，神灵等级不可以超过团队等级哦~",save = true})
mapArray:push({ id = 1303,	layer_name = "RoleTransferLayer", 	widget_name = "panel_list", 		next_step = 1304, tip_pos = {220, 150},	tip = "选择你要吞噬的经验丹，按住不放可以大量选用，品质越高经验越多！", hand_pos = {70,290}, right = true})
mapArray:push({ id = 1304,	layer_name = "RoleTransferLayer", 	widget_name = "btn_transfer", 					next_step = 0, 	 tip_pos = {0, 250},	tip = "戳这里进行修炼哟~", hand_pos = {0,0}, rotation = 180})

--勤学苦练
mapArray:push({ id = 2900 , layer_name = "RoleInfoLayer", widget_name ="panel_book_1|img_quality", next_step = 0 , tip_pos ={-300,0}, tip = "使用剩余未炼化的丹药或淬炼材料进行升级，提升炼化属性", hand_pos = {0,0},save = true})
mapArray:push({ id = 2901, layer_name = "RoleBook_Enchant", widget_name ="btn_qxkl", next_step = 0 , tip_pos ={0,0}, tip = "", hand_pos = {0,0}})

--首场战斗
--mapArray:push({ id = 10000,   layer_name = "FightUiLayer", 		widget_name = "roleskill1|roleicon", 		next_step = 0, tip_pos = {150, 180}, 	tip = "点击释放技能", hand_pos = {-10,15},specialCall = 5 ,right = true,force = false , offset ={0,10}})
--mapArray:push({ id = 10001,   mapid = 9, mission_id = 10000, role_anger = 0, npc_anger = 0, role = {0,0,2001,2004,2005,2003,0,0,2002}, npc = {50001,50003,0,50004,50005,0,0,0,50006}, skill = {{3,3,10001},{4,7,10002},{5,13,10003},{1,15,10004},{2,17,10005},{3,19,10006}}})

--七日目标
--mapArray:push({ id = 1101,	layer_name = "MissionLayer", 		widget_name = "btn_return", 		next_step = 1102, tip_pos = {250, -800},	tip = "" ,next_functionId = 19})
--mapArray:push({ id = 1102, layer_name = "MenuLayer", guideType = 1,    widget_name = "sevenday",    next_step = 1103, picture = "ui_new/home/icon_qiri.png", save = true})
--mapArray:push({ id = 1103,	layer_name = "MenuLayer", 			widget_name = "sevenday", 			next_step = 0, tip_pos = {330, 0}, 	tip = "开服七日目标达成！每日登陆有丰厚奖品，达成目标还有更多成长资源赠送，每天都要来哦~", right = true})


--btn_qx

--模板
--mapArray:push({ id = , layer_name = "", widget_name ="", next_step = , tip_pos ={}, tip = "", hand_pos = {}})
--, guideType = 1系统图标需要飞向, hand_eff = "guide_hand手指变成箭头", save = true,right = true, rotation = 1手指旋转度数，默认0度是↖ ,offset ={}

--图层名和按钮名都要与芒果UI内一一对应，否则步骤会中断，不出现，指向错误等
--mapArray:push({ id = 不可重复ID，一般整数开始往后序列增加, layer_name = "当前步骤出现图层，", widget_name ="当前步骤需要玩家点击的按钮，若不需要则什么都不填", next_step = 下一步骤序号, tip_pos ={对白座标X,Y}, tip = "对白内容，若不需要则什么都不填", hand_pos = {手指座标，不需要位移默认0,0；若这里没有按钮指向，座标原点在整个界面左下角}})
--注意一定要有save = true保存步骤！一整个系统引导只需要一次，保存在玩家必须点的步骤上。

return mapArray	