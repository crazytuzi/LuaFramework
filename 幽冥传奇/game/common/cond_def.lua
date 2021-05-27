-- 游戏条件类型
GameCondType = {
	ForceValue = "ForceValue", -- 忽略所有条件的判断，强制使用给定的值作为结果 可用于屏蔽功能 
	RoleLevel = "RoleLevel", -- RoleLevel = xx : 角色等级 > xx 时条件成立
	RoleCircle = "RoleCircle", -- RoleCircle = xx : 角色转生 > xx 时为条件成立 
	OpenServerDay = "OpenServerDay", -- OpenServerDay = xx : 开服天数 > xx 时条件成立
	VipLevel = "VipLevel", -- VipLevel >= xx : 开服天数 > xx 时条件成立
	InnerLevel = "InnerLevel", -- InnerLevel = 1 : 内功等级大于配置InnerConfig.openAptitude等级条件成立
	FuwenCircle = "FuwenCircle", -- FuwenCircle = x : 穿戴中全套符文均大于x转
	FirstChargeIsAllGet = "FirstChargeIsAllGet", --首充可领取档位是否都被领取
	HaveGuild = "HaveGuild", -- 是否有行会
	OpenServerRange = "OpenServerRange", -- OpenServerRange = {1, 3} : 开服第1天到第3天内成立
	RoleLevelRange = "RoleLevelRange", -- RoleLevelRange = {1, 60} : 角色等级在1~60内
	IsOnCrossserver = "IsOnCrossserver", -- IsOnCrossserver = false : 跨服时,屏蔽图标
	IsActBrilliantOpen = "IsActBrilliantOpen", --IsActBrilliantOpen = false :没有精彩活动开启时，屏蔽图标
	CombindDayRange = "CombindDayRange", -- CombindDayRange = {1, 3} : 合服第1天到第3天内成立
	-- IsYuanBaoZPOpen = "IsYuanBaoZPOpen",	 --IsYuanBaoZPOpen = false:元宝转盘没有开启时，屏蔽图标
	InvestmentReward = "InvestmentReward", --InvestmentReward  超值投资可领取档位是否都被领取
	IsActCanbaogeOpen = "IsActCanbaogeOpen", --IsActCanbaogeOpen  藏宝阁是否开启
	IsActBabelTowerOpen = "IsActBabelTowerOpen", --IsActBabelTowerOpen  通天塔是否开启
	IsLimitChargeOpen = "IsLimitChargeOpen", --限时充值
	IsChargeFLOpen = "IsChargeFLOpen",--充值返利
	IsHunHuanOpen = "IsHunHuanOpen",--魂环特惠
	IsChargeGiftOpen = "IsChargeGiftOpen",--充值大礼包
	IsWelfreTurnbelOpen = "IsWelfreTurnbelOpen",--福利转盘
	IsZsTaskAllGet = "IsZsTaskAllGet",-- 钻石任务
	OutOfPrint = "OutOfPrint", -- 绝版限购还有未领取档位 有-true 没有-false
	LoginReward = "LoginReward", -- 登录奖励还有未领取档位 有-true 没有-false
	EquipRecycleAll = "EquipRecycleAll", -- 钻石装备回收次数全部用完
}

