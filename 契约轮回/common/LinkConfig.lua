--
-- @Author: LaoY
-- @Date:   2018-09-15 14:48:25
--

local unpack = unpack

--[[
@author LaoY
@des	跳转链接配置
@key 	string 			id@sub_id,如果sub_id为空。就取id
@param	name 			显示名字
@param 	id 				功能模块ID。不填会解析key值 未写出来，文件后统一处理
@param	sub_id 			功能模块对应的子ID。不填会解析key值 未写出来，文件后统一处理
@param	key_str 		功能模块对应的名称。用于取其他配置的关键字,OpenConfig IconConfig--------------要和OpenConfig.IconConfig的Key一样
@param	event_model 	注册事件的model。可不填，默认是 GlobalEvent
@param	event_name 		注册事件的key
@param	param 			默认传传参。可不填
@param	level 			模块开放等级条件。可不填，可读取对应的OpenConfig,用key_str
@param	task 			模块开放任务条件。可不填，可读取对应的OpenConfig,用key_str
@param	icon 			模块小图标。可不填，可读取对应的IconConfig,用key_str
@return number
一些特殊的跳转配置备注：
合成：id@sub_id@右侧标签栏@顶部菜单     例：170@1@2@203
--]]

----同一个界面下的东西，key一定要一样,sub_id照顺序来
local LinkConfig = {
    -- 角色模块
    ["100@1"] = { name = "Character", key_str = "role_info", event_model = nil, event_name = RoleInfoEvent.OpenRoleInfoPanel, param = 1 },
    --右下角的图表中，翅膀跟角色都有图标，key值可以不一样
    ["100@2"] = { name = "Wings", key_str = "vision", event_name = MountEvent.OPEN_VISION_PANEL, param = 2 }, --  2翅膀,  3法宝, 4神兵
    ["100@6"] = { name = "Title", key_str = "role_info", event_model = nil, event_name = RoleInfoEvent.OpenRoleTitlePanel, param = nil },
    ["100@7"] = { name = "Morph", key_str = "role_info", event_name = MountEvent.MOUNT_OPEN_HUAXING, param = nil }, --  幻化
    ["100@3"] = { name = "Talisman", key_str = "vision", event_name = MountEvent.OPEN_VISION_PANEL, param = 3 },
    ["100@4"] = { name = "Artifact", key_str = "vision", event_name = MountEvent.OPEN_VISION_PANEL, param = 4 },
    -- 背包模块
    ["110@1"] = { name = "Bag", key_str = "bag", event_name = BagEvent.OpenBagPanel, param = 1 },
    ["110@2"] = { name = "Warehouse", key_str = "bag", event_name = BagEvent.OpenBagPanel, param = 2 },
    ["110@3"] = { name = "Smelt", key_str = "bag", event_name = BagEvent.OpenBagSmeltPanel, param = nil },
    ["110@4"] = { name = "Unlock slot", key_str = "bag", event_name = BagEvent.OpenBagInputPanel, param = nil },
    ["110@6"] = { name = "Stigmata", key_str = "bag", event_name = BagEvent.OpenSoulPanel, param = 3 },

    --装备模块
    ["120@1"] = { name = "Enhance", key_str = "equip", event_name = EquipEvent.ShowEquipUpPanel, param = 1 },
    ["120@2"] = { name = "Socket", key_str = "equip", event_name = EquipEvent.ShowEquipUpPanel, param = 2 },
    ["120@3"] = { name = "Set", key_str = "equip", event_name = EquipEvent.ShowEquipUpPanel, param = 3 },
    ["120@4"] = { name = "Refine", key_str = "equip", event_name = EquipEvent.ShowEquipUpPanel, param = 4 },
    --["120@5"   {120,1,1,5,5,true} ] = { name = "铸造", key_str = "equip", event_name = EquipEvent.ShowEquipUpPanel, param = 5 },
    ["120@6"] = { name = "Crystal", key_str = "spar", event_name = EquipEvent.ShowEquipUpPanel, param = { 2, 2 } },
    --ui技能模块
    ["140@1"] = { name = "Skill", key_str = "skill", event_name = SkillUIEvent.OpenSkillUIPanel, param = nil },
    ["140@3"] = { name = "Talent", key_str = "skill", event_name = SkillUIEvent.OpenSkillUIPanel, param = 3 },

    --培养模块 坐骑翅膀等培养TRAIN_MOUNT = 1坐骑
    ["130@1"] = { name = "Mount", key_str = "mount", event_name = MountEvent.OPEN_MOUNT_PANEL, param = 1 },
    ["130@2"] = { name = "Off hand", key_str = "mount", event_name = MountEvent.OPEN_MOUNT_PANEL, param = 2 },


    ["150@1"] = { name = "Dungeon", key_str = "dungeon", event_name = DungeonEvent.REQUEST_ENTER_EXPDUNGEON, param = nil },
    ["150@2"] = { name = "Fighter's Path", key_str = "dungeon", event_name = DungeonEvent.REQUEST_ENTER_EXPDUNGEON, param = nil },

    ["160@1"] = { name = "World Boss", key_str = "worldBoss", event_name = DungeonEvent.DUNGEON_PANEL_OPEN, param = nil },
    ["160@5"] = { name = "Boss Home", key_str = "worldBoss", event_name = DungeonEvent.DUNGEON_PANEL_OPEN, param = nil },
    ["160@13"] = { name = "Mirage Island (Single)", key_str = "worldBoss", event_name = DungeonEvent.DUNGEON_PANEL_OPEN, param = nil },
    ["160@12"] = { name = "World Server", key_str = "cross", event_name = DungeonEvent.CROSS_PANEL_OPEN, param = nil },
    ["160@14"] = { name = "Cross-server Boss", key_str = "timeboss", event_name = DungeonEvent.CROSS_PANEL_OPEN, param = nil },
    ["160@15"] = { name = "Mirage Island (Cross-server)", key_str = "cross", event_name = DungeonEvent.CROSS_PANEL_OPEN, param = nil },
    ["160@16"] = { name = "Island battle", key_str = "siegewar", event_name = SiegewarEvent.OpenSiegewarPanel, param = nil },
    ["160@17"] = { name = "时空裂缝", key_str = "spacetimecrack", event_name = DungeonEvent.OpenSpaceTimeCrackDungePanel, param = nil },
    --合成模块
    ["170@1"] = { name = "Combine", key_str = "combine", event_name = CombineEvent.OpenCombinePanel, param = 1 },

    --商城模块
    ["180@1"] = { name = "Shop", key_str = "shop", event_name = ShopEvent.OpenShopPanel, param = 2 },
    ["181@1"] = { name = "Elf trial", key_str = "fairytiyan", event_name = ShopEvent.OpenFairyTiyanPanel, param = nil },

    --称号界面
    ["240@4"] = { name = "Title", key_str = "title", event_name = TitleEvent.OpenTitlePanel, param = nil },
    ["240@11"] = { name = "Portrait Frame", key_str = "chat_frame", event_name = FashionEvent.OpenDecoPanel, param = 2 },
    ["240@12"] = { name = "Bubble", key_str = "chat_frame", event_name = FashionEvent.OpenDecoPanel, param = 1 },

    --帮派
    ["210@1"] = { name = "Guild", key_str = "guild", event_name = FactionEvent.OpenFactionPanel, param = nil },
    ["210@3"] = { name = "Guild warehouse", key_str = "guild", event_name = FactionEvent.OpenFactionPanel, param = nil },

    --帮派战==》主宰神殿
    ["210@5"] = { name = "Temple of Domination", key_str = "guildTemple", event_name = FactionEvent.Faction_OpenTempleEvent, param = nil },
    --以下测试模块
    ["600@1"] = { name = "Awaken", key_str = "wake", event_name = WakeEvent.OpenWakePanel, param = nil },

    ["190@1"] = { name = "Treasure Hunt", key_str = "searchtreasure", event_name = SearchTreasureEvent.OpenSearchPanel, param = nil },
    ["190@2"] = { name = "Peak Hunting", key_str = "searchtreasure", event_name = SearchTreasureEvent.OpenSearchPanelTop, param = nil },
    ["190@3"] = { name = "Point Exchange", key_str = "searchtreasure", event_name = SearchTreasureEvent.OpenSearchPanelScore, param = nil },
    ["190@4"] = { name = "Mecha Hunt", key_str = "searchtreasure", event_name = SearchTreasureEvent.OpenSearchPanelGundam, param = nil },

    -- 福利模块
    ["500@1"] = { name = "Benefit", key_str = "welfare", event_name = WelfareEvent.Welfare_OpenEvent, param = nil },
    --魔法卡
    ["220@1"] = { name = "Soul Card", key_str = "card", event_name = CardEvent.CARD_OPEN, param = 1 },

    -- 魔法卡寻宝
    ["230@1"] = { name = "Soul Card Hunt", key_str = "mttreasure", event_name = MagictowerTreasureEvent.OpenMtTreasurePanel, param = 1 },

    --时装
    ["240@1"] = { name = "Costume", key_str = "fashion", event_name = FashionEvent.OpenFashionPanel, param = nil },

    --市场系统
    ["250@1"] = { name = "Market", key_str = "market", event_name = MarketEvent.OpenMarketPanel, param = nil },

    --天书
    ["260@1"] = { name = "Skill Vault", key_str = "book", event_name = BookEvent.OpenBookPanel, param = nil },

    --日常
    ["270@1"] = { name = "Daily", key_str = "daily", event_name = DailyEvent.OpenDailyPanel, param = nil },

    --赠礼
    ["280@1"] = { name = "Gift", key_str = "sendgift", event_name = FriendEvent.OpenSendGiftPanel, param = nil },
    --添加好友
    ["281@1"] = { name = "Add friend", key_str = "add_friend", event_name = FriendEvent.OpenAddFriendPanel, param = nil },

    ["290@1"] = { name = "Leaderboard", key_str = "rank", event_name = RankEvent.OpenRankPanel, param = nil },
    --神兽 300系列的@ling,其它人自已定个百位数
    ["300@1"] = { name = "Beast", key_str = "beast", event_name = BeastEvent.BEAST_OPEN, param = nil },
    ["1600@1"] = { name = "Beast", key_str = "beast", event_name = BeastEvent.BEAST_OPEN, param = nil },
    --竞技 300系列的@ling,其它人自已定个百位数
    ["310@1"] = { name = "PK", key_str = "athletics", event_name = AthleticsEvent.ATHLETICS_OPEN, param = 3 },
    ["311@1"] = { name = "Brawl", key_str = "melee", event_name = AthleticsEvent.ATHLETICS_OPEN, param = 10111 },
    ["314@1"] = { name = "Brawl (Cross-server)", key_str = "meleeCross", event_name = AthleticsEvent.ATHLETICS_OPEN, param = 10112 },
    ["313@1"] = { name = "Guild Guard", key_str = "guildGuard", event_name = FactionEvent.OPEN_GUILD_GUARD, param = nil },

    ["400@1"] = { name = "Escort", key_str = "escort", event_name = FactionEscortEvent.FactionEscortDoublePanel, param = nil },
    --充值
    ["401@2"] = { name = "Recharge", key_str = "recharge", event_name = VipEvent.OpenVipPanel, param = 2 },
    ["401@6"] = { name = "Become VIP 4", key_str = "recharge", event_name = VipEvent.OpenVFourPanel, param = 2 },
    ["402@1"] = { name = "VIP Trial", key_str = "viptiyan", event_name = VipEvent.OpenVipTiyanPanel, param = nil },
    ["403@1"] = { name = "VIP expired", key_str = "vipexpire", event_name = VipEvent.OpenVipExpirePanel, param = nil },
    --悬赏令
    ["405@1"] = { name = "Wanted", key_str = "wanted", event_name = WantedEvent.OpenWantedPanel, param = 2 },
    --糖果屋
    ["1000@1"] = { name = "Candy House", key_str = "candy", event_name = CandyEvent.OpenEnterEnterHousePanel, param = nil },
    --首充
    ["840@1"] = { name = "First recharge", key_str = "firstPay", event_name = FirstPayEvent.OpenFirstPayPanel, param = nil },
    ["841@1"] = { name = "0.1元首充", key_str = "firstPayDime", event_name = FirstPayEvent.OpenFirstPayDimePanel, param = nil },
    -- /*模块内容比较多，单独占领800 - 900*/
    -- 运营活动模块
    ["800@1"] = { name = "New-server Feast", key_str = "welfare", event_name = EventName.TestModel, param = 1 },
    --七天登录
    ["810@1"] = { name = "7-day Login", key_str = "sevenDay", event_name = SevenDayEvent.OpenSevenDayPanel, param = 1 },
    --每日累充
    ["820@1"] = { name = "Daily Recharge", key_str = "dailyRecharge", event_name = DailyRechargeEvent.OpenDailyRechargePanel, param = nil },
    --七天活动
    ["830@1"] = { name = "7-day List Rush", key_str = "sevenDayActive", event_name = SevenDayActiveEvent.OpenSevenDayActivePanel, param = 1 },
    ["830@2"] = { name = "Snap up", key_str = "sevenDayActive", event_name = SevenDayActiveEvent.OpenSevenBuyPanel, param = 2 },
    ["830@3"] = { name = "Total Recharge", key_str = "sevenDayActive", event_name = SevenDayActiveEvent.OpenSevenDayRechargePanel, param = 3 },
    ["830@4"] = { name = "Single-day Recharge", key_str = "sevenDayActive", event_name = SevenDayActiveEvent.OpenSevenDayRechargeOnePanel, param = 4 },
    ["830@5"] = { name = "Daily Goal", key_str = "sevenDayActive", event_name = SevenDayActiveEvent.OpenSevenDayTargePanel, param = 5 },
    --0元礼包
    ["850@1"] = { name = "Free Pack", key_str = "freeGift", event_name = FreeGiftEvent.OpenFreeGiftPanel, param = 5 },
    --开服狂欢
    ["870@1"] = { name = "Outraged", key_str = "openHigh", event_name = OpenHighEvent.MainBtnClick, param = 1 },
    ["870@2"] = { name = "Perfect Lover", key_str = "openHigh", event_name = OpenHighEvent.MainBtnClick, param = 2 },
    ["870@3"] = { name = "Collect Character", key_str = "openHigh", event_name = OpenHighEvent.MainBtnClick, param = 3 },
    ["870@4"] = { name = "Create Guild", key_str = "openHigh", event_name = OpenHighEvent.MainBtnClick, param = 4 },
    ["870@5"] = { name = "Guild Clash", key_str = "openHigh", event_name = OpenHighEvent.MainBtnClick, param = 5 },
    --主题抽奖
    ["875@1"] = { name = "Leveling Lottery", key_str = "yylotterLevel", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@1" },
    ["875@2"] = { name = "Off-hand Lottery", key_str = "yylotterFushou", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@2" },
    ["875@3"] = { name = "Soulcard Lottery", key_str = "yylotterMCard", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@3" },
    ["875@4"] = { name = "Gryphon Lottery", key_str = "yylotterHorse", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@4" },
    ["875@5"] = { name = "Soulcard Lottery", key_str = "yylotterMCard2", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@5" },
    ["875@6"] = { name = "Fashion Lottery", key_str = "yylotterFashion", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@6" },
    ["875@7"] = { name = "Off-hand Lottery", key_str = "yylotterFushou2", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@7" },

    ["875@8"] = { name = "EXP Stigmata", key_str = "yylotterEXPSH", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@8" },
    ["875@9"] = { name = "Chase Soul Card", key_str = "yylotterMCardFollow", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@9" },
    ["875@10"] = { name = "Enhance Stigmata", key_str = "yylotterStrengthSH", event_name = SearchTreasureEvent.OpenYYLotteryPanel, param = "875@10" },

    --小R活动
    ["876@1"] = { name = "Griffin", key_str = "yySmallR_1", event_name = SearchTreasureEvent.OpenYYSmallRPanel, param = "876@1" },
    ["876@2"] = { name = "EXP Soul Card", key_str = "yySmallR_2", event_name = SearchTreasureEvent.OpenYYSmallRPanel, param = "876@2" },
    ["876@3"] = { name = "Legion Light", key_str = "yySmallR_3", event_name = SearchTreasureEvent.OpenYYSmallRPanel, param = "876@3" },
    ["876@4"] = { name = "T9 Necklace", key_str = "yySmallR_4", event_name = SearchTreasureEvent.OpenYYSmallRPanel, param = "876@4" },
    ["876@5"] = { name = "Phantom Gaunlets", key_str = "yySmallR_5", event_name = SearchTreasureEvent.OpenYYSmallRPanel, param = "876@5" },
    ["876@6"] = { name = "Purple Ring", key_str = "yySmallR_6", event_name = SearchTreasureEvent.OpenYYSmallRPanel, param = "876@6" },
    ["876@7"] = { name = "Purple Bracelet", key_str = "yySmallR_7", event_name = SearchTreasureEvent.OpenYYSmallRPanel, param = "876@7" },

    -- 神灵解封
    ["905@1"] = { name = "Avatar Unseal", key_str = "godtarget", event_name = GodEvent.OpenGodTargetPanel, param = "905@1" },

    ["999@1"] = { name = "Settings", key_str = "setting", event_name = SettingEvent.OpenPanel, param = nil },
    --["1100@1"] = { name = "角色信息", key_str = "role_info", event_name = RoleInfoEvent.OpenRoleInfoPanel, param = nil },
    ["550@1"] = { name = "Guild War", key_str = "guildBattle", event_name = FactionEvent.Faction_OpenGuildWithWarOpeningEvent, param = nil },
    ["560@1"] = { name = "Guild Camp", key_str = "guildHouse", event_name = FactionEvent.Faction_EnterGuildHouseEvent, param = nil },
    ["560@2"] = { name = "Enter from Guild Camp", key_str = "guildHouseEnter", event_name = FactionEvent.Faction_PreGuildHouseEvent, param = nil },
    ["312@1"] = { name = "Achievements", key_str = "achieve", event_name = AchieveEvent.OpenAchievePanel, param = nil },
    ["860@1"] = { name = "Pet", key_str = "pet", event_name = PetEvent.Pet_OpenPanelEvent, param = nil },

    ["1200@1"] = { name = "Get Married", key_str = "marry", event_name = MarryEvent.OpenMarryPanel, param = nil },
    ["1200@2"] = { name = "Ring", key_str = "marry", event_name = MarryEvent.OpenMarryRingPanel, param = nil },
    ["1200@5"] = { name = "Couple's Stage", key_str = "marry", event_name = MarryEvent.OpenMarryDungeonPanel, param = nil },

    ["1201@1"] = { name = "Invitation", key_str = "weddingparty", event_name = MarryEvent.OpenMarryInvitationPanel, param = nil },
    ["1201@2"] = { name = "Wedding Forecast", key_str = "marrymatching", event_name = MarryEvent.OpenMarryMatching, param = nil },


    ["570@1"] = { name = "Ace Duel", key_str = "combat1v1", event_name = PeakArenaEvent.OpenPeakArenaPanel, param = nil },
    ["571@1"] = { name = "Altar of Bravery", key_str = "warrior", event_name = WarriorEvent.OpenWarriorPanel, param = nil },
    ["580@1"] = { name = "Friends", key_str = "friend", event_name = MailEvent.OpenMailPanel, param = 1 },
    ["590@1"] = { name = "How to become stronger", key_str = "strong_guide", event_name = GuideEvent.ShowStrong, parma = nil },

    ["880@5"] = { name = "Quick V5", key_str = "petActive", event_name = SevenDayActiveEvent.OpenSevenDayPetVipPanel, param = 1 },
    ["880@2"] = { name = "First Pet Recharge", key_str = "petActive", event_name = SevenDayActiveEvent.OpenSevenDayPetRechargePanel, param = 1 },
    ["880@3"] = { name = "Pet Goal", key_str = "petActive", event_name = SevenDayActiveEvent.SevenDayPetTargetPanel, param = 1 },
    ["880@4"] = { name = "Limited Pet Purchase", key_str = "petActive", event_name = SevenDayActiveEvent.OpenSevenDayPetBuyPanel, param = 1 },
    ["880@1"] = { name = "Pet Ranking", key_str = "petActive", event_name = SevenDayActiveEvent.OpenSevenDayPetPanel, param = 1 },
    ["880@6"] = { name = "Pet Chest", key_str = "petActive", event_name = SevenDayActiveEvent.OpenSevenDayPetBoxPanel, param = 1 },

    --国庆活动
    ["890@1"] = { name = "Item Exchange", key_str = "nation", event_name = NationEvent.OpenNationPanel, param = 401 },
    ["890@2"] = { name = "Character Collection", key_str = "nation", event_name = NationEvent.OpenNationPanel, param = 402 },
    ["890@3"] = { name = "Feast Up", key_str = "nation", event_name = NationEvent.OpenNationPanel, param = 403 },
    ["890@4"] = { name = "Total Recharge", key_str = "nation", event_name = NationEvent.OpenNationPanel, param = 404 },
    ["890@5"] = { name = "Egg Smash", key_str = "nation", event_name = NationEvent.OpenNationPanel, param = 406 },
    ["890@6"] = { name = "Total Consumption", key_str = "nation", event_name = NationEvent.OpenNationPanel, param = 407 },
    ["890@7"] = { name = "Firework", key_str = "nation", event_name = NationEvent.OpenNationPanel, param = 730 },
    ["890@8"] = { name = "X-server Shopping", key_str = "nation", event_name = NationEvent.OpenNationPanel, param = 780 },

    --神灵活动
    ["900@1"] = { name = "Avatar Ranking", key_str = "godcele", event_name = GodCeleEvent.OpenSevenDayActivePanel, param = 1 },
    ["900@2"] = { name = "Avatar Goal", key_str = "godcele", event_name = GodCeleEvent.OpenSevenDayActivePanel, param = 2 },
    ["900@3"] = { name = "Total Consumption", key_str = "godcele", event_name = GodCeleEvent.OpenSevenDayActivePanel, param = 3 },
    ["900@4"] = { name = "Avatar Snap-up", key_str = "godcele", event_name = GodCeleEvent.OpenSevenDayActivePanel, param = 4 },
    ["900@5"] = { name = "Point Exchange", key_str = "godcele", event_name = GodCeleEvent.OpenSevenDayActivePanel, param = 5 },
    ["900@6"] = { name = "Divine Tower", key_str = "godcele", event_name = GodCeleEvent.OpenSevenDayActivePanel, param = 6 },

    --子女
    ["1300@1"] = { name = "Children System", key_str = "baby", event_name = BabyEvent.OpenBabyPanel, param = nil },

    ["1400@1"] = { name = "Avatar System", key_str = "god", event_name = GodEvent.OpenGodPanel, param = 1 },

    ["1410@1"] = { name = "Forge Hut", key_str = "casthouse", event_name = CasthouseEvent.OpenCasthousePanel, param = nil },

    ["1420@1"] = { name = "Limited Beast Offer", key_str = "beast_limit", event_name = ShopEvent.OpenBeastActivityPanel, param = nil },
    ["1420@2"] = { name = "MechaLimited Purchase", key_str = "gundam_limit", event_name = ShopEvent.OpenGundamLimitBuyPanel, param = nil },
    ["1420@3"] = { name = "宠装限购", key_str = "pet_limit", event_name = ShopEvent.OpenPetBuyPanel, param = nil },
    ["1420@4"] = { name = "Divine Limit purchase", key_str = "magic_limit", event_name = ShopEvent.OpenMagicBuyPanel, param = nil },
    ["1420@5"] = { name = "图腾限购", key_str = "totem_limit", event_name = ShopEvent.OpenTotemBuyPanel, param = nil },

    ["1430@1"] = { name = "Auto Mode", key_str = "auto_play", event_name = SettingEvent.AutoPlay, param = nil },

    ["895@1"] = { name = "Timed Tower Challenge", key_str = "limitTower", event_name = LimitTowerEvent.OpenLimitTowerPanel, param = nil },

    ["910@1"] = { name = "Recharge to get VIP", key_str = "vipfree", event_name = VipFreeEvent.OpenVipFreePanel, param = nil },

    ["920@1"] = { name = "Pack Up", key_str = "packmall", event_name = ShopEvent.OpenPackMallActivityPanel, param = nil },
    ["920@2"] = { name = "Pack Up", key_str = "packmall", event_name = ShopEvent.OpenPackMallActivityPanel, param = nil },
    ["920@3"] = { name = "Pack Up", key_str = "packmall", event_name = ShopEvent.OpenPackMallActivityPanel, param = nil },
    ["920@4"] = { name = "Pack Up", key_str = "packmall", event_name = ShopEvent.OpenPackMallActivityPanel, param = nil },

    -- 图鉴冲榜
    ["940@1"] = { name = "Atlas Ranking", key_str = "cardcele", event_name = SevenDayActiveEvent.OpenIllustratedRankPanel, param = nil },
    ["940@2"] = { name = "Limited Atlas", key_str = "cardcele", event_name = SevenDayActiveEvent.OpenIllustratedBuyPanel, param = nil },
    ["940@3"] = { name = "Atlas Recharge", key_str = "cardcele", event_name = SevenDayActiveEvent.OpenIllustratedRechargePanel, param = nil },
    ["940@4"] = { name = "Atlas Goals", key_str = "cardcele", event_name = SevenDayActiveEvent.OpenIllustratedTargetPanel, param = nil },
    ["940@5"] = { name = "Atlas Chest", key_str = "cardcele", event_name = SevenDayActiveEvent.OpenIllustratedBoxPanel, param = nil },
    -- 子女冲榜
    ["990@1"] = { name = "Children Ranking", key_str = "soncele", event_name = ChildActEvent.OpenChildRankPanel, param = nil },
    ["990@2"] = { name = "Limited Children Purchase", key_str = "soncele", event_name = ChildActEvent.OpenChildBuyPanel, param = nil },
    ["990@3"] = { name = "Children Recharge", key_str = "soncele", event_name = ChildActEvent.OpenChildRechargePanel, param = nil },
    ["990@4"] = { name = "Children's Goal", key_str = "soncele", event_name = ChildActEvent.OpenChildTargetPanel, param = nil },
    ["990@5"] = { name = "Children Chest", key_str = "soncele", event_name = ChildActEvent.OpenChildBoxPanel, param = nil },
    ["990@6"] = { name = "Point Exchange", key_str = "soncele", event_name = ChildActEvent.OpenChildShopPanel, param = nil },

    ["1500@1"] = { name = "Diamond Ring", key_str = "compete", event_name = CompeteEvent.OpenCompeteNoticePanel, param = nil },

    ["1700@1"] = { name = "2nd Week Recharge", key_str = "secPay", event_name = SecPayEvent.OpenFirstPayPanel, param = nil },

    ["950@1"] = { name = "Recharge Wheel", key_str = "dial", event_name = DialEvent.OpenRechaP, param = nil },

    ["960@1"] = { name = "Invest", key_str = "investment", event_name = IllInvestEvent.OpenIllInvestPanel, param = nil },


    ["970@1"] = { name = "Assist", key_str = "revivehelp", event_name = DungeonEvent.ShowHelpPanel, param = nil },

    --["980@1"] = { name = "连充活动", key_str = "act_recharge", event_name = ActRechargeEvent.OpenSeqRechaPanel, param = nil },

    ["1011@1"] = { name = "Mecha Racing", key_str = "race", event_name = RaceEvent.OpenRaceTipPanel, param = nil },
    ["1011@2"] = { name = "Mecha Race Quest", key_str = "raceTask", event_name = RaceEvent.StartRaceTask, param = nil },

    ["1450@1"] = { name = "Mecha System", key_str = "machinearmor", event_name = MachineArmorEvent.OpenMachineArmorPanel, param = nil },

    --合服7天活动
    ["1130@1"] = { name = "合服冲榜", key_str = "mergeSer", event_name = SevenDayActiveEvent.OpenMergeRankPanel, param = 1 },
    ["1130@2"] = { name = "合服抢购", key_str = "mergeSer", event_name = SevenDayActiveEvent.OpenMergeRankPanel, param = 2 },
    ["1130@3"] = { name = "合服累冲", key_str = "mergeSer", event_name = SevenDayActiveEvent.OpenMergeRankPanel, param = 3 },
    ["1130@4"] = { name = "合服目标", key_str = "mergeSer", event_name = SevenDayActiveEvent.OpenMergeRankPanel, param = 4 },

    ["1140@1"] = { name = "星之王座", key_str = "throneStar", event_name = ThroneStarEvent.OpenThronePanel, param = nil },
    ["1150@1"] = { name = "Rich Man", key_str = "richman", event_name = RichManEvent.OpenRichManPanel, param = nil },

    ["980@1"] = { name = "扭蛋机", key_str = "eggmachine", event_name = NationEvent.OpenEggMachinePanel, param = nil },

    ["5@11"] = { name = "限时冲榜", key_str = "timelimitedrush", event_name = TimeLimitedRushEvent.OpenTimeLimitedRushPanel, param = nil },

    ["1160@1"] = { name = "跨服工会战", key_str = "crossGuildWar", event_name = FactionSerWarEvent.EnterDungeon, param = nil },
    ["1160@2"] = { name = "跨服工会战预约", key_str = "crossResGuildWar", event_name = FactionSerWarEvent.OpenFactionSerWarPanel, param = nil },

    ["1170@1"] = { name = "幸运转盘", key_str = "luckywheel", event_name = LuckyWheelEvent.OpenLuckWheelPanel, param = nil },

    ["1180@1"] = { name = "超值福利", key_str = "worthWelfare", event_name = WorthWelfareEvent.OpenWorthWelfarePanel, param = nil },

    ["1460@1"] = { name = "神器系统", key_str = "artifact", event_name = ArtifactEvent.OpenArtifactPanel, param = nil },

    ["191@1"] = { name = "限时寻宝", key_str = "timeLimitedTreasureHunt", event_name = TimeLimitedTreasureHuntEvent.OpenTimeLimitedTreasureHuntPanel, param = nil },
    ["200@1"] = { name = "图腾", key_str = "totems", event_name = ToemsEvent.OpenToemsPanel, param = nil },

    ["1190@1"] = { name = "翻牌好礼", key_str = "flop_gift", event_name = FlopGiftEvent.OpenFlopGiftPanel, param = nil },

    -- 10000之后的不需要配置系统开放，系统等功能千万不要配置在这后面
    ["10000@1"] = { name = "Questionnaire", key_str = "questionnaire", event_name = RoleInfoEvent.OpenQuestionnaire, param = nil },

    --["10001@1"] = { name = "豪禮回饋", key_str = "otherWelfare", event_name = OtherWelfareEvent.OpenOtherWelSubPanel, param = nil },
    ["10002@1"] = { name = "商店评论", key_str = "Rating", event_name = OtherWelfareEvent.OpenRatingPanel, param = nil },

    ["10003@1"] = { name = "绑定", key_str = "bind", event_name = OtherWelfareEvent.OpenBindPanel, param = nil },

    ["10004@1"] = { name = "分享点赞", key_str = "share", event_name = OtherWelfareEvent.OpenSharePanel, param = nil },
}

local function HandleConfig()
    for key, config in pairs(LinkConfig) do
        if not config.id or not config.sub_id then
            local key_data = string.split(key, "@")
            config.id = config.id or tonumber(key_data[1])
            config.sub_id = config.sub_id or tonumber(key_data[2])
        end
        if not config.icon and config.key_str then
            config.icon = IconConfig[config.key_str]
        end
        if not config.level and config.key_str then
            config.level = OpenConfig[key] and OpenConfig[key].level
        end
        if not config.task and config.key_str then
            config.task = OpenConfig[key] and OpenConfig[key].task
        end
    end
end
HandleConfig()

function OpenLink(id, sub_id, ...)
    sub_id = sub_id or 1
    local config = GetOpenLink(id, sub_id)
    if not config then
        return
    end
    local system_event
    if config.event_model then
        system_event = config.event_model:GetInstance()
    else
        system_event = GlobalEvent
    end
    local param = { ... }
    if param then
        local token = false
        local is_need_del = false
        local neeed_del_num = 1
        if type(param) == "table" then
            local last = param[#param]
            --有最后一位
            if last then
                --true
                if last == "true" then
                    is_need_del = true
                    neeed_del_num = 2
                    token = true
                    --false
                elseif last == "false" then
                    is_need_del = true
                end
            end
        end
        if token then
            local sys_sub_id = param[#param - 1]
            if not OpenTipModel.GetInstance():IsOpenSystem(id, sys_sub_id) then
                local cf = Config.db_sysopen[id .. "@" .. sys_sub_id]
                if cf then
                    --没有任务
                    local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
                    if cf.task == 0 then
                        local lv = GetLevelShow(cf.level)
                        Notify.ShowText(string.format(ConfigLanguage.LevelShow.LevelLimit, lv))
                        --有任务
                    else
                        if cur_lv >= cf.level then
                            local name = Config.db_task[cf.task].name
                            Notify.ShowText(string.format(ConfigLanguage.LevelShow.TaskLimit, name))
                        else
                            Notify.ShowText(ConfigLanguage.LevelShow.SystemNotOpen)
                        end
                    end
                else
                    logError("该跳转配置里的第一位与倒数第二位,无法组成在sysopen中的key")
                end
                return
            end
        end
        --需要删除多余数据
        if is_need_del then
            for i = 1, neeed_del_num do
                table.remove(param, #param)
            end
        end
        if table.isempty(param) then
            param = config.param
        end
        if type(param) == "table" then
            system_event:Brocast(config.event_name, unpack(param))
        else
            system_event:Brocast(config.event_name, param)
        end
    else
        system_event:Brocast(config.event_name)
    end
end

--主界面图标跳转接口
function MainIconOpenLink(id, sub_id, ...)
    sub_id = sub_id or 1
    local config = GetOpenLink(id, sub_id)
    if not config then
        return
    end
    --local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    --if config.level and main_role_data.level < config.level then
    --	local str = "该功能" .. config.level .. "级开启"
    --	Notify.ShowText(str)
    --	return
    --end
    --if config.task and not TaskModel:GetInstance():IsFinishMainTask(config.task) then
    --	local cf = Config.db_task[config.task]
    --	if not cf then
    --		local str = "没有" .. config.task .. "这个任务"
    --		Notify.ShowText(str)
    --	end
    --	local str = "请先完成" .. cf.name .. "任务"
    --	Notify.ShowText(str)
    --	return
    --end
    local system_event
    if config.event_model then
        system_event = config.event_model:GetInstance()
    else
        system_event = GlobalEvent
    end
    local param = { ... }
    if table.isempty(param) then
        param = config.param
    end
    if param then
        if type(param) == "table" then
            system_event:Brocast(config.event_name, unpack(param))
        else
            system_event:Brocast(config.event_name, param)
        end
    else
        system_event:Brocast(config.event_name)
    end
end

function GetOpenLink(id, sub_id)
    if not id or not sub_id then
        return
    end
    local key = string.format("%s@%s", id, sub_id)
    return LinkConfig[key]
end

function GetOpenByKey(key)
    local tab = string.split(key, "@")
    return GetOpenLink(tab[1], tab[2])
end

--获取ab和asset 的名字
function GetLinkAbAssetName(id, sub_id)
    local linkCfg = GetOpenLink(id, sub_id)
    if linkCfg ~= nil then
        local cfgTbl = string.split(linkCfg.icon, ":")
        return cfgTbl[1], cfgTbl[2]
    end
end

--[[
@author LaoY
@des	是否达到开放等级、任务
--]]
function IsOpenModular(level, task)
    local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    if level and main_role_data and main_role_data.level and main_role_data.level < level then
        return false
    end
    if task and task ~= 0 and not TaskModel:GetInstance():IsFinishMainTask(task) then
        return false
    end
    return true
end

--[[
@author LaoY
@des    快速跳转
@param1 jump_str
--]]
function UnpackLinkConfig(jump_str)
    if not jump_str then
        return
    end
    local jump_tab
    if jump_str:find("@") then
        jump_tab = string.split(jump_str, "@")
        for i, v in pairs(jump_tab) do
            if tonumber(v) then
                jump_tab[i] = tonumber(v)
            end
        end
    elseif jump_str:find(",") then
        jump_tab = String2Table(jump_str)
    end
    if jump_tab then
        OpenLink(unpack(jump_tab))
    end
end