-- 游戏条件定义
-- 条件可以填多个，所有类型同时成立时才判断为成立(ForceValue类型除外)
-- Tip 条件说明
GameCond = {
-----------------------------------------------------
	CondId0 = {ForceValue = false},	--屏蔽功能
	CondId1 = {ForceValue = true},
    CondId2 = {IsOnCrossserver = false},  --跨服中屏蔽
	CondId9 = {RoleLevel = 100, Tip = "达到100级开放",IsOnCrossserver = false}, 								--[cq20]【神炉-血符】
	CondId15 = {RoleLevel = 100, Tip = "达到100级开放", IsOnCrossserver = false}, 								--[cq20]【神炉按钮】主界面图标的显示
	CondId10 = {RoleLevel = 150, Tip = "达到150级开放",IsOnCrossserver = false}, 								--[cq20]【神炉-护盾】
	CondId11 = {RoleLevel = 200, Tip = "达到200级开放",IsOnCrossserver = false}, 								--[cq20]【神炉-宝石】
	CondId12 = {RoleLevel = 250, Tip = "达到250级开放",IsOnCrossserver = false}, 								--[cq20]【神炉-魂珠】
	CondId19 = {RoleCircle = 8, OpenServerDay = 15, Tip = "开服第15天，8转开放",IsOnCrossserver = false}, 		--[cq20]【神炉-神鼎】
	
	CondId25 = {RoleLevel = 200, Tip = "达到200级开放", IsOnCrossserver = false}, 								--[cq20]【封神系统】
	CondId22 = {RoleLevel = 100, Tip = "达到100级开放", IsOnCrossserver = false}, 								--[cq20]【热血装备槽位】
	CondId17 = {RoleLevel = 300, Tip = "达到300级开放", IsOnCrossserver = false}, 								--[cq20]【转生系统】
		
    CondId82 = {RoleLevel = 300 , Tip = "达到300级开放", IsOnCrossserver = false}, 								--[cq20]【翅膀-系统】
	CondId57 = {RoleLevel = 300,RoleCircle = 2, Tip = "达到2转开放", IsOnCrossserver = false},					--[cq20]【翅膀-影翼合成】装备
    CondId83 = {RoleLevel = 300, RoleCircle = 5,OpenServerDay = 15, Tip = "开服第15天5转开放", IsOnCrossserver = false}, --[cq20]【翅膀-影翼,第7-12种开放限制】

	CondId130 = {RoleLevel = 70, Tip = "达到70级开放", IsOnCrossserver = false}, 								--[cq20]【锻造按钮】主界面图标的显示
	CondId127 = {RoleLevel = 70, Tip = "达到70级开放", IsOnCrossserver = false}, 								--[cq20]【锻造-强化系统】
	CondId204 = {RoleLevel = 300, RoleCircle = 2,Tip = "达到2转开放", IsOnCrossserver = false}, 				--[cq20]【锻造-精炼系统】
	CondId128 = {RoleLevel = 80, Tip = "达到80级开放", IsOnCrossserver = false}, 								--[cq20]【锻造-镶嵌系统】
	CondId129 = {RoleCircle = 3,Tip = "达到3转开放", IsOnCrossserver = false}, 									--[cq20]【锻造-鉴定系统】
	CondId7 = {RoleLevel = 0, RoleCircle = 7, OpenServerDay = 30, Tip = "开服第30天7转开放"}, 					--[cq20]【锻造-融合系统】切面按钮显示
	CondId8 = {RoleLevel = 0, RoleCircle = 8, OpenServerDay = 40, Tip = "开服第40天8转开放"}, 					--[cq20]【锻造-融合系统】功能开放

	CondId133 = {RoleLevel = 300, Tip = "热血300级开启", IsOnCrossserver = false},  							--[cq20]【热血】图标
	CondId138 = {RoleLevel = 300, Tip = "达到300级开放",IsOnCrossserver = false}, 								--[cq20]【热血神装-功能】显示条件主界面
	CondId142 = {RoleCircle = 2, Tip = "达到2转开放", IsOnCrossserver = false}, 								--[cq20]【热血神装-副装-开启条件】
	CondId131 = {RoleCircle = 2, Tip = "达到2转开放", IsOnCrossserver = false}, 								--[cq20]【热血神装-副装-灭霸手套】
	CondId143 = {RoleCircle = 5, Tip = "达到5转开放", IsOnCrossserver = false}, 								--[cq20]【热血神装-副装-战宠合成】
	CondId144 = {RoleCircle = 9,Tip = "达到9转开放", IsOnCrossserver = false}, 									--[cq20]【热血神装-副装-翅膀合成】
	CondId14 = {RoleCircle = 3,OpenServerDay = 3,Tip = "达到3转开放", IsOnCrossserver = false}, 				--[cq20]【热血神装-神铸】
	
	CondId145 = {RoleLevel = 300, RoleCircle = 0,Tip = "达到300级开放", IsOnCrossserver = false}, 				--[cq20]【特戒】
	CondId146 = {RoleLevel = 300, RoleCircle = 0,Tip = "达到300级开放", IsOnCrossserver = false}, 				--[cq20]【特戒-合成】
	CondId147 = {RoleCircle = 5,Tip = "达到5转开放", IsOnCrossserver = false}, 									--[cq20]【特戒-融合】
	CondId148 = {RoleCircle = 5,Tip = "达到5转开放", IsOnCrossserver = false}, 									--[cq20]【特戒-分离】
	CondId126 = {RoleLevel = 180, Tip = "达到180级开放", IsOnCrossserver = false}, 								--[cq20]【合成系统】
    CondId87 = {RoleLevel = 350, Tip = "达到350级开放", IsOnCrossserver = false}, 								--[cq20]【汽车图鉴】
    CondId88 = {RoleLevel = 350, Tip = "达到350级开放", IsOnCrossserver = false}, 								--[cq20]【战鼓系统(威望)】
	CondId24 = {RoleLevel = 250, Tip = "达到250级开放", IsOnCrossserver = false}, 								--[cq20]【探索宝藏】
	CondId77 = {RoleLevel = 250, Tip = "达到250级开放", IsOnCrossserver = false}, 								--[cq20]【福利大厅】
    CondId79 = {RoleLevel = 250, Tip = "达到250级开放", IsOnCrossserver = false}, 								--[cq20]【日常活动】
    CondId71 = {RoleLevel = 30, Tip = "达到30级开放", IsOnCrossserver = false}, 								--[cq20]【排行榜】
	CondId149 = {RoleLevel = 250,Tip = "达到250级开启", IsOnCrossserver = false}, 								--[cq20]【红包开启】
	CondId121 = {RoleLevel = 300, Tip = "达到300级开放", IsOnCrossserver = false}, 								--[cq20]【切割系统】
	CondId119 = {RoleCircle = 6,Tip = "达到6转开放", IsOnCrossserver = false},									--[cq20]【星魂系统】
	CondId122 = {RoleCircle = 6, OpenServerDay = 8, Tip = "开服第8天6转开放", IsOnCrossserver = false}, 		--[cq20]【星魂-星魂守护】
	CondId150 = {RoleCircle = 4,  Tip = "达到4转开放", IsOnCrossserver = false}, 				 				--[cq20]【通天塔】	
	CondId58 = {RoleLevel = 50, Tip = "达到50级开放", IsOnCrossserver = false}, 								--[cq20]【战宠系统】
	--CondId59 = {RoleLevel = 400, Tip = "达到400级开放"}, 														--[cq20]【战宠】(废弃)
    CondId104 = {RoleLevel = 68, Tip = "达到68级开放", IsOnCrossserver = false}, 								--[cq20]【日常活动】
	CondId135 = {RoleLevel = 100, VipLevel = 2, Tip = "达到VIP2开放", IsOnCrossserver = false}, 				--[cq20]【守护神装】
	CondId136 = {RoleLevel = 100, VipLevel = 2, Tip = "达到VIP2开放", IsOnCrossserver = false}, 				--[cq20]【守护商店】	
	CondId76 = {RoleLevel = 200, Tip = "达到200级开放"}, 														--[cq20]【商城】
	CondId117 = {RoleLevel = 100, Tip = "达到100级开放", IsOnCrossserver = false}, 								--[cq20]【祈福】
    CondId78 = {RoleLevel = 180, Tip = "达到180级开放",IsOnCrossserver = false}, 								--[cq20]【新激战BOSS】
	CondId132 = {RoleLevel = 300, Tip = "达到300级开放",IsOnCrossserver = false}, 								--[cq20]【蚩尤结界】
	CondId115 = {RoleLevel = 300, Tip = "达到300级开放", EquipRecycleAll = false,IsOnCrossserver = false},		--[cq20]【钻石回收-永久】
	condId141 = {RoleLevel = 300, OpenServerRange = {1, 7}, Tip = "达到300级开放",IsOnCrossserver = false}, 	--[cq20]【钻石回收限时】
    CondId109 = {RoleLevel = 1, Tip = "达到1级开放",IsOnCrossserver = false},								--[cq20]【特权卡】
	CondId120 = {RoleLevel = 300, OpenServerDay = 5, Tip = "开服第5天300级开放",IsOnCrossserver = false}, 		--人物--豪装
	CondId151 = {RoleCircle = 8, OpenServerDay = 8, Tip = "开服第8天8转开放",IsOnCrossserver = false}, 			--激战BOSS-热血霸者
	CondId152 = {RoleCircle = 9, Tip = "达到9转开放",IsOnCrossserver = false}, 									--激战BOSS-神威秘境
	CondId153 = {RoleCircle = 8, Tip = "达到8转开放",IsOnCrossserver = false}, 									--激战BOSS-魔域圣殿
	CondId124 = {RoleLevel = 300, LoginReward = true, Tip = "达到300级开放",IsOnCrossserver = false}, 			--[cq20]【登录奖励】
	CondId96 = {RoleLevel = 300,IsOnCrossserver = false, Tip = "达到300级开放"}, 								-- 物品寄售
	CondId134 = {RoleLevel = 250, Tip = "达到250级开放",IsOnCrossserver = false}, 								--[cq20]【护送押镖】
	CondId137 = {RoleLevel = 250, OutOfPrint = true, Tip = "达到250级开放",IsOnCrossserver = false}, 			--[cq20]【绝版抢购2 图标开放】
	CondId139 = {RoleLevel = 190, Tip = "达到190级开放",IsOnCrossserver = false}, 								--[cq20]【钻石萌宠】
	CondId140 = {RoleLevel = 270, Tip = "达到270级开放",IsOnCrossserver = false}, 								--[cq20]【试炼显示】
	CondId51 = {RoleLevel = 180,FirstChargeIsAllGet = false, IsOnCrossserver = false, Tip = "达到180级开放"},	--[cq20]【首充】可领取档位未被领取
    CondId90 = {RoleLevel = 180,IsOnCrossserver = false, Tip = "达到180级开放"}, 								--[cq20]【每日充值】
    CondId110 = {RoleLevel = 180, InvestmentReward = false, Tip = "达到180级开放",IsOnCrossserver = false},		--[cq20]【超值投资】
	CondId13 = {RoleLevel = 180, OpenServerDay = 1, Tip = "达到180级开放",}, 									--[cq20]【投资-返利】
	CondId16 = {RoleLevel = 1, OpenServerDay = 8, Tip = nil,}, 									--[cq20]【投资-豪礼】
    CondId108 = {RoleLevel = 180, IsOnCrossserver = false, Tip = "达到180级开放"},								--[cq20]【充值投资】
	CondId123 = {RoleLevel = 180, IsChargeGiftOpen = true, Tip = "达到180级开放",IsOnCrossserver = false}, 		--[cq20]【充值大礼包】
	CondId116 = {RoleLevel = 180, OutOfPrint = true, Tip = "达到180级开放",IsOnCrossserver = false},			--[cq20]【绝版抢购】功能开放
	CondId118 = {RoleLevel = 9999,IsHunHuanOpen = false, Tip = "达到9999级开放",IsOnCrossserver = false},		--[cq20]【魂环特惠】
	CondId64 = {RoleLevel = 200, OpenServerRange = {1, 3}, IsOnCrossserver = false, Tip = "达到200级开放"}, 	--[cq20]【经验炼制】
	CondId125 = {RoleLevel = 250, IsWelfreTurnbelOpen = false, Tip = "达到250级开放",IsOnCrossserver = false}, 	--[cq20]【福利转盘】
    CondId66 = {RoleLevel = 270, Tip = "达到270级开放",IsOnCrossserver = false}, 								--[cq20]【练功房-试炼】
    CondId67 = {RoleLevel = 140, Tip = "达到140级开放",IsOnCrossserver = false}, 								--[cq20]【副本总管】
    CondId68 = {RoleLevel = 140, Tip = "达到140级开放",IsOnCrossserver = false}, 								--[cq20]【材料副本】
    CondId69 = {RoleLevel = 300, Tip = "达到300级开放",IsOnCrossserver = false}, 								--[cq20]【经验副本】
    CondId73 = {RoleLevel = 250, IsOnCrossserver = false, Tip = "达到250级开放"}, 								--[cq20]【王城争霸】
    CondId74 = {RoleLevel = 250, IsOnCrossserver = false, Tip = "达到250级开放"}, 								--[cq20]【行会系统】
    CondId20 = {RoleLevel = 300, IsOnCrossserver = false, Tip = "达到300级开放"}, 																			--[cq20]【行会悬赏】
	CondId5 = {RoleLevel = 11, Tip = "达到11级开放",IsOnCrossserver = false},									-- 内功功能开放
	CondId6 = {InnerLevel = 1, Tip = "达到1级开放",IsOnCrossserver = false}, 									-- 内功装备开放

	--CondId13 = {RoleLevel = 45, OpenServerDay = 3, Tip = "开服第3天开放"}, 			-- 神炉-烈焰神力开放
	--CondId14 = {RoleLevel = 50, OpenServerDay = 5, Tip = "开服第5天开放"}, 			-- 神炉-抗暴神技开放
	--CondId16 = {RoleLevel = 10, Tip = "达到10级开放"}, 								-- 角色神装开放
	CondId18 = {RoleCircle = 10, OpenServerDay = 15, Tip = "开服第15天10转开放"},	 							-- 角色轮回开放
	--CondId19 = {RoleLevel = 60, OpenServerDay = 1, Tip = "达到60级开放"}, 			-- 角色必杀开放
	CondId21 = {RoleLevel = 1, Tip = "达到1级开放",IsOnCrossserver = false}, 									--[cq20]【装扮系统】开放
	CondId23 = {RoleLevel = 45, Tip = "达到45级开放",IsOnCrossserver = false}, 									-- 经脉开放
	CondId26 = {RoleLevel = TaskGoodGiftConfig.openlimitLevel, IsZsTaskAllGet = true,IsOnCrossserver = false},	--[cq20]【钻石任务】开放
	CondId27 = {RoleLevel = 280, Tip = "达到280级开放",IsOnCrossserver = false}, 								--[cq20]【任务引导】钻石任务
	CondId28 = {RoleLevel = 320,IsOnCrossserver = false}, 														--[cq20]【任务引导】天书任务
	CondId60 = {RoleLevel = 190, Tip = "达到190级开放",IsOnCrossserver = false}, 								-- 降妖除魔
	CondId61 = {RoleLevel = 40, Tip = "达到40级开放",IsOnCrossserver = false}, 									-- 神鼎
	CondId62 = {HaveGuild = true, Tip = "还没有加入行会",IsOnCrossserver = false}, 								-- 有行会
	CondId63 = {HaveGuild = false}, 																			-- 没有行会
	CondId65 = {RoleLevel = 61, OpenServerRange = {1, 4}, IsOnCrossserver = false, Tip = "达到61级开放"}, 		-- 限时任务开放条件
	CondId72 = {RoleLevelRange = {1, 59}, Tip = "{colorandsize;ff2828;21;60级开启}",IsOnCrossserver = false}, 	-- 必杀技能预览
    CondId85 = {RoleLevel = 10, IsOnCrossserver = false, Tip = "达到10级开放"}, 								-- 历练
	-- CondId89 = {RoleLevel = 1000, Tip = "达到1000级开放"}, 													-- 转生修为轮回业力可兑换
    CondId98 = {RoleLevel = 70, IsOnCrossserver = false, Tip = "达到70级开放"}, 								-- 发现BOSS
    CondId99 = {RoleLevel = 70,Tip = "达到70级开放",IsOnCrossserver = false}, 									-- 未知暗殿
    CondId100 = {RoleLevel = 70,Tip = "达到70级开放",IsOnCrossserver = false}, 									-- 威望任务
    CondId101 = {RoleLevel = 250,Tip = "达到250级开放",IsOnCrossserver = false}, 								-- 行会禁地组队
    CondId102 = {RoleLevel = 80,Tip = "达到80级开放",IsOnCrossserver = false}, 									-- 多人副本
    CondId105 = {RoleLevel = 9999, CombindDayRange = {999, 9999}, IsOnCrossserver = false}, 					-- 合服特惠
	CondId81 = {RoleLevel = 9999,OpenServerRange = {999, 9999}, IsOnCrossserver = false},						-- 开服活动
    CondId80 = {RoleLevel = 9999, IsOnCrossserver = false, Tip = "达到9999级开放"}, 							-- 超值特惠礼包
    CondId160 = {RoleLevelRange = {1, 299},IsOnCrossserver = false}, 											-- 自动做任务按钮
	
-------------------------------------------
--运营活动东西
-------------------------------------------
	CondId103 = {RoleLevel = 200,IsActBrilliantOpen = 1,}, 											-- 精彩活动
	CondId208 = {RoleLevel = 200,IsActBrilliantOpen = 2,}, 											-- 精彩活动
	CondId209 = {RoleLevel = 200,IsActBrilliantOpen = 3,}, 											-- 精彩活动
	CondId210 = {RoleLevel = 200,IsActBrilliantOpen = 4,}, 											-- 精彩活动

    -- CondId106 = {IsYuanBaoZPOpen = false,}, 											-- 运营活动33 豪华转盘
    CondId107 = {RoleLevel = 200,RoleCircle = 1, Tip = "转生达到1转开放"},								-- 珍宝阁
    CondId111 = {RoleLevel = 200,IsActCanbaogeOpen = true},												-- 藏宝阁
    CondId112 = {RoleLevel = 200,IsActBabelTowerOpen = true},											-- 通天塔
	CondId113 = {RoleLevel = 200,IsLimitChargeOpen = false,},											-- 限时充值
	CondId114 = {RoleLevel = 200,IsChargeFLOpen = false,},												-- 充值返利
	
-------------------------------------------
--跨服内东西
-------------------------------------------
    CondId75 = {RoleLevel = 300, OpenServerDay = 3, Tip = "开服第3天300级开放",IsOnCrossserver = false}, 				-- 跨服boss
    CondId84 = {RoleLevel = 300, Tip = "达到300级开放",IsOnCrossserver = false}, 									-- 跨服boss图标显示条件
	CondId52 = {OpenServerDay = PengLaiXianJieCfg.nOpendays}, 							-- 跨服BOSS蓬莱仙境开放
	CondId53 = {OpenServerDay = reincarnationHellCfg.OpenFuBenDay}, 					-- 跨服BOSS轮回地狱开放
	CondId54 = {OpenServerDay = flamingFantasyCfg.OpenFuBenDay}, 						-- 跨服BOSS烈焰幻境开放
	CondId55 = {OpenServerDay = dragonSoulSacredAreaCfg.OpenFuBenDay}, 					-- 跨服BOSS龙魂圣域开放
	CondId56 = {OpenServerDay = therionPalaceCfg.OpenFuBenDay}, 						-- 跨服BOSS圣兽宫殿开放
    CondId91 = {IsOnCrossserver = false, Tip = "跨服中不可操作"}, 						-- 邮件
    CondId92 = {IsOnCrossserver = false, Tip = "跨服中不可操作"}, 						-- VIP
    CondId93 = {IsOnCrossserver = false, Tip = "跨服中不可操作"}, 						-- 社交
    CondId94 = {IsOnCrossserver = false, Tip = "跨服中不可操作"}, 						-- 试炼经验奖励
    CondId95 = {IsOnCrossserver = false, Tip = "跨服中不可操作"}, 						-- 随身仓库
    CondId97 = {IsOnCrossserver = true}, 												-- 跨服中跨服BOSS面板红点可提醒


--进阶
	CondId201 = {RoleLevel = 320, Tip = "达到320级开放",IsOnCrossserver = false}, --魔书开放条件 
	CondId202 = {RoleCircle = 5, Tip = "达到5转开放",IsOnCrossserver = false}, --元素开放条件		
	CondId203 = {RoleCircle = 6, Tip = "达到6转开放",IsOnCrossserver = false}, --圣兽开放条件
	CondId204 = {RoleLevel = 300,Tip = "达到300级开放",IsOnCrossserver = false},--豪装合成开启条件
	CondId205 = {RoleLevel = 300,Tip = "达到300级开放",IsOnCrossserver = false}, 	--炼狱副本
	CondId206 = {RoleLevel = 320,Tip = "达到320级开放",IsOnCrossserver = false}, --练功房-挖矿
	CondId207 = {RoleCircle = 2,Tip = "达到2转开放",IsOnCrossserver = false}, --影翼合成
-----------------------------------------------------
}
-- 用于检查GameCond中的空索引 默认只打印20个
function CheckGameCond()
	local count = 0
	for i = 1, 250 do
		if GameCond["CondId" .. i] == nil then
			print("GameCond中的空索引", i)
			count = count + 1
			if count > 20 then
				break
			end
		end
	end
end
